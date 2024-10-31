unit setcustomspritesize;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx;

type

  { Tsetcustomspritesizeform }

  Tsetcustomspritesizeform = class(TForm)
    SpriteHeight: TLabel;
    SpriteWidth: TLabel;
    OKButton: TButton;
    SpinEditWidth: TSpinEditEx;
    SpinEditHeight: TSpinEditEx;
    procedure OKButtonClick(Sender: TObject);
  private

  public

  end;

var
  setcustomspritesizeform: Tsetcustomspritesizeform;

implementation

{$R *.lfm}

{ Tsetcustomspritesizeform }

procedure Tsetcustomspritesizeform.OKButtonClick(Sender: TObject);
begin
   modalresult:= mrOk;
end;

end.

