unit spritesheetexport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, ComCtrls, Clipbrd, rmcodegen, rwxgf, rmclipboard, rmthumb, rmconfig,
  rwpng, LazFileUtils, SpinEx, bmfontgen;

type

  { TSpriteSheetExportForm }

  TSpriteSheetExportForm = class(TForm)
    Apply: TButton;
    SaveBackgroundAsTransparent: TCheckBox;
    DescExportToClipboard: TButton;
    ExportToClipBoard: TButton;
    ExportToFile: TButton;
    CSWidth: TSpinEdit;
    CSHeight: TSpinEdit;
    DescExportToFile: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SpinEditCustomSpriteWidth: TSpinEditEx;
    SpinEditCustomSpriteHeight: TSpinEditEx;
    SpriteSheet: TComboBox;
    SpriteSize: TComboBox;
    Direction: TComboBox;
    SpriteSheetPaintBox: TPaintBox;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    ItemsPerRow: TSpinEdit;
    Splitter1: TSplitter;
    DescriptionFile: TComboBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    ZoomTrackBar: TTrackBar;
    procedure ApplyClick(Sender: TObject);
    procedure DescExportToFileClick(Sender: TObject);
    procedure DirectionChange(Sender: TObject);
    procedure ExportToClipBoardClick(Sender: TObject);
    procedure ExportToFileClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpriteSheetChange(Sender: TObject);
    procedure SpriteSheetPaintBoxPaint(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);
  private

  public
   //  Picture1 : TPicture;
     SpriteSheetBitMap : TBitMap;
     SpriteWidth : integer;
     SpriteHeight: integer;
     SpriteSheetWidth : integer;
     SpriteSheetHeight: integer;
     ZoomSize    : integer;

     procedure UpdateSpriteValues;
     procedure UpdateSpriteSheetValues;
     procedure UpdateSpriteSheet;
     procedure UpdatePaintBoxSize;
     procedure UpdateSpriteSheetSize;

     procedure ImportSprites;
     procedure ExportToBMFontFiles(SaveToClipBoard : boolean);

     function CharToBmChar(x,y,w,h,c : integer) : TBmChar;
     procedure UpdateBmCommon(var common : TBmCommon);
     procedure UpdateBmInfo(var info : TBmInfo);

     procedure FixPicture(Picture1 : TPicture);

  end;

var
  SpriteSheetExportForm: TSpriteSheetExportForm;

implementation


{$R *.lfm}

{ TSpriteSheetExportForm }


procedure calcHoriz(snum,CSWidth,CSHeight,ipr : integer; var x,y,x2,y2 : integer);
var
  row,col : integer;
begin
  row:=(snum+ipr-1) div ipr;
  col:=snum-((row-1)*ipr);

  y:=(row-1)*CSHeight;
  x:=(col-1)*CSWidth;
  x2:=x+CSWidth-1;
  y2:=y+CSHeight-1;
end;

procedure calcVirt(snum,CSWidth,CSHeight,ipr : integer; var x,y,x2,y2 : integer);
var
  row,col : integer;
begin
  col:=(snum+ipr-1) div ipr;
  row:=snum-((col-1)*ipr);

  y:=(row-1)*CSHeight;
  x:=(col-1)*CSWidth;
  x2:=x+CSWidth-1;
  y2:=y+CSHeight-1;
end;

procedure TSpriteSheetExportForm.FormCreate(Sender: TObject);
begin
   SpriteWidth:=32;
   SpriteHeight:=32;
   SpriteSheetWidth:=320;
   SpriteSheetHeight:=200;
   UpdateSpriteValues;
   UpdateSpriteSheetValues;

   ZoomSize:=ZoomTrackBar.Position;
   SpriteSheetBitMap:=TBitMap.Create;

   SpriteSheetBitMap.SetSize(SpriteSheetWidth,SpriteSheetHeight);
   SpriteSheetBitMap.Canvas.FillRect(0,0,SpriteSheetWidth,SpriteSheetHeight);

   UpdateSpriteSheet;

   SpriteSheetPaintBox.Width:=SpriteSheetWidth*ZoomSize;
   SpriteSheetPaintBox.Height:=SpriteSheetHeight*ZoomSize;
   SpriteSheetPaintBox.Invalidate;
end;

procedure TSpriteSheetExportForm.FormDestroy(Sender: TObject);
begin
   SpriteSheetBitMap.Free;
