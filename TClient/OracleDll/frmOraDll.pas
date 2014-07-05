unit frmOraDll;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellAPI, mytool, inifiles, ComCtrls, Grids, DBGrids,
  ADODB, Db;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    pnl1: TPanel;
    mmo1: TMemo;
    Panel2: TPanel;
    Label2: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    ComboBox2: TComboBox;
    Button7: TButton;
    pnl5: TPanel;
    mmo2: TMemo;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Button1: TButton;
    Button8: TButton;
    ComboBox1: TComboBox;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    ADOTable1: TADOTable;
    DBGrid1: TDBGrid;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
    gIsImp: Boolean;
      gTmpDir: string;
        gAppDir: string;

  function OraImpExp():Boolean; stdcall;
implementation

{$R *.DFM}
  function OraImpExp():Boolean;
  begin
      Form1:=TForm1.Create(Application);
  Form1.ShowModal;
  Result:=true;

  Form1.Free;
  end;
procedure TForm1.Button2Click(Sender: TObject);
var
  sFileName: string;
begin
  if (gIsImp) then
  begin
    sFileName := gTmpDir + 'RESTORE.PRM';
  end
  else
  begin
    sFileName := gTmpDir + 'BACKUP.PRM';
  end;

  if (FileExists(sFileName)) then
  begin
    mmo1.Lines.LoadFromFile(sFileName);
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if (gIsImp) then
  begin
    mmo1.Lines.SaveToFile(gTmpDir + 'RESTORE.PRM');
  end
  else
  begin
    mmo1.Lines.SaveToFile(gTmpDir + 'BACKUP.PRM');
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if (gIsImp) then
  begin
    mmo1.Lines.Text := '' +
      'fromuser=test1' + #13#10 +
      'touser=test1' + #13#10 +
      'commit=Y' + #13#10 +
      'ANALYZE=Y' + #13#10 +
      'CONSTRAINTS=Y' + #13#10 +
      'DESTROY=N' + #13#10 +
      'GRANTS=N' + #13#10 +
      'IGNORE=Y' + #13#10 +
      'INDEXES=Y' + #13#10 +
      'ROWS=Y' + #13#10 +
      'SKIP_UNUSABLE_INDEXES=N' + #13#10 +
      'BUFFER=10485760' + #13#10 +
      'FILE=''' + gTmpDir + 'daoru.dmp''' + #13#10 +
      'LOG=''' + gTmpDir + 'daoru.log''';
  end
  else
  begin
    mmo1.Lines.Text := 'BUFFER=10485760' + #13#10 +
      'FULL=N' + #13#10 +
      'RECORD=Y' + #13#10 +
      'DIRECT=Y' + #13#10 +
      'CONSTRAINTS=Y' + #13#10 +
      'GRANTS=N' + #13#10 +
      'INDEXES=Y' + #13#10 +
      'ROWS=Y' + #13#10 +
      'CONSISTENT=N' + #13#10 +
      'COMPRESS=Y' + #13#10 +
      'TRIGGERS=Y' + #13#10 +
      'FILE=''' + gTmpDir + 'daochu.dmp''' + #13#10 +
      'LOG=''' + gTmpDir + 'daochu.log''' + #13#10 +
      'OWNER=test1';
  end;

end;

procedure TForm1.Button5Click(Sender: TObject);
var
  sParam: string;
  sParamFile: string;
begin
  // 执行前先保存参数文件
  Button3Click(nil);
  if (gIsImp) then
  begin
    sParamFile := gTmpDir + 'RESTORE.PRM';
    if (FileExists(sParamFile)) then
    begin
      sParam := 'test999/test999@orcl parfile=' + gTmpDir + 'RESTORE.PRM';
      shellexecute(self.Handle, nil, 'imp.exe', pchar(sParam), nil, SW_NORMAL);
    end
    else
    begin
      showMsg('导入配置文件RESTORE.PRM不存在');
    end;
  end
  else
  begin
    // 需要是DBA 才能完整导出数据
//sParam := 'test999/test999@orcl file=d:\daochu.dmp full=y';

    sParamFile := gTmpDir + 'BACKUP.PRM';
    if (FileExists(sParamFile)) then
    begin
      sParam := 'test999/test999@orcl parfile=' + gTmpDir + 'BACKUP.PRM';
      shellexecute(self.Handle, nil, 'exp.exe', pchar(sParam), nil, SW_NORMAL);
    end
    else
    begin
      showMsg('导出配置文件BACKUP.PRM不存在');
    end;
  end;

end;

procedure TForm1.Button7Click(Sender: TObject);
var
  inipath: string;
  inifile: Tinifile;
  Strings: TStringList;
begin
  inipath := gTmpDir + 'BACKUP.PRM';
  inifile := TIniFile.Create(inipath);
  Strings := TStringList.Create();
  inifile.ReadSections(Strings);

  showMsg(Strings.CommaText);
  showMsg(inifile.ReadString('', 'FILE', ''));
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  sFileName: string;
begin
  mmo2.Lines.Clear;
  if (gIsImp) then
  begin
    sFileName := gTmpDir + 'daoru.log';
  end
  else
  begin
    sFileName := gTmpDir + 'daochu.log';
  end;

  if (FileExists(sFileName)) then
  begin
    mmo2.Lines.LoadFromFile(sFileName);
  end;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
  gIsImp := (ComboBox1.ItemIndex = 1);
  button4Click(nil);
  button6Click(nil);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  gAppDir := ExtractFilePath(Application.ExeName);
  gTmpDir := gAppDir + 'temp\';
end;

end.
