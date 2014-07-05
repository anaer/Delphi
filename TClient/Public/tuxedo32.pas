unit Tuxedo32;
interface
{$DEFINE WS}
const
  {add by ming}
  TPMULTICONTEXTS = 32;
  {Flags for service routines}
  TPNOBLOCK = $00000001;
  TPSIGRSTRT = $00000002;
  TPNOREPLY = $00000004;
  TPNOTRAN = $00000008;
  TPTRAN = $00000010;
  TPNOTIME = $00000020;
  TPABSOLUTE = $00000040;
  TPGETANY = $00000080;
  TPNOCHANGE = $00000100;
  TPCONV = $00000400;
  TPSENDONLY = $00000800;
  TPRECVONLY = $00001000;
  TPACK = $00002000;
  {Flags for tpreturn()}
  TPFAIL = $00000001;
  TPSUCCESS = $00000002;
  TPEXIT = $08000000;
  {Flags for tpscmt()}
  TP_CMT_LOGGED = $01;
  TP_CMT_COMPLETE = $02;
  {Flags to tpinit()}
  TPU_MASK = $00000007;
  TPU_SIG = $00000001;
  TPU_DIP = $00000002;
  TPU_IGN = $00000004;
  TPSA_FASTPATH = $00000008;
  TPSA_PROTECTED = $00000010;
  {Flags to tpconvert()}
  TPTOSTRING = $40000000;
  TPCONVCLTID = $00000001;
  TPCONVTRANID = $00000002;
  TPCONVXID = $00000004;
  TPCONVMAXSTR = 256;
  {Return values of tpchkauth()}
  TPNOAUTH = 0;
  TPSYSAUTH = 1;
  TPAPPAUTH = 2;
  {Misc}
  MAXTIDENT = 30;
  {Errors}
  TPEABORT = 1;
  TPEBADDESC = 2;
  TPEBLOCK = 3;
  TPEINVAL = 4;
  TPELIMIT = 5;
  TPENOENT = 6;
  TPEOS = 7;
  TPEPERM = 8;
  TPEPROTO = 9;
  TPESVCERR = 10;
  TPESVCFAIL = 11;
  TPESYSTEM = 12;
  TPETIME = 13;
  TPETRAN = 14;
  TPGOTSIG = 15;
  TPERMERR = 16;
  TPEITYPE = 17;
  TPEOTYPE
    = 18;
  TPERELEASE
    = 19;
  TPEHAZARD
    = 20;
  TPEHEURISTIC = 21;
  TPEEVENT
    = 22;
  TPEMATCH
    = 23;
  TPEDIAGNOSTIC = 24;
  TPEMIB
    = 25;
  { conversations - events }
  TPEV_DISCONIMM = $0001;
  TPEV_SVCERR
    = $0002;
  TPEV_SVCFAIL
    = $0004;
  TPEV_SVCSUCC
    = $0008;
  TPEV_SENDONLY = $0020;
type
  PPChar
    = ^Pchar;
  PShortInt = ^ShortInt;
  PLongInt
    = ^LongInt;
  PInteger
    = Integer;
  PSingle
    = ^Single;
  PExtended = extended;
  TClientid = record
    Clientdata: array[1..4] of LongInt;
  end;
  PTClientid = ^TClientid;
  {add by kongdl for add fml declare}
  {add by kongdl}
  {XATMI}
type
  TTpsvcinfo = record
    Name: array[0..31] of Char;
    Flags: LongInt;
    Data: PChar;
    Len: LongInt;
    Cd: Integer;
    Appkey: LongInt;
    Cltid: TClientid;
  end;
  PTTpsvcinfo = ^TTpsvcinfo;
function tpacall
  (Svc, Data: PChar; Len, Flags: LongInt): Integer; stdcall;
function tpadvertise
  (Svcname: PChar; Tpsvcinfo: Pointer): Integer; stdcall;
function tpalloc
  (Maintype, Subtype: PChar; Size: LongInt): Pointer; stdcall;
//function tpcall ( Svc, Idata: PChar; Ilen: LongInt; Odata: PPChar; Olen: PLongInt; Flags:LongInt ):Integer; stdcall;
function tpcall(SVCNAME: pChar;
  IDATA: pChar; ILEN: LongInt;
  var ODATA: pChar; var OLEN: LongInt;
  flags: LongInt): Integer;
