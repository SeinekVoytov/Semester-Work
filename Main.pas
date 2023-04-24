﻿unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Math, Checker, Calculator, Converter;

Type
  TDotArray = array [1..10000] of Real;
type
  TMainForm = class(TForm)
    GraphPanel: TPanel;
    EditPanel: TPanel;
    InputEdit: TEdit;
    ShowGraphButton: TButton;
    GraphPaintBox: TPaintBox;
    RangeFromEdit: TEdit;
    RangeToEdit: TEdit;
    RangeLabel: TLabel;
    FromLabel: TLabel;
    ToLabel: TLabel;
    MathInputButton: TButton;
    MathInputPanel: TPanel;
    SinButton: TButton;
    CosButton: TButton;
    TgButton: TButton;
    CtgButton: TButton;
    ASinButton: TButton;
    ACosButton: TButton;
    ATgButton: TButton;
    ACtgButton: TButton;
    SqrtButton: TButton;
    RangeAndBuildPanel: TPanel;
    LogButton: TButton;
    LnButton: TButton;
    AbsButton: TButton;
    ColorBox: TColorBox;
    PenWidthComboBox: TComboBox;
    ClearGraphButton: TButton;
    ClearAllButton: TButton;
    ClearInputButton: TButton;
    procedure InputEditChange(Sender: TObject);
    procedure GraphPaintBoxPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RangeFromEditChange(Sender: TObject);
    procedure RangeToEditChange(Sender: TObject);
    procedure ShowGraphButtonClick(Sender: TObject);
    procedure MathInputButtonClick(Sender: TObject);
    procedure ClearInputButtonClick(Sender: TObject);
    procedure SinButtonClick(Sender: TObject);
    procedure CosButtonClick(Sender: TObject);
    procedure TgButtonClick(Sender: TObject);
    procedure CtgButtonClick(Sender: TObject);
    procedure ASinButtonClick(Sender: TObject);
    procedure ACosButtonClick(Sender: TObject);
    procedure ATgButtonClick(Sender: TObject);
    procedure ACtgButtonClick(Sender: TObject);
    procedure SqrtButtonClick(Sender: TObject);
    procedure LogButtonClick(Sender: TObject);
    procedure LnButtonClick(Sender: TObject);
    procedure AbsButtonClick(Sender: TObject);
    {procedure InputEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);}
    procedure ClearGraphButtonClick(Sender: TObject);
    procedure ClearAllButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

  private
    CurrXAxisPos, CurrYAxisPos: Integer;
    DotArrays: array [1..3] of TDotArray;
    XFrom, XTo, YFrom, YTo: Integer;
    PolNotExprs: array [1..3] of String;
    GraphNumber: Byte;
    YOffset, XOffset: Integer;
    Scale: Integer;
    Range, Step: Real;
    ColorsArray: array [1..3] of TColor;
    WidthArray: array [1..3] of Byte;
    MathInput: Boolean;
    LBorder, RBorder: Integer;
  public
    GraphPicture: TBitmap;
  end;

const
  ITERATION_COUNT = 10000;
  ColorNames: array[0..6] of String = ('Черный', 'Красный', 'Зеленый', 'Синий', 'Желтый', 'Оранжевый', 'Розовый');
  ColorValues: array[0..6] of string = ('$000000', '$0000FF', '$00FF00', '$FF0000', '$00FFFF', '$00A5FF', '$FF00FF');
var
  MainForm: TMainForm;
  ZoomFactor: Byte;

implementation

{$R *.dfm}

Procedure PaintYAxis(const X: Integer);
var
  Width: Integer;
  Color: TColor;
  Y, I: Integer;
