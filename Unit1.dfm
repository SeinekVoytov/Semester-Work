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
    object InputEdit: TEdit
      Left = 16
      Top = 38
      Width = 209
      Height = 21
      TabOrder = 0
      Text = 'InputEdit'
      OnChange = InputEditChange
    end
    object ShowGraphButton: TButton
      Left = 48
      Top = 65
      Width = 121
      Height = 25
      Caption = 'ShowGraphButton'
      TabOrder = 1
    end
  end
end
