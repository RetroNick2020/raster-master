unit idvalueprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Spin;

type

  { TIdValuePropsForm }

  //Small modal editor for the id/value pair carried by both HitBoxRec and
  //PathRec. Those two fields exist to let the game classify an area or a
  //path - a collision class, a trigger number, whatever the target wants -
  //and nothing in Raster Master interprets them.
  //
  //One dialog serves map hit boxes, sprite hit boxes and paths. The caller
  //sets the caption so the user knows which one is being edited.
  TIdValuePropsForm = class(TForm)
    LabelId: TLabel;
    LabelValue: TLabel;
    SpinEditId: TSpinEdit;
    SpinEditValue: TSpinEdit;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    LabelHint: TLabel;
  private

  public
    //Load the dialog with the current pair. whatfor is shown in the title,
    //e.g. 'Hit Box 3' or 'Path 1'.
    procedure SetProps(const whatfor : string; id, value : integer);
    //Read back what the user entered.
    procedure GetProps(var id, value : integer);
  end;

var
  IdValuePropsForm: TIdValuePropsForm;

//Returns the shared dialog, creating it on first use.
//
//The other dialogs in this project (SetCustomCellSizeForm and friends) are
//instantiated by Application.CreateForm in the .lpr, so their globals are
//live from startup. This unit was added by hand and has no such entry, so
//the global starts nil and touching it access-violates. Creating on demand
//keeps the unit self-contained - no project file edit needed - and is
//harmless if an auto-create entry is ever added, since the nil check just
//stops matching.
//
//Owned by Application, so it is freed at shutdown.
function GetIdValuePropsForm : TIdValuePropsForm;

implementation

{$R *.lfm}

function GetIdValuePropsForm : TIdValuePropsForm;
begin
  if IdValuePropsForm = nil then
    IdValuePropsForm:=TIdValuePropsForm.Create(Application);
  GetIdValuePropsForm:=IdValuePropsForm;
end;

{ TIdValuePropsForm }

procedure TIdValuePropsForm.SetProps(const whatfor : string; id, value : integer);
begin
  if whatfor = '' then
    Caption:='Properties'
  else
    Caption:=whatfor+' Properties';

  //The spin edits are ranged in the LFM to what a 16 bit RES payload can
  //hold. Clamp incoming values too - a project loaded from JSON could carry
  //something outside that range and TSpinEdit would silently snap it.
  if id < SpinEditId.MinValue then id:=SpinEditId.MinValue;
  if id > SpinEditId.MaxValue then id:=SpinEditId.MaxValue;
  if value < SpinEditValue.MinValue then value:=SpinEditValue.MinValue;
  if value > SpinEditValue.MaxValue then value:=SpinEditValue.MaxValue;

  SpinEditId.Value:=id;
  SpinEditValue.Value:=value;
end;

procedure TIdValuePropsForm.GetProps(var id, value : integer);
begin
  id:=SpinEditId.Value;
  value:=SpinEditValue.Value;
end;

end.
