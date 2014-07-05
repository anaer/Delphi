unit mytool;

interface
uses windows, Messages, SysUtils, Dialogs, Db, forms, stdctrls, comctrls, classes, controls,
  graphics, Psock, DBTables, Shellapi, Menus, dbctrls, RxDBComb, Printers, registry, RXDBCtrl,
  DBGridEh, DBGridEhX, frxClass, Buttons, extctrls, DBGrids,
  HSQuery, hscheckcombox, HsCtrls, QueryClass, PrnDbgeh, FileUtil, FileCtrl, TlHelp32,
  Math, Hsutils, contnrs, ProgressBar, ComObj, IniFiles, Clipbrd;

procedure WriteLog2(filename, msg: string; autoclear: Boolean = True);
procedure ShowMsg(msg: string);
procedure getSections(fileName, section: string; out stringList: TStringList);
procedure getSectionValue(fileName, section, key: string; out value: string);
function GetFileNameNoExt(FileName: string): string;

implementation
type
  Texe = packed record
    name: string;
    path: string;
  end;

var
  isFirst: Boolean = true;

procedure WriteLog2(filename, msg: string; autoclear: Boolean = True);
var
  inifile: TIniFile;
  strings: TStringList;
  i: Integer;
begin
  inifile := TIniFile.Create('d:\abc.log');
  if (isFirst) then
  begin
    strings := TStringList.Create();
    inifile.ReadSections(strings);
    for i := 0 to strings.Count - 1 do
    begin
      inifile.EraseSection(strings[i]);
    end;
    inifile.WriteString('ROOT', 'Version5', '');
    isFirst := False;
  end;
  inifile.WriteString(filename, FormatDateTime('YYYY-MM-DD HH:MM:SS ZZZ', now) + ' (' + Format('%.3d', [Random(999)]) + ')', msg + ';');

  FreeAndNil(inifile);
end;

procedure ShowMsg(msg: string);
begin
  Application.MessageBox(PChar(msg), '消息', MB_OK);
end;

procedure getSections(fileName, section: string; out stringList: TStringList);
var
  inifile: TIniFile;
begin

  inifile := TIniFile.Create(ExtractFilePath(application.ExeName) + '\' + fileName + '.ini');
  if (inifile <> nil) then
  begin
    stringList := TStringList.Create();
    inifile.ReadSection(section, stringList);
  end;

end;

procedure getSectionValue(fileName, section, key: string; out value: string);
var
  inifile: TIniFile;
begin

  inifile := TIniFile.Create(ExtractFilePath(application.ExeName) + '\' + fileName + '.ini');
  if (inifile <> nil) then
  begin
    value := inifile.ReadString(section, key, '');
  end;

end;

function GetFileNameNoExt(FileName: string): string;
var
  Str1: string;
  str2: string;
  n: Integer;
begin
  Str1 := ExtractFileName(FileName);
  n := Pos('.', Str1);
  str2 := copy(Str1, 1, n - 1); //这便是你想要的 K8team
  Result := str2;
end;

end.