begin
  Width := MainForm.GraphPicture.Canvas.Pen.Width;
  with MainForm.GraphPicture.Canvas do
    begin
      Pen.Width := 3;
      Pen.Color := clBlack;
      MoveTo(X, 0);
      LineTo(X, MainForm.GraphPaintBox.Height);
      Mainform.GraphPaintBox.Canvas.Draw(0, 0, Mainform.GraphPicture);                      // axis painting
      Y := MainForm.Scale;
      for I := MainForm.YTo - 1 downto MainForm.YFrom + 1  do      // sticks painting
        Begin
          if (I <> 0) then
            Begin
              MoveTo(MainForm.CurrYAxisPos - 4, Y);
              LineTo(MainForm.CurrYAxisPos + 4, Y);
              TextOut(MainForm.CurrYAxisPos + 4, Y, IntToStr(I));
            End;
          Y := Y + MainForm.Scale;
        End;
      MoveTo(MainForm.CurrYAxisPos - 10, 10);
      LineTo(MainForm.CurrYAxisPos, 0);
      LineTo(MainForm.CurrYAxisPos + 10, 10);
      Pen.Color := Color;
      Pen.Width := Width;
    end;
end;

Procedure PaintXAxis(const Y: Integer);
var
  Width: Integer;
  Color: TColor;
  X, I: Integer;
begin
  Width := MainForm.GraphPicture.Canvas.Pen.Width;
  Color := MainForm.GraphPicture.Canvas.Pen.Color;
  with MainForm.GraphPicture.Canvas do
    begin
      Pen.Width := 3;
      Pen.Color := clBlack;
      MoveTo(0, Y);
      LineTo(MainForm.GraphPaintBox.Width, Y);     // axis painting
      X := MainForm.Scale;
      for I := MainForm.XFrom + 1 to MainForm.XTo - 1 do      // sticks painting
        Begin
          MoveTo(X, MainForm.CurrXAxisPos - 3);
          LineTo(X, MainForm.CurrXAxisPos + 3);
          TextOut(X, MainForm.CurrXAxisPos + 3, IntToStr(I));
          X := X + MainForm.Scale;
        End;
      MoveTo(MainForm.GraphPaintBox.Width - 10, MainForm.CurrXAxisPos - 10);
      LineTo(MainForm.GraphPaintBox.Width, MainForm.CurrXAxisPos);
      LineTo(MainForm.GraphPaintBox.Width - 10, MainForm.CurrXAxisPos + 10);
      Pen.Color := Color;
      Pen.Width := Width;
    end;
end;

Procedure PaintGraph(Const DotArray: TDotArray; Const XOffset, YOffset: Integer; Const IsZoom: Boolean);
var
  LowX, HighX: Integer;
  WasNan: Boolean;
  CurrX: Real;
begin
   WasNan := True;
   CurrX := 0;
//   LowX := 500 * Abs(10 - Abs(MainForm.XFrom));
//   HighX := 500 * Abs(10 - Abs(MainForm.XTo));
   lowx := 0;
   highx := 0;
   //MainForm.Step := MainForm.GraphPaintBox.Width / (ITERATION_COUNT - LowX - HighX);
   for LowX := LowX + 1 to ITERATION_COUNT - HighX do
    Begin
      if (FloatToStr(DotArray[LowX]) = 'NAN') then
        WasNaN := True
      else if (WasNan) then
        begin
          MainForm.GraphPicture.Canvas.MoveTo(Trunc(CurrX) + XOffset, Trunc(MainForm.Scale * DotArray[LowX]) + YOffset);
          WasNan := False;
        End
      else
        MainForm.GraphPicture.Canvas.LineTo(Trunc(CurrX) + XOffset, Trunc(MainForm.Scale * DotArray[LowX] + YOffset));

      CurrX := CurrX + MainForm.Step;
    End;
   MainForm.GraphPaintBox.Canvas.Draw(0, 0, MainForm.GraphPicture);
end;

Procedure ShiftArrayLeft(var Arr: TDotArray);
const
  SHIFTING_SIZE = 500;
var
  I: Integer;
begin
  for I := SHIFTING_SIZE + 1 to High(Arr) do
    Arr[I - SHIFTING_SIZE] := Arr[I];
end;

Procedure ShiftArrayRight(var Arr: TDotArray);
const
  SHIFTING_SIZE = 500;
var
  I: Integer;
