unit MapEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,LMessages,Types,
  ComCtrls, Menus,rmthumb,mapcore,rwmap;

type
 (* TScrollBox = class(Forms.TScrollBox)
     procedure WMHScroll(var Message : TLMHScroll); message LM_HScroll;
     procedure WMVScroll(var Message : TLMVScroll); message LM_VScroll;
   end;
   *)
  { TMapEdit }

  TMapEdit = class(TForm)
    MenuItem10: TMenuItem;
    Clear: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuNew: TMenuItem;
    OpenDialog1: TOpenDialog;
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
    MapImage: TImage;
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

    procedure MenuDeleteClick(Sender: TObject);
    procedure MenuExportBasicMapData(Sender: TObject);
    procedure MenuExportCArray(Sender: TObject);
    procedure MenuExportPascalArray(Sender: TObject);
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

    procedure PlotTileAt(x,y : integer; TTile : TileRec);
    procedure PlotTile(mx,my : integer; TTile : TileRec);
    procedure ClearTile(mx,my : integer);
    procedure PlotMissingTile(mx,my : integer);
    Procedure SetMapTool(Tool : integer);

    procedure LoadTile(index : integer);

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

(*
procedure TScrollBox.WMHScroll(var Message : TLMHScroll);


begin
   inherited WMHScroll(Message);
//   Form1.WMHScroll(Message);
end;

procedure TScrollBox.WMVScroll(var Message : TLMVScroll);
begin
    inherited WMVScroll(Message);
 //   Form1.WMVScroll(Message);
end;

  *)

{$R *.lfm}

{ TMapEdit }

procedure TMapEdit.FormCreate(Sender: TObject);
begin
 SetMapTool(1);  //draw
 CurrentMap:=MapCoreBase.GetCurrentMap;
 MapCoreBase.SetZoomSize(CurrentMap,4);
 //TileZoom.Position:=4;

 MapCoreBase.SetMapTileSize(CurrentMap,32,32);

 CTileBitmap:=TBitMAp.Create;

 MapImage.Width:=MapCoreBase.GetZoomMapPageWidth(CurrentMap);
 MapImage.height:=MapCoreBase.GetZoomMapPageHeight(CurrentMap);

 TileWidth:=MapCoreBase.GetZoomMapTileWidth(CurrentMap);
 TileHeight:=MapCoreBase.GetZoomMapTileHeight(CurrentMap);

 MDownLeft:=False;
 MDownRight:=False;
 CTile.ImageIndex:=-1;
end;

procedure TMapEdit.FormShow(Sender: TObject);
begin
 //bug fix scrollbox scrollbars not displaying correctly after onshow event
  MapImage.AutoSize:=true;
  MapImage.Picture.Bitmap.SetSize(1,1);
  MapImage.Picture.Bitmap.SetSize(MapCoreBase.GetZoomMapPageWidth(CurrentMap),MapCoreBase.GetZoomMapPageHeight(CurrentMap));
  MapImage.AutoSize:=false;
  //end big fix
  if CTile.ImageIndex = -1 then
  begin
    LoadTile(0);     // first time opening MApEdit Window
  end
  else
  begin
    LoadTile(CTile.ImageIndex);   // Follow up open windows - reload current tile incase it was edited
  end;
  UpdateCurrentTile;
  UpdateMapListView;
  UpdateMapView;
end;

procedure TMapEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 hpos:=MapScrollBox.HorzScrollBar.Position;
 vpos:=MapScrollBox.VertScrollBar.Position;
end;

procedure TMapEdit.PlotTile(mx,my : integer; TTile : TileRec);
var
  gx,gy : integer;
