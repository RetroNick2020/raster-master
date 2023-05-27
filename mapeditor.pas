unit mapeditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,Types,
  ComCtrls, Menus,rmthumb,mapcore,rwmap,mapexiportprops,rmcodegen;

type
  { TMapEdit }

  TMapEdit = class(TForm)
    TileImageList: TImageList;
    MenuItem10: TMenuItem;
    Clear: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuMapProps: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuNew: TMenuItem;
    OpenDialog1: TOpenDialog;
    ExportMapsPropsMenu: TPopupMenu;
    MapPaintBox: TPaintBox;
    RadioDraw: TRadioButton;
    RadioErase: TRadioButton;
    SaveDialog1: TSaveDialog;
    ToolPanel: TPanel;
    ReSize64x64: TMenuItem;
    ReSize128x128: TMenuItem;
    ReSize256x256: TMenuItem;
    ReSizeMap64x64: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuToolDraw: TMenuItem;
    MenuToolErase: TMenuItem;
    SelectedTileImage: TImage;
    MainMenu1: TMainMenu;
    ImageList1: TImageList;
    MapInfoLabel: TLabel;
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
    TopMiddlePanel: TPanel;
    MapScrollBox: TScrollBox;
    LeftVertSplitter: TSplitter;
    LeftSplitter: TSplitter;
    RightSplitter: TSplitter;
    TileZoom: TTrackBar;

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure MapImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MapImageMouseLeave(Sender: TObject);
    procedure MapImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure MapImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClearMapClick(Sender: TObject);
    procedure MapListViewClick(Sender: TObject);
    procedure MapPaintBoxPaint(Sender: TObject);

    procedure MenuDeleteClick(Sender: TObject);
    procedure MenuExportBasicLNMapData(Sender: TObject);
    procedure MenuExportBasicMapData(Sender: TObject);
    procedure MenuExportCArray(Sender: TObject);
    procedure MenuExportPascalArray(Sender: TObject);
    procedure MenuMapPropsClick(Sender: TObject);
    procedure MenuOpenClick(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure ReSizeMapClick(Sender: TObject);
    procedure MenuToolDrawClick(Sender: TObject);
    procedure MenuToolEraseClick(Sender: TObject);
    procedure RadioDrawClick(Sender: TObject);
    procedure RadioEraseClick(Sender: TObject);
    procedure ReSizeTiles(Sender: TObject);

    procedure TileListViewClick(Sender: TObject);
    procedure TileZoomChange(Sender: TObject);
  private

  public
    hpos,vpos : integer;
    MDownLeft      : Boolean;
    MDownRight      : Boolean;
    CurrentMap : integer;
    TileWidth : integer;
    TileHeight : integer;
    CTile      : TileRec;
    CTileBitMap : TBitMap;
    CTool       : integer;
    FormShowActivate : boolean;

    procedure PlotTileAt(x,y : integer; TTile : TileRec);
    procedure PlotTile(mx,my : integer; TTile : TileRec);
    procedure ImageListPlotTile(mx,my : integer;var TTile : TileRec);

    procedure ClearTile(mx,my : integer);
    procedure PlotMissingTile(mx,my : integer);
    Procedure SetMapTool(Tool : integer);

    procedure APlotTile(x,y : integer;var TTile : TileRec);   //convert to grid format and store on array
    procedure AClearTile(x,y : integer);
    procedure CPlotTile(ColX,ColY : integer;var TTile : TileRec); //draw to canvas - do not store
    procedure CClearTile(ColX,ColY : integer);

    procedure LoadTile(index : integer);
    procedure LoadTilesToTileImageList;
    procedure VerifyTileImageList;

    procedure UpdateTileView;
    procedure UpdateCurrentTile;
    procedure UpdateMapInfo(x,y : integer);
    procedure UpdateMapView;
    Procedure UpdateMapListView;
    procedure UpdatePageSize;
  end;

var
  MapEdit: TMapEdit;

implementation


{$R *.lfm}

{ TMapEdit }

procedure TMapEdit.FormCreate(Sender: TObject);
begin
 SetMapTool(1);  //draw
 CurrentMap:=MapCoreBase.GetCurrentMap;
 MapCoreBase.SetZoomSize(CurrentMap,4);

 MapCoreBase.SetMapTileSize(CurrentMap,32,32);

 CTileBitmap:=TBitMap.Create;

 TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
 TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);

 MDownLeft:=False;
 MDownRight:=False;
 CTile.ImageIndex:=TileMissing;
 FormShowActivate:=false;
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
    LoadTile(CTile.ImageIndex);   // Follow up open windows - reload current tile incase it was edited
  end;

  UpdateCurrentTile;
  UpdateMapListView;

  MapPaintBox.Width:=0;   //this hack updated the scrollbars properly after the 2nd and following attempts
  MapPaintBox.Height:=0;
  MapPaintBox.Invalidate;
  MapPaintBox.Width:=MapCoreBase.GetZoomMapPageWidth(CurrentMap);
  MapPaintBox.Height:=MapCoreBase.GetZoomMapPageHeight(CurrentMap);
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

  if CTile.ImageIndex = TileMissing then
  begin
     LoadTile(0);     // first time opening MApEdit Window
  end
  else
  begin
    LoadTile(CTile.ImageIndex);   // Follow up open windows - reload current tile incase it was edited
  end;
  UpdateCurrentTile;

  UpdateTileView;
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
// MapPaintBox.canvas.CopyRect(Rect(gx, gy, gx+TileWidth, gy+TileHeight), CTileBitMap.Canvas, Rect(0, 0,CTileBitMap.Width, CTileBitMap.Height));
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

