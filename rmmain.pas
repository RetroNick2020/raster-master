unit rmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uPSComponent, uPSRuntime, uPSComponent_Forms,
  Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ComCtrls, Menus,
  ActnList, StdActns, ColorPalette, Types, LResources, lclintf, rmtools, rmcore, flood,
  rmcolor, rmcolorvga, rmcolorxga, rmamigaColor, uAbout, rwpal, rwraw, rwpcx, rwbmp,
  rmamigarwxgf, wjavascriptarray, rmthumb, wmodex, rwgif, rwxgf, rmexportprops,
  rres, rwpng, wmouse, mapeditor, spriteimport,spritesheetexport,fontsheetexport, wraylib, rwilbm, rwaqb, rmapi,rmxgfcore,
  fileprops,rmconfig,rmclipboard,soundgen,animate,setcustomspritesize,SetCustomCellSize,QBasicInterp, uPSCompiler, Clipbrd, LCLType,
  rwjson, uRetrobrush, brusheffects;

const
  NoScript = 0;
  PascalScript = 1;
  QBScript = 2;

type

  { TRMMainForm }

  TRMMainForm = class(TForm)
    Action1: TAction;
    ActionList1: TActionList;
    ActualBox: TImage;
    ActualPane: TPanel;
    GradientMethod: TComboBox;
    DitherPatternPaintBox: TPaintBox;
    MenuItem19: TMenuItem;
    PaletteCopyToClipboard: TMenuItem;
    PalettePasteFromClipboard: TMenuItem;
    DrawMethod: TRadioGroup;
    rmToggle: TMenuItem;
    ToolBrushIcon: TImage;
    ToolBrushFXIcon: TImage;
    ToolVFLIP: TButton;
    EditColorBox1: TButton;
    EditColorBox2: TButton;
    ColorBox1: TShape;
    ColorBox2: TShape;
    ColorPalette1: TColorPalette;
    Panel1: TPanel;
    StatusBar: TStatusBar;
    TextDrawEdit: TEdit;
    FontDialog1: TFontDialog;
    FreePascal: TMenuItem;
    GWBASIC: TMenuItem;
    FreeBASIC: TMenuItem;
    AmigaBasic: TMenuItem;
    ImageList1: TImageList;
    TransImageList1: TImageList;
    ListView1: TListView;
    MenuEdit: TMenuItem;
    EditCopy: TMenuItem;
    EditPaste: TMenuItem;
    EditPastePalette: TMenuItem;
    EditColor: TMenuItem;
    EditUndo: TMenuItem;
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
    MenuItem1: TMenuItem;
    MenuItem12: TMenuItem;
    fpRayLibCustom: TMenuItem;
    gccRayLibCustom: TMenuItem;
    EditProperties: TMenuItem;
    TransparentToggle: TMenuItem;
    BAMRGBPutData: TMenuItem;
    DeleteImage: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    EditResizeTo8: TMenuItem;
    EditResizeTo16: TMenuItem;
    EditResizeTo32: TMenuItem;
    EditResizeTo64: TMenuItem;
    EditResizeTo128: TMenuItem;
    EditResizeTo256: TMenuItem;
    FontSheetExportMenu: TMenuItem;
    ToolTextMenu: TMenuItem;
    ShowCustomSize: TMenuItem;
    EditResizeCustom: TMenuItem;
    MenuItem27: TMenuItem;
    gcNormal: TMenuItem;
    gcWide: TMenuItem;
    gcTall: TMenuItem;
    gcCustomShow: TMenuItem;
    gcCustom: TMenuItem;
    SpriteAnimationMenu: TMenuItem;
    SpriteExportMenu: TMenuItem;
    SoundGenerator: TMenuItem;
    QBJS: TMenuItem;
    qbjsRGBAFuchsia: TMenuItem;
    qbjsRGBAIndex0: TMenuItem;
    qbjsRGBACustom: TMenuItem;
    qbjsRGB: TMenuItem;
    qb64RGBACustom: TMenuItem;
    PaletteExportTMTPascal: TMenuItem;
    TMTPaletteArray: TMenuItem;
    TMTPaletteCommands: TMenuItem;
    TMTPutImageFile: TMenuItem;
    TMTPutImageArray: TMenuItem;
    QB64: TMenuItem;
    MenuItem13: TMenuItem;
    AqbPsetBitMap: TMenuItem;
    GWMouseShapeFile: TMenuItem;
    FBMouseShapeFile: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    ACBobFile: TMenuItem;
    ACVSpriteFile: TMenuItem;
    BAMPutData: TMenuItem;
    BAMPutPlusMaskData: TMenuItem;
    MenuItem16: TMenuItem;
    BAMPaletteData: TMenuItem;
    BAMPaletteCommands: TMenuItem;
    EditClone: TMenuItem;
    BulkExportPNG: TMenuItem;
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
    SelectDirectoryDialog: TSelectDirectoryDialog;
    ToolTextIcon: TImage;
    ToolFontIcon: TImage;
    ToolHFLIP: TButton;
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
    qb64RGB: TMenuItem;
    qb64RGBAIndex0: TMenuItem;
    qb64RGBAFuchsia: TMenuItem;
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
    ZoomTrackBar: TTrackBar;
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
    PaletteCopyJASC: TMenuItem;
    PalettePasteJASC: TMenuItem;
    QPPutImageArray: TMenuItem;
    QPPutImageFile: TMenuItem;
    QuickPascal: TMenuItem;
    Properties: TMenuItem;
    DeleteAll: TMenuItem;
    OpenProjectFile: TMenuItem;
    SaveProjectFile: TMenuItem;
    OpenProjectJSONFile: TMenuItem;
    InsertProjectJSONFile: TMenuItem;
    SaveProjectJSONFile: TMenuItem;
    ExportJSONSprite: TMenuItem;

    DitherPatternPanel: TPanel;
    DrawMethodPreview: TPaintBox;
    BrushMenu: TMenuItem;
    MnuBrushGrabSelection: TMenuItem;
    MnuBrushGrabSprite: TMenuItem;
    MnuBrushGrabClipboard: TMenuItem;
    MnuBrushSep1: TMenuItem;
    MnuBrushOpen: TMenuItem;
    MnuBrushSave: TMenuItem;
    MnuBrushSep1b: TMenuItem;
    MnuBrushEffects: TMenuItem;
    MnuBrushSep2: TMenuItem;
    MnuBrushStampTool: TMenuItem;
    MnuBrushSep3: TMenuItem;
    MnuBrushSetTransColor: TMenuItem;
    MnuBrushClear: TMenuItem;
    ExportJSONRES: TMenuItem;
    PaletteExportJSON: TMenuItem;
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
    MaterialsMenu: TMenuItem;
    MnuMatDirt: TMenuItem;
    MnuMatDirtSide: TMenuItem;
    MnuMatDirtTop: TMenuItem;
    MnuMatRock: TMenuItem;
    MnuMatRockSide: TMenuItem;
    MnuMatRockTop: TMenuItem;
    MnuMatGrass: TMenuItem;
    MnuMatGrassSide: TMenuItem;
    MnuMatGrassTop: TMenuItem;
    MnuMatSnow: TMenuItem;
    MnuMatSnowSide: TMenuItem;
    MnuMatSnowTop: TMenuItem;
    MnuMatIce: TMenuItem;
    MnuMatIceSide: TMenuItem;
    MnuMatIceTop: TMenuItem;
    MnuMatWood: TMenuItem;
    MnuMatWoodSide: TMenuItem;
    MnuMatWoodTop: TMenuItem;
    MnuMatMetal: TMenuItem;
    MnuMatMetalSide: TMenuItem;
    MnuMatMetalTop: TMenuItem;
    MnuMatSilver: TMenuItem;
    MnuMatSilverSide: TMenuItem;
    MnuMatSilverTop: TMenuItem;
    MnuMatGold: TMenuItem;
    MnuMatGoldSide: TMenuItem;
    MnuMatGoldTop: TMenuItem;
    MnuMatWater: TMenuItem;
    MnuMatWaterSide: TMenuItem;
    MnuMatWaterTop: TMenuItem;
    MnuMatCrate: TMenuItem;
    MnuMatCrateSide: TMenuItem;
    MnuMatCrateTop: TMenuItem;
    MnuMatBrownBrick: TMenuItem;
    MnuMatBrownBrickSide: TMenuItem;
    MnuMatBrownBrickTop: TMenuItem;
    MnuMatStoneBrick: TMenuItem;
    MnuMatStoneBrickSide: TMenuItem;
    MnuMatStoneBrickTop: TMenuItem;
    MnuMatWoodFloor: TMenuItem;
    MnuMatWoodFloorSide: TMenuItem;
    MnuMatWoodFloorTop: TMenuItem;
    MnuMatCeramicTile: TMenuItem;
    MnuMatCeramicTileSide: TMenuItem;
    MnuMatCeramicTileTop: TMenuItem;
    PaletteResetDefault: TMenuItem;
    PaletteSortColors: TMenuItem;
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
    procedure BAMPutDataClick(Sender: TObject);
    procedure BulkExportPNGClick(Sender: TObject);
    procedure EditColorBox1Click(Sender: TObject);
    procedure ColorBox1MouseEnter(Sender: TObject);
    procedure ColorBox2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorBox2MouseEnter(Sender: TObject);
    procedure ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure ColorPalette1GetHintText(Sender: TObject; AColor: TColor;
      var AText: String);
    procedure DeleteImageClick(Sender: TObject);
    procedure EditColorBox2Click(Sender: TObject);
    procedure rmToggleClick(Sender: TObject);

    procedure TextDrawEditChange(Sender: TObject);
    procedure EditClearClick(Sender: TObject);
    procedure EditCloneClick(Sender: TObject);
    procedure TransparentToggleClick(Sender: TObject);
    procedure EditCopyClick(Sender: TObject);
    procedure EditPasteClick(Sender: TObject);
    procedure EditPastePaletteClick(Sender: TObject);
    procedure FontSheetExportMenuClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);


    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FreeBASICClick(Sender: TObject);
    procedure FreePascalClick(Sender: TObject);
    procedure SetCustomGridCellClick(Sender: TObject);
    procedure SetGridCellClick(Sender: TObject);
    procedure GWBASICClick(Sender: TObject);
    procedure EditResizeToNewSize(Sender: TObject);
    procedure javaScriptArrayClick(Sender: TObject);

    procedure ListView1Click(Sender: TObject);
    procedure DeleteAllClick(Sender: TObject);
    procedure MapEditMenuClick(Sender: TObject);
    procedure EditResizeCustomClick(Sender: TObject);
    procedure SoundGeneratorClick(Sender: TObject);
    procedure SpriteAnimationMenuClick(Sender: TObject);
    procedure SpriteExportMenuClick(Sender: TObject);
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
    procedure OpenProjectJSONClick(Sender: TObject);
    procedure SaveProjectJSONClick(Sender: TObject);
    procedure ExportJSONSpriteClick(Sender: TObject);
    procedure DrawMethodClick(Sender: TObject);
    procedure DrawMethodPreviewPaint(Sender: TObject);
    procedure GradientMethodChange(Sender: TObject);
    procedure DitherPatternPaintBoxPaint(Sender: TObject);
    procedure DitherPatternPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BrushOpenClick(Sender: TObject);
    procedure BrushSaveClick(Sender: TObject);
    procedure BrushEffectsClick(Sender: TObject);
    procedure BrushGrabSelectionClick(Sender: TObject);
    procedure BrushGrabSpriteClick(Sender: TObject);
    procedure BrushGrabClipboardClick(Sender: TObject);
    procedure BrushStampToolClick(Sender: TObject);
    procedure BrushSetTransColorClick(Sender: TObject);
    procedure BrushClearClick(Sender: TObject);
    procedure ExportJSONRESClick(Sender: TObject);
    procedure PaletteSaveJSONClick(Sender: TObject);
    procedure PaletteCopyClick(Sender: TObject);
    procedure PaletteCopyJASCClick(Sender: TObject);
    procedure PalettePasteJASCClick(Sender: TObject);
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
    procedure MaterialClick(Sender: TObject);
    procedure PaletteResetDefaultClick(Sender: TObject);
    procedure PaletteSortColorsClick(Sender: TObject);
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
    procedure ToolFontIconClick(Sender: TObject);
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
    procedure ColorBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ToolRectangleMenuClick(Sender: TObject);
    procedure ToolScrollDownMenuClick(Sender: TObject);
    procedure ToolScrollLeftMenuClick(Sender: TObject);
    procedure ToolScrollRightMenuClick(Sender: TObject);
    procedure ToolScrollUpMenuClick(Sender: TObject);
    procedure ToolTextMenuClick(Sender: TObject);
    procedure ToolUndoIconClick(Sender: TObject);
    procedure TurboPowerBasicClick(Sender: TObject);
    procedure TurboCClick(Sender: TObject);
    procedure TurboPascalClick(Sender: TObject);
    procedure TMTPascalClick(Sender: TObject);

    procedure ZoomBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FileExitMenuClick(Sender: TObject);
    procedure OpenFileClick(Sender: TObject);
    procedure ZoomPaintBoxClick(Sender: TObject);
    procedure ZoomPaintBoxMouseEnter(Sender: TObject);
    procedure ZoomPaintBoxMouseLeave(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);
    procedure ZoomScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ZoomPaintBoxPaint(Sender: TObject);
    procedure ZPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ZPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure ZPaintBoxMouseMoveDrawTextTool(Sender: TObject; Shift: TShiftState; X, Y: Integer);

  private
       ZoomX,ZoomY,ZoomX2,ZoomY2 : integer;
       OldZoomX,OldZoomY : integer;
       ZoomSize : Integer;
       DrawMode : Boolean;
       DrawFirst : Boolean;
       MaxXOffset : Integer;
       MaxYOffset : Integer;
       ShowTransparent : Boolean;
       BrushOverlayActive : Boolean;
       FSelectedDitherPattern : integer;
       FCheckerBmp : TBitmap;

       RenderBitMap  : TBitMap;
       RenderBitMap2 : TBitMap;

       ScriptLoaded   : integer;
       QBInterpreter  : TQBasicInterpreter;
       ScriptFileName : String;

       procedure UpdateZoomArea;
       procedure UpdateZoomScroller;
       procedure UpdateActualArea;
       procedure LoadDefaultPalette;
       procedure SetDefaultDrawColors;
       function  ImageHasData : boolean;
       function  ConfirmPaletteSwitch(newMode : integer) : boolean;
       procedure RemapImageToNewPalette(newMode : integer);
       procedure GenerateMaterial(const MatName : string; TopView : boolean);
       procedure UpdateStatusInfo;
       function  AllocMaterialColor(r, g, b : byte; var pal : TRMPaletteBuf;
                   var usedColors : array of boolean; colorCount : integer;
                   var paletteModified : boolean) : integer;
       procedure UpdatePalette;
       procedure UpdatePaletteMenu;
       procedure UpdateEditMenu;
       procedure UpdateToolsMenu;

       procedure UpdateToolFlipScrollMenu;

       procedure UpdateColorBoxes;
       procedure UpdateInfoBarXY(x,y : integer);
       procedure UpdateInfoBarDetail;
       procedure UpdateThumbview;
       procedure RebuildTransImageList;
       procedure UpdateTransImageListItem(index : integer);


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
       procedure EditColors(ColorBox : integer);
       procedure Clear;
       procedure InitThumbView;
       Procedure CopyScrollPositionToCore;
       Procedure CopyScrollPositionFromCore;
       function getopenfilename(var filename,ext : string; filter : string) : boolean;
       function getsavefilename(var filename,ext : string; filter : string) : boolean;

       procedure UpdateRenderBitMap;
       procedure ZPaintBoxMouseMoveDrawBrushTool(Sender: TObject; Shift: TShiftState; X, Y: Integer);
       procedure UpdateDitherGradientColors;
       procedure UpdateBrushRadioState;
       procedure DitherGradientFloodFill(StartX, StartY, FillWidth, FillHeight, ColorIndex : integer);
       procedure StampBrushToCore;
       procedure DrawBrushOverlay(ACanvas : TCanvas);
       procedure ZPaintBoxMouseDownXYTool(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
       procedure ZPaintBoxMouseMoveXYTool(Sender: TObject; Shift: TShiftState;  X, Y: Integer);
       procedure ZPaintBoxMouseUpXYTool(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
       procedure ZPaintBoxMouseDownXYX2Y2Tool(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
       procedure ZPaintBoxMouseMoveXYX2Y2Tool(Sender: TObject; Shift: TShiftState;  X, Y: Integer);
       procedure ZPaintBoxMouseUpXYX2Y2Tool(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);

       function ExportTextFileToClipboard(Sender: TObject) : boolean;
       function ExportPaletteTextFileToClipboard(Sender: TObject; ColorFormat : integer) : boolean;
       function DetectPaletteFormat(filename : string) : integer;
       procedure RefreshAfterProjectOpen(insertmode : boolean);
       procedure ApplyZoom(newsize : integer; useAnchor : boolean; anchorX : integer = 0; anchorY : integer = 0);

  public
       procedure UpdateImportedImage;
       procedure DeleteImageByIndex(index : integer);

       procedure InitQBInterpreter;
       procedure QBScriptRun;
       procedure PascalScriptRun;
       procedure API_PutPixel(const Args: array of Double; const StrArgs: array of string);
       function  API_GetPixel(const Args: array of Double): Double;
       function  API_GetWidth(const Args: array of Double): Double;
       function  API_GetHeight(const Args: array of Double): Double;
       function  API_GetMaxColor(const Args: array of Double): Double;
       function  API_GetColorR(const Args: array of Double) : double;
       function  API_GetColorG(const Args: array of Double) : double;
       function  API_GetColorB(const Args: array of Double) : double;

       procedure QBPrint(const AText: string);
       function QBInput(const Prompt: string; var Value: string) : boolean;
  end;



var
  RMMainForm: TRMMainForm;

implementation

const
  DrawShapeBrush = 14;
  DitherPatternCount = 36;
  DitherPatternSize = 8;   //pattern data is 8x8
  DitherPreviewSize = 32;  //preview drawn at 32x32 (4x scale)
  DitherPreviewScale = 4;
  DitherCols = 12;
  DitherRows = 3;

  DitherPatterns : array[0..DitherPatternCount-1, 0..63] of byte = (
    //row 1: basic patterns
    //0: 50% checkerboard
    (1,0,1,0,1,0,1,0, 0,1,0,1,0,1,0,1, 1,0,1,0,1,0,1,0, 0,1,0,1,0,1,0,1,
     1,0,1,0,1,0,1,0, 0,1,0,1,0,1,0,1, 1,0,1,0,1,0,1,0, 0,1,0,1,0,1,0,1),
    //1: 25% light dots
    (1,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0, 0,0,1,0,0,0,1,0, 0,0,0,0,0,0,0,0,
     1,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0, 0,0,1,0,0,0,1,0, 0,0,0,0,0,0,0,0),
    //2: 75% heavy
    (1,1,1,0,1,1,1,0, 1,1,1,1,1,1,1,1, 1,0,1,1,1,0,1,1, 1,1,1,1,1,1,1,1,
     1,1,1,0,1,1,1,0, 1,1,1,1,1,1,1,1, 1,0,1,1,1,0,1,1, 1,1,1,1,1,1,1,1),
    //3: horizontal lines thin
    (0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0),
    //4: horizontal lines thick
    (0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0),
    //5: vertical lines thin
    (0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0,
     0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0),
    //6: vertical lines thick
    (0,1,1,0,0,1,1,0, 0,1,1,0,0,1,1,0, 0,1,1,0,0,1,1,0, 0,1,1,0,0,1,1,0,
     0,1,1,0,0,1,1,0, 0,1,1,0,0,1,1,0, 0,1,1,0,0,1,1,0, 0,1,1,0,0,1,1,0),
    //7: diagonal right
    (1,0,0,0,0,0,0,0, 0,1,0,0,0,0,0,0, 0,0,1,0,0,0,0,0, 0,0,0,1,0,0,0,0,
     0,0,0,0,1,0,0,0, 0,0,0,0,0,1,0,0, 0,0,0,0,0,0,1,0, 0,0,0,0,0,0,0,1),
    //8: diagonal left
    (0,0,0,0,0,0,0,1, 0,0,0,0,0,0,1,0, 0,0,0,0,0,1,0,0, 0,0,0,0,1,0,0,0,
     0,0,0,1,0,0,0,0, 0,0,1,0,0,0,0,0, 0,1,0,0,0,0,0,0, 1,0,0,0,0,0,0,0),
    //9: cross-hatch
    (1,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
     1,0,0,0,1,0,0,0, 1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0),
    //10: diagonal cross X
    (1,0,0,0,0,0,0,1, 0,1,0,0,0,0,1,0, 0,0,1,0,0,1,0,0, 0,0,0,1,1,0,0,0,
     0,0,0,1,1,0,0,0, 0,0,1,0,0,1,0,0, 0,1,0,0,0,0,1,0, 1,0,0,0,0,0,0,1),
    //11: brick
    (1,1,1,1,1,1,1,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,1,1,1,1,1,
     1,1,1,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,0),
    //row 2: more patterns
    //12: basket weave
    (1,1,0,0,1,1,0,0, 1,1,0,0,1,1,0,0, 0,0,1,1,0,0,1,1, 0,0,1,1,0,0,1,1,
     1,1,0,0,1,1,0,0, 1,1,0,0,1,1,0,0, 0,0,1,1,0,0,1,1, 0,0,1,1,0,0,1,1),
    //13: dots sparse
    (0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,1,0,0,0,0,
     0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0),
    //14: dots medium
    (1,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0,
     1,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0),
    //15: grid
    (1,1,1,1,1,1,1,1, 1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0,
     1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0),
    //16: zigzag
    (1,0,0,0,0,0,0,0, 0,1,0,0,0,0,0,0, 0,0,1,0,0,0,0,0, 0,1,0,0,0,0,0,0,
     1,0,0,0,0,0,0,0, 0,1,0,0,0,0,0,0, 0,0,1,0,0,0,0,0, 0,1,0,0,0,0,0,0),
    //17: waves
    (0,0,1,1,0,0,0,0, 0,1,0,0,1,0,0,0, 1,0,0,0,0,1,0,0, 0,0,0,0,0,0,1,1,
     0,0,1,1,0,0,0,0, 0,1,0,0,1,0,0,0, 1,0,0,0,0,1,0,0, 0,0,0,0,0,0,1,1),
    //18: double diagonal
    (1,0,0,0,1,0,0,0, 0,1,0,0,0,1,0,0, 0,0,1,0,0,0,1,0, 0,0,0,1,0,0,0,1,
     1,0,0,0,1,0,0,0, 0,1,0,0,0,1,0,0, 0,0,1,0,0,0,1,0, 0,0,0,1,0,0,0,1),
    //19: diamond
    (0,0,0,1,0,0,0,0, 0,0,1,0,1,0,0,0, 0,1,0,0,0,1,0,0, 1,0,0,0,0,0,1,0,
     0,1,0,0,0,1,0,0, 0,0,1,0,1,0,0,0, 0,0,0,1,0,0,0,0, 0,0,0,0,0,0,0,0),
    //20: fish scale
    (0,0,0,1,1,0,0,0, 0,0,1,0,0,1,0,0, 0,1,0,0,0,0,1,0, 1,0,0,0,0,0,0,1,
     0,0,0,0,1,1,0,0, 0,0,0,1,0,0,1,0, 0,0,1,0,0,0,0,1, 0,1,0,0,0,0,0,0),
    //21: Bayer ordered 25%
    (0,0,0,0,0,0,0,0, 0,0,1,0,0,0,1,0, 0,0,0,0,0,0,0,0, 0,1,0,0,0,1,0,0,
     0,0,0,0,0,0,0,0, 0,0,1,0,0,0,1,0, 0,0,0,0,0,0,0,0, 0,1,0,0,0,1,0,0),
    //22: Bayer ordered 50%
    (1,0,1,0,1,0,1,0, 0,0,0,1,0,0,0,1, 1,0,1,0,1,0,1,0, 0,1,0,0,0,1,0,0,
     1,0,1,0,1,0,1,0, 0,0,0,1,0,0,0,1, 1,0,1,0,1,0,1,0, 0,1,0,0,0,1,0,0),
    //23: horizontal stripe 3px
    (0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
     1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0),
    //row 3: additional patterns
    //24: vertical stripe 3px
    (0,0,1,1,1,0,0,1, 0,0,1,1,1,0,0,1, 0,0,1,1,1,0,0,1, 0,0,1,1,1,0,0,1,
     0,0,1,1,1,0,0,1, 0,0,1,1,1,0,0,1, 0,0,1,1,1,0,0,1, 0,0,1,1,1,0,0,1),
    //25: herringbone
    (1,1,0,0,0,0,0,0, 0,1,1,0,0,0,0,0, 0,0,1,1,0,0,0,0, 0,0,0,1,1,0,0,0,
     0,0,0,0,1,1,0,0, 0,0,0,0,0,1,1,0, 0,0,0,0,0,0,1,1, 0,0,0,0,0,0,0,1),
    //26: dotted grid
    (1,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
     1,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0),
    //27: fine checker 2x2
    (1,1,0,0,1,1,0,0, 1,1,0,0,1,1,0,0, 0,0,1,1,0,0,1,1, 0,0,1,1,0,0,1,1,
     1,1,0,0,1,1,0,0, 1,1,0,0,1,1,0,0, 0,0,1,1,0,0,1,1, 0,0,1,1,0,0,1,1),
    //28: thick diagonal right
    (1,1,0,0,0,0,0,1, 0,1,1,0,0,0,0,0, 0,0,1,1,0,0,0,0, 0,0,0,1,1,0,0,0,
     0,0,0,0,1,1,0,0, 0,0,0,0,0,1,1,0, 0,0,0,0,0,0,1,1, 1,0,0,0,0,0,0,1),
    //29: thick diagonal left
    (1,0,0,0,0,0,1,1, 0,0,0,0,0,1,1,0, 0,0,0,0,1,1,0,0, 0,0,0,1,1,0,0,0,
     0,0,1,1,0,0,0,0, 0,1,1,0,0,0,0,0, 1,1,0,0,0,0,0,0, 1,0,0,0,0,0,0,1),
    //30: plus signs
    (0,0,0,0,0,0,0,0, 0,0,1,0,0,0,0,0, 0,1,1,1,0,0,0,0, 0,0,1,0,0,0,0,0,
     0,0,0,0,0,0,0,0, 0,0,0,0,0,0,1,0, 0,0,0,0,0,1,1,1, 0,0,0,0,0,0,1,0),
    //31: horizontal dashes
    (0,0,0,0,0,0,0,0, 1,1,1,0,0,1,1,1, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0, 0,0,1,1,1,0,0,1, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0),
    //32: vertical dashes
    (0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0, 0,0,0,0,0,0,0,0,
     0,0,0,1,0,0,0,1, 0,0,0,1,0,0,0,1, 0,0,0,1,0,0,0,1, 0,0,0,0,0,0,0,0),
    //33: small squares
    (1,1,0,0,1,1,0,0, 1,1,0,0,1,1,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
     1,1,0,0,1,1,0,0, 1,1,0,0,1,1,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0),
    //34: maze-like
    (1,1,1,0,0,0,1,1, 0,0,1,0,0,0,1,0, 0,0,1,0,1,1,1,0, 0,0,1,0,1,0,0,0,
     0,0,0,0,1,0,0,0, 1,1,1,0,1,0,0,0, 1,0,0,0,1,0,1,1, 1,0,0,0,0,0,0,0),
    //35: stipple
    (1,0,0,1,0,0,1,0, 0,0,0,0,0,0,0,0, 0,1,0,0,1,0,0,1, 0,0,0,0,0,0,0,0,
     1,0,0,1,0,0,1,0, 0,0,0,0,0,0,0,0, 0,1,0,0,1,0,0,1, 0,0,0,0,0,0,0,0)
  );

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
var
  i, j : integer;
begin
 //for which type of script to run PascalScript ot QBScript
 ScriptLoaded := NoScript;
 InitQBInterpreter;

 RenderBitMap:=TBitMap.Create;
 //size should be set to biggest bitmap to create
 RenderBitMap.SetSize(256,256);

 RenderBitMap2:=TBitMap.Create;
 //size should be set to biggest bitmap to create
RenderBitMap2.SetSize(256,256);

 ZoomSize:=RMDrawTools.GetZoomMode;
 DrawMode:=False;
 DrawFirst:=False;
 ShowTransparent:=False;
 FSelectedDitherPattern:=0;
 BrushOverlayActive:=False;

 // create checkerboard pattern for transparency display - fixed size, never scaled
 FCheckerBmp:=TBitmap.Create;
 FCheckerBmp.SetSize(256, 256);
 FCheckerBmp.Canvas.Brush.Color:=clWhite;
 FCheckerBmp.Canvas.FillRect(0, 0, 256, 256);
 FCheckerBmp.Canvas.Brush.Color:=RGBToColor(192, 192, 192);
 for i:=0 to 15 do
   for j:=0 to 15 do
     if ((i + j) mod 2) = 0 then
       FCheckerBmp.Canvas.FillRect(i*16, j*16, (i+1)*16, (j+1)*16);
// ActualBox.Width:=256;
// ActualBox.Height:=256;
 ActualBox.Canvas.Brush.Style := bsSolid;
 ActualBox.Canvas.Brush.Color := clblack;
 ActualBox.Canvas.FillRect(0,0,256,256);

 RMDrawTools.SetZoomMaxX(RMDrawTools.GetZoomPageWidth);
 RMDrawTools.SetZoomMaxY(RMDrawTools.GetZoomPageHeight);

 LoadResourceIcons;
 MaxXOffset:=0;
 MaxYOffset:=0;

 ZoomTrackBar.Position:=RMDrawTools.getZoomSize;

 RMCoreBase.Palette.SetPaletteMode(PaletteModeXGA256);
 LoadDefaultPalette;

 //set the colors in the Color Boxes and Palette
 ColorBox1.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor1];
 ColorBox2.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor2];
 ColorPalette1.PickedIndex:=RMCoreBase.GetCurColor1;

 RMDrawTools.SetDrawTool(DrawShapePencil);
 ClearSelectedToolsMenu;
 PaletteXGA256.Checked:=true; // set xga 256 palette
 UpdateToolSelectionIcons;
 UpdateEditMenu;
 InitThumbView;

 RMDrawTools.SetTextInfoText(TextDrawEdit.Text);
 RMDrawTools.SetTextInfoFont(RenderBitMap.Canvas.Font);
 RMDrawTools.SetTextInfoTColor(ColorBox1.Brush.Color);

 ZoomX:=0;
 ZoomY:=0;
 ZoomX2:=0;
 ZoomY2:=0;
 OldZoomX:=-1;
 OldZoomY:=-1;
end;

procedure TRMMainForm.FormDestroy(Sender: TObject);
begin
  QBInterpreter.Free;
  RenderBitMap.Free;
  RenderBitMap2.Free;
end;

procedure TRMMainForm.RMAboutDialogClick(Sender: TObject);
var
  Dlg: TAboutForm;
begin
  Dlg := TAboutForm.Create(Application);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
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

procedure TRMMainForm.ToolFontIconClick(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    RMDrawTools.SetTextInfoFont(FontDialog1.Font);
  end;
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

procedure TRMMainForm.ToolTextMenuClick(Sender: TObject);
begin
  ClearClipAreaOutline;
  RMDrawTools.SetDrawTool(DrawShapeText);
  UpdateToolSelectionIcons;
  ToolTextMenu.Checked:=true;
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
  if not ConfirmPaletteSwitch(PaletteModeMono) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeMono)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteMono.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeMono);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteMono.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteCGA0Click(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeCGA0) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeCGA0)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteCGA0.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeCGA0);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteCGA0.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteCGA1Click(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeCGA1) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeCGA1)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteCGA1.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeCGA1);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteCGA1.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga2Click(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeAmiga2) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeAmiga2)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteAmiga2.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga2);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteAmiga2.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga4Click(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeAmiga4) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeAmiga4)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteAmiga4.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga4);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteAmiga4.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga8Click(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeAmiga8) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeAmiga8)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteAmiga8.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga8);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteAmiga8.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga16Click(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeAmiga16) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeAmiga16)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteAmiga16.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga16);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteAmiga16.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteAmiga32Click(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeAmiga32) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeAmiga32)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteAmiga32.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeAmiga32);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteAmiga32.Checked:=true;
  UpdateColorBoxes;
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
  if not ConfirmPaletteSwitch(PaletteModeVGA) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeVGA)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteVGA.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeVGA);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteVGA.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteVGA256Click(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeVGA256) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeVGA256)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteVGA256.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeVGA256);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteVGA256.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteEGAClick(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeEGA) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeEGA)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteEGA.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeEGA);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteEGA.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PencilDrawChange(Sender: TObject);
