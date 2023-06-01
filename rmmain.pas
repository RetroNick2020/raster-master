unit rmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uPSComponent, uPSRuntime, uPSComponent_Forms,
  Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ComCtrls, Menus,
  ActnList, StdActns, ColorPalette, Types, LResources, lclintf, rmtools, rmcore, flood,
  rmcolor, rmcolorvga, rmcolorxga, rmamigaColor, rmabout, rwpal, rwraw, rwpcx, rwbmp,
  rmamigarwxgf, wjavascriptarray, rmthumb, wmodex, rwgif, rwxgf, rmexportprops,
  rres, rwpng, wmouse, mapeditor, spriteimport, wraylib, rwilbm, rwaqb, rmapi,rmxgfcore,fileprops;


type

  { TRMMainForm }

  TRMMainForm = class(TForm)
    Action1: TAction;
    ActionList1: TActionList;
    ActualBox: TImage;
    ActualPane: TPanel;
    ColorBox: TShape;
    ColorPalette1: TColorPalette;
    FreePascal: TMenuItem;
    GWBASIC: TMenuItem;
    FreeBASIC: TMenuItem;
    AmigaBasic: TMenuItem;
    ImageList1: TImageList;
    InfoBarLabel: TLabel;
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
    ExportPropsMenu: TPopupMenu;
    ExportRESInclude: TMenuItem;
    ExportRESBinary: TMenuItem;
    ABPutPlusMaskData: TMenuItem;
    FBPutPlusMaskData: TMenuItem;
    FPPutImagePlusMaskArray: TMenuItem;
    GWPutPlusMaskData: TMenuItem;
    GWMouseShapeData: TMenuItem;
    FPMouseShapeArray: TMenuItem;
    ExportInclude: TMenuItem;
    LeftPanel: TPanel;
    MapEditMenu: TMenuItem;
    gcc: TMenuItem;
    gccRayLibIndex0: TMenuItem;
    gccRayLibFuchsia: TMenuItem;
    fpRayLibFuchsia: TMenuItem;
    fpRayLibIndex0: TMenuItem;
    fpRayLibRGB: TMenuItem;
    gccRayLibRGB: TMenuItem;
    fbRayLibFuchsia: TMenuItem;
    fbRayLibIndex0: TMenuItem;
    fbRayLibRGB: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    AqbPsetBitMap: TMenuItem;
    GWMouseShapeFile: TMenuItem;
    FBMouseShapeFile: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    ACBobFile: TMenuItem;
    ACVSpriteFile: TMenuItem;
    PascalBOBBitmapFile: TMenuItem;
    PascalVSpriteBitmapFile: TMenuItem;
    PropertiesFileDialog: TMenuItem;
    PaletteXGA256: TMenuItem;
    PaletteXGA: TMenuItem;
    OWPaletteCommands: TMenuItem;
    OWPaletteArray: TMenuItem;
    OWMouseShapeArray: TMenuItem;
    OWPutImageFile: TMenuItem;
    OWPutImagePlusMaskArray: TMenuItem;
    OWPutImageArray: TMenuItem;
    OpenWatcom: TMenuItem;
    QBMouseShapeFile: TMenuItem;
  //  ZoomScrollBox: TScrollBox;
    ZoomPaintBox: TPaintBox;
    ZoomScrollBox: TScrollBox;
    TCMouseShapeFile: TMenuItem;
    TBMouseShapeFile: TMenuItem;
    TPMouseShapeFile: TMenuItem;
    QPMouseShapeFile: TMenuItem;
    QCMouseShapeFile: TMenuItem;
    FPMouseShapeFile: TMenuItem;
    NewImage: TMenuItem;
    ScriptMenuLoad: TMenuItem;
    ScriptMenuRun: TMenuItem;
    ScriptMenu: TMenuItem;
    RMScript: TPSScript;
    qbRayLibRGB: TMenuItem;
    qbRayLibIndex0: TMenuItem;
    qbRayLibFuchsia: TMenuItem;
    MenuItem8: TMenuItem;
    SpriteImportMenu: TMenuItem;
    MiddleTopPanel: TPanel;
    RightPanel: TPanel;
    RMLogo: TImage;
    RMPanel: TPanel;
    RightHSplitter: TSplitter;
    ToolCircleIcon: TImage;
    ToolEllipseIcon: TImage;
    ToolFCircleIcon: TImage;
    ToolFEllipseIcon: TImage;
    ToolFRectangleIcon: TImage;
    ToolGridIcon: TImage;
    ToolHFLIPButton: TButton;
    ToolLineIcon: TImage;
    ToolPaintIcon: TImage;
    ToolPanel: TPanel;
    ToolPencilIcon: TImage;
    ToolRectangleIcon: TImage;
    ToolScrollDownIcon: TImage;
    ToolScrollLeftIcon: TImage;
    ToolScrollRightIcon: TImage;
    ToolScrollUpIcon: TImage;
    ToolSelectAreaIcon: TImage;
    ToolSprayPaintIcon: TImage;
    ToolUndoIcon: TImage;
    ToolVFLIPButton: TButton;
    TrackBar1: TTrackBar;
    Utilities: TMenuItem;
    MiddleBottomPanel: TPanel;
    QPPaletteArray: TMenuItem;
    QPPaletteCommands: TMenuItem;
    PaletteExportQuickPascal: TMenuItem;
    PBPaletteCommands: TMenuItem;
    MenuItem2: TMenuItem;
    FPPaletteArray: TMenuItem;
    FPPaletteCommands: TMenuItem;
    MenuItem3: TMenuItem;
    FBPaletteData: TMenuItem;
    FBPaletteCommands: TMenuItem;
    MenuItem7: TMenuItem;
    PBPaletteData: TMenuItem;
    QCMouseShapeArray: TMenuItem;
    QPMouseShapeArray: TMenuItem;
    LeftVSplitter: TSplitter;
    LeftHSplitter: TSplitter;
    TBMouseShapeData: TMenuItem;
    QBMouseShapeData: TMenuItem;
    TCMouseShapeArray: TMenuItem;
    FBMouseShapeData: TMenuItem;
    TPMouseShapeArray: TMenuItem;
    TCPutImagePlusMaskArray: TMenuItem;
    TBPutPlusMaskData: TMenuItem;
    QPPutImagePlusMaskArray: TMenuItem;
    QCPutImagePlusMaskArray: TMenuItem;
    QBPutPlusMaskData: TMenuItem;
    TPPutImagePlusMaskArray: TMenuItem;
    TCDOSLBMArray: TMenuItem;
    TCDOSLBMFile: TMenuItem;
    TCDOSPBMArray: TMenuItem;
    TCDOSPBMFile: TMenuItem;
    TPDOSLBMArray: TMenuItem;
    TPDOSLBMFile: TMenuItem;
    TPDOSPBMArray: TMenuItem;
    TPDOSPBMFile: TMenuItem;
    PaletteCopy: TMenuItem;
    PalettePaste: TMenuItem;
    QPPutImageArray: TMenuItem;
    QPPutImageFile: TMenuItem;
    QuickPascal: TMenuItem;
    Properties: TMenuItem;
    DeleteAll: TMenuItem;
    OpenProjectFile: TMenuItem;
    SaveProjectFile: TMenuItem;
    InsertProjectFile: TMenuItem;
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
    FileDelete: TMenuItem;
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
    TurboBasic: TMenuItem;
    QuickC: TMenuItem;
    TurboC: TMenuItem;
    TurboPascal: TMenuItem;
    QuickBasic: TMenuItem;
    ColorButton1: TColorButton;
    EditCut1: TEditCut;
    FileOpen1: TFileOpen;
    ToolGridMenu: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    ToolMenu: TMenuItem;
    ToolPencilMenu: TMenuItem;
    ToolLineMenu: TMenuItem;
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
    MainMenu1: TMainMenu;
    FileExitMenu: TMenuItem;
    OpenFile: TMenuItem;
    SaveFile: TMenuItem;



    procedure AmigaBasicClick(Sender: TObject);
    procedure AmigaCClick(Sender: TObject);
    procedure AmigaCPaletteClick(Sender: TObject);
    procedure AmigaPascalClick(Sender: TObject);
    procedure AmigaPascalPaletteClick(Sender: TObject);
    procedure AqbPsetBitMapClick(Sender: TObject);


    procedure ColorBoxMouseEnter(Sender: TObject);
    procedure ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure ColorPalette1GetHintText(Sender: TObject; AColor: TColor;
      var AText: String);
    procedure EditClearClick(Sender: TObject);
    procedure EditCopyClick(Sender: TObject);
    procedure EditPasteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);


    procedure FormCreate(Sender: TObject);
    procedure FreeBASICClick(Sender: TObject);
    procedure FreePascalClick(Sender: TObject);
    procedure GWBASICClick(Sender: TObject);
    procedure EditResizeToNewSize(Sender: TObject);
    procedure javaScriptArrayClick(Sender: TObject);

    procedure ListView1Click(Sender: TObject);
    procedure DeleteAllClick(Sender: TObject);
    procedure MapEditMenuClick(Sender: TObject);
    procedure OpenWatcomCClick(Sender: TObject);
    procedure PaletteExportOWCClick(Sender: TObject);
    procedure PaletteXGA256Click(Sender: TObject);
    procedure PaletteXGAClick(Sender: TObject);
    procedure PropertiesFileDialogClick(Sender: TObject);
    procedure RayLibExportClick(Sender: TObject);
    procedure RMPanelClick(Sender: TObject);
    procedure RMScriptCompile(Sender: TPSScript);
    procedure ScriptMenuLoadClick(Sender: TObject);
    procedure ScriptMenuRunClick(Sender: TObject);
    procedure SpriteImportMenuClick(Sender: TObject);
    procedure ThumbPopUpMenuExportClick(Sender: TObject);
    procedure ThumbPopUpMenusaveClick(Sender: TObject);
    procedure PalettePasteClick(Sender: TObject);
    procedure OpenProjectFileClick(Sender: TObject);
    procedure PaletteCopyClick(Sender: TObject);
    procedure PaletteEditColors(Sender: TObject);
    procedure PropertiesClick(Sender: TObject);
    procedure QuickPascalClick(Sender: TObject);
    procedure MouseSaveClick(Sender: TObject);


    procedure RESExportClick(Sender: TObject);
    procedure FileDeleteClick(Sender: TObject);
    procedure SaveProjectFileClick(Sender: TObject);
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

    procedure ZoomBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FileExitMenuClick(Sender: TObject);
    procedure OpenFileClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure ZoomPaintBoxPaint(Sender: TObject);
    procedure ZPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ZPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
       ZoomX,ZoomY,ZoomX2,ZoomY2 : integer;
       OldZoomX,OldZoomY : integer;
       ZoomSize : Integer;
       DrawMode : Boolean;
       DrawFirst : Boolean;
       MaxXOffset : Integer;
       MaxYOffset : Integer;

       RenderBitMap  : TBitMap;
       RenderBitMap2 : TBitMap;

       procedure UpdateZoomArea;
       procedure UpdateZoomScroller;
       procedure UpdateActualArea;
       procedure LoadDefaultPalette;
       procedure UpdatePalette;
       procedure UpdatePaletteMenu;
       procedure UpdateToolFlipScrollMenu;

       procedure UpdateColorBox;
       procedure UpdateInfoBarXY(x,y : integer);
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
       procedure ShowSelectAreaTools;
       procedure GetOpenSaveRegion(var x,y,x2,y2 : integer);  //if we are in select/clip area use those coords
       procedure EditColors;
       procedure Clear;
       procedure InitThumbView;
       Procedure CopyScrollPositionToCore;
       Procedure CopyScrollPositionFromCore;
       function getopenfilename(var filename,ext : string; filter : string) : boolean;
       function getsavefilename(var filename,ext : string; filter : string) : boolean;

       procedure UpdateRenderBitMap;
       procedure ZPaintBoxMouseDownXYTool(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
       procedure ZPaintBoxMouseMoveXYTool(Sender: TObject; Shift: TShiftState;  X, Y: Integer);
       procedure ZPaintBoxMouseUpXYTool(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
       procedure ZPaintBoxMouseDownXYX2Y2Tool(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
       procedure ZPaintBoxMouseMoveXYX2Y2Tool(Sender: TObject; Shift: TShiftState;  X, Y: Integer);
       procedure ZPaintBoxMouseUpXYX2Y2Tool(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);


  public
       procedure UpdateImportedImage;

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
  ColorPalette1.ClearColors;
  for i:=0 to Count-1 do
  begin
    RMCoreBase.Palette.GetColor(i,cr);
    tc:=RGBToColor(cr.r,cr.g,cr.b);
    ColorPalette1.AddColor(tc);
  end;
end;

procedure TRMMainForm.FormCreate(Sender: TObject);
begin
 RenderBitMap:=TBitMap.Create;
 RenderBitMap.SetSize(RMCoreBase.GetWidth,RMCoreBase.GetHeight);
 RenderBitMap2:=TBitMap.Create;
 RenderBitMap2.SetSize(RMCoreBase.GetWidth,RMCoreBase.GetHeight);

 ZoomSize:=RMDrawTools.GetZoomMode;
 DrawMode:=False;
 DrawFirst:=False;
 ActualBox.Width:=256;
 ActualBox.Height:=256;
 ActualBox.Canvas.Brush.Style := bsSolid;
 ActualBox.Canvas.Brush.Color := clblack;
 ActualBox.Canvas.FillRect(0,0,256,256);

 RMDrawTools.SetZoomMaxX(RMDrawTools.GetZoomPageWidth);
 RMDrawTools.SetZoomMaxY(RMDrawTools.GetZoomPageHeight);

 LoadResourceIcons;
 MaxXOffset:=0;
 MaxYOffset:=0;

 Trackbar1.Position:=RMDrawTools.getZoomSize;

 RMCoreBase.Palette.SetPaletteMode(PaletteModeVGA);
 LoadDefaultPalette;

 ColorBox.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor];
 ColorPalette1.PickedIndex:=RMCoreBase.GetCurColor;

 RMDrawTools.SetDrawTool(DrawShapePencil);
 ClearSelectedToolsMenu;
 PaletteVGA.Checked:=true; // set vga palette
 UpdateToolSelectionIcons;
 ToolPencilMenu.Checked:=true; //enable pencil tool in SpriteImportMenu
 InitThumbView;

 ZoomX:=0;
 ZoomY:=0;
 ZoomX2:=0;
 ZoomY2:=0;
 OldZoomX:=-1;
 OldZoomY:=-1;
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
begin
  //will return cliparea if clipped or entire area if not clipped
  RMDrawTools.GetClipAreaCoords(ca);
  RMDrawTools.HFlip(ca.x,ca.y,ca.x2,ca.y2);
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.ToolFlipVirtMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
begin
  RMDrawTools.GetClipAreaCoords(ca);
  RMDrawTools.VFlip(ca.x,ca.y,ca.x2,ca.y2);
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.ToolGridMenuClick(Sender: TObject);
begin
  UpdateGridDisplay;
end;

procedure TRMMainForm.ToolPencilMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  RMDrawTools.SetDrawTool(DrawShapePencil);
  UpdateToolSelectionIcons;
  ToolPencilMenu.Checked:=true;
end;

procedure TRMMainForm.ToolLineMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  ClearSelectedToolsMenu;
  RMDrawTools.SetDrawTool(DrawShapeLine);
  UpdateToolSelectionIcons;
  ToolLineMenu.Checked:=true;
end;

procedure TRMMainForm.ToolRectangleMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  ClearSelectedToolsMenu;
  RMDrawTools.SetDrawTool(DrawShapeRectangle);
  UpdateToolSelectionIcons;
  ToolRectangleMenu.Checked:=true;
end;

procedure TRMMainForm.ToolScrollDownMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
begin
  RMDrawTools.GetClipAreaCoords(ca);
  ClearClipAreaOutline;
  RMDrawTools.ScrollDown(ca.x,ca.y,ca.x2,ca.y2);
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.ToolScrollLeftMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
begin
  RMDrawTools.GetClipAreaCoords(ca);
  ClearClipAreaOutline;
  RMDrawTools.ScrollLeft(ca.x,ca.y,ca.x2,ca.y2);
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.ToolScrollRightMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
begin
  RMDrawTools.GetClipAreaCoords(ca);
  RMDrawTools.ScrollRight(ca.x,ca.y,ca.x2,ca.y2);
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.ClearClipAreaOutline;
begin
 if RMDrawTools.GetClipStatus = 1 then
 begin
   RMDrawTools.SetClipStatus(0);
   UpdateZoomArea;
 end;
end;

 procedure TRMMainForm.ToolScrollUpMenuClick(Sender: TObject);
var
 ca : TClipAreaRec;
begin
  RMDrawTools.GetClipAreaCoords(ca);
  RMDrawTools.ScrollUp(ca.x,ca.y,ca.x2,ca.y2);
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.ToolUndoIconClick(Sender: TObject);
begin
  RMCoreBase.Undo;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.ToolFRectangleMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  ClearSelectedToolsMenu;
  RMDrawTools.SetDrawTool(DrawShapeFRectangle);
  UpdateToolSelectionIcons;
  ToolFRectangleMenu.Checked:=true;
end;

procedure TRMMainForm.ToolCircleMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  ClearSelectedToolsMenu;
  RMDrawTools.SetDrawTool(DrawShapeCircle);
  UpdateToolSelectionIcons;
  ToolCircleMenu.Checked:=true;
end;

procedure TRMMainForm.ToolFCircleMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  ClearSelectedToolsMenu;
  RMDrawTools.SetDrawTool(DrawShapeFCircle);
  UpdateToolSelectionIcons;
  ToolFCircleMenu.Checked:=true;
end;

procedure TRMMainForm.ToolEllipseMenuClick(Sender: TObject);
begin
 ClearClipAreaOutline;
 ClearSelectedToolsMenu;
 RMDrawTools.SetDrawTool(DrawShapeEllipse);
 UpdateToolSelectionIcons;
 ToolEllipseMenu.Checked:=true;
end;

procedure TRMMainForm.ToolFEllipseMenuClick(Sender: TObject);
begin
 ClearClipAreaOutline;
 ClearSelectedToolsMenu;
 RMDrawTools.SetDrawTool(DrawShapeFEllipse);
 UpdateToolSelectionIcons;
 ToolFEllipseMenu.Checked:=true;
end;

procedure TRMMainForm.ToolMenuPaintClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  ClearSelectedToolsMenu;
  RMDrawTools.SetDrawTool(DrawShapePaint);
  UpdateToolSelectionIcons;
  ToolMenuPaint.Checked:=true;
end;

procedure TRMMainForm.ToolMenuSprayPaintClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  ClearSelectedToolsMenu;
  RMDrawTools.SetDrawTool(DrawShapeSpray);
  UpdateToolSelectionIcons;
  ToolMenuSprayPaint.Checked:=true;
end;

procedure TRMMainForm.ToolMenuSelectAreaMenuClick(Sender: TObject);
begin
   ClearClipAreaOutline;
   ClearSelectedToolsMenu;
   RMDrawTools.SetDrawTool(DrawShapeClip);
   UpdateToolSelectionIcons;
   ToolSelectAreaMenu.Checked:=True;
end;

procedure TRMMainForm.PaletteMonoClick(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteMono.Checked:=true;
  RMCoreBase.Palette.SetPaletteMode(PaletteModeMono);
  LoadDefaultPalette;

  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteCGA0Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteCGA0.Checked:=true;
  RMCoreBase.Palette.SetPaletteMode(PaletteModeCGA0);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteCGA1Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteCGA1.Checked:=true;
  RMCoreBase.Palette.SetPaletteMode(PaletteModeCGA1);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;


procedure TRMMainForm.PaletteAmiga2Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteAmiga.Checked:=true;
  PaletteAmiga2.Checked:=true;
  RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga2);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga4Click(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteAmiga.Checked:=true;
 PaletteAmiga4.Checked:=true;
 RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga4);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
 UpdateZoomArea;
 UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga8Click(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteAmiga.Checked:=true;
 PaletteAmiga8.Checked:=true;
 RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga8);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
 UpdateZoomArea;
 UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga16Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteAmiga.Checked:=true;
  PaletteAmiga16.Checked:=true;
  RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga16);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga32Click(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteAmiga.Checked:=true;
 PaletteAmiga32.Checked:=true;
 RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga32);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
 UpdateZoomArea;
 UpdateThumbview;
end;


procedure TRMMainForm.ClearSelectedPaletteMenu;
begin
  PaletteMono.Checked:=false;
  PaletteCGA0.Checked:=false;
  PaletteCGA1.Checked:=false;
  PaletteEGA.Checked:=false;
  PaletteVGA.Checked:=false;
  PaletteVGA256.Checked:=false;
  PaletteXGA.Checked:=false;
  PaletteXGA256.Checked:=false;
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
  RMCoreBase.Palette.SetPaletteMode(PaletteModeVGA);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteVGA256Click(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteVGA256.Checked:=true;
  RMCoreBase.Palette.SetPaletteMode(PaletteModeVGA256);
  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteEGAClick(Sender: TObject);
begin
  ClearSelectedPaletteMenu;
  PaletteEGA.Checked:=true;
  RMCoreBase.Palette.SetPaletteMode(PaletteModeEGA);

  LoadDefaultPalette;
  RMCoreBase.SetCurColor(1);
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
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

procedure TRMMainForm.UpdateActualArea;
var
  i,j : integer;
  zoommode : integer;
  tc : TColor;
begin
   zoommode:=RMDrawTools.GetZoomMode;
   RMDrawTools.SetZoomMode(0);
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
begin
  UpdateRenderBitMap;
  ZoomPaintBox.Invalidate;
end;

procedure TRMMainForm.updateZoomScroller;
begin
  Trackbar1.Position:=ZoomSize;
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
  else if pm = PaletteModeXGA256 then
  begin
    RMDrawTools.AddVGAPalette256(ColorPalette1);
    ColorPalette1.ColumnCount:=32;
    ColorPalette1.ButtonHeight:=17;
    ColorPalette1.ButtonWidth:=17;
    PaletteToCore;
  end
  else if pm = PaletteModeXGA then
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
  pm:=RMCoreBase.Palette.GetPaletteMode;
  if (pm = PaletteModeVGA256) or (pm=PaletteModeXGA256) then
  begin
    ColorPalette1.ColumnCount:=32;
    ColorPalette1.ButtonHeight:=17;
    ColorPalette1.ButtonWidth:=17;
  end
  else if (pm = PaletteModeVGA) or (pm = PaletteModeXGA) then
  begin
    ColorPalette1.ColumnCount:=8;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
  end
  else if pm = PaletteModeEGA then
  begin
   ColorPalette1.ColumnCount:=8;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
  end
  else if pm = PaletteModeCGA0 then
  begin
   ColorPalette1.ColumnCount:=2;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
  end
  else if pm = PaletteModeCGA1 then
  begin
   ColorPalette1.ColumnCount:=2;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
  end
  else if pm = PaletteModeMono then
  begin
   ColorPalette1.ColumnCount:=1;
   ColorPalette1.ButtonHeight:=50;
   ColorPalette1.ButtonWidth:=30;
  end
  else if pm = PaletteModeAmiga32 then
   begin
    ColorPalette1.ColumnCount:=16;
    ColorPalette1.ButtonHeight:=25;
    ColorPalette1.ButtonWidth:=30;
   end
   else if pm = PaletteModeAmiga16 then
   begin
    ColorPalette1.ColumnCount:=8;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
   end
   else if pm = PaletteModeAmiga8 then
    begin
     ColorPalette1.ColumnCount:=4;
     ColorPalette1.ButtonHeight:=50;
     ColorPalette1.ButtonWidth:=30;
    end
   else if pm = PaletteModeAmiga4 then
   begin
    ColorPalette1.ColumnCount:=2;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
   end
   else if pm = PaletteModeAmiga2 then
   begin
    ColorPalette1.ColumnCount:=1;
    ColorPalette1.ButtonHeight:=50;
    ColorPalette1.ButtonWidth:=30;
   end;
end;

procedure TRMMainForm.UpdatePaletteMenu;
var
 pm : integer;
begin
  PaletteMono.Checked:=false;
  PaletteCGA0.Checked:=false;
  PaletteCGA1.Checked:=false;
  PaletteEGA.Checked:=false;
  PaletteVGA.Checked:=false;
  PaletteVGA256.Checked:=false;
  PaletteXGA.Checked:=false;
  PaletteXGA256.Checked:=false;
  PaletteAmiga.Checked:=false;
  PaletteAmiga2.Checked:=false;
  PaletteAmiga4.Checked:=false;
  PaletteAmiga8.Checked:=false;
  PaletteAmiga16.Checked:=false;
  PaletteAmiga32.Checked:=false;

  pm:=RMCoreBase.Palette.GetPaletteMode;
  if pm = PaletteModeVGA256 then
  begin
    PaletteVGA256.Checked:=true;
  end
  else if pm = PaletteModeVGA then
  begin
     PaletteVGA.Checked:=true;
  end
  else if pm = PaletteModeXGA256 then
  begin
     PaletteXGA256.Checked:=true;
  end
  else if pm = PaletteModeXGA then
  begin
     PaletteXGA.Checked:=true;
  end
  else if pm = PaletteModeEGA then
  begin
     PaletteEGA.Checked:=true;
  end
  else if pm = PaletteModeCGA0 then
  begin
     PaletteCGA0.Checked:=true;
  end
  else if pm = PaletteModeCGA1 then
  begin
     PaletteCGA1.Checked:=true;
  end
  else if pm = PaletteModeMono then
  begin
     PaletteMono.Checked:=false;
  end
  else if pm = PaletteModeAmiga32 then
   begin
      PaletteAmiga.Checked:=true;
      PaletteAmiga32.Checked:=true;
   end
   else if pm = PaletteModeAmiga16 then
   begin
      PaletteAmiga.Checked:=true;
      PaletteAmiga16.Checked:=true;
   end
   else if pm = PaletteModeAmiga8 then
   begin
      PaletteAmiga.Checked:=true;
      PaletteAmiga8.Checked:=true;
    end
   else if pm = PaletteModeAmiga4 then
   begin
      PaletteAmiga.Checked:=true;
      PaletteAmiga4.Checked:=true;
   end
   else if pm = PaletteModeAmiga2 then
   begin
      PaletteAmiga.Checked:=true;
      PaletteAmiga2.Checked:=true;
   end;
end;

procedure TRMMainForm.UpdateToolFlipScrollMenu;
begin
 if RMDrawTools.GetClipStatus = 1  then
 begin
    ToolFlipMenu.Enabled:=true;
    ToolScrollMenu.Enabled:=true;
 end
 else
 begin
   ToolFlipMenu.Enabled:=false;
   ToolScrollMenu.Enabled:=false;
 end;
end;

Procedure TRMMainForm.UpdateGridDisplay;
begin
  if RMDrawTools.GetGridMode = 0 then
  begin
    RMDrawTools.SetGridMode(1);
    ToolGridMenu.Checked:=true;
  end
  else
  begin
    RMDrawTools.SetGridMode(0);
    ToolGridMenu.Checked:=false;
  end;

  UpdateActualArea;
  UpdateZoomArea;
end;

procedure TRMMainForm.ColorBoxMouseEnter(Sender: TObject);
begin
  ColorBox.Hint:=ColIndexToHoverInfo(RMCoreBase.GetCurColor,RMCoreBase.Palette.GetPaletteMode);
end;

procedure TRMMainForm.ColorPalette1GetHintText(Sender: TObject; AColor: TColor;
  var AText: String);
begin
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

//disable - not happy with zoom in with mouse wheel
procedure TRMMainForm.ZoomBoxMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
   if RMDrawTools.GetClipStatus = 1 then exit;

   ZoomSize:=RMDrawTools.GetZoomSize;
   If WheelDelta < 0 then dec(ZoomSize)
   else if WheelDelta > 0 then inc(ZoomSize);

   RMDrawTools.SetZoomSize(ZoomSize);
   RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
   TrackBar1.Position:=RMDrawTools.GetZoomSize;
   UpdateZoomArea;
end;

procedure TRMMainForm.FileExitMenuClick(Sender: TObject);
begin
  close;            // I created extra work - i added prompt in close
end;

procedure TRMMainForm.TrackBar1Change(Sender: TObject);
begin
  RMDrawTools.SetZoomSize(TrackBar1.Position);
  ZoomPaintBox.Width:=1;
  ZoomPaintBox.Height:=1;
  ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
  ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;
  ZoomPaintBox.Canvas.Clear;
  RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
  RMDrawTools.SetZoomMaxX(ZoomPaintBox.Width);
  RMDrawTools.SetZoomMaxY(ZoomPaintBox.Height);

  ZoomSize:=RMDrawTools.GetZoomSize;
  UpdateZoomArea;
end;

//updates RenderBitMap from core buf pixels
procedure TRMMainForm.UpdateRenderBitMap;
var
 i,j : integer;
begin
 RenderBitMap.SetSize(RMCoreBase.GetWidth,RMCoreBase.GetHeight);
 for j:=0 to RMCoreBase.GetHeight do
 begin
   for i:=0 to RMCoreBase.GetWidth do
   begin
       RenderBitMap.Canvas.Pixels[i,j]:=RMCoreBase.GetPixelTColor(i,j);
   end;
 end;
end;

procedure TRMMainForm.UpdateInfoBarXY(x,y : integer);
var
  XYStr   : string;
  ClipStr : string;
  ColIndexStr : string;
  ca      : TClipAreaRec;
  zx,zy : integer;
begin
 zx:=RMDrawTools.GetZoomX(x);
 zy:=RMDrawTools.GetZoomy(y);
 XYStr:='Zoom X = '+IntToStr(ZX)+' Zoom Y = '+IntToStr(ZY)+#13#10;
 ColIndexStr:='';
 if (zx >= 0) and (zy >= 0) then
 begin
   ColIndexStr:='Color Index: '+IntToStr(RMCoreBase.GetPixel(ZX,ZY))
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
begin
 XYStr:='Zoom X = '+IntToStr(ZoomX)+' Zoom Y = '+IntToStr(ZoomY)+#13#10+
        'Zoom X2 = '+IntToStr(ZoomX2)+' Zoom Y2 = '+IntToStr(ZoomY2)+#13#10+
        'Width = '+IntToStr(ABS(ZoomX2-ZoomX+1))+' Height = '+IntToStr(ABS(ZoomY2-ZoomY+1));
 InfoBarLabel.Caption:=XYStr;
end;

// xy mouse down event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseDownXYTool(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 DrawTool : integer;
begin
  ZoomX:=RMDrawTools.GetZoomX(x);
  ZoomY:=RMDrawTools.GetZoomY(y);
  if (ZoomX=OldZoomX) and (ZoomY=OldZoomY) then exit; // we are just just drawing in the same zoom x,y

  OldZoomX:=ZoomX;
  OldZoomY:=ZoomY;
  DrawTool:=RMDRAWTools.GetDrawTool;

  if DrawTool = DrawShapePaint then  // special kludge here - fix in future updates
  begin
    Fill(ZoomX,ZoomY,RMCoreBase.GetCurColor);
    UpdateRenderBitMap;
    ZoomPaintBox.Invalidate;
    UpdateActualArea;
  end
  else
  begin
    UpdateRenderBitMap;
    RMDrawTools.CreateRandomSprayPoints;
    RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox.Brush.Color,DrawShapeModeCopy,DrawTool,0);
    RMDrawTools.ADrawShape(ActualBox.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox.Brush.Color,DrawShapeModeCopy,DrawTool,0);
    ZoomPaintBox.Invalidate;
    RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox.Brush.Color,DrawShapeModeCopyToBuf,DrawTool,0);
  end;
