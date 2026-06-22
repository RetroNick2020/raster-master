unit uAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, lclintf;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    GoToItchIOButton: TButton;
    lblTitle: TLabel;
    lblVersion: TLabel;
    lblDescription: TLabel;
    btnOK: TButton;
    procedure GoToItchIOButtonClick(Sender: TObject);
  private
  public
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.lfm}

{ TAboutForm }

procedure TAboutForm.GoToItchIOButtonClick(Sender: TObject);
begin
  OpenUrl('https://retronick2020.itch.io');
end;

end.