begin
  RMDrawTools.SetDrawTool(DrawShapePencil);
end;

procedure TRMMainForm.ColorBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssRight in Shift then
  begin
     EditColors(cbColorBox1);
     exit;
  end;
  RMCoreBase.SetCurColorBox(cbColorBox1);
  UpdateColorBoxes;
end;

procedure TRMMainForm.ColorBox2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if ssRight in Shift then
  begin
    EditColors(cbColorBox2);
    exit;
  end;
  RMCoreBase.SetCurColorBox(cbColorBox2);
  UpdateColorBoxes;
end;

procedure TRMMainForm.ColorBox2MouseEnter(Sender: TObject);
begin
  ColorBox2.Hint:='Color 2'+LineEnding+ColIndexToHoverInfo(RMCoreBase.GetCurColor2,RMCoreBase.Palette.GetPaletteMode);
end;

procedure TRMMainForm.UpdateActualArea;
var
  i,j : integer;
  zoommode : integer;
  tc : TColor;
  ACBitMap : TBitMap;
  saveDither, saveGradient, saveBrushFill : boolean;
  saveDitherPattern : integer;
  saveDitherUseBitmap : boolean;
begin
   //temporarily disable dither/gradient/brush - we're rendering existing buffer
   //content, not drawing new shapes
   saveDither:=RMDrawTools.GetDitherEnabled;
   saveGradient:=RMDrawTools.GetGradientEnabled;
   saveBrushFill:=RMDrawTools.GetBrushFillEnabled;
   saveDitherPattern:=RMDrawTools.GetDitherPattern;
   saveDitherUseBitmap:=RMDrawTools.GetDitherUseBitmap;
   RMDrawTools.SetDitherEnabled(false);
   RMDrawTools.SetGradientEnabled(false);
   RMDrawTools.SetBrushFillEnabled(false);

   ACBitMap:=TBitMap.Create;
   ACBitMap.SetSize(RMCoreBase.GetWidth,RMCoreBase.GetHeight);

   // set transparency BEFORE drawing content onto bitmap
   if ShowTransparent then
   begin
     ACBitMap.TransparentColor:=ColorPalette1.Colors[0];
     ACBitMap.TransparentMode:=tmFixed;
     ACBitMap.Transparent:=True;
   end;

   zoommode:=RMDrawTools.GetZoomMode;
   RMDrawTools.SetZoomMode(0);

   for i:=0 to RMCoreBase.GetWidth -1 do
   begin
     for j:=0 to RMCoreBase.GetHeight-1 do
     begin
        tc:=ColorPalette1.Colors[RMCoreBase.GetPixel(i,j)];
        RMDrawTools.PutPixel(ACBitMap.Canvas,i,j,tc,0);
     end;
   end;

   ActualBox.Picture.Bitmap.SetSize(256, 256);

   if ShowTransparent then
   begin
     ActualBox.Canvas.Draw(0, 0, FCheckerBmp);
     ActualBox.Canvas.StretchDraw(Rect(0, 0, 256, 256), ACBitMap);
   end
   else
   begin
     ActualBox.canvas.CopyRect(Rect(0, 0, 256, 256), ACBitMap.Canvas, Rect(0, 0, ACBitMap.Width, ACBitMap.Height));
   end;

   RMDrawTools.SetZoomMode(zoommode);
   ACBitMap.Free;

   //restore dither/gradient/brush state
   RMDrawTools.SetDitherPattern(saveDitherPattern);
   RMDrawTools.SetDitherUseBitmap(saveDitherUseBitmap);
   if saveBrushFill then RMDrawTools.SetBrushFillEnabled(true);
   if saveDither then RMDrawTools.SetDitherEnabled(true);
   if saveGradient then RMDrawTools.SetGradientEnabled(true);
end;

procedure TRMMainForm.updateZoomArea;
begin
  UpdateRenderBitMap;
  ZoomPaintBox.Invalidate;
end;

procedure TRMMainForm.updateZoomScroller;
begin
  ZoomTrackBar.Position:=ZoomSize;
end;

procedure TRMMainForm.UpdateColorBoxes;
begin
  ColorBox1.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor1];
  ColorBox2.Brush.Color:=ColorPalette1.Colors[RMCoreBase.GetCurColor2];

  //Reset Color Style to Normal - non picked
  ColorBox1.Pen.Style:=psSolid;
  ColorBox1.Pen.Color:=clBlack;
  ColorBox1.Pen.Width:=1;

  ColorBox2.Pen.Style:=psSolid;
  ColorBox2.Pen.Color:=clBlack;
  ColorBox2.Pen.Width:=1;

  //make red outline for picked color box
  if RMCoreBase.GetCurColorBox = cbColorBox1 then
  begin
    ColorBox1.Pen.Color:=clRed;
    ColorBox1.Pen.Width:=3;

    ColorPalette1.PickedIndex:=RMCoreBase.GetCurColor1;
  end
  else
  begin
   ColorBox2.Pen.Color:=clRed;
   ColorBox2.Pen.Width:=3;

   ColorPalette1.PickedIndex:=RMCoreBase.GetCurColor2;
  end;
  if DrawMethodPreview <> nil then
    DrawMethodPreview.Invalidate;
  UpdateStatusInfo;
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
  SetDefaultDrawColors;
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

 // UpdateActualArea;
  UpdateZoomArea;
end;

procedure TRMMainForm.ColorBox1MouseEnter(Sender: TObject);
begin
  ColorBox1.Hint:='Color 1'+LineEnding+ColIndexToHoverInfo(RMCoreBase.GetCurColor1,RMCoreBase.Palette.GetPaletteMode);
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

procedure TRMMainForm.DeleteImageClick(Sender: TObject);
 var
  item  : TListItem;
  index : integer;
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

    DeleteImageByIndex(index);
  end;
end;

procedure TRMMainForm.EditColorBox2Click(Sender: TObject);
begin
  EditColors(cbColorBox2);
end;

procedure TRMMainForm.rmToggleClick(Sender: TObject);
begin
 rmToggle.Checked:=NOT rmToggle.Checked;
 if  rmToggle.Checked  then RMPanel.Hide else RMPanel.Show;
end;


procedure TRMMainForm.TextDrawEditChange(Sender: TObject);
begin
  RMDrawTools.SetTextInfoText(TextDrawEdit.Text);
end;

procedure TRMMainForm.ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
  if (ssShift in Shift) or (ssRight in Shift) then
  begin
    if RMCoreBase.GetCurColorBox = cbColorBox1 then
    begin
      ColorBox2.Brush.Color:= AColor;
      RMCoreBase.SetCurColor2(ColorPalette1.PickedIndex);
    end
    else
    begin
     ColorBox1.Brush.Color:= AColor;
     RMCoreBase.SetCurColor1(ColorPalette1.PickedIndex);
     RMDrawTools.SetTextInfoTColor(AColor);
    end;
  end
  else if RMCoreBase.GetCurColorBox = cbColorBox1 then
  begin
    ColorBox1.Brush.Color:= AColor;
    RMCoreBase.SetCurColor1(ColorPalette1.PickedIndex);
    RMDrawTools.SetTextInfoTColor(AColor); //when using the T (text) Tool
  end
  else
  begin
   ColorBox2.Brush.Color:= AColor;
   RMCoreBase.SetCurColor2(ColorPalette1.PickedIndex);
   ///RMDrawTools.SetTextInfoTColor(AColor);
  end;
  DrawMethodPreview.Invalidate;
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
   ZoomTrackBar.Position:=RMDrawTools.GetZoomSize;
   UpdateZoomArea;
end;

procedure TRMMainForm.FileExitMenuClick(Sender: TObject);
begin
  close;            // I created extra work - i added prompt in close
end;

procedure TRMMainForm.ApplyZoom(newsize : integer; useAnchor : boolean; anchorX : integer; anchorY : integer);
var
  oldCellW, oldCellH, newCellW, newCellH : integer;
  pixX, pixY : double;
  newScrollX, newScrollY : integer;
begin
  if newsize < 1 then newsize:=1;
  if newsize > 20 then newsize:=20;
  //NOTE: no early exit when newsize = current zoom - the initial call at
  //startup relies on this proc to size and paint the ZoomPaintBox even
  //when the zoom value is unchanged

  //remember which image pixel sits under the anchor point (in scrollbox
  //client coordinates) so we can keep it there after zooming
  oldCellW:=RMDrawTools.GetCellWidth;
  oldCellH:=RMDrawTools.GetCellHeight;
  pixX:=0; pixY:=0;
  if useAnchor and (oldCellW > 0) and (oldCellH > 0) then
  begin
    pixX:=(ZoomScrollBox.HorzScrollBar.Position + anchorX) / oldCellW;
    pixY:=(ZoomScrollBox.VertScrollBar.Position + anchorY) / oldCellH;
  end;

  RMDrawTools.SetZoomSize(newsize);
  ZoomPaintBox.Width:=1;
  ZoomPaintBox.Height:=1;
  ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
  ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;
  RMDrawTools.SetZoomMaxX(ZoomPaintBox.Width);
  RMDrawTools.SetZoomMaxY(ZoomPaintBox.Height);
  ZoomSize:=RMDrawTools.GetZoomSize;

  //keep the anchored pixel under the cursor
  if useAnchor then
  begin
    newCellW:=RMDrawTools.GetCellWidth;
    newCellH:=RMDrawTools.GetCellHeight;
    newScrollX:=Round(pixX * newCellW) - anchorX;
    newScrollY:=Round(pixY * newCellH) - anchorY;
    if newScrollX < 0 then newScrollX:=0;
    if newScrollY < 0 then newScrollY:=0;
    ZoomScrollBox.HorzScrollBar.Position:=newScrollX;
    ZoomScrollBox.VertScrollBar.Position:=newScrollY;
  end;

  //keep the trackbar in sync without retriggering
  if ZoomTrackBar.Position <> ZoomSize then
  begin
    ZoomTrackBar.OnChange:=nil;
    ZoomTrackBar.Position:=ZoomSize;
    ZoomTrackBar.OnChange:=@ZoomTrackBarChange;
  end;

  UpdateZoomArea;
end;

procedure TRMMainForm.ZoomTrackBarChange(Sender: TObject);
begin
  ApplyZoom(ZoomTrackBar.Position, False);
  UpdateStatusInfo;
end;

procedure TRMMainForm.ZoomScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint;
begin
  //zoom with the wheel, anchored on the pixel under the mouse cursor
  pt:=ZoomScrollBox.ScreenToClient(MousePos);
  if WheelDelta > 0 then
    ApplyZoom(RMDrawTools.GetZoomSize + 1, True, pt.X, pt.Y)
  else
    ApplyZoom(RMDrawTools.GetZoomSize - 1, True, pt.X, pt.Y);
  Handled:=True;
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
 XYStr:='X = '+IntToStr(ZX)+' Y = '+IntToStr(ZY)+' ';
 ColIndexStr:='';
 if (zx >= 0) and (zy >= 0) then
 begin
   ColIndexStr:='Color Index: '+IntToStr(RMCoreBase.GetPixel(ZX,ZY))
 end;
 ClipStr:='';
 if RMDrawTools.GetClipStatus = 1 then
 begin
      RMDrawTools.GetClipAreaCoords(ca);
      ClipStr:='Select Area '+'X = '+IntToStr(ca.x)+' Y = '+IntToStr(ca.y)+' X2 = '+IntToStr(ca.x2)+' Y2 = '+IntToStr(ca.y2)+' '+
               'Width = '+IntToStr(ca.x2-ca.x+1)+' Height = '+IntToStr(ca.y2-ca.y+1)+' ';
 end;
// InfoBarLabel.Caption:=XYStr+ClipStr+ColIndexStr;
 StatusBar.Panels[0].Text:=XYStr+ColIndexStr;
 StatusBar.Panels[1].Text:=ClipStr;
end;

procedure TRMMainForm.UpdateInfoBarDetail;
var
  XYStr,WHStr   : string;
begin
 XYStr:='X = '+IntToStr(ZoomX)+' Y = '+IntToStr(ZoomY)+' '+
        'X2 = '+IntToStr(ZoomX2)+' Y2 = '+IntToStr(ZoomY2)+' ';
 WHStr:='Width = '+IntToStr(ABS(ZoomX2-ZoomX+1))+' Height = '+IntToStr(ABS(ZoomY2-ZoomY+1));
// InfoBarLabel.Caption:=XYStr;
 StatusBar.Panels[0].Text:=XYStr;
 StatusBar.Panels[1].Text:=WHStr;
end;




// xy mouse down event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseDownXYTool(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 DrawTool  : integer;
 ColorIndex : integer;
 DrawColor  : TColor;
begin
  ZoomX:=RMDrawTools.GetZoomX(x);
  ZoomY:=RMDrawTools.GetZoomY(y);
//  if (ZoomX=OldZoomX) and (ZoomY=OldZoomY) then exit; // we are just just drawing in the same zoom x,y
//  this is commented out because it breaks repainting to the same pixel
  OldZoomX:=ZoomX;
  OldZoomY:=ZoomY;
  DrawTool:=RMDRAWTools.GetDrawTool;

  ColorIndex:=RMCoreBase.GetCurColor1;
  DrawColor:=ColorBox1.Brush.Color;

  if ssLeft in Shift then
  begin
    ColorIndex:=RMCoreBase.GetCurColor1;
    DrawColor:=ColorBox1.Brush.Color;
  end
  else if ssRight in Shift then
  begin
    ColorIndex:=RMCoreBase.GetCurColor2;
    DrawColor:=ColorBox2.Brush.Color;
  end;
  RMCoreBase.SetColorEx(ColorIndex);  //kludge - fix this in future
  UpdateDitherGradientColors;

  if DrawTool = DrawShapePaint then  // special kludge here - fix in future updates
  begin
    if (ssLeft in Shift) and (ssShift in Shift) then
      ReplaceAllFill(ZoomX,ZoomY,RMCoreBase.GetWidth,RMCoreBase.GetHeight,ColorIndex)
    else if RMDrawTools.GetDitherEnabled or RMDrawTools.GetGradientEnabled or RMDrawTools.GetBrushFillEnabled then
      DitherGradientFloodFill(ZoomX, ZoomY, RMCoreBase.GetWidth, RMCoreBase.GetHeight, ColorIndex)
    else
      ScanFill(ZoomX,ZoomY,RMCoreBase.GetWidth,RMCoreBase.GetHeight,ColorIndex);

      //   Fill(ZoomX,ZoomY,RMCoreBase.GetWidth,RMCoreBase.GetHeight,RMCoreBase.GetCurColor);
   // Fill(ZoomX,ZoomY,RMCoreBase.GetCurColor);

    UpdateRenderBitMap;
    ZoomPaintBox.Invalidate;
    UpdateActualArea;
  end
  else
  begin
    UpdateRenderBitMap;
    RMDrawTools.CreateRandomSprayPoints;
    RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,DrawColor,DrawShapeModeCopy,DrawTool,0);
    //this
   // RMDrawTools.ADrawShape(ActualBox.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox1.Brush.Color,DrawShapeModeCopy,DrawTool,0);
    ZoomPaintBox.Invalidate;
    RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,DrawColor,DrawShapeModeCopyToBuf,DrawTool,0);
 //   UpdateActualArea;
  end;
end;


procedure TRMMainForm.ZPaintBoxMouseMoveDrawTextTool(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 ZoomX:=RMDrawTools.GetZoomX(x);
 ZoomY:=RMDrawTools.GetZoomY(y);
 UpdateInfoBarXY(x,y);
 RMDrawTools.SetTextInfoXY(ZoomX,ZoomY);
 ZoomPaintBox.Invalidate;
end;



// xy mouse move event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseMoveXYTool(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
 DrawTool : integer;
 DrawColor : TColor;
 ColorIndex : integer;
begin
  DrawTool:=RMDRAWTools.GetDrawTool;
  ZoomX:=RMDrawTools.GetZoomX(x);
  ZoomY:=RMDrawTools.GetZoomY(y);

  UpdateInfoBarXY(x,y);
//  if not ((ssLeft in Shift) or (ssRight in Shift))  then exit;
  DrawColor:=ColorBox1.Brush.Color;
  ColorIndex:=RMCoreBase.GetCurColor1;
  if ssLeft in Shift then
  begin
    ColorIndex:=RMCoreBase.GetCurColor1;
    DrawColor:=ColorBox1.Brush.Color;
  end
  else if ssRight in Shift then
  begin
    ColorIndex:=RMCoreBase.GetCurColor2;
    DrawColor:=ColorBox2.Brush.Color;
  end
  else exit;
  RMCoreBase.SetColorEx(ColorIndex);  //kludge - fix this in future
  UpdateDitherGradientColors;

  if (ZoomX=OldZoomX) and (ZoomY=OldZoomY) then exit; // we are just just drawing in the same zoom x,y
  OldZoomX:=ZoomX;
  OldZoomY:=ZoomY;
  RMDrawTools.CreateRandomSprayPoints;

  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,DrawColor,DrawShapeModeCopy,DrawTool,0);
  //this
  //RMDrawTools.ADrawShape(ActualBox.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,ColorBox1.Brush.Color,DrawShapeModeCopy,DrawTool,0);
  ZoomPaintBox.Invalidate;
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,DrawColor,DrawShapeModeCopyToBuf,DrawTool,0);
end;

// xy mouse up event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseUpXYTool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  OldZoomX:=-1;
  OldZoomY:=-1;
end;


// xyx2y2 mouse down event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseDownXYX2Y2Tool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 DrawTool : integer;
 DrawColor : TColor;
 ColorIndex : integer;
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

  DrawColor:=ColorBox1.Brush.Color;
  ColorIndex:=RMCoreBase.GetCurColor1;

  if ssLeft in Shift then
  begin
    ColorIndex:=RMCoreBase.GetCurColor1;
    DrawColor:=ColorBox1.Brush.Color;
  end
  else if ssRight in Shift then
  begin
    ColorIndex:=RMCoreBase.GetCurColor2;
    DrawColor:=ColorBox2.Brush.Color;
  end;
  RMCoreBase.SetColorEx(ColorIndex);  //kludge - fix this in future
  UpdateDitherGradientColors;

  UpdateRenderBitMap;
  RenderBitMap2.Canvas.CopyRect(rect(0,0,RenderBitMap2.Width,RenderBitMap2.Height),RenderBitMap.Canvas,rect(0,0,RenderBitMap.Width,RenderBitMap.Height));
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,DrawColor,DrawShapeModeCopy,DrawTool,1);
  ZoomPaintBox.Invalidate;
end;

// xyx2y2 mouse move event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseMoveXYX2Y2Tool(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
 DrawTool : integer;
 DrawColor : TColor;
 ColorIndex : integer;
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

  DrawColor:=ColorBox1.Brush.Color;
  ColorIndex:=RMCoreBase.GetCurColor1;
  if ssLeft in Shift then
  begin
    ColorIndex:=RMCoreBase.GetCurColor1;
    DrawColor:=ColorBox1.Brush.Color;
  end
  else if ssRight in Shift then
  begin
    ColorIndex:=RMCoreBase.GetCurColor2;
    DrawColor:=ColorBox2.Brush.Color;
  end;
  RMCoreBase.SetColorEx(ColorIndex);  //kludge - fix this in future
  UpdateDitherGradientColors;

  //UpdateRenderBitMap;
  RenderBitMap.Canvas.CopyRect(rect(0,0,RenderBitMap.Width,RenderBitMap.Height),RenderBitMap2.Canvas,rect(0,0,RenderBitMap2.Width,RenderBitMap2.Height));
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX2,ZoomY2,DrawColor,DrawShapeModeCopy,DrawTool,1);
  ZoomPaintBox.Invalidate;
