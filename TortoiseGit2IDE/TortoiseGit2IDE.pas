//===================================================================================================//
//  �ο�TortoiseSVN2IDE�޸ģ���TortoiseSVN�������﷨����һ��                                         //                                 //
//  �޸ĵ�: 1. TTortoiseGit.Create ע���ȥ·���޸�                                                  //
//          2. TTortoiseGit.GetIDString, TTortoiseGit.GetName �޸�                                   //
//          3. ��Ӳ˵��������ļ�·�����ļ���                                  
//  ע���:                                                                                          //
//          1. �˵�ͼ����Դ��Ҫ��icons.res�����                                                     //
//                                                           ------Modified by lvcn                  //
//                                                                  2013.11.05                       //
//===================================================================================================//

unit TortoiseGit2IDE;

{$R 'icons.res'}

interface

uses ToolsAPI, SysUtils, Windows, Dialogs, Menus, Registry, ShellApi,
  Classes, Controls, Graphics, ImgList, ExtCtrls, ActnList, Forms, TypInfo, Clipbrd;
  // TypInfo ö������ʹ��
  // Clipbrd ������ ����
type
  TGitMenuType = (
    GIT_PROJECT_EXPLORER, //�������Ŀ¼
    GIT_LOG, //�鿴Ŀ¼��־
    GIT_LOG_FILE, //��ѯ��ǰ�ļ���־��Ϣ
    GIT_CHECK_MODIFICATIONS, //������
    GIT_UPDATE, //����
    GIT_ADD, //����ļ�
    GIT_COMMIT, //�ύ
    GIT_COMMIT_FILE, //�ύ��ǰ�ļ�
    GIT_REVERT, //��ԭ
    GIT_DIFF, //����Ƚ�
    GIT_REPOSITORY_BROWSER, //����汾��
    GIT_SETTINGS, //����
    GIT_ABOUT, //����
    SYS_COPY_FULLPATH, //��������·�����ļ�����������
    SYS_COPY_PATH,     //����·����������
    SYS_COPY_FILENAME //�����ļ���
    );

type
  TTortoiseGit = class(TNotifierObject, IOTANotifier, IOTAWizard)
  private
    timer: TTimer;
    tGitMenu: TMenuItem;
    sGitPath: string;
    procedure Tick(sender: tobject);
    procedure TGitExec(params: string);
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

constructor TTortoiseGit.Create;
var
  reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('\SOFTWARE\TortoiseGit') then
      sGitPath := Reg.ReadString('ProcPath');
  finally
    Reg.CloseKey;
    Reg.Free;
  end;

  tGitMenu := nil;

  timer := TTimer.create(nil);
  timer.interval := 200;
  timer.OnTimer := tick;
  timer.enabled := true;

end;

procedure TTortoiseGit.Tick(sender: tobject);
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

procedure TTortoiseGit.CreateMenu;
var
  mainMenu: TMainMenu;
  item: TMenuItem;
  i: integer;
  bmp: TBitmap;
  action: TAction;
  pi: PTypeInfo;
begin
  if tGitMenu <> nil then
    exit;

  tGitMenu := TMenuItem.Create(nil);
  tGitMenu.Caption := 'Tortoise&Git';  // ��ӿ�ݼ�
  pi := TypeInfo(TGitMenuType);
  with GetTypeData(pi)^ do
  begin
    for i := MinValue to MaxValue do
    begin
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

      // ��ӷָ���
      if (TGitMenuType(i) = SYS_COPY_FULLPATH) then
      begin
        item := TMenuItem.Create(tGitMenu);
        item.Caption := '-';
        tGitMenu.add(item);
      end;
      item := TMenuItem.Create(tGitMenu);
      item.action := action;

      tGitMenu.add(item);
    end;
  end;

  mainMenu := (BorlandIDEServices as INTAServices).MainMenu;
  mainMenu.Items.Insert(mainMenu.Items.Count - 1, tGitMenu);
end;

destructor TTortoiseGit.Destroy;
begin
  if tGitMenu <> nil then
  begin
    tGitMenu.free;
  end;
  inherited;
end;

function TTortoiseGit.GetBitmapName(Index: Integer): string;
var
  gmt: TGitMenuType;
