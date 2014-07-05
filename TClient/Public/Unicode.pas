{****************************************************************************}
{ Some Function of Ansi, UTF8, Unicode Converting (copy from Delphi6) }
{****************************************************************************}

unit Unicode;

interface

uses
  Classes, Windows, SysUtils;

type
  UTF8String = type string;
  PUTF8String = ^UTF8String;

  { PChar/PWideChar Unicode <-> UTF8 conversion }

  // UnicodeToUTF8(3):
  // UTF8ToUnicode(3):
  // Scans the source data to find the null terminator, up to MaxBytes
  // Dest must have MaxBytes available in Dest.
  // MaxDestBytes includes the null terminator (last char in the buffer will be set to null)
  // Function result includes the null terminator.

function UnicodeToUtf8(Dest: PChar; Source: PWideChar; MaxBytes: Integer): Integer; overload; //deprecated;
function Utf8ToUnicode(Dest: PWideChar; Source: PChar; MaxChars: Integer): Integer; overload; //deprecated;

// UnicodeToUtf8(4):
// UTF8ToUnicode(4):
// MaxDestBytes includes the null terminator (last char in the buffer will be set to null)
// Function result includes the null terminator.
// Nulls in the source data are not considered terminators - SourceChars must be accurate

function UnicodeToUtf8(Dest: PChar; MaxDestBytes: Cardinal; Source: PWideChar; SourceChars: Cardinal): Cardinal; overload;
function Utf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PChar; SourceBytes: Cardinal): Cardinal; overload;

{ WideString <-> UTF8 conversion }

function UTF8Encode(const WS: WideString): UTF8String;
function UTF8Decode(const S: UTF8String): WideString;

{ Ansi <-> UTF8 conversion }

function AnsiToUtf8(const S: string): UTF8String;
function Utf8ToAnsi(const S: UTF8String): string;

function AnsiToUtf8Xml(const S: string): UTF8String;

implementation

// UnicodeToUTF8(3):
// Scans the source data to find the null terminator, up to MaxBytes
// Dest must have MaxBytes available in Dest.

function UnicodeToUtf8(Dest: PChar; Source: PWideChar; MaxBytes: Integer): Integer;
var
  len: Cardinal;
begin
  len := 0;
  if Source <> nil then
    while Source[len] <> #0 do
      Inc(len);
  Result := UnicodeToUtf8(Dest, MaxBytes, Source, len);
end;

// UnicodeToUtf8(4):
// MaxDestBytes includes the null terminator (last char in the buffer will be set to null)
// Function result includes the null terminator.
// Nulls in the source data are not considered terminators - SourceChars must be accurate

function UnicodeToUtf8(Dest: PChar; MaxDestBytes: Cardinal; Source: PWideChar; SourceChars: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Cardinal;
begin
  Result := 0;
  if Source = nil then
    Exit;
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceChars) and (count < MaxDestBytes) do
    begin
      c := Cardinal(Source[i]);
      Inc(i);
      if c <= $7F then
      begin
        Dest[count] := Char(c);
        Inc(count);
      end
      else if c > $7FF then
      begin
        if count + 3 > MaxDestBytes then
          break;
        Dest[count] := Char($E0 or (c shr 12));
        Dest[count + 1] := Char($80 or ((c shr 6) and $3F));
        Dest[count + 2] := Char($80 or (c and $3F));
        Inc(count, 3);
      end
      else // $7F < Source[i] <= $7FF
      begin
        if count + 2 > MaxDestBytes then
          break;
        Dest[count] := Char($C0 or (c shr 6));
        Dest[count + 1] := Char($80 or (c and $3F));
        Inc(count, 2);
      end;
    end;
    if count >= MaxDestBytes then
      count := MaxDestBytes - 1;
    Dest[count] := #0;
  end
  else
  begin
    while i < SourceChars do
    begin
      c := Integer(Source[i]);
      Inc(i);
      if c > $7F then
      begin
        if c > $7FF then
          Inc(count);
        Inc(count);
      end;
      Inc(count);
    end;
  end;
  Result := count + 1; // convert zero based index to byte count
end;

function Utf8ToUnicode(Dest: PWideChar; Source: PChar; MaxChars: Integer): Integer;
var
  len: Cardinal;
begin
  len := 0;
  if Source <> nil then
    while Source[len] <> #0 do
      Inc(len);
  Result := Utf8ToUnicode(Dest, MaxChars, Source, len);