end;

// xyx2y2 mouse up event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TRMMainForm.ZPaintBoxMouseUpXYX2Y2Tool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 DrawTool : integer;
 DrawColor : TColor;
 //ColorIndex : Integer;
begin
  if (OldZoomX=-1) or (OldZoomY=-1) then exit;       //prevent right clicking from outsize of zoom area while moving into zoom area creates unwanted event - checking the coors allows to jump out with out drawing garbage
  OldZoomX:=-1;
  OldZoomY:=-1;
  DrawTool:=RMDRAWTools.GetDrawTool;

  DrawColor:=ColorBox1.Brush.Color;
 // ColorIndex:=RMCoreBase.GetCurColor1;

  if ssLeft in Shift then
  begin
//    ColorIndex:=RMCoreBase.GetCurColor1;
    DrawColor:=ColorBox1.Brush.Color;
  end
  else if ssRight in Shift then
  begin
 //   ColorIndex:=RMCoreBase.GetCurColor2;
    DrawColor:=ColorBox2.Brush.Color;
  end;
//  RMCoreBase.SetColorEx(ColorIndex);  //kludge - fix this in future
  UpdateDitherGradientColors;

  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX2,ZoomY2,DrawColor,DrawShapeModeCopyToBuf,DrawTool,1);
  UpdateActualArea;
end;

procedure TRMMainForm.ZPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 DrawTool : integer;
 DrawColor : TColor;
 ColorIndex : integer;
begin
 RMDrawTools.SetClipStatus(0);  //turn it off - we turn on again when new area is selected
 DrawTool:=RMDRAWTools.GetDrawTool;
 if DrawTool<>DrawShapeClip then RMCoreBase.CopyToUndoBuf;

 //brush stamp tool - stamp on left or right click
 if (DrawTool = DrawShapeBrush) and (Button = mbLeft) then
 begin
   if not RetroBrush.HasBrush then exit;
   RMCoreBase.CopyToUndoBuf;
   StampBrushToCore;
   UpdateZoomArea;
   UpdateThumbview;
   UpdateActualArea;
   exit;
 end;

 //the Text tool stamps on OnClick which the LCL only fires for the left
 //button - handle the right button here so it draws with Color 2
 if (DrawTool = DrawShapeText) and (Button = mbRight) then
 begin
   DrawColor:=ColorBox2.Brush.Color;
   ColorIndex:=RMCoreBase.GetCurColor2;
   RMCoreBase.SetColorEx(ColorIndex);  //kludge - fix this in future
  UpdateDitherGradientColors;

   RMDrawTools.SetTextInfoTColor(DrawColor);
   RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,DrawColor,DrawShapeModeCopy,DrawTool,1);
   RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX2,ZoomY2,DrawColor,DrawShapeModeCopyToBuf,DrawTool,1);
   RMDrawTools.SetTextInfoTColor(ColorBox1.Brush.Color);  //restore Color 1 for the hover preview

   if ShowTransparent then
     UpdateZoomArea
   else
     ZoomPaintBox.Invalidate;
   UpdateThumbview;
   UpdateActualArea;
   exit;
 end;

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
 Case DrawTool of DrawShapeText:ZPaintBoxMouseMoveDrawTextTool(Sender,Shift,X,Y);
                  DrawShapeBrush:ZPaintBoxMouseMoveDrawBrushTool(Sender,Shift,X,Y);
                  DrawShapePencil,DrawShapeSpray,DrawShapePaint:ZPaintBoxMouseMoveXYTool(Sender,Shift,X,Y);
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
 UpdateActualArea;
 if ShowTransparent then UpdateZoomArea;
end;

procedure TRMMainForm.ZoomPaintBoxClick(Sender: TObject);
var
  DrawTool : integer;
  DrawColor : TColor;
  ColorIndex : integer;
begin
  DrawTool:=RMDRAWTools.GetDrawTool;
  if DrawTool = DrawShapeBrush then
  begin
    if not RetroBrush.HasBrush then exit;
    RMCoreBase.CopyToUndoBuf;
    StampBrushToCore;
    UpdateZoomArea;
    UpdateThumbview;
    UpdateActualArea;
    exit;
  end;
  if DrawTool <> DrawShapeText then exit;

  DrawColor:=ColorBox1.Brush.Color;
  ColorIndex:=RMCoreBase.GetCurColor1;

  RMCoreBase.SetColorEx(ColorIndex);  //kludge - fix this in future
  UpdateDitherGradientColors;

  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX,ZoomY,DrawColor,DrawShapeModeCopy,DrawTool,1);
  RMDrawTools.ADrawShape(RenderBitMap.Canvas,ZoomX,ZoomY,ZoomX2,ZoomY2,DrawColor,DrawShapeModeCopyToBuf,DrawTool,1);
  if ShowTransparent then
    UpdateZoomArea
  else
    ZoomPaintBox.Invalidate;
end;

procedure TRMMainForm.ZoomPaintBoxMouseEnter(Sender: TObject);
begin
  // set DrawText active
  if RMDrawTools.GetDrawTool = DrawShapeText then
  begin
    RMDrawTools.SetTextInfoActive(true);
    RMDrawTools.SetTextInfoTColor(ColorBox1.Brush.Color);
    ZoomPaintBox.Invalidate;
  end;
  if RMDrawTools.GetDrawTool = DrawShapeBrush then
  begin
    BrushOverlayActive:=true;
    ZoomPaintBox.Invalidate;
  end;
end;

procedure TRMMainForm.ZoomPaintBoxMouseLeave(Sender: TObject);
begin
  //set DrawText not active
  if RMDrawTools.GetDrawTool = DrawShapeText then
  begin
    RMDrawTools.SetTextInfoActive(false);
    ZoomPaintBox.Invalidate;
  end;
  if RMDrawTools.GetDrawTool = DrawShapeBrush then
  begin
    BrushOverlayActive:=false;
    ZoomPaintBox.Invalidate;
  end;
end;

procedure TRMMainForm.ZoomPaintBoxPaint(Sender: TObject);
var
  x, y : integer;
  TmpBmp : TBitmap;
begin
  if ShowTransparent then
  begin
    // tile fixed checkerboard at destination resolution
    y:=0;
    while y < ZoomPaintBox.Height do
    begin
      x:=0;
      while x < ZoomPaintBox.Width do
      begin
        ZoomPaintBox.Canvas.Draw(x, y, FCheckerBmp);
        inc(x, 256);
      end;
      inc(y, 256);
    end;

    // create temp bitmap with transparency set BEFORE content is drawn on it
    TmpBmp:=TBitmap.Create;
    try
      TmpBmp.SetSize(RenderBitMap.Width, RenderBitMap.Height);
      TmpBmp.TransparentColor:=ColorPalette1.Colors[0];
      TmpBmp.TransparentMode:=tmFixed;
      TmpBmp.Transparent:=True;
      TmpBmp.Canvas.Draw(0, 0, RenderBitMap);
      ZoomPaintBox.Canvas.StretchDraw(rect(0,0,ZoomPaintBox.Width,ZoomPaintBox.Height), TmpBmp);
    finally
      TmpBmp.Free;
    end;
  end
  else
  begin
    ZoomPaintBox.Canvas.CopyRect(rect(0,0,ZoomPaintBox.Width,ZoomPaintBox.Height),
                 RenderBitMap.Canvas,rect(0,0,RenderBitMap.Width,RenderBitMap.Height));
  end;

  //render the text here
  RMDrawTools.DrawOverlayText(ZoomPaintBox.Canvas);

  //render brush preview overlay
  if (RMDrawTools.GetDrawTool = DrawShapeBrush) and RetroBrush.HasBrush and BrushOverlayActive then
    DrawBrushOverlay(ZoomPaintBox.Canvas);

  RMDrawTools.DrawOverlayGrid(ZoomPaintBox.Canvas,clWhite);
  RMDrawTools.DrawOverlayOnClipArea(ZoomPaintBox.Canvas,clYellow,0); //mode 0 is copy
end;

procedure TRMMainForm.UpdateToolsMenu;
var
  DT : integer;
begin
 DT:=RMDRAWTools.GetDrawTool;
 case DT of DrawShapePencil:ToolPencilMenu.Checked:=true;
              DrawShapeLine:ToolLineMenu.Checked:=true;
            DrawShapeCircle:  ToolCircleMenu.Checked:=true;
          DrawShapeFCircle:  ToolFCircleMenu.Checked:=true;
          DrawShapeEllipse:  ToolEllipseMenu.Checked:=true;
         DrawShapeFEllipse:  ToolFEllipseMenu.Checked:=true;
        DrawShapeRectangle:  ToolRectangleMenu.Checked:=true;
       DrawShapeFRectangle:  ToolFRectangleMenu.Checked:=true;
            DrawShapeSpray:  ToolMenuSprayPaint.Checked:=true;
            DrawShapePaint:  ToolMenuPaint.Checked:=true;
             DrawShapeClip:  ToolSelectAreaMenu.Checked:=true;
 end;
 if RMDrawTools.GetGridMode = 1 then ToolGridMenu.Checked:=true;
end;

procedure TRMMainForm.ClearSelectedToolsMenu;
begin
  ToolPencilMenu.Checked:=false;
  ToolTextMenu.Checked:=false;
  ToolLineMenu.Checked:=false;

  ToolFRectangleMenu.Checked:=false;
  ToolRectangleMenu.Checked:=false;
  ToolSelectAreaMenu.Checked:=false;

  ToolMenuSprayPaint.Checked:=false;
  ToolMenuPaint.Checked:=false;
  ToolCircleMenu.Checked:=false;
  ToolFCircleMenu.Checked:=false;
  ToolEllipseMenu.Checked:=false;
  ToolFEllipseMenu.Checked:=false;

  ToolGridMenu.Checked:=false;
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

  ToolBrushIcon.Picture.LoadFromResourceName(HInstance,'BRUSH1');
  ToolBrushFXIcon.Picture.LoadFromResourceName(HInstance,'BRUSHFX1');

  ToolTextIcon.Picture.LoadFromResourceName(HInstance,'TEXT1');
  ToolFontIcon.Picture.LoadFromResourceName(HInstance,'FONT1');


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
  ToolBrushIcon.Picture.LoadFromResourceName(HInstance,'BRUSH1');
  TooltextIcon.Picture.LoadFromResourceName(HInstance,'TEXT1');
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
             DrawShapeText:TooltextIcon.Picture.LoadFromResourceName(HInstance,'TEXT2');
             DrawShapePaint:ToolPaintIcon.Picture.LoadFromResourceName(HInstance,'PAINT2');
             DrawShapeBrush:ToolBrushIcon.Picture.LoadFromResourceName(HInstance,'BRUSH2');
             DrawShapeClip:ToolSelectAreaIcon.Picture.LoadFromResourceName(HInstance,'SELECT2');

  end;
  ClearSelectedToolsMenu;
  UpdateToolsMenu;
end;

procedure TRMMainForm.ShowSelectAreaTools;
begin
  //ToolVFLIPButton.Visible:=true;
  //ToolHFLIPButton.Visible:=true;
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
   SaveDialog1.Filter := 'PNG|*.png|Windows BMP|*.bmp|PC Paintbrush|*.pcx|DP-Amiga IFF|*.iff|DP-Amiga IFF Brush|*.brush|DP-PC IFF LBM(PBM)|*.lbm|DP-PC BBM Brush|*.bbm|GIF|*.gif|RM RAW Files|*.raw|All Files|*.*';
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
   OpenDialog1.Filter := 'PNG|*.png|Windows BMP|*.bmp|PC Paintbrush |*.pcx|DP-Amiga IFF LBM|*.lbm|DP-Amiga IFF|*.iff|DP-Amiga IFF Brush|*.brush|DP-PC IFF LBM(PBM)|*.lbm|DP-PC BBM Brush|*.bbm|GIF|*.gif|RM RAW Files|*.raw|All Files|*.*' ;

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
      UpdateColorBoxes;
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
                                    'BAMPaletteData' : ExportDialog.Filter := 'BAM Basic Palette Data|*.bas';
                                    'BAMPaletteCommands' : ExportDialog.Filter :='BAM Basic Palette Commands|*.bas';

   end;

   pm:=RMCoreBase.Palette.GetPaletteMode;
   ColorFormat:=ColorSixBitFormat;
   if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

   if ExportPaletteTextFileToClipboard(Sender,ColorFormat) then exit;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'QBPaletteData' : error:=WritePalData(ExportDialog.FileName,QBLan,ColorFormat);
                                     'QBPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,QBLan,ColorFormat);
                                     'FBPaletteData' : error:=WritePalData(ExportDialog.FileName,FBinQBModeLan,ColorFormat);
                                     'FBPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,FBinQBModeLan,ColorFormat);
                                     'PBPaletteData' : error:=WritePalData(ExportDialog.FileName,PBLan,ColorFormat);
                                     'PBPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,PBLan,ColorFormat);
                                     'BAMPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,BAMLan,ColorEightBitFormat);
                                     'BAMPaletteData' : error:=WritePalData(ExportDialog.FileName,BAMLan,ColorEightBitFormat);


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

   if ExportTextFileToClipboard(Sender) then exit;

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

procedure TRMMainForm.BAMPutDataClick(Sender: TObject);
 var
  x,y,x2,y2 : integer;
  error : word;
 begin
    GetOpenSaveRegion(x,y,x2,y2);
    ExportDialog.FileName:='';
    Case (Sender As TMenuItem).Name of 'BAMPutData' :ExportDialog.Filter := 'BAM Put Data Statements|*.bas';
                                       'BAMPutPlusMaskData' :ExportDialog.Filter := 'BAM Put+Mask Data Statements|*.bas';
                                       'BAMRGBPutData' :ExportDialog.Filter := 'BAM Put RGB Data Statements|*.bas';

    End;

    if ExportTextFileToClipboard(Sender) then exit;

    if ExportDialog.Execute then
    begin
       Case (Sender As TMenuItem).Name of 'BAMPutData' : error:=WriteXGFToCode(x,y,x2,y2,BAMLan,ExportDialog.FileName);
                                          'BAMPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,BAMLan,ExportDialog.FileName);
                                          'BAMRGBPutData' : error:=WriteXGFToCodeEx(x,y,x2,y2,BAMLan,RGBExportFormat,ExportDialog.FileName);
       End;

       if (error<>0) then
       begin
          ShowMessage('Error Saving file!');
          exit;
       end;
    end;
end;

procedure TRMMainForm.BulkExportPNGClick(Sender: TObject);
var
 PngRGBA : PngRGBASettingsRec;
 FileName : String;
 i : integer;
begin
 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
 FilePropertiesDialog.GetProps(PngRGBA);
 if SelectDirectoryDialog.Execute then
 begin
   for i:=0 to ImageThumbBase.GetCount-1 do
   begin
     FileName:=IncludeTrailingPathDelimiter(SelectDirectoryDialog.filename)+ImageThumbBase.GetExportName(i)+'.png';
     SaveFromThumbAsPNG(i,FileName,PngRGBA);
   end;
 end;
end;

procedure TRMMainForm.EditColorBox1Click(Sender: TObject);
begin
  EditColors(cbColorBox1);
end;



procedure TRMMainForm.TMTPascalClick(Sender: TObject);
var
 x,y,x2,y2 : integer;
 error : word;
begin
  GetOpenSaveRegion(x,y,x2,y2);
  Case (Sender As TMenuItem).Name of 'TMTPutImageArray' :ExportDialog.Filter := 'TMT Pascal PutImage Array|*.pas';
//                                  'TMTPutImagePlusMaskArray' :ExportDialog.Filter := 'TMT Pascal PutImage+Mask Array|*.pas';
                                  'TMTPutImageFile' : ExportDialog.Filter := 'TMT Pascal PutImage File|*.xgf';



  End;

  if ExportTextFileToClipboard(Sender) then exit;

  if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'TMTPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,TMTLan,ExportDialog.FileName);
                         //        'TMTPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,TPLan,ExportDialog.FileName);
                                         'TMTPutImageFile' : error:=WriteXGFToFile(x,y,x2,y2,TMTLan,ExportDialog.FileName);

      End;

      if error<>0 then
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

  if ExportTextFileToClipboard(Sender) then exit;

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

   if ExportTextFileToClipboard(Sender) then exit;

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



procedure TRMMainForm.SetCustomGridCellClick(Sender: TObject);
begin
   if SetCustomCellSizeForm.ShowModal = mrOK then
  begin
    SetGridCellClick(Sender);
  end;
end;

procedure TRMMainForm.SetGridCellClick(Sender: TObject);
begin
  if (Sender As TMenuItem).Name = 'gcNormal' then
  begin
    RMDrawTools.SetCellWidthMin(10);
    RMDrawTools.SetCellHeightMin(9);
  end
  else if (Sender As TMenuItem).Name = 'gcWide' then
  begin
    RMDrawTools.SetCellWidthMin(16);
    RMDrawTools.SetCellHeightMin(8);
  end
  else if (Sender As TMenuItem).Name = 'gcTall' then
  begin
    RMDrawTools.SetCellWidthMin(8);
    RMDrawTools.SetCellHeightMin(16);
  end
  else if (Sender As TMenuItem).Name = 'gcCustom' then
  begin
    RMDrawTools.SetCellWidthMin(setcustomcellsizeform.SpinEditCellWidth.Value);
    RMDrawTools.SetCellHeightMin(setcustomcellsizeform.SpinEditCellHeight.Value);
  end;

  RMDrawTools.SetZoomSize(ZoomSize);
  ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
  ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;

  RMDrawTools.SetZoomMaxX(RMDrawTools.GetZoomPageWidth);
  RMDrawTools.SetZoomMaxY(RMDrawTools.GetZoomPageHeight);
  RMDrawTools.SetClipStatus(0); // turn off in case clip area is bigger than work area

  ZoomTrackBar.Position:=RMDrawTools.GetZoomSize;;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbView;
  UpdateEditMenu;
  UpdateStatusInfo;
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

   if ExportTextFileToClipboard(Sender) then exit;

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

Procedure TRMMainForm.UpdateEditMenu;
var
 swidth,sheight : integer;
 gcWidth,gcHeight : integer;
begin
  EditResizeTo8.Checked:=false;
  EditResizeTo16.Checked:=false;
  EditResizeTo32.Checked:=false;
  EditResizeTo64.Checked:=false;
  EditResizeTo128.Checked:=false;
  EditResizeTo256.Checked:=false;
  ShowCustomSize.Checked:=false;
  ShowCustomSize.Caption:='';
  swidth:=RMCoreBase.GetWidth;
  sheight:=RMCoreBase.GetHeight;
  if (swidth=8) and (sheight=8) then  EditResizeTo8.Checked:=true
  else if (swidth=16) and (sheight=16) then EditResizeTo16.Checked:=true
  else if (swidth=32) and (sheight=32) then EditResizeTo32.Checked:=true
  else if (swidth=64) and (sheight=64) then EditResizeTo64.Checked:=true
  else if (swidth=128) and (sheight=128) then EditResizeTo128.Checked:=true
  else if (swidth=256) and (sheight=256) then EditResizeTo256.Checked:=true
  else
  begin
    ShowCustomSize.Caption:=IntToStr(swidth)+'X'+IntToStr(sheight);
    ShowCustomSize.Checked:=true;
    RMCoreBase.SetWidth(swidth);
    RMCoreBase.SetHeight(sheight);
  end;

  gcNormal.Checked:=false;
  gcWide.Checked:=false;
  gcTall.Checked:=false;
  gcCustomShow.Caption:='';
  gcCustomShow.Checked:=false;
  gcWidth:=RMDrawTools.GetCellWidthMin;
  gcHeight:=RMDrawTools.GetCellHeightMin;
  if (gcwidth=10) and (gcheight=9) then gcNormal.Checked:=true
  else if (gcwidth=16) and (gcheight=8) then gcWide.Checked:=true
  else if (gcwidth=8) and (gcheight=16) then gcTall.Checked:=true
  else
  begin
    gcCustomShow.Checked:=true;
    gcCustomShow.Caption:=IntToStr(gcwidth)+'X'+IntToStr(gcheight);
  end;


end;

procedure TRMMainForm.EditResizeToNewSize(Sender: TObject);
var
 ImgWidth,ImgHeight,zsize : integer;
begin
  zsize:=2;
  if (Sender As TMenuItem).Name = 'EditResizeTo8' then
  begin
    ImgWidth:=8;
    ImgHeight:=8;
    zsize:=9;
  end
  else if (Sender As TMenuItem).Name = 'EditResizeTo16' then
  begin
    ImgWidth:=16;
    ImgHeight:=16;
    zsize:=4;
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
  end
  else if (Sender As TMenuItem).Name = 'EditResizeCustom' then
  begin
    ImgWidth:=setcustomspritesizeform.SpinEditWidth.Value;
    ImgHeight:=setcustomspritesizeform.SpinEditHeight.Value;
  end;

  RMCoreBase.SetWidth(ImgWidth);
  RMCoreBase.SetHeight(ImgHeight);
  RMDrawTools.SetZoomSize(zsize);

  ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
  ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;

  RMDrawTools.SetZoomMaxX(RMDrawTools.GetZoomPageWidth);
  RMDrawTools.SetZoomMaxY(RMDrawTools.GetZoomPageHeight);
  RMDrawTools.SetClipStatus(0); // turn off in case clip area is bigger than work area
  ZoomSize:=RMDrawTools.GetZoomSize;
  ZoomTrackBar.Position:=ZoomSize;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbView;
  UpdateEditMenu;
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

   if ExportTextFileToClipboard(Sender) then exit;

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

Procedure TRMMainForm.EditColors(ColorBox : integer);
var
  PI : integer;
  cr : TRMColorRec;
  ci : integer;
  pm : integer;
begin
   pm:=RMCoreBase.Palette.GetPaletteMode;
   If (pm = PaletteModeVGA) OR (pm = PaletteModeVGA256) OR
      (pm = PaletteModeMono) OR (pm = PaletteModeCGA0) OR (pm = PaletteModeCGA1) then
   begin
      if ColorBox = cbColorBox1 then
         RMVGAColorDialog.SetPickedIndex(RMCoreBase.GetCurColor1)
      else RMVGAColorDialog.SetPickedIndex(RMCoreBase.GetCurColor2);

      if pm = PaletteModeVGA then
         RMVGAColorDialog.InitColorBox16
      else if pm = PaletteModeVGA256 then
         RMVGAColorDialog.InitColorBox256
      else if pm = PaletteModeMono then
         RMVGAColorDialog.InitColorBox2
      else //CGA0 or CGA1
         RMVGAColorDialog.InitColorBox4;

      if RMVGAColorDialog.ShowModal = mrOK then
      begin
         PI:=RMVGAColorDialog.GetPickedIndex;

         if ColorBox = cbColorBox1 then
            RMCoreBase.SetCurColor1(PI)
         else RMCoreBase.SetCurColor2(PI);

         ColorPalette1.PickedIndex:=PI;
         RMVGAColorDialog.PaletteToCore;
         CoreToPalette;

         UpdateColorBoxes;
         UpdateActualArea;
         UpdateZoomArea;
         UpdateThumbview;
      end;
  end
  else If (pm = PaletteModeXGA) OR (pm = PaletteModeXGA256) then
  begin
       if ColorBox = cbColorBox1 then
          RMXGAColorDialog.SetPickedIndex(RMCoreBase.GetCurColor1)
       else RMXGAColorDialog.SetPickedIndex(RMCoreBase.GetCurColor2);

       if pm = PaletteModeXGA then
          RMXGAColorDialog.InitColorBox16
       else RMXGAColorDialog.InitColorBox256;

       if RMXGAColorDialog.ShowModal = mrOK then
       begin
          PI:=RMXGAColorDialog.GetPickedIndex;

          if ColorBox = cbColorBox1 then
             RMCoreBase.SetCurColor1(PI)
          else RMCoreBase.SetCurColor2(PI);

          ColorPalette1.PickedIndex:=PI;
          RMXGAColorDialog.PaletteToCore;
          CoreToPalette;

          UpdateColorBoxes;
          UpdateActualArea;
          UpdateZoomArea;
          UpdateThumbview;
       end;
  end
  else if (pm = PaletteModeEGA) then
  begin
     if ColorBox = cbColorBox1 then
        RMEGAColorDialog.SetSelectedColor(RMCoreBase.GetCurColor1)
     else RMEGAColorDialog.SetSelectedColor(RMCoreBase.GetCurColor2);

     RMEGAColorDialog.InitColorBox;
     if RMEGAColorDialog.ShowModal = mrOK then
     begin
       PI:=RMEGAColorDialog.GetPickedIndex;           //this is EGA Picked Index,0 to 63
       if (PI > -1) then
       begin
         if ColorBox = cbColorBox1 then
            ci:=RMCoreBase.GetCurColor1
         else ci:=RMCoreBase.GetCurColor2;

         ColorPalette1.Colors[ci]:=RMEGAColorDialog.GetPickedColor;

         GetDefaultRGBEGA64(PI, cr);
         RMCoreBase.Palette.SetColor(ci,cr);

         if ColorBox = cbColorBox1 then
            RMCoreBase.SetCurColor1(ci)
         else RMCoreBase.SetCurColor2(ci);

         UpdateColorBoxes;
         UpdateActualArea;
         UpdateZoomArea;
         UpdateThumbview;
       end;
     end;
  end
  else if (pm >= PaletteModeAmiga2) AND (pm <= PaletteModeAmiga32) then
  begin

    if ColorBox = cbColorBox1 then
       RMAmigaColorDialog.SetPickedIndex(RMCoreBase.GetCurColor1)
    else RMAmigaColorDialog.SetPickedIndex(RMCoreBase.GetCurColor2);

    case pm of PaletteModeAmiga2:RMAmigaColorDialog.InitColorBox2;
               PaletteModeAmiga4:RMAmigaColorDialog.InitColorBox4;
               PaletteModeAmiga8:RMAmigaColorDialog.InitColorBox8;
               PaletteModeAmiga16:RMAmigaColorDialog.InitColorBox16;
               PaletteModeAmiga32:RMAmigaColorDialog.InitColorBox32
    end;

    if RMAmigaColorDialog.ShowModal = mrOK then
    begin
 (*      PI:=RMAmigaColorDialog.GetPickedIndex;
       RMCoreBase.SetCurColor1(PI);
       ColorPalette1.PickedIndex:=PI;

       ColorBox1.Brush.Color:=RMAmigaColorDialog.GetPickedColor;
       RMAmigaColorDialog.PaletteToCore;
       CoreToPalette;

       UpdateActualArea;
       UpdateZoomArea;
       UpdateThumbview;
             *)

       PI:=RMAmigaColorDialog.GetPickedIndex;

       if ColorBox = cbColorBox1 then
          RMCoreBase.SetCurColor1(PI)
       else RMCoreBase.SetCurColor2(PI);

       ColorPalette1.PickedIndex:=PI;
       RMAmigaColorDialog.PaletteToCore;
       CoreToPalette;

       UpdateColorBoxes;
       UpdateActualArea;
       UpdateZoomArea;
       UpdateThumbview;
   end;
 end;
