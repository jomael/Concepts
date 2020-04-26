{
  Copyright (C) 2013-2019 Tim Sinaeve tim.sinaeve@gmail.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
}

{$I DDuce.inc}

unit DDuce.Logger.Channels.ZeroMQ;

interface

{ Channel holding a ZeroMQ publisher socket where one or more Logviewers can
  subscribe to.

  The channel creates a PUB socket and binds it to its local IP address.
}

uses
  System.Classes, System.SysUtils,

  ZeroMQ,

  DDuce.Logger.Interfaces, DDuce.Logger.Channels.Base;

const
  DEFAULT_ENDPOINT = 'tcp://*:5555';

type
  TZeroMQChannel = class(TCustomLogChannel, ILogChannel, IZeroMQChannel)
  private
    FBuffer    : TStringStream;
    FZMQ       : IZeroMQ;
    FPublisher : IZMQPair;
    FPort      : Integer;
    FEndPoint  : string;
    FBound     : Boolean;

  protected
    {$REGION 'property access methods'}
    function GetZMQVersion: string;
    function GetEnabled: Boolean; override;
    function GetEndPoint: string;
    procedure SetEndPoint(const Value: string);
    function GetPort: Integer; override;
    function GetConnected: Boolean; override;
    {$ENDREGION}

    { The endpoint argument is a string consisting of two parts as follows:
      transport ://address. The transport part specifies the underlying
      transport protocol to use. The meaning of the address part is specific to
      the underlying transport protocol selected.
      Currently only tcp is supported as transport. }
    property EndPoint : string
      read GetEndPoint write SetEndPoint;

    property ZMQVersion: string
      read GetZMQVersion;

  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    constructor Create(
      const AEndPoint : string = '';
      AActive         : Boolean = True
    ); reintroduce; overload; virtual;

    function Connect: Boolean; override;
    function Disconnect: Boolean; override;

    function Write(const AMsg: TLogMessage): Boolean; override;

  end;

implementation

uses
  Spring, Spring.Helpers, Spring.SystemUtils,

  ZeroMQ.API;

{$REGION 'construction and destruction'}
constructor TZeroMQChannel.Create(const AEndPoint: string; AActive: Boolean);
begin
  inherited Create(AActive);
  FEndPoint := AEndPoint;
end;

procedure TZeroMQChannel.AfterConstruction;
begin
  inherited AfterConstruction;
  Guard.CheckTrue(
    FileExists(LIBZEROMQ),
    Format('ZeroMQ library (%s) is missing!', [LIBZEROMQ])
  );
  FBuffer := TStringStream.Create;
  FZMQ    := TZeroMQ.Create;
  if FEndPoint = '' then
  begin
    FEndPoint := DEFAULT_ENDPOINT;
  end;
  if Enabled then
  begin
    FBound := Connect;
  end;
end;

procedure TZeroMQChannel.BeforeDestruction;
begin
  if Assigned(FBuffer) then
  begin
    FBuffer.Free;
  end;
  if Assigned(FPublisher) then
  begin
    Disconnect;
  end;
  inherited BeforeDestruction;
end;
{$ENDREGION}

{$REGION 'property access methods'}
function TZeroMQChannel.GetEnabled: Boolean;
begin
  Result := Assigned(FZMQ) and inherited GetEnabled;
end;

function TZeroMQChannel.GetConnected: Boolean;
begin
  Result := FBound;
end;

function TZeroMQChannel.GetEndPoint: string;
begin
  Result := FEndPoint;
end;

procedure TZeroMQChannel.SetEndPoint(const Value: string);
begin
  if Value <> EndPoint then
  begin
    FEndPoint := Value;
  end;
end;

function TZeroMQChannel.GetPort: Integer;
begin
  Result := FPort;
end;

function TZeroMQChannel.GetZMQVersion: string;
var
  LMajor : Integer;
  LMinor : Integer;
  LPatch : Integer;
begin
  zmq_version(@LMajor, @LMinor, @LPatch);
  Result := Format('%d.%d.%d', [LMajor, LMinor, LPatch]);
end;
{$ENDREGION}

{$REGION 'public methods'}
{ Returns true if successful. }

function TZeroMQChannel.Connect: Boolean;
var
  S : string;
  A : TStringDynArray;
begin
  if Enabled then
  begin
    FPublisher := FZMQ.Start(ZMQSocket.Publisher);
    FBound := FPublisher.Bind(FEndPoint) = 0; // 0 when successful
    // Physical connection is always a bit after Connected reports True.
    // https://stackoverflow.com/questions/11634830/zeromq-always-loses-the-first-message
    if Connected then
    begin
      Sleep(100);
    end;
  end;
  if Connected then
  begin
    S := FPublisher.LastEndPoint;
    A := SplitString(S, [':']);
    FPort := StrToIntDef(A[High(A)], 0);
    FEndPoint := S;
  end;
  Result := Connected;
end;

{ Returns True if successful. }

function TZeroMQChannel.Disconnect: Boolean;
begin
  Result := True;
  if Connected then
  begin
    Result := FPublisher.Close;
    FBound := False;
  end;
end;

function TZeroMQChannel.Write(const AMsg: TLogMessage): Boolean;
const
  ZeroBuf: Integer = 0;
var
  TextSize : Integer;
  DataSize : Integer;
begin
  if Enabled then
  begin
    if not Connected and AutoConnect then
      Connect;
    if Connected then
    begin
      TextSize := Length(AMsg.Text);
      FBuffer.Seek(0, soFromBeginning);
      FBuffer.WriteBuffer(AMsg.MsgType);
      FBuffer.WriteBuffer(AMsg.LogLevel);
      FBuffer.WriteBuffer(AMsg.Reserved1);
      FBuffer.WriteBuffer(AMsg.Reserved2);
      FBuffer.WriteBuffer(AMsg.TimeStamp);
      FBuffer.WriteBuffer(TextSize);
      if TextSize > 0 then
      begin
        FBuffer.WriteBuffer(AMsg.Text[1], TextSize);
      end;
      if AMsg.Data <> nil then
      begin
        DataSize := AMsg.Data.Size;
        FBuffer.WriteBuffer(DataSize);
        AMsg.Data.Position := 0;
        FBuffer.CopyFrom(AMsg.Data, DataSize);
      end
      else
        FBuffer.WriteBuffer(ZeroBuf);
      Result := FPublisher.SendString(FBuffer.DataString) > 0;
    end
    else
    begin
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;
end;
{$ENDREGION}

end.
