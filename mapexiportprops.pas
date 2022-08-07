unit mapexiportprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,mapcore,rwmap,rmcodegen;

type

  { TMapExportForm }

  TMapExportForm = class(TForm)
    Button1: TButton;
    ComboCompiler: TComboBox;
    ComboMap: TComboBox;
    CompilerType: TLabel;
    EditHeight: TEdit;
    EditName: TEdit;
    EditWidth: TEdit;
    HeightLabel: TLabel;
    MapName: TLabel;
    MapType: TLabel;
    WidthLabel: TLabel;
    procedure Button1Click(Sender: TObject);
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

procedure TMapExportForm.Button1Click(Sender: TObject);
begin
  modalresult:= mrOk;
end;

procedure TMapExportForm.SetExportProps(props : MapExportFormatRec);
begin
   EO:=props;
   EditName.caption:=EO.Name;
   ComboCompiler.ItemIndex:=EO.Lan;
   ComboMap.ItemIndex:=EO.MapFormat;
   EditWidth.Text:=IntToStr(props.Width);
   EditHeight.Text:=IntToStr(props.Height);
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TMapExportForm.GetExportProps(var props : MapExportFormatRec);
begin
  props.Name:=EditName.caption;
  props.Lan:=ComboCompiler.ItemIndex;
  props.MapFormat:=ComboMap.ItemIndex;
  props.Width:=StrToIntDef(EditWidth.Text,0);
  props.Height:=StrToIntDef(EditHeight.Text,0);
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
   ComboCompiler.ItemIndex:=0;

   ComboMap.Items.Clear;
   ComboMap.Items.Add('None');
   ComboMap.ItemIndex:=0;

   EditWidth.Text:='0';
   EditHeight.Text:='0';
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

   end;
end;

end.

