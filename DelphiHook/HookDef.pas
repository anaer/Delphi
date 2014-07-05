unit HookDef;

interface
uses
    Windows, Messages, SysUtils, Classes, Dialogs;
type
    TKeyProc = function (iCode: Integer; wParam: WPARAM; lParam: LPARAM): LResult; stdcall;

    THook = class
    private
        FHook: HHook;
        FKeyProc: TKeyProc;
        function LoadKeyHook: Boolean;
        function UnLoadKeyHook: Boolean;
    public
        constructor Create(AProc:TKeyProc);
        destructor Destroy; override;
        property  KeyProc: TKeyProc read FKeyProc;
    end;
    
    //公共函数
    function KeyBoardHook(iCode: Integer; wParam: WPARAM; lParam: LPARAM): LResult; stdcall;

var
    gHook :HHook;
    
implementation

{ THook }

constructor THook.Create(AProc: TKeyProc);
begin
    FKeyProc := AProc;
    LoadKeyHook;
end;

destructor THook.Destroy;
begin
    UnLoadKeyHook;
end;

function KeyBoardHook(iCode: Integer; wParam: WPARAM; lParam: LPARAM): LResult;
var
    Arry: array[0..3] of byte;
begin
    if icode = HC_ACTION then
    begin
        Move(lParam, Arry[0], 4);
        //按键
        if Arry[3] = 192 then
        begin
          case Wparam of
             65..90:
                 ShowMessage('字符 ' + chr(wParam));
             48..57:
                 ShowMessage(IntToStr(wParam) + ' 数字 '+ chr(wParam));
             96..105:
                 ShowMessage(IntToStr(wParam) + ' 小键盘数字' + chr(wParam));
             else
                 ShowMessage(IntToStr(wParam) + chr(wParam));
           end;
           Result := CallNextHookEx(gHook, iCode, wParam, lParam);
        end;
    end
    else
        Result := CallNextHookEx(gHook, iCode, wParam, lParam);
end;

 function THook.LoadKeyHook: Boolean;
begin
    FHook := SetWindowsHookex(WH_keyboard, KeyProc, HInstance, 0);
    Result := FHook > 0 ;
    gHook := FHook;
end;

function THook.UnLoadKeyHook: Boolean;
begin
    UnHookWindowsHookEx(FHook);
end;

end.
 