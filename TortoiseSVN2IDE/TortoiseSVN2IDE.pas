//===================================================================================================//
//  ϰ����Windows��Դ��������TortoiseSVN���Ҽ����Ĳ˵����ٿ�IDE���ɻ����е�Ӣ�Ľ��棬�о��е㲻ˬ��  //
//  ���ǾͰ�TortoiseSVN�Ĳ˵������ʾ�Ի��򶼺����ɼ������ĵ��ˡ�������������TortoiseSVN 1.4.1�ٷ�   //
//  ��ʽ���Ӣ��--�������Ķ��ձ�����һ��Ч�������ԡ�                                               //
//                                                           ------Modified by С��ɵ�              //
//                                                                  2006.12.26                       //
//===================================================================================================//
//  �޸�ԭ���Ĳ˵�����Ϊö������, ������ɾ�˵������, ���Ҳ˵��������ֱ�ӵ���,����Ҫ�ٸ��²˵����. //
//                                                           ------Modified by lvcn                  //
//                                                                  2013.11.05                       //
//===================================================================================================//

unit TortoiseSVN2IDE;

{$R 'icons.res'}

interface

uses ToolsAPI, SysUtils, Windows, Dialogs, Menus, Registry, ShellApi,
  Classes, Controls, Graphics, ImgList, ExtCtrls, ActnList, Forms, TypInfo;
type
  TSvnMenuType = (
    SVN_PROJECT_EXPLORER, //�������Ŀ¼
    SVN_LOG, //�鿴Ŀ¼��־
    SVN_LOG_FILE, //��ѯ��ǰ�ļ���־��Ϣ
    SVN_CHECK_MODIFICATIONS, //������
    SVN_UPDATE, //����
    SVN_ADD, //����ļ�
    SVN_COMMIT, //�ύ
    SVN_COMMIT_FILE, //�ύ��ǰ�ļ�
    SVN_REVERT, //��ԭ
    SVN_DIFF, //����Ƚ�
    SVN_REPOSITORY_BROWSER, //����汾��
    SVN_SETTINGS, //����
    SVN_ABOUT //����
    );

