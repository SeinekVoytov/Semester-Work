object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 469
  ClientWidth = 745
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Input: TEdit
    Left = 8
    Top = 8
    Width = 209
    Height = 21
    TabOrder = 0
    Text = 'Input'
    OnChange = InputChange
  end
  object ShowGraph: TButton
    Left = 64
    Top = 48
    Width = 75
    Height = 25
    Caption = 'ShowGraph'
    TabOrder = 1
  end
end