end;

// xy mouse move event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseMoveXYTool(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
 DrawTool : integer;
begin
  ZoomX:=RMDrawTools.GetZoomX(x);
  ZoomY:=RMDrawTools.GetZoomY(y);

  UpdateInfoBarXY(x,y);
  if not ((ssLeft in Shift) or (ssRight in Shift)) then exit;

  if (ZoomX=OldZoomX) and (ZoomY=OldZoomY) then exit; // we are just just drawing in the same zoom x,y
  OldZoomX:=ZoomX;
  OldZoomY:=ZoomY;
  DrawTool:=RMDRAWTools.GetDrawTool;

  RMDrawTools.CreateRandomSprayPoints;
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox.Brush.Color,DrawShapeModeCopy,DrawTool,0);
  RMDrawTools.ADrawShape(ActualBox.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox.Brush.Color,DrawShapeModeCopy,DrawTool,0);
  ZoomPaintBox.Invalidate;
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox.Brush.Color,DrawShapeModeCopyToBuf,DrawTool,0);
end;

// xy mouse up event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseUpXYTool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  OldZoomX:=-1;
  OldZoomX:=-1;
end;


// xyx2y2 mouse down event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseDownXYX2Y2Tool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 DrawTool : integer;
begin
  ZoomX:=RMDrawTools.GetZoomX(x);
  ZoomY:=RMDrawTools.GetZoomY(y);
  ZoomX2:=ZoomX;
  ZoomY2:=ZoomY;
  UpdateInfoBarDetail;
  OldZoomX:=ZoomX;
  OldZoomY:=ZoomY;
  DrawTool:=RMDRAWTools.GetDrawTool;

  if DrawTool = DrawShapeClip then
  begin
    RMDrawTools.SaveClipCoords(ZoomX,ZoomY,ZoomX2,ZoomY2);
    RMDrawTools.SetClipStatus(1);
    ZoomPaintBox.Invalidate;
    exit;
  end;

  UpdateRenderBitMap;
  RenderBitMap2.Canvas.CopyRect(rect(0,0,RenderBitMap2.Width,RenderBitMap2.Height),RenderBitMap.Canvas,rect(0,0,RenderBitMap.Width,RenderBitMap.Height));
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox.Brush.Color,DrawShapeModeCopy,DrawTool,1);
  ZoomPaintBox.Invalidate;
