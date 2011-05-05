program jsbeautify_demo;

uses
  Forms,
  main in 'main.pas' {Form1},
  jsbeautify in 'jsbeautify.pas',
  beautify_tests in 'beautify_tests.pas',
  functions in 'functions.pas',
  htmlbeautify in 'htmlbeautify.pas',
  cssbeautify in 'cssbeautify.pas',
  cssbeautify_tests in 'cssbeautify_tests.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
