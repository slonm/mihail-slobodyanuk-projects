// JCL_DEBUG_EXPERT_GENERATEJDBG ON
// JCL_DEBUG_EXPERT_INSERTJDBG ON
// JCL_DEBUG_EXPERT_DELETEMAPFILE ON
program DemoProject;

uses
  Forms,
  SysUtils,
  Unit2 in '..\stend\Unit2.pas' {Form2},
  DemoUnit in 'DemoUnit.pas' {Form1};

{$R *.res}
begin
  Application.Initialize;
  Application.Title := 'Demo Code Folding';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
