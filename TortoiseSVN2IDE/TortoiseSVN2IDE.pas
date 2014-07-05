//===================================================================================================//
//  习惯了Windows资源管理器下TortoiseSVN的右键中文菜单，再看IDE集成环境中的英文界面，感觉有点不爽。  //
//  于是就把TortoiseSVN的菜单项和提示对话框都汉化成简体中文的了。汉化的依据是TortoiseSVN 1.4.1官方   //
//  正式版的英文--简体中文对照表！试了一下效果还可以。                                               //
//                                                           ------Modified by 小宇飞刀              //
//                                                                  2006.12.26                       //
//===================================================================================================//
//  修改原来的菜单常量为枚举类型, 这样增删菜单方便点, 而且菜单排序可以直接调整,不需要再更新菜单序号. //
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
    SVN_PROJECT_EXPLORER, //浏览工程目录
    SVN_LOG, //查看目录日志
    SVN_LOG_FILE, //查询当前文件日志信息
    SVN_CHECK_MODIFICATIONS, //检查更新
    SVN_UPDATE, //更新
    SVN_ADD, //添加文件
    SVN_COMMIT, //提交
    SVN_COMMIT_FILE, //提交当前文件
    SVN_REVERT, //还原
    SVN_DIFF, //差异比较
    SVN_REPOSITORY_BROWSER, //浏览版本库
    SVN_SETTINGS, //设置
    SVN_ABOUT //关于
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
      Result := '浏览项目文件夹[&P]...'; //'&Project explorer...';
    SVN_LOG:
      Result := '日志[&L]...'; //'&Log...';
    SVN_CHECK_MODIFICATIONS:
      Result := '检查更新[&M]...'; //'Check &modifications...';
    SVN_ADD:
      Result := '添加[&A]...'; //'&Add...';
    SVN_UPDATE:
      Result := '更新为某一版本[&U]...'; //'&Update to revision...';
    SVN_COMMIT:
      Result := '提交[&C]...'; //'&Commit...';
    SVN_DIFF:
      Result := '差异比较[&D]...'; //'&Diff...';
    SVN_REVERT:
      Result := '还原[&R]...'; //'&Revert...';
    SVN_REPOSITORY_BROWSER:
      Result := '浏览版本库[&B]...'; //'Repository &browser...';
    SVN_SETTINGS:
      Result := '设置[&S]...'; //'&Settings...';
    SVN_ABOUT:
      Result := '关于...'; //'&About...'; 原快捷键跟添加Add冲突了
    SVN_LOG_FILE:
      Result := '当前文件日志[&F]...'; //'&Log...';
    SVN_COMMIT_FILE:
      Result := '提交当前文件...'; // 如果没有添加快捷键 程序会自动提供一个
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
          Application.MessageBox('更新之前，所有的项目文件都将被保存。继续吗？　　', '提示', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          //if MessageDlg( '更新之前，所有的项目文件都将被保存。继续吗？', mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then begin
          (BorlandIDEServices as IOTAModuleServices).saveAll;
          TSVNExec('/command:update /rev /notempfile /path:' +
            AnsiQuotedStr(ExtractFilePath(project.GetFileName), '"'));
        end;
    SVN_COMMIT:
      if project <> nil then
        if
          Application.MessageBox('提交之前，所有的项目文件都将被保存。继续吗？　　', '提示', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          //if MessageDlg( '提交之前，所有的项目文件都将被保存。继续吗？', mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then begin
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