end;

procedure TSpriteSheetExportForm.SpriteSheetChange(Sender: TObject);
begin
  UpdateSpriteSheetValues;
  UpdateSpriteValues;
  if Direction.ItemIndex = 0  then
  begin
     ItemsPerRow.Value:=SpriteSheetWidth div SpriteWidth;
  end
  else
  begin
    ItemsPerRow.Value:=SpriteSheetHeight div SpriteHeight;
  end;
end;

procedure TSpriteSheetExportForm.ApplyClick(Sender: TObject);
begin
 // SpriteSheetBitMap.Clear;
   UpdateSpriteValues;
   UpdateSpriteSheetValues;
   UpdateSpriteSheetSize;
   SpriteSheetBitMap.Canvas.FillRect(0,0,SpriteSheetWidth,SpriteSheetHeight);
   UpdatePaintBoxSize;
   ImportSprites;
   SpriteSheetPaintBox.Invalidate;
end;


function menuToLan(menuid : integer) : integer;
begin
  case menuid of 0:menutoLan:=QB64Lan;
                 1:menutoLan:=QBLan;
                 2:menutoLan:=FPLan;
                 3:menutoLan:=TPLan;
                 4:menutoLan:=TMTLan;
                 5:menutoLan:=APLan;
                 6:menutoLan:=QPLan;
                 7:menutoLan:=gccLan;
                 8:menutoLan:=OWLan;
                 9:menutoLan:=TCLan;
                10:menutoLan:=QCLan;
                11:menutoLan:=ACLan;
                12:menutoLan:=JSonLan;


  end;
end;

function LanToFileFilter(Lan : integer) : string;
begin
  case Lan of QB64Lan,QBLan:LanToFileFilter:='BAS|*.bas|All Files|*.*';
              FPLan,TPLan,TMTLan,APLan:LanToFileFilter:='PAS|*.pas|All Files|*.*';
              QCLan,gccLan,OWLan,TCLan,ACLan:LanToFileFilter:='C|*.c|All Files|*.*';
              JSonLan:LanToFileFilter:='JSON|*.json|All Files|*.*';
  end;
end;

procedure WriteHeader(var F : Text;lan : integer);
var
   headstr : string;