end;

procedure TRMMainForm.PaletteEditColors(Sender: TObject);
begin
  if RMCoreBase.GetCurColorBox = cbColorBox1 then
     EditColors(cbColorBox1)
  else EditColors(cbColorBox2);
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

function TRMMainForm.ExportTextFileToClipboard(Sender: TObject) : boolean;
var
 x,y,x2,y2 : integer;
 error : word;
 filename : string;
begin
 if rmconfigbase.GetExportTextFileToClipStatus = false then
 begin
   result:=false;
   exit;
 end;

 GetOpenSaveRegion(x,y,x2,y2);
 filename:=GetTemporaryPathWithProvidedFileName(ImagethumbBase.GetExportName(ImagethumbBase.GetCurrent));
 Case (Sender As TMenuItem).Name of       'ExportRESInclude' :begin
                                                                filename:=GetTemporaryPathAndFileName;
                                                                error:=RESInclude(FileName,0,FALSE);
                                                              end;
                                          'ABPutData' : error:=WriteAmigaBasicXGFDataFile(x,y,x2,y2,FileName);
                                          'ABPutPlusMaskData' : error:=WriteAmigaBasicXGFPlusMaskDataFile(x,y,x2,y2,FileName);
                                          'ABBobData' : error:=WriteAmigaBasicBobDataFile(x,y,x2,y2,filename,false);
                                          'ABVSpriteData' : error:=WriteAmigaBasicBobDataFile(x,y,x2,y2,FileName,true);

                                          'CBOBBitmapArray':error:=WriteAmigaCBobCodeToFile(x,y,x2,y2,FileName,False);
                                          'CVSpriteBitmapArray':error:=WriteAmigaCBobCodeToFile(x,y,x2,y2,FileName,true);

                                          'PascalBOBBitmapArray':error:=WriteAmigaPascalBobCodeToFile(x,y,x2,y2,FileName,false);
                                          'PascalVSpriteBitmapArray':error:=WriteAmigaPascalBobCodeToFile(x,y,x2,y2,FileName,true);

                                          'AqbPsetBitMap':  error:=WriteAQBBitMapCodeToFile(x,y,x2,y2,FileName);

                                          'BAMPutData' : error:=WriteXGFToCode(x,y,x2,y2,BAMLan,FileName);
                                          'BAMPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,BAMLan,FileName);
                                          'BAMRGBPutData' : error:=WriteXGFToCodeEx(x,y,x2,y2,BAMLan,RGBExportFormat,FileName);

                                          'FBPutData' : error:=WriteXGFToCode(x,y,x2,y2,FBinQBModeLan,FileName);
                                          'FBPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,FBinQBModeLan,FileName);

                                          'FPPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,FPLan,FileName);
                                          'FPPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,FPLan,FileName);

                                          'GWPutData' : error:=WriteXGFToCode(x,y,x2,y2,GWLan,FileName);
                                          'GWPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,GWLan,FileName);

                                          'fpRayLibFuchsia' :begin
                                                               WriteRayLibCodeToFile(FileName,x,y,x2,y2,FPLan,1);
                                                               {$I+}
                                                               error:=IORESULT;
                                                               {$I-}
                                                             end;
                                          'fpRayLibIndex0'  :begin
                                                               WriteRayLibCodeToFile(FileName,x,y,x2,y2,FPLan,2);
                                                               {$I+}
                                                               error:=IORESULT;
                                                               {$I-}
                                                              end;
                                          'fpRayLibCustom'  :begin
                                                               WriteRayLibCodeToFile(FileName,x,y,x2,y2,FPLan,4);
                                                               {$I+}
                                                               error:=IORESULT;
                                                               {$I-}
                                                              end;
                                          'fpRayLibRGB' :begin
                                                           WriteRayLibCodeToFile(FileName,x,y,x2,y2,FPLan,3);
                                                           {$I+}
                                                           error:=IORESULT;
                                                           {$I-}
                                                          end;
                                       'gccRayLibFuchsia':begin
                                                            WriteRayLibCodeToFile(FileName,x,y,x2,y2,gccLan,1);
                                                            {$I+}
                                                            error:=IORESULT;
                                                            {$I-}
                                                           end;
                                         'gccRayLibIndex0':begin
                                                             WriteRayLibCodeToFile(FileName,x,y,x2,y2,gccLan,2);
                                                             {$I+}
                                                             error:=IORESULT;
                                                             {$I-}
                                                            end;
                                         'gccRayLibCustom':begin
                                                             WriteRayLibCodeToFile(FileName,x,y,x2,y2,gccLan,4);
                                                             {$I+}
                                                             error:=IORESULT;
                                                             {$I-}
                                                            end;

                                           'gccRayLibRGB' : begin
                                                              WriteRayLibCodeToFile(FileName,x,y,x2,y2,gccLan,3);
                                                              {$I+}
                                                              error:=IORESULT;
                                                              {$I-}
                                                             end;
                                            'qb64RGBAFuchsia':begin
                                                                WriteRayLibCodeToFile(FileName,x,y,x2,y2,QB64Lan,1);
                                                                {$I+}
                                                                error:=IORESULT;
                                                                {$I-}
                                                              end;
                                             'qb64RGBAIndex0':begin
                                                                 WriteRayLibCodeToFile(FileName,x,y,x2,y2,QB64Lan,2);
                                                                {$I+}
                                                                error:=IORESULT;
                                                                {$I-}
                                                              end;
                                             'qb64RGBACustom':begin
                                                                 WriteRayLibCodeToFile(FileName,x,y,x2,y2,QB64Lan,4);
                                                                {$I+}
                                                                error:=IORESULT;
                                                                {$I-}
                                                              end;

                                              'qb64RGB' : begin
                                                                 WriteRayLibCodeToFile(FileName,x,y,x2,y2,QB64Lan,3);
                                                                {$I+}
                                                                error:=IORESULT;
                                                                {$I-}
                                                               end;
                                              'qbjsRGBAFuchsia':begin
                                                                  WriteRayLibCodeToFile(FileName,x,y,x2,y2,QBJSLan,1);
                                                                  {$I+}
                                                                  error:=IORESULT;
                                                                  {$I-}
                                                                end;
                                               'qbjsRGBAIndex0':begin
                                                                   WriteRayLibCodeToFile(FileName,x,y,x2,y2,QBJSLan,2);
                                                                  {$I+}
                                                                  error:=IORESULT;
                                                                  {$I-}
                                                                end;
                                               'qbjsRGBACustom':begin
                                                                   WriteRayLibCodeToFile(FileName,x,y,x2,y2,QBJSLan,4);
                                                                  {$I+}
                                                                  error:=IORESULT;
                                                                  {$I-}
                                                                end;

                                                'qbjsRGB' : begin
                                                                   WriteRayLibCodeToFile(FileName,x,y,x2,y2,QBJSLan,3);
                                                                  {$I+}
                                                                  error:=IORESULT;
                                                                  {$I-}
                                                                 end;

                                             'fbRayLibFuchsia':begin
                                                                 WriteRayLibCodeToFile(FileName,x,y,x2,y2,FBLan,1);
                                                                 {$I+}
                                                                 error:=IORESULT;
                                                                 {$I-}
                                                               end;
                                             'fbRayLibIndex0':begin
                                                                WriteRayLibCodeToFile(FileName,x,y,x2,y2,FBLan,2);
                                                                {$I+}
                                                                error:=IORESULT;
                                                                {$I-}
                                                              end;
                                              'fbRayLibRGB' : begin
                                                                WriteRayLibCodeToFile(FileName,x,y,x2,y2,FBLan,3);
                                                                {$I+}
                                                                error:=IORESULT;
                                                                {$I-}
                                                               end;

                                          'OWPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,OWLan,FileName);
                                          'OWPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,OWLan,FileName);

                                          'QBPutData' : error:=WriteXGFToCode(x,y,x2,y2,QBLan,FileName);
                                          'QBPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,QBLan,FileName);

                                          'QCPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,QCLan,FileName);
                                          'QCPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,QCLan,FileName);

                                          'QPPutImageArray' : error:=WriteXgfToCode(x,y,x2,y2,QPLan,FileName);
                                          'QPPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,QPLan,FileName);

                                          'TBPutData' : error:=WriteXGFToCode(x,y,x2,y2,PBLan,FileName);
                                          'TBPutPlusMaskData' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,PBLan,FileName);

                                          'TPPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,TPLan,FileName);
                                          'TPPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,TPLan,FileName);
                                          'TPDOSLBMArray' : error:=WriteLBMToCode(x,y,x2,y2,TPLan,FileName);
                                          'TPDOSPBMArray' : error:=WritePBMToCode(x,y,x2,y2,TPLan,FileName);

                                          'TMTPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,TMTLan,FileName);

                                          'TCPutImageArray' : error:=WriteXGFToCode(x,y,x2,y2,TCLan,FileName);
                                          'TCPutImagePlusMaskArray' : error:=WriteXgfWithMaskToCode(x,y,x2,y2,TCLan,FileName);
                                          'TCDOSLBMArray' : error:=WriteLBMToCode(x,y,x2,y2,TCLan,FileName);
                                          'TCDOSPBMArray' : error:=WritePBMToCode(x,y,x2,y2,TCLan,FileName);

                                          'QBMouseShapeData',
                                          'FBMouseShapeData',
                                          'TBMouseShapeData': error:=WriteMShapeToCode(x,y,QBLan,1,FileName);
                                          'GWMouseShapeData': error:=WriteMShapeToCode(x,y,GWLan,1,FileName);
                                          'TPMouseShapeArray',
                                          'QPMouseShapeArray': error:=WriteMShapeToCode(x,y,TPLan,1,FileName);
                                          'TCMouseShapeArray',
                                          'QCMouseShapeArray',
                                          'OWMouseShapeArray': error:=WriteMShapeToCode(x,y,TCLan,1,FileName);
                                          'GWMouseShapeFile',
                                          'FPMouseShapeFile',
                                          'FBMouseShapeFile',
                                          'TPMouseShapeFile',
                                          'QPMouseShapeFile',
                                          'QBMouseShapeFile',
                                          'TBMouseShapeFile',
                                          'TCMouseShapeFile',
                                          'QCMouseShapeFile',
                                          'OWMouseShapeFile':error:=WriteMShapeToFile(x,y,FileName);
                                          'TransparentImage':error:=WriteJavaScriptArray(x,y,x2,y2,Filename,true);
                                          'NonTransparentImage':error:=WriteJavaScriptArray(x,y,x2,y2,FileName,false);

 else
   result:=false;  //did not find a supported format return false
   exit;
 End;

 result:=true;  //found supported format - return true
 if error<>0 then
 begin
    ShowMessage('Error Exporting!');
    exit;
 end;

 ReadFileAndCopyToClipboard(filename);
 EraseFile(filename);
 ShowMessage('Exported to Clipboard!');
end;

function TRMMainForm.ExportPaletteTextFileToClipboard(Sender: TObject; ColorFormat : integer) : boolean;
var
 error : word;
 filename : string;
begin
 if rmconfigbase.GetExportTextFileToClipStatus = false then
 begin
   result:=false;
   exit;
 end;

 filename:=GetTemporaryPathWithProvidedFileName(ImagethumbBase.GetExportName(ImagethumbBase.GetCurrent)+'Pal');
 Case (Sender As TMenuItem).Name of
                                          'ABPaletteData'  : error:=WritePalData(FileName,ABLan,ColorOnePercentFormat);
                                          'ABPaletteCommands' : error:=WritePalStatements(FileName,ABLan,ColorOnePercentFormat);

                                          'ACVSpriteColorArray' :  error:=WriteRGBPackedPalArray(FileName,ACLan,true);
                                          'ACPaletteArray'    :  error:=WritePalConstants(FileName,ACLan,ColorFourBitFormat);
                                          'ACRGB4PaletteArray' :  error:=WriteRGBPackedPalArray(FileName,ACLan,false);

                                          'APVSpriteColorArray' :  error:=WriteRGBPackedPalArray(FileName,APLan,true);
                                          'APPaletteArray'     :  error:=WritePalConstants(FileName,APLan,ColorFourBitFormat);
                                          'APRGB4PaletteArray'  :  error:=WriteRGBPackedPalArray(FileName,APLan,false);

                                          'QBPaletteData' : error:=WritePalData(FileName,QBLan,ColorFormat);
                                          'QBPaletteCommands' : error:=WritePalStatements(FileName,QBLan,ColorFormat);
                                          'FBPaletteData' : error:=WritePalData(FileName,FBinQBModeLan,ColorFormat);
                                          'FBPaletteCommands' : error:=WritePalStatements(FileName,FBinQBModeLan,ColorFormat);
                                          'PBPaletteData' : error:=WritePalData(FileName,PBLan,ColorFormat);
                                          'PBPaletteCommands' : error:=WritePalStatements(FileName,PBLan,ColorFormat);
                                          'BAMPaletteCommands' : error:=WritePalStatements(FileName,BAMLan,ColorEightBitFormat);
                                          'BAMPaletteData' : error:=WritePalData(FileName,BAMLan,ColorEightBitFormat);

                                          'TPPaletteArray' : error:=WritePalConstants(FileName,TPLan,ColorFormat);
                                          'TPPaletteCommands' : error:=WritePalStatements(FileName,TPLan,ColorFormat);
                                          'FPPaletteArray' : error:=WritePalConstants(FileName,FPLan,ColorFormat);
                                          'FPPaletteCommands' : error:=WritePalStatements(FileName,FPLan,ColorFormat);
                                          'TMTPaletteArray' : error:=WritePalConstants(FileName,TMTLan,ColorEightBitFormat);
                                          'TMTPaletteCommands' : error:=WritePalStatements(FileName,TMTLan,ColorEightBitFormat);

                                          'GWPaletteData' : error:=WritePalData(FileName,GWLan,ColorFormat);
                                          'GWPaletteCommands' : error:=WritePalStatements(FileName,GWLan,ColorFormat);

                                          'OWPaletteArray' : error:=WritePalConstants(FileName,OWLan,ColorFormat);
                                          'OWPaletteCommands' : error:=WritePalStatements(FileName,OWLan,ColorFormat);

                                          'QCPaletteArray' : error:=WritePalConstants(FileName,QCLan,ColorFormat);
                                          'QCPaletteCommands' : error:=WritePalStatements(FileName,QCLan,ColorFormat);
                                          'QPPaletteArray' : error:=WritePalConstants(FileName,QPLan,ColorFormat);
                                          'QPPaletteCommands' : error:=WritePalStatements(FileName,QPLan,ColorFormat);

                                          'TCPaletteArray' : error:=WritePalConstants(FileName,TCLan,ColorFormat);
                                          'TCPaletteCommands' : error:=WritePalStatements(FileName,TCLan,ColorFormat);
 else
   result:=false;  //did not find a supported format return false
   exit;
 End;

 result:=true;  //found supported format - return true
 if error<>0 then
 begin
    ShowMessage('Error Exporting!');
    exit;
 end;

 ReadFileAndCopyToClipboard(filename);
 EraseFile(filename);
 ShowMessage('Exported to Clipboard!');
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

  if ExportTextFileToClipboard(Sender) then exit;

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

 if ExportTextFileToClipboard(Sender) then exit;  //copy to clipboard found export format and was success - if it doesn't we contnue to export to file

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

    pm:=RMCoreBase.Palette.GetPaletteMode;
    ColorFormat:=ColorSixBitFormat;
    if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

    if ExportPaletteTextFileToClipboard(Sender,ColorFormat) then exit;

    if ExportDialog.Execute then
    begin
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

   pm:=RMCoreBase.Palette.GetPaletteMode;
   ColorFormat:=ColorEightBitFormat;
   if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

   if ExportPaletteTextFileToClipboard(Sender,ColorFormat) then exit;

   if ExportDialog.Execute then
   begin
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

   if ExportTextFileToClipboard(Sender) then exit;

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

    pm:=RMCoreBase.Palette.GetPaletteMode;
    ColorFormat:=ColorSixBitFormat;
    if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

    if ExportPaletteTextFileToClipboard(Sender,ColorFormat) then exit;

    if ExportDialog.Execute then
    begin
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
  if not ConfirmPaletteSwitch(PaletteModeXGA256) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeXGA256)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteXGA256.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeXGA256);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteXGA256.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteXGAClick(Sender: TObject);
begin
  if not ConfirmPaletteSwitch(PaletteModeXGA) then exit;

  if ImageHasData then
    RemapImageToNewPalette(PaletteModeXGA)
  else
  begin
    ClearSelectedPaletteMenu;
    PaletteXGA.Checked:=true;
    RMCoreBase.Palette.SetPaletteMode(PaletteModeXGA);
    LoadDefaultPalette;
    RMCoreBase.CopyToUndoBuf;
  end;

  ClearSelectedPaletteMenu;
  PaletteXGA.Checked:=true;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PropertiesFileDialogClick(Sender: TObject);
var
 PngRGBA : PngRGBASettingsRec;
begin
 FilePropertiesDialog.GetProps(PngRGBA);  //get values before change
 if FilePropertiesDialog.ShowModal = mrOK then
 begin
    FilePropertiesDialog.GetProps(PngRGBA); //get the new updated props
    rmconfigbase.SetProps(PngRGBA);  //set new values to config object
 end
 else
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

   if ExportTextFileToClipboard(Sender) then exit;

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

   if ExportTextFileToClipboard(Sender) then exit;

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

   if ExportTextFileToClipboard(Sender) then exit;

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

   if ExportTextFileToClipboard(Sender) then exit;

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

 if ExportTextFileToClipboard(Sender) then exit;

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

   if ExportPaletteTextFileToClipboard(Sender,0) then exit;

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

   if ExportTextFileToClipboard(Sender) then exit;

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

   if ExportTextFileToClipboard(Sender) then exit;

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

   if ExportPaletteTextFileToClipboard(Sender,0) then exit;

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

   if ExportTextFileToClipboard(Sender) then exit;

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

//returns 0=unknown/corrupt, 1=RM raw 8-bit PAL, 2=JASC text PAL, 3=VGA 6-bit PAL
function TRMMainForm.DetectPaletteFormat(filename : string) : integer;
var
  F : file;
  fsize : longint;
  sig : array[0..7] of char;
  buf : array[0..767] of byte;
  i, count : integer;
  isSixBit : boolean;
begin
  DetectPaletteFormat:=0;
  if not FileExists(filename) then exit;

  {$I-}
  AssignFile(F, filename);
  Reset(F, 1);
  if IOResult <> 0 then exit;

  fsize:=FileSize(F);
  if fsize <= 0 then
  begin
    CloseFile(F);
    if IOResult <> 0 then ;
    exit;
  end;

  //check for JASC text signature "JASC-PAL"
  if fsize >= 8 then
  begin
    BlockRead(F, sig, 8);
    if IOResult <> 0 then
    begin
      CloseFile(F);
      if IOResult <> 0 then ;
      exit;
    end;
    if (sig[0]='J') and (sig[1]='A') and (sig[2]='S') and (sig[3]='C') and
       (sig[4]='-') and (sig[5]='P') and (sig[6]='A') and (sig[7]='L') then
    begin
      CloseFile(F);
      if IOResult <> 0 then ;
      DetectPaletteFormat:=2;
      exit;
    end;
    Seek(F, 0);
  end;

  //raw palette - must be one of the valid sizes ReadPAL accepts
  if (fsize=6) or (fsize=12) or (fsize=24) or (fsize=48) or (fsize=96) or (fsize=768) then
  begin
    count:=fsize;
    BlockRead(F, buf, count);
    if IOResult <> 0 then
    begin
      CloseFile(F);
      if IOResult <> 0 then ;
      exit;
    end;
    CloseFile(F);
    if IOResult <> 0 then ;

    //if every byte fits in 6 bits it is most likely a VGA DAC palette
    isSixBit:=true;
    for i:=0 to count-1 do
      if buf[i] > 63 then
      begin
        isSixBit:=false;
        break;
      end;

    if isSixBit and (fsize=768) then
      DetectPaletteFormat:=3
    else
      DetectPaletteFormat:=1;
    exit;
  end;

  CloseFile(F);
  if IOResult <> 0 then ;
  {$I+}
end;

procedure TRMMainForm.PaletteOpenClick(Sender: TObject);
Var
 pm : integer;
 fmt : integer;
 err : word;
begin
 OpenDialog1.Filter := 'All Palette Files|*.pal;*.vga|RM Palette (8-bit)|*.pal|JASC Palette|*.pal|VGA Palette (6-bit)|*.vga|All Files|*.*';
 if OpenDialog1.Execute then
 begin
     pm:=RMCoreBase.Palette.GetPaletteMode;

     //auto-detect the palette format from file contents
     //so the selected filter no longer matters
     fmt:=DetectPaletteFormat(OpenDialog1.FileName);

     err:=0;
     try
       case fmt of
         1: err:=ReadPAL(OpenDialog1.FileName, pm);
         2: err:=ReadJASCPAL(OpenDialog1.FileName, pm);
         3: err:=ReadVGAPAL(OpenDialog1.FileName, pm);
       else
         err:=1000; //unknown format or corrupt file
       end;
     except
       err:=1000;  //reader raised an exception - treat as corrupt
     end;

     if err <> 0 then
     begin
        ShowMessage('Unable to open palette.' + LineEnding +
                    'The file is not a recognized palette format or may be corrupt.');
        exit;
     end;
     CoreToPalette;
     UpdateColorBoxes;
     UpDateZoomArea;
     UpdateActualArea;
     UpdateThumbView;
 end;
end;

procedure TRMMainForm.PaletteSaveClick(Sender: TObject);
var
  err : word;
begin
 SaveDialog1.Filter := 'RM Palette (8-bit)|*.pal|JASC Palette|*.pal|VGA Palette (6-bit)|*.vga';
 if SaveDialog1.Execute then
 begin
   err:=0;
   case SaveDialog1.FilterIndex of
     1: err:=WritePAL(SaveDialog1.FileName);
     2: err:=WriteJASCPAL(SaveDialog1.FileName);
     3: err:=WriteVGAPAL(SaveDialog1.FileName);
   end;
   if err <> 0 then
   begin
     ShowMessage('Error Saving Palette file!');
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

   if ExportPaletteTextFileToClipboard(Sender,0) then exit;

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

   pm:=RMCoreBase.Palette.GetPaletteMode;
   ColorFormat:=ColorSixBitFormat;
   if pm=PaletteModeEGA then ColorFormat:=ColorIndexFormat;

   if ExportPaletteTextFileToClipboard(Sender,ColorFormat) then exit;

   if ExportDialog.Execute then
   begin
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
                                         'TMTPaletteArray' : ExportDialog.Filter := 'TMT Pascal Palette Array|*.pas';
                                         'TMTPaletteCommands' : ExportDialog.Filter :='TMT Pascal Palette Commands|*.pas';

   end;

   ColorFormat:=ColorEightBitFormat;
   pm:=RMCoreBase.Palette.GetPaletteMode;
   if (pm=PaletteModeEGA) then ColorFormat:=ColorIndexFormat;

   if ExportPaletteTextFileToClipboard(Sender,ColorFormat) then exit;

   if ExportDialog.Execute then
   begin
      Case (Sender As TMenuItem).Name of 'TPPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,TPLan,ColorFormat);
                                      'TPPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,TPLan,ColorFormat);
                                      'FPPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,FPLan,ColorFormat);
                                      'FPPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,FPLan,ColorFormat);
                                      'TMTPaletteArray' : error:=WritePalConstants(ExportDialog.FileName,TMTLan,ColorEightBitFormat);
                                      'TMTPaletteCommands' : error:=WritePalStatements(ExportDialog.FileName,TMTLan,ColorEightBitFormat);

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

   if ExportTextFileToClipboard(Sender) then exit;

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
 TextBmp : TBitmap;
 BrushBmp : TBitmap;
 w, h, i, j : integer;
 TextStr : string;
 ci : byte;
 pal : TRMPaletteBuf;