begin
  gmt := TGitMenuType(Index);
  case gmt of
    GIT_PROJECT_EXPLORER:
      Result := 'explorer';
    GIT_LOG, GIT_LOG_FILE:
      Result := 'log';
    GIT_CHECK_MODIFICATIONS:
      Result := 'check';
    GIT_ADD:
      Result := 'add';
    GIT_UPDATE:
      Result := 'update';
    GIT_COMMIT, GIT_COMMIT_FILE:
      Result := 'commit';
    GIT_DIFF:
      Result := 'diff';
    GIT_REVERT:
      Result := 'revert';
    GIT_REPOSITORY_BROWSER:
      Result := 'repository';
    GIT_SETTINGS:
      Result := 'settings';
    GIT_ABOUT:
      Result := 'about';
    SYS_COPY_FULLPATH:
      Result := 'find';
    SYS_COPY_PATH:
      Result := 'find';
    SYS_COPY_FILENAME:
      Result := 'find';
  end;
end;

function TTortoiseGit.GetVerb(Index: Integer): string;
var
  gmt: TGitMenuType;
begin
  gmt := TGitMenuType(Index);
  case gmt of
    GIT_PROJECT_EXPLORER:
      Result := '�����Ŀ�ļ���[&P]...'; //'&Project explorer...';
    GIT_LOG:
      Result := '��־[&L]...'; //'&Log...';
    GIT_CHECK_MODIFICATIONS:
      Result := '������[&M]...'; //'Check &modifications...';
    GIT_ADD:
      Result := '���[&A]...'; //'&Add...';
    GIT_UPDATE:
      Result := '����Ϊĳһ�汾[&U]...'; //'&Update to revision...';
    GIT_COMMIT:
      Result := '�ύ[&C]...'; //'&Commit...';
    GIT_DIFF:
      Result := '����Ƚ�[&D]...'; //'&Diff...';
    GIT_REVERT:
      Result := '��ԭ[&R]...'; //'&Revert...';
    GIT_REPOSITORY_BROWSER:
      Result := '����汾��[&B]...'; //'Repository &browser...';
    GIT_SETTINGS:
      Result := '����[&S]...'; //'&Settings...';
    GIT_ABOUT:
      Result := '����...'; //'&About...'; ԭ��ݼ������Add��ͻ��
    GIT_LOG_FILE:
      Result := '��ǰ�ļ���־[&F]...'; //'&Log...';
    GIT_COMMIT_FILE:
      Result := '�ύ��ǰ�ļ�...'; // ���û����ӿ�ݼ� ������Զ��ṩһ��
    SYS_COPY_FULLPATH:
      Result := '��������·�����ļ�����������';
    SYS_COPY_PATH:
      Result := '����·����������';
    SYS_COPY_FILENAME:
      Result := '���Ƶ�ǰ�ļ���';
  end;
end;

const
  vsEnabled = 1;

function TTortoiseGit.GetVerbState(Index: Integer): Word;

var
  gmt: TGitMenuType;
begin
  Result := 0;
  gmt := TGitMenuType(Index);
  case gmt of
    GIT_PROJECT_EXPLORER:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    GIT_LOG, GIT_LOG_FILE:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    GIT_CHECK_MODIFICATIONS:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    GIT_ADD:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    GIT_UPDATE:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    GIT_COMMIT, GIT_COMMIT_FILE:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    GIT_DIFF:
      if GetCurrentFileName <> '' then
        Result := vsEnabled;
    GIT_REVERT:
      if GetCurrentProject <> nil then
        Result := vsEnabled;
    GIT_REPOSITORY_BROWSER:
      Result := vsEnabled;
    GIT_SETTINGS:
      Result := vsEnabled;
    GIT_ABOUT:
      Result := vsEnabled;
    SYS_COPY_FULLPATH:
      if GetCurrentFileName <> '' then
        Result := vsEnabled;
    SYS_COPY_PATH:
      if GetCurrentFileName <> '' then
        Result := vsEnabled;
    SYS_COPY_FILENAME:
      if GetCurrentFileName <> '' then
        Result := vsEnabled;
  end;
end;

