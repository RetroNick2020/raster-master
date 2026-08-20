//=============================================================================
// CHANGE LOG (Claude edits - newest first)
//-----------------------------------------------------------------------------
// 2026-08-13  TILED (TMX) EXPORT - use the project's own PNG writer
//   * TmxWriteTileImage was hand rolling a 24 bit TBitmap and colour keying
//     it against a hardcoded clFuchsia. That is the ONLY PNG path in the
//     program that did not go through rwpng, it ignored the file properties
//     settings every other export honours, and if a sprite's own background
//     happened to be fuchsia the whole sheet came out transparent - which
//     displays as an empty tileset with no error at all.
//   * Collection mode now calls SaveFromThumbAsPNG. Atlas mode uses the new
//     BeginAtlas/CopyThumbToImageAt pair, so both share one set of alpha
//     rules with sprite, JSON and sprite sheet export.
//-----------------------------------------------------------------------------
// 2026-08-13  TILED (TMX) EXPORT
//   * Maps > Export > Tiled (TMX): current map or all maps, sprite sheet or
//     image collection. Sprite sheet is listed first and is the default,
//     because it is the tileset shape every TMX runtime can read.
//   * All maps writes ONE shared tileset as an external .tsx plus one .tmx
//     per map. A single map embeds its tileset, so it travels as one file.
//   * rwtmx does the format and holds no LCL reference. The pixels are this
//     unit's job: TmxWriteTileImage is handed to it as a callback and is the
//     only place a TBitmap or TPortableNetworkGraphic appears.
//   * The atlas sheet is built once, in memory, across the per tile calls and
//     saved on the call flagged Finish - reopening a PNG for every tile would
//     be both slow and lossy.
//-----------------------------------------------------------------------------
// 2026-08-11  CLOSED PATHS DID NOT RETURN TO THEIR START
//   * FinishPath(true) now repairs the implicit closing leg before it sets
//     closed. Every leg the user PLOTS goes through SnapTo8, but the leg
//     from the last waypoint back to the first is never plotted, so it was
//     never constrained to the 8 directions and the exported follower did
//     not come back to its start tile.
//   * The geometry lives in mapcore (ClosingLegNeedsCorner / RepairClosingLeg)
//     so the tool and the repair command cannot drift apart.
//   * New Paths -> Fix Closed Paths repairs maps saved before this fix.
//     Surveys first, so it burns no undo level when there is nothing to do.
//-----------------------------------------------------------------------------
// 2026-08-03  MAP LAYERS - phase 4 (editor)
//   * UpdateMapView draws visible layers bottom to top. The checkerboard is
//     still drawn ONCE before the layer loop - it is a map level background,
//     not a per layer one. Drawing it per layer would erase everything
//     underneath and only the top visible layer would ever be seen.
//   * VerifyTileImageList now walks every layer, otherwise deleting a sprite
//     would fix indexes on the active layer only and corrupt the rest.
//   * UpdateMapPreviewImageIcons composites visible layers (still clamped to
//     the first 32x32 tiles - see the note there).
//   * Flip and scroll apply to ALL layers via ForEachLayer. Applying them to
//     the active layer alone would desynchronise layers that are meant to
//     line up.
//   * MenuOpenClick reports why a map failed to load instead of silently
//     doing nothing.
//
// 2026-08-03 16:57 UTC
//   * VerifyTileImageList: FIXED map tile remap on sprite delete for non-square
//     maps. Outer/inner loop bounds had width and height swapped, so a 16x24
//     map only remapped the first 16x16 block (GetMapTile/SetMapTile take
//     (x,y) and silently exit when out of range). Now j walks height, i walks
//     width, matching the drawing loop convention.
//   * UpdateMapPreviewImageIcons: added comment only - no code change. Marks
//     the 32-tile preview clamp as INTENTIONAL so it is not "fixed" later.
//=============================================================================

unit mapeditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,Types,Math,
  ComCtrls, CheckLst, Menus,rmconst,rmthumb,mapcore,rwmap,mapexiportprops,rmcodegen,drawprocs,rmtools,rmclipboard,
  rmconfig, LCLType,setcustommapsize,setcustomtilesize,rmcore,rwtmx,rwpng;

const
  AddImage = 1;
  InsertImage = 2;
  UpdateImage = 3;

  tlModeErase = 0;
  tlModeDraw  = 1;