begin
  //when brush stamp tool is active, copy working brush to clipboard
  if RMDrawTools.GetDrawTool = DrawShapeBrush then
  begin
    if not RetroBrush.HasBrush then exit;

    RMCoreBase.Palette.GetPalette(pal);
    RetroBrush.InvalidateRemap;
    RetroBrush.BuildRemapTable(pal,
      RMCoreBase.Palette.GetPaletteMode,
      RMCoreBase.Palette.GetColorCount);

    BrushBmp:=TBitmap.Create;
    try
      w:=RetroBrush.WorkWidth;
      h:=RetroBrush.WorkHeight;
      BrushBmp.SetSize(w, h);
      BrushBmp.Canvas.Brush.Color:=clBlack;
      BrushBmp.Canvas.FillRect(0, 0, w, h);

      for i:=0 to w-1 do
        for j:=0 to h-1 do
        begin
          ci:=RetroBrush.WorkPixels[i][j];
          if ci <> RetroBrush.TransColor then
            BrushBmp.Canvas.Pixels[i, j]:=
              RGBToColor(pal[RetroBrush.RemapIndex(ci)].r,
                         pal[RetroBrush.RemapIndex(ci)].g,
                         pal[RetroBrush.RemapIndex(ci)].b);
        end;
      Clipboard.Assign(BrushBmp);
    finally
      BrushBmp.Free;
    end;
    exit;
  end;

  //when text tool is active, copy the text bitmap to clipboard
  if RMDrawTools.GetDrawTool = DrawShapeText then
  begin
    TextStr:=TextDrawEdit.Text;
    if TextStr = '' then exit;

    TextBmp:=TBitmap.Create;
    try
      TextBmp.Canvas.Font:=FontDialog1.Font;
      TextBmp.Canvas.Font.Quality:=fqNonAntialiased;
      w:=TextBmp.Canvas.TextWidth(TextStr);
      h:=TextBmp.Canvas.TextHeight(TextStr);
      if w < 1 then w:=1;
      if h < 1 then h:=1;
      TextBmp.SetSize(w, h);
      TextBmp.Canvas.Brush.Color:=clBlack;
      TextBmp.Canvas.FillRect(0, 0, w, h);
      TextBmp.Canvas.Font.Color:=ColorBox1.Brush.Color;
      TextBmp.Canvas.TextOut(0, 0, TextStr);
      Clipboard.Assign(TextBmp);
    finally
      TextBmp.Free;
    end;
    exit;
  end;

  //normal copy behavior
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

procedure TRMMainForm.EditPastePaletteClick(Sender: TObject);
var
  ClipBmp : TBitmap;
  w, h, i, j : integer;
  pal : TRMPaletteBuf;
  colorCount : integer;
  usedColors : array[0..255] of boolean;
  hasImage : boolean;
  pc : TColor;
  r, g, b : byte;
  ci, ni : integer;
  bestIdx, bestDist, dist : integer;
  nextFreeSlot : integer;
  px, py, x, y, x2, y2 : integer;
  found : boolean;
  paletteModified : boolean;
begin
  if not Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
  begin
    ShowMessage('No image found on the clipboard.');
    exit;
  end;

  ClipBmp:=TBitmap.Create;
  try
    ClipBmp.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));
    w:=ClipBmp.Width;
    h:=ClipBmp.Height;
    if (w <= 0) or (h <= 0) then
    begin
      ShowMessage('Clipboard image is empty.');
      exit;
    end;

    //clamp paste size to sprite dimensions
    if w > RMCoreBase.GetWidth then w:=RMCoreBase.GetWidth;
    if h > RMCoreBase.GetHeight then h:=RMCoreBase.GetHeight;

    RMCoreBase.Palette.GetPalette(pal);
    colorCount:=RMCoreBase.Palette.GetColorCount;
    hasImage:=ImageHasData;
    paletteModified:=false;

    //find which color indices are currently used in the image
    for i:=0 to 255 do
      usedColors[i]:=false;
    usedColors[0]:=true;  //index 0 always considered used (background)

    if hasImage then
    begin
      for py:=0 to RMCoreBase.GetHeight-1 do
        for px:=0 to RMCoreBase.GetWidth-1 do
        begin
          ci:=RMCoreBase.GetPixel(px, py);
          if (ci >= 0) and (ci < colorCount) then
            usedColors[ci]:=true;
        end;
      nextFreeSlot:=-1;  //will search for unused slots on demand
    end
    else
      nextFreeSlot:=1;  //empty image: add colors starting at index 1

    RMCoreBase.CopyToUndoBuf;

    //get paste region
    GetOpenSaveRegion(x, y, x2, y2);

    //paste each pixel with palette handling
    for i:=0 to w-1 do
    begin
      for j:=0 to h-1 do
      begin
        if (x + i > x2) or (y + j > y2) then continue;

        pc:=ClipBmp.Canvas.Pixels[i, j];
        r:=Red(pc);
        g:=Green(pc);
        b:=Blue(pc);

        //1. try exact match in current palette
        found:=false;
        bestIdx:=0;
        for ni:=0 to colorCount-1 do
        begin
          if (pal[ni].r = r) and (pal[ni].g = g) and (pal[ni].b = b) then
          begin
            bestIdx:=ni;
            found:=true;
            break;
          end;
        end;

        //2. no exact match - try to add to a free/unused slot
        if not found then
        begin
          if not hasImage then
          begin
            //empty image: add sequentially starting at index 1
            if nextFreeSlot < colorCount then
            begin
              pal[nextFreeSlot].r:=r;
              pal[nextFreeSlot].g:=g;
              pal[nextFreeSlot].b:=b;
              usedColors[nextFreeSlot]:=true;
              bestIdx:=nextFreeSlot;
              inc(nextFreeSlot);
              found:=true;
              paletteModified:=true;
            end;
          end
          else
          begin
            //existing image: find an unused palette slot to replace
            for ni:=1 to colorCount-1 do
            begin
              if not usedColors[ni] then
              begin
                pal[ni].r:=r;
                pal[ni].g:=g;
                pal[ni].b:=b;
                usedColors[ni]:=true;
                bestIdx:=ni;
                found:=true;
                paletteModified:=true;
                break;
              end;
            end;
          end;
        end;

        //3. all slots used - nearest color match
        if not found then
        begin
          bestDist:=MaxInt;
          for ni:=0 to colorCount-1 do
          begin
            dist:=(r - pal[ni].r) * (r - pal[ni].r) +
                  (g - pal[ni].g) * (g - pal[ni].g) +
                  (b - pal[ni].b) * (b - pal[ni].b);
            if dist < bestDist then
            begin
              bestDist:=dist;
              bestIdx:=ni;
            end;
          end;
        end;

        RMCoreBase.SetColorEx(bestIdx);
        RMCoreBase.PutPixelEx(x + i, y + j);
      end;
    end;

    //write modified palette back to core and UI
    if paletteModified then
    begin
      for ni:=0 to colorCount-1 do
        RMCoreBase.Palette.SetColor(ni, pal[ni]);
      CoreToPalette;
    end;

    ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);

    UpdateColorBoxes;
    UpdateActualArea;
    UpdateZoomArea;
    UpdateThumbView;
  finally
    ClipBmp.Free;
  end;
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

   ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
   ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;
   ZoomPaintBox.Canvas.Clear;

   RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
   RMDrawTools.SetZoomMaxX(ZoomPaintBox.Width);
   RMDrawTools.SetZoomMaxY(ZoomPaintBox.Height);

   ZoomSize:=RMDrawTools.GetZoomSize;

   CoreToPalette;
   UpdateColorBoxes;
   UpdateToolSelectionIcons;      //calls updatetoolsmenu
   UpdatePalette;
   UpdatePaletteMenu;
   UpdateEditMenu;
   UpdateActualArea;
   UpdateZoomArea;
   UpdateZoomScroller;
   UpdateThumbView;
   CopyScrollPositionFromCore;
 end;
end;

procedure TRMMainForm.DeleteAllClick(Sender: TObject);
var
  ImgWidth,ImgHeight : integer;
begin
 if MessageDlg('Delete All Images, Maps, and Sprite Animations!', 'Are you sure you want to do this?', mtConfirmation,
   [mbYes, mbNo],0) = mrNo    then  Exit;

 ImgWidth:=32;
 ImgHeight:=32;
 RMCoreBase.SetWidth(ImgWidth);
 RMCoreBase.SetHeight(ImgHeight);
 RMCoreBase.ClearBuf(0);
 SetDefaultDrawColors;
 RMDrawTools.SetDrawTool(DrawShapePencil);

 UpdateToolSelectionIcons;
 UpdateColorBoxes;
 UpdateActualArea;

 RMDrawTools.SetClipStatus(0);
 RMDrawTools.SetZoomSize(2);

 ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
 ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;
 RMDrawTools.SetZoomMaxX(RMDrawTools.GetZoomPageWidth);
 RMDrawTools.SetZoomMaxY(RMDrawTools.GetZoomPageHeight);

 ZoomSize:=RMDrawTools.GetZoomSize;
 RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
 UpdateZoomArea;
 ZoomTrackBar.Position:=RMDrawTools.getZoomSize;

 ImageThumbBase.SetCount(1);
 ImageThumbBase.SetCurrent(0);
 ImageList1.Clear;
 ImageList1.Width:=128;
 ImageList1.Height:=128;

 ListView1.Items.Clear;
 ListView1.Items.Add;

 ImageThumbBase.CopyCoreToIndexImage(0);
 ImageThumbBase.MakeThumbImageFromCore(0,imagelist1,1);   //ads an image to image list with option 1 3rd paremeter

 if ShowTransparent then
 begin
   TransImageList1.Clear;
   TransImageList1.Width:=128;
   TransImageList1.Height:=128;
   UpdateTransImageListItem(0);
 end;

 ListView1.Items[0].Caption:='Image '+IntToStr(1);
 ListView1.Items[0].ImageIndex :=0;

 MapEdit.DeleteAll;
 AnimationForm.DeleteAll;
end;

procedure TRMMainForm.MapEditMenuClick(Sender: TObject);
begin
 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
 MapEdit.UpdateTileView;
 MapEdit.Show;
 MapEdit.WindowState:=wsNormal;
end;

procedure TRMMainForm.EditResizeCustomClick(Sender: TObject);
begin
  if SetCustomSpriteSizeForm.ShowModal = mrOK then
  begin
    EditResizeToNewSize(Sender);
  end;
end;

procedure TRMMainForm.SoundGeneratorClick(Sender: TObject);
begin
  SoundGeneratorForm.Show;
  SoundGeneratorForm.WindowState:=wsNormal;
end;

procedure TRMMainForm.SpriteAnimationMenuClick(Sender: TObject);
begin
 AnimationForm.Show;
 AnimationForm.WindowState:=wsNormal;
end;

procedure TRMMainForm.SpriteExportMenuClick(Sender: TObject);
begin
  SpriteSheetExportForm.Show;
  SpriteSheetExportForm.WindowState:=wsNormal;
end;

procedure TRMMainForm.FontSheetExportMenuClick(Sender: TObject);
begin
  FontSheetExportForm.Show;
  FontSheetExportForm.WindowState:=wsNormal;
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
                                      'fpRayLibCustom' :begin
                                                           ExportDialog.Filter := 'FreePascal Array|*.pas';
                                                           Lan:=FPLan;
                                                           format:=4;
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
                                         'gccRayLibCustom':begin
                                                             ExportDialog.Filter := 'gcc Array|*.c';
                                                             Lan:=gccLan;
                                                             format:=4;
                                                           end;

                                         'gccRayLibRGB' : begin
                                                             ExportDialog.Filter := 'gcc Array|*.c';
                                                             Lan:=gccLan;
                                                             format:=3;
                                                           end;
                                       'qb64RGBAFuchsia':begin
                                                              ExportDialog.Filter := 'Basic Array|*.bas';
                                                              Lan:=QB64Lan;
                                                              format:=1;
                                                            end;
                                          'qb64RGBAIndex0':begin
                                                              ExportDialog.Filter := 'Basic Array|*.bas';
                                                              Lan:=QB64Lan;
                                                              format:=2;
                                                            end;


                                          'qb64RGBACustom':begin
                                                              ExportDialog.Filter := 'Basic Array|*.bas';
                                                              Lan:=QB64Lan;
                                                              format:=4;
                                                            end;
                                               'qb64RGB' : begin
                                                            ExportDialog.Filter := 'Basic Array|*.bas';
                                                            Lan:=QB64Lan;
                                                            format:=3;
                                                          end;
                                               'qbjsRGBAFuchsia':begin
                                                                      ExportDialog.Filter := 'Basic Array|*.bas';
                                                                      Lan:=QBJSLan;
                                                                      format:=1;
                                                                    end;
                                                  'qbjsRGBAIndex0':begin
                                                                      ExportDialog.Filter := 'Basic Array|*.bas';
                                                                      Lan:=QBJSLan;
                                                                      format:=2;
                                                                    end;

                                                  'qbjsRGBACustom':begin
                                                                      ExportDialog.Filter := 'Basic Array|*.bas';
                                                                      Lan:=QBJSLan;
                                                                      format:=4;
                                                                    end;
                                                       'qbjsRGB' : begin
                                                                    ExportDialog.Filter := 'Basic Array|*.bas';
                                                                    Lan:=QBJSLan;
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

   if ExportTextFileToClipboard(Sender) then exit;

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
  rmToggle.Checked:=true;
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

procedure TRMMainForm.UpdateImportedImage;
var
  count : integer;
begin
 count:=ImageThumbBase.GetCount;

 if ShowTransparent then
 begin
   //transparent mode needs both lists rebuilt together - the trans list
   //must have all entries before the ListView item is added, otherwise
   //the new item's ImageIndex points past TransImageList1.Count and
   //the ListView caches a blank icon before RebuildTransImageList runs
   ImageThumbBase.UpdateAllThumbImages(imagelist1);
   RebuildTransImageList;
 end
 else
   ImageThumbBase.MakeThumbImage(count-1, ImageList1, 1);

 ListView1.Items.Add;
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
 filename : string;
begin
 //update the current thumb image
 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
 ExportDialog.Filter := 'RES Pascal Include|*.inc|RES Pascal Include|*.pas|RES C Include|*.h|RES C Include|*.c|RES BASIC Include|*.bi|RES BASIC Include|*.bas|All Files|*.*';

 if rmconfigbase.GetExportTextFileToClipStatus = true then
 begin
    index:=ListView1.ItemIndex;
    if index = -1 then index:=0;
    filename:=GetTemporaryPathAndFileName;
    error:=RESInclude(filename,index,TRUE);
    if error<>0 then
    begin
      ShowMessage('Error Exporting!');
    end;
    ReadFileAndCopyToClipboard(filename);
    EraseFile(filename);
    ShowMessage('Exported to Clipboard!');
    exit;
 end;

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
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.RefreshAfterProjectOpen(insertmode : boolean);
var
  amount : integer;
  i : integer;
begin
   ImageThumbBase.UpdateAllThumbImages(imagelist1);

   if ShowTransparent then
     RebuildTransImageList;

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

      RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
      RMDrawTools.SetZoomSize(1);

      ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
      ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;
      RMDrawTools.SetZoomMaxX(RMDrawTools.GetZoomPageWidth);
      RMDrawTools.SetZoomMaxY(RMDrawTools.GetZoomPageHeight);

      ZoomSize:=RMDrawTools.GetZoomSize;
      CopyScrollPositionFromCore;

      CoreToPalette;
      UpdateColorBoxes;
      UpdateToolSelectionIcons;
      UpdatePalette;
      UpdatePaletteMenu;
      UpdateEditMenu;
      UpdateActualArea;
      UpdateZoomArea;
      UpdateZoomScroller;
      UpdateThumbView;
    end;
end;

procedure TRMMainForm.OpenProjectFileClick(Sender: TObject);
var
  InsertMode : boolean;
begin
   InsertMode:=FALSE;
   if (Sender As TMenuItem).Name = 'InsertProjectFile' then insertMode:=TRUE;
   OpenDialog1.Filter := 'Raster Master Project|*.rmp';
   if NOT OpenDialog1.Execute then exit;

   CopyScrollPositionToCore;
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
   ImageThumbBase.OpenProject(OpenDialog1.Filename,InsertMode);
   RefreshAfterProjectOpen(InsertMode);
end;

procedure TRMMainForm.OpenProjectJSONClick(Sender: TObject);
var
  InsertMode : boolean;
begin
   InsertMode:=FALSE;
   if (Sender As TMenuItem).Name = 'InsertProjectJSONFile' then insertMode:=TRUE;
   OpenDialog1.Filter := 'Raster Master JSON Project|*.rmj;*.json|All Files|*.*';
   if NOT OpenDialog1.Execute then exit;

   CopyScrollPositionToCore;
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);

   if NOT OpenProjectJSON(OpenDialog1.Filename,InsertMode) then
   begin
     ShowMessage('Unable to open JSON project.' + LineEnding +
                 'The file is not a valid Raster Master JSON project or may be corrupt.');
     exit;
   end;

   RefreshAfterProjectOpen(InsertMode);
end;

procedure TRMMainForm.SaveProjectJSONClick(Sender: TObject);
begin
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
   SaveDialog1.Filter := 'Raster Master JSON Project|*.rmj';
   SaveDialog1.DefaultExt := 'rmj';
   if SaveDialog1.Execute then
   begin
      if NOT SaveProjectJSON(SaveDialog1.Filename) then
        ShowMessage('Error saving JSON project!');
   end;
end;

//exports the current sprite to a JSON file using the image type from its
//export properties (indexed / RGB / RGBA); RGBA alpha follows the PNG
//Transparent RGBA settings from File->Properties
//honors the Export Files To Clipboard flag from File->Properties
procedure TRMMainForm.ExportJSONSpriteClick(Sender: TObject);
var
  filename : string;
  PngRGBA : PngRGBASettingsRec;
  EO : ImageExportFormatRec;
  imgtype : integer;
begin
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);

   FilePropertiesDialog.GetProps(PngRGBA);
   ImageThumbBase.GetExportOptions(ImageThumbBase.GetCurrent, EO);
   imgtype:=EO.Image;
   if (EO.Lan <> JSONSpriteLan) or (imgtype = 0) then imgtype:=JSONImageIndexed;

   if rmconfigbase.GetExportTextFileToClipStatus then
   begin
     filename:=GetTemporaryPathWithProvidedFileName(ImageThumbBase.GetExportName(ImageThumbBase.GetCurrent));
     if ExportSpriteJSON(ImageThumbBase.GetCurrent, filename, imgtype, PngRGBA) then
     begin
       ReadFileAndCopyToClipboard(filename);
       EraseFile(filename);
       ShowMessage('Exported to Clipboard!');
     end
     else
       ShowMessage('Error exporting sprite to JSON!');
     exit;
   end;

   SaveDialog1.Filter := 'JSON|*.json';
   SaveDialog1.DefaultExt := 'json';
   if SaveDialog1.Execute then
   begin
     if NOT ExportSpriteJSON(ImageThumbBase.GetCurrent, SaveDialog1.Filename, imgtype, PngRGBA) then
       ShowMessage('Error exporting sprite to JSON!');
   end;
end;

//exports every sprite/map/animation whose export compiler is set to JSON
//into one combined JSON resource file
//honors the Export Files To Clipboard flag from File->Properties
procedure TRMMainForm.ExportJSONRESClick(Sender: TObject);
var
  filename : string;
  PngRGBA : PngRGBASettingsRec;
begin
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
   FilePropertiesDialog.GetProps(PngRGBA);

   if rmconfigbase.GetExportTextFileToClipStatus then
   begin
     filename:=GetTemporaryPathAndFileName;
     if ExportResJSON(filename, PngRGBA) then
     begin
       ReadFileAndCopyToClipboard(filename);
       EraseFile(filename);
       ShowMessage('Exported to Clipboard!');
     end
     else
       ShowMessage('Error exporting JSON RES file!');
     exit;
   end;

   SaveDialog1.Filter := 'JSON|*.json';
   SaveDialog1.DefaultExt := 'json';
   if SaveDialog1.Execute then
   begin
     if NOT ExportResJSON(SaveDialog1.Filename, PngRGBA) then
       ShowMessage('Error exporting JSON RES file!');
   end;
end;

//exports the current sprite's palette to JSON (Palette->Export->JSON)
//honors the Export Files To Clipboard flag from File->Properties
procedure TRMMainForm.PaletteSaveJSONClick(Sender: TObject);
var
  filename : string;
begin
   ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);

   if rmconfigbase.GetExportTextFileToClipStatus then
   begin
     filename:=GetTemporaryPathWithProvidedFileName(ImageThumbBase.GetExportName(ImageThumbBase.GetCurrent)+'Pal');
     if ExportPaletteJSONFile(ImageThumbBase.GetCurrent, filename) then
     begin
       ReadFileAndCopyToClipboard(filename);
       EraseFile(filename);
       ShowMessage('Exported to Clipboard!');
     end
     else
       ShowMessage('Error exporting palette to JSON!');
     exit;
   end;

   SaveDialog1.Filter := 'JSON|*.json';
   SaveDialog1.DefaultExt := 'json';
   if SaveDialog1.Execute then
   begin
     if NOT ExportPaletteJSONFile(ImageThumbBase.GetCurrent, SaveDialog1.Filename) then
       ShowMessage('Error exporting palette to JSON!');
   end;
end;

procedure TRMMainForm.PaletteCopyClick(Sender: TObject);
begin
  RMCoreBase.Palette.CopyPaletteToCB;
end;

procedure TRMMainForm.PaletteCopyJASCClick(Sender: TObject);
var
  i, NColors : integer;
  CR : TRMColorRec;
  S : string;
begin
  SetCoreActive;
  NColors:=GetMaxColor+1;
  S:='JASC-PAL' + LineEnding + '0100' + LineEnding + IntToStr(NColors) + LineEnding;
  for i:=0 to NColors-1 do
  begin
    GetColor(i, CR);
    S:=S + IntToStr(CR.r) + ' ' + IntToStr(CR.g) + ' ' + IntToStr(CR.b) + LineEnding;
  end;
  Clipboard.AsText:=S;
end;

  procedure TRMMainForm.PalettePasteJASCClick(Sender: TObject);
var
  S  : string;
  Lines : TStringList;
  pm, NColors, i : integer;
  r, g, b : integer;
  p1, p2 : integer;
  CR : TRMColorRec;
  ColorLine : string;
begin
  if not Clipboard.HasFormat(CF_TEXT) then
  begin
    ShowMessage('No text data on clipboard.');
    exit;
  end;

  S:=Clipboard.AsText;
  Lines:=TStringList.Create;
  try
    Lines.Text:=S;
    if Lines.Count < 4 then
    begin
      ShowMessage('Clipboard does not contain valid JASC palette data.');
      exit;
    end;

    // verify header
    if Trim(Lines[0]) <> 'JASC-PAL' then
    begin
      ShowMessage('Clipboard does not contain JASC-PAL header.');
      exit;
    end;

    // read color count (line 2)
    NColors:=StrToIntDef(Trim(Lines[2]), 0);
    if NColors <= 0 then
    begin
      ShowMessage('Invalid color count in JASC palette.');
      exit;
    end;
    if NColors > 256 then NColors:=256;

    SetCoreActive;
    pm:=RMCoreBase.Palette.GetPaletteMode;

    for i:=0 to NColors-1 do
    begin
      if (i + 3) >= Lines.Count then break;
      ColorLine:=Trim(Lines[i + 3]);

      // parse R G B
      p1:=Pos(' ', ColorLine);
      if p1 = 0 then continue;
      r:=StrToIntDef(Copy(ColorLine, 1, p1-1), 0);
      Delete(ColorLine, 1, p1);
      ColorLine:=TrimLeft(ColorLine);

      p2:=Pos(' ', ColorLine);
      if p2 = 0 then continue;
      g:=StrToIntDef(Copy(ColorLine, 1, p2-1), 0);
      Delete(ColorLine, 1, p2);
      ColorLine:=TrimLeft(ColorLine);

      b:=StrToIntDef(ColorLine, 0);

      CR.r:=r;
      CR.g:=g;
      CR.b:=b;

      if CanLoadPaletteFile(pm) then
      begin
        if pm = PaletteModeEGA then
        begin
          if RGBToEGAIndex(CR.r, CR.g, CR.b) > -1 then
            RMCoreBase.Palette.SetColor(i, CR);
        end
        else if isAmigaPaletteMode(pm) then
        begin
          CR.r:=FourToEightBit(EightToFourBit(CR.r));
          CR.g:=FourToEightBit(EightToFourBit(CR.g));
          CR.b:=FourToEightBit(EightToFourBit(CR.b));
          RMCoreBase.Palette.SetColor(i, CR);
        end
        else if (pm = PaletteModeVGA) or (pm = PaletteModeVGA256) then
        begin
          CR.r:=SixToEightBit(EightToSixBit(CR.r));
          CR.g:=SixToEightBit(EightToSixBit(CR.g));
          CR.b:=SixToEightBit(EightToSixBit(CR.b));
          RMCoreBase.Palette.SetColor(i, CR);
        end
        else
        begin
          RMCoreBase.Palette.SetColor(i, CR);
        end;
      end;
    end;
  finally
    Lines.Free;
  end;

  CoreToPalette;
  UpdatePalette;
  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.InitThumbView;
var
  LItem: TListItem;
begin
  ImageThumbBase.AddImage;
  ImageThumbBase.SetCurrent(0);

  ImageThumbBase.MakeThumbImageFromCore(ImageThumbBase.GetCount-1,imagelist1,1);
  if ShowTransparent then
    UpdateTransImageListItem(ImageThumbBase.GetCount-1);
  LItem:=ListView1.Items.Add;

  LItem.ImageIndex :=ImageThumbBase.GetCount-1;
  LItem.Caption:='Image '+IntToStr(ImageThumbBase.GetCount);
end;

procedure TRMMainForm.UpdateThumbView;
begin
  ImageThumbBase.MakeThumbImageFromCore(ImageThumbBase.GetCurrent,imagelist1,4);
  if ShowTransparent then
  begin
    ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
    UpdateTransImageListItem(ImageThumbBase.GetCurrent);
  end;
  Listview1.Refresh;
end;

procedure TRMMainForm.RebuildTransImageList;
var
  i, x, y, aw, ah : integer;
  CheckBmp, SpriteBmp, TransBmp : TBitmap;
