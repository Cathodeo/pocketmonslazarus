program pokebattle;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, mainwindow, unit1
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='MonsterBattle';
  Application.Scaled:=True;
  Application.Initialize;
  Application.Createform(TForm1, Form1);
  Application.Run;
end.

