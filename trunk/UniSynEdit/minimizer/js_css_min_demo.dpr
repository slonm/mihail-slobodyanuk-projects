program js_css_min_demo;

uses
  Forms,
  main in 'main.pas' {Form1},
  functions in 'functions.pas',
  cssmin in 'cssmin.pas',
  cssmin_tests in 'cssmin_tests.pas',
  jsmin in 'jsmin.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