begin
  //NOTE: do NOT sync CopyCoreToIndexImage here - during NewClick the core
  //buffer holds the blank new canvas while GetCurrent still points at the
  //old image, so syncing here would erase the old image's stored pixels.
  //Callers must sync at safe points (see TransparentToggleClick).

  TransImageList1.Clear;
  TransImageList1.Width:=128;
  TransImageList1.Height:=128;

  for i:=0 to ImageThumbBase.GetCount-1 do
  begin
    aw:=ImageThumbBase.GetWidth(i);
    ah:=ImageThumbBase.GetHeight(i);

    SpriteBmp:=TBitmap.Create;
    SpriteBmp.SetSize(aw, ah);
    for y:=0 to ah-1 do
      for x:=0 to aw-1 do
        SpriteBmp.Canvas.Pixels[x, y]:=ImageThumbBase.GetPixelTColor(i, x, y);

    CheckBmp:=TBitmap.Create;
    CheckBmp.SetSize(128, 128);
    CheckBmp.Canvas.Draw(0, 0, FCheckerBmp);

    TransBmp:=TBitmap.Create;
    TransBmp.Width:=128;
    TransBmp.Height:=128;
    TransBmp.TransparentColor:=clBlack;
    TransBmp.TransparentMode:=tmFixed;
    TransBmp.Transparent:=True;
    TransBmp.Canvas.CopyRect(Rect(0, 0, 128, 128), SpriteBmp.Canvas, Rect(0, 0, aw, ah));

    CheckBmp.Canvas.Draw(0, 0, TransBmp);
    TransImageList1.Add(CheckBmp, nil);

    SpriteBmp.Free;
    TransBmp.Free;
    CheckBmp.Free;
  end;

  //rebind and force the listview to re-read every icon from the new list
  ListView1.LargeImages:=TransImageList1;
  ListView1.LargeImagesWidth:=128;
  for i:=0 to ListView1.Items.Count-1 do
    ListView1.Items[i].ImageIndex:=ListView1.Items[i].ImageIndex;
  ListView1.Invalidate;
end;

procedure TRMMainForm.UpdateTransImageListItem(index : integer);
var
  x, y, aw, ah : integer;
  CheckBmp, SpriteBmp, TransBmp : TBitmap;
begin
  if (index < 0) or (index >= ImageThumbBase.GetCount) then exit;
  if index >= TransImageList1.Count then
  begin
    RebuildTransImageList;
    exit;
  end;

  aw:=ImageThumbBase.GetWidth(index);
  ah:=ImageThumbBase.GetHeight(index);

  SpriteBmp:=TBitmap.Create;
  SpriteBmp.SetSize(aw, ah);
  for y:=0 to ah-1 do
    for x:=0 to aw-1 do
      SpriteBmp.Canvas.Pixels[x, y]:=ImageThumbBase.GetPixelTColor(index, x, y);

  CheckBmp:=TBitmap.Create;
  CheckBmp.SetSize(128, 128);
  CheckBmp.Canvas.Draw(0, 0, FCheckerBmp);

  TransBmp:=TBitmap.Create;
  TransBmp.Width:=128;
  TransBmp.Height:=128;
  TransBmp.TransparentColor:=clBlack;
  TransBmp.TransparentMode:=tmFixed;
  TransBmp.Transparent:=True;
  TransBmp.Canvas.CopyRect(Rect(0, 0, 128, 128), SpriteBmp.Canvas, Rect(0, 0, aw, ah));

  CheckBmp.Canvas.Draw(0, 0, TransBmp);
  TransImageList1.Replace(index, CheckBmp, nil, false);

  SpriteBmp.Free;
  TransBmp.Free;
  CheckBmp.Free;
end;


procedure TRMMainForm.DeleteImageByIndex(index : integer);
var i: integer;
begin
if index > -1 then
begin
      listview1.Items.Delete(index);
      imagelist1.Delete(index);
      if ShowTransparent and (index < TransImageList1.Count) then
        TransImageList1.Delete(index);

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
     // ActualBox.Width:=RMCoreBase.GetWidth;
     // ActualBox.Height:=RMCoreBase.GetHeight;

      ZoomPaintBox.Width:=1;
      ZoomPaintBox.Height:=1;
      ZoomPaintBox.Width:=RMDrawTools.GetZoomPageWidth;
      ZoomPaintBox.Height:=RMDrawTools.GetZoomPageHeight;
      //  ZoomPaintBox.Canvas.Clear;
      //  RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
      RMDrawTools.SetZoomMaxX(ZoomPaintBox.Width);
      RMDrawTools.SetZoomMaxY(ZoomPaintBox.Height);
      ZoomSize:=RMDrawTools.GetZoomSize;
      CoreToPalette;
      UpdateColorBoxes;
      UpdatePalette;
      UpdateActualArea;
      UpdateZoomArea;
      UpdateEditMenu;
   end;
end;

procedure TRMMainForm.FileDeleteClick(Sender: TObject);
var
  item  : TListItem;
  index : integer;
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

   DeleteImageByIndex(index);
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
 SetDefaultDrawColors;
 RMCoreBase.SetCurColorBox(cbColorBox1);

 RMDrawTools.SetDrawTool(DrawShapePencil);
 RMDrawTools.SetClipStatus(0);
 UpdateToolSelectionIcons;

 UpdateColorBoxes;
 UpdateActualArea;
 UpdateZoomArea;

 ZoomTrackBar.Position:=RMDrawTools.getZoomSize;
 ZoomScrollBox.HorzScrollBar.Position:=0;
 ZoomScrollBox.VertScrollBar.Position:=0;

 ImageThumbBase.AddImage;
 ImageThumbBase.MakeThumbImage(ImageThumbBase.GetCount-1,imagelist1,1);

 if ShowTransparent then
   UpdateTransImageListItem(ImageThumbBase.GetCount-1);

 ListView1.AddItem('Image '+IntToStr(ImageThumbBase.GetCount),nil);
 ListView1.Items[ImageThumbBase.GetCount-1].ImageIndex:=ImageThumbBase.GetCount-1;

 //with ListView1.Items.Add do
 //begin
 //  ImageIndex :=ImageThumbBase.GetCount-1;
 //  Caption:='Image '+IntToStr(ImageThumbBase.GetCount);
 //end;

 ImageThumbBase.SetCurrent(ImageThumbBase.GetCount-1);
 Listview1.Refresh;
end;

procedure TRMMainForm.Clear;
begin
 //  ClearClipAreaOutline;
 RMCoreBase.ClearBuf(0);
 SetDefaultDrawColors;
 RMDrawTools.SetDrawTool(DrawShapePencil);
 UpdateToolSelectionIcons;

 UpdateColorBoxes;
 UpdateActualArea;
 RMDrawTools.SetClipStatus(0);
 RMDrawTools.DrawGrid(ZoomPaintBox.Canvas,0,0,ZoomPaintBox.Width,ZoomPaintBox.Height,0);
 UpdateZoomArea;
// UnFreezeScrollAndZoom;
 ZoomTrackBar.Position:=RMDrawTools.getZoomSize;
 ZoomScrollBox.HorzScrollBar.Position:=0;
 ZoomScrollBox.VertScrollBar.Position:=0;
 UpdateThumbView;
end;

procedure TRMMainForm.EditClearClick(Sender: TObject);
begin
 Clear;
end;

procedure TRMMainForm.EditCloneClick(Sender: TObject);
begin
 if ImageThumbBase.GetCount >= MaxThumbImages then exit;

 CopyScrollPositionToCore;
 ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent); //copy again before we switch to new image

 ZoomScrollBox.HorzScrollBar.Position:=0;
 ZoomScrollBox.VertScrollBar.Position:=0;

 ImageThumbBase.AddImage;
 ImageThumbBase.MakeThumbImage(ImageThumbBase.GetCount-1,imagelist1,1);

 if ShowTransparent then
   UpdateTransImageListItem(ImageThumbBase.GetCount-1);

 with ListView1.Items.Add do
 begin
   ImageIndex :=ImageThumbBase.GetCount-1;
   Caption:='Image '+IntToStr(ImageThumbBase.GetCount);
 end;

 ImageThumbBase.SetCurrent(ImageThumbBase.GetCount-1);
 Listview1.Refresh;
 ShowMessage('Image Cloned!');

end;

procedure TRMMainForm.TransparentToggleClick(Sender: TObject);
var
  i : integer;
begin
  ShowTransparent:=not ShowTransparent;
  TransparentToggle.Checked:=ShowTransparent;
  if ShowTransparent then
  begin
    //safe to sync here - the core buffer holds the current image
    if ImageThumbBase.GetCurrent >= 0 then
      ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
    RebuildTransImageList;
  end
  else
  begin
    ListView1.LargeImages:=ImageList1;
    ListView1.LargeImagesWidth:=128;
    for i:=0 to ListView1.Items.Count-1 do
      ListView1.Items[i].ImageIndex:=ListView1.Items[i].ImageIndex;
    ListView1.Invalidate;
  end;
  ListView1.Refresh;
  UpdateActualArea;
  UpdateZoomArea;
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

  Sender.AddFunction(@rm_getcliparea,'procedure getcliparea(var active,x1,y1,x2,y2 : integer)');

  Sender.AddFunction(@rm_getmaxcolor,'function  getmaxcolor : integer');
  Sender.AddFunction(@rm_getcolorrgb,'procedure getcolorrgb(index : integer;var r,g,b : byte)');
  Sender.AddFunction(@rm_setcolorrgb,'procedure setcolorrgb(index : integer; r,g,b : byte)');

  Sender.AddFunction(@rm_getpalettemode,'function getpalettemode : integer');
  Sender.AddFunction(@rm_setpalettemode, 'procedure setpalettemode(mode : integer)');

//  Sender.AddFunction(@rm_settileproperty,'procedure settileproperty(x,y : integer;tilepropertyname,value : string)');
//  Sender.AddFunction(@rm_puttile, 'procedure puttile(x,y,index : integer)');
//  Sender.AddFunction(@rm_gettile, 'function gettile(x,y : integer) : integer');


//FileCreate/FileWrite/FileClose lifted from Lazarus Pascal Script Example Page - don't seem to work - you let me know
  Sender.AddFunction(@FileCreate, 'Function FileCreate(const FileName: string): integer)');
  Sender.AddFunction(@FileWrite, 'function FileWrite(Handle: Integer; const Buffer: pChar; Count: LongWord): Integer)');
  Sender.AddFunction(@FileClose, 'Procedure FileClose(handle: integer)');

end;

procedure TRMMainForm.ScriptMenuLoadClick(Sender: TObject);
var
 ext : string;
begin
 OpenDialog1.Filter := 'QBasic Script|*.bas|Pascal Script|*.pas|All Files|*.*';
 if OpenDialog1.Execute then
 begin
   ScriptFileName:=OpenDialog1.FileName;
   ext:=UpperCase(ExtractFileExt(ScriptFileName));
   if ext = '.PAS' then
   begin
     ScriptLoaded:=PascalScript;
   end
   else if ext = '.BAS' then
   begin
     ScriptLoaded:=QBScript;
   end;
 end;
end;

procedure TRMMainForm.PascalScriptRun;
var
  ErrorMsg : string;
  i : integer;
begin
  if ScriptLoaded = NoScript then exit;
  RMScript.Script.LoadFromFile(ScriptFileName);

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

procedure TRMMainForm.QBScriptRun;
var
  Code: TStringList;
  ErrorMsg : string;
  CA,CX,CY,CX2,CY2 : integer;
begin
 if ScriptLoaded = NoScript then exit;
 Code := TStringList.Create;
 Code.LoadFromFile(ScriptFileName);

 SetCoreActive;
 ErrorMsg:='';
 try
  QBInterpreter.Reset;
  QBInterpreter.LoadProgram(code.text);
  rm_getcliparea(CA,CX,CY,CX2,CY2);
  QBInterpreter.SetGlobalVariable('CLIP_ACTIVE',CA);
  QBInterpreter.SetGlobalVariable('CLIP_X1',CX);
  QBInterpreter.SetGlobalVariable('CLIP_Y1',CY);
  QBInterpreter.SetGlobalVariable('CLIP_X2',CX2);
  QBInterpreter.SetGlobalVariable('CLIP_Y2',CY2);
  QBInterpreter.Execute;
 except
    on E: EQBasicError do
    begin
      ErrorMsg := 'ERROR at line ' + IntToStr(E.Line)+sLineBreak + E.Message;
      ShowMessage(ErrorMsg);
    end;
    on E: Exception do
    begin
      ErrorMsg:= 'Error: ' + E.Message;
      ShowMessage(ErrorMsg);
    end;
 end;

 Code.Free;
 UpdateActualArea;
 UpdateZoomArea;
 UpdateThumbview;
end;

procedure TRMMainForm.ScriptMenuRunClick(Sender: TObject);
begin
 if ScriptLoaded = QBScript then
 begin
   QBScriptRun;
 end
 else if ScriptLoaded = PascalScript then
 begin
   PascalScriptRun;
 end;
end;


procedure TRMMainForm.QBPrint(const AText: string);
begin
 // will print to a console window in the future
end;

function TRMMainForm.QBinput(const Prompt: string; var Value: string) : boolean;
begin
 result:=true;
 // will display and input dialog to enter value
end;

// the API functions will be moved somewhere else in the future
procedure TRMMainForm.API_PutPixel(const Args: array of Double; const StrArgs: array of string);
begin
 rm_putpixel(Trunc(Args[0]),Trunc(Args[1]),Trunc(Args[2]));
end;

function TRMMainForm.API_GetPixel(const Args: array of Double): Double;
begin
 result:=rm_getpixel(Trunc(Args[0]),Trunc(Args[1]));
end;

function TRMMainForm.API_GetWidth(const Args: array of Double): Double;
begin
 result:=rm_getwidth;
end;

function TRMMainForm.API_GetHeight(const Args: array of Double): Double;
begin
 result:=rm_getheight;
end;

function TRMMainForm.API_GetMaxColor(const Args: array of Double): Double;
begin
 result:=rm_getmaxcolor;
end;

function TRMMainForm.API_GetColorR(const Args: array of Double) : double;
var
  r,g,b : byte;
begin
  rm_getcolorrgb(Trunc(Args[0]),r,g,b);
  result:=r;
end;

function TRMMainForm.API_GetColorG(const Args: array of Double) : double;
var
  r,g,b : byte;
begin
  rm_getcolorrgb(Trunc(Args[0]),r,g,b);
  result:=g;
end;

function TRMMainForm.API_GetColorB(const Args: array of Double) : double;
var
  r,g,b : byte;
begin
  rm_getcolorrgb(Trunc(Args[0]),r,g,b);
  result:=b;
end;

procedure TRMMainForm.InitQBInterpreter;
begin
 QBInterpreter := TQBasicInterpreter.Create;
 QBInterpreter.Reset;
 QBInterpreter.OnPrint := @QBPrint;
 QBInterpreter.OnInput := @QBInput;
 QBInterpreter.RegisterProcedure('PUTPIXEL', 4, 4,@API_PUTPIXEL);
 QBInterpreter.RegisterFunction('GETPIXEL', 3, 3,@API_GETPIXEL);
 QBInterpreter.RegisterFunction('GETWIDTH', 0, 0,@API_GETWIDTH);
 QBInterpreter.RegisterFunction('GETHEIGHT', 0, 0,@API_GETHEIGHT);
 QBInterpreter.RegisterFunction('GETMAXCOLOR', 0, 0,@API_GETMAXCOLOR);
 QBInterpreter.RegisterFunction('GETCOLORR', 3, 3,@API_GETCOLORR);
 QBInterpreter.RegisterFunction('GETCOLORG', 3, 3,@API_GETCOLORG);
 QBInterpreter.RegisterFunction('GETCOLORB', 3, 3,@API_GETCOLORB);
end;

{ ===== Brush Tool ===== }

procedure TRMMainForm.DrawBrushOverlay(ACanvas : TCanvas);
var
  bx, by, px, py : integer;
  ci : byte;
  CW, CH : integer;
  pal : TRMPaletteBuf;
  offX, offY : integer;
begin
  if not RetroBrush.HasBrush then exit;

  CW:=RMDrawTools.GetCellWidth;
  CH:=RMDrawTools.GetCellHeight;

  //center the brush on the cursor
  offX:=ZoomX - RetroBrush.WorkWidth div 2;
  offY:=ZoomY - RetroBrush.WorkHeight div 2;

  RMCoreBase.Palette.GetPalette(pal);
  RetroBrush.InvalidateRemap;
  RetroBrush.BuildRemapTable(pal,
    RMCoreBase.Palette.GetPaletteMode,
    RMCoreBase.Palette.GetColorCount);

  for bx:=0 to RetroBrush.WorkWidth-1 do
  begin
    for by:=0 to RetroBrush.WorkHeight-1 do
    begin
      ci:=RetroBrush.WorkPixels[bx][by];
      if ci = RetroBrush.TransColor then continue;
      px:=(offX + bx) * CW;
      py:=(offY + by) * CH;
      //clip to sprite pixel bounds, not canvas size
      if (offX + bx >= 0) and (offX + bx < RMCoreBase.GetWidth) and
         (offY + by >= 0) and (offY + by < RMCoreBase.GetHeight) then
      begin
        ACanvas.Brush.Color:=
          RGBToColor(pal[RetroBrush.RemapIndex(ci)].r,
                     pal[RetroBrush.RemapIndex(ci)].g,
                     pal[RetroBrush.RemapIndex(ci)].b);
        ACanvas.FillRect(px, py, px + CW, py + CH);
      end;
    end;
  end;
end;

procedure TRMMainForm.BrushGrabClipboardClick(Sender: TObject);
var
  ClipBmp : TBitmap;
  w, h, i, j, k : integer;
  SrcBuf : TPixelBuf;
  SrcPal : TRMPaletteBuf;
  ci : integer;
  cr, cg, cb : byte;
  BestIdx, BestDist, Dist, DR, DG, DB : integer;
  ColorCount, PaletteMode : integer;
begin
  if not Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
  begin
    ShowMessage('No image found on the clipboard.');
    exit;
  end;

  ClipBmp:=TBitmap.Create;
  try
    ClipBmp.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));
    w:=ClipBmp.Width;
    h:=ClipBmp.Height;
    if (w <= 0) or (h <= 0) then
    begin
      ShowMessage('Clipboard image is empty.');
      exit;
    end;

    //get the current sprite palette for color matching
    RMCoreBase.Palette.GetPalette(SrcPal);
    PaletteMode:=RMCoreBase.Palette.GetPaletteMode;
    ColorCount:=RMCoreBase.Palette.GetColorCount;

    //convert clipboard image to indexed pixels using nearest color match
    SetLength(SrcBuf, w, h);
    for i:=0 to w-1 do
    begin
      for j:=0 to h-1 do
      begin
        cr:=Red(ClipBmp.Canvas.Pixels[i, j]);
        cg:=Green(ClipBmp.Canvas.Pixels[i, j]);
        cb:=Blue(ClipBmp.Canvas.Pixels[i, j]);

        BestIdx:=0;
        BestDist:=MaxInt;
        for k:=0 to ColorCount-1 do
        begin
          DR:=cr - SrcPal[k].r;
          DG:=cg - SrcPal[k].g;
          DB:=cb - SrcPal[k].b;
          Dist:=DR*DR*2 + DG*DG*4 + DB*DB*3;
          if Dist < BestDist then
          begin
            BestDist:=Dist;
            BestIdx:=k;
            if Dist = 0 then break;
          end;
        end;
        SrcBuf[i][j]:=BestIdx;
      end;
    end;

    RetroBrush.GrabFromPixels(SrcBuf, w, h, SrcPal, PaletteMode, ColorCount);
    SetLength(SrcBuf, 0);
    ShowMessage('Brush grabbed from clipboard (' + IntToStr(w) + 'x' + IntToStr(h) + ').');
  finally
    ClipBmp.Free;
  end;
end;

procedure TRMMainForm.DrawMethodClick(Sender: TObject);
begin
  DrawMethodPreview.Invalidate;
  case DrawMethod.ItemIndex of
    0: begin  //Color - disable all
         RMDrawTools.SetDitherEnabled(false);
         RMDrawTools.SetGradientEnabled(false);
         RMDrawTools.SetBrushFillEnabled(false);
       end;
    1: begin  //Brush - use active brush as fill pattern
         if not RetroBrush.HasBrush then
         begin
           DrawMethod.ItemIndex:=0;  //fall back to Color
           RMDrawTools.SetBrushFillEnabled(false);
           exit;
         end;
         RMDrawTools.SetDitherEnabled(false);
         RMDrawTools.SetGradientEnabled(false);
         RMDrawTools.SetBrushFillEnabled(true);
       end;
    2: begin  //Dither - enable dither with current pattern
         RMDrawTools.SetDitherEnabled(true);
         RMDrawTools.SetGradientEnabled(false);
         RMDrawTools.SetBrushFillEnabled(false);
         UpdateDitherGradientColors;
         if not RMDrawTools.GetDitherUseBitmap then
           RMDrawTools.SetDitherPattern(0);
       end;
    3: begin  //Gradient - enable gradient with combo selection
         RMDrawTools.SetDitherEnabled(false);
         RMDrawTools.SetGradientEnabled(true);
         RMDrawTools.SetBrushFillEnabled(false);
         RMDrawTools.SetGradientMode(GradientMethod.ItemIndex);
         UpdateDitherGradientColors;
       end;
  end;
  DitherPatternPaintBox.Invalidate;
  UpdateStatusInfo;
end;

procedure TRMMainForm.GradientMethodChange(Sender: TObject);
begin
  DrawMethodPreview.Invalidate;
  //switch to gradient mode and update direction
  DrawMethod.ItemIndex:=3;
  RMDrawTools.SetBrushFillEnabled(false);
  RMDrawTools.SetDitherEnabled(false);
  RMDrawTools.SetGradientEnabled(true);
  RMDrawTools.SetGradientMode(GradientMethod.ItemIndex);
  UpdateDitherGradientColors;
  FSelectedDitherPattern:=0;
  DitherPatternPaintBox.Invalidate;
end;

procedure TRMMainForm.DrawMethodPreviewPaint(Sender: TObject);
var
  i, j : integer;
  ci : integer;
  pal : TRMPaletteBuf;
  c1Idx, c2Idx : integer;
  pw, ph : integer;
  dist, maxDist : double;
  dx, dy : integer;
begin
  if RMCoreBase = nil then exit;
  if DrawMethod = nil then exit;

  pw:=DrawMethodPreview.Width;
  ph:=DrawMethodPreview.Height;

  RMCoreBase.Palette.GetPalette(pal);
  c1Idx:=RMCoreBase.GetCurColor1;
  c2Idx:=RMCoreBase.GetCurColor2;

  for i:=0 to pw-1 do
  begin
    for j:=0 to ph-1 do
    begin
      ci:=c1Idx;

      case DrawMethod.ItemIndex of
        0: begin //Color - solid Color 1
             ci:=c1Idx;
           end;
        1: begin //Brush - tile brush pattern
             if RetroBrush.HasBrush and (RetroBrush.WorkWidth > 0) and (RetroBrush.WorkHeight > 0) then
             begin
               ci:=RetroBrush.WorkPixels[i mod RetroBrush.WorkWidth][j mod RetroBrush.WorkHeight];
               //clamp to valid palette range
               if ci >= RMCoreBase.Palette.GetColorCount then
                 ci:=ci mod RMCoreBase.Palette.GetColorCount;
               if ci = RetroBrush.TransColor then
                 ci:=c1Idx;  //transparent pixels show Color 1
             end;
           end;
        2: begin //Dither - use pattern
             if RMDrawTools.DitherIsColor2(i, j) then
               ci:=c2Idx;
           end;
        3: begin //Gradient
             case GradientMethod.ItemIndex of
               0: begin //horizontal
                    if pw > 1 then
                      ci:=c1Idx + ((c2Idx - c1Idx) * i) div (pw - 1);
                  end;
               1: begin //vertical
                    if ph > 1 then
                      ci:=c1Idx + ((c2Idx - c1Idx) * j) div (ph - 1);
                  end;
               2: begin //circular
                    dx:=i - pw div 2;
                    dy:=j - ph div 2;
                    dist:=Sqrt(dx*dx + dy*dy);
                    maxDist:=Sqrt(Sqr(pw / 2.0) + Sqr(ph / 2.0));
                    if maxDist < 1 then maxDist:=1;
                    if dist > maxDist then dist:=maxDist;
                    ci:=c1Idx + Round((c2Idx - c1Idx) * (dist / maxDist));
                  end;
             end;
             if ci < 0 then ci:=0;
             if ci > 255 then ci:=255;
           end;
      end;

      DrawMethodPreview.Canvas.Pixels[i, j]:=
        RGBToColor(pal[ci].r, pal[ci].g, pal[ci].b);
    end;
  end;
end;

procedure TRMMainForm.DitherPatternPaintBoxPaint(Sender: TObject);
var
  p, i, j, col, row : integer;
  cx, cy, sx, sy : integer;
begin
  DitherPatternPaintBox.Canvas.Brush.Color:=clBtnFace;
  DitherPatternPaintBox.Canvas.FillRect(0, 0, DitherPatternPaintBox.Width, DitherPatternPaintBox.Height);

  for p:=0 to DitherPatternCount-1 do
  begin
    col:=p mod DitherCols;
    row:=p div DitherCols;
    cx:=col * (DitherPreviewSize + 2) + 2;
    cy:=row * (DitherPreviewSize + 2) + 2;

    //draw 8x8 pattern scaled up to 32x32
    for i:=0 to 7 do
    begin
      for j:=0 to 7 do
      begin
        sx:=cx + i * DitherPreviewScale;
        sy:=cy + j * DitherPreviewScale;
        if DitherPatterns[p, j * 8 + i] = 1 then
          DitherPatternPaintBox.Canvas.Brush.Color:=clBlack
        else
          DitherPatternPaintBox.Canvas.Brush.Color:=clWhite;
        DitherPatternPaintBox.Canvas.FillRect(sx, sy, sx + DitherPreviewScale, sy + DitherPreviewScale);
      end;
    end;

    //draw border - red for selected, gray for others
    if (p = FSelectedDitherPattern) then
    begin
      DitherPatternPaintBox.Canvas.Pen.Color:=clRed;
      DitherPatternPaintBox.Canvas.Pen.Width:=2;
    end
    else
    begin
      DitherPatternPaintBox.Canvas.Pen.Color:=clGray;
      DitherPatternPaintBox.Canvas.Pen.Width:=1;
    end;
    DitherPatternPaintBox.Canvas.Brush.Style:=bsClear;
    DitherPatternPaintBox.Canvas.Rectangle(cx - 1, cy - 1, cx + DitherPreviewSize + 1, cy + DitherPreviewSize + 1);
    DitherPatternPaintBox.Canvas.Brush.Style:=bsSolid;
    DitherPatternPaintBox.Canvas.Pen.Width:=1;
  end;
end;

procedure TRMMainForm.DitherPatternPaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  col, row, idx : integer;
  pat : array[0..63] of byte;
  i : integer;
