unit URLEncodeDecode;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, HttpApp,Unicode;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Button2: TButton;
    Memo2: TMemo;
    Button3: TButton;
    Memo3: TMemo;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

 function DealUrlEncode():Boolean;stdcall;

implementation

{$R *.DFM}

procedure TForm1.Button2Click(Sender: TObject);
var
  str: string;
  strEncode: string;
begin
  str := Memo1.Text;
  strEncode := HttpEncode(Utf8Encode(str));
  Memo2.Text := strEncode;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  str: string;
  strDecode: string;
begin
  str := Memo2.Text;
  strDecode := Utf8Decode(HttpDecode(str));
  Memo3.Text := strDecode;
end;

function DealUrlEncode():Boolean;stdcall;  //账户回报数据处理
begin
  Form1:=TForm1.Create(Application);
//  DealDataForm.Mode := 1;
//  DealDataForm.Caption :='账户数据处理';
//  DealDataForm.AutoMode:=AutoMode;
//  DealDataForm.Timer1.Enabled:=AutoMode;
  Form1.ShowModal;
  Result:=true;
//  Result:=Form1.AutoMode;
  Form1.Free;
end;

end.