procedure TMapEdit.MapImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 UpdateMapInfo(x,y);

 if MDOwnLeft and (CTool=1) then
 begin
   APlotTile(x,y,CTile);
   //MapCoreBase.SetMapTile(CurrentMap,mx,my,CTile);
 end
 else if (MDOwnRight=true) or ((MDownLeft=true) and (CTool=0)) then
 begin
   AClearTile(x,y);
 end;
 MapPaintBox.Invalidate;
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
    if CTool = 1 then
    begin
      APlotTile(x,y,CTile);
    end
    else if CTool = 0 then
    begin
      AClearTile(x,y);
    end;
 end;
 MapPaintbox.Invalidate
end;

procedure TMapEdit.MapImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MDownLeft:=False;
  MDownRight:=False;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.ClearMapClick(Sender: TObject);
begin
  MapCoreBase.ClearMap(CurrentMap,TileClear);
  VerifyTileImageList;
  MapPaintBox.Invalidate;
end;

procedure TMapEdit.MapListViewClick(Sender: TObject);
var
  item : TListItem;
begin
   if (MapListView.SelCount > 0) then
   begin
     item:=MapListView.LastSelected;
     MapCoreBase.SetCurrentMap(item.Index);
     CurrentMap:=MapCoreBase.GetCurrentMap;
     UpdatePageSize;
     //UpdateMapView;
     MapPaintBox.Invalidate;
   end;
end;

procedure TMapEdit.MapPaintBoxPaint(Sender: TObject);
begin
  UpdateMapView;
end;

procedure TMapEdit.MenuDeleteClick(Sender: TObject);
begin
  if MapCoreBase.GetMapCount > 1 then
  begin
    if (MapListView.SelCount > 0) then
    begin
      MapCoreBase.DeleteMap(CurrentMap);
      if CurrentMap > (MapCoreBase.GetMapCount-1) then
      begin
        CurrentMap:=MapCoreBase.GetMapCount-1;
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
    //UpdateMapView;
    MapPaintBox.Invalidate;
  end;
end;

procedure TMapEdit.MenuExportBasicLNMapData(Sender: TObject);
begin
 SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*';
 if SaveDialog1.Execute then
 begin
  ExportMap(SaveDialog1.FileName,BasicLNLan);
 end;
end;

procedure TMapEdit.MenuExportBasicMapData(Sender: TObject);
begin
 SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*';
 if SaveDialog1.Execute then
 begin
   ExportMap(SaveDialog1.FileName,BasicLan);
 end;
end;

procedure TMapEdit.MenuExportCArray(Sender: TObject);
begin
 SaveDialog1.Filter := 'c|*.c|All Files|*.*';
 if SaveDialog1.Execute then
 begin
   ExportMap(SaveDialog1.FileName,CLan);
 end;
end;

procedure TMapEdit.MenuExportPascalArray(Sender: TObject);
begin
  SaveDialog1.Filter := 'Pascal|*.pas|All Files|*.*';
  if SaveDialog1.Execute then
  begin
   ExportMap(SaveDialog1.FileName,PascalLan);
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
  MapCoreBase.AddMap;
  MapCoreBase.SetCurrentMap(MapCoreBase.GetMapCount-1);
  CurrentMap:=MapCoreBase.GetCurrentMap;
  UpdateMapListView;
  UpdatePageSize;
  //UpdateMapView;
  MapPaintBox.Invalidate;
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

