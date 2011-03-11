object Form1: TForm1
  Left = 61
  Top = 0
  Width = 929
  Height = 605
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 486
    Width = 921
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ResizeStyle = rsLine
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 345
    Width = 921
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ResizeStyle = rsLine
  end
  object Splitter3: TSplitter
    Left = 300
    Top = 348
    Height = 138
    ResizeStyle = rsLine
  end
  object SynEdit1: TSynEdit
    Left = 0
    Top = 29
    Width = 921
    Height = 316
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 0
    Gutter.AutoSize = True
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.ShowLineNumbers = True
    Highlighter = SynPasSyn1
    Lines.UnicodeStrings = 'SynEdit1'
    OnGutterClick = SynEdit1GutterClick
  end
  object ListBox1: TListBox
    Left = 0
    Top = 348
    Width = 300
    Height = 138
    Align = alLeft
    ItemHeight = 13
    TabOrder = 1
    OnClick = ListBox1Click
  end
  object SynEdit2: TSynEdit
    Left = 303
    Top = 348
    Width = 618
    Height = 138
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 2
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Highlighter = SynPasSyn1
    Lines.UnicodeStrings = 'SynEdit2'
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 921
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 3
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Caption = 'ToolButton1'
      ImageIndex = 0
      OnClick = ToolButton1Click
    end
    object ToolButton2: TToolButton
      Left = 23
      Top = 2
      Caption = 'ToolButton2'
      ImageIndex = 1
      OnClick = ToolButton2Click
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 489
    Width = 921
    Height = 89
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    TabOrder = 4
  end
  object SynPasSyn1: TSynPasSyn
    Left = 320
    Top = 64
  end
end
