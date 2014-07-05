program TClient;

uses
  Forms,
  Frm_Main in 'Frm_Main.pas' {frmClient},
  tuxedo32 in '..\Public\tuxedo32.pas',
  Graphics in 'C:\Program Files\Borland\Delphi5\Source\Vcl\graphics.pas',
  Unicode in '..\Public\Unicode.pas',
  mytool in '..\Public\mytool.pas',
  CommonDll in '..\Public\CommonDll.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmClient, frmClient);
  Application.Run;
end.

