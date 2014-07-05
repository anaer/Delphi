unit FrmIMail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ipscore, ipssmtps, ipsfilemailers;

type
  TForm1 = class(TForm)
    control: TipsSMTPS;
    control1: TipsFileMailerS;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

function showImail():Boolean;stdcall;
implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
//  control.MailServer := 'mail.xxx.com';
//  control.MailPort := 25;
//  control.User := 'xxx';
//  control.Password := 'xxx';
//  control.From := 'xxx@xxx.com';
//  control.SendTo := 'xxx@xxx.com';
//  control.Subject := 'My Subject';
//  control.MessageText := 'This is the message body';
//  control.Connect();
//  control.Send();
//  control.Disconnect();


  control1.MailServer := 'mail.xxx.com';
  control1.MailPort := 25;
  control1.User := 'xxx';
  control1.Password := 'xxx';
  control1.From := 'xxx@xxx.com';
  control1.SendTo := 'xxx@xxx.com';
  control1.Subject := 'My Subject';
  control1.MessageText := 'This is the message body';
  control1.AddAttachment('E:\Dropbox\Public\IPWorksSSLV6.0.1650.rar.7z');
  control1.Connect();
  control1.Send();
  control1.Disconnect();

  {还有一个HTMLMailerS 估计用法也差不多} 

end;

function showImail():Boolean;stdcall;
begin
  Form1:=TForm1.Create(Application);
  Form1.ShowModal;
  FreeAndNil(form1);
end;

end.

