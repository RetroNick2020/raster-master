unit RMMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Menus, ColorBox, ActnList, StdActns, ColorPalette, Types,
  LResources,lclintf, RMTools, RMCore,RMColor,RMColorVGA,rmabout,RWPCX,RWBMP,RWXGF,WCON,XGF2SRC,bits,flood;



const
  MaxImagePixelWidth = 256;
  MaxImagePixelHeight = 256;

 // CellWidthBorderRemove =2;
 // CellHeightBorderRemove =2;
//  CellWidth = 20;
 // CellHeight = 20;
//  GridYThick=1;
//  GridXThick=1;

  PaletteModeNone = 0;
  PaletteModeMono = 1;
  PaletteModeCGA0 = 2;
  PaletteModeCGA1 = 3;
  PaletteModeEGA  = 4;
  PaletteModeVGA =  5;
  PaletteModeVGA256 = 6;


type

  { TRMMainForm }

  TRMMainForm = class(TForm)
    Action1: TAction;
    ActionList1: TActionList;
    FreePascalConst: TMenuItem;
    GWBASIC: TMenuItem;
    FreeBASICDATA: TMenuItem;
    TurboPowerBasicData: TMenuItem;
    QuickCChar: TMenuItem;
    TurboCChar: TMenuItem;
    RMLogo: TImage;
    RMPanel: TPanel;
    TurboPascalConst: TMenuItem;
    QBasicData: TMenuItem;
    ToolHFLIPButton: TButton;
    ColorButton1: TColorButton;
    ColorPalette1: TColorPalette;
    EditCut1: TEditCut;
    FileOpen1: TFileOpen;
    ToolUndoIcon: TImage;
    ToolScrollLeftIcon: TImage;
    ToolScrollRightIcon: TImage;
    ToolScrollUpIcon: TImage;
    ToolScrollDownIcon: TImage;
    ToolVFLIPButton: TButton;
    ToolCircleIcon: TImage;
    InfoBarLabel: TLabel;
    Panel1: TPanel;
    ToolSelectAreaIcon: TImage;
    ToolSprayPaintIcon: TImage;
    ToolFCircleIcon: TImage;
    ToolPencilIcon: TImage;
    ToolGridMenu: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    ToolMenu: TMenuItem;
    ToolLineIcon: TImage;
    ToolRectangleIcon: TImage;
    ToolPencilMenu: TMenuItem;
    ToolLineMenu: TMenuItem;
    ToolFRectangleIcon: TImage;
    ToolRectangleMenu: TMenuItem;
    ToolFRectangleMenu: TMenuItem;
    ToolCircleMenu: TMenuItem;
    ToolFCircleMenu: TMenuItem;
    ToolMenuPaint: TMenuItem;
    ToolMenuSprayPaint: TMenuItem;
    ToolSelectAreaMenu: TMenuItem;
    ToolFlipMenu: TMenuItem;
    ToolFlipHorizMenu: TMenuItem;
    ToolFlipVirtMenu: TMenuItem;
    ToolScrollMenu: TMenuItem;
    ToolScrollRightMenu: TMenuItem;
    ToolScrollLeftMenu: TMenuItem;
    ToolScrollUpMenu: TMenuItem;
    ToolScrollDownMenu: TMenuItem;
    HelpMenu: TMenuItem;
    RMAboutDialog: TMenuItem;
    NewFile: TMenuItem;
    PaletteMono: TMenuItem;
    PaletteCGA0: TMenuItem;
    PaletteCGA1: TMenuItem;
    MenuItem4: TMenuItem;
    PaletteVGA: TMenuItem;
    PaletteVGA256: TMenuItem;
    PaletteEGA: TMenuItem;
    SaveFileAs: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ColorBox : TShape;
    ActualBox: TImage;
    ToolPaintIcon: TImage;
    ToolGridIcon: TImage;
    ZoomBox: TImage;
    MainMenu1: TMainMenu;
    FileExitMenu: TMenuItem;
    OpenFile: TMenuItem;
    SaveFile: TMenuItem;
    HorizScroll: TScrollBar;

    TrackBar1: TTrackBar;
    VirtScroll: TScrollBar;
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure ActualBoxClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

    procedure ColorBox1Change(Sender: TObject);
    procedure ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FreeBASICDATAClick(Sender: TObject);
    procedure FreePascalConstClick(Sender: TObject);
    procedure GWBASICClick(Sender: TObject);
    procedure QuickCCharClick(Sender: TObject);
    procedure RMAboutDialogClick(Sender: TObject);
    procedure LineDrawChange(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure QBasicDataClick(Sender: TObject);
    procedure NewClick(Sender: TObject);
    procedure RMLogoClick(Sender: TObject);
    procedure ToolFlipHorizMenuClick(Sender: TObject);
    procedure ToolFlipVirtMenuClick(Sender: TObject);
    procedure ToolGridMenuClick(Sender: TObject);
    procedure ToolCircleMenuClick(Sender: TObject);
    procedure ToolFRectangleMenuClick(Sender: TObject);

    procedure ToolLineMenuClick(Sender: TObject);
    procedure ToolMenuSelectAreaMenuClick(Sender: TObject);
    procedure ToolMenuSprayPaintClick(Sender: TObject);
    procedure ToolMenuPaintClick(Sender: TObject);
    procedure ToolFCircleMenuClick(Sender: TObject);
    procedure ToolPencilMenuClick(Sender: TObject);
    procedure PaletteMonoClick(Sender: TObject);
    procedure PaletteCGA0Click(Sender: TObject);
    procedure PaletteCGA1Click(Sender: TObject);
    procedure SaveFileClick(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure PaletteVGAClick(Sender: TObject);
    procedure PaletteVGA256Click(Sender: TObject);
    procedure PaletteEGAClick(Sender: TObject);
    procedure PencilDrawChange(Sender: TObject);
    procedure ColorBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ToggleBox1Change(Sender: TObject);
    procedure ToolRectangleMenuClick(Sender: TObject);
    procedure ToolScrollDownMenuClick(Sender: TObject);
    procedure ToolScrollLeftMenuClick(Sender: TObject);
    procedure ToolScrollRightMenuClick(Sender: TObject);
    procedure ToolScrollUpMenuClick(Sender: TObject);
    procedure ToolUndoIconClick(Sender: TObject);
    procedure ToolVFLIPButtonClick(Sender: TObject);
    procedure TurboPowerBasicDataClick(Sender: TObject);
    procedure TurboCCharClick(Sender: TObject);
    procedure TurboPascalConstClick(Sender: TObject);


    procedure ZoomBoxClick(Sender: TObject);
    procedure ZoomBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZoomBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure ZoomBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZoomBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ToolCircleIconClick(Sender: TObject);
    procedure FileExitMenuClick(Sender: TObject);
    procedure OpenFileClick(Sender: TObject);
    procedure HorizScrollChange(Sender: TObject);
    procedure VirtScrollChange(Sender: TObject);

    procedure Shape1ChangeBounds(Sender: TObject);
    procedure ToolBar1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
       FX,FY,FX2,FY2 : Integer;
       ZoomX,ZoomY,ZoomX2,ZoomY2 : integer;
       ZoomSize : Integer;
       DrawMode : Boolean;
       DrawFirst : Boolean;
       MaxXOffset : Integer;
       MaxYOffset : Integer;
      // MaxXOffset2 : Integer;
       XOffset    : Integer;
       YOffset    : Integer;
      // r1,r2 : integer;
       palettemode : integer;

       procedure SetPaletteMode(mode : integer);
       function GetPaletteMode : integer;
       procedure UpdateZoomArea;
        procedure UpdateActualArea;
       procedure UpdatePalette;
       procedure UpdateColorBox;
       procedure UpdateInfoBarXY;
       procedure UpdateInfoBarDetail;

       procedure PaletteToCore;
       procedure CoreToPalette;
       procedure ClearSelectedToolsMenu;
       procedure UpdateToolSelectionIcons;
       procedure UpdateGridDisplay;
       procedure ClearSelectedPaletteMenu;
       procedure ClearClipAreaOutline;
       procedure LoadResourceIcons;
       procedure FreezeScrollAndZoom;
       procedure UnFreezeScrollAndZoom;
       procedure ShowSelectAreaTools;
       procedure HideSelectAreaTools;

  public

  end;



var
  RMMainForm: TRMMainForm;

implementation

{$R *.lfm}

{ TRMMainForm }

procedure TRMMainForm.PaletteToCore;
var
  i,count : integer;
  cr      : TRMColorRec;
  tc      : TColor;
begin
  count:=ColorPalette1.ColorCount;
  RMCoreBase.Palette.ClearColors;
  for i:=0 to count-1 do
  begin
     cr.r:=Red(ColorPalette1.Colors[i]);
     cr.g:=Green(ColorPalette1.Colors[i]);
     cr.b:=Blue(ColorPalette1.Colors[i]);
     RMCoreBase.Palette.AddColor(cr.r,cr.g,cr.b);
  end;
end;

procedure TRMMainForm.CoreToPalette;
var
  i,count : integer;
  cr      : TRMColorRec;
  tc      : TColor;
begin
  count:= RMCoreBase.Palette.GetColorCount;
//  ShowMessage('Count='+inttostr(count));
  ColorPalette1.ClearColors;
  for i:=0 to Count-1 do
  begin
     RMCoreBase.Palette.GetColor(i,cr);
     tc:=RGBToColor(cr.r,cr.g,cr.b);
  //   ColorPalette1.Colors[i]:=tc;
    ColorPalette1.AddColor(tc);
  end;
end;

procedure TRMMainForm.SetPaletteMode(mode : integer);
begin
   palettemode:=mode;
end;

function TRMMainForm.GetPaletteMode : integer;
begin
  getPaletteMode:=palettemode;
end;

procedure TRMMainForm.FormCreate(Sender: TObject);
Var
  X,Y : Integer;
begin
ZoomSize:=RMDrawTools.GetZoomMode;
DrawMode:=False;
DrawFirst:=False;
ActualBox.Canvas.Brush.Style := bsSolid;
ActualBox.Canvas.Brush.Color := clblack;
ActualBox.Canvas.FillRect(0,0,256,256);

ZoomBox.Canvas.Brush.Style := bsSolid;
ZoomBox.Canvas.Brush.Color := clwhite;

RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
LoadResourceIcons;


MaxXOffset:=RMDrawTools.GetMaxXOffset(MaxImagePixelWidth,ZoomBox.Width);
HorizScroll.Max:=MaxXOffset;
MaxYOffset:=RMDrawTools.GetMaxYOffset(MaxImagePixelHeight,ZoomBox.Height);
VirtScroll.Max:=MaxYOffset;

XOffset:=0;
YOffset:=0;
Trackbar1.Position:=RMDrawTools.getZoomSize;

SetPaletteMode(PaletteModeVGA);
UpdatePalette;

ColorBox.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor];
ColorPalette1.PickedIndex:=RMCoreBase.GetCurColor;


RMDrawTools.SetDrawTool(DrawShapePencil);
ClearSelectedToolsMenu;
HideSelectAreaTools;
UpdateToolSelectionIcons;
ToolPencilMenu.Checked:=true; //enable pencil tool in menu
end;





procedure TRMMainForm.RMAboutDialogClick(Sender: TObject);
begin
 Aboutdialog.InitName;
 AboutDialog.showmodal;
end;

procedure TRMMainForm.LineDrawChange(Sender: TObject);
begin

end;

procedure TRMMainForm.MenuItem11Click(Sender: TObject);
begin
  Close;
end;



procedure TRMMainForm.NewClick(Sender: TObject);
begin
  RMCoreBase.ClearBuf(0);
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
end;

procedure TRMMainForm.RMLogoClick(Sender: TObject);
begin
    OpenUrl('https://www.youtube.com/channel/UCogrq1maRKDUOT_r0dADlEQ');
end;

procedure TRMMainForm.ToolFlipHorizMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
 clipstatus : integer;
begin
  clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea
  RMDrawTools.GetClipAreaCoords(ca);
  ClearClipAreaOutline;
  RMDrawTools.HFlip(ca.x+Xoffset,ca.y+YOffset,ca.x2+XOffset,ca.y2+YOffset);
  UpdateActualArea;
  UpdateZoomArea;
  RMDrawTools.SetClipStatus(clipstatus);
  if clipstatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
  end;
end;

procedure TRMMainForm.ToolFlipVirtMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
 clipstatus : integer;
begin
  clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea
  RMDrawTools.GetClipAreaCoords(ca);
  ClearClipAreaOutline;
  RMDrawTools.VFlip(ca.x+Xoffset,ca.y+YOffset,ca.x2+XOffset,ca.y2+YOffset);
  UpdateActualArea;
  UpdateZoomArea;
  RMDrawTools.SetClipStatus(clipstatus);
  if clipstatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
  end;
end;

procedure TRMMainForm.ToolGridMenuClick(Sender: TObject);
begin
  UpdateGridDisplay;
end;

procedure TRMMainForm.ClearClipAreaOutline;
begin
   if (RMDRAWTools.GetDrawTool=DrawShapeClip) AND (RMDrawTools.GetClipStatus = 1) then
    begin
      RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
      RMDrawTools.SetClipStatus(0);
      RMDrawTools.SetClipSizedStatus(0);
    end;
end;

procedure TRMMainForm.ToolPencilMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  UnFreezeScrollAndZoom;
  ClearSelectedToolsMenu;
  HideSelectAreaTools;
  RMDrawTools.SetDrawTool(DrawShapePencil);
  UpdateToolSelectionIcons;
  ToolPencilMenu.Checked:=true;
 // ToolPencilIcon.Picture.LoadFromResourceName(HInstance,'PEN2');
end;

procedure TRMMainForm.ToolLineMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  UnFreezeScrollAndZoom;
  ClearSelectedToolsMenu;
  HideSelectAreaTools;
  RMDrawTools.SetDrawTool(DrawShapeLine);
  UpdateToolSelectionIcons;
  ToolLineMenu.Checked:=true;
end;

procedure TRMMainForm.ToolRectangleMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  UnFreezeScrollAndZoom;
  ClearSelectedToolsMenu;
  HideSelectAreaTools;
  RMDrawTools.SetDrawTool(DrawShapeRectangle);
  UpdateToolSelectionIcons;
  ToolRectangleMenu.Checked:=true;
end;

procedure TRMMainForm.ToolScrollDownMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
 clipstatus : integer;
begin
  clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea
  RMDrawTools.GetClipAreaCoords(ca);
  ClearClipAreaOutline;
  RMDrawTools.ScrollDown(ca.x+Xoffset,ca.y+YOffset,ca.x2+XOffset,ca.y2+YOffset);
  UpdateActualArea;
  UpdateZoomArea;
  RMDrawTools.SetClipStatus(clipstatus);
  if clipstatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
  end;
end;

procedure TRMMainForm.ToolScrollLeftMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
 clipstatus : integer;
begin
  clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea
  RMDrawTools.GetClipAreaCoords(ca);
  ClearClipAreaOutline;
  RMDrawTools.ScrollLeft(ca.x+Xoffset,ca.y+YOffset,ca.x2+XOffset,ca.y2+YOffset);
  UpdateActualArea;
  UpdateZoomArea;
  RMDrawTools.SetClipStatus(clipstatus);
  if clipstatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
  end;
end;

procedure TRMMainForm.ToolScrollRightMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
 clipstatus : integer;
begin
  clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea
  RMDrawTools.GetClipAreaCoords(ca);
  ClearClipAreaOutline;
  RMDrawTools.ScrollRight(ca.x+Xoffset,ca.y+YOffset,ca.x2+XOffset,ca.y2+YOffset);
  UpdateActualArea;
  UpdateZoomArea;
  RMDrawTools.SetClipStatus(clipstatus);
  if clipstatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
  end;
end;

procedure TRMMainForm.ToolScrollUpMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
 clipstatus : integer;
begin
  clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea
  RMDrawTools.GetClipAreaCoords(ca);
  ClearClipAreaOutline;
  RMDrawTools.ScrollUp(ca.x+Xoffset,ca.y+YOffset,ca.x2+XOffset,ca.y2+YOffset);
  UpdateActualArea;
  UpdateZoomArea;
  RMDrawTools.SetClipStatus(clipstatus);
  if clipstatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
  end;

end;

procedure TRMMainForm.ToolUndoIconClick(Sender: TObject);
var
 clipstatus : integer;
begin
  RMCoreBase.Undo;
  clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea
  ClearClipAreaOutline;
  UpdateActualArea;
  UpdateZoomArea;
  RMDrawTools.SetClipStatus(clipstatus);
  if clipstatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
  end;
end;

procedure TRMMainForm.ToolVFLIPButtonClick(Sender: TObject);
begin

end;









procedure TRMMainForm.ToolFRectangleMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  UnFreezeScrollAndZoom;
  ClearSelectedToolsMenu;
  HideSelectAreaTools;
  RMDrawTools.SetDrawTool(DrawShapeFRectangle);
  UpdateToolSelectionIcons;
  ToolFRectangleMenu.Checked:=true;
end;



procedure TRMMainForm.ToolCircleMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  UnFreezeScrollAndZoom;
  ClearSelectedToolsMenu;
  HideSelectAreaTools;
  RMDrawTools.SetDrawTool(DrawShapeCircle);
  UpdateToolSelectionIcons;
  ToolCircleMenu.Checked:=true;
end;

procedure TRMMainForm.ToolFCircleMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  UnFreezeScrollAndZoom;
  ClearSelectedToolsMenu;
  HideSelectAreaTools;
  RMDrawTools.SetDrawTool(DrawShapeFCircle);
  UpdateToolSelectionIcons;
  ToolFCircleMenu.Checked:=true;
end;

procedure TRMMainForm.ToolMenuPaintClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  UnFreezeScrollAndZoom;
  ClearSelectedToolsMenu;
  HideSelectAreaTools;
  RMDrawTools.SetDrawTool(DrawShapePaint);
  UpdateToolSelectionIcons;
  ToolMenuPaint.Checked:=true;
end;


procedure TRMMainForm.ToolMenuSprayPaintClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  UnFreezeScrollAndZoom;
  ClearSelectedToolsMenu;
  HideSelectAreaTools;
  RMDrawTools.SetDrawTool(DrawShapeSpray);
  UpdateToolSelectionIcons;
  ToolMenuSprayPaint.Checked:=true;
end;

procedure TRMMainForm.ToolMenuSelectAreaMenuClick(Sender: TObject);
begin
   ClearClipAreaOutline;
   UnFreezeScrollAndZoom;
   ClearSelectedToolsMenu;
   HideSelectAreaTools;
   RMDrawTools.SetDrawTool(DrawShapeClip);
   UpdateToolSelectionIcons;
   ToolSelectAreaMenu.Checked:=True;
end;

procedure TRMMainForm.PaletteMonoClick(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteMono.Checked:=true;
  SetPaletteMode(PaletteModeMono);
  UpdatePalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
end;

procedure TRMMainForm.PaletteCGA0Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteCGA0.Checked:=true;
  SetPaletteMode(PaletteModeCGA0);
  UpdatePalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
end;

procedure TRMMainForm.PaletteCGA1Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteCGA1.Checked:=true;
  SetPaletteMode(PaletteModeCGA1);
  UpdatePalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
end;



procedure TRMMainForm.MenuItem4Click(Sender: TObject);
begin

end;

procedure TRMMainForm.ClearSelectedPaletteMenu;
begin
  PaletteMono.Checked:=false;
  PaletteCGA0.Checked:=false;
  PaletteCGA1.Checked:=false;
  PaletteEGA.Checked:=false;
  PaletteVGA.Checked:=false;
  PaletteVGA256.Checked:=false;
end;

procedure TRMMainForm.PaletteVGAClick(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteVGA.Checked:=true;
  SetPaletteMode(PaletteModeVGA);
  UpdatePalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
end;

procedure TRMMainForm.PaletteVGA256Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteVGA256.Checked:=true;
  SetPaletteMode(PaletteModeVGA256);
  UpdatePalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
end;

procedure TRMMainForm.PaletteEGAClick(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteEGA.Checked:=true;
  SetPaletteMode(PaletteModeEGA);
  UpdatePalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
end;

procedure TRMMainForm.PencilDrawChange(Sender: TObject);
begin
  RMDrawTools.SetDrawTool(DrawShapePencil);
end;

procedure TRMMainForm.ColorBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  PI : integer;
  tc : TColor;
  cr : TRMColorRec;
  ci : integer;
  pm : integer;
begin
   // ShowMessage('count='+inttostr(RMCoreBase.Palette.GetColorCount));
   pm:=GetPaletteMode;
   If (pm = PaletteModeVGA) OR (pm = PaletteModeVGA256) then
  begin
    if pm = PaletteModeVGA then RMVGAColorDialog.InitColorBox16
    else RMVGAColorDialog.InitColorBox256;

   // RMVGAColorDialog.Left:= ColorBox.Left;
    if RMVGAColorDialog.ShowModal = mrOK then
    begin
       PI:=RMVGAColorDialog.GetPickedIndex;
       RMCoreBase.SetCurColor(PI);
       ColorPalette1.PickedIndex:=PI;

       ColorBox.Brush.Color:=RMVGAColorDialog.GetPickedColor;
       RMVGAColorDialog.PaletteToCore;
       CoreToPalette;
       UpdateActualArea;
       UpdateZoomArea;
    end;
  end
  else if (pm = PaletteModeEGA) then
  begin
     RMEGAColorDialog.InitColorBox;
   //  RMEGAColorDialog.Left:= RMMainForm.Left+ColorBox.Left;
     if RMEGAColorDialog.ShowModal = mrOK then
     begin
       PI:=RMEGAColorDialog.GetPickedIndex;
       if (PI > -1) then
       begin
          ci:=RMCoreBase.GetCurColor;
          ColorPalette1.Colors[ci]:=RMEGAColorDialog.GetPickedColor;
          ColorBox.Brush.Color:=RMEGAColorDialog.GetPickedColor;
          GetRGBEGA64(RMEGAColorDialog.GetPickedIndex, cr);
          RMCoreBase.Palette.SetColor(ci,cr);
          UpdateActualArea;
          UpdateZoomArea;
       end;
     end;
  end;


end;

procedure TRMMainForm.FreezeScrollAndZoom;
begin
   VirtScroll.Enabled:=false;
   HorizScroll.Enabled:=false;
   TrackBar1.Enabled:=false;
end;

procedure TRMMainForm.UnFreezeScrollAndZoom;
begin
  VirtScroll.Enabled:=true;
  HorizScroll.Enabled:=true;
  TrackBar1.Enabled:=true;
end;

procedure TRMMainForm.ToggleBox1Change(Sender: TObject);
begin
(*
   if ToggleBox1.Checked then
  begin
    RMDrawTools.SetDrawTool(DrawShapeClip);
    VirtScroll.Enabled:=false;
    HorizScroll.Enabled:=false;
    TrackBar1.Enabled:=false;
  end
  else
  begin
    RMDrawTools.SetDrawTool(DrawShapeNothing);
    VirtScroll.Enabled:=true;
    HorizScroll.Enabled:=true;
    TrackBar1.Enabled:=true;
  end;
  *)
end;





procedure TRMMainForm.VirtScrollChange(Sender: TObject);
begin
   YOffset:=VirtScroll.Position;
   updatezoomarea;
end;

procedure TRMMainForm.UpdateInfoBarXY;
var
  XYStr   : string;
  ClipStr : string;
  ca      : TClipAreaRec;
begin
 XYStr:='Zoom X = '+IntToStr(ZoomX)+' Zoom Y = '+IntToStr(ZoomY)+#13#10+
        'X = '+IntToStr(ZoomX+XOffset)+' Y = '+IntToStr(ZoomY + YOffset);
 ClipStr:='';
 if RMDrawTools.GetClipStatus = 1 then
 begin
      RMDrawTools.GetClipAreaCoords(ca);
      ClipStr:='Select Area '+'X = '+IntToStr(ca.x)+' Y = '+IntToStr(ca.y)+' X2 = '+IntToStr(ca.x2)+' Y2 = '+IntToStr(ca.y2)+#13#10+
               'Width = '+IntToStr(ca.x2-ca.x+1)+' Height = '+IntToStr(ca.y2-ca.y+1);
 end;
 InfoBarLabel.Caption:=XYStr+#13#10+ClipStr;
end;

procedure TRMMainForm.UpdateInfoBarDetail;
var
  XYStr   : string;
  ClipStr : string;
  ca      : TClipAreaRec;
begin
 XYStr:='Zoom X = '+IntToStr(FX)+' Zoom Y = '+IntToStr(FY)+#13#10+
        'Zoom X2 = '+IntToStr(FX2)+' Zoom Y2 = '+IntToStr(FY2)+#13#10+
        'X = '+IntToStr(FX+XOffset)+' Y = '+IntToStr(FY+YOffset)+#13#10+
        'X2 = '+IntToStr(FX2+XOffset)+' Y2 = '+IntToStr(FY2+YOffset)+#13#10+
        'Width = '+IntToStr(ABS(FX2-FX+1))+' Height = '+IntToStr(ABS(FY2-FY+1));
 InfoBarLabel.Caption:=XYStr;
end;


procedure TRMMainForm.UpdateActualArea;
var
  i,j : integer;
  zoommode : integer;
  tc : TColor;
begin
   zoommode:=RMDrawTools.GetZoomMode;
   RMDrawTools.SetZoomMode(0);
   for i:=0 to MaxImagePixelWidth -1 do
   begin
     for j:=0 to MaxImagePixelHeight-1 do
     begin
        tc:=ColorPalette1.Colors[RMCoreBase.GetPixel(i,j)];
        RMDrawTools.PutPixel(ActualBox.Canvas,i,j,tc,0);
     end;
   end;
   RMDrawTools.SetZoomMode(zoommode);
end;

procedure TRMMainForm.updateZoomArea;
var
i,j,w,h,xoff,yoff : integer;
tc : TColor;
begin
   xoff:=HorizScroll.Position;
   yoff:=VirtScroll.Position;

   w:=RMDrawTools.GetCellsPerRow(ZoomBox.Width);
   h:=RMDrawTools.GetCellsPerCol(ZoomBox.Height);

   for i:=0 to w do
   begin
     for j:=0 to h do
     begin
        tc:=ColorPalette1.Colors[RMCoreBase.GetPixel(xoff+i,yoff+j)];
        RMDrawTools.PutPixel(ZoomBox.Canvas,i,j,tc,0);
     end;
   end;
   if RMDrawTools.GetClipStatus = 1 then
   begin
      RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.Brush.color,1);
   end;
end;


procedure TRMMainForm.UpdateColorBox;
begin
  ColorBox.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor];
  ColorPalette1.PickedIndex:=RMCoreBase.GetCurColor;
end;

procedure TRMMainForm.UpdatePalette;
var
pm : integer;
begin
  pm:=GetPaletteMode;
  if pm = PaletteModeVGA256 then
  begin
    RMDrawTools.AddVGAPalette256(ColorPalette1);
    ColorPalette1.ColumnCount:=32;
    ColorPalette1.ButtonHeight:=17;
    ColorPalette1.ButtonWidth:=17;
    PaletteToCore;
  end
  else if pm = PaletteModeVGA then
  begin
    RMDrawTools.AddVGAPalette(ColorPalette1);       //Add to Visual Compononet Palette
    ColorPalette1.ColumnCount:=8;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
    PaletteToCore;  //copy valaues from Component pallete to internal core palette
  end
  else if pm = PaletteModeEGA then
  begin
   RMDrawTools.AddEGAPalette(ColorPalette1);
   ColorPalette1.ColumnCount:=8;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
   PaletteToCore;
  end
  else if pm = PaletteModeCGA0 then
  begin
   RMDrawTools.AddCGAPalette0(ColorPalette1);
   ColorPalette1.ColumnCount:=2;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
   PaletteToCore;
  end
  else if pm = PaletteModeCGA1 then
  begin
   RMDrawTools.AddCGAPalette1(ColorPalette1);
   ColorPalette1.ColumnCount:=2;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
   PaletteToCore;
  end
  else if pm = PaletteModeMono then
  begin
   RMDrawTools.AddMonoPalette(ColorPalette1);
   ColorPalette1.ColumnCount:=1;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
   PaletteToCore;
  end;
end;

procedure TRMMainForm.Action1Execute(Sender: TObject);
begin

end;

procedure TRMMainForm.Action2Execute(Sender: TObject);
begin

end;

procedure TRMMainForm.ActualBoxClick(Sender: TObject);
begin

end;

procedure TRMMainForm.Button1Click(Sender: TObject);

begin

end;

Procedure TRMMainForm.UpdateGridDisplay;
var
 clipstatus : integer;
begin
  clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea
  ClearClipAreaOutline;
  if RMDrawTools.GetGridMode = 0 then
     begin
       RMDrawTools.SetGridMode(1);
       //Button2.Caption:='Grid Off';
       ToolGridMenu.Checked:=true;
     end
     else
     begin
       RMDrawTools.SetGridMode(0);
      // Button2.Caption:='Grid On';
       ToolGridMenu.Checked:=false;

     end;
    MaxXOffset:=RMDrawTools.GetMaxXOffset(MaxImagePixelWidth,ZoomBox.Width);
    HorizScroll.Max:=MaxXOffset;
    MaxYOffset:=RMDrawTools.GetMaxYOffset(MaxImagePixelHeight,ZoomBox.Height);
    VirtScroll.Max:=MaxYOffset;

    UpdateActualArea;
    RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
    UpdateZoomArea;

    RMDrawTools.SetClipStatus(clipstatus);
    if RMDrawTools.GetClipStatus = 1 then
    begin
       RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
    end;

end;

procedure TRMMainForm.Button2Click(Sender: TObject);
begin
  UpdateGridDisplay;
end;



procedure TRMMainForm.ColorBox1Change(Sender: TObject);
begin
end;

procedure TRMMainForm.ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
  //Label5.Caption:= ColorToString(AColor)+' '+IntToStr(ColorPalette1.PickedIndex);
  ColorBox.Brush.Color:= AColor;
  RMCoreBase.SetCurColor(ColorPalette1.PickedIndex);
 // MyDraw(ActualBox);
end;




procedure TRMMainForm.ZoomBoxClick(Sender: TObject);
var
  PT : TPoint;
begin
    PT := Mouse.CursorPos;
  // now have SCREEN position
 // Label1.Caption := 'X = '+IntToStr(pt.x)+', Y = '+IntToStr(pt.y);
  pt := ScreenToClient(pt);
  // now have FORM position
 // Label2.Caption := 'X = '+IntToStr(pt.x)+', Y = '+IntToStr(pt.y);
end;

procedure TRMMainForm.ZoomBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

 var
  PT : TPoint;
  DT : integer;
begin
   DT:=RMDrawTools.GetDrawTool;                                             //if there is a clip area and we are no longer in clip mode - remove it
   if (DT<>DrawShapeClip) AND (RMDrawTools.GetClipStatus = 1) then
   begin
     RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
     RMDrawTools.SetClipStatus(0);
     RMDrawTools.SetClipSizedStatus(0);
   end;

   DrawMode:=True;
 //  XOffset:=HorizScroll.Position;
 //  YOffset:=VirtScroll.Position;
  //ZoomX:=X div CellWidth;
  //ZoomY:=Y div CellHeight;
 // ZoomX:=X div (CellWidth+GridYThick);
 // ZoomY:=Y div (CellHeight+GridXThick);
 ZoomX:=RMDrawTools.GetZoomX(x);
 ZoomY:=RMDrawTools.GetZoomY(y);

  FX:=ZoomX;
  FY:=ZoomY;
  FX2:=FX;
  FY2:=FY;
  UpdateInfoBarXY;
  If DT = DrawShapePencil then
  begin
    RMCoreBase.CopyToUndoBuf;
    RMDrawTools.ADrawShape(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,0,DT,0);
    RMDrawTools.DrawShape(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,0,DT,0);
    RMDrawTools.DrawShape(ZoomBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,2,DT,0);       // to internal buffer
    exit;
  end
  else if DT = DrawShapePaint then
  begin
    RMCoreBase.CopyToUndoBuf;
    Fill(FX+XOffset,FY+YOffset,RMCoreBase.GetCurColor);
    UpdateActualArea;
    UpdateZoomArea;
    exit;
  end
  else if DT = DrawShapeSpray then
  begin
    RMCoreBase.CopyToUndoBuf;
    RMDrawTools.CreateRandomSprayPoints;
    RMDrawTools.ADrawShape(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,0,DT,0);
    RMDrawTools.DrawShape(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,0,DT,0);
    RMDrawTools.DrawShape(ZoomBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,2,DT,0);       // to internal buffer
    exit;
  end
  else if DT = DrawShapeClip then
   begin
     if RMDrawTools.GetClipStatus = 1 then                              //remove the previous clip
     begin
      RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
     end;
     RMDrawTools.SetClipStatus(0);
     RMDrawTools.SetClipSizedStatus(0);
   end;




//   PT := Mouse.CursorPos;
  // now have SCREEN position
 // Label1.Caption := 'X = '+IntToStr(x)+', Y = '+IntToStr(y);
 // pt := ScreenToClient(pt);
  // now have FORM position
 // Label2.Caption := 'X = '+IntToStr(pt.x)+', Y = '+IntToStr(pt.y);
end;

procedure TRMMainForm.ZoomBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 DT : integer;
begin
 DT:=RMDRAWTools.GetDrawTool;
 ZoomX:=RMDrawTools.GetZoomX(x);
 ZoomY:=RMDrawTools.GetZoomY(y);
 UpdateInfoBarXY;
 //InfoBarLabel.Caption:= 'MaxXOff = '+IntToStr(MaxXoffset)+' ZoomX ='+IntToStr(ZoomX)+' ZoomY ='+IntToStr(ZoomY);
 //Label8.Caption:= 'XOffset = '+IntToStr(Xoffset)+'YOffset = '+IntToStr(Yoffset);

 if DrawMode = False then exit;


 If (DT = DrawShapePencil) OR (DT = DrawShapeSpray) then
  begin
    FX:=ZoomX;
    FY:=ZoomY;
    FX2:=ZoomX;
    FY2:=ZoomY;
    //RMCoreBase.CopyToUndoBuf;
    RMDrawTools.CreateRandomSprayPoints;
    RMDrawTools.ADrawShape(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,0,DT,0);
    RMDrawTools.DrawShape(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,0,DT,0);
    RMDrawTools.DrawShape(ZoomBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,2,DT,0);
    exit;
  end;

 if DrawFirst = True then
 begin
  //RMDrawTools.ARectangle(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,1);
  //RMDrawTools.Rect(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,1);

  RMDrawTools.ADrawShape(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,1,DT,0);
  RMDrawTools.DrawShape(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,1,DT,0);
 end;


 FX2:=ZoomX;
 FY2:=ZoomY;
 UpdateInfoBarDetail;

 //RMDrawTools.ARectangle(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,1);
 //RMDrawTools.Rect(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,1);
 RMDrawTools.ADrawShape(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,1,DT,0);
 RMDrawTools.DrawShape(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,1,DT,0);

 DrawFirst:=True;
 RMDrawTools.SetClipSizedStatus(1); // yes we have some sizing co-ordinates
end;

procedure TRMMainForm.ZoomBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 DT : integer;
begin
 DT:=RMDRAWTools.GetDrawTool;
 if (DT =DrawShapePencil) OR (DT = DrawShapeSpray) Or (DT = DrawShapePaint) then               //we draw pencil on mouse move events only
 begin
   DrawFirst:=FALSE;
   DrawMode:=False;
   exit;
 end
 else if  DT = DrawShapeClip then        //move event was not triggered so we don't have a clip area - user clicked really fast
 begin                                   // we haven't drawn a clip area so lets just exit
   if RMDrawTools.GetClipSizedStatus = 0 then
   begin
     DrawFirst:=FALSE;
     DrawMode:=False;
     exit;
   end;
 end;

 //erase the old
  //RMDrawTools.ARectangle(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,1);
  //RMDrawTools.Rect(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,1);
  RMDrawTools.ADrawShape(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,1,DT,0);
  RMDrawTools.DrawShape(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,1,DT,0);



  DrawFirst:=FALSE;
  DrawMode:=False;

 //Draw the real image
//  RMDrawTools.SetZoomMode(0);
//  RMDrawTools.Rect(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,0);
//  RMDrawTools.SetZoomMode(1);
//  RMDrawTools.Rect(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,0);


  if DT = DrawShapeClip then
  begin
    RMDrawTools.DrawShape(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,1,DT,1);
    RMDrawTools.SaveClipCoords(fx,fy,fx2,fy2);
    RMDrawTools.SetClipStatus(1); //on
    FreezeScrollAndZoom;
    ShowSelectAreaTools;
   end
  else
  begin
    RMCoreBase.CopyToUndoBuf;
    RMDrawTools.ADrawShape(ActualBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,0,DT,1);
    RMDrawTools.DrawShape(ZoomBox.Canvas,fx,fy,fx2,fy2,ColorBox.Brush.Color,0,DT,1);
    RMDrawTools.DrawShape(ZoomBox.Canvas,FX+XOffset,FY+YOffset,FX2+XOffset,FY2+YOffset,ColorBox.Brush.Color,2,DT,1);
  end;
end;

procedure TRMMainForm.ZoomBoxMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
//   if ToggleBox1.Checked then exit;
   if RMDrawTools.GetClipStatus = 1 then exit;

   ZoomSize:=RMDrawTools.GetZoomSize;
   If WheelDelta < 0 then dec(ZoomSize)
   else if WheelDelta > 0 then inc(ZoomSize);

   //Label3.Caption := 'Wheel = '+IntToStr(WheelDelta)+' ZoomSize - '+IntToStr(ZoomSize);
   RMDrawTools.SetZoomSize(ZoomSize);
   RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
   MaxXOffset:=RMDrawTools.GetMaxXOffset(MaxImagePixelWidth,ZoomBox.Width);
   HorizScroll.Max:=MaxXOffset;
   MaxYOffset:=RMDrawTools.GetMaxYOffset(MaxImagePixelHeight,ZoomBox.Height);
   VirtScroll.Max:=MaxYOffset;
   TrackBar1.Position:=RMDrawTools.GetZoomSize;
   UpdateZoomArea;
end;

procedure TRMMainForm.ToolCircleIconClick(Sender: TObject);
begin
  ToolCircleIcon.Picture.LoadFromResourceName(HInstance,'CIRCLE_BLACK');
  //drawgrid(0,0,20,20,'');
end;

procedure TRMMainForm.FileExitMenuClick(Sender: TObject);
begin
   Close;
end;


procedure TRMMainForm.HorizScrollChange(Sender: TObject);
begin
  //Label6.Caption:='ScrollBar Pos='+IntToStr(HorizScroll.Position);
  XOffset:=HorizScroll.Position;
  updatezoomarea;
end;



procedure TRMMainForm.Shape1ChangeBounds(Sender: TObject);
begin

end;

procedure TRMMainForm.ToolBar1Click(Sender: TObject);
begin

end;

procedure TRMMainForm.TrackBar1Change(Sender: TObject);
begin
  //Label4.Caption := 'Position = '+IntToStr(TrackBar1.Position);
  RMDrawTools.SetZoomSize(TrackBar1.Position);
  RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  MaxXOffset:=RMDrawTools.GetMaxXOffset(MaxImagePixelWidth,ZoomBox.Width);
  HorizScroll.Max:=MaxXOffset;
  MaxYOffset:=RMDrawTools.GetMaxYOffset(MaxImagePixelHeight,ZoomBox.Height);
  VirtScroll.Max:=MaxYOffset;
  UpdateZoomArea;
end;


procedure TRMMainForm.ClearSelectedToolsMenu;
begin
     ToolCircleMenu.Checked:=false;
     ToolFRectangleMenu.Checked:=false;
     ToolRectangleMenu.Checked:=false;
     ToolLineMenu.Checked:=false;
     ToolSelectAreaMenu.Checked:=false;

     ToolMenuSprayPaint.Checked:=false;
     ToolMenuPaint.Checked:=false;
     ToolFCircleMenu.Checked:=false;
     ToolPencilMenu.Checked:=false;

     //menus - we disable menus instead of making them invisible
     ToolFlipMenu.Enabled:=false;
     ToolScrollMenu.Enabled:=false;
end;

Procedure TRMMainForm.LoadResourceIcons;
begin
  ToolPencilIcon.Picture.LoadFromResourceName(HInstance,'PEN1');
  ToolLineIcon.Picture.LoadFromResourceName(HInstance,'LINE1');
  ToolCircleIcon.Picture.LoadFromResourceName(HInstance,'CIRC1');
  ToolFCircleIcon.Picture.LoadFromResourceName(HInstance,'FCIRC1');
  ToolRectangleIcon.Picture.LoadFromResourceName(HInstance,'RECT1');
  ToolFRectangleIcon.Picture.LoadFromResourceName(HInstance,'FRECT1');
  ToolSprayPaintIcon.Picture.LoadFromResourceName(HInstance,'SPRAY1');
  ToolPaintIcon.Picture.LoadFromResourceName(HInstance,'PAINT1');
  ToolGridIcon.Picture.LoadFromResourceName(HInstance,'GRID1');
  ToolSelectAreaIcon.Picture.LoadFromResourceName(HInstance,'SELECT1');
  ToolUndoIcon.Picture.LoadFromResourceName(HInstance,'UNDO1');
  ToolScrollUpIcon.Picture.LoadFromResourceName(HInstance,'UP1');
  ToolScrollDownIcon.Picture.LoadFromResourceName(HInstance,'DOWN1');
  ToolScrollLeftIcon.Picture.LoadFromResourceName(HInstance,'LEFT1');
  ToolScrollRightIcon.Picture.LoadFromResourceName(HInstance,'RIGHT1');
  RMLogo.Picture.LoadFromResourceName(HInstance,'RM');
 // RMLogo.Picture.Bitmap.MaskHandle:=0;
  RMLogo.Picture.Bitmap.Transparent := True;
 // RMLogo.Picture.Bitmap.TransparentColor := RGBToColor(170,170,170);
end;


procedure TRMMainForm.UpdateToolSelectionIcons;
var
 DT : Integer;
begin
  ToolPencilIcon.Picture.LoadFromResourceName(HInstance,'PEN1');
  ToolLineIcon.Picture.LoadFromResourceName(HInstance,'LINE1');
  ToolCircleIcon.Picture.LoadFromResourceName(HInstance,'CIRC1');
  ToolFCircleIcon.Picture.LoadFromResourceName(HInstance,'FCIRC1');
  ToolRectangleIcon.Picture.LoadFromResourceName(HInstance,'RECT1');
  ToolFRectangleIcon.Picture.LoadFromResourceName(HInstance,'FRECT1');
  ToolSprayPaintIcon.Picture.LoadFromResourceName(HInstance,'SPRAY1');
  ToolPaintIcon.Picture.LoadFromResourceName(HInstance,'PAINT1');
  ToolSelectAreaIcon.Picture.LoadFromResourceName(HInstance,'SELECT1');

 DT:=RMDRAWTools.GetDrawTool;
 case DT of DrawShapePencil:ToolPencilIcon.Picture.LoadFromResourceName(HInstance,'PEN2');
              DrawShapeLine:ToolLineIcon.Picture.LoadFromResourceName(HInstance,'LINE2');
            DrawShapeCircle:ToolCircleIcon.Picture.LoadFromResourceName(HInstance,'CIRC2');
           DrawShapeFCircle:ToolFCircleIcon.Picture.LoadFromResourceName(HInstance,'FCIRC2');
         DrawShapeRectangle:ToolRectangleIcon.Picture.LoadFromResourceName(HInstance,'RECT2');
        DrawShapeFRectangle:ToolFRectangleIcon.Picture.LoadFromResourceName(HInstance,'FRECT2');
             DrawShapeSpray:ToolSprayPaintIcon.Picture.LoadFromResourceName(HInstance,'SPRAY2');
             DrawShapePaint:ToolPaintIcon.Picture.LoadFromResourceName(HInstance,'PAINT2');
              DrawShapeClip:ToolSelectAreaIcon.Picture.LoadFromResourceName(HInstance,'SELECT2');

 end;
end;

procedure TRMMainForm.ShowSelectAreaTools;
begin
  ToolVFLIPButton.Visible:=true;
  ToolHFLIPButton.Visible:=true;
  ToolScrollUpIcon.Visible:=true;
  ToolScrollDownIcon.Visible:=true;
  ToolScrollLeftIcon.Visible:=true;
  ToolScrollRightIcon.Visible:=true;

   //menus - we enable menus also
  ToolFlipMenu.Enabled:=true;
  ToolScrollMenu.Enabled:=true;
end;

procedure TRMMainForm.HideSelectAreaTools;
begin
  ToolVFLIPButton.Visible:=false;
  ToolHFLIPButton.Visible:=false;
  ToolScrollUpIcon.Visible:=false;
  ToolScrollDownIcon.Visible:=false;
  ToolScrollLeftIcon.Visible:=false;
  ToolScrollRightIcon.Visible:=false;
end;


procedure TRMMainForm.SaveFileClick(Sender: TObject);
var
 ext : string;
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
begin
   SaveDialog1.Filter := 'Windows BMP|*.bmp|PC Paintbrush |*.pcx|All Files|*.*' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
      ext:=UpperCase(ExtractFileExt(SaveDialog1.Filename));
     // ShowMessage(SaveDialog1.Filename);
     // ShowMessage(SaveDialog1.DefaultExt);
      if ext = '.PCX' then
      begin
         if SavePcxImg(x,y,x2,y2,SaveDialog1.FileName) <> 0 then
         begin
           ShowMessage('Error Saving PCX file!');
         end;
      end
      else if ext = '.BMP' then
      begin
        if WriteBMP(x,y,x2,y2,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving BMP file!');
        end;
      end;
   end;
end;

procedure TRMMainForm.OpenFileClick(Sender: TObject);
var
 ext : string;
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 lp   : integer;
begin
   if RMDrawTools.GetClipStatus = 1 then
   begin
        lp:=0;
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        lp:=1;
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;

   OpenDialog1.Filter := 'Windows BMP|*.bmp|PC Paintbrush |*.pcx|All Files|*.*' ;

   if OpenDialog1.Execute then
   begin
      ext:=UpperCase(ExtractFileExt(OpenDialog1.FileName));
      if ext = '.PCX' then
      begin
         if ReadPcxImg(x,y,x2,y2,lp,OpenDialog1.FileName) <> 0 then
         begin
           ShowMessage('Error Opening PCX file!');
           exit;
         end;
      end
      else if ext = '.BMP' then
      begin
        if ReadBMP(x,y,x2,y2,lp,OpenDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Opening BMP file!');
          exit;
        end;
      end;
      if RMDrawTools.GetClipStatus <> 1 then CoreToPalette;
      UpDateZoomArea;
      UpdateActualArea;
   end;
end;

procedure TRMMainForm.QBasicDataClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 pm : integer;
begin
   SaveDialog1.Filter := 'QBasic DATA|*.dat' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
      pm:=GetPaletteMode;
      if (pm = PaletteModeMono)  then
          begin
            if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,Source2,QBLan,SaveDialog1.FileName) <> 0 then
            begin
              ShowMessage('Error Saving DAT file!');
              exit;
            end;
          end
       else if (pm = PaletteModeCGA0) or (pm = PaletteModeCGA1) then
          begin
            if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,Source4,QBLan,SaveDialog1.FileName) <> 0 then
            begin
              ShowMessage('Error Saving DAT file!');
              exit;
            end;
          end
      else if (pm = PaletteModeEGA) or (pm = PaletteModeVGA) then
      begin
        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,Source16,QBLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving DAT file!');
          exit;
        end;
      end
      else  if  (pm = PaletteModeVGA256) then
      begin
        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,Source256,QBLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving DAT file!');
          exit;
        end;
      end;
   end;
 end;

procedure TRMMainForm.TurboPascalConstClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 pm : integer;
begin
   SaveDialog1.Filter := 'Turbo Pascal Const|*.con' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
      pm:=GetPaletteMode;
      if (pm = PaletteModeMono)  then
          begin
            if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,Source2,TPLan,SaveDialog1.FileName) <> 0 then
            begin
              ShowMessage('Error Saving CON file!');
              exit;
            end;
          end
       else if (pm = PaletteModeCGA0) or (pm = PaletteModeCGA1) then
          begin
            if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,Source4,TPLan,SaveDialog1.FileName) <> 0 then
            begin
              ShowMessage('Error Saving CON file!');
              exit;
            end;
          end
      else if (pm = PaletteModeEGA) or (pm = PaletteModeVGA) then
      begin
        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,Source16,TPLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving CON file!');
          exit;
        end;
      end
      else  if  (pm = PaletteModeVGA256) then
      begin
        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,Source256,TPLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving CON file!');
          exit;
        end;
      end;
   end;