stdcall; external 'wtuxws32.dll'
function tpcancel
  (Cd: Integer): Integer; stdcall;
function tpconnect
  (Svc, Data: PChar; Len, Flags: LongInt): Integer; stdcall;
function tpdiscon
  (Cd: Integer): Integer; stdcall;
procedure tpfree
  (Ptr: PChar); stdcall;
function tpgetrply
  (Cd: PInteger; Data: PPChar; Len: PLongInt; Flags: LongInt): Integer; stdcall;
function tprealloc
  (Ptr: PChar; Size: LongInt): PChar; stdcall;
function tprecv
  (Cd: Integer; Data: PPChar; Len: PLongInt; Flags: LongInt; Revent: PLongInt):
  Integer; stdcall;
procedure tpreturn
  (Rval: Integer; Rcode: LongInt; Data: PChar; Len, Flags: LongInt); stdcall;
function tpsend
  (Cd: Integer; Data: PChar; Len, Flags: LongInt; Revent: PLongInt): Integer; stdcall;
procedure tpservice
  (Svcinfo: PTTpsvcinfo); stdcall;
function tptypes
  (Ptr, Maintype, Subtype: PChar): LongInt; stdcall;
function tpunadvertise(Svcname: PChar): Integer; stdcall;
//hz add
function tpgetctxt(context: PLongInt; flags: LongInt): Integer; stdcall;
function tpsetctxt(context: LongInt; flags: LongInt): Integer; stdcall;
{ATMI}
type
  TTpinit = record
    Usrname: array[0..31] of Char;
    Cltname: array[0..31] of Char;
    Passwd: array[0..31] of Char;
    Grpname: array[0..31] of Char;
    Flags: LongInt;
    Datalen: LongInt;
    Data: longInt;
  end;
  TTpqctl = record
    Flags: LongInt;
    Deq_time: LongInt;
    Priority: LongInt;
    Diagnostic: LongInt;
    Msgid: array[0..31] of Char;
    Corrid: array[0..31] of Char;
    Replyqueue: array[0..16] of Char;
    Failurequeue: array[0..16] of Char;
    Cltid: TClientid;
    Urcode: LongInt;
    Appkey: LongInt;
  end;
  TTpevctl = record
    Flags: LongInt;
    Name1: array[0..31] of Char;
    Name2: array[0..31] of Char;
    Qctl: TTpqctl;
  end;
  TTptranid = record
    Info: array[0..5] of LongInt;
  end;
  PTTpinit
    = ^TTpinit;
  PTTpqctl
    = ^TTpqctl;
  PTTpevctl = ^TTpevctl;
  PTTptranid = ^TTptranid;
  Unsolhandler = procedure(Data: PChar; Len, Flags: LongInt); stdcall;
function tpabort
  (Flags: LongInt): Integer; stdcall;
function tpbegin
  (Timeout, Flags: LongInt): Integer; stdcall;
function tpbroadcast
  (Lmid, Usrname, Cltname, Data: PChar; Len, Flags: LongInt): Integer; stdcall;
function tpchkauth
  : Integer; stdcall;
function tpchkunsol
  : Integer; stdcall;
function tpcommit
  (Flags: LongInt): Integer; stdcall;
function tpdequeue
  (Qspace, Qname: PChar; Ctl: PTTpqctl; Data: PPChar; Len: PLongInt; Flags:
  LongInt): Integer; stdcall;
function tpenqueue
  (Qspace, Qname: PChar; Ctl: PTTpqctl; Data: PChar; Len, Flags: LongInt):
  Integer; stdcall;
procedure tpforward
  (Svc, Data: PChar; Len, Flags: LongInt); stdcall;
function tpgetlev
  : Integer; stdcall;
function tpgprio
  : Integer; stdcall;
function tpinit
  (Tpinfo: PTTpinit): Integer; stdcall;
function tpnotify
  (Clientid: PTClientid; Data: PChar; Len, Flags: LongInt): Integer; stdcall;
