unit animationexport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,AnimBase,rwxgf,rmcodegen;

type

  { TAnimationExportForm }

  TAnimationExportForm = class(TForm)
    ComboCompiler: TComboBox;
    ComboMap: TComboBox;
    CompilerType: TLabel;
    EditName: TEdit;
    AnimationName: TLabel;
    AnimationType: TLabel;
    OKButton: TButton;
    procedure ComboCompilerChange(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private

  public
       EO : AnimExportFormatRec;
       procedure SetExportProps(props : AnimExportFormatRec);
       procedure GetExportProps(var props : AnimExportFormatRec);
       procedure InitComboBoxes;
       procedure UpdateComboBoxes(compiler : integer);

  end;

var
  AnimationExportForm: TAnimationExportForm;

implementation

{$R *.lfm}

procedure TAnimationExportForm.ComboCompilerChange(Sender: TObject);
begin
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TAnimationExportForm.OKButtonClick(Sender: TObject);
begin
  modalresult:= mrOk;
end;

procedure TAnimationExportForm.SetExportProps(props : AnimExportFormatRec);
begin
   EO:=props;
   EditName.caption:=EO.Name;
   ComboCompiler.ItemIndex:=EO.Lan;
   ComboMap.ItemIndex:=EO.AnimateFormat;
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TAnimationExportForm.GetExportProps(var props : AnimExportFormatRec);
begin
  props.Name:=EditName.caption;
  props.Lan:=ComboCompiler.ItemIndex;
  props.AnimateFormat:=ComboMap.ItemIndex;
end;

procedure TAnimationExportForm.InitComboBoxes;
begin
   EditName.caption:='';
   Combocompiler.Items.Clear;
   ComboCompiler.Items.Add('None');
   ComboCompiler.Items.Add('Basic');
   ComboCompiler.Items.Add('Basic (Line#)');
   ComboCompiler.Items.Add('C');
   ComboCompiler.Items.Add('Pascal');
   ComboCompiler.Items.Add('FreeBASIC');
   ComboCompiler.Items.Add('QB64');
   ComboCompiler.Items.Add('Amiga QuickBasic AQB');
   ComboCompiler.Items.Add('BAM Basic');
   ComboCompiler.ItemIndex:=0;

   ComboMap.Items.Clear;
   ComboMap.Items.Add('None');
   ComboMap.ItemIndex:=0;

end;

procedure TAnimationExportForm.UpdateComboBoxes(compiler : integer);
begin
  case compiler of NoLan:begin
                            ComboMap.Items.Clear;
                            ComboMap.Items.Add('None');
                            ComboMap.ItemIndex:=0;
                          end;
                    BasicLan:begin
                                ComboMap.Items.Clear;
                                ComboMap.Items.Add('None');
                                ComboMap.Items.Add('Simple');
                                ComboMap.ItemIndex:=EO.AnimateFormat;
                          end;
                    BasicLNLan:begin
                                ComboMap.Items.Clear;
                                ComboMap.Items.Add('None');
                                ComboMap.Items.Add('Simple');
                                ComboMap.ItemIndex:=EO.AnimateFormat;
                          end;
                    PascalLan:begin
                                ComboMap.Items.Clear;
                                ComboMap.Items.Add('None');
                                ComboMap.Items.Add('Simple');
                                ComboMap.ItemIndex:=EO.AnimateFormat;
                          end;
                    CLan:begin
                                ComboMap.Items.Clear;
                                ComboMap.Items.Add('None');
                                ComboMap.Items.Add('Simple');
                                ComboMap.ItemIndex:=EO.AnimateFormat;
                           end;
                   FBBasicLan:begin
                                ComboMap.Items.Clear;
                                ComboMap.Items.Add('None');
                                ComboMap.Items.Add('Simple');
                                ComboMap.ItemIndex:=EO.AnimateFormat;
                              end;
                   QB64BasicLan:begin
                                  ComboMap.Items.Clear;
                                  ComboMap.Items.Add('None');
                                  ComboMap.Items.Add('Simple');
                                  ComboMap.ItemIndex:=EO.AnimateFormat;
                                end;
                   AQBBasicLan:begin
                               ComboMap.Items.Clear;
                               ComboMap.Items.Add('None');
                               ComboMap.Items.Add('Simple');
                               ComboMap.ItemIndex:=EO.AnimateFormat;
                          end;
                   BAMBasicLan:begin
                               ComboMap.Items.Clear;
                               ComboMap.Items.Add('None');
                               ComboMap.Items.Add('Simple');
                               ComboMap.ItemIndex:=EO.AnimateFormat;
                          end;

   end;
end;


end.

