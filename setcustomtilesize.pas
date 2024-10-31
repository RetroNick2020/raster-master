unit setcustomtilesize;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx;

type

  { TSetCustomTileSizeForm }

  TSetCustomTileSizeForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    SpinEditTileWidth: TSpinEditEx;
    SpinEditTileHeight: TSpinEditEx;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  SetCustomTileSizeForm: TSetCustomTileSizeForm;

implementation

{$R *.lfm}

{ TSetCustomTileSizeForm }

procedure TSetCustomTileSizeForm.Button1Click(Sender: TObject);
begin
   modalresult:= mrOk;
end;

end.

