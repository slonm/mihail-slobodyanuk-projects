program DemoProject;

uses
  Forms,
  DemoUnit in 'DemoUnit.pas' {Form1};
//  SynEditScrollStructureUnit in 'SynEditScrollStructureUnit.pas';
//  SynEditMarks in '..\UniSynEdit\Source\SynEditMarks.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