begin
  headstr:='Sprite Sheet Description Created By Raster Master';
  case Lan of QB64Lan,QBLan:Writeln(F,#39,' ',headstr);
              FPLan,TPLan,TMTLan,APLan:Writeln(F,'(* ',headstr,' *)');
              QCLan,gccLan,OWLan,TCLan,ACLan:Writeln(F,'/* ',headstr,' */');
  end;
end;

procedure WriteDesc(var F : Text;lan : integer;DescName : string; swidth,sheight,x,y,x2,y2 : integer;csprite,snum : integer);
begin
  case Lan of QBLan,QB64Lan:begin
                        Writeln(F,DescName,'Desc:');
                        Writeln(F,#39,' Width=',SWidth,' Height=',SHeight);
                        Writeln(F,'DATA ',x,',',y,',',x2,',',y2);
                      end;
          APLan,QPLan,TMTLan,FPLan,TPLan:begin
                         Writeln(F,'(* ',DescName,' Width=',SWidth,' Height=',SHeight,' *)');
                         Writeln(F,DescName,'Desc: Array[1..4] of Integer=(',x,',',y,',',x2,',',y2,');');
                      end;
           gccLan,OWLan,TCLan,QCLan,ACLan:begin
                         Writeln(F,'/* ',DescName,' Width=',SWidth,' Height=',SHeight,' */');
                         Writeln(F,'int ',DescName,'[] = {',x,',',y,',',x2,',',y2,'};');
                                 end;
               JsonLan:begin
                         if csprite = 1 then Writeln(F,'[');
                         Writeln(F,' {');
                         Writeln(F,'  DescName: "',DescName,'",');
                         Writeln(F,'  Width:',SWidth,',');
                         Writeln(F,'  Height:',SHeight,',');
                         Writeln(F,'  x:',x,',');
                         Writeln(F,'  y:',y,',');
                         Writeln(F,'  x2:',x2,',');
                         Writeln(F,'  y2:',y2);
                         if csprite < snum then Writeln(F,'  },') else Writeln(F,'  }');
                         if csprite = snum then Writeln(F,']');
                       end;

  end;
end;
 (*
var
 c         : integer;
 ipr       : integer;
 xpos,ypos : integer;
 bmc       : TBmChar;
 info      : TBmInfo;
 common    : TBmCommon;
 Page      : TBmPage;
 FontGen   : TBmFontGen;
 nameonly  : string;
 picture1  : TPicture;
begin
  FontGen:=TBmFontGen.Create;
  UpdateBmInfo(info);
  FontGen.SetInfo(Info);
  UpdateBmCommon(common);
  FontGen.SetCommon(Common);

  ipr:=0;
  xpos:=0;
  ypos:=0;

  for c:=SpinStartChar.Value to SpinEndChar.Value do
  begin
    bmc:=CharToBmChar(xpos,ypos,c);
    FontGen.AddCharacter(bmc);
    inc(ipr);
    if ipr = ItemsPerRow.Value then
    begin
      ipr:=0;
      if Direction.ItemIndex = 0 then
      begin
        xpos:=0;
        inc(ypos,CharHeight);
      end
      else
      begin
        ypos:=0;
        inc(xpos,CharWidth);
      end;
    end
    else
    begin
      if Direction.ItemIndex = 0 then inc(xpos,CharWidth) else inc(ypos,CharHeight);
    end;
  end;

  SaveDialog1.Filter := 'FNT|*.fnt|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    NameOnly := ChangeFileExt(ExtractFileName(SaveDialog1.FileName), '');
    page.filename:=NameOnly+'.png';
    page.id:=0;
    FontGen.SetPage(page);
    FontGen.SaveFont(SaveDialog1.FileName);  //create fnt file
    Picture1:=TPicture.Create;
    FixPicture(Picture1);
    Picture1.SaveToFile(ChangeFileExt(SaveDialog1.FileName,'.png'),'.PNG');  //create atlas/png file
    Picture1.Free;
  end;
  FontGen.Free;



end;
*)

procedure TSpriteSheetExportForm.UpdateBmInfo(var info : TBmInfo);
begin
  Info.face:='';
  info.size:=SpriteHeight;
  Info.bold:=0;
  Info.italic:=0;
  Info.charset:='';
  Info.unicode:=1;
  info.stretchH:=100;
  info.smooth:=0;
  info.aa:=1;
  info.padding.down:=0;
  info.padding.up:=0;
  info.padding.left:=0;
  info.padding.right:=0;
  info.spacing.horizontal:=0;
  info.spacing.vertical:=0;
  info.outline:=0;
end;

procedure TSpriteSheetExportForm.UpdateBmCommon(var common : TBmCommon);
begin
  common.LineHeight:=SpriteHeight;
  common.Base:=SpriteHeight; //baseLine
  common.scaleW:=SpriteSheetWidth;
  common.scaleH:=SpriteSheetHeight;
  common.pages:=1;      //we only support one page
  common.ppacked:=0;    // no packing
  common.alphaChnl:=0;
  common.redChnl:=4;
  common.greenChnl:=4;
  common.blueChnl:=4;
end;

function TSpriteSheetExportForm.CharToBmChar(x,y,w,h,c : integer) : TBmChar;
var
 bmc : TBmChar;
begin
 bmc.chnl:=15;
 bmc.id:=c;
 bmc.page:=0;
 bmc.x:=x;
 bmc.y:=y;
 bmc.xoffset:=0;
 bmc.yoffset:=0;

 bmc.height:=h;
 bmc.width:=w;
 bmc.xadvance:=w+1;
 result:=bmc;
end;

procedure TSpriteSheetExportForm.FixPicture(Picture1 : TPicture);
var
 i,j        : integer;
 pixeldata  : PByte;
 pixelpos   : longint;
 cl         : TColor;
 PngRGBA    : PngRGBASettingsRec;
begin
  RMConfigBase.GetProps(PngRGBA);
  Picture1.Bitmap.Width:=SpriteSheetWidth;
  Picture1.Bitmap.height:=SpriteSheetHeight;
  Picture1.BitMap.PixelFormat:=pf32bit;         //change format to 32 bit/RGBA

  pixeldata:=picture1.Bitmap.RawImage.Data;
  pixelpos:=0;
  for j:=0 to SpriteSheetHeight-1 do
  begin
    for i:=0 to SpriteSheetWidth-1 do
    begin
      cl:=SpriteSheetBitMap.Canvas.Pixels[i,j];
      pixeldata[pixelpos]:=Blue(cl);     // Blue
      pixeldata[pixelpos+1]:=Green(cl);   // Green
      pixeldata[pixelpos+2]:=Red(cl);   // Red
      pixeldata[pixelpos+3]:=255;    // Alpha     255 = solid

      if (PngRGBA.UseFuschia) and (Red(cl) = 255) and (Green(cl)=0) and (Blue(cl)=255) then   //use fuschia
      begin
        pixeldata[pixelpos+3]:=0;  // Alpha     0 = transparent
      end;

      if (PngRGBA.UseCustom) and (Red(cl) = PngRGBA.R) and (Blue(cl)=PngRGBA.B) and (Green(cl)=PngRGBA.G) then   //use custom
      begin
        pixeldata[pixelpos+3]:=PngRGBA.A;  // use Custom Alpha level for transperancy
      end;

      if SaveBackgroundAsTransparent.Checked and ((Red(cl)= 0) and (Green(cl)=0) and (Blue(cl)=0)) then   //if black then make transparent
      begin
        pixeldata[pixelpos+3]:=0;
      end;

     inc(pixelpos,4);
    end;
  end;
end;

procedure TSpriteSheetExportForm.ExportToBMFontFiles(SaveToClipBoard : boolean);
var
  FontGen   : TBmFontGen;
  bmc       : TBmChar;
  info      : TBmInfo;
  common    : TBmCommon;
  Page      : TBmPage;
  c         : integer;
  ipr       : integer;
  xpos,ypos : integer;
  snum : integer;
  SWidth,SHeight : integer;
  NameOnly : string;
  Picture1 : TPicture;
begin

 FontGen:=TBmFontGen.Create;
 UpdateBmInfo(info);
 FontGen.SetInfo(Info);
 UpdateBmCommon(common);
 FontGen.SetCommon(Common);

 ipr:=0;
 xpos:=0;
 ypos:=0;
 snum:=ImageThumbBase.GetCount;
 for c:=0 to snum-1 do
 begin
   // DescName:=ImageThumbBase.GetExportName(c);
    SWidth:=ImageThumbBase.GetWidth(c);
    SHeight:=ImageThumbBase.GetHeight(c);
    bmc:=CharToBmChar(xpos,ypos,SWidth,SHeight,c);
    FontGen.AddCharacter(bmc);
    inc(ipr);
    if ipr = ItemsPerRow.Value then
    begin
      ipr:=0;
      if Direction.ItemIndex = 0 then
      begin
        xpos:=0;
        inc(ypos,SpriteHeight);
      end
      else
      begin
        ypos:=0;
        inc(xpos,SpriteWidth);
      end;
    end
    else
    begin
      if Direction.ItemIndex = 0 then inc(xpos,SpriteWidth) else inc(ypos,SpriteHeight);
    end;
  end;

  SaveDialog1.Filter := 'FNT|*.fnt|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    NameOnly := ChangeFileExt(ExtractFileName(SaveDialog1.FileName), '');
    page.filename:=NameOnly+'.png';
    page.id:=0;
    FontGen.SetPage(page);
    FontGen.SaveFont(SaveDialog1.FileName);  //create fnt file
    Picture1:=TPicture.Create;
    FixPicture(Picture1);
    Picture1.SaveToFile(ChangeFileExt(SaveDialog1.FileName,'.png'),'.PNG');  //create atlas/png file
    Picture1.Free;
  end;
  FontGen.Free;
end;

procedure TSpriteSheetExportForm.DescExportToFileClick(Sender: TObject);
  var
    DescName : String;
    F : Text;
    c : integer;
    Lan,snum : integer;
    SWidth,SHeight,x,y,x2,y2 : integer;
    FileName : string;
  begin
   if DescriptionFile.ItemIndex = 13 then      //BMFont
   begin
      ExportToBMFontFiles(FALSE);
      exit;
   end;
   Lan:=menutoLan(DescriptionFile.ItemIndex);
   if (Sender As TButton).Name = 'DescExportToFile' then
   begin
     SaveDialog2.Filter := LanToFileFilter(Lan);
     if NOT SaveDialog2.Execute then exit;
     FileName:=SaveDialog2.FileName;
   end
   else
   begin
     FileName:=GetTemporaryPathAndFileName;
   end;
   {$I-}

    System.Assign(F,FileName);
    Rewrite(F);

    WriteHeader(F,Lan);
    snum:=ImageThumbBase.GetCount;
    for c:=0 to snum-1 do
    begin
      DescName:=ImageThumbBase.GetExportName(c);
      SWidth:=ImageThumbBase.GetWidth(c);
      SHeight:=ImageThumbBase.GetHeight(c);
      if Direction.ItemIndex = 0 then
        CalcHoriz(c+1,SWidth,SHeight,ItemsPerRow.Value,x,y,x2,y2)
      else CalcVirt(c+1,SWidth,SHeight,ItemsPerRow.Value,x,y,x2,y2);

      WriteDesc(F,Lan,DescName,swidth,sheight,x,y,x2,y2,c+1,snum);
    end;

    {$I+}
    if IORESULT<>0 then exit;

    {$I-}
    System.close(F);
  {$I+}
  if (Sender As TButton).Name = 'DescExportToClipboard' then
  begin
    ReadFileAndCopyToClipboard(FileName);
    EraseFile(FileName);
  end;
end;


procedure TSpriteSheetExportForm.DirectionChange(Sender: TObject);
begin
  if Direction.ItemIndex = 0  then
  begin
     ItemsPerRow.Value:=SpriteSheetWidth div SpriteWidth;
  end
  else
  begin
    ItemsPerRow.Value:=SpriteSheetHeight div SpriteHeight;
  end;
end;

procedure TSpriteSheetExportForm.ExportToClipBoardClick(Sender: TObject);
begin
  Clipboard.Assign(SpriteSheetBitMap);
end;

procedure TSpriteSheetExportForm.ExportToFileClick(Sender: TObject);
var
 i,j   : integer;
 pixeldata  : PByte;
 pixelpos   : longint;
 cl : TColor;
 PngRGBA : PngRGBASettingsRec;
 Picture1 : TPicture;
 ext : string;
begin
  RMConfigBase.GetProps(PngRGBA);
  Picture1:=TPicture.Create;
  Picture1.Bitmap.Width:=SpriteSheetWidth;
  Picture1.Bitmap.height:=SpriteSheetHeight;
  Picture1.BitMap.PixelFormat:=pf32bit;         //change format to 32 bit/RGBA

  pixeldata:=picture1.Bitmap.RawImage.Data;
  pixelpos:=0;
  for j:=0 to SpriteSheetHeight-1 do
  begin
    for i:=0 to SpriteSheetWidth-1 do
    begin
      cl:=SpriteSheetBitMap.Canvas.Pixels[i,j];
      pixeldata[pixelpos]:=Blue(cl);     // Blue
      pixeldata[pixelpos+1]:=Green(cl);   // Green
      pixeldata[pixelpos+2]:=Red(cl);   // Red
      pixeldata[pixelpos+3]:=255;    // Alpha     255 = solid

  //    if (PngRGBA.UseColorIndex) and (PngRGBA.ColorIndex=ci) then
  //    begin
  //      pixeldata[pixelpos+3]:=0;  // Alpha     0 = transparent
  //    end;

      if (PngRGBA.UseFuschia) and (Red(cl) = 255) and (Green(cl)=0) and (Blue(cl)=255) then   //use fuschia
      begin
        pixeldata[pixelpos+3]:=0;  // Alpha     0 = transparent
      end;

      if (PngRGBA.UseCustom) and (Red(cl) = PngRGBA.R) and (Blue(cl)=PngRGBA.B) and (Green(cl)=PngRGBA.G) then   //use fuschia
      begin
        pixeldata[pixelpos+3]:=PngRGBA.A;  // use Custom Alpha level for transperancy
      end;
      inc(pixelpos,4);
    end;
  end;

  SaveDialog1.Filter := 'PNG|*.png|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    ext:=UpperCase(ExtractFileExt(SaveDialog1.Filename));
    if ext = '.PNG' then Picture1.SaveToFile(SaveDialog1.FileName,'.PNG');
  end;
  Picture1.Free;
end;

procedure TSpriteSheetExportForm.FormActivate(Sender: TObject);
begin
  UpdateSpriteSheet;
end;

procedure TSpriteSheetExportForm.SpriteSheetPaintBoxPaint(Sender: TObject);
begin
  UpdateSpriteSheet;
end;

procedure TSpriteSheetExportForm.UpdateSpriteSheet;
begin
  SpriteSheetPaintBox.Canvas.CopyRect(Rect(0,0,SpriteSheetWidth*ZoomSize,SpriteSheetHeight*ZoomSize),SpriteSheetBitMap.Canvas,Rect(0,0,SpriteSheetWidth,SpriteSheetHeight));
end;

procedure TSpriteSheetExportForm.UpdatePaintBoxSize;
begin
  SpriteSheetPaintBox.Width:=SpriteSheetWidth*ZoomSize;
  SpriteSheetPaintBox.Height:=SpriteSheetHeight*ZoomSize;
end;

procedure TSpriteSheetExportForm.UpdateSpriteSheetSize;
begin
  SpriteSheetBitMap.SetSize(SpriteSheetWidth,SpriteSheetHeight);
end;

procedure TSpriteSheetExportForm.ZoomTrackBarChange(Sender: TObject);
begin
  ZoomSize:=ZoomTrackBar.Position;
  SpriteSheetPaintBox.Width:=SpriteSheetWidth*ZoomSize;
  SpriteSheetPaintBox.Height:=SpriteSheetHeight*ZoomSize;
  SpriteSheetPaintBox.Invalidate;
end;

procedure TSpriteSheetExportForm.UpdateSpriteValues;
begin
  Case SpriteSize.ItemIndex of 0:begin
                        SpriteWidth:=8;
                        SpriteHeight:=8;
                       end;
                     1:begin
                        SpriteWidth:=16;
                        SpriteHeight:=16;
                       end;
                     2:begin
                        SpriteWidth:=32;
                        SpriteHeight:=32;
                       end;
                     3:begin
                        SpriteWidth:=64;
                        SpriteHeight:=64;
                       end;
                     4:begin
                        SpriteWidth:=128;
                        SpriteHeight:=128;
                       end;
                     5:begin
                        SpriteWidth:=256;
                        SpriteHeight:=256;
                       end;
                     6:begin
                        SpriteWidth:=SpinEditCustomSpriteWidth.Value;
                        SpriteHeight:=SpinEditCustomSpriteHeight.Value;
                     end;
  end;

end;

procedure TSpriteSheetExportForm.UpdateSpriteSheetValues;
begin
  Case SpriteSheet.ItemIndex of 0:begin
                        SpriteSheetWidth:=320;
                        SpriteSheetHeight:=200;
                       end;
                     1:begin
                       SpriteSheetWidth:=640;
                        SpriteSheetHeight:=200;
                       end;
                     2:begin
                        SpriteSheetWidth:=640;
                        SpriteSheetHeight:=350;
                       end;
                     3:begin
                         SpriteSheetWidth:=640;
                        SpriteSheetHeight:=480;
                       end;
                     4:begin
                          SpriteSheetWidth:=800;
                        SpriteSheetHeight:=600;
                       end;
                     5:begin
                        SpriteSheetWidth:=1024;
                        SpriteSheetHeight:=768;
                       end;
                     6:begin
                        SpriteSheetWidth:=CSWidth.Value;
                        SpriteSheetHeight:=CSHeight.Value;
                       end;

  end;

end;

procedure TSpriteSheetExportForm.ImportSprites;
var
c,i,j : integer;
cc: TColor;
ipr : integer;
xstart,ystart : integer;
begin
  ipr:=0;
  xstart:=0;
  ystart:=0;
  ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
  for c:=0 to ImageThumbBase.GetCount-1 do
  begin
    for i:=0 to ImageThumbBase.GetWidth(c)-1 do
    begin
      for j:=0 to ImageThumbBase.GetHeight(c)-1 do
      begin
        cc:=ImageThumbBase.GetPixelTColor(c,i,j);
        SpriteSheetBitMap.Canvas.Pixels[i+xstart,j+ystart]:=cc;
      end
    end;
    inc(ipr);
    if ipr = ItemsPerRow.Value then
    begin
      ipr:=0;
      if Direction.ItemIndex = 0 then
      begin
        xstart:=0;
        inc(ystart,SpriteHeight);
      end
      else
      begin
        ystart:=0;
        inc(xstart,SpriteWidth);
      end;
    end
    else
    begin
      if Direction.ItemIndex = 0 then inc(xstart,Spritewidth) else inc(ystart,SpriteHeight);
    end;
  end;
end;

end.