end;

// xyx2y2 mouse move event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseMoveXYX2Y2Tool(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
 DrawTool : integer;
begin
  if not ((ssLeft in Shift) or (ssRight in Shift)) then UpdateInfoBarXY(x,y);    // update info when button is up
  if (OldZoomX=-1) or (OldZoomY=-1) then exit;
  if not ((ssLeft in Shift) or (ssRight in Shift)) then exit;

  ZoomX2:=RMDrawTools.GetZoomX(x);
  ZoomY2:=RMDrawTools.GetZoomY(y);
  if (ZoomX2=OldZoomX) and (ZoomY2=OldZoomY) then exit; // we are just just drawing in the same zoom x,y

  //new spot
  OldZoomX:=ZoomX2;
  OldZoomY:=ZoomY2;
  DrawTool:=RMDRAWTools.GetDrawTool;

  UpdateInfoBarDetail; // update info when button is down
  if DrawTool = DrawShapeClip then
  begin
    RMDrawTools.SaveClipCoords(ZoomX,ZoomY,ZoomX2,ZoomY2);
    RMDrawTools.SetClipStatus(1);
    ZoomPaintBox.Invalidate;
    exit;
  end;
  //UpdateRenderBitMap;
  RenderBitMap.Canvas.CopyRect(rect(0,0,RenderBitMap.Width,RenderBitMap.Height),RenderBitMap2.Canvas,rect(0,0,RenderBitMap2.Width,RenderBitMap2.Height));
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX2,ZoomY2,ColorBox.Brush.Color,DrawShapeModeCopy,DrawTool,1);
  ZoomPaintBox.Invalidate;
