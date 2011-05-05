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
    object Label1: TLabel
      Left = 8
      Top = 64
      Width = 76
      Height = 13
      Caption = 'Generic Options'
    end
    object Bevel1: TBevel
      Left = 8
      Top = 72
      Width = 153
      Height = 9
      Shape = bsBottomLine
    end
    object Label3: TLabel
      Left = 8
      Top = 24
      Width = 61
      Height = 13
      Caption = 'Source Type'
    end
    object ComboBox1: TComboBox
      Left = 8
      Top = 88
      Width = 153
      Height = 21
      ImeName = #1056#1091#1089#1089#1082#1072#1103
      ItemHeight = 13
      ItemIndex = 3
      TabOrder = 0
      Text = 'indent with 4 spaces'
      Items.Strings = (
        'indent with a tab character'
        'indent with 2 spaces'
        'indent with 3 spaces'
        'indent with 4 spaces'
        'indent with 8 spaces')
    end
    object SourceType: TComboBox
      Left = 8
      Top = 40
      Width = 153
      Height = 21
      ImeName = #1056#1091#1089#1089#1082#1072#1103
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = 'HTML'
      OnChange = SourceTypeChange
      Items.Strings = (
        'HTML'
        'JavaScript'
        'CSS')
    end
    object HTMLOpt: TGroupBox
      Left = 8
      Top = 224
      Width = 169
      Height = 97
      Caption = 'HTML Options'
      TabOrder = 2
      object CheckBox3: TCheckBox
        Left = 8
        Top = 24
        Width = 97
        Height = 17
        Caption = 'Beautify HTML'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object CheckBox5: TCheckBox
        Left = 8
        Top = 48
        Width = 137
        Height = 17
        Caption = 'Beautify JavaScript'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object CheckBox6: TCheckBox
        Left = 8
        Top = 72
        Width = 137
        Height = 17
        Caption = 'Beautify CSS'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
    end
    object JSOpt: TGroupBox
      Left = 8
      Top = 120
      Width = 170
      Height = 97
      Caption = 'JavaScript Options'
      TabOrder = 3
      object CheckBox1: TCheckBox
        Left = 8
        Top = 24
        Width = 121
        Height = 17
        Caption = 'Braces on own line'
        TabOrder = 0
      end
      object CheckBox2: TCheckBox
        Left = 8
        Top = 48
        Width = 129
        Height = 17
        Caption = 'Preserve empty lines?'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object CheckBox4: TCheckBox
        Left = 8
        Top = 72
        Width = 137
        Height = 17
        Caption = 'Keep array indentation?'
        TabOrder = 2
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
        Caption = 'Beautify'
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
      Highlighter = SynHTMLSyn1
      ImeName = #1056#1091#1089#1089#1082#1072#1103
    end
  end
  object SynJScriptSyn1: TSynJScriptSyn
    Left = 88
    Top = 24
  end
  object SynHTMLSyn1: TSynHTMLSyn
    Left = 168
    Top = 24
  end
  object SynCssSyn1: TSynCssSyn
    Left = 240
    Top = 24
  end
end
