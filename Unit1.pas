unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Math;

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
 Type
  TStack<T> = class
    Stack: array of T;
    Size: Integer;
    Function Pop(): T;
    Function Peek(): T;
    Procedure Push(Item: T);
    Function IsEmpty(): Boolean;
    constructor Create(Const InintialCapacity: Integer);
    destructor Destroy();
  end;


var
  Form1: TForm1;

implementation

  constructor TStack<T>.Create(Const InintialCapacity: Integer);
    Begin
      SetLength(Stack, InintialCapacity);
      Size := 0;
    End;

  destructor TStack<T>.Destroy();
    Begin

      inherited;
    End;

  Function TStack<T>.Pop(): T;
    Begin
      Result := Stack[Size - 1];
      Dec(Size);
    End;

  Function TStack<T>.Peek(): T;
    Begin
      Result := Stack[Size - 1];
    End;

  Function TStack<T>.IsEmpty(): Boolean;
    Begin
      Result := (Size = 0);
    End;

  Procedure TStack<T>.Push(Item: T);
    Begin
      Stack[Size] := Item;
      Inc(Size);
    End;

{$R *.dfm}

Function IsMathExprValid(Const Expr: String): Boolean;

  Function IsCharValid(Const Symbol: Char): Boolean;
    Begin
      Result := CharInSet(Symbol, ['0'..'9', '+', '-', '*', '/', '^', '(', '.',
                                   ')', 's', 'c', 't', 'l', 'x', ' ', 'a', 'p']);
    End;

  Function IsNumber(Const Item: Char): Boolean;
    Begin
      Result := CharInSet(Item, ['0'..'9', '.']);
    End;

  Function IsSign(Const Item: Char): Boolean;
    Begin
      Result := CharInSet(Item, ['+', '-', '*', '/', '^']);
    End;

  Function CheckNumber(Var Index: Integer): Boolean;
    Var
      WasDot: Boolean;
    Begin
      Result := True;
      if (Expr[Index] = '.') or ((Expr[Index] = '0') and (Index < Length(Expr)) and (CharInSet(Expr[Index + 1], ['0'..'9']))) then
        Begin
          Result := False;
        End
      else
        Begin
          WasDot := False;
          while (Index <= Length(Expr)) and (IsNumber(Expr[Index])) do
            Begin
              if (Expr[Index] = '.') then
                Begin
                  if (WasDot) or (Index = Length(Expr)) or (not CharInSet(Expr[Index + 1], ['0'..'9'])) then
                    Begin
                      Result := False;
                    End
                  else
                    Begin
                      WasDot := True;
                    End;
                End;
              Inc(Index);
            End;
        End;
      Dec(Index);
    End;

  Function CheckParentheses(): Boolean;
    Var
      I, ParenthesisCounter: Integer;
      CurrSymbol: Char;
    Begin
      ParenthesisCounter := 0;
      I := 1;
      Result := True;
      while (I <= Length(Expr)) and (Result) do
        Begin
          CurrSymbol := Expr[I];
          if (CurrSymbol = '(') then
            Begin
              Inc(ParenthesisCounter);
            End
          else if (CurrSymbol = ')') then
            Begin
              if (ParenthesisCounter = 0) then
                Begin
                  Result := False;
                End
              else
                Begin
                  Dec(ParenthesisCounter);
                End;
            End;
          Inc(I);
        End;
      Result := Result and (ParenthesisCounter = 0);
    End;

  Var
    I, Len, TempIndex: Integer;
    CurrSymbol: Char;
    Temp: String;
  Begin
    I := 1;
    Len := Length(Expr);
    Result := CheckParentheses();
    while (I <= Len) and (Result) do
      Begin
        CurrSymbol := Expr[I];
          Begin
            if (IsCharValid(CurrSymbol)) then
              Begin
                if (IsSign(CurrSymbol)) then
                  Begin
                    Result := Result and ((I > 1) or (Length(Expr) > 1));
                    TempIndex := I;
                    Inc(I);
                    while (I < Length(Expr)) and (Expr[I] = ' ') do
                      Begin
                        Inc(I);
                      End;
                    Result := Result and (IsNumber(Expr[I]) or (Expr[I] = '(') or (Expr[I] = 'x') or (CharInSet(Expr[I], ['s', 'c', 't', 'l', 'a', 'p'])));
                    while (TempIndex > 1) and (Expr[TempIndex] = ' ') do
                      Begin
                        Dec(TempIndex);
                      End;
                    Result := Result and (IsNumber(Expr[I]) or (Expr[I] = 'x') or (Expr[I] = '(') or (CharInSet(Expr[I], ['s', 'c', 't', 'l', 'a', 'p'])));
                    Dec(I);
                  End
                else if IsNumber(CurrSymbol) then
                  Begin
                    Result := Result and CheckNumber(I);
                  End
                else if (CurrSymbol = 's') or (CurrSymbol = 'c') then
                  Begin
                    if (I < Len - 4) then
                      Begin
                        Temp := Copy(Expr, I, 4);
                        Result := ((Temp = 'sin(') or (Temp = 'cos(') or (Temp = 'ctg(')) and (Expr[I + 4] <> ')');
                        Inc(I, 3);
                      End
                    else
                      Result := False;
                  End
                else if (CurrSymbol = 't') or (CurrSymbol = 'l') then
                  Begin
                    if (I < Len - 3) then
                      Begin
                        Temp := Copy(Expr, I, 3);
                        Result := ((Temp = 'tg(') or (Temp = 'ln(')) and (Expr[I + 3] <> ')');
                        Inc(I, 2);
                      End
                    else
                      Result := False;
                  End
                else if (CurrSymbol = 'a') then
                  Begin
                    if (I < Len - 4) then
                      Begin
                        Result := (Copy(Expr, I, 3) = 'arc') and (CharInSet(Expr[I + 3], ['s', 'c', 't']));
                        Inc(I, 2);
                      End
                    else
                      Result := False;
                  End
                else if (CurrSymbol = 'p') then
                  Begin
                    if (I < Len) then
                      Begin
                        Result := (Copy(Expr, I, 2) = 'pi');
                        Inc(I, 1);
                      End
                    else
                      Result := False;
                  End;
              End
            else
              Begin
                Result := False;
              End;
          End;
        Inc(I);
      End;
  End;

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
  if (not IsMathExprValid(Text)) then
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