begin
  for I := High(Arr) - SHIFTING_SIZE downto Low(Arr) do
    Arr[I + SHIFTING_SIZE] := Arr[I];
end;

Procedure SetSelectedWidth();
var
  SelectedWidth: String;
begin
  SelectedWidth := MainForm.PenWidthComboBox.Items[MainForm.PenWidthComboBox.ItemIndex];
    with MainForm.GraphPicture.Canvas.Pen do
    Begin
      if (SelectedWidth = 'mid') then
          Width := 3
      else if (SelectedWidth = 'low') then
        Width := 1
      else
        Width := 5;
      MainForm.WidthArray[MainForm.GraphNumber] := Width;;
    End;
end;

Procedure SetEditEnabled(const Value: Boolean);
begin
  with MainForm do
    Begin
      RangeToEdit.Enabled := Value;
      RangeFromEdit.Enabled := Value;
    End;
end;

Procedure SetButtonEnabled(const Value: Boolean);
begin
  with MainForm do
    Begin
      ClearAllButton.Enabled := Value;
      ClearGraphButton.Enabled := Value;
    End;
end;

Procedure ClearPaintBox();
var
  Color: TColor;
  Width: Byte;
begin
  with MainForm.GraphPicture.Canvas do
    Begin
      Color := Pen.Color;
      Width := Pen.Width;
      Pen.Color := clWhite;
      Rectangle(0,0,MainForm.GraphPaintBox.Width,MainForm.GraphPaintBox.Height);
      Pen.Width := 3;
      Pen.Color := Color;
      Pen.Width := Width;
    End;
end;

procedure TMainForm.FormCreate(Sender: TObject);
  var
    I: Integer;
  begin
    XFrom := -10;
    XTo := 10;
    YFrom := -10;
    YTo := 10;
    GraphNumber := 0;
    Step := GraphPaintBox.Width / ITERATION_COUNT;
    Range := 20 / ITERATION_COUNT;
    YOffset := GraphPaintBox.Height div 2;
    XOffset := 0;
    Scale := 60;
    CurrXAxisPos := GraphPaintBox.Height div 2;
    CurrYAxisPos := GraphPaintBox.Width div 2;
    LBorder := 0;
    RBorder := ITERATION_COUNT;
    MathInput := False;
    SetButtonEnabled(False);
    GraphPicture := TBitmap.Create;
    GraphPicture.Canvas.Pen.Width := 3;
    MathInputPanel.Visible := False;
    ShowGraphButton.Enabled := False;

    with PenWidthComboBox do
      Begin
        Items.Add('low');
        Items.Add('mid');
        Items.Add('high');
        ItemIndex := 1;
      End;

    ColorBox.Clear;
    for I := 0 to High(ColorValues) do
      ColorBox.Items.AddObject(ColorNames[i], TObject(StringToColor(ColorValues[i])));

    ColorBox.Selected := clBlack;
    GraphPicture.SetSize(GraphPaintBox.Width, GraphPaintBox.Height);
    PaintYAxis(CurrXAxisPos);
    PaintXAxis(CurrYAxisPos);
    GraphPaintBox.Canvas.Draw(0, 0, GraphPicture);
  end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I, J: Integer;
  X: Real;
  LowX, HighX: Integer;