function tppost
  (Eventname, Data: PChar; Len, Flags: LongInt): Integer; stdcall;
function tpresume
  (Tranid: PTTptranid; Flags: LongInt): Integer; stdcall;
function tpsetunsol
  (Disp: Unsolhandler): Unsolhandler; stdcall;
function tpsprio
  (Prio: Integer; Flags: LongInt): Integer; stdcall;
function tpstrerror
  (Err: Integer): PChar; stdcall;
function tpsubscribe
  (Eventexpr, Filter: PChar; Ctl: PTTpevctl; Flags: LongInt): Integer; stdcall;
function tpsuspend
  (Tranid: PTTptranid; Flags: LongInt): Integer; stdcall;
procedure tpsvrdone
  ; stdcall;
function tpsvrinit
  (Argc: Integer; Argv: PPChar): Integer; stdcall;
function tpterm
  : Integer; stdcall;
function tpunsubscribe(Subscription, Flags: LongInt): Integer; stdcall;
{TX}
type
  Txid = record
    FormatID: LongInt;
    Gtrid_Length: LongInt;
    Bqual_length: LongInt;
    Data: array[0..127] of Char;
  end;
  TTxinfo = record
    XID: TXID;
    When_Return: LongInt;
    Tran_Control: LongInt;
    Tran_Timeout: LongInt;
    Tran_State: LongInt;
  end;
  COMMIT_RETURN
    = LongInt;
  TRANSACTION_CONTROL = LongInt;
  TRANSACTION_TIMEOUT = LongInt;
function tx_begin
  : Integer; stdcall;
function tx_close
  : Integer; stdcall;
function tx_commit
  : Integer; stdcall;
function tx_info
  (Info: Pointer): Integer; stdcall;
function tx_open
  : Integer; stdcall;
function tx_rollback
  : Integer; stdcall;
function tx_set_commit_return
  (When_return: COMMIT_RETURN): Integer; stdcall;
function tx_set_transaction_control(Control: TRANSACTION_CONTROL): Integer; stdcall;
function tx_set_transaction_timeout(Timeout: TRANSACTION_TIMEOUT): Integer; stdcall;
{FML}
type
  FLDIDD = Word;
  FLDLEN = Word;
  FLDOCC = Integer;
  TFbfr = record
    Magic: Integer;
    Len: FLDLEN;
    Maxlen: FLDLEN;
    Nie: FLDLEN;
    Indxintvl: FLDLEN;
    Val: array[0..7] of Byte;
  end;
  TFldidArray = array[0..99] of FLDIDD;
  PFLDIDD = ^FLDIDD;
  PFLDLEN = ^FLDLEN;
  PFLDOCC = ^FLDOCC;
  PTFbfr = ^TFbfr;
  PFldidArray = ^TFldidArray;
function Fadd(Fbfr: PTFbfr; Fieldid: FLDIDD; Value: Pointer; Len: FLDLEN): Integer; stdcall;
function Falloc(F: FLDOCC; V: FLDLEN): PTFbfr; stdcall;
function Fchg(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC; Value: Pointer; Len: FLDLEN): Integer;
stdcall;
function Fcmp(Fbfr1, Fbfr2: PTFbfr): Integer; stdcall;
function Fcpy(Dest, Src: PTFbfr): Integer; stdcall;
function Fdel(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC): Integer; stdcall;
function Fdel32(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC): Integer; stdcall;
function Fdelall(Fbfr: PTFbfr; Fieldid: FLDIDD): Integer; stdcall;
function Fdelete(Fbfr: PTFbfr; PFieldid: PFldidArray): Integer; stdcall;
function Ffind(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC; Len: PFLDLEN): Pointer; stdcall;
function Ffindlast(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: PFLDOCC; Len: PFLDLEN): integer; stdcall;
function Ffindocc(Fbfr: PTFbfr; Fieldid: FLDIDD; Value: Pointer; Len: FLDLEN): FLDOCC; stdcall;
function Fget(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC; Value: Pointer; Maxlen: PFLDLEN):
  Integer; stdcall;
function Fgetalloc(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC; Extralen: PFLDLEN): Pointer; stdcall;
function Fgetlast(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: PFLDOCC; Value: Pointer; Maxlen: PFLDLEN):
  Integer; stdcall;
