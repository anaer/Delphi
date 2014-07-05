unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, HookDef;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button3: TButton;
    Button4: TButton;
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
var
    Form1: TForm1;
    Hook:THook;

implementation

{$R *.dfm}
   //Download http://www.codefans.net
procedure TForm1.Button4Click(Sender: TObject);
begin
    Hook.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
    Hook := THook.Create(KeyBoardHook);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Hook.Free;
end;

end.