begin
  case Key of
    VK_UP, VK_DOWN:
      Begin
        with GraphPicture.Canvas.Pen do
          begin
            KeyPreview := True;
            ClearPaintBox();
            if (Key = VK_UP) then
              begin
                Inc(YTo);
                Inc(YFrom);
                CurrXAxisPos := CurrXAxisPos + Scale;
                YOffset := YOffset + Scale;
              end
            else
              begin
                Dec(YTo);
                Dec(YFrom);
                CurrXAxisPos := CurrXAxisPos - Scale;
                YOffset := YOffset - Scale;
              end;

            PaintXAxis(CurrXAxisPos);
            PaintYAxis(CurrYAxisPos);
            for I := 1 to GraphNumber do
              Begin
                GraphPicture.Canvas.Pen.Color := ColorsArray[I];
                GraphPicture.Canvas.Pen.Width := WidthArray[I];
                PaintGraph(DotArrays[I], XOffset, YOffset, False);
              End;
          end;
        GraphPaintBox.Canvas.Draw(0, 0, GraphPicture);
      End;
    VK_RIGHT, VK_LEFT:
      begin
        with GraphPicture.Canvas.Pen do
          begin
            KeyPreview := True;
            ClearPaintBox();
            if (Key = VK_LEFT) then
              begin
                CurrYAxisPos := CurrYAxisPos + Scale;
                for J := 1 to GraphNumber do
                  Begin
                    X := XFrom;
                    if (RBorder < ITERATION_COUNT) then
                      Begin
                        Inc(RBorder, 500);
                        Inc(LBorder, 500);
                      End
                    else
                      Begin
                        ShiftArrayRight(DotArrays[J]);
                        for I := 500 downto Low(DotArrays[J]) do
                          Begin
                            DotArrays[J][I] := -TCalculate.Calculate(PolNotExprs[J], X);
                            X := X - Range;
                          End;
                      End;
                  End;
                Dec(XTo);
                Dec(XFrom);
              end
            else
              begin
                Inc(XTo);
                Inc(XFrom);
                CurrYAxisPos := CurrYAxisPos - Scale;
                for J := 1 to GraphNumber do
                  Begin
                    X := XTo - 1;
                    LowX := 500 * Abs(MainForm.XFrom div 10);
                    HighX := 500 * Abs(MainForm.XTo div 10);
                    if (LBorder > 0) then
                      Begin
                        Dec(LBorder, 500);
                        Dec(RBorder, 500);
                      End
                    else
                      Begin
                        ShiftArrayLeft(DotArrays[J]);
                        for I := ITERATION_COUNT - HighX + 1 to ITERATION_COUNT - HighX + 500 do
                          Begin
                            DotArrays[J][I] := -TCalculate.Calculate(PolNotExprs[J], X);
                            X := X + Range;
                          End;
                      End;
                  End;
              end;
            PaintXAxis(CurrXAxisPos);
            PaintYAxis(CurrYAxisPos);
            for I := 1 to GraphNumber do
              Begin
                GraphPicture.Canvas.Pen.Color := ColorsArray[I];
                GraphPicture.Canvas.Pen.Width := WidthArray[I];
                PaintGraph(DotArrays[I], XOffset, YOffset, False);
              End;
          end;
        GraphPaintBox.Canvas.Draw(0, 0, GraphPicture);
      end;
    VK_RETURN:
      Begin
        KeyPreview := True;
        if (ShowGraphButton.Enabled) then
          ShowGraphButtonClick(Sender);
      End;
  end;
end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  I: Integer;
begin
  MousePos := GraphPaintBox.ScreenToClient(MousePos);