end;

procedure TRMMainForm.FreePascalConstClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 pm : integer;
 sourcemode : word;
begin
   SaveDialog1.Filter := 'FreePascal Const|*.con' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
        pm:=GetPaletteMode;
        case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
                         PaletteModeVGA256:sourcemode:=source256;
        end;

        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,sourcemode,FPLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving CON file!');
          exit;
        end;
   end;
end;

procedure TRMMainForm.GWBASICClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 pm : integer;
 sourcemode : word;
begin
   SaveDialog1.Filter := 'GWBASIC DATA|*.DAT' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
        pm:=GetPaletteMode;
        case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
                         PaletteModeVGA256:sourcemode:=source256;
        end;

        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,sourcemode,GWLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving DAT file!');
          exit;
        end;
   end;


end;

procedure TRMMainForm.QuickCCharClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 pm : integer;
 sourcemode : word;
begin
   SaveDialog1.Filter := 'Quick C Char|*.CHA' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
        pm:=GetPaletteMode;
        case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
                         PaletteModeVGA256:sourcemode:=source256;
        end;

        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,sourcemode,QCLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving CHA file!');
          exit;
        end;
   end;

end;

procedure TRMMainForm.TurboCCharClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 pm : integer;
 sourcemode : word;
begin
   SaveDialog1.Filter := 'Turbo C Char|*.CHA' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
        pm:=GetPaletteMode;
        case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
                         PaletteModeVGA256:sourcemode:=source256;
        end;

        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,sourcemode,TCLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving CHA file!');
          exit;
        end;
   end;
