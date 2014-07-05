unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SQLite3, SQLiteTable3, StdCtrls, Grids, DBGrids, Db, DBClient, mytool,
  ComCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ListView1: TListView;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  sldb: TSQLiteDatabase; {数据库变量}

function InitDataBase(dbName: string = 'config'): Boolean;
function InitTable(tableName: string): Boolean;
function CustomSortProc(Item1, Item2: TListItem; ColumnIndex: integer): integer;
stdcall;
procedure ListViewItemMoveUpDown(lv: TListView; Item: TListItem; MoveUp,
  SetFocus: Boolean);
implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  InitDataBase();
  InitTable('a');
end;

{初始化数据库}

function InitDataBase(dbName: string = 'config'): Boolean;
begin
  Result := False;

  {初始化数据库文件}
  if sldb <> nil then
    FreeAndNil(sldb);
  sldb := TSQLiteDatabase.Create(dbName);

end;

function InitTable(tableName: string): Boolean;
begin
  if sldb = nil then
  begin
    InitDataBase();
  end;

  {初始化表}
  if not sldb.TableExists('a') then
  begin
    sldb.ExecSQL('create table a(aa, bb)');
  end
  else
  begin
    sldb.ExecSQL('delete from a');
  end;

  if sldb.TableExists('a') then
  begin
    sldb.BeginTransaction;
    sldb.ExecSQL('insert into a values (''1'',''1'')');
    sldb.ExecSQL('insert into a values(''中文'',''2'')');
    sldb.ExecSQL('insert into a values(''3'',''下载'')');
    sldb.ExecSQL('insert into a values("测试","4")');
    sldb.ExecSQL('insert into a values (''1'',''1'')');
    sldb.ExecSQL('insert into a values(''中文'',''2'')');
    sldb.ExecSQL('insert into a values(''3'',''下载'')');
    sldb.ExecSQL('insert into a values("测试","4")');
    sldb.ExecSQL('insert into a values (''1'',''1'')');
    sldb.ExecSQL('insert into a values(''中文'',''2'')');
    sldb.ExecSQL('insert into a values(''3'',''下载'')');
    sldb.ExecSQL('insert into a values("测试","4")');
    sldb.Commit;
  end;

  Result := True;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  table: TSQLiteTable;
//  i: integer;
  tempNode: TListItem;
begin
  if sldb = nil then
    InitDataBase();

  if not sldb.TableExists('a') then
    InitTable('a');

  table := TSQLiteTable.Create(sldb, 'select * from a;');
  table.MoveFirst;
  while not table.EOF do
  begin
    tempNode := ListView1.Items.Add;
    tempNode.Caption := table.FieldAsString(0);
    tempNode.SubItems.Add(table.FieldAsString(0));
    tempNode.SubItems.Add(table.FieldAsString(1));

    table.Next;
  end;
end;

function getAllData(tableName: string): TDataSet;
var
  table: TSQLiteTable;
begin
  if sldb = nil then
    InitDataBase();

  if not sldb.TableExists(tableName) then
    InitTable(tableName);

  table := TSQLiteTable.Create(sldb, 'select * from ' + tableName);
  table.MoveFirst;
  while not table.EOF do
  begin
    table.Next;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //ListView1.Clear;
  ListView1.Columns.Clear;
  ListView1.Columns.Add;
  ListView1.Columns.Add;
  ListView1.Columns.Add;
  ListView1.Columns.Items[0].Caption := 'id';
  ListView1.Columns.Items[1].Caption := 'type';
  ListView1.Columns.Items[2].Caption := 'title';
  ListView1.Columns.Items[2].Width := 300;
  Listview1.ViewStyle := vsreport;
  Listview1.GridLines := true; //注:此处代码也可以直接在可视化编辑器中完成,
end;

{点击列头排序}

procedure TForm1.ListView1ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  ListView1.CustomSort(@CustomSortProc, Column.Index);
end;

{自定义排序规则}

function CustomSortProc(Item1, Item2: TListItem; ColumnIndex: integer): integer;
  stdcall;
begin
  if ColumnIndex = 0 then
    Result := CompareText(Item1.Caption, Item2.Caption)
  else
    Result := CompareText(Item1.SubItems[ColumnIndex - 1],
      Item2.SubItems[ColumnIndex - 1])
end;

procedure ListViewItemMoveUpDown(lv: TListView; Item: TListItem; MoveUp,
  SetFocus: Boolean);
var
  DestItem: TListItem;
begin
  if (Item = nil) or
    ((Item.Index - 1 < 0) and MoveUp) or
    ((Item.Index + 1 >= lv.Items.Count) and (not MoveUp)) then
    Exit;
  lv.Items.BeginUpdate;
  try
    if MoveUp then
      DestItem := lv.Items.Insert(Item.Index - 1)
    else
      DestItem := lv.Items.Insert(Item.Index + 2);
    DestItem.Assign(Item);
    lv.Selected := DestItem;
    Item.Free;
  finally
    lv.Items.EndUpdate;
  end;
  if SetFocus then
    lv.SetFocus;
  DestItem.MakeVisible(False);
end;

{隔行分颜色显示}

procedure TForm1.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  i: integer;
begin
  i := (Sender as TListView).Items.IndexOf(Item);
  if odd(i) then
    sender.Canvas.Brush.Color := $02E0F0D7
  else
    sender.Canvas.Brush.Color := $02F0EED7;
  Sender.Canvas.FillRect(Item.DisplayRect(drIcon));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ListViewItemMoveUpDown(ListView1, ListView1.Selected, True, True); //上移
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ListViewItemMoveUpDown(ListView1, ListView1.Selected, False, True); //下移
end;

end.