end;

function Utf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PChar; SourceBytes: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Byte;
  wc: Cardinal;
begin
  if Source = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := Cardinal(-1);
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceBytes) and (count < MaxDestChars) do
    begin
      wc := Cardinal(Source[i]);
      Inc(i);
      if (wc and $80) <> 0 then
      begin
        wc := wc and $3F;
        if i > SourceBytes then
          Exit; // incomplete multibyte char
        if (wc and $20) <> 0 then
        begin
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then
            Exit; // malformed trail byte or out of range char
          if i > SourceBytes then
            Exit; // incomplete multibyte char
          wc := (wc shl 6) or (c and $3F);
        end;
        c := Byte(Source[i]);
        Inc(i);
        if (c and $C0) <> $80 then
          Exit; // malformed trail byte

        Dest[count] := WideChar((wc shl 6) or (c and $3F));
      end
      else
        Dest[count] := WideChar(wc);
      Inc(count);
    end;
    if count >= MaxDestChars then
      count := MaxDestChars - 1;
    Dest[count] := #0;
  end
  else
  begin
    while (i <= SourceBytes) do
    begin
      c := Byte(Source[i]);
      Inc(i);
      if (c and $80) <> 0 then
      begin
        if (c and $F0) = $F0 then
          Exit; // too many bytes for UCS2
        if (c and $40) = 0 then
          Exit; // malformed lead byte
        if i > SourceBytes then
          Exit; // incomplete multibyte char

        if (Byte(Source[i]) and $C0) <> $80 then
          Exit; // malformed trail byte
        Inc(i);
        if i > SourceBytes then
          Exit; // incomplete multibyte char
        if ((c and $20) <> 0) and ((Byte(Source[i]) and $C0) <> $80) then
          Exit; // malformed trail byte
        Inc(i);
      end;
      Inc(count);
    end;
  end;
  Result := count + 1;
end;

function Utf8Encode(const WS: WideString): UTF8String;
var
  L: Integer;
  Temp: UTF8String;
begin
  Result := '';
  if WS = '' then
    Exit;
  SetLength(Temp, Length(WS) * 3); // SetLength includes space for null terminator

  L := UnicodeToUtf8(PChar(Temp), Length(Temp) + 1, PWideChar(WS), Length(WS));
  if L > 0 then
    SetLength(Temp, L - 1)
  else
    Temp := '';
  Result := Temp;
end;

function Utf8Decode(const S: UTF8String): WideString;
var
  L: Integer;
  Temp: WideString;
begin
  Result := '';
  if S = '' then
    Exit;
  SetLength(Temp, Length(S));

  L := Utf8ToUnicode(PWideChar(Temp), Length(Temp) + 1, PChar(S), Length(S));
  if L > 0 then
    SetLength(Temp, L - 1)
  else
    Temp := '';
  Result := Temp;
end;

function AnsiToUtf8(const S: string): UTF8String;
begin
  Result := Utf8Encode(S);
end;

function Utf8ToAnsi(const S: UTF8String): string;
begin
  Result := Utf8Decode(S);
end;

function AnsiToUtf8Xml(const S: string): UTF8String;
var //only process '&', ... &#xB4 ...
  i: Integer;
begin
  Result := S;
  i := 1;
  while i <= Length(Result) do
  begin
    case Result[i] of
      '&':
        begin
          Insert('amp;', Result, i + 1);
          Inc(i, 4);
        end;
      '>':
        begin
          Result[i] := '&';
          Insert('gt;', Result, i + 1);
          Inc(i, 3);
        end;
      '<':
        begin
          Result[i] := '&';
          Insert('lt;', Result, i + 1);
          Inc(i, 3);
        end;
      '"':
        begin
          Result[i] := '&';
          Insert('quot;', Result, i + 1);
          Inc(i, 5);
        end;
      '''':
        begin
          Result[i] := '&';
          Insert('apos;', Result, i + 1);
          Inc(i, 5);
        end;
      #128..#255: //process wearer¡äs ¡ä=&#xB4;
        begin
          Insert('#x' + IntToHex(Ord(Result[i]), 2) + ';', Result, i + 1);
          Result[i] := '&';
          Inc(i, 5);
        end;
    end;
    Inc(i);
  end;
  Result := AnsiToUtf8(Result);
end;

end.
