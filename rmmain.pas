unit rmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Menus, ActnList, StdActns, ColorPalette, Types,
  LResources,lclintf, rmtools, rmcore,rmcolor,rmcolorvga,rmamigaColor,
  rmabout,rwpal,rwraw,rwpcx,rwbmp,rwxgf,wcon,flood,rmamigarwxgf,wjavascriptarray,rmthumb;


type

  { TRMMainForm }

  TRMMainForm = class(TForm)
    Action1: TAction;
    ActionList1: TActionList;
    ActualBox: TImage;
    FreePascal: TMenuItem;
    GWBASIC: TMenuItem;
    FreeBASIC: TMenuItem;
    AmigaBasic: TMenuItem;
    ImageList1: TImageList;
    ListView1: TListView;
    MenuItem1: TMenuItem;
    EditCopy: TMenuItem;
    EditPaste: TMenuItem;
    EditColor: TMenuItem;
    EditResizeTo128: TMenuItem;
    EditResizeTo256: TMenuItem;
    EditUndo: TMenuItem;
    EditResizeTo: TMenuItem;
    EditResizeTo8: TMenuItem;
    EditResizeTo16: TMenuItem;
    EditResizeTo32: TMenuItem;
    EditResizeTo64: TMenuItem;
    EditClear: TMenuItem;
    JavaScript: TMenuItem;
    ACVSpriteColorArray: TMenuItem;
    ACPaletteArray: TMenuItem;
    QCPaletteArray: TMenuItem;
    QCPaletteCommands: TMenuItem;
    TCPaletteArray: TMenuItem;
    TCPaletteCommands: TMenuItem;
    TPPaletteArray: TMenuItem;
    TPPaletteCommands: TMenuItem;
    GWPaletteData: TMenuItem;
    GWPaletteCommands: TMenuItem;
    QBPaletteData: TMenuItem;
    QBPaletteCommands: TMenuItem;
    TPPutImageArray: TMenuItem;
    FPPutImageArray: TMenuItem;
    TCPutImageArray: TMenuItem;
    QCPutImageArray: TMenuItem;
    TPPutImageFile: TMenuItem;
    GWPutFile: TMenuItem;
    FBPutFile: TMenuItem;
    FPPutImageFile: TMenuItem;
    AmigaPascal: TMenuItem;
    TCPutImageFile: TMenuItem;
    QCPutImageFile: TMenuItem;
    AmigaC: TMenuItem;
    CBOBBitmapArray: TMenuItem;
    CVSpriteBitmapArray: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    APVSpriteColorArray: TMenuItem;
    APPaletteArray: TMenuItem;
    APRGB4PaletteArray: TMenuItem;
    ACRGB4PaletteArray: TMenuItem;
    ABPutData: TMenuItem;
    ABBobData: TMenuItem;
    ABVSpriteData: TMenuItem;
    ABPutFile: TMenuItem;
    ABBobFile: TMenuItem;
    ABVSpriteFile: TMenuItem;
    ABPaletteData: TMenuItem;
    ABPaletteCommands: TMenuItem;
    GWPutData: TMenuItem;
    FBPutData: TMenuItem;
    TBPutData: TMenuItem;
    TBPutFile: TMenuItem;
    QBPutData: TMenuItem;
    QBPutFile: TMenuItem;
    PascalBOBBitmapArray: TMenuItem;
    PascalVSpriteBitmapArray: TMenuItem;
    TransparentImage: TMenuItem;
    NonTransparentImage: TMenuItem;
    SaveDelete: TMenuItem;
    Panel2: TPanel;
    ToolEllipseMenu: TMenuItem;
    ToolFEllipseMenu: TMenuItem;
    PaletteExportQuickC: TMenuItem;
    PaletteExportGWBasic: TMenuItem;
    PaletteExportTurboC: TMenuItem;
    PaletteExportTurboPascal: TMenuItem;
    PaletteExportAmigaBasic: TMenuItem;
    PaletteExportQBasic: TMenuItem;
    PaletteExport: TMenuItem;
    PaletteOpen: TMenuItem;
    PaletteSave: TMenuItem;
    PaletteAmiga2: TMenuItem;
    PaletteAmiga4: TMenuItem;
    PaletteAmiga8: TMenuItem;
    PaletteAmiga16: TMenuItem;
    PaletteAmiga32: TMenuItem;
    PaletteAmiga: TMenuItem;
    ExportDialog: TSaveDialog;
    ToolEllipseIcon: TImage;
    ToolFEllipseIcon: TImage;
    TurboBasic: TMenuItem;
    QuickC: TMenuItem;
    TurboC: TMenuItem;
    RMLogo: TImage;
    RMPanel: TPanel;
    TurboPascal: TMenuItem;
    QuickBasic: TMenuItem;
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
    procedure AmigaBasicClick(Sender: TObject);
    procedure AmigaCClick(Sender: TObject);
    procedure AmigaCPaletteClick(Sender: TObject);
    procedure AmigaPascalClick(Sender: TObject);
    procedure AmigaPascalPaletteClick(Sender: TObject);


//    procedure ColorBox1Change(Sender: TObject);
    procedure ColorBoxMouseEnter(Sender: TObject);
    procedure ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure ColorPalette1GetHintText(Sender: TObject; AColor: TColor;
      var AText: String);
    procedure EditClearClick(Sender: TObject);
    procedure EditCopyClick(Sender: TObject);
    procedure EditPasteClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FreeBASICClick(Sender: TObject);
    procedure FreePascalClick(Sender: TObject);
    procedure GWBASICClick(Sender: TObject);
    procedure EditResizeToNewSize(Sender: TObject);
    procedure javaScriptArrayClick(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure PaletteEditColors(Sender: TObject);
    procedure SaveDeleteClick(Sender: TObject);
    procedure ToolEllipseMenuClick(Sender: TObject);
    procedure PaletteExportQuickCClick(Sender: TObject);
    procedure PaletteExportTurboCClick(Sender: TObject);
    procedure PaletteExportAmigaBasicClick(Sender: TObject);
    procedure PaletteExportGWBasicClick(Sender: TObject);
    procedure PaletteExportTurboPascalClick(Sender: TObject);
    procedure PaletteOpenClick(Sender: TObject);
    procedure PaletteSaveClick(Sender: TObject);
    procedure PaletteAmiga16Click(Sender: TObject);
    procedure PaletteAmiga2Click(Sender: TObject);
    procedure PaletteAmiga32Click(Sender: TObject);
    procedure PaletteAmiga4Click(Sender: TObject);
    procedure PaletteAmiga8Click(Sender: TObject);
    procedure PaletteExportQBasicClick(Sender: TObject);
    procedure QuickCClick(Sender: TObject);
    procedure RMAboutDialogClick(Sender: TObject);
    procedure QBasicDataClick(Sender: TObject);
    procedure NewClick(Sender: TObject);
    procedure RMLogoClick(Sender: TObject);
    procedure ToolFEllipseMenuClick(Sender: TObject);
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
    procedure PaletteVGAClick(Sender: TObject);
    procedure PaletteVGA256Click(Sender: TObject);
    procedure PaletteEGAClick(Sender: TObject);
    procedure PencilDrawChange(Sender: TObject);
    procedure ColorBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ToolRectangleMenuClick(Sender: TObject);
    procedure ToolScrollDownMenuClick(Sender: TObject);
    procedure ToolScrollLeftMenuClick(Sender: TObject);
    procedure ToolScrollRightMenuClick(Sender: TObject);
    procedure ToolScrollUpMenuClick(Sender: TObject);
    procedure ToolUndoIconClick(Sender: TObject);
    procedure TurboPowerBasicClick(Sender: TObject);
    procedure TurboCClick(Sender: TObject);
    procedure TurboPascalClick(Sender: TObject);
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
    procedure TrackBar1Change(Sender: TObject);
  private
       FX,FY,FX2,FY2 : Integer;
       ZoomX,ZoomY : integer;
       ZoomSize : Integer;
       DrawMode : Boolean;
       DrawFirst : Boolean;
       MaxXOffset : Integer;
       MaxYOffset : Integer;
       XOffset    : Integer;
       YOffset    : Integer;



       procedure UpdateZoomArea;
        procedure UpdateActualArea;
       procedure LoadDefaultPalette;
       procedure UpdatePalette;
       procedure UpdateColorBox;
       procedure UpdateInfoBarXY;
       procedure UpdateInfoBarDetail;
       procedure UpdateThumbview;

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
       procedure GetOpenSaveRegion(var x,y,x2,y2 : integer);  //if we are in select/clip area use those coords
       procedure EditColors;
       procedure Clear;
       procedure InitThumbView;
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

procedure TRMMainForm.FormCreate(Sender: TObject);
begin
ZoomSize:=RMDrawTools.GetZoomMode;
DrawMode:=False;
DrawFirst:=False;
ActualBox.Canvas.Brush.Style := bsSolid;
ActualBox.Canvas.Brush.Color := clblack;
ActualBox.Canvas.FillRect(0,0,256,256);

ZoomBox.Canvas.Brush.Style := bsSolid;
ZoomBox.Canvas.Brush.Color := clwhite;


RMDrawTools.SetZoomMaxX(ZoomBox.Width);
RMDrawTools.SetZoomMaxY(ZoomBox.Height);

RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
LoadResourceIcons;
//check MaxImagePixel
MaxXOffset:=RMDrawTools.GetMaxXOffset(RMCoreBase.GetWidth,ZoomBox.Width);
HorizScroll.Max:=MaxXOffset;
MaxYOffset:=RMDrawTools.GetMaxYOffset(RMCoreBase.GetHeight,ZoomBox.Height);
VirtScroll.Max:=MaxYOffset;

XOffset:=0;
YOffset:=0;
Trackbar1.Position:=RMDrawTools.getZoomSize;

//SetPaletteMode(PaletteModeVGA);
RMCoreBase.Palette.SetPaletteMode(PaletteModeVGA);
LoadDefaultPalette;

ColorBox.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor];
ColorPalette1.PickedIndex:=RMCoreBase.GetCurColor;