begin
 if (mx < 0) or (my<0) or (mx >= MapCoreBase.GetMapWidth(CurrentMap)) or (my >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;
 MapCoreBase.SetMapTile(CurrentMap,mx,my,CTile);

 gx:=mx*TileWidth;
 gy:=my*TileHeight;
 MapImage.canvas.CopyRect(Rect(gx, gy, gx+TileWidth, gy+TileHeight), CTileBitMap.Canvas, Rect(0, 0,CTileBitMap.Width, CTileBitMap.Height));
end;

procedure TMapEdit.ClearTile(mx,my : integer);
var
  gx,gy : integer;
  T : TileRec;
begin
 if (mx < 0) or (my<0) or (mx >= MapCoreBase.GetMapWidth(CurrentMap)) or (my >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;
 T.ImageIndex:=-1;
 MapCoreBase.SetMapTile(CurrentMap,mx,my,T);

 gx:=mx*TileWidth;
 gy:=my*TileHeight;

 MapImage.Canvas.Brush.Color:=clBlack;
 MapImage.Canvas.FillRect(gx,gy,gx+TileWidth,gy+TileHeight);
end;

procedure TMapEdit.PlotMissingTile(mx,my : integer);
var
  gx,gy : integer;
begin
 if (mx < 0) or (my<0) or (mx >= MapCoreBase.GetMapWidth(CurrentMap)) or (my >= MapCoreBase.GetMapHeight(CurrentMap)) then exit;

 gx:=mx*TileWidth;
 gy:=my*TileHeight;

 //red circle on white background
 MapImage.Canvas.Brush.Color:=clWhite;
 MapImage.Canvas.FillRect(gx,gy,gx+TileWidth,gy+TileHeight);
 MapImage.Canvas.Brush.Color:=clRed;
 MapImage.Canvas.Ellipse(gx,gy,gx+TileWidth,gy+TileHeight);
end;


procedure TMapEdit.PlotTileAt(x,y : integer;TTile : TileRec);
var
  mx,my : integer;
begin
 mx:=x div TileWidth;
 my:=y div TileHeight;
 PlotTile(mx,my,TTile);
end;

procedure TMapEdit.MapImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  mx,my : integer;
begin
 UpdateMapInfo(x,y);

 mx:=x div TileWidth;
 my:=y div TileHeight;

 if MDOwnLeft and (CTool=1) then
 begin
   PlotTileAt(x,y,CTile);
 end
 else if (MDOwnRight=true) or ((MDownLeft=true) and (CTool=0)) then
 begin
   ClearTile(mx,my);
 end;
end;

procedure TMapEdit.MapImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  mx,my : integer;
begin
 MDownLeft:=False;
 MDownRight:=False;

 mx:=(x div TileWidth);
 my:=(y div TileHeight);

 if Button = mbRight then
 begin
   MDownRight:=True;
   ClearTile(mx,my);
 end
 else if Button = mbLeft then
 begin
    MDownLeft:=True;
    if CTool = 1 then
    begin
      PlotTileAt(x,y,CTile);
    end
    else if CTool = 0 then
    begin
      ClearTile(mx,my);
    end;
 end;
end;


procedure TMapEdit.MapImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MDownLeft:=False;
  MDownRight:=False;
end;

procedure TMapEdit.ClearMapClick(Sender: TObject);
begin
  MapCoreBase.ClearMap(CurrentMap,-1);
  MapImage.Canvas.Brush.Color:=clBlack;
  MapImage.Canvas.FillRect(0,0,MapImage.Width,MApImage.HEight);
//  UpdateMapView;
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
     UpdateMapView;
   end;
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
      UpdateMapView;
    end;
  end
  else
  begin
    MapCoreBase.ClearMap(0,-1);  // if there is only one map we just clear it
    UpdatePageSize;
    UpdateMapView;
  end;
end;

procedure TMapEdit.MenuExportBasicMapData(Sender: TObject);
begin
 SaveDialog1.Filter := 'Basic|*.bas|All Files|*.*';
 if SaveDialog1.Execute then
 begin
  ExportBasicMap(SaveDialog1.FileName);
 end;
end;

procedure TMapEdit.MenuExportCArray(Sender: TObject);
begin
 SaveDialog1.Filter := 'c|*.c|All Files|*.*';
 if SaveDialog1.Execute then
 begin
  ExportCMap(SaveDialog1.FileName);
 end;
end;

procedure TMapEdit.MenuExportPascalArray(Sender: TObject);
begin
  SaveDialog1.Filter := 'Pascal|*.pas|All Files|*.*';
  if SaveDialog1.Execute then
  begin
   ExportPascalMap(SaveDialog1.FileName);
  end;
end;

procedure TMapEdit.MenuNewClick(Sender: TObject);
begin
  MapCoreBase.AddMap;
  MapCoreBase.SetCurrentMap(MapCoreBase.GetMapCount-1);
  CurrentMap:=MapCoreBase.GetCurrentMap;
  UpdateMapListView;
  UpdatePageSize;
  UpdateMapView;
end;

procedure TMapEdit.MenuOpenClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'RM MAP Files|*.map|All Files|*.*';
  if OpenDialog1.Execute then
  begin
   ReadMap(OpenDialog1.FileName);
   UpdatePageSize;
   UpdateMapView;
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
 UpdateMapView;
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
  UpdateMapView;
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

 (*   SelectedTileImage.Canvas.Clear;
    For j:=0 to aheight-1 do
    begin
      For i:=0 to awidth-1 do
      begin
        SelectedTileImage.Canvas.Pixels[i,j]:=ImageThumbBase.GetPixelTColor(item.Index,i,j);
      end;
    end;
   *)
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
  UpdateMapView;
end;

procedure TMapEdit.UpdateMapView;
var
  i,j : integer;
  T   : TileRec;
  LastTile : TileRec;
  STile    : integer;
  FIndex   : integer;
begin
 STile:=CTile.ImageIndex;
 LastTile.ImageIndex:=-255;
 for j:=0 to MapCoreBase.GetMapWidth(CurrentMap)-1 do
  begin
    for i:=0 to MapCoreBase.GetMapHeight(CurrentMap)-1 do
    begin
      MapCoreBase.GetMapTile(CurrentMap,i,j,T);
      if T.ImageIndex > -1 then
      begin
         //(LastTile.ImageIndex<>T.ImageIndex) and  IsEqualGUID(LastTile.ImageUID,T.ImageUID)=false then   //skip reloading if the same time
         if IsEqualGUID(LastTile.ImageUID,T.ImageUID)=false then   //skip reloading if the same time
         begin
           FIndex:=ImageThumbBase.FindUID(T.ImageUID);
           if  FIndex > -1 then     // check if image exist - it might have been deleted
           begin
             T.ImageIndex:=FIndex;
             LoadTile(T.ImageIndex);
             PlotTile(i,j,T);
             LastTile.ImageIndex:=T.ImageIndex;
             LastTile.ImageUID:=T.ImageUID;
           end
           else
           begin
             PlotMissingTile(i,j);
           end;
         end
         else
         begin
           PlotTile(i,j,T);
         end;
      end;
    end;
  end;
  LoadTile(STile); //load the tile that is currently selected
end;

procedure TMapEdit.UpdateTileView;
var
  i,count : integer;
begin
 (*
 ImageList1.Clear;
 ImageThumbBase.UpdateAllThumbImages(imagelist1);
 *)
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
  // MapListView.Items[i].ImageIndex:=i;
 end;
end;

procedure TMapEdit.UpdatePageSize;
begin
 MapImage.AutoSize:=true;
 MapImage.Picture.Bitmap.SetSize(1,1);
 MapImage.Picture.Bitmap.SetSize(MapCoreBase.GetZoomMapPageWidth(CurrentMap),MapCoreBase.GetZoomMapPageHeight(CurrentMap));
 MapImage.AutoSize:=false;
end;

procedure TMapEdit.UpdateCurrentTile;
begin
  SelectedTileImage.Picture.Bitmap.SetSize(CTileBitMap.Width, CTileBitMap.Height);
  SelectedTileImage.canvas.CopyRect(Rect(0, 0, CTileBitMap.Width, CTileBitMap.Height), CTileBitMap.Canvas, Rect(0, 0,CTileBitMap.Width, CTileBitMap.Height));
 (*   For j:=0 to aheight-1 do
    begin
      For i:=0 to awidth-1 do
      begin
        SelectedTileImage.Canvas.Pixels[i,j]:=ImageThumbBase.GetPixelTColor(item.Index,i,j);
      end;
    end;
   *)
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

