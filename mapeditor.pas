unit mapeditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,Types,
  ComCtrls, Menus,rmthumb,mapcore,rwmap,mapexiportprops,rmcodegen,drawprocs,rmtools,rmclipboard,
  rmconfig;

const
  AddImage = 1;
  InsertImage = 2;
  UpdateImage = 3;

type
  { TMapEdit }

  TMapEdit = class(TForm)
    CopyToClipBoard: TMenuItem;
    GroupBox1: TGroupBox;
    MapImageList: TImageList;
    MenuItem15: TMenuItem;
    CloneMap: TMenuItem;
    MenuDeleteAll: TMenuItem;
    MenuPopupNew: TMenuItem;
    MenuPopupDelete: TMenuItem;
    Properties: TMenuItem;
    Panel1: TPanel;
    RadioDraw: TRadioButton;
    RadioErase: TRadioButton;
    ReSizeMap256x256: TMenuItem;
    ReSizeMap128x128: TMenuItem;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    TileImageList: TImageList;
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
    Undo: TMenuItem;
    PasteFromClipBoard: TMenuItem;
    Panel2: TPanel;
    MenuItem10: TMenuItem;
    Clear: TMenuItem;
    ExportCArray: TMenuItem;
    ExportPascalArray: TMenuItem;
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
    MenuItem18: TMenuItem;
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

    procedure Button1Click(Sender: TObject);
    procedure CheckBoxDisplayGridChange(Sender: TObject);
    procedure CloneMapClick(Sender: TObject);
    procedure CopyToClipBoardClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure MapImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MapImageMouseLeave(Sender: TObject);
    procedure MapImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClearMapClick(Sender: TObject);
    procedure MapListViewClick(Sender: TObject);
    procedure MapPaintBoxPaint(Sender: TObject);
    procedure MenuDeleteAllClick(Sender: TObject);

    procedure MenuDeleteClick(Sender: TObject);
    procedure MenuExportBasicLNMapData(Sender: TObject);
    procedure MenuExportBasicMapData(Sender: TObject);
    procedure MenuExportCArray(Sender: TObject);
    procedure MenuExportPascalArray(Sender: TObject);
    procedure MenuMapPropsClick(Sender: TObject);
    procedure MenuOpenClick(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);

    procedure MenuPopupNewClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure PasteFromClipBoardClick(Sender: TObject);
    procedure ReSizeMapClick(Sender: TObject);
    procedure TileModeDrawClick(Sender: TObject);
    procedure TileModeEraseClick(Sender: TObject);
    procedure RadioDrawClick(Sender: TObject);
    procedure RadioEraseClick(Sender: TObject);
    procedure ReSizeTiles(Sender: TObject);

    procedure TileListViewClick(Sender: TObject);
    procedure TileZoomChange(Sender: TObject);

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
    TileWidth : integer;
    TileHeight : integer;
    CTile      : TileRec;
    CTileBitMap : TBitMap;
    TileMode       : integer;
    DrawTool       : integer;
    RenderDrawToolShape : Boolean;

    FormShowActivate : boolean;

    MapX,MapY,MapX2,MapY2,OldMapX,OldMapY : integer;

    procedure Init;
    function GetMapX(x : integer) : integer;
    function GetMapY(y : integer) : integer;

    procedure PlotTileAt(x,y : integer; TTile : TileRec);
    procedure PlotTile(mx,my : integer; TTile : TileRec);
    procedure ImageListPlotTile(mx,my : integer;var TTile : TileRec);

    procedure ClearTile(mx,my : integer);
    procedure PlotMissingTile(mx,my : integer);
    Procedure SetMapTileMode(Tool : integer);
    procedure SetDrawTool(tool : integer);

    procedure APlotTile(x,y : integer;var TTile : TileRec);   //convert to grid format and store on array
    procedure AClearTile(x,y : integer);
    procedure CPlotTile(ColX,ColY : integer;var TTile : TileRec); //draw to canvas - do not store
    procedure CClearTile(ColX,ColY : integer);
    Procedure DrawOverLayOnClipArea;

    procedure LoadTile(index : integer);
    procedure LoadTilesToTileImageList;
    procedure VerifyTileImageList;

    procedure UpdateTileView;
    procedure UpdateCurrentTile;
    procedure UpdateMapInfo(x,y : integer);
    procedure UpdateInfoBarX1Y1X2Y2;

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

    procedure MapPreviewPlotTile(MPCanvas : TCanvas;mx,my : integer;var TTile : TileRec);
    Procedure UpdateMapPreviewImageIcons(MapIndex,ImageAction : integer);

    procedure DeleteAll;

  end;

