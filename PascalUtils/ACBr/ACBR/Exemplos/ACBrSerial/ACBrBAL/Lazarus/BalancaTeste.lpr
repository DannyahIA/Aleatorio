program BalancaTeste;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { add your units here }, BalancaTeste1, ACBrSerial;

{$R *.res}

begin
  Application.Title := '';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

