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

unit DDuce.Logger.Interfaces;

interface

uses
  System.Classes, System.Rtti, System.SysUtils, System.Types, System.UITypes,
  Vcl.Menus, Vcl.Graphics, Vcl.Forms,
  Data.DB,

  Spring, Spring.Collections;

type
  { Remark: Enumerated types with explicitly assigned ordinality don't have RTTI
    generated for them. Enumerated constants without a specific value however
    do have RTTI.}
  TLogMessageType = (
    lmtInfo        = 0,
    lmtError       = 1,
    lmtWarning     = 2,
    lmtValue       = 3,
    lmtEnterMethod = 4,
    lmtLeaveMethod = 5,
    lmtConditional = 6,
    lmtCheckpoint  = 7,
    lmtStrings     = 8,   // TStrings and descendants
    lmtCallStack   = 9,   // not supported yet
    lmtComponent   = 10,
    lmtException   = 11,
    lmtBitmap      = 12,
    lmtHeapInfo    = 13,  // not supported yet
    lmtMemory      = 14,
    lmtCustomData  = 15,  // not supported yet
    lmtObject      = 16,
    lmtInterface   = 17,
    lmtPersistent  = 18,
    lmtWatch       = 20,
    lmtCounter     = 21,
    lmtColor       = 22,
    lmtAlphaColor  = 23,
    lmtScreenShot  = 24,
    lmtText        = 25,  // arbitrary text with optional highlighter info
    lmtDataSet     = 26,
    lmtAction      = 27,  // TAction execution
    lmtClear       = 99,
    lmtNone        = 100  // can be used as a default value
  );

  TLogMessageTypes = set of TLogMessageType;

  ILogger = interface;

  TLogMessage = packed record
    MsgType   : Byte; // TLogMessageType
    LogLevel  : Byte;
    Reserved1 : Byte;
    Reserved2 : Byte;
    TimeStamp : TDateTime;
    Text      : UTF8String;
    Data      : TStream;
  end;

  (*
    ProcessId                  source process Id (WinIPC, WinODS)
    ThreadId
    IpAddress                  source IP address (ZeroMQ)

  *)

  TCustomDataCallbackMethod = function(
    ASender     : ILogger;
    AData       : TValue;
    var ADoSend : Boolean
  ): string of object;

  TCustomDataCallbackFunction = function(
    ASender     : ILogger;
    AData       : TValue;
    var ADoSend : Boolean
  ): string;

  ILogChannel = interface
  ['{FDE37401-BB4F-4362-863A-CCCCF9228BD9}']
    {$REGION 'property access methods'}
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    function GetConnected: Boolean;
    function GetAutoConnect: Boolean;
    procedure SetAutoConnect(const Value: Boolean);
    {$ENDREGION}

    function Write(const AMsg: TLogMessage): Boolean;
    function Connect: Boolean;
    function Disconnect: Boolean;

    property Enabled: Boolean
      read GetEnabled write SetEnabled;

    { True when the channel is connected with the server (or receiving)
      instance. }
    property Connected: Boolean
      read GetConnected;
  end;

  ILogFileChannel = interface(ILogChannel)
  ['{AD38F81B-DC15-4295-B74D-B646CDF9831D}']
    {$REGION 'property access methods'}
    function GetFileName: string;
    procedure SetFileName(const Value: string);
    procedure SetShowTime(const AValue: Boolean);
    procedure SetShowDate(const Value: Boolean);
    function GetShowDate: Boolean;
    function GetShowHeader: Boolean;
    function GetShowPrefix: Boolean;
    function GetShowTime: Boolean;
    procedure SetShowHeader(const Value: Boolean);
    procedure SetShowPrefix(const Value: Boolean);
    {$ENDREGION}

    property FileName: string
      read GetFileName write SetFileName;

    property ShowHeader: Boolean
      read GetShowHeader write SetShowHeader;

    property ShowPrefix: Boolean
      read GetShowPrefix write SetShowPrefix;

    property ShowTime: Boolean
      read GetShowTime write SetShowTime;

    property ShowDate: Boolean
      read GetShowDate write SetShowDate;
  end;

  IZeroMQChannel = interface(ILogChannel)
  ['{7DC63C0E-1038-4416-84C3-9D8E76C9B929}']
    {$REGION 'property access methods'}
    function GetPort: Integer;
    function GetEndPoint: string;
    procedure SetEndPoint(const Value: string);
    function GetZMQVersion: string;
    {$ENDREGION}

    { Endpoint string consisting of transport, host/IP, port  }
    property EndPoint : string
      read GetEndPoint write SetEndPoint;

    property ZMQVersion: string
      read GetZMQVersion;

    property Port: Integer
      read GetPort;
  end;

  IMQTTChannel = interface(ILogChannel)
  ['{5D482099-AB68-462B-8EE8-CCE4DBB60C44}']
    {$REGION 'property access methods'}
    function GetPort: Integer;
    function GetBroker: string;
    procedure SetBroker(const Value: string);
    {$ENDREGION}
    { Hostname/IP of the MQTT broker }
    property Broker: string
      read GetBroker write SetBroker;

    property Port: Integer
      read GetPort;
  end;

  IWinIPCChannel = interface(ILogChannel)
  ['{E23B78DA-F62D-4D2B-A0FB-33C3CE106FFA}']
  end;

  TChannelList = IList<ILogChannel>;

  // TODO send TTimeSpan
  //      send stream?
  //      send file

  ILogger = interface
  ['{28E9BADE-6B42-4399-8867-1CA115576E40}']
    function GetChannels: TChannelList;
    function GetLogLevel: Byte;
    procedure SetLogLevel(const Value: Byte);

    procedure Send(const AName: string; const AArgs: array of const); overload;

    { These three overloads are here because TValue would cast them implicitely
      to string (and we would lose type information of AValue) }
    procedure Send(const AName: string; const AValue: AnsiString); overload;
    procedure Send(const AName: string; const AValue: WideString); overload;
    procedure Send(const AName: string; const AValue: ShortString); overload;
    procedure Send(const AName: string; const AValue: string); overload;

    { UInt8 = Byte }
    procedure Send(const AName: string; const AValue: Byte); overload;
    { UInt16 = Word }
    procedure Send(const AName: string; const AValue: Word); overload;
    { UInt32 = Cardinal = FixedUInt }
    procedure Send(const AName: string; const AValue: Cardinal); overload;
    { UInt64 }
    procedure Send(const AName: string; const AValue: UInt64); overload;
    { Int8 = ShortInt }
    procedure Send(const AName: string; const AValue: ShortInt); overload;
    { Int16 = SmallInt }
    procedure Send(const AName: string; const AValue: SmallInt); overload;
    { Int32 = Integer = FixedInt }
    procedure Send(const AName: string; const AValue: FixedInt); overload;

    { All types that can implicitely be casted to TValue will be handled
      through this call. }

    { These are (tested):
       Integer
       Single
       Double
       Extended
       Currency
       Int64
       UInt64
       Boolean

       TObject ?
       TClass ?
    }
    procedure Send(const AName: string; const AValue: TValue); overload;

    procedure Send(const AValue: AnsiString); overload;
    procedure Send(const AValue: WideString); overload;
    procedure Send(const AValue: ShortString); overload;
    procedure Send(const AValue: string); overload;

    procedure Send(const AValue: Byte); overload;
    procedure Send(const AValue: Word); overload;
    procedure Send(const AValue: Cardinal); overload;
    procedure Send(const AValue: UInt64); overload;
    procedure Send(const AValue: ShortInt); overload;
    procedure Send(const AValue: SmallInt); overload;
    procedure Send(const AValue: FixedInt); overload;

    procedure Send(const AValue: TValue); overload;

    { Send methods for types that do not have an implicit cast to TValue
      These are equivalent to Send(AName, TValue.From(AValue)); }
    procedure SendDateTime(const AName: string; AValue: TDateTime); overload;
    procedure SendDateTime(AValue: TDateTime); overload;
    procedure SendDate(const AName: string; AValue: TDate); overload;
    procedure SendDate(AValue: TDate); overload;
    procedure SendTime(const AName: string; AValue: TTime); overload;
    procedure SendTime(AValue: TTime); overload;

    { Send methods for types that need a custom representation. }
    procedure SendColor(const AName: string; AColor: TColor); overload;
    procedure SendColor(AColor: TColor); overload;
    procedure SendAlphaColor(const AName: string; AAlphaColor: TAlphaColor); overload;
    procedure SendAlphaColor(AAlphaColor: TAlphaColor); overload;
    procedure SendObject(const AName: string; AValue: TObject); overload;
    procedure SendObject(AValue: TObject); overload;
    { Logs interface properties. }
    procedure SendInterface(const AName: string; AValue: IInterface); overload;
    procedure SendInterface(AValue: IInterface); overload;
    { Logs published properties. }
    procedure SendPersistent(const AName: string; AValue: TPersistent); overload;
    procedure SendPersistent(AValue: TPersistent); overload;
    procedure SendRect(const AName: string; const AValue: TRect); overload;
    procedure SendRect(const AValue: TRect); overload;
    procedure SendPoint(const AName: string; const AValue: TPoint); overload;
    procedure SendPoint(const AValue: TPoint); overload;
    procedure SendStrings(const AName: string; AValue: TStrings); overload;
    procedure SendStrings(AValue: TStrings); overload;
    procedure SendComponent(const AName: string; AValue: TComponent); overload;
    procedure SendComponent(AValue: TComponent); overload;
    procedure SendPointer(const AName: string; AValue: Pointer); overload;
    procedure SendPointer(AValue: Pointer); overload;
    procedure SendException(const AName: string; AValue: Exception); overload;
    procedure SendException(AValue: Exception); overload;
    procedure SendBitmap(const AName: string; AValue: TBitmap); overload;
    procedure SendBitmap(AValue: TBitmap); overload;
    procedure SendScreenShot(const AName: string; AForm: TCustomForm); overload;
    procedure SendScreenShot(AForm: TCustomForm); overload;
    procedure SendDataSet(const AName: string; AValue: TDataSet); overload;
    procedure SendDataSet(AValue: TDataSet); overload;
    procedure SendShortCut(const AName: string; AValue: TShortCut); overload;
    procedure SendShortCut(AValue: TShortCut); overload;
    procedure SendVariant(const AName: string; const AValue: Variant); overload;
    procedure SendVariant(const AValue: Variant); overload;

    procedure SendMemory(
      const AName: string;
      AAddress   : Pointer;
      ASize      : LongWord
    );

    { Send methods for (optionally named) text that optionally can be displayed
      with a dedicated highlighter. }
    procedure SendText(
      const AName        : string;
      const AText        : string;
      const AHighlighter : string = ''
    ); overload;
    procedure SendText(const AText: string); overload;

    procedure SendSql(const AName: string; const AValue: string); overload;
    procedure SendSql(const AValue: string); overload;
    procedure SendXml(const AName: string; const AValue: string); overload;
    procedure SendXml(const AValue: string); overload;
    procedure SendHtml(const AName: string; const AValue: string); overload;
    procedure SendHtml(const AValue: string); overload;
    procedure SendIni(const AName: string; const AValue: string); overload;
    procedure SendIni(const AValue: string); overload;
    procedure SendJson(const AName: string; const AValue: string); overload;
    procedure SendJson(const AValue: string); overload;

    procedure IncCounter(const AName: string);
    procedure DecCounter(const AName: string);
    procedure ResetCounter(const AName: string);
    function GetCounter(const AName: string): Integer;

    procedure Enter(const AName: string); overload;
    procedure Enter(ASender: TObject; const AName: string); overload;
    procedure Leave(const AName: string); overload;
    procedure Leave(ASender: TObject; const AName: string); overload;
    { Track uses an interface variable to replace Enter/Leave calls in the
      scope of the method where it is called. A call to Track will create an
      instance and trigger the Enter method. When the interface variable goes
      out of scope (end of the routine or method) a call to the logger's Leave
      method is triggered. }
    function Track(const AName: string): IInterface; overload;
    function Track(ASender: TObject; const AName: string): IInterface; overload;

    procedure Action(AAction: TBasicAction);

    procedure AddCheckPoint(const AName: string = '');
    procedure ResetCheckPoint(const AName: string = '');

    { Monitors a named value in the LogViewer application }
    procedure Watch(const AName: string; const AValue: TValue); overload;
    procedure Watch(const AName: string; const AValue: string = ''); overload;
    procedure Watch(const AName: string; const AValue: ShortString); overload;
    procedure Watch(const AName: string; const AValue: AnsiString); overload;
    procedure Watch(const AName: string; const AValue: WideString); overload;

    procedure Warn(const AText: string); overload;
    procedure Warn(
      const AText : string;
      const AArgs : array of const
    ); overload;
    procedure Error(const AText: string); overload;
    procedure Error(
      const AText : string;
      const AArgs : array of const
    ); overload;
    procedure Info(const AText: string); overload;
    procedure Info(
      const AText: string;
      const AArgs: array of const
    ); overload;

    procedure SendIf(
      const AText : string;
      AExpression : Boolean;
      AIsTrue     : Boolean = True
    );
    { Sends out a dedicated message to clear the logviewer contents. }
    procedure Clear;

    property LogLevel: Byte
      read GetLogLevel write SetLogLevel;

    property Channels: TChannelList
      read GetChannels;
  end;