function Finit(Fbfr: PTFbfr; Buflen: FLDLEN): Integer; stdcall;
function Fldid(Name: PChar): FLDIDD; stdcall;
function Fldno(Fieldid: FLDIDD): Integer; stdcall;
function Fldtype(Fieldid: FLDIDD): Integer; stdcall;
function Fmkfldid(Itype: Integer; Num: FLDIDD): FLDIDD; stdcall;
function Fmove(Dest: PChar; Src: PTFbfr): Integer; stdcall;
function Fname(Fieldid: FLDIDD): PChar; stdcall;
function Fneeded(F: FLDOCC; V: FLDLEN): LongInt; stdcall;
function Ffree(Fbfr: PTFbfr): Integer; stdcall;
function Fnext(Fbfr: PTFbfr; Fieldid: PFLDIDD; Oc: PFLDOCC; Value: Pointer; Len: PFLDLEN):
  Integer; stdcall;
function Fnum(Fbfr: PTFbfr): FLDOCC; stdcall;
function Foccur(Fbfr: PTFbfr; Fieldid: FLDIDD): FLDOCC; stdcall;
function Fpres(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC): Integer; stdcall;
function Frealloc(Fbfr: PTFbfr; Nf: FLDOCC; Nv: FLDLEN): PTFbfr; stdcall;
function Fsizeof(Fbfr: PTFbfr): LongInt; stdcall;
function Ftype(Fieldid: FLDIDD): PChar; stdcall;
function Funused(Fbfr: PTFbfr): LongInt; stdcall;
function Fused(Fbfr: PTFbfr): LongInt; stdcall;
function Fvall(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC): LongInt; stdcall;
function Fvals(Fbfr: PTFbfr; FIeldid: FLDIDD; Oc: FLDOCC): PChar; stdcall;
function Fconcat(Dest, Src: PTFbfr): Integer; stdcall;
function Fjoin(Dest, Src: PTFbfr): Integer; stdcall;
function Fojoin(Dest, Src: PTFbfr): Integer; stdcall;
function Fproj(Fbfr: PTFbfr; Fieldid: PFldidArray): Integer; stdcall;
function Fprojcpy(Dest, Src: PTFbfr; Fieldid: PFldidArray): Integer; stdcall;
function Fupdate(Dest, Src: PTFbfr): Integer; stdcall;
function CFadd(Fbfr: PTFbfr; Fieldid: FLDIDD; Value: PChar; Len: FLDLEN; Itype: Integer): Integer;
stdcall;
function CFchg(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC; Value: PChar; Len: FLDLEN; Itype:
  Integer): Integer; stdcall;
function CFget(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC; Buf: PChar; Len: PFLDLEN; Itype:
  Integer): Integer; stdcall;
function CFgetalloc(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC; Itype: Integer; Extralen: PFLDLEN):
  PChar; stdcall;
function CFfind(Fbfr: PTFbfr; Fieldid: FLDIDD; Oc: FLDOCC; Len: PFLDLEN; Itype: Integer): PChar;
stdcall;
function CFfindocc(Fbfr: PTFbfr; Fieldid: FLDIDD; Value: PChar; Len: FLDLEN; Itype: Integer):
  Integer; stdcall;
function Ftypcvt(Tolen: PFLDLEN; Totype: Integer; Fromval: PChar; Fromtype: Integer; Fromlen:
  FLDLEN): PChar; stdcall;
function Fidxused(Fbfr: PTFbfr): Integer; stdcall;
function Findex(Fbfr: PTFbfr; Intvl: FLDOCC): Integer; stdcall;
function Frstrindex(Fbfr: PTFbfr; Numidx: FLDOCC): Integer; stdcall;
function Funindex(Fbfr: PTFbfr): Integer; stdcall;
function Fboolco(Expression: PChar): PChar; stdcall;
function Fboolev(Fbfr: PTFbfr; Tree: PChar): Integer; stdcall;
function Ffloatev(Fbfr: PTFbfr; Tree: PChar): Double; stdcall;
procedure Fidnm_unload; stdcall;
procedure Fnmid_unload; stdcall;
function Fchksum(Fbfr: PTFbfr): LongInt; stdcall;
function Fielded(Fbfr: PTFbfr): Integer; stdcall;
function Fstrerror(Err: Integer): PChar; stdcall;
{Miscellaneous}
type
  TNl_catd = record
    Catd_set: PChar;
    Catd_msgs: PChar;
    Catd_data: PChar;
    Catd_set_nr: Integer;
    Catd_type: Char;
  end;
  Nl_item = Integer;
  PTNl_catd = ^TNl_catd;