procedure TMapEdit.ReSizeMapClick(Sender: TObject);
var
  mw,mh : integer;
begin
 Case (Sender As TMenuItem).Name of 'ReSizeMap8x8' :begin
                                                      mw:=8;
                                                      mh:=8;
                                                    end;
                                    'ReSizeMap16x16' :begin
                                                      mw:=16;
                                                      mh:=16;
                                                    end;
                                    'ReSizeMap32x32' :begin
                                                      mw:=32;
                                                      mh:=32;
                                                    end;
                                    'ReSizeMap64x64' :begin
                                                      mw:=64;
                                                      mh:=64;
                                                    end;
 end;
 MapCoreBase.ResizeMap(CurrentMap,mw,mh);
// TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
// TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);
 UpdatePageSize;
// UpdateMapView;
 MapPaintBox.Invalidate;
end;

procedure TMapEdit.MenuToolDrawClick(Sender: TObject);
begin
  SetMapTool(1);
end;

procedure TMapEdit.MenuToolEraseClick(Sender: TObject);
begin
 SetMapTool(0);
end;

procedure TMapEdit.RadioDrawClick(Sender: TObject);
begin
  SetMapTool(1);
end;

procedure TMapEdit.RadioEraseClick(Sender: TObject);
begin
 SetMapTool(0);
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
  MapPaintBox.Invalidate;
end;


//0 erase 1 draw tile
Procedure TMapEdit.SetMapTool(Tool : integer);
begin
  CTool:=Tool;
  MenuToolErase.Checked:=false;
  MenuToolDraw.Checked:=false;

  if Tool = 0 then
  begin
    RadioErase.Checked:=true;
    MenuToolErase.Checked:=true;
  end
  else if Tool = 1 then
  begin
    RadioDraw.Checked:=true;
    MenuToolDraw.Checked:=true;
  end;
end;

procedure TMapEdit.MapImageMouseLeave(Sender: TObject);
begin
  MDownRight:=False;
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
  awidth,aheight : integer;
begin
 if (TileListview.SelCount > 0)  then
 begin
    item:=TileListView.LastSelected;
    aheight:=ImageThumbBase.GetHeight(item.index);
    awidth:=ImageThumbBase.GetWidth(item.index);

    SelectedTilePanel.AutoSize:=true;
    SelectedTileImage.AutoSize:=true;
    SelectedTileImage.Picture.Bitmap.SetSize(awidth,aheight);
    SelectedTilePanel.AutoSize:=false;
    SelectedTileImage.AutoSize:=false;

    LoadTile(item.Index);
    UpdateCurrentTile;
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
  MapPaintBox.Invalidate;
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

Procedure TMapEdit.UpdateMapListView;
var
  i,count : integer;
begin
 count:=MapCoreBase.GetMapCount;
 MapListView.items.Clear;

 for i:=1 to count do
 begin
   MapListView.Items.Add;
 end;

 For i:=0 to MapListView.Items.Count-1 do
 begin
   MapListView.Items[i].Caption:='Map '+IntToStr(i+1);
 end;
end;

procedure TMapEdit.UpdatePageSize;
begin
 MapPaintBox.Width:=0;
 MapPaintBox.height:=0;
 MapPaintBox.Invalidate;
 MapPaintBox.Width:=MapCoreBase.GetZoomMapPageWidth(CurrentMap);
 MapPaintBox.height:=MapCoreBase.GetZoomMapPageHeight(CurrentMap);
 MapPaintBox.Invalidate;
end;

procedure TMapEdit.UpdateCurrentTile;
begin
  SelectedTileImage.Picture.Bitmap.SetSize(CTileBitMap.Width, CTileBitMap.Height);
  SelectedTileImage.canvas.CopyRect(Rect(0, 0, CTileBitMap.Width, CTileBitMap.Height), CTileBitMap.Canvas, Rect(0, 0,CTileBitMap.Width, CTileBitMap.Height));
end;

procedure TMapEdit.UpdateMapInfo(x,y : integer);
var
 mx,my : integer;
begin
  mx:=x div TileWidth;
  my:=y div TileHeight;
  MapInfoLabel.Caption:='X = '+IntToStr(mx)+'  Y = '+IntToStr(my);
end;

end.