const
  LOG_PREFIXES: array [lmtInfo..lmtAction] of string = (
    'INFO',
    'ERROR',
    'WARNING',
    'VALUE',
    '>>ENTER METHOD',
    '<<LEAVE METHOD',
    'CONDITIONAL',
    'CHECKPOINT',
    'STRINGS',
    'CALL STACK',
    'OBJECT',
    'EXCEPTION',
    'BITMAP',
    'HEAP INFO',
    'MEMORY',
    '',
    '',
    '',
    '',
    '',
    'WATCH',
    'COUNTER',
    'COLOR',
    'ALPHACOLOR',
    'SCREENSHOT',
    'TEXT',
    'DATASET',
    'ACTION'
  );

function LogMessageTypeNameOf(ALogMessageType: TLogMessageType): string;

implementation

{$REGION 'interfaced routines'}
function LogMessageTypeNameOf(ALogMessageType: TLogMessageType): string;
var
  S : string;
begin
  case ALogMessageType of
    lmtInfo        : S := 'lmtInfo';
    lmtError       : S := 'lmtError' ;
    lmtWarning     : S := 'lmtWaring';
    lmtValue       : S := 'lmtValue';
    lmtEnterMethod : S := 'lmtEnterMethod';
    lmtLeaveMethod : S := 'lmtLeaveMethod';
    lmtConditional : S := 'lmtConditional';
    lmtCheckpoint  : S := 'lmtCheckpoint';
    lmtStrings     : S := 'lmtStrings';
    lmtCallStack   : S := 'lmtCallStack';
    lmtComponent   : S := 'lmtComponent';
    lmtException   : S := 'lmtException';
    lmtBitmap      : S := 'lmtBitmap';
    lmtHeapInfo    : S := 'lmtHeapInfo';
    lmtMemory      : S := 'lmtMemory';
    lmtCustomData  : S := 'lmtCustomData';
    lmtObject      : S := 'lmtObject';
    lmtInterface   : S := 'lmtInterface';
    lmtPersistent  : S := 'lmtPersistent';
    lmtWatch       : S := 'lmtWatch';
    lmtCounter     : S := 'lmtCounter';
    lmtColor       : S := 'lmtColor';
    lmtAlphaColor  : S := 'lmtAlphaColor';
    lmtScreenShot  : S := 'lmtScreenShot';
    lmtText        : S := 'lmtText';
    lmtClear       : S := 'lmtClear';
    lmtDataSet     : S := 'lmtDataSet';
    lmtAction      : S := 'lmtAction';
  else
    S := '';
  end;
  Result := S;
end;
{$ENDREGION}

end.
