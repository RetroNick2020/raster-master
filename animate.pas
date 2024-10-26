unit animate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ExtCtrls,
  ComCtrls, Menus, StdCtrls, Arrow,AnimBase,animationexport,rmthumb,rwpng,
  fileprops,rwspriteanim,rmcodegen,rmconfig,rmclipboard;

type

  { TAnimationForm }

  TAnimationForm = class(TForm)
    CurrentAnimationImageList: TImageList;
    AnimThumbImageList: TImageList;
    CopyMenu: TMenuItem;
    AddFrameMenu: TMenuItem;
    DeleteMenu: TMenuItem;
    CopyFromThumbView: TMenuItem;
    AnimDeleteMenu: TMenuItem;
    Image1: TImage;
    Image2: TImage;
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
    SpriteListView: TListView;
    CurrentAnimListView: TListView;
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

    procedure CurrentAnimListViewDragDrop(Sender, Source: TObject; X, Y: Integer
      );
    procedure CurrentAnimListViewDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
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

  public
    AnimFrameCounter : integer;
    FPSDelay         : integer;

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

    function ExportTextFileToClipboard(Sender: TObject) : boolean;
  end;

var
  AnimationForm: TAnimationForm;

implementation
       uses rmmain;
{$R *.lfm}

{ TAnimationForm }

procedure TAnimationForm.FormCreate(Sender: TObject);
begin
  FPSDelay:=1000 Div FPSTrackBar.Position;
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
 else if CurrentAnimListView.ItemIndex > -1 then
 begin
   index:=CurrentAnimListView.ItemIndex;
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
  index:=CurrentAnimListView.ItemIndex;
  if index > -1 then
  begin
    if AnimateBase.GetClipBoardStatus then
    begin
     AnimateBase.PasteFromClipBoard(ImageIndex,uid);
     AnimateBase.ChangeFrame(index,ImageIndex,uid);
     //add code to check if image still exists - it may have been deleted since it was copied to clipboard
     CurrentAnimListView.Items[index].ImageIndex:=ImageIndex;
    end;
  end;
end;

procedure TAnimationForm.MenuDeleteAllClick(Sender: TObject);
begin
  DeleteAll;
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

  CurrentAnimListView.Repaint;
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

  CurrentAnimListView.Repaint;
  AllAnimListView.Repaint;
end;


procedure TAnimationForm.DeleteAnimation(AnimationIndex : integer);
begin
  AnimateBase.DeleteAnimation(AnimationIndex);

  LoadCurrentAnimList;
  LoadAnimThumbList;

  CurrentAnimListView.Repaint;
  AllAnimListView.Repaint;
end;

procedure TAnimationForm.MenuItem11Click(Sender: TObject);
var
  index : integer;
begin
  index:=CurrentAnimListView.ItemIndex;
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
  ExportAnimation(SaveDialog1.FileName,PascalLan);
end;

end;

function TAnimationForm.ExportTextFileToClipboard(Sender: TObject) : boolean;
var
 filename : string;
begin
 if rmconfigbase.GetExportTextFileToClipStatus = false then
 begin
   result:=false;
   exit;
 end;

 filename:=GetTemporaryPathAndFileName;
 Case (Sender As TMenuItem).Name of  'ExportBasicAnimData':ExportAnimation(FileName,BasicLan);
                                     'ExportBasicLNAnimData':ExportAnimation(FileName,BasicLNLan);
                                     'ExportCAnimArray','ExportEmscriptenAnimArray','ExportgccAnimArray': ExportAnimation(FileName,CLan);
                                     'ExportPascalAnimArray':ExportAnimation(FileName,PascalLan);

 else
   result:=false;  //did not find a supported format return false
   exit;
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
end;



procedure TAnimationForm.DeleteAll;
begin
// AnimateBase.DeleteAll;
 AnimateBase.InitAnimation;

 LoadCurrentAnimList;
 LoadAnimThumbList;

 CurrentAnimListView.Repaint;
 AllAnimListView.Repaint;
end;

procedure TAnimationForm.SelectAnimation(AnimationIndex : integer);
begin
  AnimateBase.SetCurrentAnimation(AnimationIndex);
  LoadCurrentAnimList;
  LoadAnimThumbList;

  CurrentAnimListView.Repaint;
  AllAnimListView.Repaint;
end;


procedure TAnimationForm.NewAnimationMenuClick(Sender: TObject);
begin
 AddAnimation;
end;



procedure TAnimationForm.PasteMenuClick(Sender: TObject);
var
  index,ImageIndex : integer;
  uid : TGUID;
begin
  index:=CurrentAnimListView.ItemIndex;
  if index > -1 then
  begin
    if AnimateBase.GetClipBoardStatus then
    begin
      AnimateBase.PasteFromClipBoard(ImageIndex,uid);
      AnimateBase.ChangeFrame(index,ImageIndex,uid);
      //add code to check if image still exists - it may have been deleted since it was copied to clipboard
      CurrentAnimListView.Items[index].ImageIndex:=ImageIndex;
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
  MEBitMap  : TBitMap;  //missing extra bitmap
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
   CurrentAnimListView.Clear;
   for i:=0 to ImageCount-1 do
   begin
     CurrentAnimListView.AddItem('Frame '+IntToStr(i+1), self);
     if IsEqualGUID(AnimateBase.GetUID(i),ImageThumbBase.GetUID(i)) then          //verify that image still exist
     begin
         CurrentAnimListView.Items[i].ImageIndex:=AnimateBase.GetImageIndex(i);
     end
     else
     begin
       FoundImage:=ImageThumbBase.FindUID(AnimateBase.GetUID(i));
       if FoundImage<>-1 then
       begin
          AnimateBase.ChangeFrame(i,FoundImage,AnimateBase.GetUID(i));
          CurrentAnimListView.Items[i].ImageIndex:=AnimateBase.GetImageIndex(i);
       end
       else
       begin
         //CreateGUID(uid);
         //AnimateBase.ChangeFrame(i,-1,uid);
         CurrentAnimListView.Items[i].ImageIndex:=CurrentAnimationImageList.Count-1;
       end;
     end;
   end;
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
end;



