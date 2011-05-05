object Form1: TForm1
  Left = 179
  Top = 125
  Width = 786
  Height = 475
  Caption = 'Javascript beautifier'
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
  object Panel1: TPanel
    Left = 593
    Top = 0
    Width = 185
    Height = 448
    Align = alRight
    ParentBackground = False
    TabOrder = 0
    object Label3: TLabel
      Left = 8
      Top = 24
      Width = 61
      Height = 13
      Caption = 'Source Type'
    end
    object SourceType: TComboBox
      Left = 8
      Top = 40
      Width = 153
      Height = 21
      ImeName = #1056#1091#1089#1089#1082#1072#1103
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'JavaScript'
      OnChange = SourceTypeChange
      Items.Strings = (
        'JavaScript'
        'CSS')
    end
    object CSSOpt: TGroupBox
      Left = 8
      Top = 152
      Width = 169
      Height = 153
      Caption = 'CSS Options'
      TabOrder = 1
      Visible = False
      object Label2: TLabel
        Left = 8
        Top = 24
        Width = 26
        Height = 13
        Caption = 'Level'
      end
      object RemLastSemi: TCheckBox
        Left = 8
        Top = 80
        Width = 137
        Height = 17
        Caption = 'Remove last semicolons'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object RemComments: TCheckBox
        Left = 8
        Top = 112
        Width = 137
        Height = 17
        Caption = 'Remove comments'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object csslevel: TComboBox
        Left = 8
        Top = 40
        Width = 153
        Height = 21
        ImeName = #1056#1091#1089#1089#1082#1072#1103
        ItemHeight = 13
        TabOrder = 2
        Text = '1 - minimal'
        OnChange = SourceTypeChange
        Items.Strings = (
          '1 - minimal'
          '2 - maximal')
      end
    end
    object JSOpt: TGroupBox
      Left = 8
      Top = 72
      Width = 170
      Height = 73
      Caption = 'JavaScript Options'
      TabOrder = 2
      object Label1: TLabel
        Left = 8
        Top = 24
        Width = 26
        Height = 13
        Caption = 'Level'
      end
      object jslevel: TComboBox
        Left = 8
        Top = 40
        Width = 153
        Height = 21
        ImeName = #1056#1091#1089#1089#1082#1072#1103
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 0
        Text = '1 - minimal'
        OnChange = SourceTypeChange
        Items.Strings = (
          '1 - minimal'
          '2 - normal'
          '3 - agressive')
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 593
    Height = 448
    Align = alClient
    ParentBackground = False
    TabOrder = 1
    object Panel3: TPanel
      Left = 1
      Top = 406
      Width = 591
      Height = 41
      Align = alBottom
      ParentBackground = False
      TabOrder = 0
      object Button1: TButton
        Left = 240
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Minimize'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
    object Editor: TSynEdit
      Left = 1
      Top = 1
      Width = 591
      Height = 405
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      TabOrder = 1
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Courier New'
      Gutter.Font.Style = []
      Gutter.RightOffset = 21
      Gutter.ShowLineNumbers = True
      Gutter.HighlightChanges = False
      Highlighter = SynJScriptSyn1
      ImeName = #1056#1091#1089#1089#1082#1072#1103
    end
  end
  object SynJScriptSyn1: TSynJScriptSyn
    Left = 88
    Top = 24
  end
  object SynCssSyn1: TSynCssSyn
    Left = 240
    Top = 24
  end
end