function catgets
  (Catd: PTNl_catd; Set_num, Msg_num: Integer; S: PChar): PChar; stdcall;
function catopen
  (Name: PChar; Oflag: Integer): PTNl_catd; stdcall;
function catclose
  (Catd: PTNl_catd): Integer; stdcall;
function gettperrno: Integer; stdcall;
//add by kongdl
function gettpurcode: integer; stdcall
//add by kongdl
function nl_langinfo(Item: Nl_item): PChar; stdcall;
function tuxgetenv
  (Name: PChar): PChar; stdcall;
function tuxputenv
  (Envstring: PChar): Integer; stdcall;
function tuxreadenv(Envfile, Envlabel: PChar): Integer; stdcall;
function userlog
  (Format: PChar): Integer; stdcall;
{$IFDEF WS}
function bq
  (Cmd: PChar): Integer; stdcall;
function setlocale
  (Category: Integer; Locale: PChar): PChar; stdcall;
{$ENDIF}
{Others}
type
  TTm = record
    Tm_sec:
    Integer;
    Tm_min:
    Integer;
    Tm_hour: Integer;
    Tm_mday: Integer;
    Tm_mon:
    Integer;
    Tm_year: Integer;
    Tm_wday: Integer;
    Tm_yday: Integer;
    Tm_isdst: Integer;
  end;
  PTTm = ^TTm;
function gp_mktime(Time: PTTm): LongInt; stdcall;
implementation
{XATMI}

function tpacall
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpacall';

function tpadvertise
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpadvertise';

function tpalloc
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpalloc';
//function tpcall    ; stdcall ; external {$IFDEF WS} 'wtuxws32.dll' {$ELSE} 'libtux.dll' {$ENDIF} name 'tpcall';

function tpcancel
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpcancel';

function tpconnect
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpconnect';

function tpdiscon
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpdiscon';

procedure tpfree
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpfree';

function tpgetrply
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpgetrply';

function tprealloc
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tprealloc';

function tprecv
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tprecv';

procedure tpreturn
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpreturn';

function tpsend
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpsend';

procedure tpservice
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpservice';

function tptypes
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tptypes';

function tpunadvertise; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpunadvertise';

function tpgetctxt
  ; stdcall; external{$IFDEF WS} 'libtux.dll'{$ELSE} 'wtuxws32.dll'{$ENDIF}name
'tpgetctxt';

function tpsetctxt
  ; stdcall; external{$IFDEF WS} 'libtux.dll'{$ELSE} 'wtuxws32.dll'{$ENDIF}name
'tpsetctxt';
{ATMI}

function tpabort
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpabort';

function tpbegin
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpbegin';

function tpbroadcast
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpbroadcast';

function tpchkauth
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpchkauth';

function tpchkunsol
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpchkunsol';

function tpcommit
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpcommit';

function tpdequeue
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpdequeue';

function tpenqueue
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpenqueue';

procedure tpforward
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpforward';

function tpgetlev
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpgetlev';

function tpgprio
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpgprio';

function tpinit
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpinit';

function tpnotify
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpnotify';

function tppost
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tppost';

function tpresume
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpresume';

function tpsetunsol
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpsetunsol';

function tpsprio
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpsprio';

function tpstrerror
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpstrerror';

function tpsubscribe
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpsubscribe';

function tpsuspend
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpsuspend';

procedure tpsvrdone
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpsvrdone';

function tpsvrinit
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpsvrinit';

function tpterm
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'tpterm';

function tpunsubscribe; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tpunsubscribe';
{TX}

function tx_begin
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'
{$ENDIF}name 'tx_begin';

function tx_close
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tx_close';

function tx_commit
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'
{$ENDIF}name 'tx_commit';

