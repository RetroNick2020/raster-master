unit setcustomcellsize;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx;

type

  { TSetCustomCellSizeForm }

  TSetCustomCellSizeForm = class(TForm)
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    SpinEditCellWidth: TSpinEditEx;
    SpinEditCellHeight: TSpinEditEx;
    procedure OKButtonClick(Sender: TObject);
  private

  public

  end;

var
  SetCustomCellSizeForm: TSetCustomCellSizeForm;

implementation

{$R *.lfm}

{ TSetCustomCellSizeForm }

procedure TSetCustomCellSizeForm.OKButtonClick(Sender: TObject);
begin
   modalresult:= mrOk;
end;

end.

