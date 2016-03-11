program usbview;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{.$IFDEF UseCThreads}
  cthreads,
  {.$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uMainTree, LResources
  { you can add units after this };

{$IFDEF WINDOWS}{$R usbview.rc}{$ENDIF}

begin
  {$I usbview.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