RMDrawTools.SetDrawTool(DrawShapePencil);
ClearSelectedToolsMenu;
PaletteVGA.Checked:=true; // set vga palette
HideSelectAreaTools;
UpdateToolSelectionIcons;
ToolPencilMenu.Checked:=true; //enable pencil tool in menu
InitThumbView;
end;

procedure TRMMainForm.RMAboutDialogClick(Sender: TObject);
begin
 Aboutdialog.InitName;
 AboutDialog.ShowModal;
end;



procedure TRMMainForm.RMLogoClick(Sender: TObject);
begin
    OpenUrl('https://www.youtube.com/channel/UCLak9dN2fgKU9keY2XEBRFQ');
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
  UpdateThumbview;
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
  UpdateThumbview;

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
  UpdateThumbview;

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
  UpdateThumbview;

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
  UpdateThumbview;

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
  UpdateThumbview;

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
  UpdateThumbview;
  RMDrawTools.SetClipStatus(clipstatus);
  if clipstatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
  end;
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

procedure TRMMainForm.ToolEllipseMenuClick(Sender: TObject);
begin
 ClearClipAreaOutline;
 UnFreezeScrollAndZoom;
 ClearSelectedToolsMenu;
 HideSelectAreaTools;
 RMDrawTools.SetDrawTool(DrawShapeEllipse);
 UpdateToolSelectionIcons;
 ToolEllipseMenu.Checked:=true;
end;

procedure TRMMainForm.ToolFEllipseMenuClick(Sender: TObject);
begin
 ClearClipAreaOutline;
 UnFreezeScrollAndZoom;
 ClearSelectedToolsMenu;
 HideSelectAreaTools;
 RMDrawTools.SetDrawTool(DrawShapeFEllipse);
 UpdateToolSelectionIcons;
 ToolFEllipseMenu.Checked:=true;
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
//  SetPaletteMode(PaletteModeMono);
  RMCoreBase.Palette.SetPaletteMode(PaletteModeMono);

  LoadDefaultPalette;

  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
//  RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  if RMDrawTools.GetClipStatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
  end;
end;

procedure TRMMainForm.PaletteCGA0Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteCGA0.Checked:=true;
//  SetPaletteMode(PaletteModeCGA0);
  RMCoreBase.Palette.SetPaletteMode(PaletteModeCGA0);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
//  RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  if RMDrawTools.GetClipStatus = 1 then
  begin
     RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
  end;
end;

procedure TRMMainForm.PaletteCGA1Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteCGA1.Checked:=true;
//  SetPaletteMode(PaletteModeCGA1);
  RMCoreBase.Palette.SetPaletteMode(PaletteModeCGA1);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
  //RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  if RMDrawTools.GetClipStatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
  end;
end;


procedure TRMMainForm.PaletteAmiga2Click(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteAmiga.Checked:=true;
 PaletteAmiga2.Checked:=true;
 //SetPaletteMode(PaletteModeAmiga2);
  RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga2);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
// RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
 UpdateZoomArea;
 UpdateThumbview;
 if RMDrawTools.GetClipStatus = 1 then
 begin
   RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
 end;
end;



procedure TRMMainForm.PaletteAmiga4Click(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteAmiga.Checked:=true;
 PaletteAmiga4.Checked:=true;
// SetPaletteMode(PaletteModeAmiga4);
 RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga4);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
// RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
 UpdateZoomArea;
 UpdateThumbview;
 if RMDrawTools.GetClipStatus = 1 then
 begin
   RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
 end;
end;

procedure TRMMainForm.PaletteAmiga8Click(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteAmiga.Checked:=true;
 PaletteAmiga8.Checked:=true;
// SetPaletteMode(PaletteModeAmiga8);
 RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga8);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
// RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
 UpdateZoomArea;
 UpdateThumbview;
 if RMDrawTools.GetClipStatus = 1 then
 begin
   RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
 end;
end;

procedure TRMMainForm.PaletteAmiga16Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteAmiga.Checked:=true;
  PaletteAmiga16.Checked:=true;
//  SetPaletteMode(PaletteModeAmiga16);
  RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga16);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
//  RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  UpdateZoomArea;
  UpdateThumbview;
 if RMDrawTools.GetClipStatus = 1 then
  begin
   RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
  end;
end;

procedure TRMMainForm.PaletteAmiga32Click(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteAmiga.Checked:=true;
 PaletteAmiga32.Checked:=true;
// SetPaletteMode(PaletteModeAmiga32);
 RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga32);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
// RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
 UpdateZoomArea;
 UpdateThumbview;
 if RMDrawTools.GetClipStatus = 1 then
 begin
   RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
 end;
end;


procedure TRMMainForm.ClearSelectedPaletteMenu;
begin
  PaletteMono.Checked:=false;
  PaletteCGA0.Checked:=false;
  PaletteCGA1.Checked:=false;
  PaletteEGA.Checked:=false;
  PaletteVGA.Checked:=false;
  PaletteVGA256.Checked:=false;
  PaletteAmiga.Checked:=false;
  PaletteAmiga2.Checked:=false;
  PaletteAmiga4.Checked:=false;
  PaletteAmiga8.Checked:=false;
  PaletteAmiga16.Checked:=false;
  PaletteAmiga32.Checked:=false;
end;

