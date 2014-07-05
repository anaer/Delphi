//===================================================================================================//
//  参考TortoiseSVN2IDE修改，跟TortoiseSVN的命令语法基本一样                                         //                                 //
//  修改点: 1. TTortoiseGit.Create 注册表去路径修改                                                  //
//          2. TTortoiseGit.GetIDString, TTortoiseGit.GetName 修改                                   //
//          3. 添加菜单，复制文件路径及文件名                                  
//  注意点:                                                                                          //
//          1. 菜单图标资源需要在icons.res中添加                                                     //
//                                                           ------Modified by lvcn                  //
//                                                                  2013.11.05                       //
//===================================================================================================//

unit TortoiseGit2IDE;

{$R 'icons.res'}

interface

uses ToolsAPI, SysUtils, Windows, Dialogs, Menus, Registry, ShellApi,
  Classes, Controls, Graphics, ImgList, ExtCtrls, ActnList, Forms, TypInfo, Clipbrd;
  // TypInfo 枚举类型使用
  // Clipbrd 剪贴板 操作
type
  TGitMenuType = (
    GIT_PROJECT_EXPLORER, //浏览工程目录
    GIT_LOG, //查看目录日志
    GIT_LOG_FILE, //查询当前文件日志信息
    GIT_CHECK_MODIFICATIONS, //检查更新
    GIT_UPDATE, //更新
    GIT_ADD, //添加文件
    GIT_COMMIT, //提交
    GIT_COMMIT_FILE, //提交当前文件
    GIT_REVERT, //还原
    GIT_DIFF, //差异比较
    GIT_REPOSITORY_BROWSER, //浏览版本库
    GIT_SETTINGS, //设置
    GIT_ABOUT, //关于
    SYS_COPY_FULLPATH, //复制完整路径和文件名到剪贴板
    SYS_COPY_PATH,     //复制路径到剪贴板
    SYS_COPY_FILENAME //复制文件名
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
  tGitMenu.Caption := 'Tortoise&Git';  // 添加快捷键
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

      // 添加分割线
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
      Result := '浏览项目文件夹[&P]...'; //'&Project explorer...';
    GIT_LOG:
      Result := '日志[&L]...'; //'&Log...';
    GIT_CHECK_MODIFICATIONS:
      Result := '检查更新[&M]...'; //'Check &modifications...';
    GIT_ADD:
      Result := '添加[&A]...'; //'&Add...';
    GIT_UPDATE:
      Result := '更新为某一版本[&U]...'; //'&Update to revision...';
    GIT_COMMIT:
      Result := '提交[&C]...'; //'&Commit...';
    GIT_DIFF:
      Result := '差异比较[&D]...'; //'&Diff...';
    GIT_REVERT:
      Result := '还原[&R]...'; //'&Revert...';
    GIT_REPOSITORY_BROWSER:
      Result := '浏览版本库[&B]...'; //'Repository &browser...';
    GIT_SETTINGS:
      Result := '设置[&S]...'; //'&Settings...';
    GIT_ABOUT:
      Result := '关于...'; //'&About...'; 原快捷键跟添加Add冲突了
    GIT_LOG_FILE:
      Result := '当前文件日志[&F]...'; //'&Log...';
    GIT_COMMIT_FILE:
      Result := '提交当前文件...'; // 如果没有添加快捷键 程序会自动提供一个
    SYS_COPY_FULLPATH:
      Result := '复制完整路径和文件名到剪贴板';
    SYS_COPY_PATH:
      Result := '复制路径到剪贴板';
    SYS_COPY_FILENAME:
      Result := '复制当前文件名';
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
          Application.MessageBox('更新之前，所有的项目文件都将被保存。继续吗？　　', '提示', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          //if MessageDlg( '更新之前，所有的项目文件都将被保存。继续吗？', mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then begin
          (BorlandIDEServices as IOTAModuleServices).saveAll;
          TGitExec('/command:update /rev /notempfile /path:' +
            AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
        end;
    GIT_COMMIT:
      if project <> nil then
        if
          Application.MessageBox('提交之前，所有的项目文件都将被保存。继续吗？　　', '提示', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          //if MessageDlg( '提交之前，所有的项目文件都将被保存。继续吗？', mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then begin
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