end;

// xyx2y2 mouse up event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseUpXYX2Y2Tool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 DrawTool : integer;
begin
  if (OldZoomX=-1) or (OldZoomY=-1) then exit;       //prevent right clicking from outsize of zoom area while moving into zoom area creates unwanted event - checking the coors allows to jump out with out drawing garbage
  OldZoomX:=-1;
  OldZoomY:=-1;
  DrawTool:=RMDRAWTools.GetDrawTool;
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX2,ZoomY2,ColorBox.Brush.Color,DrawShapeModeCopyToBuf,DrawTool,1);
  RMDrawTools.ADrawShape(ActualBox.Canvas,ZoomX,ZoomY,ZoomX2,ZoomY2,ColorBox.Brush.Color,DrawShapeModeCopy,DrawTool,1);
end;

procedure TRMMainForm.ZPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 DrawTool : integer;
begin
 RMDrawTools.SetClipStatus(0);  //turn it off - we turn on again when new area is selected
 DrawTool:=RMDRAWTools.GetDrawTool;
 if DrawTool<>DrawShapeClip then RMCoreBase.CopyToUndoBuf;
 Case DrawTool of DrawShapePencil,DrawShapeSpray,DrawShapePaint:ZPaintBoxMouseDownXYTool(Sender,Button,Shift,X,Y);
                                  DrawShapeLine,DrawShapeRectangle,DrawShapeFRectangle,DrawShapeCircle,DrawShapeFCircle,
               DrawShapeEllipse,DrawShapeFEllipse,DrawShapeClip:ZPaintBoxMouseDownXYX2Y2Tool(Sender,Button,Shift,X,Y);
 end;
end;

procedure TRMMainForm.ZPaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
 DrawTool : integer;
begin
 //UpdateInfoBarXY;
 DrawTool:=RMDRAWTools.GetDrawTool;
 Case DrawTool of DrawShapePencil,DrawShapeSpray,DrawShapePaint:ZPaintBoxMouseMoveXYTool(Sender,Shift,X,Y);
               DrawShapeLine,DrawShapeRectangle,DrawShapeFRectangle,DrawShapeCircle,DrawShapeFCircle,
               DrawShapeEllipse,DrawShapeFEllipse,DrawShapeClip:ZPaintBoxMouseMoveXYX2Y2Tool(Sender,Shift,X,Y);

 end;
end;

procedure TRMMainForm.ZPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 DrawTool : integer;
begin
 DrawTool:=RMDRAWTools.GetDrawTool;
 Case DrawTool of DrawShapePencil,DrawShapeSpray:ZPaintBoxMouseUpXYTool(Sender,Button,Shift,X,Y);
               DrawShapeLine,DrawShapeRectangle,DrawShapeFRectangle,DrawShapeCircle,DrawShapeFCircle,
               DrawShapeEllipse,DrawShapeFEllipse:ZPaintBoxMouseUpXYX2Y2Tool(Sender,Button,Shift,X,Y);

 end;
 UpdateThumbview;
end;

procedure TRMMainForm.ZoomPaintBoxPaint(Sender: TObject);
begin
  ZoomPaintBox.Canvas.CopyRect(rect(0,0,ZoomPaintBox.Width,ZoomPaintBox.Height),
               RenderBitMap.Canvas,rect(0,0,RenderBitMap.Width,RenderBitMap.Height));
  RMDrawTools.DrawOverlayGrid(ZoomPaintBox.Canvas,clWhite);
  RMDrawTools.DrawOverlayOnClipArea(ZoomPaintBox.Canvas,clYellow,0); //mode 0 is copy
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
     x:=ca.x;
     y:=ca.y;
     x2:=ca.x2;
     y2:=ca.y2;
   end;
end;

procedure TRMMainForm.SaveFileClick(Sender: TObject);
var
 ext : string;
 x,y,x2,y2 : integer;
 PngRGBA : PngRGBASettingsRec;
 UsePBM  : boolean;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   SaveDialog1.Filter := 'Windows BMP|*.bmp|PNG|*.png|PC Paintbrush|*.pcx|DP-Amiga IFF|*.iff|DP-Amiga IFF Brush|*.brush|DP-PC IFF LBM(PBM)|*.lbm|DP-PC BBM Brush|*.bbm|GIF|*.gif|RM RAW Files|*.raw|All Files|*.*';
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
      else if ext = '.PNG' then
      begin
        FilePropertiesDialog.GetProps(PngRGBA);
        if SavePNG(x,y,x2,y2,SaveDialog1.FileName,PngRGBA) <> 0 then
         begin
           ShowMessage('Error Saving PNG file!');
         end;
      end
      else if ext = '.GIF' then
      begin
        if WGIF(x,y,x2,y2,SaveDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Saving GIF file!');
        end;
      end
      else if (ext = '.ILBM') or (ext = '.LBM') or (ext = '.IFF') then
          begin
            if ext='.LBM' then UsePBM:=true else UsePBM:=false;
            if WriteILBM(SaveDialog1.FileName,x,y,x2,y2,1,UsePBM) <> 0 then
            begin
              ShowMessage('Error Saving IFF/ILBM file!');
            end;
          end
      else if (ext = '.BBM') or (ext = '.BRUSH') then
          begin
            if ext='.BBM' then UsePBM:=true else UsePBM:=false;
            if WriteILBM(SaveDialog1.FileName,x,y,x2,y2,0,UsePBM) <> 0 then
            begin
              ShowMessage('Error Saving IFF/BBM Brush file!');
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
   pm:=RMCoreBase.Palette.GetPaletteMode;

   if RMDrawTools.GetClipStatus = 1 then lp:=0;
   OpenDialog1.Filter := 'Windows BMP|*.bmp|PNG|*.png|PC Paintbrush |*.pcx|DP-Amiga IFF LBM|*.lbm|DP-Amiga IFF|*.iff|DP-Amiga IFF Brush|*.brush|DP-PC IFF LBM(PBM)|*.lbm|DP-PC BBM Brush|*.bbm|GIF|*.gif|RM RAW Files|*.raw|All Files|*.*' ;

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
      else if (ext = '.LBM') or (ext = '.BBM') or (ext = '.BRUSH') or (ext = '.ILBM') or (ext = '.IFF') then
      begin
        if ReadILBM(OpenDialog1.FileName,x,y,x2,y2,lp,pm) <> 0 then
        begin
          ShowMessage('Error Opening IFF/ILBM file!');
          exit;
        end;
      end
      else if ext = '.GIF' then
      begin
        if RGIF(x,y,x2,y2,lp,pm,OpenDialog1.FileName) <> 0 then
        begin
          ShowMessage('Error Opening GIF file!');
          exit;
        end;
      end
      else if ext = '.PNG' then
      begin
        if ReadPNG(x,y,x2,y2,OpenDialog1.FileName,(lp=1)) <> 0 then
        begin
          ShowMessage('Error Opening PNG file!');
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
                                    'FBPaletteData' : ExportDialog.Filter := 'FreeBASIC Palette Data|*.bas';
                                    'FBPaletteCommands' : ExportDialog.Filter :='FreeBASIC Palette Commands|*.bas';
                                    'PBPaletteData' : ExportDialog.Filter := 'Turbo\Power Basic Palette Data|*.bas';
                                    'PBPaletteCommands' : ExportDialog.Filter :='Turbo\Power Basic Palette Commands|*.bas';
   end;

   if ExportDialog.Execute then
   begin
      pm:=RMCoreBase.Palette.GetPaletteMode;

      ColorFormat:=ColorSixBitFormat;
      if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

      Case (Sender As TMenuItem).Name of 'QBPaletteData' : error:=WritePalData(ExportDialog.FileName,QBLan,ColorFormat);
                                     'QBPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,QBLan,ColorFormat);
                                     'FBPaletteData' : error:=WritePalData(ExportDialog.FileName,FBinQBModeLan,ColorFormat);
                                     'FBPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,FBinQBModeLan,ColorFormat);
                                     'PBPaletteData' : error:=WritePalData(ExportDialog.FileName,PBLan,ColorFormat);
                                     'PBPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,PBLan,ColorFormat);
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
 error : word;
 begin
   GetOpenSaveRegion(x,y,x2,y2);
   ExportDialog.FileName:='';
   Case (Sender As TMenuItem).Name of 'QBPutData' :ExportDialog.Filter := 'QuickBasic\QB64 Put Data Statements|*.bas';
                              'QBPutPlusMaskData' :ExportDialog.Filter := 'QuickBasic\QB64 Put+Mask Data Statements|*.bas';
                                     'QBPutFile' : ExportDialog.Filter := 'QuickBasic\QB64 Put File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'QBPutData' : error:=WriteXGFToCode(x,y,x2,y2,QBLan,ExportDialog.FileName);
                                 'QBPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,QBLan,ExportDialog.FileName);
                                         'QBPutFile' : error:=WriteXGFToFile(x,y,x2,y2,QBLan,ExportDialog.FileName);
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
 error : word;
begin
  GetOpenSaveRegion(x,y,x2,y2);
  Case (Sender As TMenuItem).Name of 'TPPutImageArray' :ExportDialog.Filter := 'Turbo Pascal PutImage Array|*.pas';
                                  'TPPutImagePlusMaskArray' :ExportDialog.Filter := 'Turbo Pascal PutImage+Mask Array|*.pas';
                                  'TPPutImageFile' : ExportDialog.Filter := 'Turbo Pascal PutImage File|*.xgf';
                                        'TPDOSLBMArray' : ExportDialog.Filter := 'Turbo Pascal DOS Xlib LBM Array|*.pas';
                                        'TPDOSLBMFile' : ExportDialog.Filter := 'Turbo Pascal DOS Xlib LBM File|*.lbm';
                                        'TPDOSPBMArray' : ExportDialog.Filter := 'Turbo Pascal DOS Xlib PBM Array|*.pas';
                                        'TPDOSPBMFile' : ExportDialog.Filter := 'Turbo Pascal DOS Xlib PBM File|*.pbm';



  End;
  if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'TPPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,TPLan,ExportDialog.FileName);
                                 'TPPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,TPLan,ExportDialog.FileName);
                                         'TPPutImageFile' : error:=WriteXGFToFile(x,y,x2,y2,TPLan,ExportDialog.FileName);
                                          'TPDOSLBMArray' : error:=WriteLBMToCode(x,y,x2,y2,TPLan,ExportDialog.FileName);
                                          'TPDOSLBMFile'  : error:=WriteLBMToFile(x,y,x2,y2,ExportDialog.FileName);
                                          'TPDOSPBMArray' : error:=WritePBMToCode(x,y,x2,y2,TPLan,ExportDialog.FileName);
                                          'TPDOSPBMFile'  : error:=WritePBMToFile(x,y,x2,y2,ExportDialog.FileName);

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
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'FPPutImageArray' :ExportDialog.Filter := 'FreePascal PutImage Array|*.pas';
                              'FPPutImagePlusMaskArray' :ExportDialog.Filter := 'FreePascal PutImage+Mask Array|*.pas';
                                       'FPPutImageFile' :ExportDialog.Filter := 'FreePascal PutImage File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'FPPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,FPLan,ExportDialog.FileName);
                                 'FPPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,FPLan,ExportDialog.FileName);
                                         'FPPutImageFile'  : error:=WriteXGFToFile(x,y,x2,y2,FPLan,ExportDialog.FileName);
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
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'GWPutData' :ExportDialog.Filter := 'GWBASIC Put Data Statements|*.bas';
                              'GWPutPlusMaskData' :ExportDialog.Filter := 'GWBASIC Put+Mask Data Statements|*.bas';
                                      'GWPutFile' :ExportDialog.Filter := 'GWBASIC Put File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'GWPutData' : error:=WriteXGFToCode(x,y,x2,y2,GWLan,ExportDialog.FileName);
                                 'GWPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,GWLan,ExportDialog.FileName);
                                         'GWPutFile' : error:=WriteXGFToFile(x,y,x2,y2,GWLan,ExportDialog.FileName);
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
  RMDrawTools.SetZoomSize(1);

  ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
  ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;

  RMDrawTools.SetZoomMaxX(RMDrawTools.GetZoomPageWidth);
  RMDrawTools.SetZoomMaxY(RMDrawTools.GetZoomPageHeight);
  RMDrawTools.SetClipStatus(0); // turn off in case clip area is bigger than work area
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
       CoreToPalette;       //onscreen palette - not copying back to dialog

       UpdateActualArea;
       UpdateZoomArea;
       UpdateThumbview;
    end;
  end
  else If (pm = PaletteModeXGA) OR (pm = PaletteModeXGA256) then
      begin
       if pm = PaletteModeXGA then RMXGAColorDialog.InitColorBox16
       else RMXGAColorDialog.InitColorBox256;

       if RMXGAColorDialog.ShowModal = mrOK then
       begin
          PI:=RMXGAColorDialog.GetPickedIndex;
          RMCoreBase.SetCurColor(PI);
          ColorPalette1.PickedIndex:=PI;

          ColorBox.Brush.Color:=RMXGAColorDialog.GetPickedColor;
          RMXGAColorDialog.PaletteToCore;
          CoreToPalette;       //onscreen palette - not copying back to dialog

          UpdateActualArea;
          UpdateZoomArea;
          UpdateThumbview;

       end;
     end
  else if (pm = PaletteModeEGA) then
  begin
     RMEGAColorDialog.InitColorBox;
     if RMEGAColorDialog.ShowModal = mrOK then
     begin
       PI:=RMEGAColorDialog.GetPickedIndex;
       if (PI > -1) then
       begin
          ci:=RMCoreBase.GetCurColor;
          ColorPalette1.Colors[ci]:=RMEGAColorDialog.GetPickedColor;
          ColorBox.Brush.Color:=RMEGAColorDialog.GetPickedColor;
          GetDefaultRGBEGA64(RMEGAColorDialog.GetPickedIndex, cr);
          RMCoreBase.Palette.SetColor(ci,cr);
          UpdateActualArea;
          UpdateZoomArea;
          UpdateThumbview;
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
   end;
 end;
