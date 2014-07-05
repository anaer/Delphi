unit CommonDll;

interface
uses Windows, Dialogs;
type
  TDLLFunction = procedure(sParam: string = ''); stdcall;

procedure RunDLLFunction(DLLFile: string; DLLFunction: string; sParam: string = ''; ShowError: Boolean = True); stdcall;
implementation

procedure RunDLLFunction(DLLFile: string; DLLFunction: string; sParam: string = ''; ShowError: Boolean = True); stdcall;
var
  Handle: THandle;
  DLLFunc: TDLLFunction;
begin
  Handle := LoadLibrary(PChar(DLLFile));
  if Handle <> 0 then
  begin
    @DLLFunc := GetProcAddress(Handle, PChar(DLLFunction));
    if @DLLFunc <> nil then
      DLLFunc(sParam)
    else if ShowError then
      ShowMessage(PChar('调用DLL文件"' + DLLFile + '"中的函数"' + DLLFunction + '"错误!'));
    FreeLibrary(Handle);
  end
  else if ShowError then
    ShowMessage(PChar('DLL文件"' + DLLFile + '"不存在!'));
end;
end.
