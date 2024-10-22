unit mapexiportprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx,
  mapcore, rwmap, rmcodegen;

type

  { TMapExportForm }

  TMapExportForm = class(TForm)
    OKButton: TButton;
    ComboCompiler: TComboBox;
    ComboMap: TComboBox;
    CompilerType: TLabel;
    EditName: TEdit;
    HeightLabel: TLabel;
    MapName: TLabel;
    MapType: TLabel;
    SpinEditExportWidth: TSpinEditEx;
    SpinEditExportHeight: TSpinEditEx;
    WidthLabel: TLabel;
    procedure OKButtonClick(Sender: TObject);
    procedure ComboCompilerChange(Sender: TObject);
  private

  public
       EO : MapExportFormatRec;
       procedure SetExportProps(props : MapExportFormatRec);
       procedure GetExportProps(var props : MapExportFormatRec);
       procedure InitComboBoxes;
       procedure UpdateComboBoxes(compiler : integer);
  end;

var
  MapExportForm: TMapExportForm;

implementation

{$R *.lfm}

procedure TMapExportForm.ComboCompilerChange(Sender: TObject);
begin
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TMapExportForm.OKButtonClick(Sender: TObject);
begin
  modalresult:= mrOk;
end;

procedure TMapExportForm.SetExportProps(props : MapExportFormatRec);
begin
   EO:=props;
   EditName.caption:=EO.Name;
   ComboCompiler.ItemIndex:=EO.Lan;
   ComboMap.ItemIndex:=EO.MapFormat;
   SpinEditExportWidth.Value:=props.Width;
   SpinEditExportHeight.Value:=props.Height;
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TMapExportForm.GetExportProps(var props : MapExportFormatRec);
begin
  props.Name:=EditName.caption;
  props.Lan:=ComboCompiler.ItemIndex;
  props.MapFormat:=ComboMap.ItemIndex;
  props.Width:=SpinEditExportWidth.Value;
  props.Height:=SpinEditExportHeight.Value;
end;

procedure TMapExportForm.InitComboBoxes;
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

   SpinEditExportWidth.Value:=24;
   SpinEditExportHeight.Value:=8;
end;

procedure TMapExportForm.UpdateComboBoxes(compiler : integer);
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
                                ComboMap.ItemIndex:=EO.MapFormat;
                          end;
                    BasicLNLan:begin
                                ComboMap.Items.Clear;
                                ComboMap.Items.Add('None');
                                ComboMap.Items.Add('Simple');
                                ComboMap.ItemIndex:=EO.MapFormat;
                          end;
                    PascalLan:begin
                                ComboMap.Items.Clear;
                                ComboMap.Items.Add('None');
                                ComboMap.Items.Add('Simple');
                                ComboMap.ItemIndex:=EO.MapFormat;
                          end;
                    CLan:begin
                                ComboMap.Items.Clear;
                                ComboMap.Items.Add('None');
                                ComboMap.Items.Add('Simple');
                                ComboMap.ItemIndex:=EO.MapFormat;
                           end;
                   FBBasicLan:begin
                               ComboMap.Items.Clear;
                               ComboMap.Items.Add('None');
                               ComboMap.Items.Add('Simple');
                               ComboMap.ItemIndex:=EO.MapFormat;
                          end;
                   QB64BasicLan:begin
                               ComboMap.Items.Clear;
                               ComboMap.Items.Add('None');
                               ComboMap.Items.Add('Simple');
                               ComboMap.ItemIndex:=EO.MapFormat;
                          end;
                   AQBBasicLan:begin
                               ComboMap.Items.Clear;
                               ComboMap.Items.Add('None');
                               ComboMap.Items.Add('Simple');
                               ComboMap.ItemIndex:=EO.MapFormat;
                          end;
                   BAMBasicLan:begin
                               ComboMap.Items.Clear;
                               ComboMap.Items.Add('None');
                               ComboMap.Items.Add('Simple');
                               ComboMap.ItemIndex:=EO.MapFormat;
                          end;

   end;
end;

end.