begin
  col:=(X - 2) div (DitherPreviewSize + 2);
  row:=(Y - 2) div (DitherPreviewSize + 2);
  if (col < 0) or (col >= DitherCols) then exit;
  if (row < 0) or (row >= DitherRows) then exit;
  idx:=row * DitherCols + col;
  if idx >= DitherPatternCount then exit;

  //copy pattern data
  for i:=0 to 63 do
    pat[i]:=DitherPatterns[idx, i];

  //activate bitmap dither
  FSelectedDitherPattern:=idx;
  RMDrawTools.SetDitherBitmap(pat);
  UpdateDitherGradientColors;

  //switch radio group to Dither
  DrawMethod.ItemIndex:=2;
  RMDrawTools.SetBrushFillEnabled(false);

  DitherPatternPaintBox.Invalidate;
  DrawMethodPreview.Invalidate;
end;

procedure TRMMainForm.BrushOpenClick(Sender: TObject);
var
  OpenDlg : TOpenDialog;
  Bmp : TBitmap;
  Png : TPortableNetworkGraphic;
  i, j, w, h : integer;
  r, g, b : byte;
  pc : TColor;
  bestIdx, bestDist, dist, ci : integer;
  pr, pg, pb : byte;
  pal : TRMPaletteBuf;
  colorCount : integer;
begin
  OpenDlg:=TOpenDialog.Create(Self);
  try
    OpenDlg.Title:='Open Brush';
    OpenDlg.Filter:='Image Files|*.bmp;*.png|Bitmap|*.bmp|PNG|*.png|All Files|*.*';
    if not OpenDlg.Execute then exit;

    Bmp:=TBitmap.Create;
    try
      if LowerCase(ExtractFileExt(OpenDlg.FileName)) = '.png' then
      begin
        Png:=TPortableNetworkGraphic.Create;
        try
          Png.LoadFromFile(OpenDlg.FileName);
          Bmp.Assign(Png);
        finally
          Png.Free;
        end;
      end
      else
        Bmp.LoadFromFile(OpenDlg.FileName);

      w:=Bmp.Width;
      h:=Bmp.Height;
      if (w < 1) or (h < 1) or (w > 512) or (h > 512) then
      begin
        ShowMessage('Brush image must be 1-512 pixels in each dimension.');
        exit;
      end;

      //get current palette for remapping
      RMCoreBase.Palette.GetPalette(pal);
      colorCount:=RMCoreBase.Palette.GetColorCount;

      //load into brush, remap each pixel to closest palette color
      RetroBrush.OrigWidth:=w;
      RetroBrush.OrigHeight:=h;
      RetroBrush.WorkWidth:=w;
      RetroBrush.WorkHeight:=h;
      SetLength(RetroBrush.OrigPixels, w, h);
      SetLength(RetroBrush.WorkPixels, w, h);
      RetroBrush.TransColor:=0;
      RetroBrush.HasBrush:=true;
      RetroBrush.ColorCount:=colorCount;

      //copy current palette into brush so RemapIndex works correctly
      //since we're already remapping to this palette during load
      for ci:=0 to colorCount-1 do
        RetroBrush.Palette[ci]:=pal[ci];

      for i:=0 to w-1 do
      begin
        for j:=0 to h-1 do
        begin
          pc:=Bmp.Canvas.Pixels[i, j];
          r:=Red(pc);
          g:=Green(pc);
          b:=Blue(pc);

          //find closest palette color
          bestIdx:=0;
          bestDist:=MaxInt;
          for ci:=0 to colorCount-1 do
          begin
            pr:=pal[ci].r;
            pg:=pal[ci].g;
            pb:=pal[ci].b;
            dist:=(r - pr) * (r - pr) + (g - pg) * (g - pg) + (b - pb) * (b - pb);
            if dist < bestDist then
            begin
              bestDist:=dist;
              bestIdx:=ci;
            end;
          end;

          RetroBrush.OrigPixels[i][j]:=bestIdx;
          RetroBrush.WorkPixels[i][j]:=bestIdx;
        end;
      end;

      RetroBrush.InvalidateRemap;
      UpdateBrushRadioState;
      DrawMethodPreview.Invalidate;
      ZoomPaintBox.Invalidate;
    finally
      Bmp.Free;
    end;
  finally
    OpenDlg.Free;
  end;
end;

procedure TRMMainForm.BrushSaveClick(Sender: TObject);
var
  SaveDlg : TSaveDialog;
  Bmp : TBitmap;
  Png : TPortableNetworkGraphic;
  i, j : integer;
  ci : byte;
  pal : TRMPaletteBuf;
begin
  if not RetroBrush.HasBrush then
  begin
    ShowMessage('No brush to save. Capture a brush first.');
    exit;
  end;

  SaveDlg:=TSaveDialog.Create(Self);
  try
    SaveDlg.Title:='Save Brush';
    SaveDlg.Filter:='PNG Image|*.png|Bitmap|*.bmp';
    SaveDlg.DefaultExt:='.png';
    if not SaveDlg.Execute then exit;

    RMCoreBase.Palette.GetPalette(pal);

    Bmp:=TBitmap.Create;
    try
      Bmp.SetSize(RetroBrush.WorkWidth, RetroBrush.WorkHeight);

      for i:=0 to RetroBrush.WorkWidth-1 do
      begin
        for j:=0 to RetroBrush.WorkHeight-1 do
        begin
          ci:=RetroBrush.WorkPixels[i][j];
          Bmp.Canvas.Pixels[i, j]:=RGBToColor(pal[ci].r, pal[ci].g, pal[ci].b);
        end;
      end;

      if LowerCase(ExtractFileExt(SaveDlg.FileName)) = '.png' then
      begin
        Png:=TPortableNetworkGraphic.Create;
        try
          Png.Assign(Bmp);
          Png.SaveToFile(SaveDlg.FileName);
        finally
          Png.Free;
        end;
      end
      else
        Bmp.SaveToFile(SaveDlg.FileName);
    finally
      Bmp.Free;
    end;
  finally
    SaveDlg.Free;
  end;
end;

procedure TRMMainForm.BrushEffectsClick(Sender: TObject);
var
  Dlg : TBrushEffectsForm;
begin
  if not RetroBrush.HasBrush then
  begin
    ShowMessage('No brush captured. Use Brush > Grab from Selection or Grab Entire Sprite first.');
    exit;
  end;
  Dlg:=TBrushEffectsForm.Create(Self);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
  ZoomPaintBox.Invalidate;
end;

procedure TRMMainForm.DitherGradientFloodFill(StartX, StartY, FillWidth, FillHeight, ColorIndex : integer);
var
  TargetColor : integer;
  Visited : array of boolean;
  Queue : array of TPoint;
  QHead, QTail, QSize : integer;
  CX, CY, LX, RX, ScanX : integer;
  PixCount : integer;
  FillColor : integer;
  ci : integer;
  dist, maxDist : double;
  dx, dy : integer;
  Color2Index : integer;
  GradMode : integer;
  GradStartIdx, GradEndIdx : integer;

  procedure Enqueue(AX, AY : integer);
  begin
    if (AX < 0) or (AX >= FillWidth) or (AY < 0) or (AY >= FillHeight) then exit;
    if Visited[AY * FillWidth + AX] then exit;
    if RMCoreBase.GetPixel(AX, AY) <> TargetColor then exit;

    if QTail >= QSize then
    begin
      QSize:=QSize * 2;
      if QSize > PixCount then QSize:=PixCount;
      SetLength(Queue, QSize);
    end;
    Queue[QTail].X:=AX;
    Queue[QTail].Y:=AY;
    inc(QTail);
  end;

  function ComputeFillColor(px, py, baseColor : integer) : integer;
  var
    c : integer;
    bci : byte;
  begin
    c:=baseColor;

    //apply brush fill pattern
    if RMDrawTools.GetBrushFillEnabled and RetroBrush.HasBrush then
    begin
      bci:=RetroBrush.WorkPixels[px mod RetroBrush.WorkWidth][py mod RetroBrush.WorkHeight];
      //clamp to valid palette range
      if bci >= RMCoreBase.Palette.GetColorCount then
        bci:=bci mod RMCoreBase.Palette.GetColorCount;
      if bci <> RetroBrush.TransColor then
        c:=bci
      else
        c:=baseColor;  //transparent pixels use base color
      ComputeFillColor:=c;
      exit;
    end;

    //apply gradient
    if RMDrawTools.GetGradientEnabled then
    begin
      case GradMode of
        0: begin //horizontal
             if FillWidth > 1 then
               c:=GradStartIdx + ((GradEndIdx - GradStartIdx) * px) div (FillWidth - 1);
           end;
        1: begin //vertical
             if FillHeight > 1 then
               c:=GradStartIdx + ((GradEndIdx - GradStartIdx) * py) div (FillHeight - 1);
           end;
        2: begin //circular
             dx:=px - (FillWidth div 2);
             dy:=py - (FillHeight div 2);
             dist:=Sqrt(dx*dx + dy*dy);
             maxDist:=Sqrt(Sqr(FillWidth / 2.0) + Sqr(FillHeight / 2.0));
             if maxDist < 1 then maxDist:=1;
             if dist > maxDist then dist:=maxDist;
             c:=GradStartIdx + Round((GradEndIdx - GradStartIdx) * (dist / maxDist));
           end;
      end;
      if c < 0 then c:=0;
      if c > 255 then c:=255;
    end;

    //apply dither pattern
    if RMDrawTools.GetDitherEnabled then
    begin
      if RMDrawTools.DitherIsColor2(px, py) then
        c:=Color2Index;
    end;

    ComputeFillColor:=c;
  end;

begin
  if (StartX < 0) or (StartX >= FillWidth) or
     (StartY < 0) or (StartY >= FillHeight) then exit;

  TargetColor:=RMCoreBase.GetPixel(StartX, StartY);
  Color2Index:=RMCoreBase.GetCurColor2;
  GradMode:=RMDrawTools.GetGradientMode;
  GradStartIdx:=RMCoreBase.GetCurColor1;
  GradEndIdx:=Color2Index;

  //if fill color equals target and no effects active, skip
  if (TargetColor = ColorIndex) and
     (not RMDrawTools.GetDitherEnabled) and
     (not RMDrawTools.GetGradientEnabled) and
     (not RMDrawTools.GetBrushFillEnabled) then exit;

  PixCount:=FillWidth * FillHeight;

  //visited array prevents infinite loops when dither/gradient
  //writes pixels that match TargetColor
  Visited:=nil;
  SetLength(Visited, PixCount);
  FillChar(Visited[0], PixCount * SizeOf(Boolean), 0);

  QSize:=4096;
  SetLength(Queue, QSize);
  QHead:=0;
  QTail:=0;

  Enqueue(StartX, StartY);

  while QHead < QTail do
  begin
    CX:=Queue[QHead].X;
    CY:=Queue[QHead].Y;
    inc(QHead);

    //skip if already visited
    if Visited[CY * FillWidth + CX] then continue;

    //verify still target color
    if RMCoreBase.GetPixel(CX, CY) <> TargetColor then continue;

    //scan left to find span start
    LX:=CX;
    while (LX > 0) and (not Visited[CY * FillWidth + LX - 1]) and
          (RMCoreBase.GetPixel(LX - 1, CY) = TargetColor) do
      dec(LX);

    //scan right to find span end
    RX:=CX;
    while (RX < FillWidth - 1) and (not Visited[CY * FillWidth + RX + 1]) and
          (RMCoreBase.GetPixel(RX + 1, CY) = TargetColor) do
      inc(RX);

    //mark span as visited BEFORE filling
    for ScanX:=LX to RX do
      Visited[CY * FillWidth + ScanX]:=True;

    //fill the span with dither/gradient-aware color
    for ScanX:=LX to RX do
    begin
      FillColor:=ComputeFillColor(ScanX, CY, ColorIndex);
      RMCoreBase.SetColorEx(FillColor);
      RMCoreBase.PutPixelEx(ScanX, CY);
    end;

    //enqueue seeds for row above and below
    for ScanX:=LX to RX do
    begin
      if CY > 0 then Enqueue(ScanX, CY - 1);
      if CY < FillHeight - 1 then Enqueue(ScanX, CY + 1);
    end;
  end;

  SetLength(Queue, 0);
  SetLength(Visited, 0);

  //restore ColorEx
  RMCoreBase.SetColorEx(ColorIndex);
end;

function TRMMainForm.ImageHasData : boolean;
var
  i, j : integer;
begin
  ImageHasData:=false;
  for j:=0 to RMCoreBase.GetHeight-1 do
    for i:=0 to RMCoreBase.GetWidth-1 do
      if RMCoreBase.GetPixel(i, j) <> 0 then
      begin
        ImageHasData:=true;
        exit;
      end;
end;

function TRMMainForm.ConfirmPaletteSwitch(newMode : integer) : boolean;
var
  oldCount, newCount : integer;
  msg : string;
begin
  ConfirmPaletteSwitch:=true;

  if not ImageHasData then exit;  //empty image, no confirmation needed

  oldCount:=RMCoreBase.Palette.GetColorCount;

  case newMode of
    PaletteModeMono:    newCount:=2;
    PaletteModeCGA0:    newCount:=4;
    PaletteModeCGA1:    newCount:=4;
    PaletteModeEGA:     newCount:=16;
    PaletteModeVGA:     newCount:=16;
    PaletteModeVGA256:  newCount:=256;
    PaletteModeXGA:     newCount:=16;
    PaletteModeXGA256:  newCount:=256;
    PaletteModeAmiga2:  newCount:=2;
    PaletteModeAmiga4:  newCount:=4;
    PaletteModeAmiga8:  newCount:=8;
    PaletteModeAmiga16: newCount:=16;
    PaletteModeAmiga32: newCount:=32;
  else
    newCount:=16;
  end;

  if newCount < oldCount then
  begin
    //going to fewer colors - severe quality loss
    msg:='This Palette change will result in huge image quality loss, '+
         'please consider using a program like RetroConvert(free) that can '+
         'convert with more palette/image dithering options.' + LineEnding + LineEnding +
         'Do you wish to continue?';
    ConfirmPaletteSwitch:=(MessageDlg('Palette Change Warning', msg,
      mtWarning, [mbYes, mbNo], 0) = mrYes);
  end
  else if newCount > oldCount then
  begin
    //going to more colors - minor quality concern from remapping
    msg:='Switching Palette will require remapping the current colors '+
         'and may result in loss of quality.' + LineEnding + LineEnding +
         'Do you wish to continue?';
    ConfirmPaletteSwitch:=(MessageDlg('Palette Change', msg,
      mtConfirmation, [mbYes, mbNo], 0) = mrYes);
  end
  else
  begin
    //same color count but different palette
    msg:='Switching Palette will require remapping the current colors '+
         'and may result in loss of quality.' + LineEnding + LineEnding +
         'Do you wish to continue?';
    ConfirmPaletteSwitch:=(MessageDlg('Palette Change', msg,
      mtConfirmation, [mbYes, mbNo], 0) = mrYes);
  end;
end;

procedure TRMMainForm.RemapImageToNewPalette(newMode : integer);
var
  oldPal : TRMPaletteBuf;
  newPal : TRMPaletteBuf;
  oldCount, newCount : integer;
  remapTable : array[0..255] of byte;
  usedColors : array[0..255] of boolean;
  usedRGB : array[0..255] of TRMColorRec;
  usedCount : integer;
  i, j, oi, ni, ui : integer;
  bestIdx, bestDist, dist : integer;
  or1, og1, ob1, nr, ng, nb : integer;
  customColors : boolean;
  palSlot : integer;
begin
  //save current palette before switching
  RMCoreBase.Palette.GetPalette(oldPal);
  oldCount:=RMCoreBase.Palette.GetColorCount;

  //find which color indices are actually used in the image
  for oi:=0 to 255 do
    usedColors[oi]:=false;

  for j:=0 to RMCoreBase.GetHeight-1 do
    for i:=0 to RMCoreBase.GetWidth-1 do
    begin
      oi:=RMCoreBase.GetPixel(i, j);
      if (oi >= 0) and (oi < oldCount) then
        usedColors[oi]:=true;
    end;

  //build list of unique RGB colors actually used
  usedCount:=0;
  for oi:=0 to oldCount-1 do
  begin
    if usedColors[oi] then
    begin
      usedRGB[usedCount]:=oldPal[oi];
      inc(usedCount);
    end;
  end;

  //switch to new palette mode and load its default colors
  ClearSelectedPaletteMenu;
  RMCoreBase.Palette.SetPaletteMode(newMode);
  LoadDefaultPalette;

  //get the new default palette
  RMCoreBase.Palette.GetPalette(newPal);
  newCount:=RMCoreBase.Palette.GetColorCount;
  customColors:=false;

  //when going to fewer colors, build optimal palette from used image colors
  if newCount < oldCount then
  begin
    //count frequency of each old color index
    for oi:=0 to 255 do
      remapTable[oi]:=0;  //reuse as frequency counter temporarily

    for j:=0 to RMCoreBase.GetHeight-1 do
      for i:=0 to RMCoreBase.GetWidth-1 do
      begin
        oi:=RMCoreBase.GetPixel(i, j);
        if (oi >= 0) and (oi < oldCount) then
          inc(remapTable[oi]);
      end;

    //keep slot 0 as background (usually black)
    //fill remaining slots with most frequently used colors
    //first, check if old color 0 matches new color 0 (both usually black)
    newPal[0].r:=oldPal[0].r;
    newPal[0].g:=oldPal[0].g;
    newPal[0].b:=oldPal[0].b;

    //build list of used color indices sorted by frequency (highest first)
    //simple selection: pick top (newCount-1) most frequent non-zero indices
    palSlot:=1;
    while palSlot < newCount do
    begin
      bestIdx:=-1;
      bestDist:=0;  //reuse as max frequency
      for oi:=1 to oldCount-1 do  //skip 0
      begin
        if remapTable[oi] > bestDist then
        begin
          //check this color isn't already in the new palette
          or1:=oldPal[oi].r;
          og1:=oldPal[oi].g;
          ob1:=oldPal[oi].b;
          dist:=1;  //assume not duplicate
          for ni:=0 to palSlot-1 do
          begin
            if (newPal[ni].r = or1) and (newPal[ni].g = og1) and (newPal[ni].b = ob1) then
            begin
              dist:=0;
              break;
            end;
          end;
          if dist = 1 then
          begin
            bestDist:=remapTable[oi];
            bestIdx:=oi;
          end;
        end;
      end;

      if bestIdx < 0 then break;  //no more used colors

      newPal[palSlot].r:=oldPal[bestIdx].r;
      newPal[palSlot].g:=oldPal[bestIdx].g;
      newPal[palSlot].b:=oldPal[bestIdx].b;
      remapTable[bestIdx]:=0;  //mark as placed so we don't pick it again
      inc(palSlot);
    end;

    customColors:=true;

    //clear frequency data from remapTable before building actual remap
    for oi:=0 to 255 do
      remapTable[oi]:=0;
  end;

  //when going to more colors, add unmatched old colors to empty slots
  if newCount > oldCount then
  begin
    palSlot:=oldCount;  //start filling after the default entries
    for oi:=0 to oldCount-1 do
    begin
      if not usedColors[oi] then continue;
      or1:=oldPal[oi].r;
      og1:=oldPal[oi].g;
      ob1:=oldPal[oi].b;

      //check if exact match exists
      bestDist:=MaxInt;
      for ni:=0 to newCount-1 do
      begin
        if (or1 = newPal[ni].r) and (og1 = newPal[ni].g) and (ob1 = newPal[ni].b) then
        begin
          bestDist:=0;
          break;
        end;
      end;

      if (bestDist > 0) and (palSlot < newCount) then
      begin
        newPal[palSlot].r:=or1;
        newPal[palSlot].g:=og1;
        newPal[palSlot].b:=ob1;
        inc(palSlot);
        customColors:=true;
      end;
    end;
  end;

  //write custom palette back if modified
  if customColors then
  begin
    for ni:=0 to newCount-1 do
      RMCoreBase.Palette.SetColor(ni, newPal[ni]);
    //update the UI palette from core (preserves our custom colors)
    CoreToPalette;
    //re-read palette to confirm
    RMCoreBase.Palette.GetPalette(newPal);
  end;

  //build remap table: for each old index, find best new index
  for oi:=0 to 255 do
    remapTable[oi]:=0;

  for oi:=0 to oldCount-1 do
  begin
    or1:=oldPal[oi].r;
    og1:=oldPal[oi].g;
    ob1:=oldPal[oi].b;

    bestIdx:=0;
    bestDist:=MaxInt;
    for ni:=0 to newCount-1 do
    begin
      nr:=newPal[ni].r;
      ng:=newPal[ni].g;
      nb:=newPal[ni].b;
      if (or1 = nr) and (og1 = ng) and (ob1 = nb) then
      begin
        bestIdx:=ni;
        bestDist:=0;
        break;
      end;
      dist:=(or1 - nr) * (or1 - nr) + (og1 - ng) * (og1 - ng) + (ob1 - nb) * (ob1 - nb);
      if dist < bestDist then
      begin
        bestDist:=dist;
        bestIdx:=ni;
      end;
    end;

    remapTable[oi]:=bestIdx;
  end;

  //remap all pixels in the image buffer
  for j:=0 to RMCoreBase.GetHeight-1 do
  begin
    for i:=0 to RMCoreBase.GetWidth-1 do
    begin
      oi:=RMCoreBase.GetPixel(i, j);
      if oi >= oldCount then oi:=0;
      RMCoreBase.SetColorEx(remapTable[oi]);
      RMCoreBase.PutPixelEx(i, j);
    end;
  end;

  //save undo buffer AFTER remap so undo cannot revert to old palette indices
  RMCoreBase.CopyToUndoBuf;
end;

procedure TRMMainForm.PaletteResetDefaultClick(Sender: TObject);
var
  oldPal, newPal : TRMPaletteBuf;
  colorCount : integer;
  remapTable : array[0..255] of byte;
  i, j, oi, ni : integer;
  bestIdx, bestDist, dist : integer;
  doRemap : boolean;
