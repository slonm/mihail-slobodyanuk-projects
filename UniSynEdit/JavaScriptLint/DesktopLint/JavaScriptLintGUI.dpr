program JavaScriptLintGUI;

uses
  Forms,
  Umain in 'Umain.pas' {Main},
  JavaScriptLintAPI in 'JavaScriptLintAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
