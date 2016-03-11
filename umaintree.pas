unit uMainTree;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, uUsb;

type

  { TUSBHostController }

  TUSBHostController = class
  private
    FName: string;
    FPath: string;
  public
    property Name : string read FName;
    property Path : string read FPath;
    constructor Create(aName,aPath : string);
  end;

  { TForm1 }

  TForm1 = class(TForm)
    ImageList1: TImageList;
    tvMain: TTreeView;
    procedure ControllerUSBArrival(Sender: TObject);
    procedure ControllerUSBRemove(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    Controller: TUSBController;
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  aBus: Integer;
  aNode: TTreeNode;
  procedure AddUsbDevices(Node : TTreeNode;Dev : TUSBHub);
  var
    i: Integer;
    bNode: TTreeNode;
  begin
    for i := 0 to Dev.Count-1 do
      begin
        bNode := tvMain.Items.AddChild(Node,'not Connected');
        bNode.ImageIndex:=4;
        bNode.SelectedIndex:=4;
        if Assigned(Dev.Devices[i]) then
          begin
            bNode.Data:=Dev.Devices[i];
            if Dev.Devices[i] is TUSBHub then
              begin
                bNode.Text := 'Hub';
                bNode.ImageIndex:=3;
                AddUSBDevices(bNode,TUSBHub(Dev.Devices[i]));
              end
            else
              begin
                if TUSBDevice(Dev.Devices[i]).Status = dsConnected then
                  begin
                    bNode.text := TUSBDevice(Dev.Devices[i]).Vendor+' '+TUSBDevice(Dev.Devices[i]).DeviceDescription+' '+TUSBDevice(Dev.Devices[i]).SerialNumber;
                    if TUSBDevice(Dev.Devices[i]).USBSerialPort <> '' then
                      bNode.text := bNode.text+' ('+TUSBDevice(Dev.Devices[i]).USBSerialPort+')';
                    bNode.ImageIndex := 1;
                  end
                else
                  begin
                    bNode.text := USBDeviceStatusStings[Integer(TUSBDevice(Dev.Devices[i]).Status)];
                    bNode.ImageIndex:=2;
                  end;
                tvMain.Selected := bNode;
                tvMain.MakeSelectionVisible;
                bNode.SelectedIndex:=bNode.ImageIndex;
              end;
          end;
      end;
  end;
begin
  Controller := TUSBController.Create(Self);
  Controller.Enumerate;
  tvMain.BeginUpdate;
  for aBus := 0 to Controller.Count-1 do
    begin
      aNode := tvMain.Items.Add(nil,'HostController');
      aNode.ImageIndex:=0;
      aNode.SelectedIndex:=aNode.ImageIndex;
      aNode.Data:=Controller.HostController[aBus];
      aNode := tvMain.Items.AddChild(aNode,'Root Hub');
      aNode.ImageIndex:=3;
      aNode.SelectedIndex:=3;
      aNode.Data:=Controller.HostController[aBus].Devices[0];
      AddUSBDevices(aNode,TUSBHub(Controller.HostController[aBus].Devices[0]));
    end;
  tvMain.EndUpdate;
  Controller.OnUSBArrival:=@ControllerUSBArrival;
  Controller.OnUSBRemove:=@ControllerUSBRemove;
end;

procedure TForm1.ControllerUSBArrival(Sender: TObject);
var
  aNode: TTreeNode;
  bNode: TTreeNode;
  i: Integer;
  cNode: TTreeNode;
begin
  aNode := tvMain.Items[0];
  while Assigned(aNode) do
    begin
      if TObject(aNode.Data) = TUSBGenericDevice(Sender).Parent then
        begin
          i := TUSBHub(TUSBGenericDevice(Sender).Parent).IndexOf(Sender);
          bNode := aNode.Items[i];
          bNode.Data := Sender;
          if Sender is TUSBDevice then
            begin
              if TUSBDevice(Sender).Status = dsConnected then
                begin
                  bNode.Text := TUSBDevice(Sender).Vendor+' '+TUSBDevice(Sender).DeviceDescription+' '+TUSBDevice(Sender).SerialNumber;
                  if TUSBDevice(Sender).USBSerialPort <> '' then
                    bNode.text := bNode.text+' ('+TUSBDevice(Sender).USBSerialPort+')';
                  bNode.ImageIndex := 1;
                end
              else
                begin
                  bNode.text := USBDeviceStatusStings[Integer(TUSBDevice(Sender).Status)];
                  bNode.ImageIndex:=2;
                end;
            end
          else if Sender is TUSBHub then
            begin
              bNode.Text := 'Hub';
              bNode.DeleteChildren;
              bNode.ImageIndex:=3;
              for i := 0 to TUSBHub(Sender).Count-1 do
                begin
                  cNode := tvMain.Items.AddChild(bNode,'not Connected');
                  cNode.ImageIndex:=4;
                  cNode.SelectedIndex:=4;
                end;
            end;
          tvMain.Selected := bNode;
          tvMain.MakeSelectionVisible;
          bNode.SelectedIndex:=bNode.ImageIndex;
          break;
        end;
      aNode := aNode.GetNext;
    end;
end;

procedure TForm1.ControllerUSBRemove(Sender: TObject);
var
  aNode: TTreeNode;
begin
  aNode := tvMain.Items[0];
  while Assigned(aNode) do
    begin
      if TObject(aNode.Data) = Sender then
        begin
          if (Sender is TUSBDevice) or ((Sender is TUSBHub) and (aNode.Level > 1)) then
            begin
              aNode.Data:=nil;
              aNode.Text:='not Connected';
              aNode.ImageIndex:=4;
              aNode.DeleteChildren;
              aNode.SelectedIndex:=aNode.ImageIndex;
              break;
            end;
        end;
      aNode := aNode.GetNext;
    end;
end;

{ TUSBHostController }

constructor TUSBHostController.Create(aName, aPath: string);
begin
  FName := aName;
  FPath := aPath;
end;

initialization
  {$I umaintree.lrs}

end.

