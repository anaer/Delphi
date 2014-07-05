unit frmSTAdll;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Db, DBTables, Grids, DBGrids, ExtCtrls, Tuxedo32;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    pnl10: TPanel;
    btn5: TButton;
    pnl4: TPanel;
    dbgrd1: TDBGrid;
    qry1: TQuery;
    ds1: TDataSource;
    TabSheet1: TTabSheet;
    pnl2: TPanel;
    lbl_svrname: TLabel;
    lbl_param: TLabel;
    lbl_result: TLabel;
    edt_svrname: TEdit;
    edt_param: TEdit;
    btn_ok: TButton;
    pnl3: TPanel;
    redt_result: TRichEdit;
    procedure btn_okClick(Sender: TObject);
    procedure btn5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  function showForm123():Boolean;stdcall;
implementation

{$R *.DFM}
   function showForm123():Boolean;
   begin
       Form1:=TForm1.Create(Application);
  Form1.ShowModal;
  Result:=true;
  Form1.Free;
   end;
procedure TForm1.btn_okClick(Sender: TObject);
var
  bConn: boolean;
  iRes, iRcvLen: longint;
  sSrc, sSvrName: string;
  TPTTpinit: PTTpinit;
  bufSend, bufRcv: PChar;
begin
  try
    Screen.Cursor := crSQLWait;
    bConn := false;
    TPTTpinit := nil;
    bufSend := nil;
    bufRcv := nil;
    TPTTpinit := PTTpinit(tpalloc('TPINIT', nil, sizeOf(PTTpinit)));
    // 也可以配置成环境变量
    tuxputenv('WSNADDR=//127.0.0.1:2223');
    iRes := TPInit(nil);
    if (iRes = -1) then
    begin
      Application.MessageBox(PChar(Format('初始化失败: %d！', [gettperrno])),
        '系统提示', MB_OK);
      Exit;
    end
    else
      bConn := true;
    sSvrName := edt_svrname.Text;
    sSrc := edt_param.Text;
    bufSend := PChar(PTTpinit(tpalloc('STRING', nil, Length(sSrc) + 1)));
    bufRcv := PChar(PTTpinit(tpalloc('STRING', nil, Length(sSrc) + 1)));
    StrCopy(bufSend, PChar(sSrc));

    //iRes := tpcall(PChar('TOUPPER'), bufSend, longint(Length(sSrc) + 1), bufSend, iRcvLen,
    iRes := tpcall(PChar(sSvrName), bufSend, longint(Length(sSrc) + 1), bufRcv,
      iRcvLen,
      TPNOBLOCK);
    if (iRes = -1) then
    begin
      Application.MessageBox('调用 TOUPPER 失败！', '系统提示', MB_OK);
      Exit;
    end
    else
    begin
      redt_result.Text := bufRcv;
    end;
  finally
    if Assigned(TPTTpinit) then
      tpfree(pchar(TPTTpinit));
    if Assigned(bufSend) then
      tpfree(bufSend);
    if Assigned(bufRcv) then
      tpfree(bufRcv);
    if bConn then
      tpterm();
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.btn5Click(Sender: TObject);
begin
  qry1.Open;
end;

end.