procedure TAnimationForm.Timer1StartTimer(Sender: TObject);
begin
  AnimFrameCounter:=0;

end;

procedure TAnimationForm.Timer1Timer(Sender: TObject);
var
   ImageIndex : integer;
begin
  inc(AnimFrameCounter);
  if AnimFrameCounter > AnimateBase.GetFrameCount then
  begin
      AnimFrameCounter:=1;
  end;

  if  AnimateBase.GetFrameCount > 0 then
  begin
    ImageIndex:=AnimateBase.GetImageIndex(AnimFrameCounter-1);
    CurrentAnimationImageList.Draw(Panel1.Canvas,10,10,ImageIndex,true);
  end;
end;

procedure TAnimationForm.FPSTrackBarChange(Sender: TObject);
begin
  FPSDelay:=1000 div FPSTrackBar.Position;
  Timer1.Interval:=FPSDelay;
end;

procedure TAnimationForm.FormActivate(Sender: TObject);
begin
   LoadImageThumbList;
   LoadCurrentAnimList;
   LoadAnimThumbList;
   SpriteListView.Repaint;
   CurrentAnimListView.Repaint;
   AllAnimListView.Repaint;
end;

procedure TAnimationForm.AddFrame(ImageIndex : integer);
var
  uid  : TGUID;
begin
   uid:=ImageThumbBase.GetUID(ImageIndex);
   AnimateBase.AddFrame(ImageIndex,uid);
   LoadCurrentAnimList;
   CurrentAnimListView.Repaint;
   LoadAnimThumbList;
   AllAnimListView.Repaint;
end;


procedure TAnimationForm.AddEmptyFrame;
var
  uid  : TGUID;
begin
   AnimateBase.AddFrame(-1,uid);
   LoadCurrentAnimList;
   CurrentAnimListView.Repaint;
   LoadAnimThumbList;
   AllAnimListView.Repaint;
end;

procedure TAnimationForm.DeleteFrame(ImageIndex : integer);
begin
   AnimateBase.DeleteFrame(ImageIndex);
   LoadCurrentAnimList;
   CurrentAnimListView.Repaint;
   LoadAnimThumbList;
   AllAnimListView.Repaint;
end;


procedure TAnimationForm.InsertFrame(FrameIndex,ImageIndex : integer);
var
  uid  : TGUID;
begin
   uid:=ImageThumbBase.GetUID(ImageIndex);
   AnimateBase.InsertFrame(FrameIndex, ImageIndex,uid);
   LoadCurrentAnimList;
   CurrentAnimListView.Repaint;
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
     LoadCurrentAnimList;
     CurrentAnimListView.Repaint;

     if ToFrameIndex = 0 then
     begin
       LoadAnimThumbList;
       AllAnimListView.Repaint;
     end;
   end;
end;

procedure TAnimationForm.CurrentAnimListViewDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  index,destindex : integer;
  item  : TListItem;
begin
   destindex:=-1;
   index:=(Source as TListView).ItemIndex;
   //  showMessage(IntToStr(index));
   item:=CurrentAnimListView.GetItemAt(x,y);

   if assigned(item) then
   begin
     destindex:=item.Index;
   end;

   if Source = Sender then     //Move Frame
   begin
       if destindex > -1 then
       begin
         MoveFrame(index,destindex);
         //ShowMessage('Move: '+IntToStr(destindex)+' '+IntToStr(index));
       end;
   end
   else
   begin
     if (destindex <> -1) and  (AnimateBase.GetFrameCount > 0) then
     begin
         //ShowMessage('Dest:'+IntToStr(destindex)+' Image Index:'+IntTostr(index));
         InsertFrame(destindex,index);
     end
     else  AddFrame(index);
   end;
end;

procedure TAnimationForm.CurrentAnimListViewDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin

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
  index:=CurrentAnimListView.ItemIndex;
  if index > -1 then
  begin
    if AnimateBase.GetImageIndex(index) > -1 then     //prevent copying empty frame - just use add frame
    begin
      AnimateBase.CopyToClipBoard(AnimateBase.GetImageIndex(index),AnimateBase.GetUID(index));
    end;
  end;
//  info.Caption:='Copy: '+IntToStr(index)+' '+IntToStr(AnimateBase.GetImageIndex(index));
end;





procedure TAnimationForm.DeleteMenuClick(Sender: TObject);
var
  index : integer;
begin
  index:=CurrentAnimListView.ItemIndex;
//  info.Caption:='Delete: '+IntToStr(index)+' '+IntToStr(AnimateBase.GetImageIndex(index));
  if index > -1 then DeleteFrame(Index);
end;



end.