end;

procedure TRMMainForm.TurboPowerBasicDataClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 pm : integer;
 sourcemode : word;
begin
   SaveDialog1.Filter := 'Turbo/Power Basic DATA|*.DAT' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
        pm:=GetPaletteMode;
        case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
                         PaletteModeVGA256:sourcemode:=source256;
        end;

        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,sourcemode,PBLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving DAT file!');
          exit;
        end;
   end;

end;


procedure TRMMainForm.FreeBASICDATAClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 ca   : TClipAreaRec;
 pm : integer;
 sourcemode : word;
begin
   SaveDialog1.Filter := 'FreeBASIC DATA|*.DAT' ;
   if RMDrawTools.GetClipStatus = 1 then
   begin
        RMDrawTools.GetClipAreaCoords(ca);
        x:=ca.x+XOffset;
        y:=ca.y+Yoffset;
        x2:=ca.x2+XOffset;
        y2:=ca.y2+YOffset;
   end
   else
   begin
        x:=0;
        y:=0;
        x2:=255;
        y2:=255;
   end;
   if SaveDialog1.Execute then
   begin
        pm:=GetPaletteMode;
        case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
                         PaletteModeVGA256:sourcemode:=source256;
        end;

        if WriteDat(x+XOffset,y+YOffset,x2+XOffset,y2+YOffset,sourcemode,FBLan,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving DAT file!');
          exit;
        end;
   end;


end;


end.

