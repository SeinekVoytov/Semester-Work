object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 577
  ClientWidth = 874
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
  object GraphPanel: TPanel
    Left = 274
    Top = 0
    Width = 600
    Height = 577
    Align = alClient
    TabOrder = 0
    object GraphPaintBox: TPaintBox
      Left = 1
      Top = 1
      Width = 598
      Height = 575
      Align = alClient
      OnPaint = GraphPaintBoxPaint
      ExplicitLeft = -135
      ExplicitTop = 113
    end
  end
  object EditPanel: TPanel
    Left = 0
    Top = 0
    Width = 274
    Height = 577
    Align = alLeft
    TabOrder = 1
    object RangeLabel: TLabel
      Left = 16
      Top = 77
      Width = 110
      Height = 13
      Caption = #1043#1088#1072#1085#1080#1094#1099' '#1087#1086#1089#1090#1088#1086#1077#1085#1080#1103':'
    end
    object FromLabel: TLabel
      Left = 20
      Top = 99
      Width = 14
      Height = 13
      Caption = #1054#1090
    end
    object ToLabel: TLabel
      Left = 87
      Top = 99
      Width = 13
      Height = 13
      Caption = #1076#1086
    end
    object InputEdit: TEdit
      Left = 16
      Top = 36
      Width = 209
      Height = 23
      TabOrder = 0
      OnChange = InputEditChange
    end
    object ShowGraphButton: TButton
      Left = 56
      Top = 137
      Width = 121
      Height = 25
      Caption = #1055#1086#1089#1090#1088#1086#1080#1090#1100' '#1075#1088#1072#1092#1080#1082
      TabOrder = 1
      OnClick = ShowGraphButtonClick
    end
    object RangeFromEdit: TEdit
      Left = 40
      Top = 96
      Width = 41
      Height = 21
      TabOrder = 2
      Text = '-10'
      OnChange = RangeFromEditChange
    end
    object RangeToEdit: TEdit
      Left = 113
      Top = 96
      Width = 45
      Height = 21
      TabOrder = 3
      Text = '10'
      OnChange = RangeToEditChange
    end
    object MathInputButton: TButton
      Left = 200
      Top = 34
      Width = 25
      Height = 25
      Hint = #1052#1072#1090#1077#1084#1072#1090#1080#1095#1077#1089#1082#1080#1081' '#1074#1074#1086#1076
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
  end
end
