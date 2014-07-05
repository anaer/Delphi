unit AppShortCutForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, StdCtrls, ExtCtrls, ShellAPI, mytool;

type
  TfrmAppShortCut = class(TForm)
    pnlMain: TPanel;
    imgIcon: TImage;
    imgBmp: TImage;
    lblIcon: TLabel;
    lblBmp: TLabel;
    btnGetIcon: TButton;
    edtAppPath: TEdit;
    dlgOpen1: TOpenDialog;
    il1: TImageList;
    procedure btnGetIconClick(Sender: TObject);
    procedure edtAppPathDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function getAppIcon(): Boolean; stdcall;
implementation

{$R *.DFM}

function getAppIcon(): Boolean; stdcall;
var
  frmAppShortCut: TfrmAppShortCut;
begin
  frmAppShortCut := TfrmAppShortCut.Create(Application);
  frmAppShortCut.ShowModal;
  Result := true;
  frmAppShortCut.Free;
end;

procedure TfrmAppShortCut.btnGetIconClick(Sender: TObject);
var
  Icon: hIcon;
  IconIndex: word;
  filepath: string;
  //  Bitmap: TBitmap;
  //  Icon2: TIcon;
  //  stream: TResourceStream;
  winDC, srcdc, destdc: HDC;
  oldBitmap: HBitmap;
  iinfo: TICONINFO;
begin
  filepath := edtAppPath.Text;
  if (not FileExists(filepath)) then
  begin
    Application.MessageBox(PChar(filepath + '�ļ�������'), '��Ϣ', MB_OK);
    exit;
  end;

  IconIndex := 0; //Application.ExeName
  Icon := ExtractAssociatedIcon(HInstance,
    Pchar(filepath),
    //��������
    IconIndex);
  //��ȡͼ�꣬���ؾ�������ڱ���Icon��
  imgIcon.Picture.Icon.Handle := Icon;
  //  img1.Picture.Icon.SaveToFile('Glyph\' + GetFileNameNoExt(filepath) + '.ico');
    //��image1����ʾ��ȡ��ͼ��

    //���潫icon ת��bmp
  GetIconInfo(imgIcon.Picture.Icon.Handle, iinfo);
  WinDC := getDC(handle);
  srcDC := CreateCompatibleDC(WinDC);
  destDC := CreateCompatibleDC(WinDC);
  //oldBitmap := SelectObject(destDC, iinfo.hbmColor);
  oldBitmap := SelectObject(srcDC, iinfo.hbmMask);
  BitBlt(destdc, 0, 0,
    imgIcon.picture.icon.width, imgIcon.picture.icon.height, srcdc,
    0, 0, SRCPAINT);
  imgBmp.picture.bitmap.handle := SelectObject(destDC,
    oldBitmap);
  DeleteDC(destDC);
  DeleteDC(srcDC);
  DeleteDC(WinDC);
  //  img2.Picture.Bitmap.savetofile('Glyph\' + GetFileNameNoExt(filepath) +
  //    '.bmp');
end;

procedure TfrmAppShortCut.edtAppPathDblClick(Sender: TObject);
begin
  dlgOpen1.Filter := 'exe file(*.exe)|*.exe|dll file(*.dll)|*.dll';
  if dlgOpen1.Execute then
    edtAppPath.Text := dlgOpen1.FileName;
end;

end.

 