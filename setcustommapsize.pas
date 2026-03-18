unit setcustommapsize;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx;

type

  { TSetCustomMapSizeForm }

  TSetCustomMapSizeForm = class(TForm)
    OKButton: TButton;
    CustHeightLabel: TLabel;
    CustWidthLabel: TLabel;
    SpinEditCustomHeight: TSpinEditEx;
    SpinEditCustomWidth: TSpinEditEx;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private

  public

  end;

var
  SetCustomMapSizeForm: TSetCustomMapSizeForm;

implementation

{$R *.lfm}

{ TSetCustomMapSizeForm }

procedure TSetCustomMapSizeForm.OKButtonClick(Sender: TObject);
begin
  modalresult:= mrOk;
end;

procedure TSetCustomMapSizeForm.FormCreate(Sender: TObject);
begin

end;

end.

