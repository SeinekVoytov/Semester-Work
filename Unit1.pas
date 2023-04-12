unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Math, Checker, Stack;

type
  TForm1 = class(TForm)
    ShowGraph: TButton;
    Input: TEdit;
    Graph: TPaintBox;
    procedure InputChange(Sender: TObject);
    procedure ShowGraphClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

  Function Calculate(const Expr: String; X: Extended): Extended;

  Function FindOperandReversed(Const Expr: String; var Index: Integer): Extended;
  Var
    I: Integer;
  Begin
    I := Index;
    while (I > 0) and (Expr[I] >= '0') and (Expr[I] <= '9') or (Expr[I] = '.') do
      Begin
        Dec(I);
      End;
    Result := StrToFloat(Copy(Expr, I + 1, Index - I));
    Index := I + 1;
  End;

  Function IsFunction(Item: Char): Boolean;
    Begin
      Result := CharInSet(Item, ['!', '@', '#', '$', '%', '&', '_', '{', '}']);
    End;

  Function IsOperand(Item: Char): Boolean;
    Begin
      Result := ((Item >= '0') and (Item <= '9')) or (Item = 'x');
    End;

  Var
    OperandStack: TStack<Extended>;
    Index: Integer;
    CurrSymbol: Char;
    Operand1, Operand2, Temp: Extended;
  Begin
    OperandStack := TStack<Extended>.Create(Length(Expr));
    Index := Length(Expr);
    while (Index > 0) do
      Begin
          CurrSymbol := Expr[Index];
          if (CurrSymbol <> ' ') then
          Begin
            if (IsOperand(Expr[Index])) or (Expr[Index] = '~') then
              Begin
                if (CurrSymbol = 'x') then
                  Begin
                    Operand1 := X;
                  End
                else if (CurrSymbol = '~') then
                  Begin
                    Operand1 := Pi;
                  End
                else
                  Begin
                    Operand1 := FindOperandReversed(Expr, Index);
                  End;
                OperandStack.Push(Operand1);
              End
            else if (IsFunction(CurrSymbol)) then
              Begin
                  Operand1 := OperandStack.Pop();
                  case CurrSymbol of
                    '!':
                      OperandStack.Push(System.Math.RoundTo(System.Sin(Operand1), -3));
                    '@':
                      OperandStack.Push(System.Math.RoundTo(System.Cos(Operand1), -3));
                    '#':
                      OperandStack.Push(System.Math.RoundTo(System.Sin(Operand1) / System.Cos(Operand1), -3));
                    '$':
                      OperandStack.Push(System.Math.RoundTo(System.Cos(Operand1) / System.Sin(Operand1), -3));
                    '%':
                      OperandStack.Push(System.Math.RoundTo(System.Ln(Operand1), -3));
                    '&':
                      OperandStack.Push(System.Math.RoundTo(System.Math.ArcSin(Operand1), -3));
                    '_':
                      OperandStack.Push(System.Math.RoundTo(System.Math.ArcCos(Operand1), -3));
                    '{':
                      OperandStack.Push(System.Math.RoundTo(System.ArcTan(Operand1), -3));
                    '}':
                      OperandStack.Push(System.Math.RoundTo(Pi/2 - System.ArcTan(Operand1), -3));
                  End;
              End
            else
              Begin
                  Operand1 := OperandStack.Pop();
                  Operand2 := OperandStack.Pop();
                  case CurrSymbol of
                    '+':
                      OperandStack.Push(Operand1 + Operand2);
                    '-':
                      OperandStack.Push(Operand1 - Operand2);
                    '*':
                      OperandStack.Push(Operand1 * Operand2);
                    '/':
                      OperandStack.Push(Operand1 / Operand2);
                    '^':
                      OperandStack.Push(Math.Power(Operand1, Operand2));
                  End;
              End;
          End;
        Dec(Index);
      End;

     Result := OperandStack.Peek();
  End;


Procedure DeleteSpaces(var Expr: String);
  Begin
    Expr := StringReplace(Expr, ' ', '', [rfReplaceAll]);
  End;

procedure TForm1.InputChange(Sender: TObject);
Var
    Text: String;
begin
  Text := Lowercase(Input.Text);
  if (not TChecker.IsMathExprValid(Text)) then
    Begin
      ShowGraph.Enabled := False;
    End
  else
    Begin
      ShowGraph.Enabled := True;
    End;


end;

procedure TForm1.ShowGraphClick(Sender: TObject);
begin
  Graph.Width := 2000;
  Graph.Height := 2000;
  Graph.Canvas.MoveTo(Trunc(Graph.Width / 2), 0);
  Graph.Canvas.LineTo(Trunc(Graph.Width / 2), Graph.Height);
end;

end.