procedure TTortoiseGit.TGitExec(params: string);
begin
  WinExec(pchar(sGitPath + ' ' + params), SW_SHOW);
end;

procedure TTortoiseGit.ExecuteVerb(Index: Integer);
var
  project: IOTAProject;
  filename: string;
  gmt: TGitMenuType;
begin
  project := GetCurrentProject();
  filename := getCurrentFileName();
  gmt := TGitMenuType(Index);
  case gmt of
    GIT_PROJECT_EXPLORER:
      if project <> nil then
        ShellExecute(0, 'open', pchar(ExtractFilePath(project.GetFileName)), '',
          '', SW_SHOWNORMAL);
    GIT_LOG:
      if project <> nil then
        TGitExec('/command:log /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
    GIT_CHECK_MODIFICATIONS:
      if project <> nil then
        TGitExec('/command:repostatus /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
    GIT_ADD:
      if project <> nil then
        TGitExec('/command:add /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
    GIT_UPDATE:
      if project <> nil then

        if
          Application.MessageBox('����֮ǰ�����е���Ŀ�ļ����������档�����𣿡���', '��ʾ', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          //if MessageDlg( '����֮ǰ�����е���Ŀ�ļ����������档������', mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then begin
          (BorlandIDEServices as IOTAModuleServices).saveAll;
          TGitExec('/command:update /rev /notempfile /path:' +
            AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
        end;
    GIT_COMMIT:
      if project <> nil then
        if
          Application.MessageBox('�ύ֮ǰ�����е���Ŀ�ļ����������档�����𣿡���', '��ʾ', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          //if MessageDlg( '�ύ֮ǰ�����е���Ŀ�ļ����������档������', mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then begin
          (BorlandIDEServices as IOTAModuleServices).saveAll;
          TGitExec('/command:commit /notempfile /path:' +
            AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
        end;
    GIT_DIFF:
      if filename <> '' then
        TGitExec('/command:diff /notempfile /path:' + AnsiQuotedStr(filename,
          '"'));
    GIT_REVERT:
      if project <> nil then
        TGitExec('/command:revert /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
    GIT_REPOSITORY_BROWSER:
      if project <> nil then
        TGITExec('/command:repobrowser /notempfile /path:' +
          AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'))
      else
        TGitExec('/command:repobrowser');
    GIT_SETTINGS:
      TGitExec('/command:settings');
    GIT_ABOUT:
      TGitExec('/command:about');
    GIT_LOG_FILE:
      if filename <> '' then
        TGitExec('/command:log /notempfile /path:' + AnsiQuotedStr(filename,
          '"'));
    GIT_COMMIT_FILE:
      if filename <> '' then
        TGitExec('/command:commit /notempfile /path:' + AnsiQuotedStr(filename,
          '"'));
    SYS_COPY_FULLPATH:
      if filename <> '' then
        Clipboard.AsText := filename;
    SYS_COPY_PATH:
      if filename <> '' then
        Clipboard.AsText := ExtractFileDir(filename);
    SYS_COPY_FILENAME:
      if filename <> '' then
        Clipboard.AsText := ExtractFileName(filename);
  end;
end;

procedure TTortoiseGit.UpdateAction(sender: TObject);
var
  action: TAction;
begin
  action := sender as TAction;
  action.Enabled := getVerbState(action.tag) = vsEnabled;
end;

procedure TTortoiseGit.ExecuteAction(sender: TObject);
var
  action: TAction;
begin
  action := sender as TAction;
  executeVerb(action.tag);
end;

function TTortoiseGit.GetIDString: string;
begin
  result := 'Subversion.TortoiseGit';
end;

function TTortoiseGit.GetName: string;
begin
  result := 'TortoiseGit add-in';
end;

function TTortoiseGit.GetState: TWizardState;
begin
  result := [wsEnabled];
end;

procedure TTortoiseGit.Execute;
begin
end;

{$IFNDEF DLL_MODE}

procedure Register;
begin
  RegisterPackageWizard(TTortoiseGit.create);
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

  wizardID := WizardServices.AddWizard(TTortoiseGit.Create as IOTAWizard);

  result := wizardID >= 0;
end;

exports
  InitWizard name WizardEntryPoint;

{$ENDIF}

end.

