unit Frm_Main;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, Db,
  DBTables, DBGridEh, RXDBCtrl, ShellAPI, Placemnt, RXCtrls, RXShell,
  AppEvent, DBGridEhX, ExtCtrls, ImgList, mytool,
  CommonDll;
type
  TfrmClient = class(TForm)
    ddd: TPageControl;
    qry1: TQuery;
    ds1: TDataSource;
    ts4: TTabSheet;
    frmstrg1: TFormStorage;
    rxtrycn1: TRxTrayIcon;
    apvnts1: TAppEvents;
    ts5: TTabSheet;
    dlgOpen1: TOpenDialog;
    dlgSave1: TSaveDialog;
    pnl6: TPanel;
    btnKillProcess: TButton;
    btnDelete: TButton;
    pnl7: TPanel;
    lstCmd: TListBox;
    pnl8: TPanel;
    pnl9: TPanel;
    lblCommandList: TLabel;
    edtParam: TEdit;
    lblCommand: TLabel;
    il1: TImageList;
    TabSheet2: TTabSheet;
    Panel2: TPanel;
    Panel3: TPanel;
    Button4: TButton;
    Button5: TButton;
    Button2: TButton;
    Button3: TButton;
    img1: TImage;
    Button1: TButton;
    Button6: TButton;
    //    procedure edtEmpNOKeyPress(Sender: TObject; var Key: Char);
    //    procedure btn2Click(Sender: TObject);
    //    procedure btn3Click(Sender: TObject);
    //    procedure edtBalanceKeyPress(Sender: TObject; var Key: Char);
    //    procedure btn4Click(Sender: TObject);
    //    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    //    procedure lvFMLEmpSelectItem(Sender: TObject; Item: TListItem;
    //      Selected: Boolean);
    //    procedure btn5Click(Sender: TObject);
    //    procedure btn6Click(Sender: TObject);
    //    procedure btn7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnKillProcessClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure showMsg(msg: string);
    procedure lstCmdClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure rxtrycn1Click(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure apvnts1Minimize(Sender: TObject);
    procedure apvnts1Restore(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ts5Show(Sender: TObject);
    procedure aClick(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;
var
  frmClient: TfrmClient;
  gAppDir: string;
  gTmpDir: string;
  lstcmdfile: string;
  gIsImp: Boolean;

implementation

{$R *.dfm}

procedure TfrmClient.FormCreate(Sender: TObject);
begin
  //init
  gAppDir := ExtractFilePath(Application.ExeName);
  gTmpDir := gAppDir + 'temp\';

  lstcmdfile := 'lstcmd.txt';
  if (FileExists(lstcmdfile)) then
  begin
    lstCmd.Items.LoadFromFile('lstcmd.txt');
  end;

end;

procedure TfrmClient.btnKillProcessClick(Sender: TObject);
var
  param: string;
  index: Integer;
begin
  param := edtParam.Text;
  // 命令列表中没有 就加入列表
  index := lstCmd.Items.IndexOf(param);
  if (index = -1) then
  begin
    lstCmd.Items.Add(param);
  end
  else if (index <> 0) then
  begin
    lstCmd.Items.Exchange(index, index - 1);
  end;

  ShellExecute(Application.Handle, 'open', pChar('cmd.exe'), PChar(' /k ' +
    param), nil, SW_SHOWNORMAL);
end;

procedure TfrmClient.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  lstCmd.Items.SaveToFile(lstcmdfile);
end;

procedure TfrmClient.showMsg(msg: string);
begin
  Application.MessageBox(PChar(msg), '消息', MB_OK);
end;

procedure TfrmClient.lstCmdClick(Sender: TObject);
begin

  edtParam.Text := lstCmd.Items.Strings[lstCmd.ItemIndex];
end;

procedure TfrmClient.btnDeleteClick(Sender: TObject);
begin
  lstCmd.Items.Delete(lstCmd.ItemIndex);
end;

procedure TfrmClient.rxtrycn1Click(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //Application.Minimize();
  Application.Restore;
  Application.BringToFront;
end;

procedure TfrmClient.apvnts1Minimize(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TfrmClient.apvnts1Restore(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_SHOW);
end;

procedure TfrmClient.ts5Show(Sender: TObject);
var
  exeName, exePath: string;
  bitmap: TBitmap;
  NewButton: TSpeedButton;
  i: Integer;
  stringList: TStringList;
  Icon: hIcon;
  IconIndex: word;
begin
  stringList := TStringList.Create();
  getSections('System', 'Proc', stringList);

  for i := 0 to stringList.Count - 1 do
  begin
    exeName := stringList.strings[i];
    getSectionValue('System', 'Proc', exeName, exePath);
    //获取程序图标
    IconIndex := 0;
    Icon := ExtractAssociatedIcon(HInstance,
      Pchar(exePath),
      IconIndex);
    //抽取图标，返回句柄保存在变量Icon中
    img1.Picture.Icon.Handle := Icon;
    il1.AddIcon(img1.Picture.Icon);
    bitmap := TBitmap.Create();
    il1.GetBitmap(i, bitmap);

    // 在内存中创建一个 Button，拥有者为self，这样当窗体 destory时，这个新button
    // 能够被自动释放
    NewButton := TSpeedButton.Create(Self);
    with NewButton do
    begin
      Parent := pnl9; // 指明在那个窗体显示
      Width := 48;
      Height := 48;
      Top := Parent.Top + 10 + (i div 5) * (Height + 10); // button 出现坐标
      Left := Parent.Left + 10 + (i mod 5) * (Width + 10);
      //Caption := exeName;
      Hint := exePath;
      ShowHint := true;
      OnClick := self.aClick; //调用件 aClick后面不能带括弧
      Glyph := bitmap;
    end; // with

  end;
end;

procedure TfrmClient.aClick(Sender: TObject);
var
  aButton: TSpeedButton;
begin
  aButton := TSpeedButton(Sender);
  //ShowMsg(aButton.Caption+' : '+ IntToStr(aButton.Tag));
  ShellExecute(Handle, 'open', PChar(aButton.Hint), nil, nil, SW_SHOW);
end;

procedure TfrmClient.btn5Click(Sender: TObject);
begin
  qry1.Open;
end;

procedure TfrmClient.Button2Click(Sender: TObject);
begin
//  RunDLLFunction('ExeDll', 'getExeIcon', '', true);
end;

procedure TfrmClient.Button4Click(Sender: TObject);
begin
//  RunDLLFunction('Project1', 'DealAccount', '', true);
end;

procedure TfrmClient.Button5Click(Sender: TObject);
begin
//  RunDLLFunction('URLDLL', 'DealUrlEncode', '', true);
end;

procedure TfrmClient.Button3Click(Sender: TObject);
begin
//  RunDLLFunction('Oradll', 'OraImpExp', '', true);
end;

procedure TfrmClient.Button1Click(Sender: TObject);
begin
//  RunDLLFunction('STAdll', 'showform123', '', true);
end;

procedure TfrmClient.Button6Click(Sender: TObject);
begin
//  RunDLLFunction('imail', 'showImail', '', true);
end;

end.