end;

procedure TRMMainForm.PaletteEditColors(Sender: TObject);
begin
  EditColors;
end;

procedure TRMMainForm.PropertiesClick(Sender: TObject);
var
  EO : ImageExportFormatRec;
  index : integer;
begin
  index:=ListView1.ItemIndex;
  if index = -1 then index:=0;
  ImageThumbBase.GetExportOptions(index,EO);
  ImageExportForm.InitComboBoxes;
  ImageExportForm.SetExportProps(EO);
  if ImageExportForm.ShowModal = mrOK then
  begin
     ImageExportForm.GetExportProps(EO);
     ImageThumbBase.SetExportOptions(index,EO)
  end;
end;

procedure TRMMainForm.QuickPascalClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 error : word;
begin
  GetOpenSaveRegion(x,y,x2,y2);
  Case (Sender As TMenuItem).Name of 'QPPutImageArray' :ExportDialog.Filter := 'Quick Pascal PutImage Array|*.pas';
                             'QPPutImagePlusMaskArray' :ExportDialog.Filter := 'Quick Pascal PutImage+Mask Array|*.pas';
                                      'QPPutImageFile' :ExportDialog.Filter := 'Quick Pascal PutImage File|*.xgf';
  End;
  if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'QPPutImageArray' : error:=WriteXgfToCode(x,y,x2,y2,QPLan,ExportDialog.FileName);
                                 'QPPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,QPLan,ExportDialog.FileName);
                                          'QPPutImageFile' : error:=WriteXGFToFile(x,y,x2,y2,QPLan,ExportDialog.FileName);

      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;



procedure TRMMainForm.RESExportClick(Sender: TObject);
var
  Error : word;
begin
 //update the current thumb image
 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);

 Case (Sender As TMenuItem).Name of 'ExportRESInclude' : ExportDialog.Filter := 'RES Pascal Include|*.inc|RES Pascal Include|*.pas|RES C Include|*.h|RES C Include|*.c|RES BASIC Include|*.bi|RES BASIC Include|*.bas|All Files|*.*';
                                     'ExportRESBinary' : ExportDialog.Filter := 'RES Binary|*.res';
 end;

 if ExportDialog.Execute then
 begin
    Case (Sender As TMenuItem).Name of 'ExportRESInclude' : error:=RESInclude(ExportDialog.FileName,0,FALSE);
                                        'ExportRESBinary' : error:=RESBinary(ExportDialog.FileName);
    end;
    if error<>0 then
    begin
      ShowMessage('Error Exporting!');
      exit;
    end;
 end;
end;


procedure TRMMainForm.PaletteExportQuickCClick(Sender: TObject);
var
  pm : integer;
  ColorFormat : integer;
  error : word;
 begin
    Case (Sender As TMenuItem).Name of 'QCPaletteArray' : ExportDialog.Filter := 'QuickC Palette Array|*.c';
                                      'QCPaletteCommands' : ExportDialog.Filter :='QuickC Palette Commands|*.c';
                                      'QPPaletteArray' : ExportDialog.Filter := 'QuickPasca; Palette Array|*.pas';
                                      'QPPaletteCommands' : ExportDialog.Filter :='QuickPascal Palette Commands|*.pas';
    end;

    if ExportDialog.Execute then
    begin
       pm:=RMCoreBase.Palette.GetPaletteMode;
       ColorFormat:=ColorSixBitFormat;
       if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

       Case (Sender As TMenuItem).Name of 'QCPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,QCLan,ColorFormat);
                                         'QCPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,QCLan,ColorFormat);
                                         'QPPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,QPLan,ColorFormat);
                                         'QPPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,QPLan,ColorFormat);
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
        ColorFormat:=ColorEightBitFormat;
        if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

        Case (Sender As TMenuItem).Name of 'TCPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,TCLan,ColorFormat);
                                        'TCPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,TCLan,ColorFormat);

        end;

        if error<>0 then
        begin
           ShowMessage('Error Saving Palette file!');
           exit;
        end;
     end;
  end;

procedure TRMMainForm.OpenWatcomCClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'OWPutImageArray' :ExportDialog.Filter := 'Open Watcom C _putimage Array|*.c';
                              'OWPutImagePlusMaskArray' :ExportDialog.Filter := 'Open Watcom C _putimage+Mask Array|*.c';
                                       'OWPutImageFile' :ExportDialog.Filter := 'Open Watcom C _putimage File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'OWPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,OWLan,ExportDialog.FileName);
                                 'OWPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,OWLan,ExportDialog.FileName);
                                         'OWPutImageFile'  : error:=WriteXGFToFile(x,y,x2,y2,OWLan,ExportDialog.FileName);
      End;

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.PaletteExportOWCClick(Sender: TObject);
var
  pm : integer;
  ColorFormat : integer;
  error : word;
 begin
    Case (Sender As TMenuItem).Name of 'OWPaletteArray' : ExportDialog.Filter := 'Open Watcom C Palette Array|*.c';
                                      'OWPaletteCommands' : ExportDialog.Filter :='Open Watcom C Palette Commands|*.c';
    end;

    if ExportDialog.Execute then
    begin
       pm:=RMCoreBase.Palette.GetPaletteMode;
       ColorFormat:=ColorSixBitFormat;
       if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

       Case (Sender As TMenuItem).Name of 'OWPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,OWLan,ColorFormat);
                                         'OWPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,OWLan,ColorFormat);
       end;


       if error<>0 then
       begin
         ShowMessage('Error Saving Palette file!');
         exit;
       end;
    end;

end;