begin
  colorCount:=RMCoreBase.Palette.GetColorCount;

  if not ImageHasData then
  begin
    //empty image - just reset silently
    LoadDefaultPalette;
    UpdateColorBoxes;
    UpdateActualArea;
    UpdateZoomArea;
    UpdateThumbview;
    exit;
  end;

  //image has data - ask about remapping
  doRemap:=(MessageDlg('Reset Palette',
    'Remap the sprite colors to the closest default palette colors?' + LineEnding + LineEnding +
    'Yes = remap sprite to default colors' + LineEnding +
    'No = keep sprite indices, just reset palette colors',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes);

  //save current palette RGB values before reset
  RMCoreBase.Palette.GetPalette(oldPal);

  //reset to default palette
  LoadDefaultPalette;

  if doRemap then
  begin
    //get the new default palette
    RMCoreBase.Palette.GetPalette(newPal);

    //build remap table: old index -> closest default color
    for oi:=0 to 255 do
      remapTable[oi]:=0;

    for oi:=0 to colorCount-1 do
    begin
      bestIdx:=0;
      bestDist:=MaxInt;
      for ni:=0 to colorCount-1 do
      begin
        if (oldPal[oi].r = newPal[ni].r) and (oldPal[oi].g = newPal[ni].g) and
           (oldPal[oi].b = newPal[ni].b) then
        begin
          bestIdx:=ni;
          break;
        end;
        dist:=(oldPal[oi].r - newPal[ni].r) * (oldPal[oi].r - newPal[ni].r) +
              (oldPal[oi].g - newPal[ni].g) * (oldPal[oi].g - newPal[ni].g) +
              (oldPal[oi].b - newPal[ni].b) * (oldPal[oi].b - newPal[ni].b);
        if dist < bestDist then
        begin
          bestDist:=dist;
          bestIdx:=ni;
        end;
      end;
      remapTable[oi]:=bestIdx;
    end;

    //remap all pixels
    for j:=0 to RMCoreBase.GetHeight-1 do
      for i:=0 to RMCoreBase.GetWidth-1 do
      begin
        oi:=RMCoreBase.GetPixel(i, j);
        if oi >= colorCount then oi:=0;
        RMCoreBase.SetColorEx(remapTable[oi]);
        RMCoreBase.PutPixelEx(i, j);
      end;

    RMCoreBase.CopyToUndoBuf;
  end;

  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;

procedure TRMMainForm.PaletteSortColorsClick(Sender: TObject);
var
  pal : TRMPaletteBuf;
  colorCount : integer;
  freq : array[0..255] of integer;
  order : array[0..255] of integer;
  remapTable : array[0..255] of byte;
  sortedPal : TRMPaletteBuf;
  i, j, oi, ni, tmp : integer;
begin
  colorCount:=RMCoreBase.Palette.GetColorCount;
  RMCoreBase.Palette.GetPalette(pal);

  //count pixel frequency of each color index
  for i:=0 to 255 do
    freq[i]:=0;

  for j:=0 to RMCoreBase.GetHeight-1 do
    for i:=0 to RMCoreBase.GetWidth-1 do
    begin
      oi:=RMCoreBase.GetPixel(i, j);
      if (oi >= 0) and (oi < colorCount) then
        inc(freq[oi]);
    end;

  //build order: index 0 stays at 0 (black/background)
  for i:=0 to colorCount-1 do
    order[i]:=i;

  //bubble sort indices 1..colorCount-1 by frequency descending
  for i:=1 to colorCount-2 do
    for j:=1 to colorCount-1-i do
      if freq[order[j]] < freq[order[j+1]] then
      begin
        tmp:=order[j];
        order[j]:=order[j+1];
        order[j+1]:=tmp;
      end;

  //build sorted palette and remap table
  for ni:=0 to colorCount-1 do
  begin
    sortedPal[ni]:=pal[order[ni]];
    remapTable[order[ni]]:=ni;
  end;

  //write sorted palette to core
  for ni:=0 to colorCount-1 do
    RMCoreBase.Palette.SetColor(ni, sortedPal[ni]);
  CoreToPalette;

  //remap all pixels to their new indices
  for j:=0 to RMCoreBase.GetHeight-1 do
    for i:=0 to RMCoreBase.GetWidth-1 do
    begin
      oi:=RMCoreBase.GetPixel(i, j);
      if oi >= colorCount then oi:=0;
      RMCoreBase.SetColorEx(remapTable[oi]);
      RMCoreBase.PutPixelEx(i, j);
    end;

  RMCoreBase.CopyToUndoBuf;

  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;


function TRMMainForm.AllocMaterialColor(r, g, b : byte; var pal : TRMPaletteBuf;
  var usedColors : array of boolean; colorCount : integer;
  var paletteModified : boolean) : integer;
var
  ni, bestIdx, bestDist, dist : integer;
begin
  //1. exact match
  for ni:=0 to colorCount-1 do
    if (pal[ni].r = r) and (pal[ni].g = g) and (pal[ni].b = b) then
    begin
      AllocMaterialColor:=ni;
      exit;
    end;

  //2. unused slot starting at index 1
  for ni:=1 to colorCount-1 do
    if not usedColors[ni] then
    begin
      pal[ni].r:=r;
      pal[ni].g:=g;
      pal[ni].b:=b;
      usedColors[ni]:=true;
      paletteModified:=true;
      AllocMaterialColor:=ni;
      exit;
    end;

  //3. nearest match
  bestIdx:=0;
  bestDist:=MaxInt;
  for ni:=0 to colorCount-1 do
  begin
    dist:=(r - pal[ni].r) * (r - pal[ni].r) +
          (g - pal[ni].g) * (g - pal[ni].g) +
          (b - pal[ni].b) * (b - pal[ni].b);
    if dist < bestDist then
    begin
      bestDist:=dist;
      bestIdx:=ni;
    end;
  end;
  AllocMaterialColor:=bestIdx;
end;

procedure TRMMainForm.GenerateMaterial(const MatName : string; TopView : boolean);
type
  TShadeRGB = record r, g, b : byte; end;
var
  ca : TClipAreaRec;
  pal : TRMPaletteBuf;
  colorCount : integer;
  usedColors : array[0..255] of boolean;
  paletteModified : boolean;
  shades : array[0..4] of TShadeRGB;
  shadeIdx : array[0..4] of integer;
  i, j, px, py, ci, s, w, h, n : integer;
  fullArea : boolean;

  function Noise(x, y : integer) : integer;
  var
    v : longword;
  begin
    v:=longword(x) * 374761393 + longword(y) * 668265263;
    v:=(v xor (v shr 13)) * 1274126177;
    Noise:=(v xor (v shr 16)) and $7FFFFFFF;
  end;

  procedure SetShade(idx : integer; rr, gg, bb : byte);
  begin
    shades[idx].r:=rr; shades[idx].g:=gg; shades[idx].b:=bb;
  end;

begin
  //determine target region
  RMDrawTools.GetClipAreaCoords(ca);
  fullArea:=(RMDrawTools.GetClipStatus <> 1);

  //full-sprite render over existing pixels needs confirmation
  if fullArea and ImageHasData then
  begin
    if MessageDlg('Generate Material',
      'The current area will be replaced by the material. Continue?',
      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then exit;
  end;

  //define material shades (index 0 = darkest ... 3 = lightest)
  if MatName = 'Dirt' then
  begin
    SetShade(0, 101, 67, 33);  SetShade(1, 120, 80, 40);
    SetShade(2, 139, 94, 47);  SetShade(3, 160, 110, 60);
  end
  else if MatName = 'Rock' then
  begin
    SetShade(0, 80, 80, 85);   SetShade(1, 105, 105, 110);
    SetShade(2, 130, 130, 135); SetShade(3, 160, 160, 165);
  end
  else if MatName = 'Grass' then
  begin
    SetShade(0, 24, 100, 24);  SetShade(1, 34, 139, 34);
    SetShade(2, 50, 160, 50);  SetShade(3, 80, 190, 80);
  end
  else if MatName = 'Snow' then
  begin
    SetShade(0, 200, 210, 225); SetShade(1, 220, 228, 240);
    SetShade(2, 240, 245, 252); SetShade(3, 255, 255, 255);
  end
  else if MatName = 'Ice' then
  begin
    SetShade(0, 130, 180, 220); SetShade(1, 160, 205, 235);
    SetShade(2, 190, 225, 245); SetShade(3, 220, 240, 252);
  end
  else if MatName = 'Wood' then
  begin
    SetShade(0, 110, 70, 35);  SetShade(1, 140, 90, 45);
    SetShade(2, 165, 110, 55); SetShade(3, 190, 135, 70);
  end
  else if MatName = 'Metal' then
  begin
    SetShade(0, 90, 95, 100);  SetShade(1, 120, 125, 130);
    SetShade(2, 150, 155, 160); SetShade(3, 190, 195, 200);
  end
  else if MatName = 'Silver' then
  begin
    SetShade(0, 140, 140, 150); SetShade(1, 175, 175, 185);
    SetShade(2, 205, 205, 215); SetShade(3, 235, 235, 245);
  end
  else if MatName = 'Gold' then
  begin
    SetShade(0, 160, 120, 20); SetShade(1, 200, 155, 30);
    SetShade(2, 230, 185, 40); SetShade(3, 255, 215, 60);
  end
  else if MatName = 'Crate' then
  begin
    SetShade(0, 105, 65, 30);  SetShade(1, 145, 95, 45);
    SetShade(2, 170, 115, 60); SetShade(3, 200, 145, 80);
  end
  else if MatName = 'BrownBrick' then
  begin
    SetShade(0, 120, 55, 35);  SetShade(1, 150, 70, 45);
    SetShade(2, 170, 85, 55);  SetShade(3, 190, 105, 70);
    SetShade(4, 210, 200, 185);  //light mortar border
  end
  else if MatName = 'StoneBrick' then
  begin
    SetShade(0, 95, 95, 100);  SetShade(1, 120, 120, 128);
    SetShade(2, 140, 140, 148); SetShade(3, 165, 165, 172);
    SetShade(4, 60, 60, 68);   //dark mortar border
  end
  else if MatName = 'WoodFloor' then
  begin
    SetShade(0, 120, 78, 40);  SetShade(1, 150, 100, 52);
    SetShade(2, 175, 120, 65); SetShade(3, 200, 145, 85);
    SetShade(4, 90, 58, 28);   //dark plank border
  end
  else if MatName = 'CeramicTile' then
  begin
    SetShade(0, 200, 215, 215); SetShade(1, 220, 232, 232);
    SetShade(2, 235, 244, 244); SetShade(3, 250, 252, 252);
    SetShade(4, 120, 135, 140);  //grout border
  end
  else //Water
  begin
    SetShade(0, 20, 60, 140);  SetShade(1, 30, 90, 180);
    SetShade(2, 50, 120, 210); SetShade(3, 90, 160, 235);
  end;

  //shade 4 defaults to darkest if the material didn't define a border color
  if (MatName <> 'BrownBrick') and (MatName <> 'StoneBrick') and
     (MatName <> 'WoodFloor') and (MatName <> 'CeramicTile') then
    SetShade(4, shades[0].r, shades[0].g, shades[0].b);

  //allocate palette entries for the 4 shades
  RMCoreBase.Palette.GetPalette(pal);
  colorCount:=RMCoreBase.Palette.GetColorCount;
  paletteModified:=false;

  for i:=0 to 255 do
    usedColors[i]:=false;
  usedColors[0]:=true;

  for py:=0 to RMCoreBase.GetHeight-1 do
    for px:=0 to RMCoreBase.GetWidth-1 do
    begin
      ci:=RMCoreBase.GetPixel(px, py);
      if (ci >= 0) and (ci < colorCount) then
        usedColors[ci]:=true;
    end;

  for s:=0 to 4 do
    shadeIdx[s]:=AllocMaterialColor(shades[s].r, shades[s].g, shades[s].b,
                   pal, usedColors, colorCount, paletteModified);

  RMCoreBase.CopyToUndoBuf;

  w:=ca.x2 - ca.x + 1;
  h:=ca.y2 - ca.y + 1;

  //render material into region
  for j:=0 to h-1 do
  begin
    for i:=0 to w-1 do
    begin
      px:=ca.x + i;
      py:=ca.y + j;
      n:=Noise(px, py);

      //default: random speckle between shades 1 and 2
      s:=1 + (n mod 2);

      if MatName = 'Grass' then
      begin
        if TopView then
        begin
          s:=1 + (n mod 3);  //mixed greens
          if (n mod 17) = 0 then s:=3;  //light blade highlights
        end
        else
        begin
          //side: grass strip on top ~25% then dirt-ish darker below
          if j < (h div 4) then
            s:=1 + (n mod 3)
          else
            s:=(n mod 2);  //darker under-layer using dark shades
        end;
      end
      else if MatName = 'Dirt' then
      begin
        s:=1 + (n mod 2);
        if (n mod 11) = 0 then s:=0;  //dark clumps
        if (n mod 23) = 0 then s:=3;  //light specks
      end
      else if MatName = 'Rock' then
      begin
        //blocky: quantize noise per 4x4 cell
        n:=Noise(px div 4, py div 4);
        s:=n mod 4;
        //crack lines
        if ((px + (Noise(0, py) mod 3)) mod 8) = 0 then s:=0;
      end
      else if MatName = 'Snow' then
      begin
        s:=2 + (n mod 2);
        if (n mod 13) = 0 then s:=1;  //subtle shadows
        if (not TopView) and (j < 2) then s:=3;  //bright top edge
      end
      else if MatName = 'Ice' then
      begin
        s:=1 + (n mod 2);
        //diagonal streaks
        if ((px + py) mod 7) = 0 then s:=3;
        if ((px - py) mod 11) = 0 then s:=0;
      end
      else if MatName = 'Wood' then
      begin
        if TopView then
        begin
          //vertical grain
          s:=1 + ((px + (Noise(px div 3, 0) mod 2)) mod 2);
          if (px mod 9) = 0 then s:=0;  //grain lines
          if (n mod 19) = 0 then s:=3;
        end
        else
        begin
          //horizontal planks every 6 rows
          s:=1 + (n mod 2);
          if (py mod 6) = 0 then s:=0;  //plank separation
          if ((py mod 6) = 1) and ((n mod 3) = 0) then s:=3;  //highlight under line
        end;
      end
      else if MatName = 'Metal' then
      begin
        s:=1 + (n mod 2);
        //horizontal brushed lines
        if (py mod 5) = 0 then s:=2;
        //rivets every 8x8
        if ((px mod 8) = 4) and ((py mod 8) = 4) then s:=3;
        if ((px mod 8) = 5) and ((py mod 8) = 5) then s:=0;
      end
      else if MatName = 'Silver' then
      begin
        //smooth metallic bands
        s:=((px + py) div 4) mod 4;
        if s < 0 then s:=0;
        if (n mod 29) = 0 then s:=3;
      end
      else if MatName = 'Gold' then
      begin
        s:=((px + py) div 3) mod 4;
        if (n mod 21) = 0 then s:=3;  //sparkle
        if (n mod 31) = 0 then s:=0;
      end
      else if MatName = 'Crate' then
      begin
        //crate: wood fill with dark frame border + X diagonal braces
        s:=1 + (n mod 2);
        if (n mod 15) = 0 then s:=3;
        //outer frame (2px)
        if (i < 2) or (j < 2) or (i >= w-2) or (j >= h-2) then s:=0
        //diagonal cross braces
        else if abs((i * (h-1)) - (j * (w-1))) < (w+h) div 2 then s:=2
        else if abs((i * (h-1)) - ((h-1-j) * (w-1))) < (w+h) div 2 then s:=2;
      end
      else if MatName = 'BrownBrick' then
      begin
        //brick pattern: 8 wide x 4 tall, offset every other row, mortar border
        px:=ca.x + i;
        py:=ca.y + j;
        if (py mod 4) = 0 then s:=4  //horizontal mortar line
        else
        begin
          //offset alternate rows by half a brick
          if ((py div 4) mod 2) = 0 then n:=px
          else n:=px + 4;
          if (n mod 8) = 0 then s:=4  //vertical mortar line
          else
          begin
            n:=Noise((n div 8), (py div 4));  //per-brick shade
            s:=1 + (n mod 3);
            if (Noise(px, py) mod 19) = 0 then s:=0;  //speckle
          end;
        end;
      end
      else if MatName = 'StoneBrick' then
      begin
        //larger stone blocks: 10 wide x 5 tall, offset rows, dark mortar
        px:=ca.x + i;
        py:=ca.y + j;
        if (py mod 5) = 0 then s:=4
        else
        begin
          if ((py div 5) mod 2) = 0 then n:=px
          else n:=px + 5;
          if (n mod 10) = 0 then s:=4
          else
          begin
            n:=Noise((n div 10), (py div 5));
            s:=1 + (n mod 3);
            if (Noise(px, py) mod 13) = 0 then s:=0;  //rough texture
          end;
        end;
      end
      else if MatName = 'WoodFloor' then
      begin
        //floor boards: horizontal planks 4 tall, staggered end joints, dark border
        px:=ca.x + i;
        py:=ca.y + j;
        if (py mod 4) = 0 then s:=4  //plank separation line
        else
        begin
          //stagger joints: each row of planks offset by row index * 7
          n:=px + ((py div 4) * 7);
          if (n mod 14) = 0 then s:=4  //end joint
          else
          begin
            n:=Noise((n div 14), (py div 4));
            s:=1 + (n mod 2);
            if (Noise(px, py) mod 9) = 0 then s:=0;   //grain
            if (Noise(px, py) mod 17) = 0 then s:=3;  //highlight
          end;
        end;
      end
      else if MatName = 'CeramicTile' then
      begin
        //square tiles 6x6 with grout border
        px:=ca.x + i;
        py:=ca.y + j;
        if ((px mod 6) = 0) or ((py mod 6) = 0) then s:=4  //grout
        else
        begin
          n:=Noise(px div 6, py div 6);  //per-tile tint
          s:=1 + (n mod 2);
          //glossy highlight in top-left of each tile
          if ((px mod 6) = 1) and ((py mod 6) = 1) then s:=3;
          if ((px mod 6) = 2) and ((py mod 6) = 1) then s:=3;
        end;
      end
      else if MatName = 'Water' then
      begin
        if TopView then
        begin
          //ripple rings via noise cells
          n:=Noise(px div 3, py div 3);
          s:=1 + (n mod 2);
          if ((px + py + (n mod 5)) mod 9) = 0 then s:=3;  //glints
        end
        else
        begin
          //horizontal waves; brighter near top
          s:=1 + (n mod 2);
          if (py mod 4) = 0 then s:=2;
          if j < 2 then s:=3;  //surface highlight
          if ((px + py div 2) mod 13) = 0 then s:=0;
        end;
      end;

      RMCoreBase.SetColorEx(shadeIdx[s]);
      RMCoreBase.PutPixelEx(px, py);
    end;
  end;

  //write modified palette back
  if paletteModified then
  begin
    for i:=0 to colorCount-1 do
      RMCoreBase.Palette.SetColor(i, pal[i]);
    CoreToPalette;
  end;

  ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);

  UpdateColorBoxes;
  UpdateActualArea;
  UpdateZoomArea;
  UpdateThumbview;
end;


const
  DitherPatternNames : array[0..35] of string = (
    'Checkerboard','Light Dots','Heavy','H-Lines Thin','H-Lines Thick',
    'V-Lines Thin','V-Lines Thick','Diagonal R','Diagonal L','Crosshatch',
    'X-Cross','Brick','Basket Weave','Sparse Dots','Medium Dots','Grid',
    'Zigzag','Waves','Double Diag','Diamond','Fish Scale','Bayer 25%',
    'Bayer 50%','H-Stripe 3px','V-Stripe 3px','Herringbone','Dotted Grid',
    'Checker 2x2','Thick Diag R','Thick Diag L','Plus Signs','H-Dashes',
    'V-Dashes','Small Squares','Maze','Stipple');

procedure TRMMainForm.UpdateStatusInfo;
var
  pm : integer;
  palName, brushStr, methodStr, ditherStr, s : string;
begin
  if StatusBar = nil then exit;
  if StatusBar.Panels.Count < 4 then exit;

  //panel 2: sprite size, grid cell, zoom
  s:='Sprite: '+IntToStr(RMCoreBase.GetWidth)+'x'+IntToStr(RMCoreBase.GetHeight)+
     '  Cell: '+IntToStr(RMDrawTools.GetCellWidth)+'x'+IntToStr(RMDrawTools.GetCellHeight)+
     '  Zoom: '+IntToStr(RMDrawTools.GetZoomSize)+'x';
  StatusBar.Panels[2].Text:=s;

  //panel 3: palette type, draw method, dither, brush
  pm:=RMCoreBase.Palette.GetPaletteMode;
  case pm of
    PaletteModeMono:    palName:='Mono';
    PaletteModeCGA0:    palName:='CGA 0';
    PaletteModeCGA1:    palName:='CGA 1';
    PaletteModeEGA:     palName:='EGA';
    PaletteModeVGA:     palName:='VGA 16';
    PaletteModeVGA256:  palName:='VGA 256';
    PaletteModeXGA:     palName:='XGA 16';
    PaletteModeXGA256:  palName:='XGA 256';
    PaletteModeAmiga2:  palName:='Amiga 2';
    PaletteModeAmiga4:  palName:='Amiga 4';
    PaletteModeAmiga8:  palName:='Amiga 8';
    PaletteModeAmiga16: palName:='Amiga 16';
    PaletteModeAmiga32: palName:='Amiga 32';
  else
    palName:='?';
  end;

  case DrawMethod.ItemIndex of
    0: methodStr:='Color';
    1: methodStr:='Brush';
    2: methodStr:='Dither';
    3: begin
         case GradientMethod.ItemIndex of
           0: methodStr:='Gradient H';
           1: methodStr:='Gradient V';
           2: methodStr:='Gradient O';
         else
           methodStr:='Gradient';
         end;
       end;
  else
    methodStr:='?';
  end;

  ditherStr:='';
  if (FSelectedDitherPattern >= 0) and (FSelectedDitherPattern <= 35) then
    ditherStr:='  Dither: '+DitherPatternNames[FSelectedDitherPattern];

  if RetroBrush.HasBrush then
    brushStr:='  Brush: '+IntToStr(RetroBrush.WorkWidth)+'x'+IntToStr(RetroBrush.WorkHeight)
  else
    brushStr:='  Brush: none';

  StatusBar.Panels[3].Text:='Palette: '+palName+'  Draw: '+methodStr+ditherStr+brushStr;
end;

procedure TRMMainForm.MaterialClick(Sender: TObject);
var
  mi : string;
  matName : string;
  topView : boolean;
begin
  mi:=(Sender as TMenuItem).Name;   //e.g. MnuMatDirtSide

  //strip 'MnuMat' prefix
  matName:=Copy(mi, 7, Length(mi));

  topView:=false;
  if Copy(matName, Length(matName)-3, 4) = 'Side' then
    matName:=Copy(matName, 1, Length(matName)-4)
  else if Copy(matName, Length(matName)-2, 3) = 'Top' then
  begin
    matName:=Copy(matName, 1, Length(matName)-3);
    topView:=true;
  end;

  GenerateMaterial(matName, topView);
end;

procedure TRMMainForm.SetDefaultDrawColors;
var
  pm : integer;
begin
  pm:=RMCoreBase.Palette.GetPaletteMode;

  case pm of
    PaletteModeMono:
    begin
      RMCoreBase.SetCurColor1(1);   //white
      RMCoreBase.SetCurColor2(0);   //black
    end;
    PaletteModeCGA0, PaletteModeCGA1:
    begin
      RMCoreBase.SetCurColor1(3);   //brightest color
      RMCoreBase.SetCurColor2(0);   //black
    end;
    PaletteModeAmiga2, PaletteModeAmiga4, PaletteModeAmiga8,
    PaletteModeAmiga16, PaletteModeAmiga32:
    begin
      //amiga palettes stay as-is, don't change
    end;
  else
    //EGA, VGA, VGA256, XGA, XGA256 - all 16/256 color PC modes
    RMCoreBase.SetCurColor1(15);  //white
    RMCoreBase.SetCurColor2(0);   //black
  end;

  if DrawMethodPreview <> nil then
    UpdateColorBoxes;
end;

procedure TRMMainForm.UpdateBrushRadioState;
begin
  //enable/disable Brush radio based on whether a brush is captured
  //Brush is index 1 in the radio group
  if not RetroBrush.HasBrush then
  begin
    //if brush mode was active, switch to Color
    if DrawMethod.ItemIndex = 1 then
    begin
      DrawMethod.ItemIndex:=0;
      RMDrawTools.SetBrushFillEnabled(false);
      DrawMethodPreview.Invalidate;
    end;
  end;
  UpdateStatusInfo;
end;

procedure TRMMainForm.UpdateDitherGradientColors;
begin
  RMDrawTools.SetDitherColor2(ColorBox2.Brush.Color, RMCoreBase.GetCurColor2);
  RMDrawTools.SetGradientColors(
    RMCoreBase.GetCurColor1, RMCoreBase.GetCurColor2,
    ColorBox1.Brush.Color, ColorBox2.Brush.Color);
end;

procedure TRMMainForm.StampBrushToCore;
var
  bx, by, tx, ty, ci : integer;
  TargetPal : TRMPaletteBuf;
  offX, offY : integer;
begin
  if not RetroBrush.HasBrush then exit;

  //center the brush on the cursor - same offset as the preview
  offX:=ZoomX - RetroBrush.WorkWidth div 2;
  offY:=ZoomY - RetroBrush.WorkHeight div 2;

  RMCoreBase.Palette.GetPalette(TargetPal);
  RetroBrush.InvalidateRemap;
  RetroBrush.BuildRemapTable(TargetPal,
    RMCoreBase.Palette.GetPaletteMode,
    RMCoreBase.Palette.GetColorCount);

  for bx:=0 to RetroBrush.WorkWidth-1 do
    for by:=0 to RetroBrush.WorkHeight-1 do
    begin
      ci:=RetroBrush.WorkPixels[bx][by];
      if ci = RetroBrush.TransColor then continue;
      tx:=offX + bx;
      ty:=offY + by;
      if (tx >= 0) and (tx < RMCoreBase.GetWidth) and
         (ty >= 0) and (ty < RMCoreBase.GetHeight) then
        RMCoreBase.PutPixel(tx, ty, RetroBrush.RemapIndex(ci));
    end;
end;

procedure TRMMainForm.ZPaintBoxMouseMoveDrawBrushTool(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  ZoomX:=RMDrawTools.GetZoomX(x);
  ZoomY:=RMDrawTools.GetZoomY(y);
  UpdateInfoBarXY(x, y);
  ZoomPaintBox.Invalidate;
end;

procedure TRMMainForm.BrushGrabSelectionClick(Sender: TObject);
var
  w, h, i, j : integer;
  SrcBuf : TPixelBuf;
  SrcPal : TRMPaletteBuf;
  ca : TClipAreaRec;
begin
  w:=RMCoreBase.GetWidth;
  h:=RMCoreBase.GetHeight;

  //get clip area from draw tools
  RMDrawTools.GetClipAreaCoords(ca);
  if ca.status = 0 then
  begin
    ShowMessage('Please use the Select tool to define an area first.');
    exit;
  end;

  //clamp
  if ca.x < 0 then ca.x:=0;
  if ca.y < 0 then ca.y:=0;
  if ca.x2 >= w then ca.x2:=w-1;
  if ca.y2 >= h then ca.y2:=h-1;
  if (ca.x2 < ca.x) or (ca.y2 < ca.y) then
  begin
    ShowMessage('Invalid selection area.');
    exit;
  end;

  //build pixel buffer from core
  SetLength(SrcBuf, w, h);
  for i:=0 to w-1 do
    for j:=0 to h-1 do
      SrcBuf[i][j]:=RMCoreBase.GetPixel(i, j);

  RMCoreBase.Palette.GetPalette(SrcPal);
  RetroBrush.GrabRegion(SrcBuf, w, h, ca.x, ca.y, ca.x2, ca.y2,
    SrcPal, RMCoreBase.Palette.GetPaletteMode,
    RMCoreBase.Palette.GetColorCount);

  SetLength(SrcBuf, 0);
  ShowMessage('Brush grabbed from selection (' +
    IntToStr(RetroBrush.OrigWidth) + 'x' + IntToStr(RetroBrush.OrigHeight) + ').');
end;

procedure TRMMainForm.BrushGrabSpriteClick(Sender: TObject);
var
  w, h, i, j : integer;
  SrcBuf : TPixelBuf;
  SrcPal : TRMPaletteBuf;
begin
  w:=RMCoreBase.GetWidth;
  h:=RMCoreBase.GetHeight;

  SetLength(SrcBuf, w, h);
  for i:=0 to w-1 do
    for j:=0 to h-1 do
      SrcBuf[i][j]:=RMCoreBase.GetPixel(i, j);

  RMCoreBase.Palette.GetPalette(SrcPal);
  RetroBrush.GrabFromPixels(SrcBuf, w, h,
    SrcPal, RMCoreBase.Palette.GetPaletteMode,
    RMCoreBase.Palette.GetColorCount);

  SetLength(SrcBuf, 0);
  ShowMessage('Brush grabbed from sprite (' +
    IntToStr(RetroBrush.OrigWidth) + 'x' + IntToStr(RetroBrush.OrigHeight) + ').');
end;

procedure TRMMainForm.BrushStampToolClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then
  begin
    ShowMessage('No brush captured. Use Brush > Grab from Selection or Grab Entire Sprite first.');
    exit;
  end;
  ClearClipAreaOutline;
  ClearSelectedToolsMenu;
  RMDrawTools.SetDrawTool(DrawShapeBrush);
  UpdateToolSelectionIcons;
end;

procedure TRMMainForm.BrushSetTransColorClick(Sender: TObject);
begin
  RetroBrush.TransColor:=RMCoreBase.GetCurColor1;
  ShowMessage('Brush transparent color set to index ' + IntToStr(RetroBrush.TransColor) + '.');
end;

procedure TRMMainForm.BrushClearClick(Sender: TObject);
begin
  RetroBrush.ClearBrush;
  ShowMessage('Brush cleared.');
  UpdateBrushRadioState;
end;



begin
end.
