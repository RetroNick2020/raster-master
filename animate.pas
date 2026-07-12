unit animate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ExtCtrls,
  ComCtrls, StdCtrls, Menus, Types, Math, AnimBase,animationexport,rmthumb,rwpng,
  fileprops,rwspriteanim,rmcodegen,rmconfig,rmclipboard;

const
  FRAME_IMG_SIZE = 128;
  FRAME_PAD      = 4;
  FRAME_LABEL_H  = 18;
  FRAME_CELL_W   = FRAME_IMG_SIZE + 2 * FRAME_PAD;   // 136
  FRAME_CELL_H   = FRAME_IMG_SIZE + 2 * FRAME_PAD + FRAME_LABEL_H;  // 154
  DRAG_THRESHOLD = 5;

type

  { TAnimationForm }

  TAnimationForm = class(TForm)
    CurrentAnimationImageList: TImageList;
    TransSpriteImageList: TImageList;
    TransAnimThumbImageList: TImageList;
    AnimThumbImageList: TImageList;
    CopyMenu: TMenuItem;
    AddFrameMenu: TMenuItem;
    DeleteMenu: TMenuItem;
    CopyFromThumbView: TMenuItem;
    AnimDeleteMenu: TMenuItem;
    FrameScrollBox: TScrollBox;
    FramePaintBox: TPaintBox;
    Image1: TImage;
    Image2: TImage;
    lblSimStyle: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuDeleteAll: TMenuItem;
    AnimProperties: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    ExportCAnimArray: TMenuItem;
    MenuItem15: TMenuItem;
    ExportEmscriptenAnimArray: TMenuItem;
    ExportPascalAnimArray: TMenuItem;
    //extended compiler export menu items
    MnuAnimExpAB, AD_AB : TMenuItem;
    MnuAnimExpAC, AD_AC : TMenuItem;
    MnuAnimExpAP, AD_AP : TMenuItem;
    MnuAnimExpAQB, AD_AQB : TMenuItem;
    MnuAnimExpBAM, AD_BAM : TMenuItem;
    MnuAnimExpFBQB, AD_FBQB : TMenuItem;
    MnuAnimExpFB, AD_FB : TMenuItem;
    MnuAnimExpFP, AD_FP : TMenuItem;
    MnuAnimExpGCC, AD_GCC : TMenuItem;
    MnuAnimExpGW, AD_GW : TMenuItem;
    MnuAnimExpJS, AD_JS : TMenuItem;
    MnuAnimExpJSON, AD_JSON : TMenuItem;
    MnuAnimExpOW, AD_OW : TMenuItem;
    MnuAnimExpQB, AD_QB : TMenuItem;
    MnuAnimExpQB64, AD_QB64 : TMenuItem;
    MnuAnimExpQBJS, AD_QBJS : TMenuItem;
    MnuAnimExpQC, AD_QC : TMenuItem;
    MnuAnimExpQP, AD_QP : TMenuItem;
    MnuAnimExpTB, AD_TB : TMenuItem;
    MnuAnimExpTP, AD_TP : TMenuItem;
    MnuAnimExpTC, AD_TC : TMenuItem;
    MnuAnimExpTMT, AD_TMT : TMenuItem;
    FileExportBasicData: TMenuItem;
    ExportBasicAnimData: TMenuItem;
    pascal: TMenuItem;
    MenuItem17: TMenuItem;
    ExportgccAnimArray: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    NewAnimationMenu: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    PasteMenu: TMenuItem;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    PopupMenu3: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SimPanel: TPanel;
    SimPaintBox: TPaintBox;
    StatusBar1: TStatusBar;
    SimStyleCombo: TComboBox;
    MovementSpeedTrackBar: TTrackBar;
    lblMovementSpeed: TLabel;
    ViewMenu: TMenuItem;
    ViewTransparentToggle: TMenuItem;
    SpriteListView: TListView;
    AllAnimListView: TListView;
    LeftPanel: TPanel;
    MiddlePanel: TPanel;
    RightPanel: TPanel;
    Timer1: TTimer;
    TopSplitter: TSplitter;
    LeftSplitter: TSplitter;
    RightSplitter: TSplitter;
    FPSTrackBar: TTrackBar;
    procedure AddFrameMenuClick(Sender: TObject);
    procedure AllAnimListViewClick(Sender: TObject);
    procedure AllAnimListViewShowHint(Sender: TObject; HintInfo: PHintInfo);
    procedure AnimDeleteMenuClick(Sender: TObject);
    procedure AnimPropertiesClick(Sender: TObject);

    procedure Button1Click(Sender: TObject);
    procedure CopyFromThumbViewClick(Sender: TObject);
    procedure CopyMenuClick(Sender: TObject);

    procedure FramePaintBoxPaint(Sender: TObject);
    procedure FramePaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FramePaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FramePaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FramePaintBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FramePaintBoxDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FrameScrollBoxResize(Sender: TObject);

    procedure SimPaintBoxPaint(Sender: TObject);
    procedure SimStyleComboChange(Sender: TObject);
    procedure ViewTransparentToggleClick(Sender: TObject);
    procedure MovementSpeedTrackBarChange(Sender: TObject);

    procedure DeleteMenuClick(Sender: TObject);
    procedure ExportBasicAnimDataClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure AnimExportMenuClick(Sender: TObject);
    procedure AnimCopyMenuClick(Sender: TObject);
    procedure AnimPasteMenuClick(Sender: TObject);
    procedure MenuDeleteAllClick(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure ExportEmscriptenAnimArrayClick(Sender: TObject);
    procedure FileExportPascalArrayClick(Sender: TObject);
    procedure MenuExportAnimLanClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure NewAnimationMenuClick(Sender: TObject);

    procedure PasteMenuClick(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
    procedure SpriteListViewDblClick(Sender: TObject);
    procedure SpriteListViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SpriteListViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure StopButtonClick(Sender: TObject);

    procedure Timer1StartTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FPSTrackBarChange(Sender: TObject);
  private
    procedure ExportAnimationJSON(filename : string);
    procedure ExportAnimationJS(filename : string);
    procedure UpdateStatusBar;
  public
    AnimFrameCounter : integer;
    FAnimAccumMs : integer;   //ms accumulator - decouples frame advance (speed) from display rate (fps)
    FPSDelay         : integer;

    { Frame grid state - palette editor style }
    FSelectedFrame : integer;
    FDragActive    : boolean;
    FDragIndex     : integer;
    FDragOrigin    : TPoint;
    FDropIndex     : integer;

    { Simulation }
    FSimTick       : integer;
    FSimMovePos    : integer;
    ShowTransparent : boolean;
    FCheckerBmp    : TBitmap;
    FMovementSpeed : integer;

    procedure LoadImageThumbList;
    procedure LoadCurrentAnimList;
    procedure LoadAnimThumbList;
    procedure AddFrame(ImageIndex : integer);
    procedure InsertFrame(FrameIndex,ImageIndex : integer);
    procedure MoveFrame(FromFrameIndex,ToFrameIndex : integer);
    procedure DeleteFrame(ImageIndex : integer);
    procedure AddEmptyFrame;

    procedure AddAnimation;
    procedure DeleteAnimation(AnimationIndex : integer);
    procedure DeleteAll;
    procedure SelectAnimation(AnimationIndex : integer);

    { Frame grid helpers - palette editor style }
    function GetFrameRect(Index : integer) : TRect;
    function FrameHitTest(X, Y : integer) : integer;
    function FrameInsertHitTest(X, Y : integer) : integer;
    procedure UpdateFrameGridSize;

    { Simulation helpers }
    procedure UpdateSimulation;
    procedure DrawSimSprite(ACanvas : TCanvas; X, Y, ImgIdx : integer);
    procedure DrawSimBackground(ACanvas : TCanvas; W, H : integer; HasGround : boolean);
    procedure RebuildTransSpriteImageList;
    procedure RebuildTransAnimThumbImageList;

    function ExportTextFileToClipboard(Sender: TObject) : boolean;
  end;

var
  AnimationForm: TAnimationForm;

implementation
       uses rmmain;
{$R *.lfm}

{ TAnimationForm }


procedure TAnimationForm.FormCreate(Sender: TObject);
var
  i, j : integer;
begin
  FPSDelay:=1000 Div FPSTrackBar.Position;
  FSelectedFrame:=-1;
  FDragActive:=False;
  FDragIndex:=-1;
  FDropIndex:=-1;
  FSimTick:=0;
  FSimMovePos:=0;
  ShowTransparent:=False;
  FMovementSpeed:=4;
  SimStyleCombo.ItemIndex:=0;

  FCheckerBmp:=TBitmap.Create;
  FCheckerBmp.SetSize(256, 256);
  FCheckerBmp.Canvas.Brush.Color:=clWhite;
  FCheckerBmp.Canvas.FillRect(0, 0, 256, 256);
  FCheckerBmp.Canvas.Brush.Color:=RGBToColor(192, 192, 192);
  for i:=0 to 15 do
    for j:=0 to 15 do
      if ((i + j) mod 2) = 0 then
        FCheckerBmp.Canvas.FillRect(i*16, j*16, (i+1)*16, (j+1)*16);
end;

procedure TAnimationForm.AnimExportMenuClick(Sender: TObject);
  var
   PngRGBA : PngRGBASettingsRec;
   FileName : String;
   i : integer;
   ImageIndex : integer;
   count      : integer;
  begin
   //ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
   count:=0;
   FilePropertiesDialog.GetProps(PngRGBA);
   if SelectDirectoryDialog1.Execute then
   begin
     for i:=0 to AnimateBase.GetFrameCount-1 do
     begin
       ImageIndex:=AnimateBase.GetImageIndex(i);
       inc(count);
       FileName:=IncludeTrailingPathDelimiter(SelectDirectoryDialog1.filename)+'Animation'+IntToStr(count)+'.png';
       SaveFromThumbAsPNG(ImageIndex,FileName,PngRGBA);
     end;
   end;
end;


procedure TAnimationForm.AnimCopyMenuClick(Sender: TObject);
 var
  index : integer;
 begin
 if SpriteListView.ItemIndex > -1  then
 begin
    index:=SpriteListView.ItemIndex;
    if index > -1 then AnimateBase.CopyToClipBoard(index,ImageThumbBase.GetUID(index));
 end
 else if FSelectedFrame > -1 then
 begin
   index:=FSelectedFrame;
   if index > -1 then AnimateBase.CopyToClipBoard(AnimateBase.GetImageIndex(index),AnimateBase.GetUID(index));
 end
 else if AllAnimListView.ItemIndex > -1 then
 begin

 end;
end;

procedure TAnimationForm.AnimPasteMenuClick(Sender: TObject);
var
 index : integer;
 ImageIndex : integer;
 uid : TGUID;
begin
  index:=FSelectedFrame;
  if index > -1 then
  begin
    if AnimateBase.GetClipBoardStatus then
    begin
     AnimateBase.PasteFromClipBoard(ImageIndex,uid);
     AnimateBase.ChangeFrame(index,ImageIndex,uid);
     FramePaintBox.Invalidate;
    end;
  end;
end;

procedure TAnimationForm.MenuDeleteAllClick(Sender: TObject);
begin
  DeleteAll;
  UpdateStatusBar;
end;

procedure TAnimationForm.MenuItem10Click(Sender: TObject);
begin
  AddEmptyFrame;
end;


procedure TAnimationForm.MenuItem2Click(Sender: TObject);
begin
 OpenDialog1.Filter := 'RM Animation Files|*.rma|All Files|*.*';
 if OpenDialog1.Execute then
 begin
  AnimateBase.Open(OpenDialog1.FileName);
  LoadCurrentAnimList;
  LoadAnimThumbList;

  FramePaintBox.Invalidate;
  AllAnimListView.Repaint;
 end;
end;

procedure TAnimationForm.MenuItem3Click(Sender: TObject);
begin
 SaveDialog1.Filter := 'RM Animation Files|*.rma|All Files|*.*';
 if SaveDialog1.Execute then
 begin
   AnimateBase.Save(SaveDialog1.FileName);
 end;
end;

procedure TAnimationForm.MenuItem9Click(Sender: TObject);
begin
  AddAnimation;
end;

procedure TAnimationForm.AddAnimation;
begin
  AnimateBase.AddAnimation;
  AnimateBase.SetCurrentAnimation(AnimateBase.GetAnimationCount-1);    //animation will be added to end of list - switch to that

  LoadCurrentAnimList;
  LoadAnimThumbList;

  FramePaintBox.Invalidate;
  AllAnimListView.Repaint;
end;


procedure TAnimationForm.DeleteAnimation(AnimationIndex : integer);
begin
  AnimateBase.DeleteAnimation(AnimationIndex);

  LoadCurrentAnimList;
  LoadAnimThumbList;

  FramePaintBox.Invalidate;
  AllAnimListView.Repaint;
end;

procedure TAnimationForm.MenuItem11Click(Sender: TObject);
var
  index : integer;
begin
  index:=FSelectedFrame;
  if index > -1 then DeleteFrame(Index);

  index:=AllAnimListView.ItemIndex;
  if index > -1 then DeleteAnimation(Index);
end;

procedure TAnimationForm.ExportEmscriptenAnimArrayClick(Sender: TObject);
begin
  if ExportTextFileToClipboard(Sender) then exit;

  SaveDialog1.Filter := 'C Source Files|*.c|C Header Files|*.h|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    ExportAnimation(SaveDialog1.FileName,cLan);
  end;
end;

procedure TAnimationForm.FileExportPascalArrayClick(Sender: TObject);
begin
  if ExportTextFileToClipboard(Sender) then exit;

  SaveDialog1.Filter := 'Pascal Source Files|*.pas|Pascal Include Files|*.inc|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    ExportAnimation(SaveDialog1.FileName,PascalLan);
  end;
end;

procedure TAnimationForm.ExportBasicAnimDataClick(Sender: TObject);
begin
if ExportTextFileToClipboard(Sender) then exit;

SaveDialog1.Filter := 'Basic Source Files|*.bas|Basic Include Files|*.bi|All Files|*.*';
if SaveDialog1.Execute then
begin
  ExportAnimation(SaveDialog1.FileName,BasicLan);
end;

end;

//exports the current animation as a pure JSON data descriptor
procedure TAnimationForm.ExportAnimationJSON(filename : string);
var
  F : TextFile;
  i, fcount, cur : integer;
  exportname, line : string;
begin
  cur:=AnimateBase.GetCurrentAnimation;
  fcount:=AnimateBase.GetFrameCount;
  exportname:=AnimateBase.GetExportName(cur);
  if exportname = '' then exportname:='anim' + IntToStr(cur);

  AssignFile(F, filename);
  Rewrite(F);
  WriteLn(F,'{');
  WriteLn(F,'  "name": "',exportname,'",');
  WriteLn(F,'  "frameCount": ',fcount,',');
  line:='  "frames": [';
  for i:=0 to fcount-1 do
  begin
    line:=line+IntToStr(AnimateBase.GetImageIndex(i));
    if i < fcount-1 then line:=line+',';
  end;
  line:=line+']';
  WriteLn(F,line);
  WriteLn(F,'}');
  CloseFile(F);
end;

//exports the current animation as a JavaScript const array
procedure TAnimationForm.ExportAnimationJS(filename : string);
var
  F : TextFile;
  i, fcount, cur : integer;
  exportname, line : string;
begin
  cur:=AnimateBase.GetCurrentAnimation;
  fcount:=AnimateBase.GetFrameCount;
  exportname:=AnimateBase.GetExportName(cur);
  if exportname = '' then exportname:='anim' + IntToStr(cur);

  AssignFile(F, filename);
  Rewrite(F);
  WriteLn(F,'// JavaScript Animation Data Created By Raster Master');
  WriteLn(F,'// Frame Count = ',fcount);
  line:='const '+exportname+'Anim = [';
  for i:=0 to fcount-1 do
  begin
    line:=line+IntToStr(AnimateBase.GetImageIndex(i));
    if i < fcount-1 then line:=line+',';
  end;
  line:=line+'];';
  WriteLn(F,line);
  CloseFile(F);
end;

procedure TAnimationForm.UpdateStatusBar;
var
  cur, total, fcount : integer;
  exportname : string;
begin
  if StatusBar1.Panels.Count < 5 then exit;

  cur:=AnimateBase.GetCurrentAnimation;
  total:=AnimateBase.GetAnimationCount;
  fcount:=AnimateBase.GetFrameCount;
  exportname:=AnimateBase.GetExportName(cur);
  if exportname = '' then exportname:='(unnamed)';

  StatusBar1.Panels[0].Text:='Animation: '+IntToStr(cur+1)+'/'+IntToStr(total)+' '+exportname;
  StatusBar1.Panels[1].Text:='Frames: '+IntToStr(fcount);
  StatusBar1.Panels[2].Text:='Frame: '+IntToStr(AnimFrameCounter)+'/'+IntToStr(fcount);
  StatusBar1.Panels[3].Text:='FPS: '+IntToStr(FPSTrackBar.Position)+' Move: '+IntToStr(FMovementSpeed);
  if ShowTransparent then
    StatusBar1.Panels[4].Text:='Transparent'
  else
    StatusBar1.Panels[4].Text:='';
end;

//shared handler for all extended compiler targets - the menu item Tag
//holds the map Lan constant, which we map to the syntax family that
//ExportAnimation understands
procedure TAnimationForm.MenuExportAnimLanClick(Sender: TObject);
var
  Lan : integer;
begin
  if ExportTextFileToClipboard(Sender) then exit;

  Lan:=(Sender as TMenuItem).Tag;

  if MapLanIsBasic(Lan) or MapLanIsBasicLN(Lan) then
    SaveDialog1.Filter := 'Basic Source Files|*.bas|Basic Include Files|*.bi|All Files|*.*'
  else if MapLanIsPascal(Lan) then
    SaveDialog1.Filter := 'Pascal Source Files|*.pas|Pascal Include Files|*.inc|All Files|*.*'
  else if MapLanIsC(Lan) then
    SaveDialog1.Filter := 'C Source Files|*.c|C Header Files|*.h|All Files|*.*'
  else if MapLanIsJS(Lan) then
    SaveDialog1.Filter := 'JavaScript|*.js|All Files|*.*'
  else if MapLanIsJSON(Lan) then
    SaveDialog1.Filter := 'JSON|*.json|All Files|*.*'
  else
    SaveDialog1.Filter := 'All Files|*.*';

  if not SaveDialog1.Execute then exit;

  if MapLanIsBasic(Lan) then ExportAnimation(SaveDialog1.FileName,BasicLan)
  else if MapLanIsBasicLN(Lan) then ExportAnimation(SaveDialog1.FileName,BasicLNLan)
  else if MapLanIsPascal(Lan) then ExportAnimation(SaveDialog1.FileName,PascalLan)
  else if MapLanIsC(Lan) then ExportAnimation(SaveDialog1.FileName,CLan)
  else if MapLanIsJS(Lan) then ExportAnimationJS(SaveDialog1.FileName)
  else if MapLanIsJSON(Lan) then ExportAnimationJSON(SaveDialog1.FileName);
end;

function TAnimationForm.ExportTextFileToClipboard(Sender: TObject) : boolean;
var
 filename : string;
 mi : TMenuItem;
 Lan : integer;
begin
 if rmconfigbase.GetExportTextFileToClipStatus = false then
 begin
   result:=false;
   exit;
 end;

 filename:=GetTemporaryPathAndFileName;
 mi:=Sender As TMenuItem;
 Case mi.Name of  'ExportBasicAnimData':ExportAnimation(FileName,BasicLan);
                                     'ExportBasicLNAnimData':ExportAnimation(FileName,BasicLNLan);
                                     'ExportCAnimArray','ExportEmscriptenAnimArray','ExportgccAnimArray': ExportAnimation(FileName,CLan);
                                     'ExportPascalAnimArray':ExportAnimation(FileName,PascalLan);

 else
   //Tag-based dispatch for extended compiler targets (items named AD_*)
   if (mi.Tag > 0) and (Copy(mi.Name,1,3) = 'AD_') then
   begin
     Lan:=mi.Tag;
     if MapLanIsBasic(Lan) then ExportAnimation(FileName,BasicLan)
     else if MapLanIsBasicLN(Lan) then ExportAnimation(FileName,BasicLNLan)
     else if MapLanIsPascal(Lan) then ExportAnimation(FileName,PascalLan)
     else if MapLanIsC(Lan) then ExportAnimation(FileName,CLan)
     else if MapLanIsJS(Lan) then ExportAnimationJS(FileName)
     else if MapLanIsJSON(Lan) then ExportAnimationJSON(FileName)
     else
     begin
       result:=false;
       exit;
     end;
   end
   else
   begin
     result:=false;  //did not find a supported format return false
     exit;
   end;
 End;

 result:=true;  //found supported format - return true

 ReadFileAndCopyToClipboard(filename);
 EraseFile(filename);
 ShowMessage('Exported to Clipboard!');
end;


procedure TAnimationForm.AnimDeleteMenuClick(Sender: TObject);
var
  index : integer;
begin
   index:=AllAnimListView.ItemIndex;
   if index > -1 then  DeleteAnimation(index);
  UpdateStatusBar;
end;



procedure TAnimationForm.DeleteAll;
begin
// AnimateBase.DeleteAll;
 AnimateBase.InitAnimation;
 FSelectedFrame:=-1;

 LoadCurrentAnimList;
 LoadAnimThumbList;

 FramePaintBox.Invalidate;
 AllAnimListView.Repaint;
end;

procedure TAnimationForm.SelectAnimation(AnimationIndex : integer);
begin
  AnimateBase.SetCurrentAnimation(AnimationIndex);
  FSelectedFrame:=-1;
  LoadCurrentAnimList;
  LoadAnimThumbList;

  FramePaintBox.Invalidate;
  AllAnimListView.Repaint;
end;


procedure TAnimationForm.NewAnimationMenuClick(Sender: TObject);
begin
 AddAnimation;
  UpdateStatusBar;
end;



procedure TAnimationForm.PasteMenuClick(Sender: TObject);
var
  index,ImageIndex : integer;
  uid : TGUID;
begin
  index:=FSelectedFrame;
  if index > -1 then
  begin
    if AnimateBase.GetClipBoardStatus then
    begin
      AnimateBase.PasteFromClipBoard(ImageIndex,uid);
      AnimateBase.ChangeFrame(index,ImageIndex,uid);
      LoadCurrentAnimList;
      FramePaintBox.Invalidate;
    end;
  end
  else    //if paste in area where there is no empty frame or other image
  begin
     if AnimateBase.GetClipBoardStatus then
     begin
       AnimateBase.PasteFromClipBoard(ImageIndex,uid);
       AddFrame(ImageIndex);
     end;
  end;
end;

procedure TAnimationForm.PlayButtonClick(Sender: TObject);
begin
  Timer1.Enabled:=true;
end;

procedure TAnimationForm.SpriteListViewDblClick(Sender: TObject);
begin
//  ShowMessage(IntToStr((Sender as TListView).ItemIndex));
   AddFrame((Sender as TListView).ItemIndex);
end;

procedure TAnimationForm.LoadCurrentAnimList;
var
  ImageCount,i : integer;
  MEBitMap  : TBitMap;
  FoundImage     : integer;

begin
   CurrentAnimationImageList.Clear;
   CurrentAnimationImageList.Width:=128;
   CurrentAnimationImageList.Height:=128;
   CurrentAnimationImageList.AddImages(RmMainForm.ImageList1);

   MEBitMap:=TBitMap.Create;
   MEBitMap.SetSize(128,128);
   MEBitMap.Canvas.FillRect(0,0,127,127);

   CurrentAnimationImageList.Add(MEBitMap,nil);
   MEBitMap.Free;
   ImageCount:=AnimateBase.GetFrameCount;

   // verify UIDs and fix up indices
   for i:=0 to ImageCount-1 do
   begin
     if IsEqualGUID(AnimateBase.GetUID(i),ImageThumbBase.GetUID(i)) then
     begin
       // image still at expected position
     end
     else
     begin
       FoundImage:=ImageThumbBase.FindUID(AnimateBase.GetUID(i));
       if FoundImage<>-1 then
       begin
          AnimateBase.ChangeFrame(i,FoundImage,AnimateBase.GetUID(i));
       end;
       // if not found, paint handler will show placeholder
     end;
   end;

   // clamp selection
   if FSelectedFrame >= ImageCount then
     FSelectedFrame:=ImageCount-1;

   UpdateFrameGridSize;
   FramePaintBox.Invalidate;
end;

procedure TAnimationForm.LoadImageThumbList;
var
  ImageCount,i : integer;
begin
   SpriteListView.Items.Clear;
   ImageCount:=ImageThumbBase.GetCount;
   for i:=0 to ImageCount-1 do
   begin
     SpriteListView.AddItem('Image '+IntToStr(i+1), self);
     SpriteListView.Items[i].ImageIndex:=i;
   end;
   CurrentAnimationImageList.Clear;
   CurrentAnimationImageList.Width:=128;
   CurrentAnimationImageList.Height:=128;
   CurrentAnimationImageList.AddImages(RMMainForm.ImageList1);
end;

procedure TAnimationForm.LoadAnimThumbList;
var
  AnimCount,i : integer;
begin
   AnimThumbImageList.Clear;
   AnimThumbImageList.Width:=128;
   AnimThumbImageList.Height:=128;
   AnimThumbImageList.AddImages(CurrentAnimationImageList);

   AllAnimListView.Items.Clear;
   AnimCount:=AnimateBase.GetAnimationCount;
   for i:=0 to AnimCount-1 do
   begin
     AllAnimListView.AddItem('Animation '+IntToStr(i+1), self);
     if AnimateBase.GetImageIndex(i,0) <> -1 then
        AllAnimListView.Items[i].ImageIndex:=AnimateBase.GetImageIndex(i,0)
     else
        AllAnimListView.Items[i].ImageIndex:=AnimThumbImageList.Count-1; //empty frame icon
   end;
end;

procedure TAnimationForm.SpriteListViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin

end;

procedure TAnimationForm.SpriteListViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin

end;

procedure TAnimationForm.StopButtonClick(Sender: TObject);
begin
  Timer1.Enabled:=false;
  SimPaintBox.Invalidate;
end;



procedure TAnimationForm.Timer1StartTimer(Sender: TObject);
begin
  AnimFrameCounter:=0;
  FSimTick:=0;
  FSimMovePos:=0;
end;

procedure TAnimationForm.Timer1Timer(Sender: TObject);
var
   ImageIndex : integer;
   FramePeriod : integer;
begin
  //the timer ticks at the FPS rate (display refresh only).
  //the animation frame advances on a time accumulator driven by the
  //Speed gauge, so FPS controls smoothness and Speed controls speed.
  inc(FAnimAccumMs, Timer1.Interval);
  FramePeriod:=1000 div FMovementSpeed;   //speed 1 = 1 frame/sec ... speed 10 = 10 frames/sec

  //advance as many frames as the elapsed time calls for - a while loop
  //so a low FPS (long tick) still plays the animation at the same speed
  //by stepping several frames in one tick
  while FAnimAccumMs >= FramePeriod do
  begin
    dec(FAnimAccumMs, FramePeriod);

    inc(AnimFrameCounter);
    if AnimFrameCounter > AnimateBase.GetFrameCount then
      AnimFrameCounter:=1;

    //movement advances with the animation, not with the display rate
    inc(FSimTick);
    inc(FSimMovePos, FMovementSpeed);
  end;

  if  AnimateBase.GetFrameCount > 0 then
  begin
    //clamp - frames may have been deleted while the timer was running
    //and the reset above only runs when a frame advance happens
    if (AnimFrameCounter < 1) or (AnimFrameCounter > AnimateBase.GetFrameCount) then
      AnimFrameCounter:=1;

    ImageIndex:=AnimateBase.GetImageIndex(AnimFrameCounter-1);

    // Panel1 preview - original working draw call
    Panel1.Canvas.Brush.Color:=Panel1.Color;
    Panel1.Canvas.FillRect(Rect(10,10,138,138));
    DrawSimSprite(Panel1.Canvas, 10, 10, ImageIndex);

    UpdateSimulation;
  end;
  //update frame counter display during playback
  if StatusBar1.Panels.Count >= 3 then
    StatusBar1.Panels[2].Text:='Frame: '+IntToStr(AnimFrameCounter)+'/'+IntToStr(AnimateBase.GetFrameCount);
end;

procedure TAnimationForm.FPSTrackBarChange(Sender: TObject);
begin
  FPSDelay:=1000 div FPSTrackBar.Position;
  Timer1.Interval:=FPSDelay;
  UpdateStatusBar;
end;

procedure TAnimationForm.FormActivate(Sender: TObject);
begin
   LoadImageThumbList;
   LoadCurrentAnimList;
   LoadAnimThumbList;
   if ShowTransparent then
   begin
     ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
     RebuildTransSpriteImageList;
     RebuildTransAnimThumbImageList;
   end;
   SpriteListView.Repaint;
   FramePaintBox.Invalidate;
   AllAnimListView.Repaint;
   UpdateStatusBar;
end;

procedure TAnimationForm.AddFrame(ImageIndex : integer);
var
  uid  : TGUID;
begin
   uid:=ImageThumbBase.GetUID(ImageIndex);
   AnimateBase.AddFrame(ImageIndex,uid);
   FSelectedFrame:=AnimateBase.GetFrameCount-1;
   LoadCurrentAnimList;
   FramePaintBox.Invalidate;
   LoadAnimThumbList;
   AllAnimListView.Repaint;
   UpdateStatusBar;
end;


procedure TAnimationForm.AddEmptyFrame;
var
  uid  : TGUID;
begin
   AnimateBase.AddFrame(-1,uid);
   FSelectedFrame:=AnimateBase.GetFrameCount-1;
   LoadCurrentAnimList;
   FramePaintBox.Invalidate;
   LoadAnimThumbList;
   AllAnimListView.Repaint;
end;

procedure TAnimationForm.DeleteFrame(ImageIndex : integer);
begin
   AnimateBase.DeleteFrame(ImageIndex);
   if FSelectedFrame >= AnimateBase.GetFrameCount then
     FSelectedFrame:=AnimateBase.GetFrameCount-1;
   LoadCurrentAnimList;
   FramePaintBox.Invalidate;
   LoadAnimThumbList;
   AllAnimListView.Repaint;
end;


procedure TAnimationForm.InsertFrame(FrameIndex,ImageIndex : integer);
var
  uid  : TGUID;
begin
   uid:=ImageThumbBase.GetUID(ImageIndex);
   AnimateBase.InsertFrame(FrameIndex, ImageIndex,uid);
   FSelectedFrame:=FrameIndex;
   LoadCurrentAnimList;
   FramePaintBox.Invalidate;
   if FrameIndex = 0 then
   begin
     LoadAnimThumbList;
     AllAnimListView.Repaint;
   end;
end;


procedure TAnimationForm.MoveFrame(FromFrameIndex,ToFrameIndex : integer);
begin
   if FromFrameIndex <> ToFrameIndex then
   begin
     AnimateBase.MoveFrame(FromFrameIndex, ToFrameIndex);
     FSelectedFrame:=ToFrameIndex;
     LoadCurrentAnimList;
     FramePaintBox.Invalidate;

     if (FromFrameIndex = 0) or (ToFrameIndex = 0) then
     begin
       LoadAnimThumbList;
       AllAnimListView.Repaint;
     end;
   end;
end;

{ ===== Frame Grid Helpers - palette editor style ===== }

function TAnimationForm.GetFrameRect(Index : integer) : TRect;
var
  Col, Row, Cols : integer;
begin
  Cols:=Max(1, FramePaintBox.Width div FRAME_CELL_W);
  Col:=Index mod Cols;
  Row:=Index div Cols;
  Result.Left:=FRAME_PAD + Col * FRAME_CELL_W;
  Result.Top:=FRAME_PAD + Row * FRAME_CELL_H;
  Result.Right:=Result.Left + FRAME_CELL_W - FRAME_PAD;
  Result.Bottom:=Result.Top + FRAME_CELL_H - FRAME_PAD;
end;

function TAnimationForm.FrameHitTest(X, Y : integer) : integer;
var
  Col, Row, Cols, Idx : integer;
begin
  Result:=-1;
  Cols:=Max(1, FramePaintBox.Width div FRAME_CELL_W);
  Col:=(X - FRAME_PAD) div FRAME_CELL_W;
  Row:=(Y - FRAME_PAD) div FRAME_CELL_H;
  if (Col < 0) or (Col >= Cols) then exit;
  if (Row < 0) then exit;
  Idx:=Row * Cols + Col;
  if (Idx >= 0) and (Idx < AnimateBase.GetFrameCount) then
    Result:=Idx;
end;

function TAnimationForm.FrameInsertHitTest(X, Y : integer) : integer;
var
  Col, Row, Cols, Idx, CellX : integer;
begin
  Result:=-1;
  Cols:=Max(1, FramePaintBox.Width div FRAME_CELL_W);
  Col:=(X - FRAME_PAD) div FRAME_CELL_W;
  Row:=(Y - FRAME_PAD) div FRAME_CELL_H;
  if Row < 0 then exit;

  CellX:=(X - FRAME_PAD) mod FRAME_CELL_W;
  Idx:=Row * Cols + Col;

  if CellX > FRAME_CELL_W div 2 then
    inc(Idx);

  if Idx < 0 then Idx:=0;
  if Idx > AnimateBase.GetFrameCount then Idx:=AnimateBase.GetFrameCount;

  Result:=Idx;
end;

procedure TAnimationForm.UpdateFrameGridSize;
var
  Cols, Rows, FrameCount : integer;
begin
  FrameCount:=AnimateBase.GetFrameCount;
  FramePaintBox.Width:=FrameScrollBox.ClientWidth;
  if FrameCount = 0 then
  begin
    FramePaintBox.Height:=FrameScrollBox.ClientHeight;
    exit;
  end;

  Cols:=Max(1, FrameScrollBox.ClientWidth div FRAME_CELL_W);
  Rows:=(FrameCount + Cols - 1) div Cols;
  FramePaintBox.Height:=Max(FrameScrollBox.ClientHeight, Rows * FRAME_CELL_H + 2 * FRAME_PAD);
end;

procedure TAnimationForm.FrameScrollBoxResize(Sender: TObject);
begin
  UpdateFrameGridSize;
  FramePaintBox.Invalidate;
end;

{ ===== Frame PaintBox paint ===== }

procedure TAnimationForm.FramePaintBoxPaint(Sender: TObject);
var
  i, FrameCount, ImgIdx : integer;
  R : TRect;
  Cols, DropX, DropY : integer;
  S : string;
  TW : integer;
begin
  Cols:=Max(1, FramePaintBox.Width div FRAME_CELL_W);

  // dark background
//    FramePaintBox.Canvas.Brush.Color:=$404040;     $00F0F0F0
  FramePaintBox.Canvas.Brush.Color:=$00F0F0F0;

  FramePaintBox.Canvas.FillRect(FramePaintBox.ClientRect);

  FrameCount:=AnimateBase.GetFrameCount;

  for i:=0 to FrameCount-1 do
  begin
    R:=GetFrameRect(i);

    // cell background
    FramePaintBox.Canvas.Brush.Color:=$505050;
    FramePaintBox.Canvas.Pen.Color:=$686868;
    FramePaintBox.Canvas.Rectangle(R);

    // draw frame image
    ImgIdx:=AnimateBase.GetImageIndex(i);
    if ShowTransparent then
    begin
      // draw checkerboard clipped to image area only (128x128)
      FramePaintBox.Canvas.CopyRect(
        Rect(R.Left + FRAME_PAD, R.Top + FRAME_PAD,
             R.Left + FRAME_PAD + FRAME_IMG_SIZE, R.Top + FRAME_PAD + FRAME_IMG_SIZE),
        FCheckerBmp.Canvas,
        Rect(0, 0, FRAME_IMG_SIZE, FRAME_IMG_SIZE));
    end;

    if (ImgIdx >= 0) and (ImgIdx < CurrentAnimationImageList.Count-1) then
    begin
      if ShowTransparent then
        DrawSimSprite(FramePaintBox.Canvas, R.Left + FRAME_PAD, R.Top + FRAME_PAD, ImgIdx)
      else
        CurrentAnimationImageList.Draw(FramePaintBox.Canvas, R.Left + FRAME_PAD, R.Top + FRAME_PAD, ImgIdx, True);
    end
    else
      CurrentAnimationImageList.Draw(FramePaintBox.Canvas, R.Left + FRAME_PAD, R.Top + FRAME_PAD, CurrentAnimationImageList.Count-1, True);

    // draw label
    S:='Frame '+IntToStr(i+1);
    FramePaintBox.Canvas.Brush.Style:=bsClear;
    FramePaintBox.Canvas.Font.Color:=clWhite;
    FramePaintBox.Canvas.Font.Size:=8;
    TW:=FramePaintBox.Canvas.TextWidth(S);
    FramePaintBox.Canvas.TextOut(R.Left + (FRAME_CELL_W - FRAME_PAD - TW) div 2, R.Top + FRAME_IMG_SIZE + 2*FRAME_PAD - 1, S);
    FramePaintBox.Canvas.Brush.Style:=bsSolid;

    // selection highlight
    if i = FSelectedFrame then
    begin
      FramePaintBox.Canvas.Brush.Style:=bsClear;
      FramePaintBox.Canvas.Pen.Color:=clYellow;
      FramePaintBox.Canvas.Pen.Width:=3;
      FramePaintBox.Canvas.Rectangle(R.Left+1, R.Top+1, R.Right-1, R.Bottom-1);
      FramePaintBox.Canvas.Pen.Width:=1;
      FramePaintBox.Canvas.Brush.Style:=bsSolid;
    end;
  end;

  // drop indicator line - green insertion bar
  if (FDropIndex >= 0) then
  begin
    if FDropIndex < FrameCount then
    begin
      DropX:=FRAME_PAD + (FDropIndex mod Cols) * FRAME_CELL_W - 2;
      DropY:=FRAME_PAD + (FDropIndex div Cols) * FRAME_CELL_H;
    end
    else
    begin
      DropX:=FRAME_PAD + (FrameCount mod Cols) * FRAME_CELL_W - 2;
      DropY:=FRAME_PAD + (FrameCount div Cols) * FRAME_CELL_H;
    end;
    FramePaintBox.Canvas.Pen.Style:=psSolid;
    FramePaintBox.Canvas.Pen.Color:=clLime;
    FramePaintBox.Canvas.Pen.Width:=4;
    FramePaintBox.Canvas.MoveTo(DropX, DropY + 2);
    FramePaintBox.Canvas.LineTo(DropX, DropY + FRAME_CELL_H - 4);
    FramePaintBox.Canvas.Pen.Width:=1;
  end;
end;

{ ===== Frame PaintBox mouse - palette editor style ===== }

procedure TAnimationForm.FramePaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Idx : integer;
begin
  Idx:=FrameHitTest(X, Y);

  if Button = mbLeft then
  begin
    if Idx >= 0 then
    begin
      FSelectedFrame:=Idx;
      FDragOrigin:=Point(X, Y);
      FDragIndex:=Idx;
      FDragActive:=False;
      FDropIndex:=-1;
    end
    else
    begin
      FDragIndex:=-1;
      FDragActive:=False;
    end;
    FramePaintBox.Invalidate;
  end
  else if Button = mbRight then
  begin
    // right click selects the frame for popup menu operations
    if Idx >= 0 then
    begin
      FSelectedFrame:=Idx;
      FramePaintBox.Invalidate;
    end;
  end;
end;

procedure TAnimationForm.FramePaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) and (FDragIndex >= 0) then
  begin
    if not FDragActive then
    begin
      if (Abs(X - FDragOrigin.X) > DRAG_THRESHOLD) or
         (Abs(Y - FDragOrigin.Y) > DRAG_THRESHOLD) then
        FDragActive:=True;
    end;
    if FDragActive then
    begin
      FDropIndex:=FrameInsertHitTest(X, Y);
      FramePaintBox.Cursor:=crDrag;
      FramePaintBox.Invalidate;
    end;
  end;
end;

procedure TAnimationForm.FramePaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DropTarget : integer;
begin
  if (Button = mbLeft) and FDragActive and (FDropIndex >= 0) and
     (FDragIndex >= 0) then
  begin
    DropTarget:=FDropIndex;
    if DropTarget > FDragIndex then dec(DropTarget);
    if (DropTarget >= 0) and (DropTarget < AnimateBase.GetFrameCount) and
       (DropTarget <> FDragIndex) then
    begin
      MoveFrame(FDragIndex, DropTarget);
    end;
  end;

  FDragActive:=False;
  FDragIndex:=-1;
  FDropIndex:=-1;
  FramePaintBox.Cursor:=crDefault;
  FramePaintBox.Invalidate;
end;

{ ===== External drag from SpriteListView ===== }

procedure TAnimationForm.FramePaintBoxDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  index, destindex : integer;
begin
  if Source = SpriteListView then
  begin
    index:=SpriteListView.ItemIndex;
    if index >= 0 then
    begin
      destindex:=FrameHitTest(X, Y);
      if (destindex >= 0) and (AnimateBase.GetFrameCount > 0) then
        InsertFrame(destindex, index)
      else
        AddFrame(index);
    end;
  end;
  FDropIndex:=-1;
  FramePaintBox.Invalidate;
end;

procedure TAnimationForm.FramePaintBoxDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept:=(Source = SpriteListView);
  if Accept then
  begin
    FDropIndex:=FrameInsertHitTest(X, Y);
    FramePaintBox.Invalidate;
  end;
  if State = dsDragLeave then
  begin
    FDropIndex:=-1;
    FramePaintBox.Invalidate;
  end;
end;

procedure TAnimationForm.AllAnimListViewShowHint(Sender: TObject;
  HintInfo: PHintInfo);
begin
 //  (Sender As TListView).Hint:='New Hint';

end;



procedure TAnimationForm.AnimPropertiesClick(Sender: TObject);
  var
    EO : AnimExportFormatRec;
    index : integer;
  begin
    index:=AllAnimListView.ItemIndex;
    if index = -1 then exit;
    AnimateBase.GetAnimExportProps(index,EO);
    AnimationExportForm.InitComboBoxes;
    AnimationExportForm.SetExportProps(EO);
    if AnimationExportForm.ShowModal = mrOK then
    begin
       AnimationExportForm.GetExportProps(EO);
       AnimateBase.SetAnimExportProps(index,EO);
    end;
end;



procedure TAnimationForm.Button1Click(Sender: TObject);
begin
//  Panel1.Canvas.Draw(10,10,AnimThumbImageList.
//  CurrentAnimationImageList.bkColor:=RGBToColor(0,0,0);
  CurrentAnimationImageList.BlendColor:=RGBToColor(0,0,0);
  CurrentAnimationImageList.Draw(Panel1.Canvas,10,10,0,true);

end;

procedure TAnimationForm.AddFrameMenuClick(Sender: TObject);
begin
  AddEmptyFrame;
end;

procedure TAnimationForm.AllAnimListViewClick(Sender: TObject);
var
  index : integer;
begin
   index:=(Sender As TListView).ItemIndex;
   if (index > -1) and (index<>AnimateBase.GetCurrentAnimation) then SelectAnimation(index);
   UpdateStatusBar;
end;

procedure TAnimationForm.CopyFromThumbViewClick(Sender: TObject);
var
  index : integer;
begin
  index:=SpriteListView.ItemIndex;
  if index > -1 then AnimateBase.CopyToClipBoard(index,ImageThumbBase.GetUID(index));
end;

procedure TAnimationForm.CopyMenuClick(Sender: TObject);
var
  index : integer;
begin
  index:=FSelectedFrame;
  if index > -1 then
  begin
    if AnimateBase.GetImageIndex(index) > -1 then
    begin
      AnimateBase.CopyToClipBoard(AnimateBase.GetImageIndex(index),AnimateBase.GetUID(index));
    end;
  end;
end;





procedure TAnimationForm.DeleteMenuClick(Sender: TObject);
var
  index : integer;
begin
  index:=FSelectedFrame;
  if index > -1 then DeleteFrame(Index);
end;

{ ===== Movement Simulation ===== }

procedure TAnimationForm.SimStyleComboChange(Sender: TObject);
begin
  FSimTick:=0;
  FSimMovePos:=0;
  SimPaintBox.Invalidate;
end;

procedure TAnimationForm.ViewTransparentToggleClick(Sender: TObject);
begin
  ShowTransparent:=not ShowTransparent;
  ViewTransparentToggle.Checked:=ShowTransparent;
  if ShowTransparent then
  begin
    ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
    RebuildTransSpriteImageList;
    RebuildTransAnimThumbImageList;
  end
  else
  begin
    SpriteListView.LargeImages:=RMMainForm.ImageList1;
    AllAnimListView.LargeImages:=AnimThumbImageList;
  end;
  SpriteListView.Refresh;
  AllAnimListView.Refresh;
  FramePaintBox.Invalidate;
end;

procedure TAnimationForm.MovementSpeedTrackBarChange(Sender: TObject);
begin
  FMovementSpeed:=MovementSpeedTrackBar.Position;
  UpdateStatusBar;
end;

procedure TAnimationForm.RebuildTransSpriteImageList;
var
  i, x, y, aw, ah : integer;
  CheckBmp, SpriteBmp, TransBmp : TBitmap;
begin
  TransSpriteImageList.Clear;
  TransSpriteImageList.Width:=128;
  TransSpriteImageList.Height:=128;

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
    TransSpriteImageList.Add(CheckBmp, nil);

    SpriteBmp.Free;
    TransBmp.Free;
    CheckBmp.Free;
  end;

  SpriteListView.LargeImages:=TransSpriteImageList;
end;

procedure TAnimationForm.RebuildTransAnimThumbImageList;
var
  i : integer;
  CheckBmp, TransBmp : TBitmap;
begin
  TransAnimThumbImageList.Clear;
  TransAnimThumbImageList.Width:=128;
  TransAnimThumbImageList.Height:=128;

  for i:=0 to AnimThumbImageList.Count-1 do
  begin
    CheckBmp:=TBitmap.Create;
    TransBmp:=TBitmap.Create;
    try
      CheckBmp.SetSize(128, 128);
      CheckBmp.Canvas.Draw(0, 0, FCheckerBmp);

      TransBmp.Width:=128;
      TransBmp.Height:=128;
      TransBmp.TransparentColor:=clBlack;
      TransBmp.TransparentMode:=tmFixed;
      TransBmp.Transparent:=True;
      AnimThumbImageList.Draw(TransBmp.Canvas, 0, 0, i, True);

      CheckBmp.Canvas.Draw(0, 0, TransBmp);
      TransAnimThumbImageList.Add(CheckBmp, nil);
    finally
      TransBmp.Free;
      CheckBmp.Free;
    end;
  end;

  AllAnimListView.LargeImages:=TransAnimThumbImageList;
end;

procedure TAnimationForm.DrawSimSprite(ACanvas : TCanvas; X, Y, ImgIdx : integer);
var
  Bmp : TBitmap;
begin
  if (ImgIdx < 0) or (ImgIdx >= CurrentAnimationImageList.Count) then exit;

  if ShowTransparent then
  begin
    Bmp:=TBitmap.Create;

    try
      //CurrentAnimationImageList.GetBitmap(ImgIdx, Bmp);

      Bmp.width:=CurrentAnimationImageList.Width;
      bmp.height:=CurrentAnimationImageList.Height;
      Bmp.TransparentColor:=clBlack;
      Bmp.TransparentMode:=tmFixed;
      Bmp.Transparent:=true;

      CurrentAnimationImageList.Draw(bmp.Canvas,0,0,ImgIdx,True);
      ACanvas.Draw(X, Y,bmp);
    finally
      Bmp.Free;
    end;
  end
  else
  begin
    CurrentAnimationImageList.Draw(ACanvas, X, Y, ImgIdx, True);
  end;
end;

procedure TAnimationForm.DrawSimBackground(ACanvas : TCanvas; W, H : integer; HasGround : boolean);
var
  i : integer;
begin
  for i:=0 to H-1 do
  begin
    if HasGround and (i > H - 32) then
      ACanvas.Pen.Color:=RGBToColor(80, 120 + (i-(H-32)), 60)
    else
      ACanvas.Pen.Color:=RGBToColor(
        40 + (i * 30) div H,
        60 + (i * 40) div H,
        120 + (i * 60) div H);
    ACanvas.MoveTo(0, i);
    ACanvas.LineTo(W, i);
  end;

  if HasGround then
  begin
    ACanvas.Pen.Color:=RGBToColor(100, 160, 80);
    ACanvas.Pen.Width:=2;
    ACanvas.MoveTo(0, H - 28);
    ACanvas.LineTo(W, H - 28);
    ACanvas.Pen.Width:=1;
  end;
end;

procedure TAnimationForm.UpdateSimulation;
var
  SimStyle : integer;
  SpriteX, SpriteY : integer;
  FloorY : integer;
  W, H : integer;
  JumpPhase, BouncePhase : double;
  PatrolRange, PatrolPos, FallProgress : integer;
  ImgIdx : integer;
  HasGround : boolean;
begin
  if AnimateBase.GetFrameCount = 0 then exit;

  SimStyle:=SimStyleCombo.ItemIndex;
  W:=SimPaintBox.Width;
  H:=SimPaintBox.Height;
  FloorY:=H - 128 - 30;
  ImgIdx:=AnimateBase.GetImageIndex(AnimFrameCounter-1);
  HasGround:=True;

  case SimStyle of
    0: begin HasGround:=False; SpriteX:=(W-128) div 2; SpriteY:=(H-128) div 2; end;
    1: begin SpriteX:=FSimMovePos mod (W+128)-128; SpriteY:=FloorY; end;
    2: begin SpriteX:=FSimMovePos mod (W+128)-128; JumpPhase:=(FSimTick mod 50)/50.0; SpriteY:=FloorY-Round(80*Sin(JumpPhase*Pi)); end;
    3: begin HasGround:=False; SpriteX:=FSimMovePos mod (W+128)-128; SpriteY:=(H div 2)-64+Round(35*Sin(FSimTick*0.08)); end;
    4: begin SpriteX:=(W div 2)-64+(Random(7)-3); SpriteY:=FloorY+(Random(5)-2); end;
    5: begin HasGround:=False; SpriteX:=FSimMovePos mod (W+128)-128; SpriteY:=(H div 2)-64+Round(20*Sin(FSimTick*0.12)); end;
    6: begin SpriteX:=(W div 2)-64+Round(8*Sin(FSimTick*0.1)); SpriteY:=H-(FSimMovePos mod (H+128)); end;
    7: begin FallProgress:=FSimTick mod 60; SpriteX:=(W div 2)-64; SpriteY:=-128+Round(FallProgress*FallProgress*0.12); if SpriteY>H then FSimTick:=0; end;
    8: begin BouncePhase:=(FSimTick mod 30)/30.0; SpriteX:=(W div 2)-64; SpriteY:=FloorY-Round(60*Abs(Sin(BouncePhase*Pi))); end;
    9: begin PatrolRange:=W-128-20; if PatrolRange<10 then PatrolRange:=10; PatrolPos:=FSimMovePos mod (PatrolRange*2); if PatrolPos>PatrolRange then PatrolPos:=PatrolRange*2-PatrolPos; SpriteX:=10+PatrolPos; SpriteY:=FloorY; end;
  else begin SpriteX:=(W-128) div 2; SpriteY:=(H-128) div 2; HasGround:=False; end;
  end;

  // draw scene directly to SimPaintBox canvas
  DrawSimBackground(SimPaintBox.Canvas, W, H, HasGround);

  if SimStyle = 5 then
  begin
    SimPaintBox.Canvas.Brush.Style:=bsBDiagonal;
    SimPaintBox.Canvas.Brush.Color:=RGBToColor(40, 80, 180);
    SimPaintBox.Canvas.Pen.Style:=psClear;
    SimPaintBox.Canvas.Rectangle(0, 0, W, H);
    SimPaintBox.Canvas.Brush.Style:=bsSolid;
    SimPaintBox.Canvas.Pen.Style:=psSolid;
  end;

  DrawSimSprite(SimPaintBox.Canvas, SpriteX, SpriteY, ImgIdx);

  //style info now shown in the status bar - removed the TextOut here
  //which was causing flicker during animation playback
end;

procedure TAnimationForm.SimPaintBoxPaint(Sender: TObject);
var
  W, H, ImgIdx : integer;
begin
  W:=SimPaintBox.Width;
  H:=SimPaintBox.Height;

  SimPaintBox.Canvas.Brush.Color:=RGBToColor(50, 70, 130);
  SimPaintBox.Canvas.FillRect(SimPaintBox.ClientRect);

  if (not Timer1.Enabled) and (AnimateBase.GetFrameCount > 0) then
  begin
    if (AnimFrameCounter >= 1) and (AnimFrameCounter <= AnimateBase.GetFrameCount) then
      ImgIdx:=AnimateBase.GetImageIndex(AnimFrameCounter-1)
    else if FSelectedFrame >= 0 then
      ImgIdx:=AnimateBase.GetImageIndex(FSelectedFrame)
    else
      ImgIdx:=AnimateBase.GetImageIndex(0);

    DrawSimBackground(SimPaintBox.Canvas, W, H, SimStyleCombo.ItemIndex > 0);
    DrawSimSprite(SimPaintBox.Canvas, (W-128) div 2, (H-128) div 2, ImgIdx);
  end;
end;


end.