function tx_info
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}
name 'tx_info';

function tx_open
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'
{$ENDIF}name 'tx_open';

function tx_rollback
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'
{$ENDIF}name 'tx_rollback';

function tx_set_commit_return
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'
{$ENDIF}name 'tx_set_commit_return';

function tx_set_transaction_control; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'
{$ENDIF}name 'tx_set_transaction_control';

function tx_set_transaction_timeout; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'
{$ENDIF}name 'tx_set_transaction_timeout';
{FML}

function Fadd
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fadd';

function Falloc
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Falloc';

function Fchg
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fchg';

function Fcmp
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fcmp';

function Fcpy
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fcpy';

function Fdel32
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fdel32';
//function Fdel    ; stdcall ; external {$IFDEF WS} 'wtuxws32.dll' {$ELSE} 'libfml.dll' {$ENDIF} name 'Fdel';

function Fdel; stdcall; external 'libfml.dll' name 'Fdel';

function Fdelall
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fdelall';

function Fdelete
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fdelete';

function Ffind
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Ffind';

function Ffindlast
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Ffindlast';

function Ffindocc
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Ffindocc';

function Ffree
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Ffree';

function Fget
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fget';

function Fgetalloc
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fgetalloc';

function Fgetlast
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fgetlast';

function Finit
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Finit';

function Fldid
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fldid';

function Fldno
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fldno';

function Fldtype
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fldtype';

function Fmkfldid
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fmkfldid';

function Fmove
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fmove';

function Fname
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fname';

function Fneeded
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fneeded';

function Fnext
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fnext';

function Fnum
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fnum';

function Foccur
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Foccur';

function Fpres
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fpres';

function Frealloc
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Frealloc';

function Fsizeof
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fsizeof';

function Ftype
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Ftype';

function Funused
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Funused';

function Fused
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fused';

function Fvall
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fvall';

function Fvals
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fvals';

function Fconcat
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fconcat';

function Fjoin
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fjoin';

function Fojoin
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fojoin';

function Fproj
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fproj';

function Fprojcpy
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fprojcpy';

function Fupdate
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fupdate';

function CFadd
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'CFadd';

function CFchg
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'CFchg';

function CFget
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'CFget';

function CFgetalloc
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'CFgetalloc';

function CFfind
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'CFfind';

function CFfindocc
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'CFfindocc';

function Ftypcvt
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Ftypcvt';

function Fidxused
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fidxused';

function Findex
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Findex';

function Frstrindex
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Frstrindex';

function Funindex
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Funindex';

function Fboolco
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fboolco';

function Fboolev
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fboolev';

function Ffloatev
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Ffloatev';

procedure Fidnm_unload; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}
name 'Fidnm_unload';

procedure Fnmid_unload; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}
name 'Fnmid_unload';

function Fchksum
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fchksum';

function Fielded
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fielded';

function Fstrerror
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libfml.dll'{$ENDIF}name
'Fstrerror';
{Miscellaneous}

function catgets
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libgp.dll'{$ENDIF}name
'catgets';

function catopen
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libgp.dll'{$ENDIF}name
'catopen';

function catclose
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libgp.dll'{$ENDIF}name
'catclose';

function gettperrno; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'gettperrno';
//add by kongdl

function gettpurcode; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'gettpurcode';
//add by kongdl

function nl_langinfo; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libgp.dll'{$ENDIF}name
'nl_langinfo';

function tuxgetenv
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libgp.dll'{$ENDIF}name
'tuxgetenv';

function tuxputenv
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libgp.dll'{$ENDIF}name
'tuxputenv';

function tuxreadenv; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libgp.dll'{$ENDIF}name
'tuxreadenv';

function userlog
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libtux.dll'{$ENDIF}name
'userlog';
{$IFDEF WS}

function bq
  ; stdcall; external 'wtuxws32.dll' name 'bq';

function setlocale
  ; stdcall; external 'wtuxws32.dll' name 'setlocale';
{$ENDIF}
{Others}

function gp_mktime
  ; stdcall; external{$IFDEF WS} 'wtuxws32.dll'{$ELSE} 'libgp.dll'{$ENDIF}name
'gp_mktime';
end.