type
  TTortoiseSVN = class(TNotifierObject, IOTANotifier, IOTAWizard)
  private
    timer: TTimer;
    tsvnMenu: TMenuItem;
    TSVNPath: string;
    procedure Tick(sender: tobject);
    procedure TSVNExec(params: string);
    function GetBitmapName(Index: Integer): string;
    function GetVerb(Index: Integer): string;
    function GetVerbState(Index: Integer): Word;
    procedure ExecuteVerb(Index: Integer);
    procedure CreateMenu;
    procedure UpdateAction(sender: TObject);
    procedure ExecuteAction(sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
  end;

{$IFNDEF DLL_MODE}

procedure Register;

{$ELSE}

function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;

{$ENDIF}

implementation

function GetCurrentProject: IOTAProject;
var
  ModServices: IOTAModuleServices;
  Module: IOTAModule;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  i: Integer;
begin
  Result := nil;
  ModServices := BorlandIDEServices as IOTAModuleServices;
  if ModServices <> nil then
    for i := 0 to ModServices.ModuleCount - 1 do
    begin
      Module := ModServices.Modules[i];
      if Supports(Module, IOTAProjectGroup, ProjectGroup) then
      begin
        Result := ProjectGroup.ActiveProject;
        Exit;
      end
      else if Supports(Module, IOTAProject, Project) then
      begin // In the case of unbound packages, return the 1st
        if Result = nil then
          Result := Project;
      end;
    end;
end;

function GetCurrentFileName: string;
var
  editor: IOTAEditorServices;
begin
  result := '';
  editor := BorlandIDEServices as IOTAEditorServices;
  if editor <> nil then
  begin
    if editor.TopBuffer <> nil then
      result := editor.TopBuffer.FileName;
  end;
end;

constructor TTortoiseSVN.Create;
var
  reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('\SOFTWARE\TortoiseSVN') then
      TSVNPath := Reg.ReadString('ProcPath');
  finally
    Reg.CloseKey;
    Reg.Free;
  end;

  tsvnMenu := nil;

  timer := TTimer.create(nil);
  timer.interval := 200;
  timer.OnTimer := tick;
  timer.enabled := true;

end;

procedure TTortoiseSVN.Tick(sender: tobject);
var
  intf: INTAServices;
begin
  if BorlandIDEServices.QueryInterface(INTAServices, intf) = s_OK then
  begin
    self.createMenu;
    timer.free;
    timer := nil;
  end;
end;

procedure TTortoiseSVN.CreateMenu;
var
  mainMenu: TMainMenu;
  item: TMenuItem;
  i: integer;
  bmp: TBitmap;
  action: TAction;
  pi: PTypeInfo;
  smt: TSvnMenuType;
  s: string;
begin
  if tsvnMenu <> nil then
    exit;

  tsvnMenu := TMenuItem.Create(nil);
  tsvnMenu.Caption := 'TortoiseSVN';
  pi := TypeInfo(TSvnMenuType);
  with GetTypeData(pi)^ do
  begin
    for i := MinValue to MaxValue do
    begin
      //s :=   GetEnumName(pi,i);
      //smt := TSvnMenuType(GetEnumValue(pi,s));
      bmp := TBitmap.create;
      try
        bmp.LoadFromResourceName(HInstance, getBitmapName(i));
      except
        break;
      end;

      action := TAction.Create(nil);
      action.ActionList := (BorlandIDEServices as INTAServices).ActionList;
      action.Caption := getVerb(i);
      action.Hint := getVerb(i);
      if (bmp.Width = 16) and (bmp.height = 16) then
        action.ImageIndex := (BorlandIDEServices as INTAServices).AddMasked(bmp,
          clBlack);
      bmp.free;
      action.OnUpdate := updateAction;
      action.OnExecute := executeAction;
      action.Tag := i;

      item := TMenuItem.Create(tsvnMenu);
      item.action := action;

      tsvnMenu.add(item);
    end;
  end;

  mainMenu := (BorlandIDEServices as INTAServices).MainMenu;
  mainMenu.Items.Insert(mainMenu.Items.Count - 1, tsvnMenu);
end;

destructor TTortoiseSVN.Destroy;
begin
  if tsvnMenu <> nil then
  begin
    tsvnMenu.free;
  end;
  inherited;
end;

function TTortoiseSVN.GetBitmapName(Index: Integer): string;
var
  smt: TSvnMenuType;
begin
  smt := TSvnMenuType(Index);
  case smt of
    SVN_PROJECT_EXPLORER:
      Result := 'explorer';
    SVN_LOG, SVN_LOG_FILE:
      Result := 'log';
    SVN_CHECK_MODIFICATIONS:
      Result := 'check';
    SVN_ADD:
      Result := 'add';
    SVN_UPDATE:
      Result := 'update';
    SVN_COMMIT, SVN_COMMIT_FILE:
      Result := 'commit';
    SVN_DIFF:
      Result := 'diff';
    SVN_REVERT:
      Result := 'revert';
    SVN_REPOSITORY_BROWSER:
      Result := 'repository';
    SVN_SETTINGS:
      Result := 'settings';
    SVN_ABOUT:
      Result := 'about';
  end;
end;

function TTortoiseSVN.GetVerb(Index: Integer): string;
var
  smt: TSvnMenuType;
begin
  smt := TSvnMenuType(Index);
  case smt of
    SVN_PROJECT_EXPLORER:
      Result := '�����Ŀ�ļ���[&P]...'; //'&Project explorer...';
    SVN_LOG:
      Result := '��־[&L]...'; //'&Log...';
    SVN_CHECK_MODIFICATIONS:
      Result := '������[&M]...'; //'Check &modifications...';
    SVN_ADD:
      Result := '���[&A]...'; //'&Add...';
    SVN_UPDATE:
      Result := '����Ϊĳһ�汾[&U]...'; //'&Update to revision...';
    SVN_COMMIT:
      Result := '�ύ[&C]...'; //'&Commit...';
    SVN_DIFF:
      Result := '����Ƚ�[&D]...'; //'&Diff...';
    SVN_REVERT:
      Result := '��ԭ[&R]...'; //'&Revert...';
    SVN_REPOSITORY_BROWSER:
      Result := '����汾��[&B]...'; //'Repository &browser...';
    SVN_SETTINGS:
      Result := '����[&S]...'; //'&Settings...';
    SVN_ABOUT:
      Result := '����...'; //'&About...'; ԭ��ݼ������Add��ͻ��
    SVN_LOG_FILE:
      Result := '��ǰ�ļ���־[&F]...'; //'&Log...';
    SVN_COMMIT_FILE:
      Result := '�ύ��ǰ�ļ�...'; // ���û����ӿ�ݼ� ������Զ��ṩһ��
  end;
end;

const
  vsEnabled = 1;

function TTortoiseSVN.GetVerbState(Index: Integer): Word;

var
  smt: TSvnMenuType;
begin
  Result := 0;
  smt := TSvnMenuType(Index);
  case smt of
    SVN_PROJECT_EXPLORER:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    SVN_LOG, SVN_LOG_FILE:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    SVN_CHECK_MODIFICATIONS:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    SVN_ADD:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    SVN_UPDATE:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    SVN_COMMIT, SVN_COMMIT_FILE:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    SVN_DIFF:
      if GetCurrentFileName <> '' then
        Result := vsEnabled;
    SVN_REVERT:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    SVN_REPOSITORY_BROWSER:
      Result := vsEnabled;
    SVN_SETTINGS:
      Result := vsEnabled;
    SVN_ABOUT:
      Result := vsEnabled;
  end;
end;

procedure TTortoiseSVN.TSVNExec(params: string);
begin
  WinExec(pchar(TSVNPath + ' ' + params), SW_SHOW);
end;

procedure TTortoiseSVN.ExecuteVerb(Index: Integer);
var
  project: IOTAProject;
  filename: string;
  smt: TSvnMenuType;
begin
  project := GetCurrentProject();
  filename := getCurrentFileName();
  smt := TSvnMenuType(Index);
  case smt of
    SVN_PROJECT_EXPLORER:
      if project <> nil then
        ShellExecute(0, 'open', pchar(ExtractFilePath(project.GetFileName)), '',
          '', SW_SHOWNORMAL);
    SVN_LOG:
      if project <> nil then
        TSVNExec('/command:log /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
    SVN_CHECK_MODIFICATIONS:
      if project <> nil then
        TSVNExec('/command:repostatus /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
    SVN_ADD:
      if project <> nil then
        TSVNExec('/command:add /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
    SVN_UPDATE:
      if project <> nil then

        if
          Application.MessageBox('����֮ǰ�����е���Ŀ�ļ����������档�����𣿡���', '��ʾ', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          //if MessageDlg( '����֮ǰ�����е���Ŀ�ļ����������档������', mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then begin
          (BorlandIDEServices as IOTAModuleServices).saveAll;
          TSVNExec('/command:update /rev /notempfile /path:' +
            AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
        end;
    SVN_COMMIT:
      if project <> nil then
        if
          Application.MessageBox('�ύ֮ǰ�����е���Ŀ�ļ����������档�����𣿡���', '��ʾ', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          //if MessageDlg( '�ύ֮ǰ�����е���Ŀ�ļ����������档������', mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then begin
          (BorlandIDEServices as IOTAModuleServices).saveAll;
          TSVNExec('/command:commit /notempfile /path:' +
            AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
        end;
    SVN_DIFF:
      if filename <> '' then
        TSVNExec('/command:diff /notempfile /path:' + AnsiQuotedStr(filename,
          '"'));
    SVN_REVERT:
      if project <> nil then
        TSVNExec('/command:revert /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
    SVN_REPOSITORY_BROWSER:
      if project <> nil then
        TSVNExec('/command:repobrowser /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'))
      else
        TSVNExec('/command:repobrowser');
    SVN_SETTINGS:
      TSVNExec('/command:settings');
    SVN_ABOUT:
      TSVNExec('/command:about');
    SVN_LOG_FILE:
      if filename <> '' then
        TSVNExec('/command:log /notempfile /path:' + AnsiQuotedStr(filename,
          '"'));
    SVN_COMMIT_FILE:
      if filename <> '' then
        TSVNExec('/command:commit /notempfile /path:' + AnsiQuotedStr(filename,
          '"'));
  end;
end;

procedure TTortoiseSVN.UpdateAction(sender: TObject);
var
  action: TAction;
begin
  action := sender as TAction;
  action.Enabled := getVerbState(action.tag) = vsEnabled;
end;

procedure TTortoiseSVN.ExecuteAction(sender: TObject);
var
  action: TAction;
begin
  action := sender as TAction;
  executeVerb(action.tag);
end;

function TTortoiseSVN.GetIDString: string;
begin
  result := 'Subversion.TortoiseSVN';
end;

function TTortoiseSVN.GetName: string;
begin
  result := 'TortoiseSVN add-in';
end;

function TTortoiseSVN.GetState: TWizardState;
begin
  result := [wsEnabled];
end;

procedure TTortoiseSVN.Execute;
begin
end;

{$IFNDEF DLL_MODE}

procedure Register;
begin
  RegisterPackageWizard(TTortoiseSVN.create);
end;

{$ELSE}

var
  wizardID: integer;

procedure FinalizeWizard;
var
  WizardServices: IOTAWizardServices;
begin
  Assert(Assigned(BorlandIDEServices));

  WizardServices := BorlandIDEServices as IOTAWizardServices;
  Assert(Assigned(WizardServices));

  WizardServices.RemoveWizard(wizardID);

end;

function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
var
  WizardServices: IOTAWizardServices;
begin
  Assert(BorlandIDEServices <> nil);
  Assert(ToolsAPI.BorlandIDEServices = BorlandIDEServices);

  Terminate := FinalizeWizard;

  WizardServices := BorlandIDEServices as IOTAWizardServices;
  Assert(Assigned(WizardServices));

  wizardID := WizardServices.AddWizard(TTortoiseSVN.Create as IOTAWizard);

  result := wizardID >= 0;
end;

exports
  InitWizard name WizardEntryPoint;

{$ENDIF}

end.