procedure TRMMainForm.PaletteVGAClick(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteVGA.Checked:=true;
//  SetPaletteMode(PaletteModeVGA);
  RMCoreBase.Palette.SetPaletteMode(PaletteModeVGA);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
 // RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  UpdateZoomArea;
  UpdateThumbview;
  if RMDrawTools.GetClipStatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
  end;
end;

procedure TRMMainForm.PaletteVGA256Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteVGA256.Checked:=true;
//  SetPaletteMode(PaletteModeVGA256);
  RMCoreBase.Palette.SetPaletteMode(PaletteModeVGA256);
  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
 // RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  UpdateZoomArea;
  UpdateThumbview;
  if RMDrawTools.GetClipStatus = 1 then
  begin
    RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
  end;
end;

procedure TRMMainForm.PaletteEGAClick(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteEGA.Checked:=true;
//  SetPaletteMode(PaletteModeEGA);
  RMCoreBase.Palette.SetPaletteMode(PaletteModeEGA);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
 // RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  UpdateZoomArea;
  UpdateThumbview;
  if RMDrawTools.GetClipStatus = 1 then
  begin
   RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
  end;
end;

procedure TRMMainForm.PencilDrawChange(Sender: TObject);
begin
  RMDrawTools.SetDrawTool(DrawShapePencil);
end;

procedure TRMMainForm.ColorBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  EditColors;
end;

procedure TRMMainForm.FreezeScrollAndZoom;
begin
   VirtScroll.Enabled:=false;
   HorizScroll.Enabled:=false;
   TrackBar1.Enabled:=false;
   EditResizeTo.Enabled:=false;
end;

procedure TRMMainForm.UnFreezeScrollAndZoom;
begin
  VirtScroll.Enabled:=true;
  HorizScroll.Enabled:=true;
  TrackBar1.Enabled:=true;
  EditResizeTo.Enabled:=true;
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
  ColIndexStr : string;
  ca      : TClipAreaRec;
begin
 XYStr:='Zoom X = '+IntToStr(ZoomX)+' Zoom Y = '+IntToStr(ZoomY)+#13#10+
        'X = '+IntToStr(ZoomX+XOffset)+' Y = '+IntToStr(ZoomY + YOffset)+#13#10;
 ColIndexStr:='';
 if (zoomX >= 0) and (zoomy >= 0) then
 begin
   ColIndexStr:='Color Index: '+IntToStr(RMCoreBase.GetPixel(xoffset+ZoomX,yoffset+ZoomY))
 end;
 ClipStr:='';
 if RMDrawTools.GetClipStatus = 1 then
 begin
      RMDrawTools.GetClipAreaCoords(ca);
      ClipStr:='Select Area '+'X = '+IntToStr(ca.x)+' Y = '+IntToStr(ca.y)+' X2 = '+IntToStr(ca.x2)+' Y2 = '+IntToStr(ca.y2)+#13#10+
               'Width = '+IntToStr(ca.x2-ca.x+1)+' Height = '+IntToStr(ca.y2-ca.y+1)+#13#10;
 end;
 InfoBarLabel.Caption:=XYStr+ClipStr+ColIndexStr;
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
   //check MaxImagePixel
   for i:=0 to RMCoreBase.GetWidth -1 do
   begin
     for j:=0 to RMCoreBase.GetHeight-1 do
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
clipstatus : integer;
begin
   xoff:=HorizScroll.Position;
   yoff:=VirtScroll.Position;

   w:=RMDrawTools.GetCellsPerRow(ZoomBox.Width);
   h:=RMDrawTools.GetCellsPerCol(ZoomBox.Height);

   clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea

   for i:=0 to w do
   begin
     for j:=0 to h do
     begin
        tc:=ColorPalette1.Colors[RMCoreBase.GetPixel(xoff+i,yoff+j)];
        RMDrawTools.PutPixel(ZoomBox.Canvas,i,j,tc,0);
     end;
   end;

   if ClipStatus = 1 then
   begin
      RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.Brush.color,1);
   end;

end;

procedure TRMMainForm.UpdateColorBox;
begin
  ColorBox.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor];
  ColorPalette1.PickedIndex:=RMCoreBase.GetCurColor;
end;

procedure TRMMainForm.LoadDefaultPalette;
var
pm : integer;
begin
//  pm:=GetPaletteMode;
 pm:=RMCoreBase.Palette.GetPaletteMode;

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
  end
  else if pm = PaletteModeAmiga32 then
   begin
    RMDrawTools.AddAmigaPalette(ColorPalette1,32);
    ColorPalette1.ColumnCount:=16;
    ColorPalette1.ButtonHeight:=25;
    ColorPalette1.ButtonWidth:=30;
    PaletteToCore;
   end
   else if pm = PaletteModeAmiga16 then
   begin
    RMDrawTools.AddAmigaPalette(ColorPalette1,16);
    ColorPalette1.ColumnCount:=8;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
    PaletteToCore;
   end
   else if pm = PaletteModeAmiga8 then
    begin
     RMDrawTools.AddAmigaPalette(ColorPalette1,8);
     ColorPalette1.ColumnCount:=4;
     ColorPalette1.ButtonHeight:=50;
     ColorPalette1.ButtonWidth:=30;
     PaletteToCore;
    end
   else if pm = PaletteModeAmiga4 then
   begin
    RMDrawTools.AddAmigaPalette(ColorPalette1,4);
    ColorPalette1.ColumnCount:=2;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
    PaletteToCore;
   end
   else if pm = PaletteModeAmiga2 then
   begin
    RMDrawTools.AddAmigaPalette(ColorPalette1,2);
    ColorPalette1.ColumnCount:=1;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
    PaletteToCore;
   end;
end;

procedure TRMMainForm.UpdatePalette;
var
pm : integer;
begin
//  pm:=GetPaletteMode;
 pm:=RMCoreBase.Palette.GetPaletteMode;

  if pm = PaletteModeVGA256 then
  begin
//    RMDrawTools.AddVGAPalette256(ColorPalette1);
    ColorPalette1.ColumnCount:=32;
    ColorPalette1.ButtonHeight:=17;
    ColorPalette1.ButtonWidth:=17;
  //  PaletteToCore;
  end
  else if pm = PaletteModeVGA then
  begin
//    RMDrawTools.AddVGAPalette(ColorPalette1);       //Add to Visual Compononet Palette
    ColorPalette1.ColumnCount:=8;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
 //   PaletteToCore;  //copy valaues from Component pallete to internal core palette
  end
  else if pm = PaletteModeEGA then
  begin
//   RMDrawTools.AddEGAPalette(ColorPalette1);
   ColorPalette1.ColumnCount:=8;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
//   PaletteToCore;
  end
  else if pm = PaletteModeCGA0 then
  begin
//   RMDrawTools.AddCGAPalette0(ColorPalette1);
   ColorPalette1.ColumnCount:=2;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
//   PaletteToCore;
  end
  else if pm = PaletteModeCGA1 then
  begin
//   RMDrawTools.AddCGAPalette1(ColorPalette1);
   ColorPalette1.ColumnCount:=2;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
//   PaletteToCore;
  end
  else if pm = PaletteModeMono then
  begin
  // RMDrawTools.AddMonoPalette(ColorPalette1);
   ColorPalette1.ColumnCount:=1;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
//   PaletteToCore;
  end
  else if pm = PaletteModeAmiga32 then
   begin
  //  RMDrawTools.AddAmigaPalette(ColorPalette1,32);
    ColorPalette1.ColumnCount:=16;
    ColorPalette1.ButtonHeight:=25;
    ColorPalette1.ButtonWidth:=30;
 //   PaletteToCore;
   end
   else if pm = PaletteModeAmiga16 then
   begin
//    RMDrawTools.AddAmigaPalette(ColorPalette1,16);
    ColorPalette1.ColumnCount:=8;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
//    PaletteToCore;
   end
   else if pm = PaletteModeAmiga8 then
    begin
  //   RMDrawTools.AddAmigaPalette(ColorPalette1,8);
     ColorPalette1.ColumnCount:=4;
     ColorPalette1.ButtonHeight:=50;
     ColorPalette1.ButtonWidth:=30;
 //    PaletteToCore;
    end
   else if pm = PaletteModeAmiga4 then
   begin
//    RMDrawTools.AddAmigaPalette(ColorPalette1,4);
    ColorPalette1.ColumnCount:=2;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
  //  PaletteToCore;
   end
   else if pm = PaletteModeAmiga2 then
   begin
 //   RMDrawTools.AddAmigaPalette(ColorPalette1,2);
    ColorPalette1.ColumnCount:=1;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
 //   PaletteToCore;
   end;
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
     //check MaxImagePixel
    MaxXOffset:=RMDrawTools.GetMaxXOffset(RMCoreBase.GetWidth,ZoomBox.Width);
    HorizScroll.Max:=MaxXOffset;
    MaxYOffset:=RMDrawTools.GetMaxYOffset(RMCoreBase.GetHeight,ZoomBox.Height);
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



