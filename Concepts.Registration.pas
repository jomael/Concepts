{
  Copyright (C) 2013-2020 Tim Sinaeve tim.sinaeve@gmail.com

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

unit Concepts.Registration;

{ Handles registration of all supported concept forms. }

interface

uses
  Vcl.Graphics;

{$I Concepts.inc}

type
  TConcepts = record
  strict private
    class var FCategoryColor : TColor;

    class procedure RegisterSpringConcepts; static;
    class procedure RegisterDSharpConcepts; static;
    class procedure RegisterDevExpressConcepts; static;
    class procedure RegisterSystemConcepts; static;
    class procedure RegisterVclConcepts; static;
    class procedure RegisterWinApiConcepts; static;
  public
    class procedure RegisterConcepts; static;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,

  {$REGION 'Concept form units'}
  {$IFDEF WINAPI}
  Concepts.Winapi.LockPaint.Form,
  {$ENDIF}

  {$IFDEF VCL}
  Concepts.Vcl.GridPanel.Form,
  {$IFDEF DELPHIX_SEATTLE_UP}
  Concepts.Vcl.RelativePanel.Form,
  {$ENDIF}
  {$ENDIF}

  {$IFDEF FIREDAC}
  Concepts.FireDAC.Form,
  {$ENDIF}

  {$IFDEF SYSTEM}
  Concepts.System.RTTI.Form,
  Concepts.System.Variants.Form,
  Concepts.System.Threads.Form,
  Concepts.System.RegularExpressions.Form,
  Concepts.System.LiveBindings.Form,
  Concepts.System.Threading.Form,
  Concepts.System.Libraries.Form,
  Concepts.System.AnonymousMethods.Form,
  Concepts.System.InterfaceImplementationByAggregation.Form,
  Concepts.System.StringList.Form,
  Concepts.System.VirtualMethodInterceptor.Form,
  Concepts.System.VirtualInterface.Form,
  Concepts.System.PublishedFields.Form,
  Concepts.System.Interfaces.Form,
  {$ENDIF}

  {$IFDEF DEVEXPRESS}
  Concepts.DevExpress.cxEditors.Form,
  Concepts.DevExpress.cxGridViewPresenter.Form,
  {$ENDIF}

  {$IFDEF DSHARP}
  Concepts.DSharp.TreeViewPresenter.Tree.Form,
  Concepts.DSharp.TreeViewPresenter.List.Form,
  {$ENDIF}

  {$IFDEF SPRING}
  Concepts.Spring.ClassProxy.Form,
  Concepts.Spring.Interception.Form,
  Concepts.Spring.Collections.Form,
  Concepts.Spring.LazyInstantiation.Form,
  Concepts.Spring.MulticastEvents.Form,
  Concepts.Spring.ObjectDataSet.Form,
  Concepts.Spring.Logging.Form,
  Concepts.Spring.Types.Form,
  Concepts.Spring.Utils.Form,
  Concepts.Spring.Persistence.Form,
  {$ENDIF}

  {$IFDEF BTMEMORYMODULE}
  Concepts.BTMemoryModule.Form,
  {$ENDIF}

  {$IFDEF SQLBUILDER4D}
  Concepts.SQLBuilder4D.Form,
  {$ENDIF}

  {$IFDEF CHROMETABS}
  Concepts.ChromeTabs.Form,
  {$ENDIF}

  {$IFDEF BCEDITOR}
  Concepts.BCEditor.Form,
  {$ENDIF}

  {$IFDEF DDETOURS}
  Concepts.DDetours.Form,
  {$ENDIF}

  {$IFDEF DELPHIZMQ}
  Concepts.ZeroMQ.Form,
  {$ENDIF}

  {$IFDEF ZOBJECTINSPECTOR}
  Concepts.zObjectInspector.Form,
  {$ENDIF}
  {$ENDREGION}

  {$IFDEF SYNAPSE}
  Concepts.Synapse.Serial.Form,
  {$ENDIF}

  {$IFDEF INDY}
  Concepts.Indy.TCP.Form,
  Concepts.Indy.Telnet.Form,
  {$ENDIF}

  {$IFDEF SYNEDIT}
  Concepts.SynEdit.Form,
  {$ENDIF}

  {$IFDEF VIRTUALTREES}
  Concepts.VirtualTreeView.Form,
  {$ENDIF}

  Concepts.SynMemoEx.Form,
  Concepts.MQTT.Form,

  Concepts.FMXContainer.Form,

  Concepts.Manager;

const
  SPRING_CATEGORY_COLOR     = $00DDFFDD;
  DSHARP_CATEGORY_COLOR     = $00B0FFFF;
  DEVEXPRESS_CATEGORY_COLOR = $00C1E0FF;
  SYSTEM_CATEGORY_COLOR     = $00E1E1FF;
  VCL_CATEGORY_COLOR        = $00FFD9D9;
  WINAPI_CATEGORY_COLOR     = clWhite;

procedure EnsureZMQLibExists;
const
  LIBZMQ = 'libzmq';
var
  LResStream  : TResourceStream;
  LFileStream : TFileStream;
  LPath       : string;
begin
  LPath := Format('%s\%s.dll', [ExtractFileDir(ParamStr(0)), LIBZMQ]);
  if not FileExists(LPath) then
  begin
    LResStream := TResourceStream.Create(HInstance, LIBZMQ, RT_RCDATA);
    try
      LFileStream := TFileStream.Create(LPath, fmCreate);
      try
        LFileStream.CopyFrom(LResStream, 0);
      finally
        LFileStream.Free;
      end;
    finally
      LResStream.Free;
    end;
  end;
end;

{$REGION 'private methods'}
class procedure TConcepts.RegisterSpringConcepts;
begin
  {$IFDEF SPRING}
  FCategoryColor := SPRING_CATEGORY_COLOR;
  ConceptManager.Register(
    TfrmCollections,
    'Collections',
    'Spring',
    'Spring collections demo.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmMultiCastEvents,
    'Multicast events',
    'Spring',
    'Spring multicast events (Event<T> - IEvent<T).',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmLazyInstantiation,
    'Lazy instantiation',
    'Spring',
    'Lazy instantiation example (Lazy<T> - ILazy<T>).',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmSpringInterception,
    'Interception',
    'Spring',
    'Aspect Oriented Programming demo.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmObjectDataSet,
    'Persistence',
    'Spring',
    'TObjectDataSet demo',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmSpringPersistence,
    'ORM',
    'Spring',
    'Spring entities',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmSpringLogging,
    'Logging',
    'Spring',
    'Spring Logging system',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmSpringTypes,
    'Types',
    'Spring',
    'Spring utility types.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmSpringUtils,
    'Utils',
    'Spring',
    'Utillity classes and routines.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmClassProxy,
    'ClassProxy',
    'Spring',
    'Interception',
    FCategoryColor
  );
  {$ENDIF}
end;

class procedure TConcepts.RegisterDSharpConcepts;
begin
  {$IFDEF DSHARP}
  FCategoryColor := DSHARP_CATEGORY_COLOR;
  ConceptManager.Register(
    TfrmTreeViewPresenterList,
    'TreeViewPresenter list',
    'DSharp',
    'TreeViewPresenter list.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmTreeViewPresenterTree,
    'TreeViewPresenter tree',
    'DSharp',
    'TreeViewPresenter tree.',
    FCategoryColor
  );
  {$IFDEF DEVEXPRESS}
  ConceptManager.Register(
    TfrmcxGridViewPresenter,
    'Presenters',
    'DSharp',
    'Specialized presenters.',
    FCategoryColor
  );
  {$ENDIF}
  {$ENDIF}
end;

class procedure TConcepts.RegisterDevExpressConcepts;
begin
  {$IFDEF DEVEXPRESS}
  FCategoryColor := DEVEXPRESS_CATEGORY_COLOR;
  ConceptManager.Register(
    TfrmcxEditors,
    'cxEditors',
    'DevExpress',
    'Demonstrates the DevExpress edit controls.',
    FCategoryColor
  );
  {$ENDIF}
end;

class procedure TConcepts.RegisterSystemConcepts;
begin
  {$IFDEF SYSTEM}
  FCategoryColor := SYSTEM_CATEGORY_COLOR;
  ConceptManager.Register(
    TfrmLibraries,
    'Libraries',
    'System',
    'Demonstrates dynamic loading of libraries.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmRTTI,
    'RTTI',
    'System',
    'Demonstrates the extended RTTI.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmVariants,
    'Variants',
    'System',
    'Demonstrates some operations on Variants.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmLiveBindings,
    'LiveBindings',
    'System',
    'Demonstrates Delphi''s LiveBindings system.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmRegularExpressions,
    'Regular Expressions',
    'System',
    'Demonstrates support for regular expressions in the RTL.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmThreading,
    'Parallel library',
    'System',
    'Demonstrates the System.Threading library introduced in Delphi XE7.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmThreads,
    'Threads',
    'System',
    'Demonstrates some basic threading scenarios and primitives.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmAnonymousMethods,
    'Anonymous methods',
    'System',
    'Demonstrates anonymous methods and features like variable capturing.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmInterfaceImplementationByAggregation,
    'Interface implementation by aggregation',
    'System',
    'Demonstrates how an object can implement an interface by delegating ' +
    'the implementation to an object property.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmVirtualInterfaceDemo,
    'TVirtualInterface demo',
    'System',
    'Demonstrated how a TVirtualInterface object can be created that implements ' +
    'any IInvokable ($M+) descendant at runtime.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmVirtualMethodInterceptor,
    'TVirtualMethodInterceptor demo.',
    'System',
    'TODO',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmStringList,
    'TStringList',
    'System',
    'Demonstrates some TStringList features.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmPublishedFields,
    'Published fields',
    'System',
    'Demonstrates a form with components without published fields.',
    FCategoryColor
  );
  ConceptManager.Register(
    TfrmInterfaces,
    'Interfaces',
    'System',
    'Demonstrates how object interfaces work.',
    FCategoryColor
  );
  {$ENDIF}
end;

class procedure TConcepts.RegisterVclConcepts;
begin
  {$IFDEF VCL}
  FCategoryColor := VCL_CATEGORY_COLOR;
  ConceptManager.Register(
    TfrmGridPanel,
    'Grid panel',
    'Vcl',
    'Demonstrates the TGridPanel VCL component.',
    FCategoryColor
  );
  {$IFDEF DELPHIX_SEATTLE_UP}
  ConceptManager.Register(
    TfrmRelativePanel,
    'Relative panel',
    'Vcl',
    'Demonstrates the TRelativePanel VCL component.',
    FCategoryColor
  );
  {$ENDIF}
  {$ENDIF}
end;

class procedure TConcepts.RegisterWinApiConcepts;
begin
  {$IFDEF WINAPI}
  FCategoryColor := WINAPI_CATEGORY_COLOR;
  ConceptManager.Register(
    TfrmLockPaint,
    'LockPaint',
    'WinApi',
    'Demonstrates LockPaint/UnlockPaint routines.',
    FCategoryColor
  );
  {$ENDIF}
end;
{$ENDREGION}

{$REGION 'public methods'}
class procedure TConcepts.RegisterConcepts;
begin
  {$IFDEF ZOBJECTINSPECTOR}
  ConceptManager.Register(
    TfrmzObjectInspector,
    'TzObjectInspector',
    'TzObjectInspector',
    'TzObjectInspector component demo.'
  );
  {$ENDIF}

  {$IFDEF DELPHIZMQ}
  ConceptManager.Register(
    TfrmZMQConcept,
    'ZeroMQ',
    'ZeroMQ',
    'ZeroMQ demo.'
  );
  {$ENDIF}

  ConceptManager.Register(
    TfrmMQTTNode,
    'MQTT',
    'MQTT',
    'MQTT demo.'
  );

  {$IFDEF DDETOURS}
  ConceptManager.Register(
    TfrmDDetours,
    'DDetours',
    'DDetours',
    'DDetours library demo.'
  );
  {$ENDIF}

  {$IFDEF BCEDITOR}
  ConceptManager.Register(
    TfrmBCEditor,
    'BCEditor',
    'BCEditor',
    'TBCEditor component demo.'
  );
  {$ENDIF}

  {$IFDEF SYNEDIT}
  ConceptManager.Register(
    TfrmSynEdit,
    'SynEdit',
    'SynEdit',
    'Demonstrates the TSynEdit component'
  );
  {$ENDIF}

  {$IFDEF BTMEMORYMODULE}
  ConceptManager.Register(
    TfrmBTMemoryModule,
    'BTMemoryModule',
    'BTMemoryModule',
    'Demonstrates how to load a DLL direct from memory.'
  );
  {$ENDIF}

  {$IFDEF SQLBUILDER4D}
  ConceptManager.Register(
    TfrmSQLBuilder4D,
    'TfrmSQLBuilder4D',
    'TfrmSQLBuilder4D',
    'Demonstrates the SQLBuilder4D library.'
  );
  {$ENDIF}

  {$IFDEF CHROMETABS}
  ConceptManager.Register(
    TfrmChromeTabs,
    'ChromeTabs',
    'TChromeTabs',
    'TChromeTabs component demo.'
  );
  {$ENDIF}

//  ConceptManager.Register(
//    TfrmRTTEye,
//    'RTTEye',
//    'System',
//    'Reflection-like overview using the extended RTTI.'
//  );

  {$IFDEF SYNAPSE}
  ConceptManager.Register(
    TfrmSynapseSerial,
    'Synapse',
    'Serial',
    'Serial communication with the Synapse library.'
  );
  {$ENDIF}

  {$IFDEF INDY}
  ConceptManager.Register(
    TfrmIndyTCP,
    'TCP',
    'Indy',
    'Indy TCP client'
  );
  ConceptManager.Register(
    TfrmIndyTelnet,
    'Telnet',
    'Indy',
    'Indy Telnet client'
  );
  {$ENDIF}

  {$IFDEF FMXCONTAINER}
  ConceptManager.Register(
    TfrmFMXContainer,
    'TFireMonkeyContainer',
    'FMXContainer',
    'Demonstrates the Parnassus TFireMonkeyContainer component.'
  );
  {$ENDIF}

  {$IFDEF VIRTUALTREES}
  ConceptManager.Register(
    TfrmVirtualTreeView,
    'Virtual treeview',
    'TVirtualStringTree',
    'Demonstrates the TVirtualStringTree component.'
  );
  {$ENDIF}

  ConceptManager.Register(
    TfrmSynMemoEx,
    'SynMemoEx',
    'TMemoEx',
    'TMemoEx component from mORMot framework'
  );

  RegisterSpringConcepts;
  RegisterDSharpConcepts;
  RegisterDevExpressConcepts;
  RegisterSystemConcepts;
  RegisterVclConcepts;
  RegisterWinApiConcepts;
 end;
{$ENDREGION}

initialization
  EnsureZMQLibExists;

end.