procedure TRMMainForm.PaletteXGA256Click(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteXGA256.Checked:=true;
 RMCoreBase.Palette.SetPaletteMode(PaletteModeXGA256);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
 UpdateZoomArea;
 UpdateThumbview;
end;

procedure TRMMainForm.PaletteXGAClick(Sender: TObject);
begin
 ClearSelectedPaletteMenu;
 PaletteXGA.Checked:=true;
 RMCoreBase.Palette.SetPaletteMode(PaletteModeXGA);

 LoadDefaultPalette;
 RMCoreBase.SetCurColor(1);
 UpdateColorBox;
 UpdateActualArea;
 UpdateZoomArea;
 UpdateThumbview;
end;

procedure TRMMainForm.PropertiesFileDialogClick(Sender: TObject);
var
 PngRGBA : PngRGBASettingsRec;
begin
 FilePropertiesDialog.GetProps(PngRGBA);  //get values before change
 if FilePropertiesDialog.ShowModal <> mrOK then
 begin
    FilePropertiesDialog.SetProps(PngRGBA); //restore values because close/cancel was selected
    FilePropertiesDialog.UpdateValues;
 end;
end;

procedure TRMMainForm.QuickCClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'QCPutImageArray' :ExportDialog.Filter := 'Quick C _putimage Array|*.c';
                              'QCPutImagePlusMaskArray' :ExportDialog.Filter := 'Quick C _putimage+Mask Array|*.c';
                                       'QCPutImageFile' :ExportDialog.Filter := 'Quick C _putimage File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'QCPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,QCLan,ExportDialog.FileName);
                                 'QCPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,QCLan,ExportDialog.FileName);
                                         'QCPutImageFile'  : error:=WriteXGFToFile(x,y,x2,y2,QCLan,ExportDialog.FileName);
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
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'TCPutImageArray' :ExportDialog.Filter := 'Turbo C putimage Array|*.c';
                              'TCPutImagePlusMaskArray' :ExportDialog.Filter := 'Turbo C putimage+Mask Array|*.c';
                                       'TCPutImageFile' : ExportDialog.Filter := 'Turbo C putimage File|*.xgf';
                                       'TCDOSLBMFile' : ExportDialog.Filter := 'Turbo C DOS Xlib LBM File|*.lbm';
                                       'TCDOSPBMFile' : ExportDialog.Filter := 'Turbo C DOS Xlib PBM File|*.pbm';
                                       'TCDOSLBMArray' : ExportDialog.Filter := 'Turbo C DOS Xlib LBM Array|*.c';
                                       'TCDOSPBMArray' : ExportDialog.Filter := 'Turbo C DOS Xlib PBM Array|*.c';

   End;
   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'TCPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,TCLan,ExportDialog.FileName);
                                 'TCPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,TCLan,ExportDialog.FileName);
                                          'TCPutImageFile' : error:=WriteXGFToFile(x,y,x2,y2,TCLan,ExportDialog.FileName);
                                          'TCDOSLBMArray' : error:=WriteLBMToCode(x,y,x2,y2,TCLan,ExportDialog.FileName);
                                          'TCDOSLBMFile' : error:=WriteLBMToFile(x,y,x2,y2,ExportDialog.FileName);
                                          'TCDOSPBMArray' : error:=WritePBMToCode(x,y,x2,y2,TCLan,ExportDialog.FileName);
                                          'TCDOSPBMFile' : error:=WritePBMToFile(x,y,x2,y2,ExportDialog.FileName);

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
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'TBPutData' :ExportDialog.Filter := 'Turbo\Power Basic Put Data Statements|*.bas';
                              'TBPutPlusMaskData' :ExportDialog.Filter := 'Turbo\Power Basic Put+Mask Data Statements|*.bas';
                                      'TBPutFile' :ExportDialog.Filter := 'Turbo\Power Basic Put File|*.xgf';
   End;


   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'TBPutData' : error:=WriteXGFToCode(x,y,x2,y2,PBLan,ExportDialog.FileName);
                                 'TBPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,PBLan,ExportDialog.FileName);
                                      'TBPutFile' : WriteXGFToFile(x,y,x2,y2,PBLan,ExportDialog.FileName);
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
 error : word;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   Case (Sender As TMenuItem).Name of 'FBPutData' :ExportDialog.Filter := 'FreeBASIC Put Data Statements|*.bas';
                              'FBPutPlusMaskData' :ExportDialog.Filter := 'FreeBASIC Put+Mask Data Statements|*.bas';
                                      'FBPutFile' :ExportDialog.Filter := 'FreeBASIC Put File|*.xgf';
   End;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'FBPutData' : error:=WriteXGFToCode(x,y,x2,y2,FBinQBModeLan,ExportDialog.FileName);
                                 'FBPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,FBinQBModeLan,ExportDialog.FileName);
                                         'FBPutFile' : error:=WriteXGFToFile(x,y,x2,y2,FBinQBModeLan,ExportDialog.FileName);
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
 VSprite : boolean;
 spritewidth : integer;
begin
 GetOpenSaveRegion(x,y,x2,y2);
 spritewidth:=x2-x+1;
 VSprite:=false;

 pm:=RMCoreBase.Palette.GetPaletteMode;
 validpm:=(pm=PaletteModeAmiga2) OR (pm=PaletteModeAmiga4) OR (pm=PaletteModeAmiga8) OR (pm=PaletteModeAmiga16) OR (pm=PaletteModeAmiga32);

 if validpm = false then
 begin
   ShowMessage('Invalid Palette Mode for this action. Choose an Amiga Palette Please');
   exit;
 end;


 Case (Sender As TMenuItem).Name of 'ABPutData' :ExportDialog.Filter := 'AmigaBASIC Put Data Statements|*.bas';
                                    'ABPutPlusMaskData' :ExportDialog.Filter := 'AmigaBASIC Put+Mask Data Statements|*.bas';
                                    'ABBobData' : ExportDialog.Filter := 'AmigaBASIC Bob Data Statements|*.bas';
                                    'ABVSpriteData' :begin
                                                       VSprite:=true;
                                                       ExportDialog.Filter := 'AmigaBASIC VSprite Data Statements|*.bas';
                                                     end;
                                    'ABPutFile' : ExportDialog.Filter := 'AmigaBASIC Put File|*.xgf';
                                    'ABBobFile' : ExportDialog.Filter := 'AmigaBASIC Bob File|*.obj';
                                    'ABVSpriteFile' :begin
                                                       VSprite:=true;
                                                       ExportDialog.Filter := 'AmigaBASIC VSprite File|*.vsp';
                                                     end;
 End;

 if (vsprite=true) then
 begin
   if ((spritewidth<>16) or (pm<>PaletteModeAmiga4)) then
   begin
     ShowMessage('Sprite Width should be 16 pixels with Palette of 4 Colors');
     exit;
   end;
 end;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'ABPutData' : error:=WriteAmigaBasicXGFDataFile(x,y,x2,y2,ExportDialog.FileName);
                                         'ABPutPlusMaskData' : error:=WriteAmigaBasicXGFPlusMaskDataFile(x,y,x2,y2,ExportDialog.FileName);
                                         'ABBobData' : error:=WriteAmigaBasicBobDataFile(x,y,x2,y2,ExportDialog.FileName,false);
                                         'ABVSpriteData' : error:=WriteAmigaBasicBobDataFile(x,y,x2,y2,ExportDialog.FileName,true);
                                         'ABPutFile' :  error:=WriteAmigaBasicXGFFile(x,y,x2,y2,ExportDialog.FileName);
                                         'ABBobFile' : error:=WriteAmigaBasicBobFile(x,y,x2,y2,ExportDialog.FileName,false);
                                         'ABVSpriteFile' :  error:=WriteAmigaBasicBobFile(x,y,x2,y2,ExportDialog.FileName,true);
      End;

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
   VSprite:=false;

   case (Sender As TMenuItem).Name of      'CBOBBitmapArray':ExportDialog.Filter := 'Amiga C Bob Bitmap Array|*.c';
                                      'CVSpriteBitmapArray' :begin
                                                               VSprite:=true;
                                                               ExportDialog.Filter := 'Amiga C VSprite Bitmap Array|*.c';
                                                             end;
                                                  'ACBobFile':ExportDialog.Filter := 'Amiga Bob Bitmap File|*.xgf';
                                              'ACVSpriteFile':begin
                                                                VSprite:=true;
                                                                ExportDialog.Filter := 'Amiga VSprite Bitmap File|*.xgf';
                                                              end;

   end;
   pm:=RMCoreBase.Palette.GetPaletteMode;
   validpm:=(pm=PaletteModeAmiga2) OR (pm=PaletteModeAmiga4) OR (pm=PaletteModeAmiga8) OR (pm=PaletteModeAmiga16) OR (pm=PaletteModeAmiga32);
   if validpm = false then
   begin
      ShowMessage('Invalid Palette Mode for this action. Choose an Amiga Palette Please');
      exit;
   end;

   if (vsprite=true) then
   begin
     if ((spritewidth<>16) or (pm<>PaletteModeAmiga4)) then
     begin
      ShowMessage('Sprite Width should be 16 pixels with Palette of 4 Colors');
      exit;
     end;
   end;


   if ExportDialog.Execute then
   begin
      case (Sender As TMenuItem).Name of 'CBOBBitmapArray',
                                         'CVSpriteBitmapArray':error:=WriteAmigaCBobCodeToFile(x,y,x2,y2,ExportDialog.FileName,VSprite);
                                                   'ACBobFile',
                                               'ACVSpriteFile':begin
                                                                 error:=WriteAmigaBobFile(x,y,x2,y2,ExportDialog.FileName,VSprite);
                                                               end;

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

   VSprite:=false;
   case (Sender As TMenuItem).Name of      'PascalBOBBitmapArray':ExportDialog.Filter := 'Amiga Pascal Bob Bitmap Array|*.pas';
                                       'PascalVSpriteBitmapArray':begin
                                                                    VSprite:=true;
                                                                    ExportDialog.Filter := 'Amiga Pascal VSprite Bitmap Array|*.pas';
                                                                  end;
                                            'PascalBOBBitmapFile':ExportDialog.Filter := 'Amiga Pascal Bob Bitmap File|*.xgf';
                                        'PascalVSpriteBitmapFile':begin
                                                                    VSprite:=true;
                                                                    ExportDialog.Filter := 'Amiga Pascal VSprite Bitmap File|*.xgf';
                                                                  end;
   end;

   pm:=RMCoreBase.Palette.GetPaletteMode;

   validpm:=(pm=PaletteModeAmiga2) OR (pm=PaletteModeAmiga4) OR (pm=PaletteModeAmiga8) OR (pm=PaletteModeAmiga16) OR (pm=PaletteModeAmiga32);
   if validpm = false then
   begin
      ShowMessage('Invalid Palette Mode for this action. Choose an Amiga Palette Please');
      exit;
   end;

   if (vsprite=true) then
   begin
     if ((spritewidth<>16) or (pm<>PaletteModeAmiga4)) then
     begin
      ShowMessage('Sprite Width should be 16 pixels with Palette of 4 Colors');
      exit;
     end;
   end;


   if ExportDialog.Execute then
   begin
      case (Sender As TMenuItem).Name of  'PascalBOBBitmapArray',
                                          'PascalVSpriteBitmapArray':error:=WriteAmigaPascalBobCodeToFile(x,y,x2,y2,ExportDialog.FileName,VSprite);
                                          'PascalBOBBitmapFile',
                                          'PascalVSpriteBitmapFile':error:=WriteAmigaBobFile(x,y,x2,y2,ExportDialog.FileName,VSprite);
      end;

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

procedure TRMMainForm.AqbPsetBitMapClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 error : word;
 validpm : boolean;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   ExportDialog.Filter := 'Amiga QuickBasic Pset Bittmap Array|*.bas';

   pm:=RMCoreBase.Palette.GetPaletteMode;
   validpm:=(pm=PaletteModeAmiga2) OR (pm=PaletteModeAmiga4) OR (pm=PaletteModeAmiga8) OR (pm=PaletteModeAmiga16) OR (pm=PaletteModeAmiga32);
   if validpm = false then
   begin
      ShowMessage('Invalid Palette Mode for this action. Choose an Amiga Palette Please');
      exit;
   end;

   if ExportDialog.Execute then
   begin
      error:=WriteAQBBitMapCodeToFile(x,y,x2,y2,ExportDialog.FileName);
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
                                         'FPPaletteArray' : ExportDialog.Filter := 'FreePascal Palette Array|*.pas';
                                         'FPPaletteCommands' : ExportDialog.Filter :='FreePascal Palette Commands|*.pas';
   end;
   if ExportDialog.Execute then
   begin
      ColorFormat:=ColorEightBitFormat;
      pm:=RMCoreBase.Palette.GetPaletteMode;
      if (pm=PaletteModeEGA) then ColorFormat:=ColorIndexFormat;

      Case (Sender As TMenuItem).Name of 'TPPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,TPLan,ColorFormat);
                                      'TPPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,TPLan,ColorFormat);
                                      'FPPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,FPLan,ColorFormat);
                                      'FPPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,FPLan,ColorFormat);
      end;

      if error<>0 then
      begin
         ShowMessage('Error Saving Palette file!');
         exit;
      end;
   end;