procedure TRMMainForm.ColorBoxMouseEnter(Sender: TObject);
begin
//  ColorBox.Hint:='Color Index: '+IntToStr(RMCoreBase.GetCurColor);
 ColorBox.Hint:=ColIndexToHoverInfo(RMCoreBase.GetCurColor,RMCoreBase.Palette.GetPaletteMode);
end;


procedure TRMMainForm.ColorPalette1GetHintText(Sender: TObject; AColor: TColor;
  var AText: String);
begin
//  AText:='Color Index: '+IntToStr(ColorPalette1.MouseIndex);
  if ColorPalette1.MouseIndex > -1 then
  begin
    AText:=ColIndexToHoverInfo(ColorPalette1.MouseIndex,RMCoreBase.Palette.GetPaletteMode);
  end
  else
  begin
    AText:='Color Index: '+IntToStr(ColorPalette1.MouseIndex);
  end;
end;



procedure TRMMainForm.ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
  ColorBox.Brush.Color:= AColor;
  RMCoreBase.SetCurColor(ColorPalette1.PickedIndex);
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
   UpdateThumbView;
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
//    if fx2 > (_MaxImagePixelWidth-1) then fx2:=_MaxImagePixelWidth-1;
//    if fy2 > (_MaxImagePixelHeight-1) then fy2:=_MaxImagePixelHeight-1;
    if fx2 > (RMDrawTools.GetZoomMaxX)-1 then fx2:=RMDrawTools.GetZoomMaxX-1;

    if fy2 > (RMDrawTools.GetZoomMaxY)-1 then fy2:=RMDrawTools.GetZoomMaxY-1;


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
    UpdateThumbView;
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

   RMDrawTools.SetZoomSize(ZoomSize);
   RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
   //check MaxImagePixel
   MaxXOffset:=RMDrawTools.GetMaxXOffset(RMCoreBase.GetWidth,ZoomBox.Width);
   HorizScroll.Max:=MaxXOffset;
   MaxYOffset:=RMDrawTools.GetMaxYOffset(RMCoreBase.GetHeight,ZoomBox.Height);
   VirtScroll.Max:=MaxYOffset;
   TrackBar1.Position:=RMDrawTools.GetZoomSize;
   UpdateZoomArea;
end;

procedure TRMMainForm.ToolCircleIconClick(Sender: TObject);
begin
  ToolCircleIcon.Picture.LoadFromResourceName(HInstance,'CIRCLE_BLACK');
end;

procedure TRMMainForm.FileExitMenuClick(Sender: TObject);
begin
   Close;
end;

procedure TRMMainForm.HorizScrollChange(Sender: TObject);
begin
  XOffset:=HorizScroll.Position;
  updatezoomarea;
end;

procedure TRMMainForm.TrackBar1Change(Sender: TObject);
begin
  //Label4.Caption := 'Position = '+IntToStr(TrackBar1.Position);
  RMDrawTools.SetZoomSize(TrackBar1.Position);
  RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  //check MaxImagePixel

  RMDrawTools.SetZoomMaxX(ZoomBox.Width);
  RMDrawTools.SetZoomMaxY(ZoomBox.Height);

  MaxXOffset:=RMDrawTools.GetMaxXOffset(RMCoreBase.GetWidth,ZoomBox.Width);
  HorizScroll.Max:=MaxXOffset;
  MaxYOffset:=RMDrawTools.GetMaxYOffset(RMCoreBase.GetHeight,ZoomBox.Height);
  VirtScroll.Max:=MaxYOffset;
  ZoomSize:=RMDrawTools.GetZoomSize;
  UpdateZoomArea;
end;

procedure TRMMainForm.ClearSelectedToolsMenu;
begin
     ToolFRectangleMenu.Checked:=false;
     ToolRectangleMenu.Checked:=false;
     ToolLineMenu.Checked:=false;
     ToolSelectAreaMenu.Checked:=false;

     ToolMenuSprayPaint.Checked:=false;
     ToolMenuPaint.Checked:=false;
     ToolCircleMenu.Checked:=false;
     ToolFCircleMenu.Checked:=false;
     ToolEllipseMenu.Checked:=false;
     ToolFEllipseMenu.Checked:=false;

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

  ToolEllipseIcon.Picture.LoadFromResourceName(HInstance,'ELLIP1');
  ToolFEllipseIcon.Picture.LoadFromResourceName(HInstance,'FELLIP1');

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
  ToolEllipseIcon.Picture.LoadFromResourceName(HInstance,'ELLIP1');
  ToolFEllipseIcon.Picture.LoadFromResourceName(HInstance,'FELLIP1');
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
           DrawShapeEllipse:ToolEllipseIcon.Picture.LoadFromResourceName(HInstance,'ELLIP2');
          DrawShapeFEllipse:ToolFEllipseIcon.Picture.LoadFromResourceName(HInstance,'FELLIP2');
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


procedure TRMMainForm.GetOpenSaveRegion(var x,y,x2,y2 : integer);
var
  ca   : TClipAreaRec;
begin
   x:=0;
   y:=0;
   x2:=RMCoreBase.GetWidth-1;
   y2:=RMCoreBase.GetHeight-1;

   if RMDrawTools.GetClipStatus = 1 then
   begin
     RMDrawTools.GetClipAreaCoords(ca);
     x:=ca.x+XOffset;
     y:=ca.y+Yoffset;
     x2:=ca.x2+XOffset;
     y2:=ca.y2+YOffset;
   end;
end;