var
  MapEdit: TMapEdit;

implementation


{$R *.lfm}

{ TMapEdit }

procedure DrawTileCB(x,y,index,mode : integer);
var
  TT : TileRec;
begin
 if mode = 1 then
 begin
   if MapEdit.TileMode = 0 then
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
begin
 SetMapTileMode(1);  //draw
 SetDrawTool(DrawShapePencil);
 CurrentMap:=MapCoreBase.GetCurrentMap;
 MapCoreBase.SetZoomSize(CurrentMap,4);
 MapCoreBase.SetMapTileSize(CurrentMap,32,32);

 TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
 TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);
 CTile.ImageIndex:=TileMissing;
 LoadTile(0);

 MapX:=0;
 MapY:=0;
 MapX2:=0;
 MapY2:=0;
 OldMapX:=-1;
 OldMapY:=-1;

 RenderDrawToolShape:=False;
 UpdateToolSelectionIcons;
 UpdateEditMenus;

// MapCoreBase.SetCurrentMap(MapCoreBase.GetMapCount-1);
//  CurrentMap:=MapCoreBase.GetCurrentMap;
  TileMode:=1; //draw
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

  MapPaintBox.Width:=0;   //this hack updated the scrollbars properly after the 2nd and following attempts
  MapPaintBox.Height:=0;
  MapPaintBox.Invalidate;
  MapPaintBox.Width:=MapCoreBase.GetZoomMapPageWidth(CurrentMap)+1;    //do not remove the +1 - hack to display ScrollRightMenu and bottom corner of grid
  MapPaintBox.Height:=MapCoreBase.GetZoomMapPageHeight(CurrentMap)+1;
  MapPaintBox.Invalidate;  //forces a paint which draws the map

  MapScrollBox.HorzScrollBar.Position:=hpos;
  MapScrollBox.VertScrollBar.Position:=vpos;

  FormShowActivate:=true; //this is going to also trigger an onfocus even - letting event handler know it was because of onopen
end;

procedure TMapEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 hpos:=MapScrollBox.HorzScrollBar.Position;
 vpos:=MapScrollBox.VertScrollBar.Position;
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
  UpdateMapListView;  //if new project is open or inserted - we need to update maplist view
  UpdateMenus;
  UpdateEditMenus;
  UpdateToolSelectionIcons;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.SetDrawTool(tool : integer);
begin
  DrawTool:=tool;
  MapCoreBase.SetMapDrawTool(MapCoreBase.GetCurrentMap,DrawTool);
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

procedure TMapEdit.PasteFromClipBoardClick(Sender: TObject);
var
  ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapCoreBase.PasteFromClipboard(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2);
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.PlotTile(mx,my : integer; TTile : TileRec);
var
  gx,gy : integer;
