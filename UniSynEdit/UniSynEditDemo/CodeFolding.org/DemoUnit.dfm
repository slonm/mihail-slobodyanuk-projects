object Form1: TForm1
  Left = 311
  Top = 190
  Width = 855
  Height = 666
  Caption = 'Demo Code Folding'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu2
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 168
    Top = 16
    Width = 23
    Height = 22
  end
  object SynEdit1: TSynEdit
    Left = 249
    Top = 41
    Width = 590
    Height = 567
    Align = alClient
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
    Gutter.RightOffset = 21
    Gutter.ShowLineNumbers = True
    Gutter.Gradient = True
    Gutter.GradientEndColor = clMoneyGreen
    Highlighter = SynPasSyn1
    Lines.UnicodeStrings = 'SynEdit1'
  end
  object cxRTTIInspector1: TcxRTTIInspector
    Left = 0
    Top = 41
    Width = 249
    Height = 567
    Align = alLeft
    OptionsView.RowHeaderWidth = 123
    TabOrder = 1
    OnPropertyChanged = cxRTTIInspector1PropertyChanged
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 839
    Height = 41
    Align = alTop
    TabOrder = 2
    object ComboBox1: TComboBox
      Left = 16
      Top = 8
      Width = 233
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object SynPasSyn1: TSynPasSyn
    Left = 240
    Top = 200
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [fdEffects, fdFixedPitchOnly]
    Left = 72
    Top = 132
  end
  object MainMenu2: TMainMenu
    Left = 376
    Top = 200
    object File2: TMenuItem
      Caption = '&File'
      object Open2: TMenuItem
        Caption = '&Open...'
        OnClick = Open2Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
      end
    end
    object Collapsed1: TMenuItem
      Caption = 'Collapse'
      object CollapsAll1: TMenuItem
        Caption = 'CollapseAll'
        OnClick = CollapsAll1Click
      end
      object N21: TMenuItem
        Caption = 'CollapseCurrent'
        OnClick = N21Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.pas|*.pas'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 160
    Top = 168
  end
  object SynCSSyn1: TSynCSSyn
    Left = 272
    Top = 200
  end
  object SynCppSyn1: TSynCppSyn
    Left = 304
    Top = 200
  end
  object SynCssSyn1: TSynCssSyn
    Left = 336
    Top = 200
  end
  object SynHTMLSyn1: TSynHTMLSyn
    Left = 432
    Top = 200
  end
  object SynIniSyn1: TSynIniSyn
    Left = 464
    Top = 200
  end
  object SynJavaSyn1: TSynJavaSyn
    Left = 496
    Top = 200
  end
  object SynJScriptSyn1: TSynJScriptSyn
    Left = 528
    Top = 200
  end
  object SynVBScriptSyn1: TSynVBScriptSyn
    Left = 560
    Top = 200
  end
  object SynPerlSyn1: TSynPerlSyn
    Left = 592
    Top = 200
  end
  object SynPHPSyn1: TSynPHPSyn
    Left = 624
    Top = 200
  end
  object SynVBSyn1: TSynVBSyn
    Left = 656
    Top = 200
  end
end