procedure TRMMainForm.SaveFileClick(Sender: TObject);
var
 ext : string;
 x,y,x2,y2 : integer;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   SaveDialog1.Filter := 'Windows BMP|*.bmp|PC Paintbrush |*.pcx|RM RAW Files|*.raw|All Files|*.*';
   if SaveDialog1.Execute then
   begin
      ext:=UpperCase(ExtractFileExt(SaveDialog1.Filename));
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
      end
      else if ext = '.RAW' then
      begin
        if WriteRAW(x,y,x2,y2,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving RAW file!');
        end;
      end;
   end;
end;

procedure TRMMainForm.OpenFileClick(Sender: TObject);
var
 ext : string;
 x,y,x2,y2 : integer;
 lp   : integer;
 pm   : integer;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   lp:=1;
//   pm:=GetPaletteMode;
    pm:=RMCoreBase.Palette.GetPaletteMode;

   if RMDrawTools.GetClipStatus = 1 then lp:=0;
   OpenDialog1.Filter := 'Windows BMP|*.bmp|PC Paintbrush |*.pcx|RM RAW Files|*.raw|All Files|*.*' ;

   if OpenDialog1.Execute then
   begin
      ext:=UpperCase(ExtractFileExt(OpenDialog1.FileName));
      if ext = '.PCX' then
      begin
         if ReadPcxImg(x,y,x2,y2,lp,pm,OpenDialog1.FileName) <> 0 then
         begin
           ShowMessage('Error Opening PCX file!');
           exit;
         end;
      end
      else if ext = '.BMP' then
      begin
        if ReadBMP(x,y,x2,y2,lp,pm,OpenDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Opening BMP file!');
          exit;
        end;
      end
      else if ext = '.RAW' then
      begin
        if ReadRAW(x,y,x2,y2,lp,pm,OpenDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Opening RAW file!');
          exit;
        end;
      end;
      if lp = 1 then CoreToPalette;
      UpdateActualArea;
      UpdateColorBox;
      UpDateZoomArea;
      UpdateThumbView;
      if RMDrawTools.GetClipStatus = 1 then
      begin
        RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
      end;
   end;
end;


procedure TRMMainForm.PaletteExportQBasicClick(Sender: TObject);
var
 pm : integer;
 ColorFormat : integer;
 error : word;
begin
   Case (Sender As TMenuItem).Name of 'QBPaletteData' : ExportDialog.Filter := 'QuickBasic\QB64 Palette Data|*.bas';
                                    'QBPaletteCommands' : ExportDialog.Filter :='QuickBasic\QB64 Palette Commands|*.bas';
   end;

   if ExportDialog.Execute then
   begin
      pm:=RMCoreBase.Palette.GetPaletteMode;

      ColorFormat:=ColorSixBitFormat;
      if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

      Case (Sender As TMenuItem).Name of 'QBPaletteData' : error:=WritePalData(ExportDialog.FileName,QBLan,ColorFormat);
                                     'QBPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,QBLan,ColorFormat);
      end;

      if error<>0 then
      begin
         ShowMessage('Error Saving Palette file!');
         exit;
      end;
   end;
end;

procedure TRMMainForm.QBasicDataClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 sourcemode : word;
 error : word;
 begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'QBPutData' :ExportDialog.Filter := 'QuickBasic\QB64 Put Data Statements|*.bas';
                                      'QBPutFile' : ExportDialog.Filter := 'QuickBasic\QB64 Put File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      sourcemode:=source256;  //PaletteModeVGA256 - this will still work if we are in amiga palette modes
      pm:=RMCoreBase.Palette.GetPaletteMode;
      case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
      end;

      Case (Sender As TMenuItem).Name of 'QBPutData' : error:=WriteDat(x,y,x2,y2,sourcemode,QBLan,ExportDialog.FileName);
                                         'QBPutFile' : error:=WriteXGF(x,y,x2,y2,QBLan,ExportDialog.FileName);
      End;

      if (error<>0) then
      begin
         ShowMessage('Error Saving file!');
         exit;
      end;
   end;
 end;

procedure TRMMainForm.TurboPascalClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 sourcemode : word;
 error : word;
begin
  GetOpenSaveRegion(x,y,x2,y2);
  Case (Sender As TMenuItem).Name of 'TPPutImageArray' :ExportDialog.Filter := 'Turbo Pascal PutImage Array|*.pas';
                                        'TPPutImageFile' : ExportDialog.Filter := 'Turbo Pascal PutImage File|*.xgf';
  End;
  if ExportDialog.Execute then
   begin
      sourcemode:=source256;  //PaletteModeVGA256 - this will still work if we are in amiga palette modes
      pm:=RMCoreBase.Palette.GetPaletteMode;
      case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
      end;

      Case (Sender As TMenuItem).Name of 'TPPutImageArray' : error:=WriteDat(x,y,x2,y2,SourceMode,TPLan,ExportDialog.FileName);
                                          'TPPutImageFile' : error:=WriteXGF(x,y,x2,y2,TPLan,ExportDialog.FileName);

      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.FreePascalClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 sourcemode : word;
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'FPPutImageArray' :ExportDialog.Filter := 'FreePascal PutImage Array|*.pas';
                                      'FPPutImageFile' : ExportDialog.Filter := 'FreePascal PutImage File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      sourcemode:=source256;  //PaletteModeVGA256 - this will still work if we are in amiga palette modes
      pm:=RMCoreBase.Palette.GetPaletteMode;
      case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
      end;

      Case (Sender As TMenuItem).Name of 'FPPutImageArray' : error:=WriteDat(x,y,x2,y2,SourceMode,FPLan,ExportDialog.FileName);
                                         'FPPutImageFile'  : error:=WriteXGF(x,y,x2,y2,FPLan,ExportDialog.FileName);
      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.GWBASICClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 sourcemode : word;
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'GWPutData' :ExportDialog.Filter := 'GWBASIC Put Data Statements|*.bas';
                                      'GWPutFile' : ExportDialog.Filter := 'GWBASIC Put File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      sourcemode:=source256;  //PaletteModeVGA256 - this will still work if we are in amiga palette modes
      pm:=RMCoreBase.Palette.GetPaletteMode;
      case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
      end;
      Case (Sender As TMenuItem).Name of 'GWPutData' : error:=WriteDat(x,y,x2,y2,SourceMode,GWLan,ExportDialog.FileName);
                                         'GWPutFile' : error:=WriteXGF(x,y,x2,y2,GWLan,ExportDialog.FileName);
      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.EditResizeToNewSize(Sender: TObject);
var
 ImgWidth,ImgHeight : integer;
begin
  if (Sender As TMenuItem).Name = 'EditResizeTo8' then
  begin
    ImgWidth:=8;
    ImgHeight:=8;
  end
  else if (Sender As TMenuItem).Name = 'EditResizeTo16' then
  begin
    ImgWidth:=16;
    ImgHeight:=16;
  end
  else if (Sender As TMenuItem).Name = 'EditResizeTo32' then
  begin
    ImgWidth:=32;
    ImgHeight:=32;
  end
  else if (Sender As TMenuItem).Name = 'EditResizeTo64' then
  begin
    ImgWidth:=64;
    ImgHeight:=64;
  end
  else if (Sender As TMenuItem).Name = 'EditResizeTo128' then
  begin
    ImgWidth:=128;
    ImgHeight:=128;
  end
  else if (Sender As TMenuItem).Name = 'EditResizeTo256' then
  begin
    ImgWidth:=256;
    ImgHeight:=256;
  end;
  ActualBox.Width:=ImgWidth;
  ActualBox.Height:=ImgHeight;
  RMCoreBase.SetWidth(ImgWidth);
  RMCoreBase.SetHeight(ImgHeight);


  // ZoomBox.Canvas.Brush.Style := bsSolid;
  // ZoomBox.Canvas.Brush.Color := clGray;
  //  ZoomBox.Canvas.FillRect(0,0,ZoomBox.Width,ZoomBox.Height);


  RMDrawTools.SetZoomSize(1);
  RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
  //check MaxImagePixel

  RMDrawTools.SetZoomMaxX(ZoomBox.Width);
  RMDrawTools.SetZoomMaxY(ZoomBox.Height);

  MaxXOffset:=RMDrawTools.GetMaxXOffset(RMCoreBase.GetWidth,ZoomBox.Width);
  HorizScroll.Max:=MaxXOffset;
  MaxYOffset:=RMDrawTools.GetMaxYOffset(RMCoreBase.GetHeight,ZoomBox.Height);
  VirtScroll.Max:=MaxYOffset;
  ZoomSize:=RMDrawTools.GetZoomSize;

  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbView;
end;

procedure TRMMainForm.javaScriptArrayClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 error : word;
 transparent : boolean;
 begin
   ExportDialog.Filter := 'JavaScript Transparent Image Array|*.js';
   transparent:=true;
   if (Sender As TMenuItem).Name = 'NonTransparentImage' then
   begin
      transparent:=false;
      ExportDialog.Filter := 'JavaScript Non Transparent Array|*.js';
   end;

   GetOpenSaveRegion(x,y,x2,y2);
   if ExportDialog.Execute then
   begin
      error:=WriteJavaScriptArray(x,y,x2,y2,ExportDialog.FileName,transparent);
      if (error<>0) then
      begin
         ShowMessage('Error Saving file!');
         exit;
      end;
   end;
end;

Procedure TRMMainForm.EditColors;
var
  PI : integer;
  cr : TRMColorRec;
  ci : integer;
  pm : integer;
begin
   pm:=RMCoreBase.Palette.GetPaletteMode;
   If (pm = PaletteModeVGA) OR (pm = PaletteModeVGA256) then
   begin
    if pm = PaletteModeVGA then RMVGAColorDialog.InitColorBox16
    else RMVGAColorDialog.InitColorBox256;

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
       UpdateThumbview;

       if RMDrawTools.GetClipStatus = 1 then
       begin
         RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
       end;
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
          UpdateThumbview;
           if RMDrawTools.GetClipStatus = 1 then
           begin
              RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
           end;
       end;
     end;
  end
  else if (pm >= PaletteModeAmiga2) AND (pm <= PaletteModeAmiga32) then
  begin
    case pm of PaletteModeAmiga2:RMAmigaColorDialog.InitColorBox2;
               PaletteModeAmiga4:RMAmigaColorDialog.InitColorBox4;
               PaletteModeAmiga8:RMAmigaColorDialog.InitColorBox8;
               PaletteModeAmiga16:RMAmigaColorDialog.InitColorBox16;
               PaletteModeAmiga32:RMAmigaColorDialog.InitColorBox32
    end;

    if RMAmigaColorDialog.ShowModal = mrOK then
    begin
       PI:=RMAmigaColorDialog.GetPickedIndex;
       RMCoreBase.SetCurColor(PI);
       ColorPalette1.PickedIndex:=PI;

       ColorBox.Brush.Color:=RMAmigaColorDialog.GetPickedColor;
       RMAmigaColorDialog.PaletteToCore;
       CoreToPalette;
       UpdateActualArea;
       UpdateZoomArea;
       UpdateThumbview;
       if RMDrawTools.GetClipStatus = 1 then
       begin
         RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,0);
       end;
   end;
 end;
end;

procedure TRMMainForm.PaletteEditColors(Sender: TObject);
begin
  EditColors;
end;


procedure TRMMainForm.PaletteExportQuickCClick(Sender: TObject);
var
  pm : integer;
  ColorFormat : integer;
  error : word;
 begin
    Case (Sender As TMenuItem).Name of 'QCPaletteArray' : ExportDialog.Filter := 'QuickC Palette Array|*.c';
                                      'QCPaletteCommands' : ExportDialog.Filter :='QuickC Palette Commands|*.c';
    end;

    if ExportDialog.Execute then
    begin
       pm:=RMCoreBase.Palette.GetPaletteMode;
       ColorFormat:=ColorSixBitFormat;
       if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

       Case (Sender As TMenuItem).Name of 'QCPaletteArray' : error:=WritePalData(ExportDialog.FileName,QCLan,ColorFormat);
                                         'QCPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,QCLan,ColorFormat);
       end;

       if error<>0 then
       begin
         ShowMessage('Error Saving Palette file!');
         exit;
       end;
    end;
 end;

procedure TRMMainForm.PaletteExportTurboCClick(Sender: TObject);
  var
   pm : integer;
   ColorFormat : integer;
   error : word;
  begin
   Case (Sender As TMenuItem).Name of 'TCPaletteArray' : ExportDialog.Filter := 'Turbo C Palette Array|*.c';
                                         'TCPaletteCommands' : ExportDialog.Filter :='Turbo C Palette Commands|*.c';
   end;
     if ExportDialog.Execute then
     begin
        pm:=RMCoreBase.Palette.GetPaletteMode;
        ColorFormat:=ColorSixBitFormat;
        if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

        Case (Sender As TMenuItem).Name of 'TCPaletteArray' : error:=WritePalData(ExportDialog.FileName,TCLan,ColorFormat);
                                        'TCPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,TCLan,ColorFormat);

        end;

        if error<>0 then
        begin
           ShowMessage('Error Saving Palette file!');
           exit;
        end;
     end;
  end;

procedure TRMMainForm.QuickCClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 sourcemode : word;
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'QCPutImageArray' :ExportDialog.Filter := 'Quick C _putimage Array|*.c';
                                      'QCPutImageFile' : ExportDialog.Filter := 'Quick C _putimage File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      sourcemode:=source256;  //PaletteModeVGA256 - this will still work if we are in amiga palette modes
      pm:=RMCoreBase.Palette.GetPaletteMode;
      case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
      end;

      Case (Sender As TMenuItem).Name of 'QCPutImageArray' : error:=WriteDat(x,y,x2,y2,SourceMode,QCLan,ExportDialog.FileName);
                                         'QCPutImageFile'  : error:=WriteXGF(x,y,x2,y2,QCLan,ExportDialog.FileName);
      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.TurboCClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 sourcemode : word;
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'TCPutImageArray' :ExportDialog.Filter := 'Turbo C putimage Array|*.c';
                                       'TCPutImageFile' : ExportDialog.Filter := 'Turbo C putimage File|*.xgf';
   End;
   if ExportDialog.Execute then
   begin
      sourcemode:=source256;  //PaletteModeVGA256 - this will still work if we are in amiga palette modes
      pm:=RMCoreBase.Palette.GetPaletteMode;
      case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
      end;

      Case (Sender As TMenuItem).Name of 'TCPutImageArray' : error:=WriteDat(x,y,x2,y2,SourceMode,TCLan,ExportDialog.FileName);
                                          'TCPutImageFile' : error:=WriteXGF(x,y,x2,y2,TCLan,ExportDialog.FileName);
      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.TurboPowerBasicClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 sourcemode : word;
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'TBPutData' :ExportDialog.Filter := 'Turbo\Power Basic Data Statements|*.bas';
                                      'TBPutFile' : ExportDialog.Filter := 'Turbo\Power Basic Put File|*.xgf';
   End;


   if ExportDialog.Execute then
   begin
      sourcemode:=source256;  //PaletteModeVGA256 - this will still work if we are in amiga palette modes
      pm:=RMCoreBase.Palette.GetPaletteMode;
      case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
      end;

      Case (Sender As TMenuItem).Name of 'TBPutData' : error:=WriteDat(x,y,x2,y2,SourceMode,PBLan,ExportDialog.FileName);
                                      'TBPutFile' : WriteXGF(x,y,x2,y2,PBLan,ExportDialog.FileName);
      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.FreeBASICClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 sourcemode : word;
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'FBPutData' :ExportDialog.Filter := 'FreeBASIC Data Statements|*.bas';
                                      'FBPutFile' : ExportDialog.Filter := 'FreeBASIC Put File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      sourcemode:=source256;  //PaletteModeVGA256 - this will still work if we are in amiga palette modes
      pm:=RMCoreBase.Palette.GetPaletteMode;
      case pm of         PaletteModeMono:sourcemode:=Source2;
           PaletteModeCGA0,PaletteModeCGA1:sourcemode:=Source4;
             PaletteModeEGA,PaletteModeVGA:sourcemode:=Source16;
      end;

      Case (Sender As TMenuItem).Name of 'FBPutData' : error:=WriteDat(x,y,x2,y2,SourceMode,FBLan,ExportDialog.FileName);
                                         'FBPutFile' : error:=WriteXGF(x,y,x2,y2,FBLan,ExportDialog.FileName);
      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.AmigaBasicClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 error : word;
 validpm : boolean;
begin
   pm:=RMCoreBase.Palette.GetPaletteMode;
   validpm:=(pm=PaletteModeAmiga2) OR (pm=PaletteModeAmiga4) OR (pm=PaletteModeAmiga8) OR (pm=PaletteModeAmiga16) OR (pm=PaletteModeAmiga32);
   if validpm = false then
   begin
      ShowMessage('Invalid Palette Mode for this action. Choose an Amiga Palette Please');
      exit;
   end;

   Case (Sender As TMenuItem).Name of 'ABPutData' :ExportDialog.Filter := 'AmigaBASIC Data Statements|*.bas';
                                      'ABBobData' : ExportDialog.Filter := 'AmigaBASIC Bob Data Statements|*.bas';
                                      'ABVSpriteData' : ExportDialog.Filter := 'AmigaBASIC VSprite Data Statements|*.bas';
                                      'ABPutFile' : ExportDialog.Filter := 'AmigaBASIC Put File|*.xgf';
                                      'ABBobFile' : ExportDialog.Filter := 'AmigaBASIC Bob File|*.obj';
                                      'ABVSpriteFile' : ExportDialog.Filter := 'AmigaBASIC VSprite File|*.vsp';
   End;
   GetOpenSaveRegion(x,y,x2,y2);
   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'ABPutData' : error:=WriteAmigaBasicXGFData(x,y,x2,y2,ExportDialog.FileName);
                                         'ABBobData' : error:=WriteAmigaBasicObjectData(x,y,x2,y2,ExportDialog.FileName,false);
                                         'ABVSpriteData' : error:=WriteAmigaBasicObjectData(x,y,x2,y2,ExportDialog.FileName,true);
                                         'ABPutFile' :  error:=WriteAmigaBasicXGF(x,y,x2,y2,ExportDialog.FileName);
                                         'ABBobFile' : error:=WriteAmigaBasicObject(x,y,x2,y2,ExportDialog.FileName,false);
                                         'ABVSpriteFile' :  error:=WriteAmigaBasicObject(x,y,x2,y2,ExportDialog.FileName,true);
      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.AmigaCClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 error : word;
 validpm : boolean;
 VSprite : boolean;
 spritewidth : integer;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   spritewidth:=x2-x+1;
   ExportDialog.Filter := 'Amiga C Bob Bitmap Array|*.c';
   VSprite:=false;

   if (Sender As TMenuItem).Name = 'CVSpriteBitmapArray' then
   begin
     VSprite:=true;
     ExportDialog.Filter := 'Amiga C VSprite Bitmap Array|*.c';
   end;

   pm:=RMCoreBase.Palette.GetPaletteMode;
   validpm:=(pm=PaletteModeAmiga2) OR (pm=PaletteModeAmiga4) OR (pm=PaletteModeAmiga8) OR (pm=PaletteModeAmiga16) OR (pm=PaletteModeAmiga32);
   if validpm = false then
   begin
      ShowMessage('Invalid Palette Mode for this action. Choose an Amiga Palette Please');
      exit;
   end;

   if (vsprite=true) and (spritewidth<>16) and (pm<>PaletteModeAmiga4) then
   begin
      ShowMessage('Sprite Width should be 16 pixels with Palette of 4 Colors');
      exit;
   end;

   if ExportDialog.Execute then
   begin
      error:=WriteAmigaCWORD(x,y,x2,y2,ExportDialog.FileName,VSprite);
      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.AmigaCPaletteClick(Sender: TObject);
var
  error : word;
begin
   Case (Sender As TMenuItem).Name of 'ACVSpriteColorArray' : ExportDialog.Filter := 'Amiga C VSprite Color Array|*.c';
                                    'ACPaletteArray' : ExportDialog.Filter :='Amiga C Palettte Array|*.c';
                                    'ACRGB4PaletteArray' : ExportDialog.Filter :='Amiga C RGB4 Palette Array|*.c';

   end;
   if ExportDialog.Execute then
   begin
     Case (Sender As TMenuItem).Name of 'ACVSpriteColorArray' :  error:=WriteRGBPackedPalArray(ExportDialog.FileName,ACLan,true);
                                          'ACPaletteArray'    :  error:=WritePalConstants(ExportDialog.FileName,ACLan,ColorFourBitFormat);
                                         'ACRGB4PaletteArray' :  error:=WriteRGBPackedPalArray(ExportDialog.FileName,ACLan,false);
     end;

     if error<>0 then
     begin
      ShowMessage('Error Saving file!');
      exit;
     end;
   end;
end;

procedure TRMMainForm.AmigaPascalClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 error : word;
 validpm : boolean;
 VSprite : boolean;
 spritewidth   : integer;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   spritewidth:=x2-x+1;

   ExportDialog.Filter := 'Amiga Pascal Bob Bitmap Array|*.pas';
   VSprite:=false;
   if (Sender As TMenuItem).Name = 'PascalVSpriteBitmapArray' then
   begin
     VSprite:=true;
     ExportDialog.Filter := 'Amiga Pascal VSprite Bitmap Array|*.pas';
   end;

   pm:=RMCoreBase.Palette.GetPaletteMode;
   validpm:=(pm=PaletteModeAmiga2) OR (pm=PaletteModeAmiga4) OR (pm=PaletteModeAmiga8) OR (pm=PaletteModeAmiga16) OR (pm=PaletteModeAmiga32);
   if validpm = false then
   begin
      ShowMessage('Invalid Palette Mode for this action. Choose an Amiga Palette Please');
      exit;
   end;

   if (vsprite=true) and (spritewidth<>16) and (pm<>PaletteModeAmiga4) then
   begin
      ShowMessage('Sprite Width should be 16 pixels with Palette of 4 Colors');
      exit;
   end;

   if ExportDialog.Execute then
   begin
      error:=WriteAmigaPascalConst(x,y,x2,y2,ExportDialog.FileName,VSprite);
      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;

end;

procedure TRMMainForm.AmigaPascalPaletteClick(Sender: TObject);
var
  error : word;
begin
   Case (Sender As TMenuItem).Name of 'APVSpriteColorArray' : ExportDialog.Filter := 'Amiga Pascal VSprite Color Array|*.pas';
                                    'APPaletteArray' : ExportDialog.Filter :='Amiga Pascal Palettte Array|*.pas';
                                    'APRGB4PaletteArray' : ExportDialog.Filter :='Amiga Pascal RGB4 Palette Array|*.pas';

   end;
   if ExportDialog.Execute then
   begin
     Case (Sender As TMenuItem).Name of 'APVSpriteColorArray' :  error:=WriteRGBPackedPalArray(ExportDialog.FileName,APLan,true);
                                         'APPaletteArray'     :  error:=WritePalConstants(ExportDialog.FileName,APLan,ColorFourBitFormat);
                                        'APRGB4PaletteArray'  :  error:=WriteRGBPackedPalArray(ExportDialog.FileName,APLan,false);
     end;
     if error<>0 then
     begin
       ShowMessage('Error Saving file!');
       exit;
     end;
  end;
end;


procedure TRMMainForm.PaletteOpenClick(Sender: TObject);
Var
 pm : integer;
begin
 OpenDialog1.Filter := 'RM Palette|*.pal|All Files|*.*';
 if OpenDialog1.Execute then
 begin
     pm:=RMCoreBase.Palette.GetPaletteMode;
     if ReadPAL(OpenDialog1.FileName,pm) <> 0 then
     begin
        ShowMessage('Error Opening PAL file!');
        exit;
     end;
     CoreToPalette;
     UpdateColorBox;
     UpDateZoomArea;
     UpdateActualArea;
     UpdateThumbView;
 end;
end;

procedure TRMMainForm.PaletteSaveClick(Sender: TObject);
begin
 SaveDialog1.Filter := 'RM Palette|*.PAL|All Files|*.*';
 if SaveDialog1.Execute then
   begin
        if WritePal(SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving PAL file!');
          exit;
        end;
   end;
end;

procedure TRMMainForm.PaletteExportAmigaBasicClick(Sender: TObject);
var
 error : word;
begin
   Case (Sender As TMenuItem).Name of 'ABPaletteData' : ExportDialog.Filter := 'AmigaBasic Palette Data|*.bas';
                                      'ABPaletteCommands' : ExportDialog.Filter :='AmigaBasic Palette Commands|*.bas';
   end;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'ABPaletteData'  : error:=WritePalData(ExportDialog.FileName,ABLan,ColorOnePercentFormat);
                                      'ABPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,ABLan,ColorOnePercentFormat);
      end;

      if error<>0 then
      begin
         ShowMessage('Error Saving Palette file!');
         exit;
      end;
   end;
end;

procedure TRMMainForm.PaletteExportGWBasicClick(Sender: TObject);
var
 pm : integer;
 ColorFormat : integer;
 error : word;
begin
   Case (Sender As TMenuItem).Name of 'GWPaletteData' : ExportDialog.Filter := 'GWBasic Palette Data|*.bas';
                                      'GWPaletteCommands' : ExportDialog.Filter :='GWBasic Palette Commands|*.bas';
   end;
   if ExportDialog.Execute then
   begin
      pm:=RMCoreBase.Palette.GetPaletteMode;
      ColorFormat:=ColorSixBitFormat;
      if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

      Case (Sender As TMenuItem).Name of 'GWPaletteData' : error:=WritePalData(ExportDialog.FileName,GWLan,ColorFormat);
                                     'GWPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,GWLan,ColorFormat);
      end;

      if error<>0 then
      begin
         ShowMessage('Error Saving Palette file!');
         exit;
      end;
   end;
end;

procedure TRMMainForm.PaletteExportTurboPascalClick(Sender: TObject);
var
 pm : integer;
 ColorFormat : integer;
 error : word;
begin
   Case (Sender As TMenuItem).Name of 'TPPaletteArray' : ExportDialog.Filter := 'Turbo Pascal Palette Array|*.pas';
                                         'TPPaletteCommands' : ExportDialog.Filter :='Turbo Pascal Palette Commands|*.pas';
   end;
   if ExportDialog.Execute then
   begin
      ColorFormat:=ColorSixBitFormat;
      pm:=RMCoreBase.Palette.GetPaletteMode;
      if (pm=PaletteModeEGA) then ColorFormat:=ColorIndexFormat;

      Case (Sender As TMenuItem).Name of 'TPPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,TPLan,ColorFormat);
                                      'TPPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,TPLan,ColorFormat);
      end;

      if error<>0 then
      begin
         ShowMessage('Error Saving Palette file!');
         exit;
      end;
   end;
end;

procedure TRMMainForm.EditCopyClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
begin
 GetOpenSaveRegion(x,y,x2,y2);
 RMDrawTools.Copy(x,y,x2,y2);
end;

procedure TRMMainForm.EditPasteClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 clipstatus : integer;
begin
 clipstatus:= RMDrawTools.GetClipStatus; // capture clip status before UpdateZoomArea

 GetOpenSaveRegion(x,y,x2,y2);
 RMDrawTools.Paste(x,y,x2,y2);

 UpdateActualArea;
 UpdateZoomArea;
 UpdateThumbView;
 if clipstatus = 1 then
 begin
   RMDrawTools.DrawClipArea(ZoomBox.Canvas,ColorBox.brush.color,1);
 end;
end;


procedure TRMMainForm.ListView1DblClick(Sender: TObject);
var
  item : TListItem;
begin
 if (Listview1.SelCount > 0)  then
 begin
   item:=ListView1.LastSelected;

   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent); //copy again before we switch to new image
   ImageThumbBase.CopyIndexImageToCore(Item.Index);
   ImageThumbBase.SetCurrent(item.Index);

   ActualBox.Width:=RMCoreBase.GetWidth;
   ActualBox.Height:=RMCoreBase.GetHeight;

   RMDrawTools.SetZoomSize(1);
   RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
   RMDrawTools.SetZoomMaxX(ZoomBox.Width);
   RMDrawTools.SetZoomMaxY(ZoomBox.Height);

   MaxXOffset:=RMDrawTools.GetMaxXOffset(RMCoreBase.GetWidth,ZoomBox.Width);
   HorizScroll.Max:=MaxXOffset;
   MaxYOffset:=RMDrawTools.GetMaxYOffset(RMCoreBase.GetHeight,ZoomBox.Height);
   VirtScroll.Max:=MaxYOffset;
   ZoomSize:=RMDrawTools.GetZoomSize;

   CoreToPalette;
   UpdateColorBox;
   UpdatePalette;
   UpdateActualArea;
   UpdateZoomArea;
   UpdateThumbView;

 end;
end;

procedure TRMMainForm.InitThumbView;
var
  LItem: TListItem;
begin
  ImageThumbBase.AddImage;
  ImageThumbBase.SetCurrent(0);

  ImageThumbBase.MakeThumbImageFromCore(ImageThumbBase.GetCount-1,imagelist1,1);
  LItem:=ListView1.Items.Add;

  LItem.ImageIndex :=ImageThumbBase.GetCount-1;
  LItem.Caption:='Image '+IntToStr(ImageThumbBase.GetCount);
end;

procedure TRMMainForm.UpdateThumbView;
begin
  ImageThumbBase.MakeThumbImageFromCore(ImageThumbBase.GetCurrent,imagelist1,4);
  Listview1.Refresh;
end;

procedure TRMMainForm.SaveDeleteClick(Sender: TObject);
var
  item  : TListItem;
  i,index : integer;
begin
 if ImageThumbBase.GetCount = 1 then
 begin
    Clear;
     // display message to select clear as it is the only item
 end
 else if (Listview1.SelCount > 0)  then
 begin
   item:=ListView1.LastSelected;
   index:=item.index;

   if index > -1 then
   begin
      listview1.Items.Delete(index);
      imagelist1.Delete(index);

      for i:=0 to listview1.Items.Count -1 do
      begin
        listview1.Items[i].Caption:='Image '+intToStr(i+1);
        listview1.Items[i].ImageIndex:=i;
      end;
      ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
      ImageThumbBase.DeleteImage(index);
      if ImageThumbBase.GetCurrent > (ImageThumbBase.GetCount-1) then
      begin
        ImageThumbBase.SetCurrent(ImageThumbBase.GetCount-1);
      end;

      ImageThumbBase.CopyIndexImageToCore(ImageThumbBase.GetCurrent);   //to future nick - do not delete this line - it is important
      listview1.refresh;

      ActualBox.Width:=RMCoreBase.GetWidth;
      ActualBox.Height:=RMCoreBase.GetHeight;

      RMDrawTools.SetZoomSize(1);
      RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
      RMDrawTools.SetZoomMaxX(ZoomBox.Width);
      RMDrawTools.SetZoomMaxY(ZoomBox.Height);

      MaxXOffset:=RMDrawTools.GetMaxXOffset(RMCoreBase.GetWidth,ZoomBox.Width);
      HorizScroll.Max:=MaxXOffset;
      MaxYOffset:=RMDrawTools.GetMaxYOffset(RMCoreBase.GetHeight,ZoomBox.Height);
      VirtScroll.Max:=MaxYOffset;
      ZoomSize:=RMDrawTools.GetZoomSize;

      CoreToPalette;
      UpdateColorBox;
      UpdatePalette;
      UpdateActualArea;
      UpdateZoomArea;
   end;
 end;
end;

procedure TRMMainForm.NewClick(Sender: TObject);
begin
 if ImageThumbBase.GetCount >= MaxThumbImages then exit;


 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent); //copy again before we switch to new image
 //ImageThumbBase.MakeThumbImageFromCore(ImageThumbBase.GetCurrent,imagelist1,4);

 RMCoreBase.ClearBuf(0);
 RMCoreBase.SetCurColor(1);
 RMDrawTools.SetDrawTool(DrawShapePencil);
 UpdateToolSelectionIcons;

 UpdateColorBox;
 UpdateActualArea;
 RMDrawTools.SetClipStatus(0);
 RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
 UpdateZoomArea;
 UnFreezeScrollAndZoom;
 Trackbar1.Position:=RMDrawTools.getZoomSize;
 HorizScroll.Position:=0;
 VirtScroll.Position:=0;

 ImageThumbBase.AddImage;
// ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCount-1);
 ImageThumbBase.MakeThumbImage(ImageThumbBase.GetCount-1,imagelist1,1);

 with ListView1.Items.Add do
 begin
   ImageIndex :=ImageThumbBase.GetCount-1;
   Caption:='Image '+IntToStr(ImageThumbBase.GetCount);
 end;

 ImageThumbBase.SetCurrent(ImageThumbBase.GetCount-1);
 Listview1.Refresh;
end;

procedure TRMMainForm.Clear;
begin
 //  ClearClipAreaOutline;
 RMCoreBase.ClearBuf(0);
 RMCoreBase.SetCurColor(1);
 RMDrawTools.SetDrawTool(DrawShapePencil);
 UpdateToolSelectionIcons;

 UpdateColorBox;
 UpdateActualArea;
 RMDrawTools.SetClipStatus(0);
 RMDrawTools.DrawGrid(ZoomBox.Canvas,0,0,ZoomBox.Width,ZoomBox.Height,0);
 UpdateZoomArea;
 UnFreezeScrollAndZoom;
 Trackbar1.Position:=RMDrawTools.getZoomSize;
 HorizScroll.Position:=0;
 VirtScroll.Position:=0;
 UpdateThumbView;
end;

procedure TRMMainForm.EditClearClick(Sender: TObject);
begin
 Clear;
end;

end.