end;

procedure TRMMainForm.MouseSaveClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 pm : integer;
 error : word;
 validpm : boolean;
 mwidth   : integer;
 mheight  : integer;
begin
   GetOpenSaveRegion(x,y,x2,y2);
   mwidth:=x2-x+1;
   mheight:=y2-y+1;

   pm:=RMCoreBase.Palette.GetPaletteMode;
   validpm:=(pm=PaletteModeCGA0) OR (pm=PaletteModeCGA1) OR (pm=PaletteModeAmiga4);
   if validpm = false then
   begin
      ShowMessage('Invalid Mode for Mouse Shape. Choose a Palette mode with 4 colors!');
      exit;
   end;

   if (mwidth<>16) OR (mheight<>16) then
   begin
      ShowMessage('Mouse Shape Width and Height should be 16 pixels!');
      exit;
   end;

   Case (Sender As TMenuItem).Name of 'QBMouseShapeData',
                                      'FBMouseShapeData',
                                      'TBMouseShapeData',
                                      'GWMouseShapeData'  : ExportDialog.Filter := 'Basic Mouse Shape Data Statements|*.bas';
                                      'TPMouseShapeArray',
                                      'QPMouseShapeArray',
                                      'FPMouseShapeArray' : ExportDialog.Filter := 'Pascal Mouse Shape Array|*.pas';
                                      'TCMouseShapeArray',
                                      'QCMouseShapeArray',
                                      'OWMouseShapeArray': ExportDialog.Filter := 'C Mouse Shape Array|*.c';
                                      'GWMouseShapeFile',
                                      'FPMouseShapeFile',
                                      'FBMouseShapeFile',
                                      'TPMouseShapeFile',
                                      'QPMouseShapeFile',
                                      'QBMouseShapeFile',
                                      'TBMouseShapeFile',
                                      'TCMouseShapeFile',
                                      'QCMouseShapeFile',
                                      'OWMouseShapeFile': ExportDialog.Filter := 'Mouse Shape File|*.mou';
   end;



   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'QBMouseShapeData',
                                         'FBMouseShapeData',
                                         'TBMouseShapeData': error:=WriteMShapeToCode(x,y,QBLan,1,ExportDialog.FileName);
                                         'GWMouseShapeData': error:=WriteMShapeToCode(x,y,GWLan,1,ExportDialog.FileName);
                                        'TPMouseShapeArray',
                                        'QPMouseShapeArray': error:=WriteMShapeToCode(x,y,TPLan,1,ExportDialog.FileName);
                                        'TCMouseShapeArray',
                                        'QCMouseShapeArray',
                                        'OWMouseShapeArray': error:=WriteMShapeToCode(x,y,TCLan,1,ExportDialog.FileName);
                                        'GWMouseShapeFile',
                                        'FPMouseShapeFile',
                                        'FBMouseShapeFile',
                                        'TPMouseShapeFile',
                                        'QPMouseShapeFile',
                                        'QBMouseShapeFile',
                                        'TBMouseShapeFile',
                                        'TCMouseShapeFile',
                                        'QCMouseShapeFile',
                                        'OWMouseShapeFile':error:=WriteMShapeToFile(x,y,ExportDialog.FileName);

      end;
      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
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
begin
 GetOpenSaveRegion(x,y,x2,y2);
 RMDrawTools.Paste(x,y,x2,y2);

 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);

 UpdateActualArea;
 UpdateZoomArea;
 UpdateThumbView;
end;

procedure TRMMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 if MessageDlg('Exiting Raster Master', 'Are you sure you want to Exit?', mtConfirmation,
     [mbYes, mbNo],0) = mrNo  then  CloseAction := caNone;
end;

Procedure TRMMainForm.CopyScrollPositionToCore;
var
 sp : TScrollPosRec;
begin
  sp.HorizPos:=ZoomScrollBox.HorzScrollBar.Position;
  sp.VirtPos:=ZoomScrollBox.VertScrollBar.Position;
  RMDrawTools.SetScrollPos(sp);
end;

Procedure TRMMainForm.CopyScrollPositionFromCore;
var
 sp : TScrollPosRec;
begin
  RMDrawTools.GetScrollPos(sp);
  ZoomScrollBox.HorzScrollBar.Position:=sp.HorizPos;
  ZoomScrollBox.VertScrollBar.Position:=sp.VirtPos;
end;

procedure TRMMainForm.ListView1Click(Sender: TObject);
var
  item : TListItem;
begin
 if (Listview1.SelCount > 0)  then
 begin
   item:=ListView1.LastSelected;
   CopyScrollPositionToCore;
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent); //copy again before we switch to new image
   ImageThumbBase.CopyIndexImageToCore(Item.Index);
   ImageThumbBase.SetCurrent(item.Index);

   ActualBox.Width:=RMCoreBase.GetWidth;
   ActualBox.Height:=RMCoreBase.GetHeight;

   ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
   ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;
   ZoomPaintBox.Canvas.Clear;

   RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
   RMDrawTools.SetZoomMaxX(ZoomPaintBox.Width);
   RMDrawTools.SetZoomMaxY(ZoomPaintBox.Height);

   ZoomSize:=RMDrawTools.GetZoomSize;
   CopyScrollPositionFromCore;

   CoreToPalette;
   UpdateColorBox;
   UpdateToolSelectionIcons;
   UpdatePalette;
   UpdatePaletteMenu;
   UpdateActualArea;
   UpdateZoomArea;
   UpdateZoomScroller;
   UpdateThumbView;
 end;
end;

procedure TRMMainForm.DeleteAllClick(Sender: TObject);
var
  ImgWidth,ImgHeight : integer;
begin
 if MessageDlg('Delete All Images', 'Are you sure you want to do this?', mtConfirmation,
   [mbYes, mbNo],0) = mrNo    then  Exit;

 ImgWidth:=256;
 ImgHeight:=256;
 ActualBox.Width:=ImgWidth;
 ActualBox.Height:=ImgHeight;
 RMCoreBase.SetWidth(ImgWidth);
 RMCoreBase.SetHeight(ImgHeight);

 RMCoreBase.ClearBuf(0);
 RMCoreBase.SetCurColor(1);
 RMDrawTools.SetDrawTool(DrawShapePencil);
 UpdateToolSelectionIcons;

 UpdateColorBox;
 UpdateActualArea;
 RMDrawTools.SetClipStatus(0);
 RMDrawTools.SetZoomSize(2);
 RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
 UpdateZoomArea;
 Trackbar1.Position:=RMDrawTools.getZoomSize;

 ImageThumbBase.SetCount(1);
 ImageThumbBase.SetCurrent(0);

 ImageList1.Clear;

 ListView1.Items.Clear;
 ListView1.Items.Add;

 ImageThumbBase.CopyCoreToIndexImage(0);
 ImageThumbBase.MakeThumbImageFromCore(0,imagelist1,1);   //ads an image to image list with option 1 3rd paremeter

 ListView1.Items[0].Caption:='Image '+IntToStr(1);
 ListView1.Items[0].ImageIndex :=0;

end;

procedure TRMMainForm.MapEditMenuClick(Sender: TObject);
begin
 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
 MapEdit.UpdateTileView;
 MapEdit.Show;
 MapEdit.WindowState:=wsNormal;
end;

procedure TRMMainForm.RayLibExportClick(Sender: TObject);
var
  x,y,x2,y2 : integer;
  format,Lan : integer;
  error : integer;
begin
  GetOpenSaveRegion(x,y,x2,y2);
  Case (Sender As TMenuItem).Name of 'fpRayLibFuchsia' :begin
                                                           ExportDialog.Filter := 'FreePascal Array|*.pas';
                                                           Lan:=FPLan;
                                                           format:=1;
                                                         end;
                                      'fpRayLibIndex0' :begin
                                                           ExportDialog.Filter := 'FreePascal Array|*.pas';
                                                           Lan:=FPLan;
                                                           format:=2;
                                                         end;
                                         'fpRayLibRGB' :begin
                                                            ExportDialog.Filter := 'FreePascal Array|*.pas';
                                                            Lan:=FPLan;
                                                            format:=3;
                                                         end;
                                        'gccRayLibFuchsia':begin
                                                             ExportDialog.Filter := 'gcc Array|*.c';
                                                             Lan:=gccLan;
                                                             format:=1;
                                                           end;
                                         'gccRayLibIndex0':begin
                                                             ExportDialog.Filter := 'gcc Array|*.c';
                                                             Lan:=gccLan;
                                                             format:=2;
                                                           end;
                                         'gccRayLibRGB' : begin
                                                             ExportDialog.Filter := 'gcc Array|*.c';
                                                             Lan:=gccLan;
                                                             format:=3;
                                                           end;
                                         'qbRayLibFuchsia':begin
                                                              ExportDialog.Filter := 'Basic Array|*.bas';
                                                              Lan:=QB64Lan;
                                                              format:=1;
                                                            end;
                                          'qbRayLibIndex0':begin
                                                              ExportDialog.Filter := 'Basic Array|*.bas';
                                                              Lan:=QB64Lan;
                                                              format:=2;
                                                            end;
                                          'qbRayLibRGB' : begin
                                                            ExportDialog.Filter := 'Basic Array|*.bas';
                                                            Lan:=QB64Lan;
                                                            format:=3;
                                                          end;

                                          'fbRayLibFuchsia':begin
                                                               ExportDialog.Filter := 'Basic Array|*.bas';
                                                               Lan:=FBLan;
                                                               format:=1;
                                                            end;

                                           'fbRayLibIndex0':begin
                                                              ExportDialog.Filter := 'Basic Array|*.bas';
                                                              Lan:=FBLan;
                                                              format:=2;
                                                            end;
                                           'fbRayLibRGB' : begin
                                                              ExportDialog.Filter := 'Basic Array|*.bas';
                                                              Lan:=FBLan;
                                                              format:=3;
                                                            end;

   end;
   if ExportDialog.Execute then
   begin
      //SetCoreActive;
      WriteRayLibCodeToFile(ExportDialog.FileName,x,y,x2,y2,Lan,format);
      {$I+}
      error:=IORESULT;
      {$I-}

      if error<>0 then
      begin
        ShowMessage('Error Saving file!');
        exit;
      end;
   end;
end;

procedure TRMMainForm.RMPanelClick(Sender: TObject);
begin
  RMPanel.Hide;
end;

function rm_getopenfilename(var filename,ext : string; filter : string) : boolean;
begin
 rm_getopenfilename:=RMMainForm.getopenfilename(filename,ext,filter);
end;

function rm_getsavefilename(var filename,ext : string; filter : string) : boolean;
begin
 rm_getsavefilename:=RMMainForm.getsavefilename(filename,ext,filter);
