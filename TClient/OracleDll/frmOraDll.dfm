object Form1: TForm1
  Left = 208
  Top = 140
  Width = 870
  Height = 500
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 862
    Height = 466
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      object pnl1: TPanel
        Left = 0
        Top = 0
        Width = 854
        Height = 438
        Align = alClient
        Alignment = taLeftJustify
        TabOrder = 0
        object mmo1: TMemo
          Left = 273
          Top = 1
          Width = 580
          Height = 330
          Align = alClient
          Lines.Strings = (
            'mmo1')
          TabOrder = 0
        end
        object Panel2: TPanel
          Left = 1
          Top = 1
          Width = 272
          Height = 330
          Align = alLeft
          Caption = '`'
          TabOrder = 1
          object Label2: TLabel
            Left = 64
            Top = 208
            Width = 132
            Height = 13
            Caption = '导入前需要先删除所有表'
          end
          object Button2: TButton
            Left = 182
            Top = 8
            Width = 75
            Height = 25
            Caption = '读取参数'
            TabOrder = 0
            OnClick = Button2Click
          end
          object Button3: TButton
            Left = 182
            Top = 40
            Width = 75
            Height = 25
            Caption = '保存参数'
            TabOrder = 1
            OnClick = Button3Click
          end
          object Button4: TButton
            Left = 182
            Top = 72
            Width = 75
            Height = 25
            Caption = '默认参数'
            TabOrder = 2
            OnClick = Button4Click
          end
          object Button5: TButton
            Left = 182
            Top = 104
            Width = 75
            Height = 25
            Caption = '执行'
            TabOrder = 3
            OnClick = Button5Click
          end
          object Button6: TButton
            Left = 0
            Top = 280
            Width = 75
            Height = 25
            Caption = '刷新日志'
            TabOrder = 4
            OnClick = Button6Click
          end
          object ComboBox2: TComboBox
            Left = 16
            Top = 8
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 5
            OnChange = ComboBox2Change
            Items.Strings = (
              '导出'
              '导入')
          end
          object Button7: TButton
            Left = 32
            Top = 88
            Width = 75
            Height = 25
            Caption = '测试1'
            TabOrder = 6
            OnClick = Button7Click
          end
        end
        object pnl5: TPanel
          Left = 1
          Top = 331
          Width = 852
          Height = 106
          Align = alBottom
          Caption = 'pnl5'
          TabOrder = 2
          object mmo2: TMemo
            Left = 1
            Top = 1
            Width = 850
            Height = 104
            Align = alClient
            ScrollBars = ssVertical
            TabOrder = 0
          end
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 854
        Height = 438
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 0
        object Edit1: TEdit
          Left = 48
          Top = 16
          Width = 121
          Height = 21
          TabOrder = 0
          Text = 'test999'
        end
        object Edit2: TEdit
          Left = 48
          Top = 40
          Width = 121
          Height = 21
          TabOrder = 1
          Text = 'test999'
        end
        object Edit3: TEdit
          Left = 48
          Top = 64
          Width = 121
          Height = 21
          TabOrder = 2
          Text = 'Edit1'
        end
        object Edit4: TEdit
          Left = 48
          Top = 88
          Width = 121
          Height = 21
          TabOrder = 3
          Text = 'Edit1'
        end
        object Button1: TButton
          Left = 56
          Top = 192
          Width = 75
          Height = 25
          Caption = 'Button1'
          TabOrder = 4
        end
        object Button8: TButton
          Left = 144
          Top = 192
          Width = 75
          Height = 25
          Caption = 'Button1'
          TabOrder = 5
        end
        object ComboBox1: TComboBox
          Left = 48
          Top = 120
          Width = 145
          Height = 21
          ItemHeight = 13
          TabOrder = 6
          Text = 'ComboBox1'
        end
        object DBGrid1: TDBGrid
          Left = 288
          Top = 48
          Width = 320
          Height = 120
          TabOrder = 7
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
        end
      end
    end
  end
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=OraOLEDB.Oracle.1;Password=test999;Persist Security Inf' +
      'o=True;User ID=test999;Data Source=orcl;Extended Properties=""'
    Mode = cmReadWrite
    Provider = 'OraOLEDB.Oracle.1'
    Left = 500
    Top = 208
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from hsi_menu')
    Left = 344
    Top = 304
  end
  object ADOTable1: TADOTable
    Connection = ADOConnection1
    TableName = 'HSI_MENU'
    Left = 416
    Top = 216
  end
end
