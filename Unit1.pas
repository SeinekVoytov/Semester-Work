﻿unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Math, Checker, Calculate, Converter;

type
  TForm1 = class(TForm)
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
    procedure InputEditChange(Sender: TObject);
    procedure GraphPaintBoxPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RangeFromEditChange(Sender: TObject);
    procedure RangeToEditChange(Sender: TObject);
    procedure ShowGraphButtonClick(Sender: TObject);

  private
    { Private declarations }
  public
    GraphPicture: TBitmap;
    DotArray: array of Extended;
    RangeFrom, RangeTo: Integer;
    PolNotExpr: String;
  end;

const
  IterationCount = 1000;
var
  Form1: TForm1;

implementation

{$R *.dfm}

Function CheckInput(Const s: String): Boolean;
  Begin
    try
      StrToInt(s);
      Result := True;
    except
      Result := False;
    end;
  End;

procedure TForm1.FormCreate(Sender: TObject);
  begin
    GraphPicture := TBitmap.Create;
    GraphPicture.SetSize(GraphPaintBox.Width, GraphPaintBox.Height);
    GraphPicture.Canvas.MoveTo(GraphPaintBox.Width div 2, 0);
    GraphPicture.Canvas.LineTo(GraphPaintBox.Width div 2, GraphPaintBox.Height);
    GraphPicture.Canvas.MoveTo(0, GraphPaintBox.Height div 2);
    GraphPicture.Canvas.LineTo(GraphPaintBox.Width, GraphPaintBox.Height div 2);
  end;

procedure TForm1.GraphPaintBoxPaint(Sender: TObject);
  begin

    //GraphPaintBox.Invalidate;
    GraphPaintBox.Canvas.Draw(0, 0, GraphPicture);
  end;

procedure TForm1.InputEditChange(Sender: TObject);
Var
    Text: String;
begin
  Text := Lowercase(InputEdit.Text);
  if (not TChecker.IsMathExprValid(Text)) then
    ShowGraphButton.Enabled := False
  else
    ShowGraphButton.Enabled := True;
end;


procedure TForm1.RangeFromEditChange(Sender: TObject);
begin
  if (not CheckInput(RangeFromEdit.Text)) then
    Begin
      // покраснение рамки edit и блокировка кнопки
    End
  else
    RangeFrom := StrToInt(RangeFromEdit.Text);
end;

procedure TForm1.RangeToEditChange(Sender: TObject);
begin
  if (not CheckInput(RangeToEdit.Text)) then
    Begin
      // покраснение рамки edit и блокировка кнопки
    End
  else
    RangeTo :=  StrToInt(RangeToEdit.Text);
end;

procedure TForm1.ShowGraphButtonClick(Sender: TObject);
  Var
    CurrX, CurrY, Step, XOffset, YOffset: Real;
    DotNumber, I: Integer;
begin

  PolNotExpr := TConverter.ConvertToPolishNotation(InputEdit.Text);
  Step := (RangeTo - RangeFrom) / IterationCount;
//  CurrY := -TCalculate.Calculate(PolNotExpr, RangeFrom);
//  GraphPicture.Canvas.MoveTo(0, Trunc((CurrY + 10) * 100));
//  CurrX := RangeFrom + Step;
  //DotNumber := (RangeTo - RangeFrom) /
  DotNumber := 1000;
  SetLength(DotArray, DotNumber);
  CurrX := RangeFrom;

  for I := 0 to DotNumber - 1 do
    Begin
      DotArray[I] := -TCalculate.Calculate(PolNotExpr, CurrX);
      CurrX := CurrX + Step;
    End;

  CurrX := 0;
  CurrY := Trunc(DotArray[0] * 100);
  XOffset := GraphPaintBox.Width / DotNumber;
  YOffset := GraphPaintBox.Height / 2;
  GraphPicture.Canvas.MoveTo(Trunc(CurrX), Trunc(DotArray[0] * 100 + YOffset));
  for I := 1 to DotNumber - 1 do
    Begin
      CurrX := CurrX + XOffset;
      GraphPicture.Canvas.LineTo(Trunc(CurrX), Trunc(DotArray[I] * 100 + YOffset));
    End;



  GraphPaintBox.Invalidate;
end;

end.