end;

procedure TRMMainForm.RMScriptCompile(Sender: TPSScript);
begin
  Sender.AddFunction(@rm_putpixel, 'procedure putpixel(x,y,color : integer)');
  Sender.AddFunction(@rm_getpixel, 'function getpixel(x,y : integer) : integer');

  Sender.AddFunction(@rm_getwidth,'function getwidth : integer');
  Sender.AddFunction(@rm_getheight,'function getheight : integer');

  Sender.AddFunction(@rm_getopenfilename, 'function getopenfilename(var filename,ext : string; filter : string) : boolean');
  Sender.AddFunction(@rm_getsavefilename, 'function getsavefilename(var filename,ext : string; filter : string) : boolean');

  Sender.AddFunction(@rm_showmessage,'procedure showmessage(const aMsg : string)');

  Sender.AddFunction(@rm_cg_open,'function cgopen(filename : string) : boolean');
  Sender.AddFunction(@rm_cg_options,'procedure cgoptions(name, value : string)');
  Sender.AddFunction(@rm_cg_close,'procedure cgclose');
  Sender.AddFunction(@rm_cg_write,'procedure cgwrite(Line : string)');
  Sender.AddFunction(@rm_cg_writeln,'procedure cgwriteln');
  Sender.AddFunction(@rm_cg_write_byte,'procedure cgwritebyte(value : byte)');
  Sender.AddFunction(@rm_cg_write_integer,'procedure cgwriteinteger(value : integer)');

  Sender.AddFunction(@rm_getselectarea,'procedure getselectarea(var active,x1,y1,x2,y2 : integer)');

  Sender.AddFunction(@rm_getmaxcolor,'function  getmaxcolor : integer');
  Sender.AddFunction(@rm_getcolorrgb,'procedure getcolorrgb(index : integer;var r,g,b : byte)');
  Sender.AddFunction(@rm_setcolorrgb,'procedure setcolorrgb(index : integer; r,g,b : byte)');

  Sender.AddFunction(@rm_getpalettemode,'function getpalettemode : integer');
  Sender.AddFunction(@rm_setpalettemode, 'procedure setpalettemode(mode : integer)');

//FileCreate/FileWrite/FileClose lifted from Lazarus Pascal Script Example Page - don't seem to work - you let me know
  Sender.AddFunction(@FileCreate, 'Function FileCreate(const FileName: string): integer)');
  Sender.AddFunction(@FileWrite, 'function FileWrite(Handle: Integer; const Buffer: pChar; Count: LongWord): Integer)');
  Sender.AddFunction(@FileClose, 'Procedure FileClose(handle: integer)');
end;


procedure TRMMainForm.ScriptMenuLoadClick(Sender: TObject);
var
 ext : string;
begin
 OpenDialog1.Filter := 'Pascal Script|*.pas|All Files|*.*' ;
 if OpenDialog1.Execute then
 begin
   ext:=UpperCase(ExtractFileExt(OpenDialog1.FileName));
   if ext = '.PAS' then  RMScript.Script.LoadFromFile(OpenDialog1.FileName);
 end;
end;

procedure TRMMainForm.ScriptMenuRunClick(Sender: TObject);
var
  ErrorMsg : string;
  i : integer;
begin
  if RMScript.compile then
  begin
    SetCoreActive;
    if not RMScript.execute then
    begin
      ShowMessage('Run-time error:' + RMScript.ExecErrorToString);
    end
    else
    begin
      UpdateActualArea;
      UpdateZoomArea;
      UpdateThumbview;
    end;
  end
  else
  begin
   ErrorMsg:='';
   if RMScript.CompilerMessageCount > 0 then
   for i:= 0 to RMScript.CompilerMessageCount-1 do
          ErrorMsg:=ErrorMsg+RMScript.CompilerErrorToStr(i)+sLineBreak ;
    ShowMessage('Failed to compile!'+sLineBreak+ErrorMsg);
  end;
end;

procedure TRMMainForm.UpdateImportedImage;
var
  count : integer;
begin
 ImageThumbBase.UpdateAllThumbImages(imagelist1);
 ListView1.Items.Add;
 Count:=ListView1.Items.Count;
 Listview1.Items[count-1].Caption:='Image '+IntToStr(count);
 Listview1.Items[count-1].ImageIndex:=count-1;
end;

procedure TRMMainForm.SpriteImportMenuClick(Sender: TObject);
begin
  SpriteImportForm.Show;
  SpriteImportForm.WindowState:=wsNormal;
end;

procedure TRMMainForm.ThumbPopUpMenuExportClick(Sender: TObject);
var
 Error : word;
 index : integer;
begin
 //update the current thumb image
 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
 ExportDialog.Filter := 'RES Pascal Include|*.inc|RES Pascal Include|*.pas|RES C Include|*.h|RES C Include|*.c|RES BASIC Include|*.bi|RES BASIC Include|*.bas|All Files|*.*';

 if ExportDialog.Execute then
 begin
   index:=ListView1.ItemIndex;
   if index = -1 then index:=0;
   error:=RESInclude(ExportDialog.FileName,index,TRUE);
   if error<>0 then
   begin
     ShowMessage('Error Exporting!');
     exit;
   end;
 end;
end;

procedure TRMMainForm.ThumbPopUpMenusaveClick(Sender: TObject);
begin
 SaveFileClick(Self);
end;

procedure TRMMainForm.PalettePasteClick(Sender: TObject);
begin
  RMCoreBase.Palette.PasteFromCBToPalette;
  CoreToPalette;
  UpdatePalette;
  UpdateColorBox;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.OpenProjectFileClick(Sender: TObject);
var
  InsertMode : boolean;
  amount : integer;
  i : integer;
begin
   InsertMode:=FALSE;
   if (Sender As TMenuItem).Name = 'InsertProjectFile' then insertMode:=TRUE;
   OpenDialog1.Filter := 'Raster Master Project|*.rmp';
   if NOT OpenDialog1.Execute then exit;

   CopyScrollPositionToCore;
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
   ImageThumbBase.OpenProject(OpenDialog1.Filename,InsertMode);
   ImageThumbBase.UpdateAllThumbImages(imagelist1);

   amount:=ImageThumbBase.GetCount-ListView1.Items.Count;
   if amount < 0 then
   begin
     for i:=1 to abs(amount) do
     begin
       listview1.Items.Delete(0);
     end;
   end
   else if amount > 0 then
   begin
   //add amount to
     for i:=1 to amount do
     begin
       ListView1.Items.Add;
     end;
   end;

   For i:=0 to ListView1.Items.Count-1 do
   begin
     Listview1.Items[i].Caption:='Image '+IntToStr(i+1);
     Listview1.Items[i].ImageIndex:=i;
   end;

   if insertmode = false then
   begin
      ImageThumbBase.SetCurrent(0);
      ImageThumbBase.CopyIndexImageToCore(0);  //update view with this image

      ActualBox.Width:=RMCoreBase.GetWidth;
      ActualBox.Height:=RMCoreBase.GetHeight;

      RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
      RMDrawTools.SetZoomMaxX(ZoomPaintBox.Width);
      RMDrawTools.SetZoomMaxY(ZoomPaintBox.Height);

      ZoomSize:=RMDrawTools.GetZoomSize;
      CopyScrollPositionFromCore;

      CoreToPalette;
      UpdateColorBox;
      UpdateToolSelectionIcons;
      UpdatePalette;
      UpdatePaletteMenu;
      UpdateActualArea;
      UpdateZoomArea;
      UpdateZoomScroller;
      UpdateThumbView;
      UpdateToolFlipScrollMenu;
    end;
end;

procedure TRMMainForm.PaletteCopyClick(Sender: TObject);
begin
  RMCoreBase.Palette.CopyPaletteToCB;
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

procedure TRMMainForm.FileDeleteClick(Sender: TObject);
var
  item  : TListItem;
  i,index : integer;
begin


 if ImageThumbBase.GetCount = 1 then
 begin
    if (Listview1.SelCount > 0) then
    begin
      Clear;
    end
    else
    begin
      if MessageDlg('No Image Selected', 'Delete Current Image?', mtConfirmation,
        [mbYes, mbNo],0) = mrNo  then  Exit;
      Clear;
    end;
     // display message to select clear as it is the only item
 end
 else
 begin
   if (Listview1.SelCount = 0)  then
   begin
     if MessageDlg('No Image Selected','Please Select Image to Delete', mtConfirmation, [mbOk],0) = mrOk  then exit;
   end;

   if MessageDlg('Delete Selected Image', 'Are you sure you want to do this?', mtConfirmation, [mbYes, mbNo],0) = mrNo  then exit;

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
      RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
      RMDrawTools.SetZoomMaxX(ZoomPaintBox.Width);
      RMDrawTools.SetZoomMaxY(ZoomPaintBox.Height);

      ZoomSize:=RMDrawTools.GetZoomSize;

      CoreToPalette;
      UpdateColorBox;
      UpdatePalette;
      UpdateActualArea;
      UpdateZoomArea;
   end;
 end;
end;

procedure TRMMainForm.SaveProjectFileClick(Sender: TObject);
begin
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
   SaveDialog1.Filter := 'Raster Master Project|*.rmp';
   if SaveDialog1.Execute then
   begin
      ImageThumbBase.SaveProject(SaveDialog1.Filename);
   end;
end;

procedure TRMMainForm.NewClick(Sender: TObject);
begin
 if ImageThumbBase.GetCount >= MaxThumbImages then exit;

 CopyScrollPositionToCore;
 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent); //copy again before we switch to new image

 RMCoreBase.ClearBuf(0);
 RMCoreBase.SetCurColor(1);
 RMDrawTools.SetDrawTool(DrawShapePencil);
 RMDrawTools.SetClipStatus(0);
 UpdateToolSelectionIcons;

 UpdateColorBox;
 UpdateActualArea;
 UpdateZoomArea;

 Trackbar1.Position:=RMDrawTools.getZoomSize;
 ZoomScrollBox.HorzScrollBar.Position:=0;
 ZoomScrollBox.VertScrollBar.Position:=0;

 ImageThumbBase.AddImage;
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
 RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
 UpdateZoomArea;
// UnFreezeScrollAndZoom;
 Trackbar1.Position:=RMDrawTools.getZoomSize;
 ZoomScrollBox.HorzScrollBar.Position:=0;
 ZoomScrollBox.VertScrollBar.Position:=0;
 UpdateThumbView;
end;

procedure TRMMainForm.EditClearClick(Sender: TObject);
begin
 Clear;
end;

function TRMMainForm.getopenfilename(var filename,ext : string; filter : string) : boolean;
begin
 filename:='';
 ext:='';
 OpenDialog1.Filter := filter;
 getopenfilename:=OpenDialog1.Execute;
 if getopenfilename then
 begin
     filename:=OpenDialog1.FileName;
     ext:=ExtractFileExt(OpenDialog1.FileName)
 end;
end;

function TRMMainForm.getsavefilename(var filename,ext : string; filter : string) : boolean;
begin
 filename:='';
 ext:='';
 SaveDialog1.Filter := filter;
 getsavefilename:=SaveDialog1.Execute;
 if getsavefilename then
 begin
     filename:=SaveDialog1.FileName;
     ext:=ExtractFileExt(SaveDialog1.FileName)
 end;
end;

end.