begin
 if (mx < 0) or (my<0) or (mx >= MapCoreBase.GetMapWidth(CurrentMap)) or (my >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;
 MapCoreBase.SetMapTile(CurrentMap,mx,my,CTile);

 gx:=mx*TileWidth;
 gy:=my*TileHeight;
 MapPaintBox.canvas.CopyRect(Rect(gx, gy, gx+TileWidth, gy+TileHeight), CTileBitMap.Canvas, Rect(0, 0,CTileBitMap.Width, CTileBitMap.Height));
end;

procedure TMapEdit.ImageListPlotTile(mx,my : integer;var TTile : TileRec);
var
  gx,gy : integer;
begin
 gx:=mx*TileWidth;
 gy:=my*TileHeight;
 TileImageList.Draw(MapPaintBox.Canvas,gx,gy,TTile.ImageIndex,true);
end;

procedure TMapEdit.ClearTile(mx,my : integer);
var
  T : TileRec;
begin
 if (mx < 0) or (my<0) or (mx >= MapCoreBase.GetMapWidth(CurrentMap)) or (my >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;
 T.ImageIndex:=TileClear;
 MapCoreBase.SetMapTile(CurrentMap,mx,my,T);
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

procedure TMapEdit.PlotTileAt(x,y : integer;TTile : TileRec);
var
  mx,my : integer;
begin
  mx:=x div TileWidth;
  my:=y div TileHeight;
  PlotTile(mx,my,TTile);
end;


procedure TMapEdit.APlotTile(x,y : integer;var TTile : TileRec);
var
  mx,my : integer;
begin
  mx:=(x div TileWidth);
  if (mx < 0) or (mx >= MapCoreBase.GetMapWidth(CurrentMap)) then exit;
  my:=(y div TileHeight);
  if (my<0) or (my >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;
  MapCoreBase.SetMapTile(CurrentMap,mx,my,TTile);
end;

procedure TMapEdit.AClearTile(x,y : integer);
var
  mx,my : integer;
  T : TileRec;
begin
 mx:=(x div TileWidth);
 if (mx < 0) or (mx >= MapCoreBase.GetMapWidth(CurrentMap)) then exit;
 my:=(y div TileHeight);
 if (my<0) or (my >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;
 T.ImageIndex:=TileClear;
 MapCoreBase.SetMapTile(CurrentMap,mx,my,T);
end;

//called from onpaint
procedure TMapEdit.CPlotTile(ColX,ColY : integer;var TTile : TileRec); //draw to canvas - do not store
var
  gx,gy : integer;
begin
 if (ColX < 0) or (ColY<0) or (ColX >= MapCoreBase.GetMapWidth(CurrentMap)) or (ColY >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;
 //MapCoreBase.SetMapTile(CurrentMap,mx,my,CTile);

 gx:=ColX*TileWidth;
 gy:=ColY*TileHeight;
 MapPaintBox.canvas.CopyRect(Rect(gx, gy, gx+TileWidth, gy+TileHeight), CTileBitMap.Canvas, Rect(0, 0,CTileBitMap.Width, CTileBitMap.Height));
end;

//called from onpaint
procedure TMapEdit.CClearTile(ColX,ColY : integer);
var
  gx,gy : integer;
begin
  if (ColX < 0) or (ColY<0) or (ColX >= MapCoreBase.GetMapWidth(CurrentMap)) or (ColY >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;
  gx:=ColX*TileWidth;
  gy:=ColY*TileHeight;

  MapPaintBox.Canvas.Brush.Color:=clBlack;
  MapPaintBox.Canvas.FillRect(gx,gy,gx+TileWidth,gy+TileHeight);
end;

procedure TMapEdit.MapImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 (*
 MDownLeft:=False;
 MDownRight:=False;

 if Button = mbRight then
 begin
   MDownRight:=True;
   AClearTile(x,y);
 end
 else if Button = mbLeft then
 begin
    MDownLeft:=True;
    if TileMode = 1 then
    begin
      APlotTile(x,y,CTile);
    end
    else if TileMode = 0 then
    begin
      AClearTile(x,y);
    end;
 end;
 MapPaintbox.Invalidate
 *)
end;

procedure TMapEdit.MapImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (*MDownLeft:=False;
  MDownRight:=False;
  MapPaintBox.Invalidate;*)
end;

procedure TMapEdit.ClearMapClick(Sender: TObject);
begin
  MapCoreBase.ClearMap(CurrentMap,TileClear);
  VerifyTileImageList;
  MapPaintBox.Invalidate;
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

procedure TMapEdit.UpdateMapView;
var
  i,j : integer;
  T   : TileRec;
begin
 for j:=0 to MapCoreBase.GetMapWidth(CurrentMap)-1 do
  begin
    for i:=0 to MapCoreBase.GetMapHeight(CurrentMap)-1 do
    begin
      MapCoreBase.GetMapTile(CurrentMap,i,j,T);
      if T.ImageIndex = TileMissing then PlotMissingTile(i,j)
      else if T.ImageIndex <> TileClear then ImageListPlotTile(i,j,T);
    end;
  end;
end;

procedure TMapEdit.MapPaintBoxPaint(Sender: TObject);
begin
  UpdateMapView;
  if RenderDrawToolShape  then DrawItem(DrawTool,MapX,MapY,MapX2,MapY2,CTile.ImageIndex,0);
  if MapCoreBase.GetMapGridStatus(MapCoreBase.GetCurrentMap) = 1 then DrawGrid;
  if MapCoreBase.GetMapClipStatus(MapCoreBase.GetCurrentMap) = 1 then DrawOverLayOnClipArea;
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
begin
 if rmconfigbase.GetExportTextFileToClipStatus = false then
 begin
   result:=false;
   exit;
 end;

 filename:=GetTemporaryPathWithProvidedFileName(MapCoreBase.GetExportName(MapCoreBase.GetCurrentMap));
 Case (Sender As TMenuItem).Name of  'ExportBasicMapData':ExportMap(FileName,BasicLan,True);
                                     'BasicLNMapData':ExportMap(FileName,BasicLNLan,True);
                                     'ExportCArray': ExportMap(FileName,CLan,true);
                                     'ExportPascalArray':ExportMap(FileName,PascalLan,true);

 else
   result:=false;  //did not find a supported format return false
   exit;
 End;

 result:=true;  //found supported format - return true

 ReadFileAndCopyToClipboard(filename);
 EraseFile(filename);
 ShowMessage('Exported to Clipboard!');
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
     MapCoreBase.SetMapExportProps(index,EO)
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
  TileMode:=1; //draw
  MapCoreBase.SetMapTileMode(CurrentMap,TileMode); // we set to draw because the copied data from map 0 may be in erase mode

  TileZoom.Position:=4;
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





procedure TMapEdit.MenuPopupNewClick(Sender: TObject);
begin

end;



procedure TMapEdit.MenuOpenClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'RM MAP Files|*.map|All Files|*.*';
  if OpenDialog1.Execute then
  begin
   ReadMap(OpenDialog1.FileName);
   UpdatePageSize;
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
begin
 ReSizeMap8x8.Checked:=false;
 ReSizeMap16x16.Checked:=false;
 ReSizeMap32x32.Checked:=false;
 ReSizeMap64x64.Checked:=false;
 ReSizeMap128x128.Checked:=false;
 ReSizeMap256x256.Checked:=false;

 case MapCoreBase.GetMapWidth(MapCoreBase.GetCurrentMap) of 8: ReSizeMap8x8.Checked:=true;
                                                           16: ReSizeMap16x16.Checked:=true;
                                                           32: ReSizeMap32x32.Checked:=true;
                                                           64: ReSizeMap64x64.Checked:=true;
                                                           128: ReSizeMap128x128.Checked:=true;
                                                           256: ReSizeMap256x256.Checked:=true;

 end;
 ReSize8x8.Checked:=false;
 ReSize16x16.Checked:=false;
 ReSize32x32.Checked:=false;
 ReSize64x64.Checked:=false;
 ReSize128x128.Checked:=false;
 ReSize256x256.Checked:=false;

 case MapCoreBase.GetMapTileWidth(MapCoreBase.GetCurrentMap) of 8: ReSize8x8.Checked:=true;
                                                           16: ReSize16x16.Checked:=true;
                                                           32: ReSize32x32.Checked:=true;
                                                           64: ReSize64x64.Checked:=true;
                                                           128: ReSize128x128.Checked:=true;
                                                           256: ReSize256x256.Checked:=true;

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

 end;
 MapCoreBase.ResizeMapSize(CurrentMap,mwidth,mheight);
// TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
// TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);
 UpdateEditMenus;
 UpdatePageSize;
// UpdateMapView;
 MapPaintBox.Invalidate;
 UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
 MapListView.Repaint;
end;

procedure TMapEdit.TileModeDrawClick(Sender: TObject);
begin
  TileMode:=1;
  MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
//  RadioDraw.Checked:=true;
  UpdateMenus;
end;

procedure TMapEdit.TileModeEraseClick(Sender: TObject);
begin
 TileMode:=0;
 MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
// RadioErase.Checked:=true;
 UpdateMenus;
end;

procedure TMapEdit.RadioDrawClick(Sender: TObject);
begin
  TileMode:=1;
  MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
  UpdateMenus;
end;

procedure TMapEdit.RadioEraseClick(Sender: TObject);
begin
 TileMode:=0;
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
                                                     zs:=2;
                                                   end;
                                    'ReSize32x32' :begin
                                                     tw:=32;
                                                     th:=32;
                                                     zs:=3;
                                                   end;
                                    'ReSize64x64' :begin
                                                     tw:=64;
                                                     th:=64;
                                                     zs:=4;
                                                   end;
                                    'ReSize128x128' :begin
                                                     tw:=128;
                                                     th:=128;
                                                     zs:=5;
                                                   end;
                                    'ReSize256x256' :begin
                                                     tw:=256;
                                                     th:=256;
                                                     zs:=6;
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
  MapPaintBox.Invalidate;
end;


//0 erase 1 draw tile
Procedure TMapEdit.SetMapTileMode(Tool : integer);
begin
  TileMode:=Tool;
  MapCoreBase.SetMapTileMode(MapCoreBase.GetCurrentMap,TileMode);
  TileModeErase.Checked:=false;
  TileModeDraw.Checked:=false;

  if Tool = 0 then
  begin
    RadioErase.Checked:=true;
    TileModeErase.Checked:=true;
  end
  else if Tool = 1 then
  begin
    RadioDraw.Checked:=true;
    TileModeDraw.Checked:=true;
  end;
end;

procedure TMapEdit.MapImageMouseLeave(Sender: TObject);
begin
(*  MDownRight:=False;*)
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


procedure TMapEdit.LoadTilesToTileImageList;
var
  index,i,j,awidth,aheight : integer;
  SrcBitMap,DstBitMap : TBitMap;
begin
 TileImageList.Width:=TileWidth;
 TileImageList.Height:=TileHeight;
 TileImageList.Clear;

 DstBitMap:=TBitMap.Create;
 DstBitMap.SetSize(TileWidth,TileHeight);

 for index:=0 to ImageThumbBase.GetCount-1 do
 begin
   awidth:=ImageThumbBase.GetWidth(index);
   aheight:=ImageThumbBase.GetHeight(index);

   SrcBitMap:=TBitMap.Create;
   SrcBitMap.SetSize(awidth,aheight);
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
   SrcBitMap.Free;

 end;
 DstBitMap.Free;
end;

Procedure TMapEdit.VerifyTileImageList;
var
  i,j    : integer;
  T      : TileRec;
  FIndex : integer;
begin
 for j:=0 to MapCoreBase.GetMapWidth(CurrentMap)-1 do
  begin
    for i:=0 to MapCoreBase.GetMapHeight(CurrentMap)-1 do
    begin
      MapCoreBase.GetMapTile(CurrentMap,i,j,T);
      if (T.ImageIndex<>TileMissing) and (T.ImageIndex<>TileClear)  then
      begin
        FIndex:=ImageThumbBase.FindUID(T.ImageUID);
        if  FIndex = -1 then             // if -1 it was deleted lets update map info
        begin
          T.ImageIndex:=TileMissing;
          MapCoreBase.SetMapTile(CurrentMap,i,j,T);
        end
        else if Findex<>T.ImageIndex then  //oh oh image is in a different index now - lets update
        begin
          T.ImageIndex:=FIndex;
          MapCoreBase.SetMapTile(CurrentMap,i,j,T);
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

procedure TMapEdit.TileZoomChange(Sender: TObject);
var
  tw,th : integer;
begin
  tw:=MapCoreBase.GetMapTileWidth(CurrentMap);
  th:=MapCoreBase.GetMapTileHeight(CurrentMap);

  MapCoreBase.SetZoomSize(CurrentMap,TileZoom.Position);
  MapCoreBase.SetMapTileSize(CurrentMap,tw,th);

  TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
  TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);
  UpdatePageSize;
  //UpdateMapView;
  LoadTilesToTileImageList;
  UpdateEditMenus;
  MapPaintBox.Invalidate;
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


procedure TMapEdit.Button1Click(Sender: TObject);
begin
// UpdateMapPreviewImageIcons(MapImageList,MapCoreBase.GetCurrentMap,AddImage);
 ShowMessage(IntToStr(SelectedTileImage.Picture.Bitmap.Width)+' '+IntToStr(SelectedTileImage.Picture.Bitmap.Height));

// UpdateCurrentTile;
end;

procedure TMapEdit.MapPreviewPlotTile(MPCanvas : TCanvas;mx,my : integer;var TTile : TileRec);
var
  gx,gy : integer;
begin
 gx:=mx*TileWidth;
 gy:=my*TileHeight;
 TileImageList.Draw(MPCanvas,gx,gy,TTile.ImageIndex,true);
end;

Procedure TMapEdit.UpdateMapPreviewImageIcons(MapIndex,ImageAction : integer);
var
  i,j,index : integer;
  T   : TileRec;
  SrcBitMap,DstBitMap : TBitMap;
begin
 SrcBitMap:=TBitMap.Create;
 SrcBitMap.SetSize(MapCoreBase.GetMapWidth(MapIndex)*TileWidth,MapCoreBase.GetMapHeight(MapIndex)*TileHeight);

 DstBitMap:=TBitMap.Create;
 DstBitMap.SetSize(256,256);

 for j:=0 to MapCoreBase.GetMapWidth(MapIndex)-1 do
  begin
    for i:=0 to MapCoreBase.GetMapHeight(MapIndex)-1 do
    begin
      MapCoreBase.GetMapTile(MapIndex,i,j,T);
       if T.ImageIndex > TileClear then   //we don't care about missing tile here
       begin
         MapPreviewPlotTile(SrcBitMap.Canvas,i,j,T);
       end;
    end;
  end;
  DstBitMap.canvas.CopyRect(Rect(0, 0, DstBitMap.Width, DstBitMap.Height), SrcBitMap.Canvas, Rect(0, 0, SrcBitMap.Width, SrcBitMap.Height));
//  MapImageList.clear;

  if ImageAction = AddImage then
  begin
     index:=MapImageList.add(DstBitMap,nil);
     MapListView.Items[MapIndex].ImageIndex:=index;
  end
  else if ImageAction = UpdateImage then
  begin
     MapImageList.Replace(MapIndex,DstBitMap,nil,false);
  end;
//  MapListView.Repaint;
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
begin
// SelectedTileImage.Picture.Bitmap.SetSize(CTileBitMap.Width, CTileBitMap.Height);

 //SelectedTileImage.Picture.Bitmap.SetSize(256, 256);
// SelectedTileImage.Picture.Bitmap.Width:=256;
// SelectedTileImage.Picture.Bitmap.Height:=256;

 //  SelectedTileImage.canvas.CopyRect(Rect(0, 0, CTileBitMap.Width, CTileBitMap.Height), CTileBitMap.Canvas, Rect(0, 0,CTileBitMap.Width, CTileBitMap.Height));
  SelectedTileImage.canvas.CopyRect(Rect(0, 0,  256,256), CTileBitMap.Canvas, Rect(0, 0,CTileBitMap.Width,  CTileBitMap.Height));
//        ActualBox.canvas.CopyRect(Rect(0, 0,  256,256), ACBitMap.Canvas, Rect(0, 0,ACBitMap.Width,  ACBitMap.Height));

end;

procedure TMapEdit.UpdateInfoBarX1Y1X2Y2;
var
  XYStr,WHStr   : string;
begin
 XYStr:='X = '+IntToStr(MapX)+' Y = '+IntToStr(MapY)+' '+
        'X2 = '+IntToStr(MapX2)+' Y2 = '+IntToStr(MapY2)+' ';
 WHStr:='Width = '+IntToStr(ABS(MapX2-MapX+1))+' Height = '+IntToStr(ABS(MapY2-MapY+1));
 StatusBar1.SimpleText:=XYStr;
 StatusBar2.SimpleText:=WHStr;
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

  StatusBar1.SimpleText:=XYStr+ColIndexStr;
  StatusBar2.SimpleText:=ClipStr;
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
  UpdateInfoBarX1Y1X2Y2;
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
  UpdateInfoBarX1Y1X2Y2; //we have x1,x2,y1,t2

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
  if TileMode = 0 then
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
    if TileMode = 0 then  //erase mode
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
    if TileMode = 0 then
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
 MapCoreBase.SetMapClipStatus(MapCoreBase.GetCurrentMap,0);  //turn it off - we turn on again when new area is selected
 if DrawTool<>DrawShapeClip then MapCoreBase.CopyToUndo(MapCoreBase.GetCurrentMap);
 Case DrawTool of DrawShapePencil,DrawShapeSpray,DrawShapePaint:MPaintBoxMouseDownXYTool(Sender,Button,Shift,X,Y);
                                  DrawShapeLine,DrawShapeRectangle,DrawShapeFRectangle,DrawShapeCircle,DrawShapeFCircle,
               DrawShapeEllipse,DrawShapeFEllipse,DrawShapeClip:MPaintBoxMouseDownXYX2Y2Tool(Sender,Button,Shift,X,Y);
 end;
end;

procedure TMapEdit.MPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 Case DrawTool of DrawShapePencil,DrawShapeSpray,DrawShapePaint:MPaintBoxMouseMoveXYTool(Sender,Shift,X,Y);
               DrawShapeLine,DrawShapeRectangle,DrawShapeFRectangle,DrawShapeCircle,DrawShapeFCircle,
               DrawShapeEllipse,DrawShapeFEllipse,DrawShapeClip:MPaintBoxMouseMoveXYX2Y2Tool(Sender,Shift,X,Y);

 end;
end;

procedure TMapEdit.MPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
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
 MapPaintBox.Invalidate;
end;

procedure TMapEdit.ToolHFLIPButtonClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapCoreBase.Hflip(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2 );
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
end;

procedure TMapEdit.ToolScrollDownIconClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapCoreBase.ScrollDown(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2 );
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolScrollLeftIconClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapCoreBase.ScrollLeft(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2 );
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolScrollRightIconClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapCoreBase.ScrollRight(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2 );
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolScrollUpIconClick(Sender: TObject);
var
 ca : MapClipAreaRec;
begin
  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  MapCoreBase.ScrollUp(MapCoreBase.GetCurrentMap,ca.x,ca.y,ca.x2,ca.y2 );
  MapPaintBox.Invalidate;
  UpdateMapPreviewImageIcons(CurrentMap,UpdateImage);
  MapListView.Repaint;
end;

procedure TMapEdit.ToolUndoIconClick(Sender: TObject);
begin
 MapCoreBase.Undo(MapCoreBase.GetCurrentMap);
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
  if TileMode = 1 then
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


end.