//  PaintBoxRect := GraphPaintBox.ClientRect;  проверка, стоит ли курсор над paintbox
  if (ssCtrl in Shift) then
    Begin
      if (WheelDelta > 50) and (ZoomFactor < 9) then
        Begin
          Inc(ZoomFactor);
          ClearPaintBox();
          Handled := True;
          if (MousePos.X > 600) and (MousePos.Y > 600) then
            Begin
              Inc(XFrom);
              Dec(YTo);
            End
          else if (MousePos.X > 600) and (MousePos.Y <= 600) then
            Begin
              Inc(XFrom);
              Inc(YFrom);
            End
          else if (MousePos.X <= 600) and (MousePos.Y > 600) then
            Begin
              Dec(XTo);
              Dec(YTo);
            End
          else
            Begin
              Dec(XTo);
              Inc(YFrom);
            End;
        End
      else if (WheelDelta < -50) and (ZoomFactor > 0) then
        Begin
          Dec(ZoomFactor);
          ClearPaintBox();
          Handled := True;
          if (MousePos.X > 600) and (MousePos.Y > 600) then
            Begin
              Dec(XFrom);
              Inc(YTo);
            End
          else if (MousePos.X > 600) and (MousePos.Y <= 600) then
            Begin
              Dec(XFrom);
              Dec(YFrom);
            End
          else if (MousePos.X <= 600) and (MousePos.Y > 600) then
            Begin
              Inc(XTo);
              Inc(YTo);
            End
          else
            Begin
              Inc(XTo);
              Dec(YFrom);
            End;
        End;
      Scale := Trunc(GraphPaintBox.Width / (XTo - XFrom));
      CurrXAxisPos := Abs(YTo) * Scale;
      CurrYAxisPos := Abs(XFrom) * Scale;
      PaintXAxis(CurrXAxisPos);
      PaintYAxis(CurrYAxisPos);
      YOffset := CurrXAxisPos;
      for I := 1 to GraphNumber do
        Begin
          GraphPicture.Canvas.Pen.Color := ColorsArray[I];
          GraphPicture.Canvas.Pen.Width := WidthArray[I];
          PaintGraph(DotArrays[I], XOffset, YOffset, True);
        End;
      //Dec(XOffset, Scale);
      GraphPaintBox.Canvas.Draw(0, 0, GraphPicture);
    End;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  GraphPicture.SetSize(GraphPaintBox.Width, GraphPaintBox.Height);
  GraphPaintBox.Invalidate;
end;

procedure TMainForm.GraphPaintBoxPaint(Sender: TObject);
begin
  GraphPaintBox.Canvas.Draw(0, 0, GraphPicture);
end;

procedure TMainForm.InputEditChange(Sender: TObject);
Var
    Text: String;
begin
  Text := Lowercase(InputEdit.Text);
  if (not TChecker.IsMathExprValid(Text)) then
    ShowGraphButton.Enabled := False
  else
    ShowGraphButton.Enabled := True;
end;

//procedure TMainForm.InputEditKeyDown(Sender: TObject; var Key: Word;
//  Shift: TShiftState);
//begin
//  if (Key = VK_RETURN) and (ShowGraphButton.Enabled) then
//    Begin
//      ShowGraphButtonClick(Sender);
//      Key := 0;
//  End;
//end;

procedure TMainForm.ClearInputButtonClick(Sender: TObject);
begin
  InputEdit.Text := '';
  InputEdit.SetFocus;
end;

procedure TMainForm.MathInputButtonClick(Sender: TObject);
begin
  if (not MathInput) then
    Begin
      MathInputPanel.Visible := True;
      MathInput := True;
      MathInputPanel.Top := RangeAndBuildPanel.Top;
      RangeAndBuildPanel.Top := MathInputPanel.Top + MathInputPanel.Height;
    End
  else
    Begin
      MathInputPanel.Visible := False;
      MathInput := False;
      RangeAndBuildPanel.Top := MathInputPanel.Top;
      MathInputPanel.Top := RangeAndBuildPanel.Top + RangeAndBuildPanel.Height;
    End
end;

procedure TMainForm.RangeFromEditChange(Sender: TObject);
begin
  if (not TChecker.CheckInput(RangeFromEdit.Text) or (XTo <= XFrom)) then
    Begin
      // покраснение рамки edit и блокировка кнопки
    End
  else
    XFrom := StrToInt(RangeFromEdit.Text);
end;

procedure TMainForm.RangeToEditChange(Sender: TObject);
begin
  if (not TChecker.CheckInput(RangeToEdit.Text) or (XTo <= XFrom)) then
    Begin
      // покраснение рамки edit и блокировка кнопки
    End
  else
    XTo := StrToInt(RangeToEdit.Text);
end;

procedure TMainForm.ShowGraphButtonClick(Sender: TObject);
  Var
    CurrX: Real;
    I: Integer;
    CurrExpr: String;
