program GraphBuilder;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Converter in 'Converter.pas',
  Checker in 'Checker.pas',
  Stack in 'Stack.pas',
  Calculator in 'Calculator.pas',
  ExtremaChecker in 'ExtremaChecker.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