type
  TMazePos = record x, y : integer; end;

  { TMapEdit }

  TMapEdit = class(TForm)
    GroupBox1: TGroupBox;
    ListView1: TListView;
    MapImageList: TImageList;
    Clear: TMenuItem;
    CloneMap: TMenuItem;
    CopyToClipBoard: TMenuItem;
    CopyLayerToClipBoard: TMenuItem;
    RightTabs: TPageControl;
    TabLayers: TTabSheet;
    TabHitBoxes: TTabSheet;
    TabPaths: TTabSheet;
    PathListView: TListView;
    HitBoxButtonPanel: TPanel;
    BtnHitBoxAdd: TButton;
    BtnHitBoxDel: TButton;
    BtnHitBoxDeleteAll: TButton;
    PathButtonPanel: TPanel;
    BtnPathDelete: TButton;
    BtnPathVisible: TButton;
    BtnPathActive: TButton;
    BtnPathMode: TButton;
    BtnPathRename: TButton;
    PathsMenu: TMenuItem;
    PathToolMenu: TMenuItem;
    MoveToolMenu: TMenuItem;
    LayerPopup: TPopupMenu;
    PopLayerCopy: TMenuItem;
    PopLayerPaste: TMenuItem;
    HitBoxPopup: TPopupMenu;
    PopHitBoxCopy: TMenuItem;
    PopHitBoxPaste: TMenuItem;
    PathPopup: TPopupMenu;
    PopPathCopy: TMenuItem;
    PopPathPaste: TMenuItem;
    PathFinishOpen: TMenuItem;
    PathFinishClosed: TMenuItem;
    MnuMapExpTiledSep: TMenuItem;
    MnuMapExpTiled: TMenuItem;
    TMX_CurrentSheet: TMenuItem;
    TMX_AllSheet: TMenuItem;
    TMX_Sep1: TMenuItem;
    TMX_CurrentColl: TMenuItem;
    TMX_AllColl: TMenuItem;
    PathSep1: TMenuItem;
    PathsFixClosed: TMenuItem;
    PathSep3: TMenuItem;
    PathsDeleteAll: TMenuItem;
    PathSep2: TMenuItem;
    PathsToggle: TMenuItem;
    HitBoxes: TMenuItem;
    HitBoxesAdd: TMenuItem;
    HitBoxesClearAll: TMenuItem;
    HitBoxesDelete: TMenuItem;
    HitBoxesToggle: TMenuItem;
    TransparentToggle: TMenuItem;
    Properties: TMenuItem;
    PasteFromClipBoard: TMenuItem;
    RightVertSplitter: TSplitter;
    StatusBar0: TStatusBar;
    Undo: TMenuItem;
    RedoMenu: TMenuItem;
    SetTileCustomSize: TMenuItem;
    MenuItem15: TMenuItem;
    MenuDeleteAll: TMenuItem;
    ShowTileCustomSize: TMenuItem;
    ShowCustomSize: TMenuItem;
    SetMapCustomSize: TMenuItem;
    MenuPopupNew: TMenuItem;
    MenuPopupDelete: TMenuItem;
    Panel1: TPanel;
    RadioDraw: TRadioButton;
    RadioErase: TRadioButton;
    ReSizeMap256x256: TMenuItem;
    ReSizeMap128x128: TMenuItem;
    TileImageList: TImageList;
    TransTileImageList: TImageList;
    TransTileThumbImageList: TImageList;
    ToolPencilMenu: TMenuItem;
    ToolLineMenu: TMenuItem;
    ToolRectangleMenu: TMenuItem;
    ToolFRectangleMenu: TMenuItem;
    ToolCircleMenu: TMenuItem;
    ToolFCircleMenu: TMenuItem;
    ToolEllipseMenu: TMenuItem;
    ToolFEllipseMenu: TMenuItem;
    ToolPaintMenu: TMenuItem;
    ToolSprayPaintMenu: TMenuItem;
    ToolSelectAreaMenu: TMenuItem;
    ToolGridMenu: TMenuItem;
    ToolFlipMenu: TMenuItem;
    Horizontal: TMenuItem;
    Vertical: TMenuItem;
    ScrollMenu: TMenuItem;
    ScrollRightMenu: TMenuItem;
    ScrollLeftMenu: TMenuItem;
    ScrollUpMenu: TMenuItem;
    ScrollDownMenu: TMenuItem;
    Panel2: TPanel;
    MenuItem10: TMenuItem;
    ExportCArray: TMenuItem;
    ExportPascalArray: TMenuItem;
    ExportHitBoxBasic: TMenuItem;
    ExportHitBoxBasicLN: TMenuItem;
    ExportHitBoxC: TMenuItem;
    ExportHitBoxPascal: TMenuItem;
    //extended compiler export menu items
    MnuMapExpAB, MD_AB, HB_AB, PD_AB : TMenuItem;
    MnuMapExpAC, MD_AC, HB_AC, PD_AC : TMenuItem;
    MnuMapExpAP, MD_AP, HB_AP, PD_AP : TMenuItem;
    MnuMapExpAQB, MD_AQB, HB_AQB, PD_AQB : TMenuItem;
    MnuMapExpBAM, MD_BAM, HB_BAM, PD_BAM : TMenuItem;
    MnuMapExpFBQB, MD_FBQB, HB_FBQB, PD_FBQB : TMenuItem;
    MnuMapExpFB, MD_FB, HB_FB, PD_FB : TMenuItem;
    MnuMapExpFP, MD_FP, HB_FP, PD_FP : TMenuItem;
    MnuMapExpGCC, MD_GCC, HB_GCC, PD_GCC : TMenuItem;
    MnuMapExpGW, MD_GW, HB_GW, PD_GW : TMenuItem;
    MnuMapExpJS, MD_JS, HB_JS, PD_JS : TMenuItem;
    MnuMapExpJSON, MD_JSON, HB_JSON, PD_JSON : TMenuItem;
    MnuMapExpOW, MD_OW, HB_OW, PD_OW : TMenuItem;
    MnuMapExpQB, MD_QB, HB_QB, PD_QB : TMenuItem;
    MnuMapExpQB64, MD_QB64, HB_QB64, PD_QB64 : TMenuItem;
    MnuMapExpQBJS, MD_QBJS, HB_QBJS, PD_QBJS : TMenuItem;
    MnuMapExpQC, MD_QC, HB_QC, PD_QC : TMenuItem;
    MnuMapExpQP, MD_QP, HB_QP, PD_QP : TMenuItem;
    MnuMapExpTB, MD_TB, HB_TB, PD_TB : TMenuItem;
    MnuMapExpTP, MD_TP, HB_TP, PD_TP : TMenuItem;
    MnuMapExpTC, MD_TC, HB_TC, PD_TC : TMenuItem;
    MnuMapExpTMT, MD_TMT, HB_TMT, PD_TMT : TMenuItem;

    MazeMenu: TMenuItem;
    MnuMazeEasy, MnuMazeMedium, MnuMazeHard : TMenuItem;
    MnuMazeSep1, MnuMazeSep2, MnuMazeSep3 : TMenuItem;
    MnuMazeSetWallTile, MnuMazeSetPathTile, MnuMazeSetSolutionTile : TMenuItem;
    MnuMazeSetStart, MnuMazeSetEnd : TMenuItem;
    MnuMazeSolve : TMenuItem;
    MenuItem13: TMenuItem;
    BasicLNMapData: TMenuItem;
    MenuMapProps: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    ExportBasicMapData: TMenuItem;
    MenuNew: TMenuItem;
    OpenDialog1: TOpenDialog;
    ExportMapsPropsMenu: TPopupMenu;
    MapPaintBox: TPaintBox;
    SaveDialog1: TSaveDialog;
    ToolCircleIcon: TImage;
    ToolEllipseIcon: TImage;
    ToolFCircleIcon: TImage;
    ToolFEllipseIcon: TImage;
    ToolFRectangleIcon: TImage;
    ToolGridIcon: TImage;
    ToolHFLIPButton: TButton;
    ToolLineIcon: TImage;
    ToolPaintIcon: TImage;
    ReSize64x64: TMenuItem;
    ReSize128x128: TMenuItem;
    ReSize256x256: TMenuItem;
    ReSizeMap64x64: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem19: TMenuItem;
    TileModeDraw: TMenuItem;
    TileModeErase: TMenuItem;
    SelectedTileImage: TImage;
    MainMenu1: TMainMenu;
    FileMenuItem: TMenuItem;
    MenuItem1: TMenuItem;
    ReSize8x8: TMenuItem;
    ReSize16x16: TMenuItem;
    ReSize32x32: TMenuItem;
    MenuSaveMap: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    ReSizeMap8x8: TMenuItem;
    ReSizeMap16x16: TMenuItem;
    ReSizeMap32x32: TMenuItem;
    MenuItem9: TMenuItem;
    TileListView: TListView;
    MapListView: TListView;
    SelectedTilePanel: TPanel;
    LeftBottomPanel: TPanel;
    MiddlePanel: TPanel;
    RightPanel: TPanel;
    LeftPanel: TPanel;
    ToolPencilIcon: TImage;
    ToolRectangleIcon: TImage;
    ToolScrollDownIcon: TImage;
    ToolScrollLeftIcon: TImage;
    ToolScrollRightIcon: TImage;
    ToolScrollUpIcon: TImage;
    LayerPanel: TPanel;
    LayerButtonPanel: TPanel;
    LayerListBox: TCheckListBox;
    BtnLayerAdd: TButton;
    BtnLayerDel: TButton;
    BtnLayerDup: TButton;
    BtnLayerUp: TButton;
    BtnLayerDown: TButton;
    BtnLayerRename: TButton;
    ToolSelectAreaIcon: TImage;
    ToolSprayPaintIcon: TImage;
    ToolUndoIcon: TImage;
    ToolVFLIPButton: TButton;
    TopMiddlePanel: TPanel;
    MapScrollBox: TScrollBox;
    LeftVertSplitter: TSplitter;
    LeftSplitter: TSplitter;
    RightSplitter: TSplitter;
    TileZoom: TTrackBar;

    procedure CheckBoxDisplayGridChange(Sender: TObject);
    procedure CloneMapClick(Sender: TObject);

    procedure CopyToClipBoardClick(Sender: TObject);
    procedure CopyLayerToClipBoardClick(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure ClearMapClick(Sender: TObject);
    procedure HitBoxesAddClick(Sender: TObject);
    procedure HitBoxesDeleteClick(Sender: TObject);
    procedure HitBoxesToggleClick(Sender: TObject);
    procedure HitBoxesClearAllClick(Sender: TObject);
    procedure TransparentToggleClick(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    //--- path tool. These MUST stay in the published section: the LFM
    //    streamer resolves OnClick names through published RTTI only, and a
    //    handler in public gives "event handler not found" at load time.
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RedoClick(Sender: TObject);
    procedure PathListViewClick(Sender: TObject);
    procedure PathToolMenuClick(Sender: TObject);
    procedure MoveToolMenuClick(Sender: TObject);
    procedure PopLayerCopyClick(Sender: TObject);
    procedure PopLayerPasteClick(Sender: TObject);
    procedure PopHitBoxCopyClick(Sender: TObject);
    procedure PopHitBoxPasteClick(Sender: TObject);
    procedure PopPathCopyClick(Sender: TObject);
    procedure PopPathPasteClick(Sender: TObject);
    procedure PathsToggleClick(Sender: TObject);
    procedure PathFinishOpenClick(Sender: TObject);
    procedure PathFinishClosedClick(Sender: TObject);
    procedure PathsDeleteAllClick(Sender: TObject);
    procedure PathsFixClosedClick(Sender: TObject);
    procedure MenuExportTmxClick(Sender: TObject);
    procedure BtnPathDeleteClick(Sender: TObject);
    procedure BtnPathVisibleClick(Sender: TObject);
    procedure BtnPathActiveClick(Sender: TObject);
    procedure BtnPathModeClick(Sender: TObject);
    procedure BtnPathRenameClick(Sender: TObject);
    procedure MapListViewClick(Sender: TObject);
    procedure MapPaintBoxPaint(Sender: TObject);

    procedure MenuDeleteAllClick(Sender: TObject);

    procedure MenuDeleteClick(Sender: TObject);
    procedure MenuExportBasicLNMapData(Sender: TObject);
    procedure MenuExportBasicMapData(Sender: TObject);
    procedure MenuExportCArray(Sender: TObject);
    procedure MenuExportPascalArray(Sender: TObject);
    procedure MenuExportMapDataLanClick(Sender: TObject);
    procedure MenuExportHitBoxLanClick(Sender: TObject);
    procedure MenuExportPathDataLanClick(Sender: TObject);
    procedure MazeGenerateClick(Sender: TObject);
    procedure MazeSetWallTileClick(Sender: TObject);
    procedure MazeSetPathTileClick(Sender: TObject);
    procedure MazeSetSolutionTileClick(Sender: TObject);
    procedure MazeSetStartClick(Sender: TObject);
    procedure MazeSetEndClick(Sender: TObject);
    procedure MazeSolveClick(Sender: TObject);
    function  MazeCellIsWall(mapx,mapy : integer) : boolean;
    procedure ExportHitBoxBasicClick(Sender: TObject);
    procedure ExportHitBoxBasicLNClick(Sender: TObject);
    procedure ExportHitBoxCClick(Sender: TObject);
    procedure ExportHitBoxPascalClick(Sender: TObject);
    procedure MenuMapPropsClick(Sender: TObject);
    procedure MenuOpenClick(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);


    procedure MenuSaveClick(Sender: TObject);
    procedure PasteFromClipBoardClick(Sender: TObject);
    procedure ReSizeMapClick(Sender: TObject);
    procedure SetMapCustomSizeClick(Sender: TObject);
    procedure SetTileCustomSizeClick(Sender: TObject);
    procedure TileModeDrawClick(Sender: TObject);
    procedure TileModeEraseClick(Sender: TObject);
    procedure RadioDrawClick(Sender: TObject);
    procedure RadioEraseClick(Sender: TObject);
    procedure ReSizeTiles(Sender: TObject);

    procedure LayerListBoxClick(Sender: TObject);
    procedure LayerListBoxItemClick(Sender: TObject; Index: integer);
    procedure BtnLayerAddClick(Sender: TObject);
    procedure BtnLayerDelClick(Sender: TObject);
    procedure BtnLayerDupClick(Sender: TObject);
    procedure BtnLayerUpClick(Sender: TObject);
    procedure BtnLayerDownClick(Sender: TObject);
    procedure BtnLayerRenameClick(Sender: TObject);
    procedure TileListViewClick(Sender: TObject);
    procedure TileZoomChange(Sender: TObject);
    procedure MapScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

    procedure MPaintBoxMouseDownXYX2Y2Tool(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MPaintBoxMouseMoveXYX2Y2Tool(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure MPaintBoxMouseUpXYX2Y2Tool(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MPaintBoxMouseUpXYTool(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MPaintBoxMouseDownXYTool(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MPaintBoxMouseMoveXYTool(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure MPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ToolGridIconClick(Sender: TObject);
    procedure ToolHFLIPButtonClick(Sender: TObject);
    procedure ToolIconClick(Sender: TObject);
    procedure ToolMenuClick(Sender: TObject);
    procedure ToolScrollDownIconClick(Sender: TObject);
    procedure ToolScrollLeftIconClick(Sender: TObject);
    procedure ToolScrollRightIconClick(Sender: TObject);
    procedure ToolScrollUpIconClick(Sender: TObject);
    procedure ToolUndoIconClick(Sender: TObject);
    procedure ToolVFLIPButtonClick(Sender: TObject);


  private

  public
    hpos,vpos : integer;
    CurrentMap : integer;

    //State the TMX image callback carries between its per tile calls. It is
    //handed one tile at a time and so cannot derive the sheet size itself.
    //These sit with the other fields because Object Pascal will not accept a
    //field after a method in the same visibility section (error 3251).
    FTmxPng       : TEasyPNG;
    FTmxAtlas     : boolean;
    FTmxSheetW    : integer;
    FTmxSheetH    : integer;
    FTmxTable     : TTmxTileTable;

    //true while RefreshLayerPanel is rewriting the list, so the list box
    //events do not react to our own edits
    FUpdatingLayerPanel : boolean;
    TileWidth : integer;
    TileHeight : integer;
    CTile      : TileRec;
    CTileBitMap : TBitMap;
    //true from a Ctrl+Left mouse down until the matching mouse up. The move
    //and up handlers test this so a Ctrl drag samples tiles instead of
    //falling through and painting with the tool that happens to be selected.
    TilePickActive : boolean;
    TileMode       : integer;
    DrawTool       : integer;
    RenderDrawToolShape : Boolean;
    ShowHitBoxOverlay   : Boolean;
    ShowTransparent     : Boolean;

    //maze generator state
    MazeWallTile    : TileRec;
    MazePathTile    : TileRec;
    MazeSolutionTile: TileRec;
    MazeWallSet     : Boolean;
    MazePathSet     : Boolean;
    MazeSolutionSet : Boolean;
    MazeStartX, MazeStartY : integer;
    MazeEndX, MazeEndY     : integer;
    MazeStartSet, MazeEndSet : Boolean;
    SelectedHitBox      : integer;
    SelectedPath        : integer;
    ShowPathOverlay     : Boolean;
    //what is being dragged by the Move tool, -1 when idle
    FMoveKindIsPath     : boolean;
    FMoveIndex          : integer;
    FMoveLastX          : integer;
    FMoveLastY          : integer;
    //path currently being plotted, -1 when idle
    FPathEditIndex      : integer;
    //rubber band end point, already snapped to 8 directions
    FPathPreviewX       : integer;
    FPathPreviewY       : integer;
    FPathHasPreview     : boolean;
    FCheckerBmp         : TBitmap;

    FormShowActivate : boolean;

    MapX,MapY,MapX2,MapY2,OldMapX,OldMapY : integer;

    procedure Init;
    function GetMapX(x : integer) : integer;
    function GetMapY(y : integer) : integer;

    procedure ImageListPlotTile(mx,my : integer;var TTile : TileRec);
    procedure ImageListPlotTileTransparent(mx,my : integer;var TTile : TileRec);
    procedure PlotMissingTile(mx,my : integer);
    procedure DrawCheckerboard;
    function  GetColor0TColor : TColor;
    procedure RebuildTransTileThumbImageList;
    procedure ApplyMapZoom(newsize : integer; useAnchor : boolean; anchorX : integer = 0; anchorY : integer = 0);

    procedure SetMapTileMode(tlTileMode : integer);
    procedure SetDrawTool(tool : integer);
    procedure DrawOverLayOnClipArea;
    procedure DrawHitBoxOverlay;
    procedure DrawPathOverlay;
    function  TmxWriteTileImage(const FileName : string; const UID : TGUID;
                ImageIndex : integer; sx, sy : integer;
                Finish : boolean) : boolean;
    procedure UpdatePathListView;
    procedure StartNewPath(tx,ty : integer);
    procedure FinishPath(closeIt : boolean);
    procedure MPaintBoxMouseDownPathTool(Sender: TObject; Button: TMouseButton;
                Shift: TShiftState; X, Y: Integer);
    procedure MPaintBoxMouseMovePathTool(Sender: TObject; Shift: TShiftState;
                X, Y: Integer);
    procedure MPaintBoxMouseDownMoveTool(Sender: TObject; Button: TMouseButton;
                Shift: TShiftState; X, Y: Integer);
    procedure MPaintBoxMouseMoveMoveTool(Sender: TObject; Shift: TShiftState;
                X, Y: Integer);
    procedure MPaintBoxMouseUpMoveTool(Sender: TObject; Button: TMouseButton;
                Shift: TShiftState; X, Y: Integer);
    procedure UpdateHitBoxListView;
    procedure LoadTile(index : integer);
    //Ctrl+Left eyedropper - samples the map cell under the mouse and makes it
    //the active tile. Returns true only when a real tile was picked up.
    function  PickTileAt(x,y : integer) : boolean;
    procedure LoadTilesToTileImageList;
    //Refreshes every per map panel at once. Use THIS rather than calling the
    //three individually - layers, hitboxes and paths all belong to the
    //current map, so anything that swaps or resets the map must refresh all
    //three or one is left showing the previous map's contents.
    //A selection is a transient editing state, but it rides along inside
    //MapPropsRec and so survives a save/load. Call this after loading so a
    //restored rectangle cannot be mistaken for one the user just made.
    procedure AssignShortCuts;
    procedure ClearLoadedSelections;
    //Panels 2 and 3 hold settings rather than mouse position, so they are
    //rewritten whenever something changes rather than on every mouse move.
    procedure UpdateStatusSettings;
    procedure RefreshMapPanels;
    procedure RefreshLayerPanel;
    function  LayerRowToIndex(row : integer) : integer;
    function  LayerIndexToRow(layer : integer) : integer;
    procedure VerifyTileImageList;
    procedure ApplyToAllLayers(op,x,y,x2,y2 : integer);

    procedure UpdateTileView;
    procedure UpdateCurrentTile;
    procedure UpdateMapInfo(x,y : integer);
    procedure UpdateInfoBar;

    procedure UpdateMapView;
    Procedure UpdateMapListView;
    procedure UpdatePageSize;
    procedure DrawGrid;
    Procedure LoadResourceIcons;
    Procedure UpdateToolSelectionIcons;
    procedure ClearCheckedMenus;
    procedure UpdateMenus;
    procedure UpdateEditMenus;

    function ExportTextFileToClipboard(Sender: TObject) : boolean;

    procedure ExportHitBoxes(filename : string; lan : integer);
    procedure ExportPathData(filename : string; lan : integer);

    procedure MapPreviewPlotTile(MPCanvas : TCanvas;mx,my : integer;var TTile : TileRec);
    procedure MapPreviewPlotTileTransparent(MPCanvas : TCanvas;mx,my : integer;var TTile : TileRec);
    Procedure UpdateMapPreviewImageIcons(MapIndex,ImageAction : integer);

    procedure DeleteAll;

  end;

var
  MapEdit: TMapEdit;

implementation

uses rmmain;

{$R *.lfm}

const
  //Path tool id. Deliberately outside the rmtools DrawShape range so it can
  //never collide with a sprite editor tool.
  MapToolPath = 100;
  //Drag a whole hitbox or path. A dedicated tool rather than a modifier,
  //so it can never be confused with drawing over a hitbox.
  MapToolMove = 101;

  //operations that must affect every layer, not just the active one
  mlopHFlip       = 0;
  mlopVFlip       = 1;
  mlopScrollLeft  = 2;
  mlopScrollRight = 3;
  mlopScrollUp    = 4;
  mlopScrollDown  = 5;

{ TMapEdit }

procedure DrawTileCB(x,y,index,mode : integer);
var
  TT : TileRec;
begin
 if mode = 1 then
 begin
   if MapEdit.TileMode = tlModeErase then
   begin
     TT.ImageIndex:=TileClear;
     MapCoreBase.SetMapTile(MapCoreBase.GetCurrentMap,x,y,TT);
   end
   else
   begin
     MapCoreBase.SetMapTile(MapCoreBase.GetCurrentMap,x,y,MapEdit.CTile);
   end;
 end
 else
 begin
   if MapEdit.ShowTransparent then
     MapEdit.ImageListPlotTileTransparent(x,y,MapEdit.CTile)
   else
     MapEdit.ImageListPlotTile(x,y,MapEdit.CTile);
 end;
end;

function GetTileTB(x,y : integer) : integer;
var
  TT : TileRec;
begin
 MapCoreBase.GetMapTile(MapCoreBase.GetCurrentMap,x,y,TT);
 result:=TT.ImageIndex;
end;

procedure TMapEdit.FormCreate(Sender: TObject);
begin
 CTileBitmap:=TBitMap.Create;
 FormShowActivate:=false;
 LoadResourceIcons;
 SetDrawPixelProc(@DrawTileCB);
 SetGetPixelProc(@GetTileTB);
 Init;
end;

procedure TMapEdit.Init;
  //(layer panel state is set up before anything can repaint)
var
  i, j : integer;
begin
 SetMapTileMode(tlModeDraw);  //draw
 SetDrawTool(DrawShapePencil);
 CurrentMap:=MapCoreBase.GetCurrentMap;
 MapCoreBase.SetZoomSize(CurrentMap,1);
 TileZoom.Position:=MapCoreBase.GetZoomSize(CurrentMap);

 MapCoreBase.SetMapTileSize(CurrentMap,32,32);

 TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
 TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);
 CTile.ImageIndex:=TileMissing;
 LoadTile(0);

 //Ctrl+Left tile picker starts idle
 TilePickActive:=false;

 MapX:=0;
 MapY:=0;
 MapX2:=0;
 MapY2:=0;
 OldMapX:=-1;
 OldMapY:=-1;

 RenderDrawToolShape:=False;
 ShowHitBoxOverlay:=True;
 ShowTransparent:=False;

 //maze defaults
 MazeWallTile.ImageIndex:=0;
 FillChar(MazeWallTile.ImageUID, sizeof(TGUID), 0);
 MazePathTile.ImageIndex:=-1;
 MazeSolutionTile.ImageIndex:=-1;
 MazeWallSet:=true;   //tile 0 is always available
 MazePathSet:=false;
 MazeSolutionSet:=false;
 MazeStartSet:=false;
 MazeEndSet:=false;
 SelectedHitBox:=-1;
 SelectedPath:=-1;
 ShowPathOverlay:=True;
 FPathEditIndex:=-1;
 FPathHasPreview:=false;
 FMoveIndex:=-1;

 // create large checkerboard bitmap once for fast tiling
 FCheckerBmp:=TBitmap.Create;
 FCheckerBmp.SetSize(256, 256);
 FCheckerBmp.Canvas.Brush.Color:=clWhite;
 FCheckerBmp.Canvas.FillRect(0, 0, 256, 256);
 FCheckerBmp.Canvas.Brush.Color:=RGBToColor(192, 192, 192);
 for i:=0 to 15 do
   for j:=0 to 15 do
     if ((i + j) mod 2) = 0 then
       FCheckerBmp.Canvas.FillRect(i*16, j*16, (i+1)*16, (j+1)*16);
 UpdateToolSelectionIcons;
 UpdateEditMenus;

// MapCoreBase.SetCurrentMap(MapCoreBase.GetMapCount-1);
//  CurrentMap:=MapCoreBase.GetCurrentMap;
  TileMode:=tlModeDraw; //draw
  MapCoreBase.SetMapTileMode(CurrentMap,TileMode); // we set to draw because the copied data from map 0 may be in erase mode

//  TileZoom.Position:=4;
//  MapCoreBase.SetZoomSize(CurrentMap,TileZoom.Position);

  UpdateMapListView;
  UpdatePageSize;
  MapScrollBox.HorzScrollBar.Position:=0;
  MapScrollBox.VertScrollBar.Position:=0;
  SetDrawTool(DrawShapePencil);
//  UpdateToolSelectionIcons;
  UpdateMenus;
//  UpdateEditMenus;
  //all three panels, not just the hitboxes - Delete All comes through here
  RefreshMapPanels;
  AssignShortCuts;
  MapPaintBox.Invalidate;

end;

procedure TMapEdit.FormDestroy(Sender: TObject);
begin
  CTileBitmap.Free;
end;

procedure TMapEdit.FormShow(Sender: TObject);
begin
  LoadTilesToTileImageList;
  VerifyTileImageList;

  if CTile.ImageIndex = TileMissing then
  begin
    LoadTile(0);     // first time opening MApEdit Window
  end
  else
  begin
    LoadTile(CTile.ImageIndex);   // Follow ScrollUpMenu open windows - reload current tile incase it was edited
  end;

  UpdateCurrentTile;
  UpdateMapListView;
  RefreshMapPanels;

  //Zoom and scroll are stored PER MAP in MapPropsRec, and therefore travel
  //with the project file. hpos/vpos are form level leftovers from the last
  //time this window was closed, so using them meant a freshly opened project
  //inherited the previous project's view. Take the values from the map.
  //Suppress OnChange: ApplyMapZoom deliberately has no early exit when the
  //value is unchanged, and it recomputes the scroll position - which would
  //undo the restore a few lines below.
  TileZoom.OnChange:=nil;
  TileZoom.Position:=MapCoreBase.GetZoomSize(CurrentMap);
  TileZoom.OnChange:=@TileZoomChange;
  TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
  TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);

  MapPaintBox.Width:=0;   //this hack updated the scrollbars properly after the 2nd and following attempts
  MapPaintBox.Height:=0;
  MapPaintBox.Invalidate;
  MapPaintBox.Width:=MapCoreBase.GetZoomMapPageWidth(CurrentMap)+1;    //do not remove the +1 - hack to display ScrollRightMenu and bottom corner of grid
  MapPaintBox.Height:=MapCoreBase.GetZoomMapPageHeight(CurrentMap)+1;
  MapPaintBox.Invalidate;  //forces a paint which draws the map

  //set AFTER the paint box has been resized, or the scroll bar has no range
  //yet and the position is silently clamped to zero
  MapScrollBox.HorzScrollBar.Position:=MapCoreBase.GetMapScrollHorizPos(CurrentMap);
  MapScrollBox.VertScrollBar.Position:=MapCoreBase.GetMapScrollVertPos(CurrentMap);

  FormShowActivate:=true; //this is going to also trigger an onfocus event - letting event handler know it was because of onopen
end;

procedure TMapEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 hpos:=MapScrollBox.HorzScrollBar.Position;
 vpos:=MapScrollBox.VertScrollBar.Position;

 //store against the map too, so the position survives a save/load rather
 //than only surviving until the app closes
 MapCoreBase.SetMapScrollHorizPos(CurrentMap,hpos);
 MapCoreBase.SetMapScrollVertPos(CurrentMap,vpos);
end;

procedure TMapEdit.FormActivate(Sender: TObject);
begin
  if FormShowActivate then
  begin
    FormShowActivate:=false;  //next on focus will be real onfocus
  end;

  ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);

  LoadTilesToTileImageList;
  VerifyTileImageList;

//  if CTile.ImageIndex > (ImageThumbBase.GetCount-1) then  //check if the CTile has been deleted
//  begin
//    CTile.ImageIndex:=0;  //set it to the first tile/sprite
//  end;

  if ImageThumbBase.FindUID(CTile.ImageUID) = -1 then //check if current tile was deleted
  begin
    CTile.ImageIndex:=TileMissing;
  end;

  if CTile.ImageIndex = TileMissing then
  begin
     LoadTile(0);     // first time opening MApEdit Window
  end
  else
  begin
    LoadTile(CTile.ImageIndex);   // Follow ScrollUpMenu open windows - reload current tile incase it was edited
  end;
  UpdateCurrentTile;
  UpdateTileView;
  if ShowTransparent then
    RebuildTransTileThumbImageList;
  UpdateMapListView;  //if new project is open or inserted - we need to update maplist view
  UpdateMenus;
  UpdateEditMenus;
  UpdateToolSelectionIcons;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.SetDrawTool(tool : integer);
begin
  //switching away mid path would leave it half plotted and unreachable
  if (DrawTool = MapToolPath) and (tool <> MapToolPath) then FinishPath(false);

  DrawTool:=tool;
  MapCoreBase.SetMapDrawTool(MapCoreBase.GetCurrentMap,DrawTool);

  //MapToolPath appears in neither the menu case nor the icon case, so these
  //two calls are what actually deselect the previous tool in both places.
  //Guarded because Init calls SetDrawTool, and that can run before the LFM
  //has streamed the menu items and tool icons.
  if PathToolMenu <> nil then
  begin
    UpdateMenus;
    UpdateToolSelectionIcons;
    UpdateStatusSettings;
  end;
end;

function TMapEdit.GetMapX(x : integer) : integer;
begin
  result:=x div TileWidth;
end;

function TMapEdit.GetMapY(y : integer) : integer;
begin
  result:=y div TileHeight;
end;

procedure TMapEdit.CheckBoxDisplayGridChange(Sender: TObject);
begin
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.CloneMapClick(Sender: TObject);
begin
  MapCoreBase.CloneMap;
  MapCoreBase.SetCurrentMap(MapCoreBase.GetMapCount-1);
  CurrentMap:=MapCoreBase.GetCurrentMap;

  UpdateMapListView;
  RefreshMapPanels;   //the clone has its own layers, hitboxes and paths
  MapScrollBox.HorzScrollBar.Position:=0;
  MapScrollBox.VertScrollBar.Position:=0;
  MapPaintBox.Invalidate;
  ShowMessage('Map Cloned!');
end;

procedure TMapEdit.CopyToClipBoardClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
 MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
 MapCoreBase.CopyToClipBoard(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2);
end;

//Copies the current layer only. Paste puts it on whatever layer is current at
//the destination, so a layer can be moved onto a different layer or map.
//With no selection active GetMapClipAreaCoords returns the whole map, so this
//covers both "entire layer" and "the selected part of it".
procedure TMapEdit.CopyLayerToClipBoardClick(Sender: TObject);
var
  ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapCoreBase.CopyLayerToClipBoard(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2);
end;

procedure TMapEdit.PasteFromClipBoardClick(Sender: TObject);
var
  ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  //paste now writes every layer, so it needs an undo snapshot like any other
  //edit - without this a paste was unrecoverable
  MapCoreBase.CopyToUndo(MapCoreBase.GetCurrentMap);
  MapCoreBase.PasteFromClipboard(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2);
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ImageListPlotTile(mx,my : integer;var TTile : TileRec);
var
  gx,gy : integer;
begin
 gx:=mx*TileWidth;
 gy:=my*TileHeight;
 TileImageList.Draw(MapPaintBox.Canvas,gx,gy,TTile.ImageIndex,true);
end;

procedure TMapEdit.PlotMissingTile(mx,my : integer);
var
  gx,gy : integer;
begin
 gx:=mx*TileWidth;
 gy:=my*TileHeight;

 //red circle on white background
 MapPaintBox.Canvas.Brush.Color:=clWhite;
 MapPaintBox.Canvas.FillRect(gx,gy,gx+TileWidth,gy+TileHeight);
 MapPaintBox.Canvas.Brush.Color:=clRed;
 MapPaintBox.Canvas.Ellipse(gx,gy,gx+TileWidth,gy+TileHeight);
end;

function TMapEdit.GetColor0TColor : TColor;
begin
  Result:=RGBToColor(RMCoreBase.Palette.GetRed(0),
                     RMCoreBase.Palette.GetGreen(0),
                     RMCoreBase.Palette.GetBlue(0));
end;

procedure TMapEdit.RebuildTransTileThumbImageList;
var
  i, x, y, aw, ah : integer;
  CheckBmp, SpriteBmp, TransBmp : TBitmap;
begin
  //NOTE: do NOT sync CopyCoreToIndexImage here - callers must sync at
  //safe points where the core buffer matches the current image
  TransTileThumbImageList.Clear;
  TransTileThumbImageList.Width:=128;
  TransTileThumbImageList.Height:=128;

  //NOTE: bitmaps must be created fresh for every image - reusing one TBitmap
  //with Transparent=True across ImageList.Add calls produces stale icons
  //after the first entry
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
    TransTileThumbImageList.Add(CheckBmp, nil);

    SpriteBmp.Free;
    TransBmp.Free;
    CheckBmp.Free;
  end;

  //rebind and force the listview to re-read every icon
  TileListView.LargeImages:=TransTileThumbImageList;
  TileListView.LargeImagesWidth:=128;
  for i:=0 to TileListView.Items.Count-1 do
    TileListView.Items[i].ImageIndex:=TileListView.Items[i].ImageIndex;
  TileListView.Invalidate;
end;

procedure TMapEdit.DrawCheckerboard;
var
  pw, ph, x, y : integer;
begin
  pw:=MapCoreBase.GetMapWidth(CurrentMap) * TileWidth;
  ph:=MapCoreBase.GetMapHeight(CurrentMap) * TileHeight;

  // tile the 256x256 checkerboard bitmap across the map area
  y:=0;
  while y < ph do
  begin
    x:=0;
    while x < pw do
    begin
      MapPaintBox.Canvas.Draw(x, y, FCheckerBmp);
      inc(x, 256);
    end;
    inc(y, 256);
  end;
end;

procedure TMapEdit.ImageListPlotTileTransparent(mx,my : integer;var TTile : TileRec);
var
  gx, gy : integer;
begin
  if (TTile.ImageIndex < 0) or (TTile.ImageIndex >= TransTileImageList.Count) then exit;
  gx:=mx * TileWidth;
  gy:=my * TileHeight;
  TransTileImageList.Draw(MapPaintBox.Canvas, gx, gy, TTile.ImageIndex);
end;

procedure TMapEdit.TransparentToggleClick(Sender: TObject);
var
  i : integer;
begin
  ShowTransparent:=not ShowTransparent;
  UpdateStatusSettings;
  TransparentToggle.Checked:=ShowTransparent;

  if ShowTransparent then
    RebuildTransTileThumbImageList
  else
  begin
    TileListView.LargeImages:=RMMainForm.ImageList1;
    TileListView.LargeImagesWidth:=128;
    for i:=0 to TileListView.Items.Count-1 do
      TileListView.Items[i].ImageIndex:=TileListView.Items[i].ImageIndex;
    TileListView.Invalidate;
  end;
  TileListView.Refresh;

  UpdateCurrentTile;
  MapPaintBox.Invalidate;
  for i:=0 to MapCoreBase.GetMapCount-1 do
    UpdateMapPreviewImageIcons(i, UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ClearMapClick(Sender: TObject);
begin
  MapCoreBase.ClearMap(CurrentMap,TileClear);
  VerifyTileImageList;
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.HitBoxesAddClick(Sender: TObject);
var
  ca : MapClipAreaRec;
begin
  //The clip status flag lives in MapPropsRec and is therefore SAVED with the
  //map, so a project reopens with the selection from whenever it was saved.
  //Testing the flag alone let a hit box be added from that stale rectangle
  //without the user ever making a selection - so require the Select Area
  //tool to actually be the active tool as well.
  if DrawTool <> DrawShapeClip then
  begin
    ShowMessage('Please choose the Select Area tool and mark the hit box area first.');
    exit;
  end;

  if MapCoreBase.GetMapClipStatus(CurrentMap) = 0 then
  begin
    ShowMessage('Please use the Select Area tool to mark the hit box area first.');
    exit;
  end;

  MapCoreBase.GetMapClipAreaCoords(CurrentMap,ca);
  MapCoreBase.AddHitBox(CurrentMap,ca.x,ca.y,ca.x2,ca.y2);
  ShowHitBoxOverlay:=True;
  HitBoxesToggle.Checked:=True;
  UpdateHitBoxListView;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.HitBoxesDeleteClick(Sender: TObject);
var
  item : TListItem;
  hbindex : integer;
begin
  if ListView1.SelCount > 0 then
  begin
    item:=ListView1.Selected;
    if item <> nil then
    begin
      hbindex:=item.Index;
      MapCoreBase.DeleteHitBox(CurrentMap,hbindex);
      SelectedHitBox:=-1;
      UpdateHitBoxListView;
      MapPaintBox.Invalidate;
    end;
  end
  else
  begin
    ShowMessage('Please select a hit box from the list to delete.');
  end;
end;

Procedure TMapEdit.DrawGrid;
var
  x,y : integer;
begin
  MapPaintBox.Canvas.Brush.Style:=bsClear;
  MapPaintBox.Canvas.Pen.Style := psSolid;
  MapPaintBox.Canvas.Pen.Mode :=pmXor;
  MapPaintBox.Canvas.Pen.Width :=1;
  MapPaintBox.Canvas.Pen.Color := clWhite;

  x:=0;
  While x <= MapPaintBox.Width do
  begin
    MapPaintBox.Canvas.Line(x,0,x,MapPaintBox.Height);
    inc(x,TileWidth);
  end;
  y:=0;
  While y <= MapPaintBox.Height do
  begin
    MapPaintBox.Canvas.Line(0,y,MapPaintBox.Width,y);
    inc(y,TileHeight);
  end;
  MapPaintBox.Canvas.Pen.Mode :=pmCopy;
end;

Procedure  TMapEdit.DrawOverLayOnClipArea;
var
  ca : MapClipAreaRec;
begin
  MapPaintBox.Canvas.Brush.Style:=bsClear;
  MapPaintBox.Canvas.Pen.Color:=clYellow;
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapPaintBox.Canvas.Rectangle(ca.x*TileWidth-2,ca.y*TileHeight-2,(ca.x2+1)*TileWidth+3,(ca.y2+1)*TileHeight+3);
  MapPaintBox.Canvas.Rectangle(ca.x*TileWidth-3,ca.y*TileHeight-3,(ca.x2+1)*TileWidth+4,(ca.y2+1)*TileHeight+4);
end;


//=============================================================================
// PATH LINES - editor
//
// Plot with left click. Each new point snaps to one of 8 directions from the
// previous one, so every exported segment is a signed add at runtime.
// Right click closes the loop and finishes; Esc finishes the path open.
//=============================================================================

//Centre of a tile in paint box pixels. Paths are drawn centre to centre so a
//segment reads as "walk from this tile to that one".
function PathTileCX(tx,tw : integer) : integer;
begin
  PathTileCX:=tx*tw + tw div 2;
end;

function PathTileCY(ty,th : integer) : integer;
begin
  PathTileCY:=ty*th + th div 2;
end;

//Esc ends a path WITHOUT closing it - a bird's flight path should not loop
//back on itself. Right click is the "close the loop" gesture.
//=============================================================================
// KEYBOARD SHORTCUTS
//
// Ctrl combinations go on the menu items, assigned in AssignShortCuts using
// ShortCut(VK_x,[ssCtrl]) rather than the raw integers the LFM stores.
//
// Single letter tool keys live here instead, because a menu shortcut is
// global to the form and would fire while the user is typing in a list or
// edit box.
//=============================================================================
procedure TMapEdit.RedoClick(Sender: TObject);
begin
  MapCoreBase.Redo(CurrentMap);
  RefreshMapPanels;
  UpdatePageSize;
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.AssignShortCuts;
begin
  if Undo = nil then exit;        //before the LFM has streamed

  MenuNew.ShortCut            := ShortCut(VK_N,[ssCtrl]);
  MenuItem1.ShortCut          := ShortCut(VK_O,[ssCtrl]);   //Open
  MenuSaveMap.ShortCut        := ShortCut(VK_S,[ssCtrl]);
  Undo.ShortCut               := ShortCut(VK_Z,[ssCtrl]);
  RedoMenu.ShortCut           := ShortCut(VK_Y,[ssCtrl]);
  CopyToClipBoard.ShortCut    := ShortCut(VK_C,[ssCtrl]);
  CopyLayerToClipBoard.ShortCut := ShortCut(VK_C,[ssCtrl,ssShift]);
  PasteFromClipBoard.ShortCut := ShortCut(VK_V,[ssCtrl]);
  MenuMapProps.ShortCut       := ShortCut(VK_P,[ssCtrl]);
  CloneMap.ShortCut           := ShortCut(VK_D,[ssCtrl]);
end;

procedure TMapEdit.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  handled : boolean;
begin
  //Esc ends a path without closing it - this must stay ahead of the tool
  //keys so it works no matter what else has focus
  if (Key = VK_ESCAPE) and (FPathEditIndex >= 0) then
  begin
    FinishPath(false);
    Key:=0;
    exit;
  end;

  //never steal a key from something the user is typing into
  if (ActiveControl is TCustomEdit) or (ActiveControl is TCustomComboBox) then exit;

  //leave Ctrl and Alt to the menu shortcuts
  if (ssCtrl in Shift) or (ssAlt in Shift) then exit;

  //ToolMenuClick identifies the tool from Sender.Name, so it must be given
  //the real menu item - passing nil would dereference a nil pointer
  handled:=true;
  case Key of
    VK_P : ToolMenuClick(ToolPencilMenu);
    VK_L : ToolMenuClick(ToolLineMenu);
    VK_R : if ssShift in Shift then ToolMenuClick(ToolFRectangleMenu)
                               else ToolMenuClick(ToolRectangleMenu);
    VK_C : if ssShift in Shift then ToolMenuClick(ToolFCircleMenu)
                               else ToolMenuClick(ToolCircleMenu);
    VK_E : if ssShift in Shift then ToolMenuClick(ToolFEllipseMenu)
                               else ToolMenuClick(ToolEllipseMenu);
    VK_F : ToolMenuClick(ToolPaintMenu);
    VK_S : ToolMenuClick(ToolSprayPaintMenu);
    VK_M : ToolMenuClick(ToolSelectAreaMenu);
    VK_A : PathToolMenuClick(nil);      //A for pAth - P is taken by pencil
    VK_G : ToolGridIconClick(nil);
  else
    handled:=false;
  end;

  if handled then Key:=0;
end;

procedure TMapEdit.PathListViewClick(Sender: TObject);
begin
  if PathListView.Selected = nil then SelectedPath:=-1
                                 else SelectedPath:=PathListView.Selected.Index;
  MapPaintBox.Invalidate;
end;

//Menu only for now, as agreed - this is the testing entry point.
procedure TMapEdit.PathToolMenuClick(Sender: TObject);
begin
  SetDrawTool(MapToolPath);   //also unchecks every other tool
  RightTabs.ActivePage:=TabPaths;
end;

//=============================================================================
// LIST VIEW COPY / PASTE
//
// Pasting into the SAME map offsets a hitbox or path by a tile so the copy is
// visibly distinct, and names a layer "... Copy". Pasting into a DIFFERENT map
// keeps the original position and names the layer "... Copy from Map N".
//=============================================================================

procedure TMapEdit.PopLayerCopyClick(Sender: TObject);
begin
  MapCoreBase.CopyLayerClip(CurrentMap,MapCoreBase.GetCurrentLayer(CurrentMap));
end;

procedure TMapEdit.PopLayerPasteClick(Sender: TObject);
var
  nl : integer;
begin
  if not MapCoreBase.HasLayerClip then
  begin
    ShowMessage('No layer has been copied yet.');
    exit;
  end;

  MapCoreBase.CopyToUndo(CurrentMap);
  nl:=MapCoreBase.PasteLayerClip(CurrentMap);
  if nl < 0 then
  begin
    ShowMessage('This map already has the maximum of '+IntToStr(MaxMapLayers)+' layers.');
    exit;
  end;

  MapCoreBase.SetCurrentLayer(CurrentMap,nl);
  RefreshMapPanels;
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.PopHitBoxCopyClick(Sender: TObject);
begin
  if not MapCoreBase.IsValidHitBox(CurrentMap,SelectedHitBox) then
  begin
    ShowMessage('Select a hit box first.');
    exit;
  end;
  MapCoreBase.CopyHitBoxClip(CurrentMap,SelectedHitBox);
end;

procedure TMapEdit.PopHitBoxPasteClick(Sender: TObject);
var
  nh : integer;
begin
  if not MapCoreBase.HasHitBoxClip then
  begin
    ShowMessage('No hit box has been copied yet.');
    exit;
  end;

  MapCoreBase.CopyToUndo(CurrentMap);
  nh:=MapCoreBase.PasteHitBoxClip(CurrentMap);
  if nh < 0 then
  begin
    ShowMessage('This map already has the maximum of '+IntToStr(MaxHitBoxes)+' hit boxes.');
    exit;
  end;

  SelectedHitBox:=nh;
  ShowHitBoxOverlay:=true;
  HitBoxesToggle.Checked:=true;
  RefreshMapPanels;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.PopPathCopyClick(Sender: TObject);
begin
  if not MapCoreBase.IsValidPath(CurrentMap,SelectedPath) then
  begin
    ShowMessage('Select a path first.');
    exit;
  end;
  MapCoreBase.CopyPathClip(CurrentMap,SelectedPath);
end;

procedure TMapEdit.PopPathPasteClick(Sender: TObject);
var
  np : integer;
begin
  if not MapCoreBase.HasPathClip then
  begin
    ShowMessage('No path has been copied yet.');
    exit;
  end;

  MapCoreBase.CopyToUndo(CurrentMap);
  np:=MapCoreBase.PastePathClip(CurrentMap);
  if np < 0 then
  begin
    ShowMessage('This map already has the maximum of '+IntToStr(MaxPaths)+' paths.');
    exit;
  end;

  SelectedPath:=np;
  ShowPathOverlay:=true;
  PathsToggle.Checked:=true;
  RefreshMapPanels;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.MoveToolMenuClick(Sender: TObject);
begin
  SetDrawTool(MapToolMove);   //also unchecks every drawing tool
  //both overlays on, or there would be nothing visible to grab
  ShowPathOverlay:=true;
  PathsToggle.Checked:=true;
  ShowHitBoxOverlay:=true;
  HitBoxesToggle.Checked:=true;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.PathsToggleClick(Sender: TObject);
begin
  ShowPathOverlay:=PathsToggle.Checked;
  UpdateStatusSettings;
  MapPaintBox.Invalidate;
end;

//Menu equivalents of the Esc / right click gestures, so the two ways to end
//a path are discoverable rather than something you have to already know.
procedure TMapEdit.PathFinishOpenClick(Sender: TObject);
begin
  FinishPath(false);
end;

procedure TMapEdit.PathFinishClosedClick(Sender: TObject);
begin
  FinishPath(true);
end;

//=============================================================================
// FIX CLOSED PATHS
//
// Repairs maps saved before the closing leg was constrained. Walks every
// closed path on the current map and appends the corner waypoint that makes
// its closing leg legal.
//
// Surveys before it changes anything, so a map with nothing wrong costs no
// undo level and shows no confirmation prompt.
//=============================================================================
//=============================================================================
// TILED (TMX) EXPORT
//
// rwtmx writes the format and never touches a pixel - it asks for one tile
// image at a time through this callback. That split is what lets rwtmx build
// and be tested with no LCL present.
//
// Atlas mode calls here once per tile with a destination inside the sheet and
// the same FileName every time, so the sheet is held in FTmxSheet across the
// run and written on the call flagged Finish. Collection mode passes 0,0 and
// its own name each time, and saves immediately.
//=============================================================================
function TMapEdit.TmxWriteTileImage(const FileName : string; const UID : TGUID;
           ImageIndex : integer; sx, sy : integer;
           Finish : boolean) : boolean;
var
  img : integer;
  PngRGBA : PngRGBASettingsRec;
begin
  TmxWriteTileImage:=false;

  //The UID identifies the image itself, the index only says where it sat.
  //Resolve by UID first: if the user has inserted or deleted images since the
  //map was drawn, the stored index points at the wrong art but the UID still
  //finds the right one. The index is only a fallback.
  img:=ImageThumbBase.FindUID(UID);
  if img < 0 then img:=ImageIndex;
  if (img < 0) or (img >= ImageThumbBase.GetCount) then exit;

  //Same transparency settings as every other PNG this program writes. The
  //first version of this routine colour keyed a 24 bit TBitmap against a
  //hardcoded fuchsia, which is how a tileset ends up fully transparent - and
  //an invisible tileset looks exactly like a broken one, with no error.
  PngRGBA:=Default(PngRGBASettingsRec);
  rmconfigbase.GetProps(PngRGBA);

  try
    if not FTmxAtlas then
    begin
      //one sprite, one file - rwpng already does exactly this job
      TmxWriteTileImage:=SaveFromThumbAsPNG(img,FileName,PngRGBA) = 0;
      exit;
    end;

    //atlas: one surface held across the per tile calls, saved on the last
    if FTmxPng = nil then
    begin
      FTmxPng:=TEasyPNG.Create;
      FTmxPng.BeginAtlas(FTmxSheetW,FTmxSheetH);
    end;

    FTmxPng.CopyThumbToImageAt(img,sx,sy,PngRGBA);

    if Finish then
    begin
      FTmxPng.SaveToFile(FileName);
      FreeAndNil(FTmxPng);
    end;

    TmxWriteTileImage:=true;
  except
    //a failed write must be reported, not raised through rwtmx
    FreeAndNil(FTmxPng);
    TmxWriteTileImage:=false;
  end;
end;

//Menu Tag: 0 current+sheet, 1 all+sheet, 2 current+collection, 3 all+collection
procedure TMapEdit.MenuExportTmxClick(Sender: TObject);
var
  opt  : TmxOptionsRec;
  res  : TmxResultRec;
  choice,idx,cols,rows,missing : integer;
  msg  : string;
begin
  //NOTE: do not call this local 'Tag'. TComponent.Tag is in scope inside any
  //TForm method, so a local of that name is a duplicate identifier (5002),
  //not a shadow - the same trap as TControl.Changed.
  choice:=0;
  if Sender is TMenuItem then choice:=(Sender as TMenuItem).Tag;

  //these are records with string fields, so Default() rather than FillChar -
  //FillChar would zero the string pointers without releasing them
  opt:=Default(TmxOptionsRec);
  res:=Default(TmxResultRec);
  cols:=0;
  rows:=0;
  missing:=0;

  TmxDefaultOptions(opt);
  if choice >= 2 then opt.Mode:=TmxModeCollection
                 else opt.Mode:=TmxModeAtlas;

  //all maps -> one shared tileset in a .tsx, so it is not duplicated into
  //every .tmx. A single map embeds it and travels as one file.
  if (choice = 1) or (choice = 3) then
  begin
    idx:=-1;
    opt.Location:=TmxTilesetExternal;
  end
  else
  begin
    idx:=CurrentMap;
    opt.Location:=TmxTilesetEmbedded;
  end;

  SaveDialog1.Filter:='Tiled Map|*.tmx|All Files|*.*';
  SaveDialog1.DefaultExt:='.tmx';
  if not SaveDialog1.Execute then exit;

  //the callback needs to know the shape up front - it is handed one tile at a
  //time and cannot work out the sheet size from that
  FTmxAtlas:=(opt.Mode = TmxModeAtlas);
  FreeAndNil(FTmxPng);

  if FTmxAtlas then
  begin
    //size the sheet the same way rwtmx lays it out, or tiles would land
    //outside it
    //the survey's missing count is discarded here - TmxExport reports the
    //authoritative one afterwards. Passing 'cols' as the scratch would work
    //but reads like a bug.
    if not TmxBuildTileTable(MapCoreBase,idx,FTmxTable,missing) then
    begin
      ShowMessage('This map uses more distinct tiles than the exporter supports.');
      exit;
    end;
    TmxAtlasLayout(FTmxTable.Count,
                   MapCoreBase.GetMapTileWidth(CurrentMap),
                   MapCoreBase.GetMapTileHeight(CurrentMap),
                   cols,rows,FTmxSheetW,FTmxSheetH);
  end;

  if not TmxExport(MapCoreBase,idx,SaveDialog1.FileName,opt,
                   @TmxWriteTileImage,res) then
  begin
    FreeAndNil(FTmxPng);
    case res.Status of
      TmxNoTiles      : ShowMessage('There is nothing to export - every tile on this map is empty.');
      TmxImageFailed  : ShowMessage('The tile images could not be written.'+sLineBreak+sLineBreak+
                                    'Nothing was left on disk for at least one tile, so the '+
                                    'export was stopped rather than leaving a tileset that '+
                                    'points at files which are not there.'+sLineBreak+sLineBreak+
                                    'Check there is room on the disk and that the folder is writable.');
    else
      ShowMessage('The export could not be written.'+sLineBreak+
                  'Check the folder is writable.');
    end;
    exit;
  end;
  FreeAndNil(FTmxPng);

  //Report the folder and every file name. Tiled resolves a tileset's image
  //relative to the .tsx and the .tsx relative to the .tmx, so when something
  //cannot be found the first question is always where each piece actually
  //landed - this answers it without hunting through Explorer.
  msg:='Exported '+IntToStr(res.MapsWritten)+' map(s) using '+
       IntToStr(res.TilesUsed)+' tile(s).'+sLineBreak+sLineBreak+
       'Folder: '+res.OutputDir+sLineBreak+
       'Map:    '+res.FirstMapFile;
  if res.MapsWritten > 1 then msg:=msg+'  (+'+IntToStr(res.MapsWritten-1)+' more)';
  msg:=msg+sLineBreak;

  if res.TsxFile <> '' then
    msg:=msg+'Tileset: '+res.TsxFile+sLineBreak
  else
    msg:=msg+'Tileset: embedded in the .tmx'+sLineBreak;

  if res.SheetFile <> '' then
    msg:=msg+'Image:   '+res.SheetFile+sLineBreak
  else if res.ImageDir <> '' then
    msg:=msg+'Images:  '+IntToStr(res.ImageFiles)+' file(s) in '+res.ImageDir+PathDelim+sLineBreak
  else
    msg:=msg+'Images:  '+IntToStr(res.ImageFiles)+' file(s)'+sLineBreak;

  if res.ObjectsOut > 0 then
    msg:=msg+'Objects: '+IntToStr(res.ObjectsOut)+' hit box(es) and path(s)'+sLineBreak;
  if res.MissingTiles > 0 then
    msg:=msg+sLineBreak+IntToStr(res.MissingTiles)+
         ' cell(s) referenced an image that no longer exists and were '+
         'exported as empty.';

  //Leftovers are the one failure that looks like a broken export but is not.
  //An earlier run of the OTHER shape leaves images this run does not
  //overwrite, and any .tmx still sitting there points at a tileset that has
  //since been rewritten - which Tiled reports as missing referenced files.
  if res.StaleFiles > 0 then
    msg:=msg+sLineBreak+sLineBreak+
         'NOTE: this folder still holds '+IntToStr(res.StaleFiles)+
         ' image file(s) from an earlier export of the other type, and may '+
         'hold .tmx files from it too. Those still point at the old tileset. '+
         'Export to an empty folder if anything fails to load.';

  ShowMessage(msg);
end;

procedure TMapEdit.PathsFixClosedClick(Sender: TObject);
var
  p,cx,cy,n,closedcount,needfix,fixed,failed : integer;
  msg : string;
begin
  //filled through var parameters by ClosingLegNeedsCorner - see hint 5057
  cx:=0;
  cy:=0;
  n:=MapCoreBase.GetPathCount(CurrentMap);
  if n = 0 then
  begin
    ShowMessage('This map has no paths.');
    exit;
  end;

  closedcount:=0;
  needfix:=0;
  for p:=0 to n-1 do
  begin
    if not MapCoreBase.GetPathClosed(CurrentMap,p) then continue;
    inc(closedcount);
    if MapCoreBase.ClosingLegNeedsCorner(CurrentMap,p,cx,cy) then inc(needfix);
  end;

  if closedcount = 0 then
  begin
    ShowMessage('This map has no closed paths.'+sLineBreak+sLineBreak+
                'Only closed paths have a closing leg to repair.');
    exit;
  end;

  if needfix = 0 then
  begin
    ShowMessage('Checked '+IntToStr(closedcount)+' closed path(s).'+sLineBreak+
                'They all return to their start point already - nothing to fix.');
    exit;
  end;

  if MessageDlg('Fix Closed Paths',
     IntToStr(needfix)+' of '+IntToStr(closedcount)+' closed path(s) do not return '+
     'to their start point.'+sLineBreak+sLineBreak+
     'Add one corner waypoint to each, so the leg back to the start stays '+
     'straight or on a 45 degree line?',
     mtConfirmation,[mbYes,mbNo],0) <> mrYes then exit;

  MapCoreBase.CopyToUndo(CurrentMap);

  fixed:=0;
  failed:=0;
  for p:=0 to n-1 do
  begin
    if not MapCoreBase.GetPathClosed(CurrentMap,p) then continue;
    case MapCoreBase.RepairClosingLeg(CurrentMap,p) of
       1 : inc(fixed);
      -1 : inc(failed);
    end;
  end;

  msg:='Repaired '+IntToStr(fixed)+' of '+IntToStr(closedcount)+' closed path(s).';
  if failed > 0 then
    msg:=msg+sLineBreak+sLineBreak+
         IntToStr(failed)+' could not be repaired. A path already holding the '+
         'maximum of '+IntToStr(MaxPathPoints)+' points has no room for the '+
         'extra corner - delete a waypoint from it and run this again.';

  UpdatePathListView;
  RefreshMapPanels;
  MapPaintBox.Invalidate;
  ShowMessage(msg);
end;

procedure TMapEdit.PathsDeleteAllClick(Sender: TObject);
begin
  if MapCoreBase.GetPathCount(CurrentMap) = 0 then exit;
  if MessageDlg('Delete All Paths',
     'Delete all paths on this map?',
     mtConfirmation,[mbYes,mbNo],0) <> mrYes then exit;

  MapCoreBase.ClearPaths(CurrentMap);
  FPathEditIndex:=-1;
  FPathHasPreview:=false;
  SelectedPath:=-1;
  UpdatePathListView;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.BtnPathDeleteClick(Sender: TObject);
begin
  if not MapCoreBase.IsValidPath(CurrentMap,SelectedPath) then exit;
  if MessageDlg('Delete Path',
     'Delete "'+MapCoreBase.GetPathName(CurrentMap,SelectedPath)+'"?',
     mtConfirmation,[mbYes,mbNo],0) <> mrYes then exit;

  MapCoreBase.DeletePath(CurrentMap,SelectedPath);
  if FPathEditIndex = SelectedPath then
  begin
    FPathEditIndex:=-1;
    FPathHasPreview:=false;
  end;
  SelectedPath:=-1;
  UpdatePathListView;
  MapPaintBox.Invalidate;
end;

//Visible is an editing aid - it hides the path so you can draw over that
//area. It deliberately does NOT affect whether the path is exported.
procedure TMapEdit.BtnPathVisibleClick(Sender: TObject);
begin
  if not MapCoreBase.IsValidPath(CurrentMap,SelectedPath) then exit;
  MapCoreBase.SetPathVisible(CurrentMap,SelectedPath,
    not MapCoreBase.GetPathVisible(CurrentMap,SelectedPath));
  UpdatePathListView;
  MapPaintBox.Invalidate;
end;

//Active is the real data flag - this is the one export honours.
procedure TMapEdit.BtnPathActiveClick(Sender: TObject);
begin
  if not MapCoreBase.IsValidPath(CurrentMap,SelectedPath) then exit;
  MapCoreBase.SetPathActive(CurrentMap,SelectedPath,
    not MapCoreBase.GetPathActive(CurrentMap,SelectedPath));
  UpdatePathListView;
end;

procedure TMapEdit.BtnPathModeClick(Sender: TObject);
var
  m : integer;
begin
  if not MapCoreBase.IsValidPath(CurrentMap,SelectedPath) then exit;
  m:=MapCoreBase.GetPathMode(CurrentMap,SelectedPath)+1;
  if m > PathModePingPong then m:=PathModeOnce;
  MapCoreBase.SetPathMode(CurrentMap,SelectedPath,m);
  UpdatePathListView;
end;

procedure TMapEdit.BtnPathRenameClick(Sender: TObject);
var
  s : string;
begin
  if not MapCoreBase.IsValidPath(CurrentMap,SelectedPath) then exit;
  s:=MapCoreBase.GetPathName(CurrentMap,SelectedPath);
  if InputQuery('Rename Path','Path name:',s) then
  begin
    MapCoreBase.SetPathName(CurrentMap,SelectedPath,s);
    UpdatePathListView;
  end;
end;

Procedure TMapEdit.DrawPathOverlay;
var
  i,pt,n,pcount : integer;
  P : PathRec;
  PP,PN : PathPointRec;
  x1,y1,x2,y2 : integer;
  PColors : array[0..7] of TColor;
  c : TColor;
  r : integer;
begin
  //same cycle the hitboxes use, so the two overlays feel like one system
  PColors[0]:=clRed;
  PColors[1]:=clLime;
  PColors[2]:=clAqua;
  PColors[3]:=clFuchsia;
  PColors[4]:=clYellow;
  PColors[5]:=clBlue;
  PColors[6]:=clMaroon;
  PColors[7]:=clTeal;

  pcount:=MapCoreBase.GetPathCount(CurrentMap);
  if pcount = 0 then exit;

  for i:=0 to pcount-1 do
  begin
    //visible is an editing flag only - an invisible path is still exported
    if not MapCoreBase.GetPathVisible(CurrentMap,i) then continue;

    MapCoreBase.GetPath(CurrentMap,i,P);
    n:=P.PointCount;
    if n = 0 then continue;

    c:=PColors[i mod 8];
    MapPaintBox.Canvas.Pen.Color:=c;
    MapPaintBox.Canvas.Brush.Color:=c;
    MapPaintBox.Canvas.Brush.Style:=bsSolid;
    if i = SelectedPath then MapPaintBox.Canvas.Pen.Width:=3
                        else MapPaintBox.Canvas.Pen.Width:=2;

    //segments
    for pt:=0 to n-2 do
    begin
      PP:=P.Points[pt];
      PN:=P.Points[pt+1];
      MapPaintBox.Canvas.MoveTo(PathTileCX(PP.x,TileWidth),PathTileCY(PP.y,TileHeight));
      MapPaintBox.Canvas.LineTo(PathTileCX(PN.x,TileWidth),PathTileCY(PN.y,TileHeight));
    end;

    //closing segment back to the first point
    if P.closed and (n > 2) then
    begin
      PP:=P.Points[n-1];
      PN:=P.Points[0];
      MapPaintBox.Canvas.MoveTo(PathTileCX(PP.x,TileWidth),PathTileCY(PP.y,TileHeight));
      MapPaintBox.Canvas.LineTo(PathTileCX(PN.x,TileWidth),PathTileCY(PN.y,TileHeight));
    end;

    //waypoint markers - the first one is drawn larger so the start of the
    //path is obvious, which matters for direction of travel
    for pt:=0 to n-1 do
    begin
      PP:=P.Points[pt];
      x1:=PathTileCX(PP.x,TileWidth);
      y1:=PathTileCY(PP.y,TileHeight);
      if pt = 0 then r:=5 else r:=3;
      MapPaintBox.Canvas.Ellipse(x1-r,y1-r,x1+r,y1+r);
    end;
  end;

  //rubber band for the segment being placed
  if (FPathEditIndex >= 0) and FPathHasPreview then
  begin
    MapCoreBase.GetPath(CurrentMap,FPathEditIndex,P);
    if P.PointCount > 0 then
    begin
      PP:=P.Points[P.PointCount-1];
      x1:=PathTileCX(PP.x,TileWidth);
      y1:=PathTileCY(PP.y,TileHeight);
      x2:=PathTileCX(FPathPreviewX,TileWidth);
      y2:=PathTileCY(FPathPreviewY,TileHeight);

      MapPaintBox.Canvas.Pen.Color:=clWhite;
      MapPaintBox.Canvas.Pen.Width:=1;
      MapPaintBox.Canvas.Pen.Style:=psDot;
      MapPaintBox.Canvas.MoveTo(x1,y1);
      MapPaintBox.Canvas.LineTo(x2,y2);
      MapPaintBox.Canvas.Pen.Style:=psSolid;
    end;
  end;

  MapPaintBox.Canvas.Pen.Width:=1;
end;

Procedure TMapEdit.UpdatePathListView;
var
  i,n : integer;
  item : TListItem;
  P : PathRec;
begin
  if PathListView = nil then exit;

  PathListView.Items.BeginUpdate;
  try
    PathListView.Items.Clear;
    n:=MapCoreBase.GetPathCount(CurrentMap);
    TabPaths.Caption:='Paths ('+IntToStr(n)+')';
    for i:=0 to n-1 do
    begin
      MapCoreBase.GetPath(CurrentMap,i,P);
      item:=PathListView.Items.Add;
      item.Caption:=MapCoreBase.GetPathName(CurrentMap,i);
      item.SubItems.Add(IntToStr(P.PointCount));
      if P.closed then item.SubItems.Add('Yes') else item.SubItems.Add('No');
      case P.mode of
        PathModeOnce     : item.SubItems.Add('Once');
        PathModePingPong : item.SubItems.Add('PingPong');
      else
        item.SubItems.Add('Loop');
      end;
      if P.visible then item.SubItems.Add('Yes') else item.SubItems.Add('No');
      if P.active  then item.SubItems.Add('Yes') else item.SubItems.Add('No');
    end;
  finally
    PathListView.Items.EndUpdate;
  end;
  UpdateStatusSettings;
end;

procedure TMapEdit.StartNewPath(tx,ty : integer);
var
  p : integer;
begin
  p:=MapCoreBase.AddPath(CurrentMap);
  if p < 0 then
  begin
    ShowMessage('This map already has the maximum of '+IntToStr(MaxPaths)+' paths.');
    exit;
  end;
  MapCoreBase.AddPathPoint(CurrentMap,p,tx,ty);
  FPathEditIndex:=p;
  SelectedPath:=p;
  FPathHasPreview:=false;
  UpdatePathListView;
  MapPaintBox.Invalidate;
end;

//Every leg the user PLOTS goes through SnapTo8. The closing leg - last
//waypoint back to the first - is implicit: it is never plotted, so nothing
//ever constrained it to the 8 directions, and the exporter would round it and
//land the follower somewhere other than the start.
//
//RepairClosingLeg appends the one corner waypoint that splits that leg into a
//45 degree run and a straight run. It appends rather than moving the user's
//last point, because moving what they plotted would silently change the shape
//they drew.
procedure TMapEdit.FinishPath(closeIt : boolean);
begin
  if FPathEditIndex < 0 then exit;

  //a single point is not a path - drop it rather than leaving a stray dot
  if MapCoreBase.GetPathPointCount(CurrentMap,FPathEditIndex) < 2 then
    MapCoreBase.DeletePath(CurrentMap,FPathEditIndex)
  else
  begin
    if closeIt then
      if MapCoreBase.RepairClosingLeg(CurrentMap,FPathEditIndex) < 0 then
      begin
        ShowMessage('This path cannot be closed.'+sLineBreak+sLineBreak+
          'Closing it needs one more corner point, so that the leg back to the '+
          'start stays straight or on a 45 degree line, and this path already '+
          'has the maximum of '+IntToStr(MaxPathPoints)+' points.'+sLineBreak+sLineBreak+
          'The path has been left open.');
        closeIt:=false;
      end;

    MapCoreBase.SetPathClosed(CurrentMap,FPathEditIndex,closeIt);
  end;

  FPathEditIndex:=-1;
  FPathHasPreview:=false;
  if SelectedPath >= MapCoreBase.GetPathCount(CurrentMap) then
    SelectedPath:=MapCoreBase.GetPathCount(CurrentMap)-1;
  UpdatePathListView;
  MapPaintBox.Invalidate;
end;

//=============================================================================
// MOVE TOOL
//
// Drags a whole hitbox or a whole path. Whole object only: shifting every
// waypoint by the same amount keeps each segment on its 8 direction axis,
// whereas dragging a single waypoint would create an arbitrary angle that
// the exporter cannot represent.
//
// Paths are hit tested before hitboxes, because a path drawn across a hitbox
// would otherwise be impossible to grab.
//=============================================================================
procedure TMapEdit.MPaintBoxMouseDownMoveTool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  tx,ty,hit : integer;
begin
  if Button <> mbLeft then exit;

  tx:=GetMapX(x);
  ty:=GetMapY(y);
  FMoveIndex:=-1;

  //paths first - a waypoint within one tile of the click
  hit:=MapCoreBase.PathHitTest(CurrentMap,tx,ty,1);
  if hit >= 0 then
  begin
    FMoveKindIsPath:=true;
    FMoveIndex:=hit;
    SelectedPath:=hit;
  end
  else
  begin
    hit:=MapCoreBase.HitBoxHitTest(CurrentMap,tx,ty);
    if hit >= 0 then
    begin
      FMoveKindIsPath:=false;
      FMoveIndex:=hit;
      SelectedHitBox:=hit;
    end;
  end;

  if FMoveIndex < 0 then exit;

  //one undo level for the whole drag, taken before the first movement
  MapCoreBase.CopyToUndo(CurrentMap);
  FMoveLastX:=tx;
  FMoveLastY:=ty;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.MPaintBoxMouseMoveMoveTool(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  tx,ty,dx,dy : integer;
begin
  MapX:=GetMapX(x);
  MapY:=GetMapY(y);
  UpdateMapInfo(MapX,MapY);

  if FMoveIndex < 0 then exit;
  if not (ssLeft in Shift) then exit;

  tx:=MapX;
  ty:=MapY;
  dx:=tx-FMoveLastX;
  dy:=ty-FMoveLastY;
  if (dx = 0) and (dy = 0) then exit;   //still on the same tile

  if FMoveKindIsPath then
    MapCoreBase.MovePath(CurrentMap,FMoveIndex,dx,dy)
  else
    MapCoreBase.MoveHitBox(CurrentMap,FMoveIndex,dx,dy);

  //Track the cursor, not the object. If the object clamped at an edge the two
  //diverge, and using the cursor means dragging back moves it immediately
  //instead of first working off the difference.
  FMoveLastX:=tx;
  FMoveLastY:=ty;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.MPaintBoxMouseUpMoveTool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FMoveIndex < 0 then exit;
  FMoveIndex:=-1;
  //the lists show coordinates, so they are stale until the drag ends
  RefreshMapPanels;
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.MPaintBoxMouseDownPathTool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  tx,ty,nx,ny,last : integer;
  PP : PathPointRec;
begin
  tx:=GetMapX(x);
  ty:=GetMapY(y);

  if Button = mbRight then
  begin
    //right click closes the loop and ends the path
    FinishPath(true);
    exit;
  end;

  if Button <> mbLeft then exit;

  if FPathEditIndex < 0 then
  begin
    StartNewPath(tx,ty);
    exit;
  end;

  //snap this point to 8 directions from the previous one
  last:=MapCoreBase.GetPathPointCount(CurrentMap,FPathEditIndex)-1;
  MapCoreBase.GetPathPoint(CurrentMap,FPathEditIndex,last,PP);
  MapCoreBase.SnapTo8(CurrentMap,PP.x,PP.y,tx,ty,nx,ny);

  //ignore a click that did not move anywhere
  if (nx = PP.x) and (ny = PP.y) then exit;

  if MapCoreBase.AddPathPoint(CurrentMap,FPathEditIndex,nx,ny) < 0 then
  begin
    ShowMessage('A path can have at most '+IntToStr(MaxPathPoints)+' points.');
    FinishPath(false);
    exit;
  end;

  UpdatePathListView;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.MPaintBoxMouseMovePathTool(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  tx,ty,nx,ny,last : integer;
  PP : PathPointRec;
begin
  MapX:=GetMapX(x);
  MapY:=GetMapY(y);
  UpdateMapInfo(MapX,MapY);

  if FPathEditIndex < 0 then exit;

  last:=MapCoreBase.GetPathPointCount(CurrentMap,FPathEditIndex)-1;
  if last < 0 then exit;

  tx:=MapX;
  ty:=MapY;
  MapCoreBase.GetPathPoint(CurrentMap,FPathEditIndex,last,PP);
  MapCoreBase.SnapTo8(CurrentMap,PP.x,PP.y,tx,ty,nx,ny);

  //only repaint when the snapped end point actually changed, otherwise the
  //overlay redraws on every pixel of mouse movement
  if (not FPathHasPreview) or (nx <> FPathPreviewX) or (ny <> FPathPreviewY) then
  begin
    FPathPreviewX:=nx;
    FPathPreviewY:=ny;
    FPathHasPreview:=true;
    MapPaintBox.Invalidate;
  end;
end;

Procedure TMapEdit.DrawHitBoxOverlay;
var
  i : integer;
  HB : HitBoxRec;
  px,py,px2,py2 : integer;
  hbcount : integer;
  HBColors : array[0..7] of TColor;
begin
  HBColors[0]:=clRed;
  HBColors[1]:=clLime;
  HBColors[2]:=clAqua;
  HBColors[3]:=clFuchsia;
  HBColors[4]:=clYellow;
  HBColors[5]:=clBlue;
  HBColors[6]:=clMaroon;
  HBColors[7]:=clTeal;

  hbcount:=MapCoreBase.GetHitBoxCount(CurrentMap);
  if hbcount = 0 then exit;

  MapPaintBox.Canvas.Brush.Style:=bsBDiagonal;
  MapPaintBox.Canvas.Pen.Width:=2;

  for i:=0 to hbcount-1 do
  begin
    MapCoreBase.GetHitBox(CurrentMap,i,HB);
    if not HB.active then continue;

    px:=HB.x*TileWidth;
    py:=HB.y*TileHeight;
    px2:=(HB.x2+1)*TileWidth;
    py2:=(HB.y2+1)*TileHeight;

    MapPaintBox.Canvas.Pen.Color:=HBColors[i mod 8];
    MapPaintBox.Canvas.Brush.Color:=HBColors[i mod 8];

    // draw hatched fill rectangle
    MapPaintBox.Canvas.Rectangle(px,py,px2,py2);

    // highlight selected hitbox with thicker border
    if i = SelectedHitBox then
    begin
      MapPaintBox.Canvas.Brush.Style:=bsClear;
      MapPaintBox.Canvas.Pen.Width:=3;
      MapPaintBox.Canvas.Rectangle(px-1,py-1,px2+1,py2+1);
      MapPaintBox.Canvas.Pen.Width:=2;
      MapPaintBox.Canvas.Brush.Style:=bsBDiagonal;
    end;

    // draw index label
    MapPaintBox.Canvas.Brush.Style:=bsSolid;
    MapPaintBox.Canvas.Font.Color:=clWhite;
    MapPaintBox.Canvas.Font.Size:=8;
    MapPaintBox.Canvas.TextOut(px+2,py+2,IntToStr(i));
    MapPaintBox.Canvas.Brush.Style:=bsBDiagonal;
  end;

  MapPaintBox.Canvas.Brush.Style:=bsSolid;
  MapPaintBox.Canvas.Pen.Width:=1;
end;

procedure TMapEdit.UpdateHitBoxListView;
var
  i : integer;
  hbcount : integer;
  HB : HitBoxRec;
  item : TListItem;
begin
  ListView1.Items.Clear;
  hbcount:=MapCoreBase.GetHitBoxCount(CurrentMap);
  for i:=0 to hbcount-1 do
  begin
    MapCoreBase.GetHitBox(CurrentMap,i,HB);
    item:=ListView1.Items.Add;
    item.Caption:=IntToStr(i);
    item.SubItems.Add(IntToStr(HB.x));
    item.SubItems.Add(IntToStr(HB.y));
    item.SubItems.Add(IntToStr(HB.x2));
    item.SubItems.Add(IntToStr(HB.y2));
    item.SubItems.Add(IntToStr(HB.x2-HB.x+1)+'x'+IntToStr(HB.y2-HB.y+1));
  end;
  TabHitBoxes.Caption:='Hit Boxes ('+IntToStr(hbcount)+')';
  UpdateStatusSettings;
end;

procedure TMapEdit.HitBoxesToggleClick(Sender: TObject);
begin
  ShowHitBoxOverlay:=not ShowHitBoxOverlay;
  UpdateStatusSettings;
  HitBoxesToggle.Checked:=ShowHitBoxOverlay;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.HitBoxesClearAllClick(Sender: TObject);
begin
  if MapCoreBase.GetHitBoxCount(CurrentMap) = 0 then exit;
  if MessageDlg('Clear all hit boxes for this map?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
  begin
    MapCoreBase.ClearAllHitBoxes(CurrentMap);
    SelectedHitBox:=-1;
    UpdateHitBoxListView;
    MapPaintBox.Invalidate;
  end;
end;

procedure TMapEdit.ListView1Click(Sender: TObject);
var
  item : TListItem;
begin
  if ListView1.SelCount > 0 then
  begin
    item:=ListView1.Selected;
    if item <> nil then
    begin
      SelectedHitBox:=item.Index;
      MapPaintBox.Invalidate;
    end;
  end;
end;

procedure TMapEdit.UpdateMapView;
var
  i,j,l : integer;
  T   : TileRec;
  nlayers : integer;
  UseTrans : boolean;
begin
 // Draw the checkerboard ONCE, before the layer loop. It is a map level
 // background - drawing it per layer would paint over everything beneath
 // and only the topmost visible layer would survive.
 if ShowTransparent then DrawCheckerboard;

 nlayers:=MapCoreBase.GetLayerCount(CurrentMap);

 // Bottom to top: layer 0 first, each later layer painted over it. Cells
 // holding TileClear are skipped, so lower layers show through wherever an
 // upper layer has nothing - that is what makes layers useful.
 for l:=0 to nlayers-1 do
 begin
   if not MapCoreBase.GetLayerVisible(CurrentMap,l) then continue;

   // Layers above the base must honour per tile transparency or a sprite
   // with a transparent background would be drawn as an opaque box and
   // hide the terrain below it.
   UseTrans:=ShowTransparent or (l > 0);

   for j:=0 to MapCoreBase.GetMapHeight(CurrentMap)-1 do
   begin
     for i:=0 to MapCoreBase.GetMapWidth(CurrentMap)-1 do
     begin
       MapCoreBase.GetMapTileL(CurrentMap,l,i,j,T);
       if T.ImageIndex = TileMissing then
         PlotMissingTile(i,j)
       else if T.ImageIndex <> TileClear then
       begin
         if UseTrans then
           ImageListPlotTileTransparent(i,j,T)
         else
           ImageListPlotTile(i,j,T);
       end;
     end;
   end;
 end;
end;

procedure TMapEdit.MapPaintBoxPaint(Sender: TObject);
begin
  UpdateMapView;
  if RenderDrawToolShape  then DrawItem(DrawTool,MapX,MapY,MapX2,MapY2,CTile.ImageIndex,0);
  if MapCoreBase.GetMapGridStatus(MapCoreBase.GetCurrentMap) = 1 then DrawGrid;
  if MapCoreBase.GetMapClipStatus(MapCoreBase.GetCurrentMap) = 1 then DrawOverLayOnClipArea;
  if ShowHitBoxOverlay then DrawHitBoxOverlay;
  if ShowPathOverlay then DrawPathOverlay;
end;

procedure TMapEdit.MenuDeleteAllClick(Sender: TObject);
begin
 DeleteAll;
end;

procedure TMapEdit.DeleteAll;
begin
  MapCoreBase.Init;  //init core to default values
  Init;              //init map editor to default values
end;

procedure TMapEdit.MenuDeleteClick(Sender: TObject);
var
  index : integer;
  item  : TListItem;
begin
  if MapCoreBase.GetMapCount > 1 then
  begin
    if (MapListView.SelCount > 0) then    //if map is selected
    begin
       item:=MapListView.LastSelected;
       index:=item.index;
       if index > -1 then
       begin
         MapCoreBase.DeleteMap(Index);
       end
       else
       begin
         MapCoreBase.DeleteMap(CurrentMap);
       end;

       if CurrentMap > (MapCoreBase.GetMapCount-1) then
       begin
         CurrentMap:=MapCoreBase.GetMapCount-1;
         MapCoreBase.SetCurrentMap(CurrentMap);
       end;
       UpdateMapListView;
       UpdatePageSize;
      //UpdateMapView;
       MapPaintBox.Invalidate;
    end;
  end
  else
  begin
    MapCoreBase.ClearMap(0,TileClear);  // if there is only one map we just clear it
    UpdatePageSize;
    UpdateMapListView;
    //UpdateMapView;
    MapPaintBox.Invalidate;
  end;
end;

function TMapEdit.ExportTextFileToClipboard(Sender: TObject) : boolean;
var
 filename : string;
 mi : TMenuItem;
begin
 if rmconfigbase.GetExportTextFileToClipStatus = false then
 begin
   result:=false;
   exit;
 end;

 filename:=GetTemporaryPathWithProvidedFileName(MapCoreBase.GetExportName(MapCoreBase.GetCurrentMap));
 mi:=Sender As TMenuItem;
 Case mi.Name of  'ExportBasicMapData':ExportMap(FileName,BasicLan,True);
                                     'BasicLNMapData':ExportMap(FileName,BasicLNLan,True);
                                     'ExportCArray': ExportMap(FileName,CLan,true);
                                     'ExportPascalArray':ExportMap(FileName,PascalLan,true);
                                     'ExportHitBoxBasic':ExportHitBoxes(FileName,BasicLan);
                                     'ExportHitBoxBasicLN':ExportHitBoxes(FileName,BasicLNLan);
                                     'ExportHitBoxC':ExportHitBoxes(FileName,CLan);
                                     'ExportHitBoxPascal':ExportHitBoxes(FileName,PascalLan);
 else
   //Tag-based dispatch for extended compiler targets. Menu item names carry
   //the kind (MD_ map data, HB_ hitboxes, PD_ path data) and Tag holds the
   //Lan constant, so every language target is handled by these three lines.
   if (mi.Tag > 0) and (Copy(mi.Name,1,3) = 'MD_') then
     ExportMap(FileName,mi.Tag,True)
   else if (mi.Tag > 0) and (Copy(mi.Name,1,3) = 'HB_') then
     ExportHitBoxes(FileName,mi.Tag)
   else if (mi.Tag > 0) and (Copy(mi.Name,1,3) = 'PD_') then
     ExportPathData(FileName,mi.Tag)
   else
   begin
     result:=false;  //did not find a supported format return false
     exit;
   end;
 End;

 //An exporter can decline to write anything - ExportPathData does exactly
 //that when the map has no active paths, and it has already said why. Without
 //this check we would read a file that was never created and then claim the
 //export succeeded.
 if not FileExists(filename) then
 begin
   result:=true;   //handled: the exporter reported the problem itself
   exit;
 end;

 result:=true;  //found supported format - return true
 ReadFileAndCopyToClipboard(filename);
 EraseFile(filename);
 ShowMessage('Exported to Clipboard!');
end;

procedure TMapEdit.MenuExportMapDataLanClick(Sender: TObject);
var
  Lan : integer;
begin
 if ExportTextFileToClipboard(Sender) then exit;

 Lan:=(Sender as TMenuItem).Tag;
 if MapLanIsBasic(Lan) or MapLanIsBasicLN(Lan) then
   SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*'
 else if MapLanIsPascal(Lan) then
   SaveDialog1.Filter := 'Pascal|*.pas|All Files|*.*'
 else if MapLanIsC(Lan) then
   SaveDialog1.Filter := 'c|*.c;*.h|All Files|*.*'
 else if MapLanIsJS(Lan) then
   SaveDialog1.Filter := 'JavaScript|*.js|All Files|*.*'
 else if MapLanIsJSON(Lan) then
   SaveDialog1.Filter := 'JSON|*.json|All Files|*.*'
 else
   SaveDialog1.Filter := 'All Files|*.*';

 if SaveDialog1.Execute then
 begin
   ExportMap(SaveDialog1.FileName,Lan,True);
 end;
end;


procedure TMapEdit.MenuExportPathDataLanClick(Sender: TObject);
var
  Lan : integer;
begin
  if ExportTextFileToClipboard(Sender) then exit;

  Lan:=(Sender as TMenuItem).Tag;
  if MapLanIsBasic(Lan) or MapLanIsBasicLN(Lan) then
    SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*'
  else if MapLanIsPascal(Lan) then
    SaveDialog1.Filter := 'Pascal|*.pas|All Files|*.*'
  else if MapLanIsC(Lan) then
    SaveDialog1.Filter := 'c|*.c;*.h|All Files|*.*'
  else if MapLanIsJS(Lan) then
    SaveDialog1.Filter := 'JavaScript|*.js|All Files|*.*'
  else if MapLanIsJSON(Lan) then
    SaveDialog1.Filter := 'JSON|*.json|All Files|*.*'
  else
    SaveDialog1.Filter := 'All Files|*.*';

  if SaveDialog1.Execute then
    ExportPathData(SaveDialog1.FileName,Lan);
end;

//=============================================================================
// PATH DATA EXPORT
//
// One flat integer array, the same shape in every language:
//
//   [0]        NP                 number of paths
//   [1..NP]    offset of each path header, into this same array
//   header:    +0 startTileX  +1 startTileY
//              +2 startPixelX +3 startPixelY
//              +4 closed      +5 mode (0=once 1=loop 2=pingpong)
//              +6 segCount
//              +7 segments, stride 4: dx, dy, pixels, delay
//
// The offset table lives inside the array so a program needs no parallel
// arrays - one lookup gives the header of any path.
//
// dx,dy come from the 8 direction set so they are always -1/0/+1, which
// makes "pixels" the exact number of one pixel steps to the next waypoint,
// diagonals included. Following a path is an add and a decrement per frame,
// with no division and no fixed point.
//
// Only ACTIVE paths are exported - "visible" is an editor flag and must
// never decide what ends up in a build.
//=============================================================================
procedure TMapEdit.ExportPathData(filename : string; lan : integer);
var
  F : TextFile;
  exportname : string;
  tw,th : integer;
  i,j,k,p : integer;
  P1 : PathRec;
  npaths,segcount,dirn,steps : integer;
  offs : array[0..MaxPaths-1] of integer;
  idx  : array[0..MaxPaths-1] of integer;
  total,linenum : integer;
  vals : array of integer;
  nvals : integer;
  line : string;

  function SegCountOf(var PP : PathRec) : integer;
  begin
    if PP.PointCount < 2 then SegCountOf:=0
    else if PP.closed then SegCountOf:=PP.PointCount
    else SegCountOf:=PP.PointCount-1;
  end;

  procedure PushVal(v : integer);
  begin
    if nvals >= Length(vals) then SetLength(vals,Length(vals)+256);
    vals[nvals]:=v;
    inc(nvals);
  end;

  //Emit the flat array wrapped at a sensible width.
  //  numbered - prepend BASIC line numbers
  //  contsep  - put a comma at the end of every line but the last. That is
  //             what an array initialiser needs, but a BASIC DATA statement
  //             must NOT have one, so the two cases differ.
  procedure WriteValues(const prefix,suffix : string; perline : integer;
                        numbered,contsep : boolean);
  var
    a,b2 : integer;
  begin
    a:=0;
    while a < nvals do
    begin
      line:='';
      for b2:=a to a+perline-1 do
      begin
        if b2 >= nvals then break;
        if b2 > a then line:=line+',';
        line:=line+IntToStr(vals[b2]);
      end;

      if numbered then
      begin
        WriteLn(F,IntToStr(linenum)+' '+prefix+line);
        inc(linenum,10);
      end
      else if (a+perline) >= nvals then
        WriteLn(F,prefix+line+suffix)
      else if contsep then
        WriteLn(F,prefix+line+',')
      else
        WriteLn(F,prefix+line);

      a:=a+perline;
    end;
  end;

begin
  exportname:=MapCoreBase.GetExportName(CurrentMap);
  if exportname = '' then exportname:='map' + IntToStr(CurrentMap);
  tw:=MapCoreBase.GetMapTileWidth(CurrentMap);
  th:=MapCoreBase.GetMapTileHeight(CurrentMap);

  //gather the exportable paths first - the offset table has to be emitted
  //before the blocks, so every size must be known up front
  npaths:=0;
  for p:=0 to MapCoreBase.GetPathCount(CurrentMap)-1 do
  begin
    if not MapCoreBase.GetPathActive(CurrentMap,p) then continue;
    MapCoreBase.GetPath(CurrentMap,p,P1);
    if SegCountOf(P1) = 0 then continue;
    idx[npaths]:=p;
    inc(npaths);
    if npaths >= MaxPaths then break;
  end;

  if npaths = 0 then
  begin
    ShowMessage('This map has no active paths with at least two points.');
    exit;
  end;

  total:=1+npaths;
  for i:=0 to npaths-1 do
  begin
    offs[i]:=total;
    MapCoreBase.GetPath(CurrentMap,idx[i],P1);
    total:=total + 7 + SegCountOf(P1)*4;
  end;

  //build the flat array once, then format it per language
  nvals:=0;
  SetLength(vals,total+16);
  PushVal(npaths);
  for i:=0 to npaths-1 do PushVal(offs[i]);

  for i:=0 to npaths-1 do
  begin
    MapCoreBase.GetPath(CurrentMap,idx[i],P1);
    segcount:=SegCountOf(P1);

    PushVal(P1.Points[0].x);
    PushVal(P1.Points[0].y);
    PushVal(P1.Points[0].x*tw + tw div 2);
    PushVal(P1.Points[0].y*th + th div 2);
    if P1.closed then PushVal(1) else PushVal(0);
    PushVal(P1.mode);
    PushVal(segcount);

    for j:=0 to segcount-1 do
    begin
      k:=j+1;
      if k >= P1.PointCount then k:=0;
      dirn:=MapCoreBase.DirectionBetween(P1.Points[j].x,P1.Points[j].y,
                                         P1.Points[k].x,P1.Points[k].y);
      if dirn < 0 then
      begin
        //identical waypoints - keep a zero length hop so segCount stays true
        PushVal(0); PushVal(0); PushVal(0); PushVal(P1.Points[k].delay);
        continue;
      end;
      steps:=abs(P1.Points[k].x-P1.Points[j].x);
      if abs(P1.Points[k].y-P1.Points[j].y) > steps then
        steps:=abs(P1.Points[k].y-P1.Points[j].y);

      PushVal(PathDirX[dirn]);
      PushVal(PathDirY[dirn]);
      PushVal(steps*tw);
      PushVal(P1.Points[k].delay);
    end;
  end;

  AssignFile(F, filename);
  Rewrite(F);

  if MapLanIsC(lan) then
  begin
    WriteLn(F,'/* Path data for '+exportname+' - created by Raster Master */');
    WriteLn(F,'/* [0]=path count, [1..count]=offset of each path header.   */');
    WriteLn(F,'/* header: sx,sy,px,py,closed,mode,segcount then segcount   */');
    WriteLn(F,'/* groups of dx,dy,pixels,delay. mode 0=once 1=loop 2=pong  */');
    WriteLn(F,'#define '+exportname+'_path_size '+IntToStr(nvals));
    WriteLn(F,'#define '+exportname+'_path_count '+IntToStr(npaths));
    WriteLn(F,'const int '+exportname+'_paths['+IntToStr(nvals)+'] = {');
    WriteValues('  ','',12,false,true);
    WriteLn(F,'};');
  end
  else if MapLanIsPascal(lan) then
  begin
    WriteLn(F,'{ Path data for '+exportname+' - created by Raster Master }');
    WriteLn(F,'{ [0]=path count, [1..count]=offset of each path header.   }');
    WriteLn(F,'{ header: sx,sy,px,py,closed,mode,segcount then segcount   }');
    WriteLn(F,'{ groups of dx,dy,pixels,delay. mode 0=once 1=loop 2=pong  }');
    WriteLn(F,'const');
    WriteLn(F,'  '+exportname+'_path_size = '+IntToStr(nvals)+';');
    WriteLn(F,'  '+exportname+'_path_count = '+IntToStr(npaths)+';');
    WriteLn(F,'  '+exportname+'_paths : array[0..'+IntToStr(nvals-1)+'] of integer = (');
    WriteValues('    ',');',12,false,true);
  end
  else if MapLanIsJS(lan) then
  begin
    WriteLn(F,'// Path data for '+exportname+' - created by Raster Master');
    WriteLn(F,'// [0]=path count, [1..count]=offset of each path header.');
    WriteLn(F,'// header: sx,sy,px,py,closed,mode,segcount then segcount');
    WriteLn(F,'// groups of dx,dy,pixels,delay. mode 0=once 1=loop 2=pingpong');
    WriteLn(F,'const '+exportname+'PathCount = '+IntToStr(npaths)+';');
    WriteLn(F,'const '+exportname+'Paths = [');
    WriteValues('  ','',12,false,true);
    WriteLn(F,'];');
  end
  else if MapLanIsJSON(lan) then
  begin
    WriteLn(F,'{');
    WriteLn(F,'  "name": "'+exportname+'",');
    WriteLn(F,'  "pathCount": '+IntToStr(npaths)+',');
    WriteLn(F,'  "tileWidth": '+IntToStr(tw)+',');
    WriteLn(F,'  "tileHeight": '+IntToStr(th)+',');
    WriteLn(F,'  "format": "flat: [0]=count, [1..count]=header offsets, header=sx,sy,px,py,closed,mode,segcount, then segcount x (dx,dy,pixels,delay)",');
    WriteLn(F,'  "data": [');
    WriteValues('    ','',12,false,true);
    WriteLn(F,'  ]');
    WriteLn(F,'}');
  end
  else if MapLanIsBasicLN(lan) then
  begin
    linenum:=1000;
    WriteLn(F,IntToStr(linenum)+' REM Path data for '+exportname);
    inc(linenum,10);
    WriteLn(F,IntToStr(linenum)+' REM [0]=count [1..count]=header offsets');
    inc(linenum,10);
    WriteLn(F,IntToStr(linenum)+' REM header sx,sy,px,py,closed,mode,segcount');
    inc(linenum,10);
    WriteLn(F,IntToStr(linenum)+' REM then segcount groups of dx,dy,pixels,delay');
    inc(linenum,10);
    WriteLn(F,IntToStr(linenum)+' REM size '+IntToStr(nvals));
    inc(linenum,10);
    WriteValues('DATA ','',10,true,false);
  end
  else
  begin
    //plain BASIC - QBasic, QB64, FreeBASIC, AmigaBasic and friends
    WriteLn(F,''' Path data for '+exportname+' - created by Raster Master');
    WriteLn(F,''' Single integer array. P(0)=path count, P(1..count)=offset of');
    WriteLn(F,''' each path header. Header: sx,sy,px,py,closed,mode,segcount');
    WriteLn(F,''' then segcount groups of dx,dy,pixels,delay.');
    WriteLn(F,''' mode: 0=once 1=loop 2=pingpong');
    WriteLn(F,''' Tile size '+IntToStr(tw)+'x'+IntToStr(th));
    WriteLn(F,'');
    WriteLn(F,exportname+'PathSize = '+IntToStr(nvals));
    WriteLn(F,exportname+'PathCount = '+IntToStr(npaths));
    WriteLn(F,'');
    WriteLn(F,exportname+'PathData:');
    WriteValues('DATA ','',10,false,false);
  end;

  CloseFile(F);
end;

procedure TMapEdit.MenuExportHitBoxLanClick(Sender: TObject);
var
  Lan : integer;
begin
 if ExportTextFileToClipboard(Sender) then exit;

 Lan:=(Sender as TMenuItem).Tag;
 if MapLanIsBasic(Lan) or MapLanIsBasicLN(Lan) then
   SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*'
 else if MapLanIsPascal(Lan) then
   SaveDialog1.Filter := 'Pascal|*.pas|All Files|*.*'
 else if MapLanIsC(Lan) then
   SaveDialog1.Filter := 'c|*.c;*.h|All Files|*.*'
 else if MapLanIsJS(Lan) then
   SaveDialog1.Filter := 'JavaScript|*.js|All Files|*.*'
 else if MapLanIsJSON(Lan) then
   SaveDialog1.Filter := 'JSON|*.json|All Files|*.*'
 else
   SaveDialog1.Filter := 'All Files|*.*';

 if SaveDialog1.Execute then
 begin
   ExportHitBoxes(SaveDialog1.FileName,Lan);
 end;
end;



procedure TMapEdit.MenuExportBasicLNMapData(Sender: TObject);
begin
 if ExportTextFileToClipboard(Sender) then exit;

 SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*';
 if SaveDialog1.Execute then
 begin
  ExportMap(SaveDialog1.FileName,BasicLNLan,True);
 end;
end;

procedure TMapEdit.MenuExportBasicMapData(Sender: TObject);
begin
 if ExportTextFileToClipboard(Sender) then exit;

 SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*';
 if SaveDialog1.Execute then
 begin
   ExportMap(SaveDialog1.FileName,BasicLan,true);
 end;
end;

procedure TMapEdit.MenuExportCArray(Sender: TObject);
begin
 if ExportTextFileToClipboard(Sender) then exit;

 SaveDialog1.Filter := 'c|*.c|All Files|*.*';
 if SaveDialog1.Execute then
 begin
   ExportMap(SaveDialog1.FileName,CLan,true);
 end;
end;

procedure TMapEdit.MenuExportPascalArray(Sender: TObject);
begin
  if ExportTextFileToClipboard(Sender) then exit;

  SaveDialog1.Filter := 'Pascal|*.pas|All Files|*.*';
  if SaveDialog1.Execute then
  begin
   ExportMap(SaveDialog1.FileName,PascalLan,true);
  end;
end;

procedure TMapEdit.ExportHitBoxes(filename : string; lan : integer);
var
  F : TextFile;
  i, hbcount, linenum : integer;
  HB : HitBoxRec;
  exportname : string;
begin
  hbcount:=MapCoreBase.GetHitBoxCount(CurrentMap);
  exportname:=MapCoreBase.GetExportName(CurrentMap);
  if exportname = '' then exportname:='map' + IntToStr(CurrentMap);

  AssignFile(F, filename);
  Rewrite(F);

  if MapLanIsC(lan) then
  begin
    WriteLn(F, '// HitBox data for ' + exportname);
    WriteLn(F, 'const int ' + exportname + '_hitbox_count = ' + IntToStr(hbcount) + ';');
    if hbcount > 0 then
    begin
      WriteLn(F, 'const int ' + exportname + '_hitboxes[' + IntToStr(hbcount) + '][4] = {');
      for i:=0 to hbcount-1 do
      begin
        MapCoreBase.GetHitBox(CurrentMap, i, HB);
        if i < hbcount-1 then
          WriteLn(F, '  {' + IntToStr(HB.x) + ', ' + IntToStr(HB.y) + ', ' + IntToStr(HB.x2) + ', ' + IntToStr(HB.y2) + '},')
        else
          WriteLn(F, '  {' + IntToStr(HB.x) + ', ' + IntToStr(HB.y) + ', ' + IntToStr(HB.x2) + ', ' + IntToStr(HB.y2) + '}');
      end;
      WriteLn(F, '};');
    end;
  end
  else if MapLanIsPascal(lan) then
  begin
    WriteLn(F, '{ HitBox data for ' + exportname + ' }');
    WriteLn(F, 'const');
    WriteLn(F, '  ' + exportname + '_hitbox_count = ' + IntToStr(hbcount) + ';');
    if hbcount > 0 then
    begin
      WriteLn(F, '  ' + exportname + '_hitboxes: array[0..' + IntToStr(hbcount-1) + ', 0..3] of integer = (');
      for i:=0 to hbcount-1 do
      begin
        MapCoreBase.GetHitBox(CurrentMap, i, HB);
        if i < hbcount-1 then
          WriteLn(F, '    (' + IntToStr(HB.x) + ', ' + IntToStr(HB.y) + ', ' + IntToStr(HB.x2) + ', ' + IntToStr(HB.y2) + '),')
        else
          WriteLn(F, '    (' + IntToStr(HB.x) + ', ' + IntToStr(HB.y) + ', ' + IntToStr(HB.x2) + ', ' + IntToStr(HB.y2) + ')');
      end;
      WriteLn(F, '  );');
    end;
  end
  else if MapLanIsJSON(lan) then
  begin
    WriteLn(F, '{');
    WriteLn(F, '  "name": "' + exportname + '",');
    WriteLn(F, '  "hitBoxCount": ' + IntToStr(hbcount) + ',');
    WriteLn(F, '  "hitBoxes": [');
    for i:=0 to hbcount-1 do
    begin
      MapCoreBase.GetHitBox(CurrentMap, i, HB);
      if i < hbcount-1 then
        WriteLn(F, '    {"id": ' + IntToStr(HB.id) + ', "value": ' + IntToStr(HB.value) +
                   ', "x": ' + IntToStr(HB.x) + ', "y": ' + IntToStr(HB.y) +
                   ', "x2": ' + IntToStr(HB.x2) + ', "y2": ' + IntToStr(HB.y2) + '},')
      else
        WriteLn(F, '    {"id": ' + IntToStr(HB.id) + ', "value": ' + IntToStr(HB.value) +
                   ', "x": ' + IntToStr(HB.x) + ', "y": ' + IntToStr(HB.y) +
                   ', "x2": ' + IntToStr(HB.x2) + ', "y2": ' + IntToStr(HB.y2) + '}');
    end;
    WriteLn(F, '  ]');
    WriteLn(F, '}');
  end
  else if MapLanIsJS(lan) then
  begin
    WriteLn(F, '// HitBox data for ' + exportname);
    WriteLn(F, 'const ' + exportname + '_hitbox_count = ' + IntToStr(hbcount) + ';');
    if hbcount > 0 then
    begin
      WriteLn(F, 'const ' + exportname + '_hitboxes = [');
      for i:=0 to hbcount-1 do
      begin
        MapCoreBase.GetHitBox(CurrentMap, i, HB);
        if i < hbcount-1 then
          WriteLn(F, '  [' + IntToStr(HB.x) + ', ' + IntToStr(HB.y) + ', ' + IntToStr(HB.x2) + ', ' + IntToStr(HB.y2) + '],')
        else
          WriteLn(F, '  [' + IntToStr(HB.x) + ', ' + IntToStr(HB.y) + ', ' + IntToStr(HB.x2) + ', ' + IntToStr(HB.y2) + ']');
      end;
      WriteLn(F, '];');
    end;
  end
  else if MapLanIsBasicLN(lan) then
  begin
    linenum:=1000;
    WriteLn(F, IntToStr(linenum) + ' REM HitBox data for ' + exportname);
    inc(linenum, 10);
    WriteLn(F, IntToStr(linenum) + ' REM HitBox Count');
    inc(linenum, 10);
    WriteLn(F, IntToStr(linenum) + ' DATA ' + IntToStr(hbcount));
    if hbcount > 0 then
    begin
      inc(linenum, 10);
      WriteLn(F, IntToStr(linenum) + ' REM X, Y, X2, Y2');
      for i:=0 to hbcount-1 do
      begin
        inc(linenum, 10);
        MapCoreBase.GetHitBox(CurrentMap, i, HB);
        WriteLn(F, IntToStr(linenum) + ' DATA ' + IntToStr(HB.x) + ',' + IntToStr(HB.y) + ',' + IntToStr(HB.x2) + ',' + IntToStr(HB.y2));
      end;
    end;
  end
  else if MapLanIsBasic(lan) then
  begin
    WriteLn(F, 'REM HitBox data for ' + exportname);
    WriteLn(F, 'REM HitBox Count');
    WriteLn(F, 'DATA ' + IntToStr(hbcount));
    if hbcount > 0 then
    begin
      WriteLn(F, 'REM X, Y, X2, Y2');
      for i:=0 to hbcount-1 do
      begin
        MapCoreBase.GetHitBox(CurrentMap, i, HB);
        WriteLn(F, 'DATA ' + IntToStr(HB.x) + ',' + IntToStr(HB.y) + ',' + IntToStr(HB.x2) + ',' + IntToStr(HB.y2));
      end;
    end;
  end;

  CloseFile(F);
end;

procedure TMapEdit.ExportHitBoxBasicClick(Sender: TObject);
begin
  if ExportTextFileToClipboard(Sender) then exit;

  SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    ExportHitBoxes(SaveDialog1.FileName, BasicLan);
  end;
end;

procedure TMapEdit.ExportHitBoxBasicLNClick(Sender: TObject);
begin
  if ExportTextFileToClipboard(Sender) then exit;

  SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    ExportHitBoxes(SaveDialog1.FileName, BasicLNLan);
  end;
end;

procedure TMapEdit.ExportHitBoxCClick(Sender: TObject);
begin
  if ExportTextFileToClipboard(Sender) then exit;

  SaveDialog1.Filter := 'c|*.c|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    ExportHitBoxes(SaveDialog1.FileName, CLan);
  end;
end;

procedure TMapEdit.ExportHitBoxPascalClick(Sender: TObject);
begin
  if ExportTextFileToClipboard(Sender) then exit;

  SaveDialog1.Filter := 'Pascal|*.pas|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    ExportHitBoxes(SaveDialog1.FileName, PascalLan);
  end;
end;

procedure TMapEdit.MenuMapPropsClick(Sender: TObject);
var
  EO : MapExportFormatRec;
  index : integer;
begin
  index:=MapListView.ItemIndex;
  if index = -1 then index:=0;
  MapCoreBase.GetMapExportProps(index,EO);
  MapExportForm.InitComboBoxes;
  MapExportForm.SetExportProps(EO);
  if MapExportForm.ShowModal = mrOK then
  begin
     MapExportForm.GetExportProps(EO);
     MapCoreBase.SetMapExportProps(index,EO);
  end;
end;

procedure TMapEdit.MenuNewClick(Sender: TObject);
begin
  //capture vert/scroll bar positions
  MapCoreBase.SetMapScrollHorizPos(MapCoreBase.GetCurrentMap,MapScrollBox.HorzScrollBar.Position);
  MapCoreBase.SetMapScrollVertPos(MapCoreBase.GetCurrentMap,MapScrollBox.VertScrollBar.Position);

  MapCoreBase.AddMap;   //making copy of Map 0 for all new maps - Map 0 is the primary map
  MapCoreBase.SetCurrentMap(MapCoreBase.GetMapCount-1);
  CurrentMap:=MapCoreBase.GetCurrentMap;
  TileMode:=tlModeDraw; //draw
  MapCoreBase.SetMapTileMode(CurrentMap,TileMode); // we set to draw because the copied data from map 0 may be in erase mode

  TileZoom.Position:=1;
  MapCoreBase.SetZoomSize(CurrentMap,TileZoom.Position);

  UpdateMapListView;
  UpdatePageSize;
  MapScrollBox.HorzScrollBar.Position:=0;
  MapScrollBox.VertScrollBar.Position:=0;

  SetDrawTool(DrawShapePencil);
  UpdateToolSelectionIcons;
  UpdateMenus;
  UpdateEditMenus;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.MenuOpenClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'RM MAP Files|*.map|All Files|*.*';
  if OpenDialog1.Execute then
  begin
   ReadMap(OpenDialog1.FileName);
   //ReadMap used to fail silently on a version mismatch. With the v3->v4
   //break that would be every older map file, so say what happened.
   case LastMapReadStatus of
     MapReadBadSig     : ShowMessage('That file is not a Raster Master map file.');
     MapReadOldVersion : ShowMessage('This map was made with an older version of '+
                                     'Raster Master and cannot be opened.');
     MapReadNewVersion : ShowMessage('This map was made with a newer version of '+
                                     'Raster Master and cannot be opened.');
   end;
   UpdatePageSize;
   ClearLoadedSelections;  //a restored selection is not one the user made
   RefreshMapPanels;    //the loaded map carries its own layers/hitboxes/paths
   //UpdateMapView;
   MapPaintBox.Invalidate;
  end;
end;

procedure TMapEdit.MenuSaveClick(Sender: TObject);
begin
  SaveDialog1.Filter := 'RM MAP Files|*.map|All Files|*.*';
  if SaveDialog1.Execute then
  begin
   WriteMap(SaveDialog1.FileName);
  end;
end;

procedure TMapEdit.UpdateEditMenus;
var
  mwidth,mheight : integer;
  twidth,theight : integer;
begin
 ReSizeMap8x8.Checked:=false;
 ReSizeMap16x16.Checked:=false;
 ReSizeMap32x32.Checked:=false;
 ReSizeMap64x64.Checked:=false;
 ReSizeMap128x128.Checked:=false;
 ReSizeMap256x256.Checked:=false;
 //clear show custom size menu
 ShowCustomSize.Checked:=false;
 ShowCustomSize.Caption:='';

 mwidth:=MapCoreBase.GetMapWidth(MapCoreBase.GetCurrentMap);
 mheight:=MapCoreBase.GetMapHeight(MapCoreBase.GetCurrentMap);

 if (mwidth=8) and (mheight=8) then ReSizeMap8x8.Checked:=true
 else if (mwidth=16) and (mheight=16) then ReSizeMap16x16.Checked:=true
 else if (mwidth=32) and (mheight=32) then ReSizeMap32x32.Checked:=true
 else if (mwidth=64) and (mheight=64) then ReSizeMap64x64.Checked:=true
 else if (mwidth=128) and (mheight=128) then ReSizeMap128x128.Checked:=true
 else if (mwidth=256) and (mheight=256) then ReSizeMap256x256.Checked:=true
 else
 begin
   //if custom set checked and dimensions
   ShowCustomSize.Checked:=true;
   ShowCustomSize.Caption:=IntToStr(mwidth)+'x'+IntToStr(mheight);
 end;

 ReSize8x8.Checked:=false;
 ReSize16x16.Checked:=false;
 ReSize32x32.Checked:=false;
 ReSize64x64.Checked:=false;
 ReSize128x128.Checked:=false;
 ReSize256x256.Checked:=false;
 ShowTileCustomSize.Checked:=false;
 ShowTileCustomSize.Caption:='';

 twidth:=MapCoreBase.GetMapTileWidth(MapCoreBase.GetCurrentMap);
 theight:=MapCoreBase.GetMapTileHeight(MapCoreBase.GetCurrentMap);

 if (twidth=8) and (theight=8) then  ReSize8x8.Checked:=true
 else if (twidth=16) and (theight=16) then  ReSize16x16.Checked:=true
 else if (twidth=32) and (theight=32) then  ReSize32x32.Checked:=true
 else if (twidth=64) and (theight=64) then  ReSize64x64.Checked:=true
 else if (twidth=128) and (theight=128) then  ReSize128x128.Checked:=true
 else if (twidth=256) and (theight=256) then  ReSize256x256.Checked:=true
 else
 begin
   ShowTileCustomSize.Checked:=true;
   ShowTileCustomSize.Caption:=IntToStr(twidth)+'x'+IntToStr(theight);
   MapCoreBase.SetMapTileSize(MapCoreBase.GetCurrentMap,twidth,theight);
 end;
end;

procedure TMapEdit.ReSizeMapClick(Sender: TObject);
var
  mwidth,mheight : integer;
begin
 Case (Sender As TMenuItem).Name of 'ReSizeMap8x8' :begin
                                                      mwidth:=8;
                                                      mheight:=8;
                                                    end;
                                    'ReSizeMap16x16' :begin
                                                      mwidth:=16;
                                                      mheight:=16;
                                                    end;
                                    'ReSizeMap32x32' :begin
                                                      mwidth:=32;
                                                      mheight:=32;
                                                    end;
                                    'ReSizeMap64x64' :begin
                                                      mwidth:=64;
                                                      mheight:=64;
                                                    end;
                                    'ReSizeMap128x128' :begin
                                                      mwidth:=128;
                                                      mheight:=128;
                                                    end;
                                    'ReSizeMap256x256' :begin
                                                      mwidth:=256;
                                                      mheight:=256;
                                                    end;
                                    'SetMapCustomSize' :begin
                                                      mwidth:=setcustommapsizeform.SpinEditCustomWidth.Value;
                                                      mheight:=setcustommapsizeform.SpinEditCustomHeight.Value;
                                                    end;

 end;

 //Resizing invalidates every undo snapshot - a level captured at one size
 //cannot be restored into another - so say so before throwing the history away.
 if MapCoreBase.CanUndo(CurrentMap) or MapCoreBase.CanRedo(CurrentMap) then
   if MessageDlg('Resize Map',
      'Resizing will clear the undo history for this map.'+LineEnding+LineEnding+
      'Continue?',mtConfirmation,[mbYes,mbNo],0) <> mrYes then exit;

 MapCoreBase.ResizeMapSize(CurrentMap,mwidth,mheight);
 UpdateStatusSettings;   //map size is shown in the status bar
// TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
// TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);
 UpdateEditMenus;
 UpdatePageSize;
// UpdateMapView;
 MapPaintBox.Invalidate;
 UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
 MapListView.Repaint;
end;

procedure TMapEdit.SetMapCustomSizeClick(Sender: TObject);
begin
  if SetCustomMapSizeForm.ShowModal = mrOK then
  begin
     ReSizeMapClick(Sender);
  end;
end;

procedure TMapEdit.SetTileCustomSizeClick(Sender: TObject);
begin
  if SetCustomTileSizeForm.ShowModal = mrOK then
  begin
     ReSizeTiles(Sender);
  end;
end;

procedure TMapEdit.TileModeDrawClick(Sender: TObject);
begin
  TileMode:=tlModeDraw;
  MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
//  RadioDraw.Checked:=true;
  UpdateMenus;
end;

procedure TMapEdit.TileModeEraseClick(Sender: TObject);
begin
 TileMode:=tlModeErase;
 MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
// RadioErase.Checked:=true;
 UpdateMenus;
end;

procedure TMapEdit.RadioDrawClick(Sender: TObject);
begin
  TileMode:=tlModeDraw;
  MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
  UpdateMenus;
end;

procedure TMapEdit.RadioEraseClick(Sender: TObject);
begin
 TileMode:=tlModeErase;
 MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
 UpdateMenus;
end;

procedure TMapEdit.ReSizeTiles(Sender: TObject);
var
  tw,th,zs : integer;
begin
   Case (Sender As TMenuItem).Name of 'ReSize8x8' :begin
                                                     tw:=8;
                                                     th:=8;
                                                     zs:=1;
                                                   end;
                                    'ReSize16x16' :begin
                                                     tw:=16;
                                                     th:=16;
                                                     zs:=1;
                                                   end;
                                    'ReSize32x32' :begin
                                                     tw:=32;
                                                     th:=32;
                                                     zs:=1;
                                                   end;
                                    'ReSize64x64' :begin
                                                     tw:=64;
                                                     th:=64;
                                                     zs:=1;
                                                   end;
                                    'ReSize128x128' :begin
                                                     tw:=128;
                                                     th:=128;
                                                     zs:=1;
                                                   end;
                                    'ReSize256x256' :begin
                                                     tw:=256;
                                                     th:=256;
                                                     zs:=1;
                                                   end;
                                    'SetTileCustomSize':begin
                                                          tw:=SetCustomTileSizeForm.SpinEditTileWidth.Value;
                                                          th:=SetCustomTileSizeForm.SpinEditTileHeight.Value;
                                                          zs:=1;
                                                        end;
  End;

  MapCoreBase.SetZoomSize(CurrentMap,zs);
  TileZoom.Position:=zs;
  MapCoreBase.SetMapTileSize(CurrentMap,tw,th);
  TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
  TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);
  UpdatePageSize;
  LoadTilesToTileImageList;
  //UpdateMapView;
  UpdateEditMenus;
  UpdateStatusSettings;   //tile size is shown in the status bar
  MapPaintBox.Invalidate;
end;

//0 erase 1 draw tile
Procedure TMapEdit.SetMapTileMode(tlTileMode : integer);
begin
  TileMode:=tlTileMode;
  MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
  TileModeErase.Checked:=false;
  TileModeDraw.Checked:=false;

  if TileMode = tlModeErase then
  begin
    RadioErase.Checked:=true;
    TileModeErase.Checked:=true;
  end
  else if TileMode = tlModeDraw then
  begin
    RadioDraw.Checked:=true;
    TileModeDraw.Checked:=true;
  end;
end;

procedure TMapEdit.LoadTile(index : integer);
var
  i,j,awidth,aheight : integer;
begin
 //set ctile to selected image
 CTile.ImageIndex:=Index;

// if ImageThumbBase.;
 CTile.ImageUID:=ImageThumbBase.GetUID(Index);

 aheight:=ImageThumbBase.GetHeight(index);
 awidth:=ImageThumbBase.GetWidth(index);
 CTileBitmap.SetSize(awidth,aheight);

// SelectedTileImage.Canvas.Clear;
 For j:=0 to aheight-1 do
 begin
   For i:=0 to awidth-1 do
   begin
     CTileBitMap.Canvas.Pixels[i,j]:=ImageThumbBase.GetPixelTColor(Index,i,j);
   end;
 end;
end;

//Ctrl+Left click tile picker (eyedropper).
//Reads the tile sitting under the mouse on the layer currently being edited
//and makes it the active tile, exactly as if the user had clicked that
//thumbnail over in the tile palette. Returns false - and changes nothing -
//when the cell is outside the map or holds no tile, so the caller can tell a
//real pick from a click on empty space.
function TMapEdit.PickTileAt(x,y : integer) : boolean;
var
  T     : TileRec;
  mx,my : integer;
  index : integer;
  cm    : integer;
begin
  PickTileAt:=false;

  cm:=MapCoreBase.GetCurrentMap;

  mx:=GetMapX(x);
  my:=GetMapY(y);

  //the paint box can be larger than the map, so a click off the right or
  //bottom edge has to be rejected rather than clamped - clamping would pick
  //a tile the user never pointed at
  if (mx < 0) or (my < 0) then exit;
  if (mx > MapCoreBase.GetMapWidth(cm)-1) then exit;
  if (my > MapCoreBase.GetMapHeight(cm)-1) then exit;

  //GetMapTile follows the current layer, which is what we want - the picker
  //should sample the layer you are drawing on, not whatever is visible on top
  MapCoreBase.GetMapTile(cm,mx,my,T);

  //nothing to pick up out of an empty or broken cell
  if (T.ImageIndex = TileClear) or (T.ImageIndex = TileMissing) then exit;

  //The UID is the reliable handle. A stored ImageIndex can drift out of date
  //if tiles were inserted or deleted after the map was painted, so resolve
  //through the UID first and only fall back to the raw index for older maps
  //that were saved before UIDs were written out.
  index:=ImageThumbBase.FindUID(T.ImageUID);
  if index = -1 then
  begin
    index:=T.ImageIndex;
    if (index < 0) or (index > ImageThumbBase.GetCount-1) then exit;
  end;

  LoadTile(index);
  UpdateCurrentTile;

  //keep the palette in step so the highlighted thumbnail agrees with CTile,
  //and scroll it into view - the picked tile is often far down the list.
  //This assigns ItemIndex directly, which does not re-enter TileListViewClick.
  if (index >= 0) and (index < TileListView.Items.Count) then
  begin
    TileListView.ItemIndex:=index;
    TileListView.Items[index].MakeVisible(false);
  end;

  UpdateToolSelectionIcons;
  UpdateMenus;

  PickTileAt:=true;
end;

procedure TMapEdit.LoadTilesToTileImageList;
var
  index,i,j,awidth,aheight : integer;
  SrcBitMap,DstBitMap,TransBitMap : TBitMap;
begin
 TileImageList.Width:=TileWidth;
 TileImageList.Height:=TileHeight;
 TileImageList.Clear;

 TransTileImageList.Width:=TileWidth;
 TransTileImageList.Height:=TileHeight;
 TransTileImageList.Clear;

 DstBitMap:=TBitMap.Create;
 DstBitMap.SetSize(TileWidth,TileHeight);

 SrcBitMap:=TBitMap.Create;

 for index:=0 to ImageThumbBase.GetCount-1 do
 begin
   awidth:=ImageThumbBase.GetWidth(index);
   aheight:=ImageThumbBase.GetHeight(index);

   SrcBitMap.SetSize(awidth,aheight);

   // build normal tile
   For j:=0 to aheight-1 do
   begin
     For i:=0 to awidth-1 do
     begin
       SrcBitMap.Canvas.Pixels[i,j]:=ImageThumbBase.GetPixelTColor(Index,i,j);
     end;
   end;

   DstBitMap.Canvas.Clear;
   DstBitMap.Canvas.CopyRect( Rect(0, 0, TileWidth, TileHeight), SrcBitMap.Canvas, Rect(0, 0,aWidth, aHeight));
   TileImageList.Add(DstBitMap,NIL);

   // build transparent tile - same content but with color 0 as transparent
   // NOTE: must be a fresh TBitmap each iteration with transparency set
   // BEFORE drawing content - reusing one bitmap with Transparent=True
   // corrupts every tile after the first
   TransBitMap:=TBitMap.Create;
   TransBitMap.Width:=TileWidth;
   TransBitMap.Height:=TileHeight;
   TransBitMap.TransparentColor:=GetColor0TColor;
   TransBitMap.TransparentMode:=tmFixed;
   TransBitMap.Transparent:=True;
   TransBitMap.Canvas.CopyRect( Rect(0, 0, TileWidth, TileHeight), SrcBitMap.Canvas, Rect(0, 0,aWidth, aHeight));
   TransTileImageList.Add(TransBitMap,NIL);
   TransBitMap.Free;
 end;
 SrcBitMap.Free;
 DstBitMap.Free;
end;

//Flip and scroll are whole map operations. Running them on the active layer
//alone would slide the terrain out from under the decoration that was drawn
//to match it, so they are applied to every layer.
procedure TMapEdit.ApplyToAllLayers(op,x,y,x2,y2 : integer);
var
  l,save,cm : integer;
begin
  cm:=MapCoreBase.GetCurrentMap;
  save:=MapCoreBase.GetCurrentLayer(cm);
  for l:=0 to MapCoreBase.GetLayerCount(cm)-1 do
  begin
    MapCoreBase.SetCurrentLayer(cm,l);
    case op of
      mlopHFlip       : MapCoreBase.HFlip(cm,x,y,x2,y2);
      mlopVFlip       : MapCoreBase.VFlip(cm,x,y,x2,y2);
      mlopScrollLeft  : MapCoreBase.ScrollLeft(cm,x,y,x2,y2);
      mlopScrollRight : MapCoreBase.ScrollRight(cm,x,y,x2,y2);
      mlopScrollUp    : MapCoreBase.ScrollUp(cm,x,y,x2,y2);
      mlopScrollDown  : MapCoreBase.ScrollDown(cm,x,y,x2,y2);
    end;
  end;
  MapCoreBase.SetCurrentLayer(cm,save);
end;


//=============================================================================
// LAYER PANEL
//
// One control does both jobs: the CHECKBOX is visibility, the SELECTED ROW is
// the layer being edited. That is the convention every layer UI uses, so it
// needs no explanation and costs one list box instead of a set of widgets.
//
// The list shows the TOPMOST layer first, which is the reverse of the array
// index - see LayerRowToIndex. Do not "tidy" that away.
//=============================================================================

function TMapEdit.LayerRowToIndex(row : integer) : integer;
begin
  //row 0 is the top of the draw order = highest layer index
  LayerRowToIndex:=MapCoreBase.GetLayerCount(CurrentMap)-1-row;
end;

function TMapEdit.LayerIndexToRow(layer : integer) : integer;
begin
  LayerIndexToRow:=MapCoreBase.GetLayerCount(CurrentMap)-1-layer;
end;

procedure TMapEdit.ClearLoadedSelections;
var
  m : integer;
begin
  for m:=0 to MapCoreBase.GetMapCount-1 do
    MapCoreBase.SetMapClipStatus(m,0);
end;

//Each of the three refreshers updates the status bar itself, so adding or
//deleting a layer, hitbox or path is reflected there no matter which handler
//did it - several call the individual refreshers rather than this one.
procedure TMapEdit.RefreshMapPanels;
begin
  RefreshLayerPanel;
  UpdateHitBoxListView;
  UpdatePathListView;
end;

procedure TMapEdit.RefreshLayerPanel;
var
  l,row,n : integer;
begin
  if LayerListBox = nil then exit;      //can fire before the form is streamed
  if LayerPanel = nil then exit;

  n:=MapCoreBase.GetLayerCount(CurrentMap);

  //The panel lives on its own tab now, so it is always present - no hiding
  //rule and no View menu toggle. The tab caption carries the count.
  TabLayers.Caption:='Layers ('+IntToStr(n)+')';

  FUpdatingLayerPanel:=true;            //stop OnClick reacting to our own edits
  try
    LayerListBox.Items.BeginUpdate;
    LayerListBox.Items.Clear;
    for row:=0 to n-1 do
    begin
      l:=LayerRowToIndex(row);
      LayerListBox.Items.Add(MapCoreBase.GetLayerName(CurrentMap,l));
      LayerListBox.Checked[row]:=MapCoreBase.GetLayerVisible(CurrentMap,l);
    end;
    LayerListBox.Items.EndUpdate;

    LayerListBox.ItemIndex:=LayerIndexToRow(MapCoreBase.GetCurrentLayer(CurrentMap));
  finally
    FUpdatingLayerPanel:=false;
  end;

  BtnLayerAdd.Enabled:=(n < MaxMapLayers);
  BtnLayerDel.Enabled:=(n > 1);
  UpdateStatusSettings;
end;

procedure TMapEdit.LayerListBoxClick(Sender: TObject);
var
  l : integer;
begin
  if FUpdatingLayerPanel then exit;
  if LayerListBox.ItemIndex < 0 then exit;

  l:=LayerRowToIndex(LayerListBox.ItemIndex);
  MapCoreBase.SetCurrentLayer(CurrentMap,l);
  UpdateStatusSettings;

  //Selecting a hidden layer would mean drawing into something you cannot
  //see, which is never what was meant - make it visible instead.
  if not MapCoreBase.GetLayerVisible(CurrentMap,l) then
  begin
    MapCoreBase.SetLayerVisible(CurrentMap,l,true);
    RefreshLayerPanel;
    MapPaintBox.Invalidate;
  end;
  UpdateInfoBar;
end;

procedure TMapEdit.LayerListBoxItemClick(Sender: TObject; Index: integer);
var
  l,k,other : integer;
begin
  if FUpdatingLayerPanel then exit;
  if (Index < 0) or (Index >= LayerListBox.Items.Count) then exit;

  l:=LayerRowToIndex(Index);
  MapCoreBase.SetLayerVisible(CurrentMap,l,LayerListBox.Checked[Index]);

  //Clicking a check box also SELECTS that row, so OnClick has already run and
  //made this the active layer. Forcing the tick back on here would mean no
  //box could ever be unchecked - instead move editing to another visible
  //layer and leave the tick alone.
  if (not LayerListBox.Checked[Index]) and (MapCoreBase.GetCurrentLayer(CurrentMap) = l) then
  begin
    other:=-1;
    for k:=0 to MapCoreBase.GetLayerCount(CurrentMap)-1 do
      if (k <> l) and MapCoreBase.GetLayerVisible(CurrentMap,k) then
      begin
        other:=k;
        break;
      end;

    if other >= 0 then
    begin
      MapCoreBase.SetCurrentLayer(CurrentMap,other);
      FUpdatingLayerPanel:=true;
      LayerListBox.ItemIndex:=LayerIndexToRow(other);
      FUpdatingLayerPanel:=false;
    end
    else
    begin
      //last visible layer - hiding it would leave nothing to draw into
      MapCoreBase.SetLayerVisible(CurrentMap,l,true);
      FUpdatingLayerPanel:=true;
      LayerListBox.Checked[Index]:=true;
      FUpdatingLayerPanel:=false;
    end;
  end;

  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.BtnLayerAddClick(Sender: TObject);
var
  l : integer;
begin
  l:=MapCoreBase.AddLayer(CurrentMap);
  if l < 0 then
  begin
    ShowMessage('A map can have at most '+IntToStr(MaxMapLayers)+' layers.');
    exit;
  end;
  MapCoreBase.SetCurrentLayer(CurrentMap,l);
  RefreshLayerPanel;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.BtnLayerDelClick(Sender: TObject);
var
  l : integer;
begin
  if MapCoreBase.GetLayerCount(CurrentMap) <= 1 then exit;
  l:=MapCoreBase.GetCurrentLayer(CurrentMap);

  if MessageDlg('Delete Layer',
     'Delete layer "'+MapCoreBase.GetLayerName(CurrentMap,l)+'" and everything on it?',
     mtConfirmation,[mbYes,mbNo],0) <> mrYes then exit;

  MapCoreBase.CopyToUndo(CurrentMap);
  MapCoreBase.DeleteLayer(CurrentMap,l);
  RefreshLayerPanel;
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.BtnLayerDupClick(Sender: TObject);
var
  src,dst,i,j : integer;
  T : TileRec;
begin
  src:=MapCoreBase.GetCurrentLayer(CurrentMap);
  dst:=MapCoreBase.AddLayer(CurrentMap);
  if dst < 0 then
  begin
    ShowMessage('A map can have at most '+IntToStr(MaxMapLayers)+' layers.');
    exit;
  end;

  for j:=0 to MapCoreBase.GetMapHeight(CurrentMap)-1 do
    for i:=0 to MapCoreBase.GetMapWidth(CurrentMap)-1 do
    begin
      MapCoreBase.GetMapTileL(CurrentMap,src,i,j,T);
      MapCoreBase.SetMapTileL(CurrentMap,dst,i,j,T);
    end;

  MapCoreBase.SetLayerName(CurrentMap,dst,
    Copy(MapCoreBase.GetLayerName(CurrentMap,src)+' copy',1,31));
  MapCoreBase.SetCurrentLayer(CurrentMap,dst);
  RefreshLayerPanel;
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

//"Up" means up the draw order - closer to the viewer - which is a HIGHER
//layer index and a row nearer the top of the list.
procedure TMapEdit.BtnLayerUpClick(Sender: TObject);
begin
  MapCoreBase.MoveLayer(CurrentMap,MapCoreBase.GetCurrentLayer(CurrentMap),1);
  RefreshLayerPanel;
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.BtnLayerDownClick(Sender: TObject);
begin
  MapCoreBase.MoveLayer(CurrentMap,MapCoreBase.GetCurrentLayer(CurrentMap),-1);
  RefreshLayerPanel;
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.BtnLayerRenameClick(Sender: TObject);
var
  l : integer;
  s : string;
begin
  l:=MapCoreBase.GetCurrentLayer(CurrentMap);
  s:=MapCoreBase.GetLayerName(CurrentMap,l);
  if InputQuery('Rename Layer','Layer name:',s) then
  begin
    MapCoreBase.SetLayerName(CurrentMap,l,s);
    RefreshLayerPanel;
  end;
end;

Procedure TMapEdit.VerifyTileImageList;
var
  i,j,l  : integer;
  T      : TileRec;
  FIndex : integer;
begin
 //Every layer must be remapped, not just the active one - a sprite delete
 //affects tile indexes wherever that sprite was used.
 //
 //j = row (y) walks the map HEIGHT, i = column (x) walks the map WIDTH.
 //GetMapTileL/SetMapTileL take (x,y) and silently exit when out of range,
 //so swapping these bounds makes non-square maps only partly remap.
 for l:=0 to MapCoreBase.GetLayerCount(CurrentMap)-1 do
 begin
   for j:=0 to MapCoreBase.GetMapHeight(CurrentMap)-1 do
   begin
     for i:=0 to MapCoreBase.GetMapWidth(CurrentMap)-1 do
     begin
       MapCoreBase.GetMapTileL(CurrentMap,l,i,j,T);
       if (T.ImageIndex<>TileMissing) and (T.ImageIndex<>TileClear)  then
       begin
         FIndex:=ImageThumbBase.FindUID(T.ImageUID);
         if  FIndex = -1 then             // if -1 it was deleted lets update map info
         begin
           T.ImageIndex:=TileMissing;
           MapCoreBase.SetMapTileL(CurrentMap,l,i,j,T);
         end
         else if Findex<>T.ImageIndex then  //oh oh image is in a different index now - lets update
         begin
           T.ImageIndex:=FIndex;
           MapCoreBase.SetMapTileL(CurrentMap,l,i,j,T);
         end;
       end;
     end;
   end;
 end;
end;

procedure TMapEdit.TileListViewClick(Sender: TObject);
var
  item  : TListItem;
//  awidth,aheight : integer;
begin
 if (TileListview.SelCount > 0)  then
 begin
    item:=TileListView.LastSelected;
  //  aheight:=ImageThumbBase.GetHeight(item.index);
  //  awidth:=ImageThumbBase.GetWidth(item.index);

  //  SelectedTilePanel.AutoSize:=true;
  //  SelectedTileImage.AutoSize:=true;
  //  SelectedTileImage.Picture.Bitmap.SetSize(awidth,aheight);

  //  SelectedTilePanel.AutoSize:=false;
  //  SelectedTileImage.AutoSize:=false;

    LoadTile(item.Index);
    UpdateCurrentTile;
    UpdateToolSelectionIcons;
    UpdateMenus;

 end;
end;

procedure TMapEdit.ApplyMapZoom(newsize : integer; useAnchor : boolean; anchorX : integer; anchorY : integer);
var
  tw,th : integer;
  oldTileW, oldTileH : integer;
  tileX, tileY : double;
  newScrollX, newScrollY : integer;
begin
  if newsize < TileZoom.Min then newsize:=TileZoom.Min;
  if newsize > TileZoom.Max then newsize:=TileZoom.Max;
  //NOTE: no early exit when newsize = current zoom - initial layout
  //relies on this proc running even when the value is unchanged

  //remember which map tile position sits under the anchor point so it
  //stays under the cursor after zooming
  oldTileW:=TileWidth;
  oldTileH:=TileHeight;
  tileX:=0; tileY:=0;
  if useAnchor and (oldTileW > 0) and (oldTileH > 0) then
  begin
    tileX:=(MapScrollBox.HorzScrollBar.Position + anchorX) / oldTileW;
    tileY:=(MapScrollBox.VertScrollBar.Position + anchorY) / oldTileH;
  end;

  tw:=MapCoreBase.GetMapTileWidth(CurrentMap);
  th:=MapCoreBase.GetMapTileHeight(CurrentMap);

  MapCoreBase.SetZoomSize(CurrentMap,newsize);
  MapCoreBase.SetMapTileSize(CurrentMap,tw,th);

  TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
  TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);
  UpdatePageSize;
  LoadTilesToTileImageList;

  //keep the anchored tile position under the cursor
  if useAnchor then
  begin
    newScrollX:=Round(tileX * TileWidth) - anchorX;
    newScrollY:=Round(tileY * TileHeight) - anchorY;
    if newScrollX < 0 then newScrollX:=0;
    if newScrollY < 0 then newScrollY:=0;
    MapScrollBox.HorzScrollBar.Position:=newScrollX;
    MapScrollBox.VertScrollBar.Position:=newScrollY;
  end;

  //keep the trackbar in sync without retriggering
  if TileZoom.Position <> newsize then
  begin
    TileZoom.OnChange:=nil;
    TileZoom.Position:=newsize;
    TileZoom.OnChange:=@TileZoomChange;
  end;

  UpdateEditMenus;
  //zoom, and the tile size derived from it, are both shown in the status bar
  UpdateStatusSettings;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.TileZoomChange(Sender: TObject);
begin
  ApplyMapZoom(TileZoom.Position, False);
end;

procedure TMapEdit.MapScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint;
begin
  //zoom with the wheel, anchored on the map tile under the mouse cursor
  pt:=MapScrollBox.ScreenToClient(MousePos);
  if WheelDelta > 0 then
    ApplyMapZoom(MapCoreBase.GetZoomSize(CurrentMap) + 1, True, pt.X, pt.Y)
  else
    ApplyMapZoom(MapCoreBase.GetZoomSize(CurrentMap) - 1, True, pt.X, pt.Y);
  Handled:=True;
end;

procedure TMapEdit.UpdateTileView;
var
  i,count : integer;
begin
 count:=ImageThumbBase.GetCount;
 TileListView.items.Clear;

 for i:=1 to count do
 begin
   TileListView.Items.Add;
 end;

 For i:=0 to TileListView.Items.Count-1 do
 begin
   TileListView.Items[i].Caption:='Image '+IntToStr(i+1);
   TileListView.Items[i].ImageIndex:=i;
 end;
end;



procedure TMapEdit.MapPreviewPlotTile(MPCanvas : TCanvas;mx,my : integer;var TTile : TileRec);
var
  gx,gy : integer;
begin
 gx:=mx*TileWidth;
 gy:=my*TileHeight;
 TileImageList.Draw(MPCanvas,gx,gy,TTile.ImageIndex,true);
end;

procedure TMapEdit.MapPreviewPlotTileTransparent(MPCanvas : TCanvas;mx,my : integer;var TTile : TileRec);
var
  gx, gy : integer;
begin
  if (TTile.ImageIndex < 0) or (TTile.ImageIndex >= TransTileImageList.Count) then exit;
  gx:=mx * TileWidth;
  gy:=my * TileHeight;
  TransTileImageList.Draw(MPCanvas, gx, gy, TTile.ImageIndex);
end;

Procedure TMapEdit.UpdateMapPreviewImageIcons(MapIndex,ImageAction : integer);
var
  i,j,l,index : integer;
  T   : TileRec;
  SrcBitMap,DstBitMap : TBitMap;
  mwidth,mheight : integer;
begin
 //=== INTENTIONAL - DO NOT "FIX" ===========================================
 // The preview icon deliberately renders ONLY the first 32x32 tiles of the
 // map, starting at the top-left corner. It is NOT meant to show the whole
 // map. Rendering every tile of a large map here makes the program hang and
 // become very slow, because this runs on every map add/update.
 // If this looks like a bug because big maps show only a partial preview:
 // it is not. Leave the 32 tile clamp alone.
 //==========================================================================
 mwidth:=MapCoreBase.GetMapWidth(MapIndex);
 if mwidth > 32 then mwidth:=32;
 mheight:=MapCoreBase.GetMapHeight(MapIndex);
 if mheight > 32 then mheight:=32;

 SrcBitMap:=TBitMap.Create;
 SrcBitMap.SetSize(mwidth*TileWidth,mheight*TileHeight);

 DstBitMap:=TBitMap.Create;
 DstBitMap.SetSize(256,256);

 if ShowTransparent then
 begin
   // set transparency on SrcBitMap BEFORE drawing tiles onto it
   SrcBitMap.TransparentColor:=GetColor0TColor;
   SrcBitMap.TransparentMode:=tmFixed;
   SrcBitMap.Transparent:=True;

   // fill background with the transparent color so untouched pixels show through
   SrcBitMap.Canvas.Brush.Color:=GetColor0TColor;
   SrcBitMap.Canvas.FillRect(0, 0, SrcBitMap.Width, SrcBitMap.Height);

   // draw fixed checkerboard on DstBitMap at destination size
   DstBitMap.Canvas.Draw(0, 0, FCheckerBmp);
 end;

 //composite the visible layers bottom to top, same order as the main view
 for l:=0 to MapCoreBase.GetLayerCount(MapIndex)-1 do
 begin
   if not MapCoreBase.GetLayerVisible(MapIndex,l) then continue;

   for j:=0 to mheight-1 do
   begin
     for i:=0 to mwidth-1 do
     begin
       MapCoreBase.GetMapTileL(MapIndex,l,i,j,T);
       if T.ImageIndex > TileClear then
       begin
         //layers above the base always composite with transparency so the
         //terrain underneath is not boxed out
         if ShowTransparent or (l > 0) then
           MapPreviewPlotTileTransparent(SrcBitMap.Canvas,i,j,T)
         else
           MapPreviewPlotTile(SrcBitMap.Canvas,i,j,T);
       end;
     end;
   end;
 end;

  if ShowTransparent then
    DstBitMap.Canvas.StretchDraw(Rect(0, 0, 256, 256), SrcBitMap)
  else
    DstBitMap.canvas.CopyRect(Rect(0, 0, DstBitMap.Width, DstBitMap.Height), SrcBitMap.Canvas, Rect(0, 0, SrcBitMap.Width, SrcBitMap.Height));

  if ImageAction = AddImage then
  begin
     index:=MapImageList.add(DstBitMap,nil);
     MapListView.Items[MapIndex].ImageIndex:=index;
  end
  else if ImageAction = UpdateImage then
  begin
     MapImageList.Replace(MapIndex,DstBitMap,nil,false);
  end;
  SrcBitMap.Free;
  DstBitMap.Free;

end;

procedure TMapEdit.MapListViewClick(Sender: TObject);
var
  item : TListItem;
  zs,tw,th : integer;
begin
   if (MapListView.SelCount > 0) then
   begin
     item:=MapListView.LastSelected;
     MapCoreBase.SetMapScrollHorizPos(MapCoreBase.GetCurrentMap,MapScrollBox.HorzScrollBar.Position);
     MapCoreBase.SetMapScrollVertPos(MapCoreBase.GetCurrentMap,MapScrollBox.VertScrollBar.Position);

     MapCoreBase.SetCurrentMap(item.Index);
     CurrentMap:=MapCoreBase.GetCurrentMap;
     RefreshMapPanels;       //these lists all belong to the selected map

     tw:=MapCoreBase.GetMapTileWidth(CurrentMap);
     th:=MapCoreBase.GetMapTileHeight(CurrentMap);
     zs:=MapCoreBase.GetZoomSize(CurrentMap);
     MapCoreBase.SetZoomSize(CurrentMap,zs);
     TileZoom.Position:=zs;
     MapCoreBase.SetMapTileSize(CurrentMap,tw,th);

     TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
     TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);

     UpdatePageSize;
     MapScrollBox.HorzScrollBar.Position:=MapCoreBase.GetMapScrollHorizPos(MapCoreBase.GetCurrentMap);
     MapScrollBox.VertScrollBar.Position:=MapCoreBase.GetMapScrollVertPos(MapCoreBase.GetCurrentMap);
     SetDrawTool(MapCoreBase.GetMapDrawTool(CurrentMap));
     TileMode:=MapCoreBase.GetMapTileMode(CurrentMap);
     UpdateToolSelectionIcons;
     UpdateMenus;
     UpdateEditMenus;
     UpdateHitBoxListView;
     SelectedHitBox:=-1;
     //UpdateMapView;
     MapPaintBox.Invalidate;
   end;
end;

Procedure TMapEdit.UpdateMapListView;
var
  i,count : integer;
begin
 count:=MapCoreBase.GetMapCount;
 MapListView.items.Clear;
 MapListView.LargeImages.Width:=256;
 MapListView.LargeImages.Height:=256;

 MapImageList.Clear;
 MapImageList.Width:=256;
 MapImageList.Height:=256;
// ShowMessage(IntToStr(count));
 For i:=0 to count-1 do
 begin
   MapListView.Items.Add;
   UpdateMapPreviewImageIcons(i,AddImage);
   MapListView.Items[i].Caption:='Map '+IntToStr(i+1);
   // MapListView.Items[i].ImageIndex:=i;
 end;
end;

procedure TMapEdit.UpdatePageSize;
begin
 MapPaintBox.Width:=0;
 MapPaintBox.Height:=0;
 MapPaintBox.Invalidate;

 MapPaintBox.Width:=MapCoreBase.GetZoomMapPageWidth(CurrentMap)+1;
 MapPaintBox.Height:=MapCoreBase.GetZoomMapPageHeight(CurrentMap)+1;
 MapPaintBox.Invalidate;
end;

procedure TMapEdit.UpdateCurrentTile;
var
  Bmp : TBitmap;
  x, y, checkSize : integer;
begin
  if ShowTransparent then
  begin
    // draw checkerboard background on selected tile preview
    checkSize:=16;
    for y:=0 to (256 div checkSize) - 1 do
    begin
      for x:=0 to (256 div checkSize) - 1 do
      begin
        if ((x + y) mod 2) = 0 then
          SelectedTileImage.Canvas.Brush.Color:=RGBToColor(192, 192, 192)
        else
          SelectedTileImage.Canvas.Brush.Color:=RGBToColor(255, 255, 255);
        SelectedTileImage.Canvas.FillRect(
          x * checkSize, y * checkSize,
          (x+1) * checkSize, (y+1) * checkSize);
      end;
    end;

    // draw tile with color 0 transparent on top of checkerboard
    Bmp:=TBitmap.Create;
    try
      Bmp.Width:=CTileBitMap.Width;
      Bmp.Height:=CTileBitMap.Height;
      Bmp.TransparentColor:=GetColor0TColor;
      Bmp.TransparentMode:=tmFixed;
      Bmp.Transparent:=True;
      Bmp.Canvas.Draw(0, 0, CTileBitMap);
      SelectedTileImage.Canvas.StretchDraw(Rect(0, 0, 256, 256), Bmp);
    finally
      Bmp.Free;
    end;
  end
  else
  begin
    SelectedTileImage.canvas.CopyRect(Rect(0, 0, 256, 256), CTileBitMap.Canvas, Rect(0, 0, CTileBitMap.Width, CTileBitMap.Height));
  end;
end;

function MapToolName(tool : integer) : string;
begin
  case tool of
    DrawShapePencil     : MapToolName:='Pencil';
    DrawShapeLine       : MapToolName:='Line';
    DrawShapeRectangle  : MapToolName:='Rectangle';
    DrawShapeFRectangle : MapToolName:='Filled Rect';
    DrawShapeCircle     : MapToolName:='Circle';
    DrawShapeFCircle    : MapToolName:='Filled Circle';
    DrawShapeEllipse    : MapToolName:='Ellipse';
    DrawShapeFEllipse   : MapToolName:='Filled Ellipse';
    DrawShapePaint      : MapToolName:='Fill';
    DrawShapeClip       : MapToolName:='Select Area';
    MapToolPath         : MapToolName:='Path';
    MapToolMove         : MapToolName:='Move';
  else
    MapToolName:='?';
  end;
end;

procedure TMapEdit.UpdateStatusSettings;
var
  s : string;
  cm,n : integer;
begin
  if StatusBar0 = nil then exit;              //can fire before streaming
  if StatusBar0.Panels.Count < 4 then exit;

  cm:=MapCoreBase.GetCurrentMap;

  //panel 2 - what the map is
  s:='Map '+IntToStr(cm+1)+'/'+IntToStr(MapCoreBase.GetMapCount)+
     '  Size: '+IntToStr(MapCoreBase.GetMapWidth(cm))+'x'+IntToStr(MapCoreBase.GetMapHeight(cm))+
     '  Tile: '+IntToStr(MapCoreBase.GetMapTileWidth(cm))+'x'+IntToStr(MapCoreBase.GetMapTileHeight(cm))+
     '  Zoom: '+IntToStr(MapCoreBase.GetZoomSize(cm))+'x';
  StatusBar0.Panels[2].Text:=s;

  //panel 3 - how it is being edited
  s:='Tool: '+MapToolName(DrawTool);

  n:=MapCoreBase.GetLayerCount(cm);
  s:=s+'  Layer: '+IntToStr(MapCoreBase.GetCurrentLayer(cm)+1)+'/'+IntToStr(n);
  if not MapCoreBase.GetLayerVisible(cm,MapCoreBase.GetCurrentLayer(cm)) then
    s:=s+'(hidden)';

  s:=s+'  Tiles: '+IntToStr(ImageThumbBase.GetCount);
  s:=s+'  HitBox: '+IntToStr(MapCoreBase.GetHitBoxCount(cm));
  s:=s+'  Paths: '+IntToStr(MapCoreBase.GetPathCount(cm));

  if MapCoreBase.GetMapGridStatus(cm) = 1 then s:=s+'  Grid';
  if ShowTransparent then s:=s+'  Trans';
  if ShowHitBoxOverlay then s:=s+'  HB';
  if ShowPathOverlay then s:=s+'  PathOv';

  StatusBar0.Panels[3].Text:=s;
end;

procedure TMapEdit.UpdateInfoBar;
var
  XYStr,WHStr   : string;
begin
 XYStr:='X = '+IntToStr(MapX)+' Y = '+IntToStr(MapY)+' '+
        'X2 = '+IntToStr(MapX2)+' Y2 = '+IntToStr(MapY2)+' ';
 WHStr:='Width = '+IntToStr(ABS(MapX2-MapX+1))+' Height = '+IntToStr(ABS(MapY2-MapY+1));
 StatusBar0.Panels[0].Text:=XYStr;
 StatusBar0.Panels[1].Text:=WHStr;
end;

procedure TMapEdit.UpdateMapInfo(x,y : integer);
var
 mx,my : integer;
 ClipStr : string;
 ColIndexStr : string;
 ca      : MapClipAreaRec;
 XYStr : string;
 TIndex : integer;
begin
  mx:=x div TileWidth;
  my:=y div TileHeight;

  XYStr:='X = '+IntToStr(MX)+' Y = '+IntToStr(MY)+' ';
  ColIndexStr:='';
  if (mx >= 0) and (my >= 0) then
   begin
     TIndex:=MapCoreBase.GetMapTileIndex(MapCoreBase.GetCurrentMap,mx,my);
     ColIndexStr:='Tile Index: '+IntToStr(TIndex);
   end;
   ClipStr:='';
   if MapCoreBase.GetMapClipStatus(MapCoreBase.GetCurrentMap) = 1 then
   begin
        MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
        ClipStr:='Select Area '+'X = '+IntToStr(ca.x)+' Y = '+IntToStr(ca.y)+' X2 = '+IntToStr(ca.x2)+' Y2 = '+IntToStr(ca.y2)+' '+
                 'Width = '+IntToStr(ca.x2-ca.x+1)+' Height = '+IntToStr(ca.y2-ca.y+1)+' ';
   end;

  StatusBar0.Panels[0].Text:=XYStr+ColIndexStr;
  StatusBar0.Panels[1].Text:=ClipStr;
end;

// xyx2y2 mouse ScrollDownMenu event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TMapEdit.MPaintBoxMouseDownXYX2Y2Tool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 ca : MapClipAreaRec;
begin
  MapX:=GetMapX(x);
  MapY:=GetMapY(y);
  MapX2:=MapX;
  MapY2:=MapY;
  UpdateInfoBar;
  OldMapX:=MapX;
  OldMapY:=MapY;

  if DrawTool = DrawShapeClip then
  begin
    ca.x:=MapX;
    ca.y:=MapY;
    ca.x2:=MapX2;
    ca.y2:=MapY2;
    MapCoreBase.SetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
    MapCoreBase.SetMapClipStatus(MapCoreBase.GetCurrentMap,1);
    MapPaintBox.Invalidate;
    exit;
  end;

//  UpdateRenderBitMap;
//  RenderBitMap2.Canvas.CopyRect(rect(0,0,RenderBitMap2.Width,RenderBitMap2.Height),RenderBitMap.Canvas,rect(0,0,RenderBitMap.Width,RenderBitMap.Height));
 // DrawItem(DrawTool,MapX,MapY,MapX,MapY,CTile.ImageIndex,0);
 RenderDrawToolShape:=true;
 MapPaintBox.Invalidate;
end;

// xyx2y2 mouse move event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TMapEdit.MPaintBoxMouseMoveXYX2Y2Tool(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
 ca : MapClipAreaRec;
begin
 if not ((ssLeft in Shift) or (ssRight in Shift)) then
 begin
    UpdateMapInfo(x,y); // we only have x,y
  exit;
 end;
 MapX2:=GetMapX(x);
 MapY2:=GetMapY(y);
 if (OldMapX=-1) or (OldMapY=-1) then exit;
 if (MapX2=OldMapX) and (MapY2=OldMapY) then exit; // we are just just drawing in the same  x,y

  //new spot
  OldMapX:=MapX2;
  OldMapY:=MapY2;
  UpdateInfoBar;

  //  DrawTool:=RMDRAWTools.GetDrawTool;
  if DrawTool = DrawShapeClip then
  begin
     ca.x:=MapX;
     ca.y:=MapY;
     ca.x2:=MapX2;
     ca.y2:=MapY2;

     MapCoreBase.SetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
     MapCoreBase.SetMapClipStatus(MapCoreBase.GetCurrentMap,1);
     MapPaintBox.Invalidate;
     exit;
  end;
  RenderDrawToolShape:=true;
  MapPaintBox.Invalidate; //draw the current
end;

// xyx2y2 mouse ScrollUpMenu event - this handles all the tools that just requires x,y,x2,y2 coords only - pixel and spraypaint
procedure TMapEdit.MPaintBoxMouseUpXYX2Y2Tool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (OldMapX=-1) or (OldMapY=-1) then exit;       //prevent ScrollRightMenu clicking from outsize of zoom area while moving into zoom area creates unwanted event - checking the coors allows to jump out with out drawing garbage
  OldMapX:=-1;
  OldMapY:=-1;
//  DrawTool:=RMDRAWTools.GetDrawTool;
  if TileMode = tlModeErase then
     DrawItem(DrawTool,MapX,MapY,MapX2,MapY2,TileClear,1)
  else
     DrawItem(DrawTool,MapX,MapY,MapX2,MapY2,CTile.ImageIndex,1);
  RenderDrawToolShape:=False;
  MapPaintBox.Invalidate;
end;

// xy mouse ScrollDownMenu event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TMapEdit.MPaintBoxMouseDownXYTool(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MapX:=GetMapX(x);
  MapY:=GetMapY(y);
//  if (MapX=OldMapX) and (MapY=OldMapY) then exit; // we are just just drawing in the same zoom x,y
 // breaks flood painting over the same tile if we uncomment

  OldMapX:=MapX;
  OldMapY:=MapY;
//  DrawTool:=RMDRAWTools.GetDrawTool;

  if DrawTool = DrawShapePaint then  // special kludge here - fix in future updates
  begin
    if TileMode = tlModeErase then  //erase mode
    begin
      if (ssLeft in Shift) and (ssShift in Shift) then
        ReplaceFill(MapX,MapY,MapCoreBase.GetMapWidth(CurrentMap),MapCoreBase.GetMapHeight(CurrentMap),TileClear,1)
      else
        FloodFill(MapX,MapY,MapCoreBase.GetMapWidth(CurrentMap),MapCoreBase.GetMapHeight(CurrentMap),TileClear,1);
    end
    else
    begin
      if (ssLeft in Shift) and (ssShift in Shift) then
         ReplaceFill(MapX,MapY,MapCoreBase.GetMapWidth(CurrentMap),MapCoreBase.GetMapHeight(CurrentMap),CTile.ImageIndex,1)
      else
         FloodFill(MapX,MapY,MapCoreBase.GetMapWidth(CurrentMap),MapCoreBase.GetMapHeight(CurrentMap),CTile.ImageIndex,1);
    end;
    RenderDrawToolShape:=False;
    MapPaintBox.Invalidate;
  end
  else
  begin
    if TileMode = tlModeErase then
      DrawItem(DrawTool,MapX,MapY,MapX,MapY,TileClear,1)
    else
      DrawItem(DrawTool,MapX,MapY,MapX,MapY,CTile.ImageIndex,1);

    RenderDrawToolShape:=False;
    MapPaintBox.Invalidate;
  end;
end;

// xy mouse move event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TMapEdit.MPaintBoxMouseMoveXYTool(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MapX:=GetMapX(x);
  MapY:=GetMapY(y);

  UpdateMapInfo(x,y);

  if (MapX=OldMapX) and (MapY=OldMapY) then exit; // we are just just drawing in the same zoom x,y

  OldMapX:=MapX;
  OldMapY:=MapY;

  if ((ssLeft in Shift) or (ssRight in Shift)) then
  begin
    DrawItem(DrawTool,MapX,MapY,MapX,MapY,CTile.ImageIndex,1);
    RenderDrawToolShape:=False;
    MapPaintBox.Invalidate;
  end;
end;

// xy mouse ScrollUpMenu event - this handles all the tools that just requires x,y coords only - pixel and spraypaint
procedure TMapEdit.MPaintBoxMouseUpXYTool(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  OldMapX:=-1;
  OldMapY:=-1;
end;

procedure TMapEdit.MPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 //Ctrl+Left picks up the tile under the cursor instead of painting with it.
 //Tested before ANY tool dispatch so the picker works with every tool, and
 //before CopyToUndo so sampling never burns an undo slot or drops the
 //selection - picking is a read, it must not count as an edit.
 if (Button = mbLeft) and (ssCtrl in Shift) then
 begin
   TilePickActive:=true;
   //clear any stale drag state so the swallowed click cannot be mistaken for
   //the start of a shape by a later mouse up
   OldMapX:=-1;
   OldMapY:=-1;
   PickTileAt(X,Y);
   MapPaintBox.Invalidate;
   exit;
 end;
 TilePickActive:=false;

 //The path tool edits path records, not tiles - it must not disturb the clip
 //area and must not push a tile undo snapshot for something undo cannot restore.
 if DrawTool = MapToolPath then
 begin
   MPaintBoxMouseDownPathTool(Sender,Button,Shift,X,Y);
   exit;
 end;

 if DrawTool = MapToolMove then
 begin
   MPaintBoxMouseDownMoveTool(Sender,Button,Shift,X,Y);
   exit;
 end;

 MapCoreBase.SetMapClipStatus(MapCoreBase.GetCurrentMap,0);  //turn it off - we turn on again when new area is selected
 if DrawTool<>DrawShapeClip then MapCoreBase.CopyToUndo(MapCoreBase.GetCurrentMap);
 Case DrawTool of DrawShapePencil,DrawShapeSpray,DrawShapePaint:MPaintBoxMouseDownXYTool(Sender,Button,Shift,X,Y);
                                  DrawShapeLine,DrawShapeRectangle,DrawShapeFRectangle,DrawShapeCircle,DrawShapeFCircle,
               DrawShapeEllipse,DrawShapeFEllipse,DrawShapeClip:MPaintBoxMouseDownXYX2Y2Tool(Sender,Button,Shift,X,Y);
 end;
end;

procedure TMapEdit.MPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 //A Ctrl drag keeps sampling rather than falling through to the tool. Without
 //this the pick would happen on mouse down and the drag would then paint over
 //the very tiles being sampled.
 if TilePickActive then
 begin
   if ssLeft in Shift then
     PickTileAt(X,Y)
   else
     TilePickActive:=false;   //button let go outside our up handler
   UpdateMapInfo(X,Y);
   exit;
 end;

 if DrawTool = MapToolPath then
 begin
   MPaintBoxMouseMovePathTool(Sender,Shift,X,Y);
   exit;
 end;

 if DrawTool = MapToolMove then
 begin
   MPaintBoxMouseMoveMoveTool(Sender,Shift,X,Y);
   exit;
 end;

 Case DrawTool of DrawShapePencil,DrawShapeSpray,DrawShapePaint:MPaintBoxMouseMoveXYTool(Sender,Shift,X,Y);
               DrawShapeLine,DrawShapeRectangle,DrawShapeFRectangle,DrawShapeCircle,DrawShapeFCircle,
               DrawShapeEllipse,DrawShapeFEllipse,DrawShapeClip:MPaintBoxMouseMoveXYX2Y2Tool(Sender,Shift,X,Y);

 end;
end;

procedure TMapEdit.MPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 //the pick already happened on mouse down - there is nothing to commit here,
 //and letting this reach the tool handlers would stamp a tile on release
 if TilePickActive then
 begin
   TilePickActive:=false;
   exit;
 end;

 //path points are placed on mouse DOWN - nothing to do here
 if DrawTool = MapToolPath then exit;

 if DrawTool = MapToolMove then
 begin
   MPaintBoxMouseUpMoveTool(Sender,Button,Shift,X,Y);
   exit;
 end;

 Case DrawTool of DrawShapePencil,DrawShapeSpray:MPaintBoxMouseUpXYTool(Sender,Button,Shift,X,Y);
               DrawShapeLine,DrawShapeRectangle,DrawShapeFRectangle,DrawShapeCircle,DrawShapeFCircle,
               DrawShapeEllipse,DrawShapeFEllipse:MPaintBoxMouseUpXYX2Y2Tool(Sender,Button,Shift,X,Y);

 end;
 UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
 MapListView.Repaint;
end;

procedure TMapEdit.ToolGridIconClick(Sender: TObject);
begin
 if MapCoreBase.GetMapGridStatus(MapCoreBase.GetCurrentMap) = 1 then
 begin
    MapCoreBase.SetMapGridStatus(MapCoreBase.GetCurrentMap,0);
 end
 else
 begin
   MapCoreBase.SetMapGridStatus(MapCoreBase.GetCurrentMap,1);
 end;
 UpdateMenus;
 UpdateStatusSettings;
 MapPaintBox.Invalidate;
end;

procedure TMapEdit.ToolHFLIPButtonClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  ApplyToAllLayers(mlopHFlip,ca.x,ca.y,ca.x2,ca.y2);
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolIconClick(Sender: TObject);
var
  PrevTool : integer;
begin
 PrevTool:=DrawTool;
 MapCoreBase.SetMapClipStatus(MapCoreBase.GetCurrentMap,0);
 Case (Sender As TImage).Name of 'ToolPencilIcon':DrawTool:=DrawShapePencil;
                                 'ToolLineIcon':DrawTool:=DrawShapeLine;
                                 'ToolRectangleIcon':DrawTool:=DrawShapeRectangle;
                                 'ToolFRectangleIcon':DrawTool:=DrawShapeFRectangle;
                                 'ToolFCircleIcon':DrawTool:=DrawShapeFCircle;
                                 'ToolCircleIcon':DrawTool:=DrawShapeCircle;
                                 'ToolEllipseIcon':DrawTool:=DrawShapeEllipse;
                                 'ToolFEllipseIcon':DrawTool:=DrawShapeFEllipse;
                                 'ToolPaintIcon':DrawTool:=DrawShapePaint;
                                 'ToolSprayPaintIcon':DrawTool:=DrawShapeSpray;
                                 'ToolSelectAreaIcon':DrawTool:=DrawShapeClip;
 end;
 MapCoreBase.SetMapDrawTool(MapCoreBase.GetCurrentMap,DrawTool);
 UpdateToolSelectionIcons;
 UpdateMenus;
 if PrevTool = DrawShapeClip then MapPaintBox.Invalidate; // removes select outline
end;


procedure TMapEdit.ToolMenuClick(Sender: TObject);
begin
  Case (Sender As TMenuItem).Name of 'ToolPencilMenu':DrawTool:=DrawShapePencil;
                                 'ToolLineMenu':DrawTool:=DrawShapeLine;
                                 'ToolRectangleMenu':DrawTool:=DrawShapeRectangle;
                                 'ToolFRectangleMenu':DrawTool:=DrawShapeFRectangle;
                                 'ToolFCircleMenu':DrawTool:=DrawShapeFCircle;
                                 'ToolCircleMenu':DrawTool:=DrawShapeCircle;
                                 'ToolEllipseMenu':DrawTool:=DrawShapeEllipse;
                                 'ToolFEllipseMenu':DrawTool:=DrawShapeFEllipse;
                                 'ToolPaintMenu':DrawTool:=DrawShapePaint;
                                 'ToolSprayPaintMenu':DrawTool:=DrawShapeSpray;
                                 'ToolSelectAreaMenu':DrawTool:=DrawShapeClip;
 end;
 MapCoreBase.SetMapDrawTool(MapCoreBase.GetCurrentMap,DrawTool);
 UpdateToolSelectionIcons;
 UpdateMenus;
 UpdateStatusSettings;   //this path bypasses SetDrawTool
end;

procedure TMapEdit.ToolScrollDownIconClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  ApplyToAllLayers(mlopScrollDown,ca.x,ca.y,ca.x2,ca.y2);
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolScrollLeftIconClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  ApplyToAllLayers(mlopScrollLeft,ca.x,ca.y,ca.x2,ca.y2);
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolScrollRightIconClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  ApplyToAllLayers(mlopScrollRight,ca.x,ca.y,ca.x2,ca.y2);
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolScrollUpIconClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  ApplyToAllLayers(mlopScrollUp,ca.x,ca.y,ca.x2,ca.y2);
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolUndoIconClick(Sender: TObject);
begin
 MapCoreBase.Undo(MapCoreBase.GetCurrentMap);
 //An undo level carries layers, hitboxes AND paths, so all three panels can
 //be out of date - not just the canvas.
 RefreshMapPanels;
 UpdatePageSize;
 MapPaintBox.Invalidate;
 UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
 MapListView.Repaint;
end;

procedure TMapEdit.ToolVFLIPButtonClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapCoreBase.Vflip(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2 );
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

Procedure TMapEdit.LoadResourceIcons;
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
end;

procedure TMapEdit.ClearCheckedMenus;
begin
  TileModeDraw.Checked:=false;
  TileModeErase.Checked:=false;

  ToolFRectangleMenu.Checked:=false;
  ToolRectangleMenu.Checked:=false;
  ToolLineMenu.Checked:=false;
  ToolSelectAreaMenu.Checked:=false;

  ToolSprayPaintMenu.Checked:=false;
  ToolPaintMenu.Checked:=false;
  ToolCircleMenu.Checked:=false;
  ToolFCircleMenu.Checked:=false;
  ToolEllipseMenu.Checked:=false;
  ToolFEllipseMenu.Checked:=false;

  ToolPencilMenu.Checked:=false;
  ToolGridMenu.Checked:=false;
end;

procedure TMapEdit.UpdateMenus;          // and Tile Mode radio buttons
begin
  ClearCheckedMenus;
  if TileMode = tlModeDraw then
  begin
     TileModeDraw.Checked:=true;
     RadioDraw.Checked:=true;
  end
  else
  begin
     TileModeErase.Checked:=true;
     RadioErase.Checked:=true;
  end;

  case DrawTool of DrawShapePencil:ToolPencilMenu.Checked:=true;
                     DrawShapeLine:ToolLineMenu.Checked:=true;
            DrawShapeCircle:  ToolCircleMenu.Checked:=true;
           DrawShapeFCircle:  ToolFCircleMenu.Checked:=true;
           DrawShapeEllipse:  ToolEllipseMenu.Checked:=true;
          DrawShapeFEllipse:  ToolFEllipseMenu.Checked:=true;
           DrawShapeRectangle:  ToolRectangleMenu.Checked:=true;
        DrawShapeFRectangle:  ToolFRectangleMenu.Checked:=true;
             DrawShapeSpray:  ToolSprayPaintMenu.Checked:=true;
             DrawShapePaint:  ToolPaintMenu.Checked:=true;
              DrawShapeClip:ToolSelectAreaMenu.Checked:=true;
  end;
  //MapToolPath is not in the case above, so ClearCheckedMenus has already
  //left every drawing tool unchecked - just tick the path entry itself.
  PathToolMenu.Checked:=(DrawTool = MapToolPath);
  MoveToolMenu.Checked:=(DrawTool = MapToolMove);

  if  MapCoreBase.GetMapGridStatus(MapCoreBase.GetCurrentMap)=1 then  ToolGridMenu.Checked:=true;
end;

procedure TMapEdit.UpdateToolSelectionIcons;
begin
  LoadResourceIcons;
 // DrawTool:=MapCoreBase.GetMapDrawTool(MapCoreBase.GetCurrentMap);
  case DrawTool of DrawShapePencil:ToolPencilIcon.Picture.LoadFromResourceName(HInstance,'PEN2');
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


{ ===== Maze Generator ===== }

function TileExists(var T : TileRec) : boolean;
begin
  if T.ImageIndex < 0 then begin TileExists:=false; exit; end;
  if T.ImageIndex >= ImageThumbBase.GetCount then begin TileExists:=false; exit; end;
  if ImageThumbBase.FindUID(T.ImageUID) = -1 then begin TileExists:=false; exit; end;
  TileExists:=true;
end;

procedure TMapEdit.MazeSetWallTileClick(Sender: TObject);
begin
  if CTile.ImageIndex < 0 then begin ShowMessage('No tile selected.'); exit; end;
  MazeWallTile:=CTile;
  MazeWallSet:=true;
  ShowMessage('Wall tile set to tile ' + IntToStr(CTile.ImageIndex) + '.');
end;

procedure TMapEdit.MazeSetPathTileClick(Sender: TObject);
begin
  if CTile.ImageIndex < 0 then begin ShowMessage('No tile selected.'); exit; end;
  MazePathTile:=CTile;
  MazePathSet:=true;
  ShowMessage('Path tile set to tile ' + IntToStr(CTile.ImageIndex) + '.');
end;

procedure TMapEdit.MazeSetSolutionTileClick(Sender: TObject);
begin
  if CTile.ImageIndex < 0 then begin ShowMessage('No tile selected.'); exit; end;
  MazeSolutionTile:=CTile;
  MazeSolutionSet:=true;
  ShowMessage('Solution tile set to tile ' + IntToStr(CTile.ImageIndex) + '.');
end;

procedure TMapEdit.MazeSetStartClick(Sender: TObject);
var
  ca : MapClipAreaRec;
begin
  if MapCoreBase.GetMapClipStatus(CurrentMap) = 0 then
  begin
    ShowMessage('Please use the Select tool to mark the start area first.');
    exit;
  end;
  MapCoreBase.GetMapClipAreaCoords(CurrentMap, ca);
  MazeStartX:=ca.x;
  MazeStartY:=ca.y;
  MazeStartSet:=true;
  ShowMessage('Start area set at tile (' + IntToStr(ca.x) + ',' + IntToStr(ca.y) + ').');
end;

procedure TMapEdit.MazeSetEndClick(Sender: TObject);
var
  ca : MapClipAreaRec;
begin
  if MapCoreBase.GetMapClipStatus(CurrentMap) = 0 then
  begin
    ShowMessage('Please use the Select tool to mark the end area first.');
    exit;
  end;
  MapCoreBase.GetMapClipAreaCoords(CurrentMap, ca);
  MazeEndX:=ca.x;
  MazeEndY:=ca.y;
  MazeEndSet:=true;
  ShowMessage('End area set at tile (' + IntToStr(ca.x) + ',' + IntToStr(ca.y) + ').');
end;

procedure TMapEdit.MazeGenerateClick(Sender: TObject);
var
  ca : MapClipAreaRec;
  mx, my, mw, mh : integer;
  difficulty : integer;
  useClip : boolean;
  //grid values: 0=wall, 1=path, 2=solution path (protected)
  grid : array of array of byte;
  i, j : integer;
  cx, cy : integer;
  runlen, d : integer;
  openChance : integer;
begin
  difficulty:=(Sender as TMenuItem).Tag;  //0=easy, 1=medium, 2=hard

  //verify tiles exist
  if not TileExists(MazeWallTile) then
  begin
    //reset to tile 0
    MazeWallTile.ImageIndex:=0;
    if ImageThumbBase.GetCount > 0 then
      MazeWallTile.ImageUID:=ImageThumbBase.GetUID(0)
    else
    begin
      ShowMessage('No tiles available. Please create at least 2 tiles first.');
      exit;
    end;
  end;

  if not MazePathSet then
  begin
    ShowMessage('Please set a path tile first using Maze > Set Current Tile as Path Tile.');
    exit;
  end;

  if not TileExists(MazePathTile) then
  begin
    ShowMessage('The path tile has been deleted. Please set a new path tile.');
    MazePathSet:=false;
    exit;
  end;

  //determine area
  useClip:=(MapCoreBase.GetMapClipStatus(CurrentMap) = 1);
  if useClip then
  begin
    MapCoreBase.GetMapClipAreaCoords(CurrentMap, ca);
    mx:=ca.x;
    my:=ca.y;
    mw:=ca.x2 - ca.x + 1;
    mh:=ca.y2 - ca.y + 1;
  end
  else
  begin
    mx:=0;
    my:=0;
    mw:=MapCoreBase.GetMapWidth(CurrentMap);
    mh:=MapCoreBase.GetMapHeight(CurrentMap);
  end;

  if (mw < 5) or (mh < 5) then
  begin
    ShowMessage('The area is too small to generate a maze. Minimum size is 5x5 tiles.' + LineEnding +
                'Current area: ' + IntToStr(mw) + 'x' + IntToStr(mh) + '.' + LineEnding +
                'Use the Select tool for a larger area, or resize the map.');
    exit;
  end;

  Randomize;

  //=== step 1: fill interior with walls, then explicitly draw the
  //four exterior walls around the map area ===
  SetLength(grid, mw, mh);
  for i:=0 to mw-1 do
    for j:=0 to mh-1 do
      grid[i][j]:=0;

  //top wall: top-left to top-right
  for i:=0 to mw-1 do grid[i][0]:=0;
  //left wall: top-left to bottom-left
  for j:=0 to mh-1 do grid[0][j]:=0;
  //bottom wall: bottom-left to bottom-right
  for i:=0 to mw-1 do grid[i][mh-1]:=0;
  //right wall: bottom-right to top-right
  for j:=0 to mh-1 do grid[mw-1][j]:=0;

  //=== step 2: carve a winding solution path from top-left to
  //bottom-right of the interior. movement is right/down in random-length
  //runs with occasional sidesteps, so it zigzags but always terminates ===
  cx:=1;
  cy:=1;
  grid[cx][cy]:=2;

  while (cx < mw-2) or (cy < mh-2) do
  begin
    //pick a direction: prefer whichever axis has more distance left,
    //with randomness so the path wanders
    if cx >= mw-2 then
      d:=1                          //must go down
    else if cy >= mh-2 then
      d:=0                          //must go right
    else if Random(2) = 0 then
      d:=0
    else
      d:=1;

    //random run length 1..3 keeps the path from being a straight staircase
    runlen:=Random(3) + 1;

    while runlen > 0 do
    begin
      if (d = 0) and (cx < mw-2) then inc(cx)
      else if (d = 1) and (cy < mh-2) then inc(cy)
      else break;
      grid[cx][cy]:=2;
      dec(runlen);
    end;

    //occasional sidestep (detour) perpendicular to the run - makes the
    //path more interesting without risk of trapping itself
    if Random(4) = 0 then
    begin
      if (d = 0) and (cy < mh-2) then
      begin
        inc(cy);
        grid[cx][cy]:=2;
      end
      else if (d = 1) and (cx < mw-2) then
      begin
        inc(cx);
        grid[cx][cy]:=2;
      end;
    end;
  end;

  //=== step 3: fill the remaining interior with random paths/walls
  //without ever touching the solution cells or the border ===
  case difficulty of
    0: openChance:=45;   //easy   - more open space, easier to navigate
    1: openChance:=35;   //medium
  else
    openChance:=25;      //hard   - tight corridors, more dead ends
  end;

  for i:=1 to mw-2 do
  begin
    for j:=1 to mh-2 do
    begin
      if grid[i][j] = 0 then
      begin
        if Random(100) < openChance then
          grid[i][j]:=1;
      end;
    end;
  end;

  //auto-place start/end only if the user has not set them via
  //Maze > Set Start Area / Set End Area - user choices are remembered
  //across generations until changed
  if not MazeStartSet then
  begin
    MazeStartX:=mx + 1;
    MazeStartY:=my + 1;
    MazeStartSet:=true;
  end;
  if not MazeEndSet then
  begin
    MazeEndX:=mx + mw - 2;
    MazeEndY:=my + mh - 2;
    MazeEndSet:=true;
  end;

  //clamp start/end into the interior of the current area and make sure
  //both cells are open, connected to the solution corridor via the fill
  i:=MazeStartX - mx;
  j:=MazeStartY - my;
  if i < 1 then i:=1;
  if i > mw-2 then i:=mw-2;
  if j < 1 then j:=1;
  if j > mh-2 then j:=mh-2;
  MazeStartX:=mx + i;
  MazeStartY:=my + j;
  grid[i][j]:=2;
  //carve an L-shaped connector to the corridor start at (1,1) so a
  //user-chosen start is always connected to the solution path
  cx:=i;
  while cx > 1 do begin dec(cx); grid[cx][j]:=2; end;
  cy:=j;
  while cy > 1 do begin dec(cy); grid[1][cy]:=2; end;
  //punch an entrance in the nearest exterior wall (left or top)
  if i <= j then grid[0][j]:=1 else grid[i][0]:=1;

  i:=MazeEndX - mx;
  j:=MazeEndY - my;
  if i < 1 then i:=1;
  if i > mw-2 then i:=mw-2;
  if j < 1 then j:=1;
  if j > mh-2 then j:=mh-2;
  MazeEndX:=mx + i;
  MazeEndY:=my + j;
  grid[i][j]:=2;
  //carve an L-shaped connector to the corridor end at (mw-2,mh-2)
  cx:=i;
  while cx < mw-2 do begin inc(cx); grid[cx][j]:=2; end;
  cy:=j;
  while cy < mh-2 do begin inc(cy); grid[mw-2][cy]:=2; end;
  //punch an exit in the nearest exterior wall (right or bottom)
  if (mw-2-i) <= (mh-2-j) then grid[mw-1][j]:=1 else grid[i][mh-1]:=1;

  //copy to undo buffer before modifying map
  MapCoreBase.CopyToUndo(CurrentMap);

  //write grid to map: 0=wall, 1 or 2=path
  for i:=0 to mw-1 do
  begin
    for j:=0 to mh-1 do
    begin
      if grid[i][j] = 0 then
        MapCoreBase.SetMapTile(CurrentMap, mx+i, my+j, MazeWallTile)
      else
        MapCoreBase.SetMapTile(CurrentMap, mx+i, my+j, MazePathTile);
    end;
  end;

  SetLength(grid, 0);

  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap, 4);
  UpdateMapListView;
end;

//Is this cell blocked for the maze solver?
//
//SINGLE LAYER: unchanged - the cell is blocked when the current layer holds
//the wall tile, so existing maps behave exactly as before.
//
//MULTI LAYER: the walls may live on a layer other than the one being drawn
//on. Reading only the current layer meant a freshly added solution layer
//looked completely empty, nothing matched the wall tile, every cell came back
//passable and the solver drew a straight line through the walls.
//A cell is blocked if ANY layer holds the wall tile there.
//
//Hidden layers are included on purpose: "visible" is an editing aid, and a
//wall you have hidden to see underneath is still a wall.
function TMapEdit.MazeCellIsWall(mapx,mapy : integer) : boolean;
var
  l, n : integer;
  T : TileRec;
begin
  MazeCellIsWall:=false;

  n:=MapCoreBase.GetLayerCount(CurrentMap);
  if n <= 1 then
  begin
    MapCoreBase.GetMapTile(CurrentMap, mapx, mapy, T);
    MazeCellIsWall:=(T.ImageIndex = MazeWallTile.ImageIndex);
    exit;
  end;

  for l:=0 to n-1 do
  begin
    MapCoreBase.GetMapTileL(CurrentMap, l, mapx, mapy, T);
    if T.ImageIndex = MazeWallTile.ImageIndex then
    begin
      MazeCellIsWall:=true;
      exit;
    end;
  end;
end;

procedure TMapEdit.MazeSolveClick(Sender: TObject);
var
  ca : MapClipAreaRec;
  mx, my, mw, mh : integer;
  useClip : boolean;
  sx, sy, ex, ey : integer;
  //BFS
  queue : array of TMazePos;
    qHead, qTail : integer;
    prev : array of array of TMazePos;
    vis  : array of array of boolean;
    i, j, nx, ny, d : integer;
    found : boolean;
    dx : array[0..3] of integer;
    dy : array[0..3] of integer;
begin
  if not MazeSolutionSet then
  begin
    ShowMessage('Please set a solution tile first using Maze > Set Current Tile as Solution Tile.');
    exit;
  end;
  if not TileExists(MazeSolutionTile) then
  begin
    ShowMessage('The solution tile has been deleted. Please set a new solution tile.');
    MazeSolutionSet:=false;
    exit;
  end;
  if not MazeStartSet then
  begin
    ShowMessage('Please set the start area first using Maze > Set Start Area.');
    exit;
  end;
  if not MazeEndSet then
  begin
    ShowMessage('Please set the end area first using Maze > Set End Area.');
    exit;
  end;

  //determine area
  useClip:=(MapCoreBase.GetMapClipStatus(CurrentMap) = 1);
  if useClip then
  begin
    MapCoreBase.GetMapClipAreaCoords(CurrentMap, ca);
    mx:=ca.x;
    my:=ca.y;
    mw:=ca.x2 - ca.x + 1;
    mh:=ca.y2 - ca.y + 1;
  end
  else
  begin
    mx:=0;
    my:=0;
    mw:=MapCoreBase.GetMapWidth(CurrentMap);
    mh:=MapCoreBase.GetMapHeight(CurrentMap);
  end;

  sx:=MazeStartX - mx;
  sy:=MazeStartY - my;
  ex:=MazeEndX - mx;
  ey:=MazeEndY - my;

  if (sx < 0) or (sx >= mw) or (sy < 0) or (sy >= mh) or
     (ex < 0) or (ex >= mw) or (ey < 0) or (ey >= mh) then
  begin
    ShowMessage('Start or end position is outside the current map/selection area.');
    exit;
  end;

  //BFS from start to end - path = any tile that is NOT the wall tile
  dx[0]:=0;  dy[0]:=-1;
  dx[1]:=1;  dy[1]:=0;
  dx[2]:=0;  dy[2]:=1;
  dx[3]:=-1; dy[3]:=0;

  SetLength(vis, mw, mh);
  SetLength(prev, mw, mh);
  for i:=0 to mw-1 do
    for j:=0 to mh-1 do
    begin
      vis[i][j]:=false;
      prev[i][j].x:=-1;
      prev[i][j].y:=-1;
    end;

  SetLength(queue, mw * mh);
  qHead:=0;
  qTail:=0;

  //Refuse a start or end that sits inside a wall. Without this the solver
  //walks out of a wall and reports a route that cannot be taken - easy to
  //trip over now that the walls may be on another layer.
  if MazeCellIsWall(mx+sx, my+sy) then
  begin
    ShowMessage('The start position is on a wall tile.');
    SetLength(vis,0); SetLength(prev,0); SetLength(queue,0);
    exit;
  end;
  if MazeCellIsWall(mx+ex, my+ey) then
  begin
    ShowMessage('The end position is on a wall tile.');
    SetLength(vis,0); SetLength(prev,0); SetLength(queue,0);
    exit;
  end;

  vis[sx][sy]:=true;
  queue[qTail].x:=sx;
  queue[qTail].y:=sy;
  inc(qTail);
  found:=false;

  while qHead < qTail do
  begin
    i:=queue[qHead].x;
    j:=queue[qHead].y;
    inc(qHead);

    if (i = ex) and (j = ey) then
    begin
      found:=true;
      break;
    end;

    for d:=0 to 3 do
    begin
      nx:=i + dx[d];
      ny:=j + dy[d];
      if (nx >= 0) and (nx < mw) and (ny >= 0) and (ny < mh) then
      begin
        if not vis[nx][ny] then
        begin
          //passable = not a wall on ANY layer - see MazeCellIsWall
          if not MazeCellIsWall(mx+nx, my+ny) then
          begin
            vis[nx][ny]:=true;
            prev[nx][ny].x:=i;
            prev[nx][ny].y:=j;
            queue[qTail].x:=nx;
            queue[qTail].y:=ny;
            inc(qTail);
          end;
        end;
      end;
    end;
  end;

  if not found then
  begin
    ShowMessage('This maze is not solvable. There is no path from start to end.');
    SetLength(vis, 0);
    SetLength(prev, 0);
    SetLength(queue, 0);
    exit;
  end;

  //Draw the solution on the CURRENT layer - that is the whole point of the
  //multi layer support, walls stay where they are and the route goes on its
  //own layer. SetMapTile targets the current layer.
  MapCoreBase.CopyToUndo(CurrentMap);

  //trace back from end to start and draw solution tiles
  i:=ex;
  j:=ey;
  while not ((i = sx) and (j = sy)) do
  begin
    MapCoreBase.SetMapTile(CurrentMap, mx+i, my+j, MazeSolutionTile);
    nx:=prev[i][j].x;
    ny:=prev[i][j].y;
    i:=nx;
    j:=ny;
  end;
  MapCoreBase.SetMapTile(CurrentMap, mx+sx, my+sy, MazeSolutionTile);

  SetLength(vis, 0);
  SetLength(prev, 0);
  SetLength(queue, 0);

  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap, 4);
  UpdateMapListView;
end;

end.