begin
  Inc(GraphNumber);
  SetEditEnabled(False);
  SetButtonEnabled(True);
  CurrExpr := TConverter.ConvertToPolishNotation(InputEdit.Text);
  PolNotExprs[GraphNumber] := CurrExpr;
  CurrX := XFrom;

  for I := 1 to ITERATION_COUNT do
    Begin
      DotArrays[GraphNumber][I] := -TCalculate.Calculate(PolNotExprs[GraphNumber], CurrX);
      CurrX := CurrX + Range;
    End;

  GraphPicture.Canvas.Pen.Color := ColorBox.Selected;
  ColorsArray[GraphNumber] := ColorBox.Selected;

  SetSelectedWidth();

  PaintGraph(DotArrays[GraphNumber], XOffset, YOffset, False);

  if (GraphNumber = 3) then
  Begin
    MathInputPanel.Enabled := False;
    InputEdit.Enabled := False;
    ColorBox.Enabled := False;
    PenWidthComboBox.Enabled := False;
    ShowGraphButton.Enabled := False;
  End;
end;

procedure TMainForm.ClearAllButtonClick(Sender: TObject);
begin
  GraphNumber := 0;
  ClearPaintBox();

  CurrXAxisPos := GraphPaintBox.Height div 2;
  CurrYAxisPos := GraphPaintBox.Width div 2;
  PaintYAxis(CurrXAxisPos);
  PaintXAxis(CurrYAxisPos);

  GraphPaintBox.Canvas.Draw(0,0,GraphPicture);
  XFrom := -10;
  XTo := 10;
  RangeFromEdit.Text := IntToStr(XFrom);
  RangeToEdit.Text := IntToStr(XTo);
  SetEditEnabled(True);
  SetButtonEnabled(False);
  InputEdit.Enabled := True;
  InputEdit.Clear;
  ColorBox.Enabled := True;
  PenWidthComboBox.Enabled := True;
  MathInputPanel.Enabled := True;
  PenWidthComboBox.ItemIndex := 1;
  ShowGraphButton.Enabled := True;
end;

procedure TMainForm.ClearGraphButtonClick(Sender: TObject);
var
  I: Integer;
begin
  Dec(GraphNumber);
  if (GraphNumber = 0) then
    ClearGraphButton.Enabled := False;

  ClearPaintBox();
  PaintYAxis(CurrYAxisPos);
  PaintXAxis(CurrXAxisPos);

  for I := 1 to GraphNumber do
    Begin
      GraphPicture.Canvas.Pen.Color := ColorsArray[I];
      GraphPicture.Canvas.Pen.Width := WidthArray[I];
      PaintGraph(DotArrays[I], XOffset, YOffset, False);
    End;

  GraphPaintBox.Canvas.Draw(0,0,GraphPicture);
  InputEdit.Enabled := True;
  ColorBox.Enabled := True;
  PenWidthComboBox.Enabled := True;
  MathInputPanel.Enabled := True;
  ShowGraphButton.Enabled := True;
end;

procedure TMainForm.SinButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('sin()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 4;
end;

procedure TMainForm.CosButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('cos()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 4;
end;

procedure TMainForm.TgButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('tg()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 3;
end;

procedure TMainForm.CtgButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('ctg()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 4;
end;

procedure TMainForm.ASinButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('arcsin()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 7;
end;

procedure TMainForm.ACosButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('arccos()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 7;
end;

procedure TMainForm.ATgButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('arctg()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 6;
end;

procedure TMainForm.ACtgButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('arcctg()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 7;
end;

procedure TMainForm.SqrtButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('sqrt()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 5;
end;

procedure TMainForm.LogButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('log10()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 6;
end;

procedure TMainForm.LnButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('ln()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 3;
end;

procedure TMainForm.AbsButtonClick(Sender: TObject);
var
  CurrInput: String;
  CurrCursorPos: Integer;
begin
  CurrInput := InputEdit.Text;
  CurrCursorPos := InputEdit.SelStart;
  Insert('abs()', CurrInput, CurrCursorPos + 1);
  InputEdit.Text := CurrInput;
  InputEdit.SetFocus;
  InputEdit.SelStart := CurrCursorPos + 4;
end;
end.
