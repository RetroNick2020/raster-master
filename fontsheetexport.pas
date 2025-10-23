unit fontsheetexport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, ComCtrls, Clipbrd, rwxgf, rmclipboard, rmthumb, rmconfig,
  rwpng, LazFileUtils, SpinEx, bmfontgen;

type

  { TSpriteSheetExportForm }

  { TFontSheetExportForm }

  TFontSheetExportForm = class(TForm)
    Apply: TButton;
    Button1: TButton;
    DescExportToClipboard: TButton;
    ExportToClipBoard: TButton;
    ExportToFile: TButton;
    CSWidth: TSpinEdit;
    CSHeight: TSpinEdit;
    DescExportToFile: TButton;
    FontDialog1: TFontDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SpinEditCustomFontWidth: TSpinEditEx;
    SpinEditCustomFontHeight: TSpinEditEx;
    SpinStartChar: TSpinEditEx;
    SpinEndChar: TSpinEditEx;
    FontSheet: TComboBox;
    SpriteSize: TComboBox;
    Direction: TComboBox;
    FontSheetPaintBox: TPaintBox;
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
    procedure Button1Click(Sender: TObject);
    procedure DescExportToFileClick(Sender: TObject);
    procedure DirectionChange(Sender: TObject);
    procedure ExportToBMFontFiles(Sender: TObject);
    procedure ExportToFileClick(Sender: TObject);
    procedure ExportToClipboardClick(Sender: TObject);
    procedure FontDialog1ApplyClicked(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FontSheetChange(Sender: TObject);
    procedure FontSheetPaintBoxPaint(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);
  private

  public

     FontSheetBitMap : TBitMap;
     CharBitMap      : TBitMap;
     CharWidth       : integer;
     CharHeight      : integer;
     FontSheetWidth  : integer;
     FontSheetHeight : integer;
     ZoomSize        : integer;

     procedure UpdateFontValues;
     procedure UpdateFontSheetValues;
     procedure UpdateFontSheet;
     procedure UpdatePaintBoxSize;
     procedure UpdateSpriteSheetSize;
     procedure UpdateItemsPerRow;
     procedure ImportFontCharacters;
     procedure CharToBitMap(c : integer);
     procedure ApplySettings;

     function FindBigFontWidth : integer;
     function FindBigFontHeight : integer;
     procedure UpdateBmInfo(var info : TBmInfo);
     procedure UpdateBmCommon(var common : TBmCommon);
     function CharToBmChar(x,y,c : integer) : TBmChar;

     procedure FixPicture(Picture1 : TPicture);

  end;

var
  FontSheetExportForm: TFontSheetExportForm;

implementation


{$R *.lfm}

{ TSpriteSheetExportForm }


procedure TFontSheetExportForm.FormCreate(Sender: TObject);
begin
   CharWidth:=32;
   CharHeight:=32;
   FontSheetWidth:=320;
   FontSheetHeight:=200;

   ZoomSize:=ZoomTrackBar.Position;
   FontSheetBitMap:=TBitMap.Create;

   FontSheetBitMap.SetSize(FontSheetWidth,FontSheetHeight);
   FontSheetBitMap.Canvas.FillRect(0,0,FontSheetWidth,FontSheetHeight);

   CharBitMap:=TBitMap.Create;
   CharBitMap.SetSize(CharWidth,CharHeight);
   CharBitMap.Canvas.Font:=FontDialog1.Font;

   FontSheetPaintBox.Width:=FontSheetWidth*ZoomSize;
   FontSheetPaintBox.Height:=FontSheetHeight*ZoomSize;

   ApplySettings;
end;

procedure TFontSheetExportForm.FormDestroy(Sender: TObject);
begin
  CharBitMap.Free;
  FontSheetBitMap.Free;
end;

procedure TFontSheetExportForm.UpdateItemsPerRow;
begin
if Direction.ItemIndex = 0  then
begin
   ItemsPerRow.Value:=FontSheetWidth div CharWidth;
end
else
begin
  ItemsPerRow.Value:=FontSheetHeight div CharHeight;
end;
CharBitMap.SetSize(CharWidth,CharHeight);
end;

procedure TFontSheetExportForm.FontSheetChange(Sender: TObject);
begin
  UpdateFontSheetValues;
  UpdateFontValues;
  UpdateItemsPerRow;
end;

procedure TFontSheetExportForm.ApplySettings;
begin
  UpdateFontValues;
  UpdateFontSheetValues;
  UpdateSpriteSheetSize;
  FontSheetBitMap.Canvas.FillRect(0,0,FontSheetWidth,FontSheetHeight);
  UpdatePaintBoxSize;
  UpdateItemsPerRow;
  ImportFontCharacters;
  FontSheetPaintBox.Invalidate;
end;

procedure TFontSheetExportForm.ApplyClick(Sender: TObject);
begin
  ApplySettings;
end;

procedure TFontSheetExportForm.Button1Click(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
   CharBitMap.Canvas.Font:=FontDialog1.Font;
   CharBitMap.Canvas.Font.Quality:=fqNonAntialiased;
   ApplySettings;
  end;
end;

procedure TFontSheetExportForm.DescExportToFileClick(Sender: TObject);
begin

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


procedure TFontSheetExportForm.DirectionChange(Sender: TObject);
begin
  if Direction.ItemIndex = 0  then
  begin
     ItemsPerRow.Value:=FontSheetWidth div CharWidth;
  end
  else
  begin
    ItemsPerRow.Value:=FontSheetHeight div CharHeight;
  end;
end;

procedure TFontSheetExportForm.ExportToClipboardClick(Sender: TObject);
begin
  Clipboard.Assign(FontSheetBitMap);
end;

procedure TFontSheetExportForm.FixPicture(Picture1 : TPicture);
var
 i,j        : integer;
 pixeldata  : PByte;
 pixelpos   : longint;
 cl         : TColor;
 PngRGBA    : PngRGBASettingsRec;
begin
  RMConfigBase.GetProps(PngRGBA);
  Picture1.Bitmap.Width:=FontSheetWidth;
  Picture1.Bitmap.height:=FontSheetHeight;
  Picture1.BitMap.PixelFormat:=pf32bit;         //change format to 32 bit/RGBA

  pixeldata:=picture1.Bitmap.RawImage.Data;
  pixelpos:=0;
  for j:=0 to FontSheetHeight-1 do
  begin
    for i:=0 to FontSheetWidth-1 do
    begin
      cl:=FontSheetBitMap.Canvas.Pixels[i,j];
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
      inc(pixelpos,4);
    end;
  end;
end;

procedure TFontSheetExportForm.ExportToFileClick(Sender: TObject);
var
 Picture1   : TPicture;
 ext        : string;
begin
  Picture1:=TPicture.Create;
  FixPicture(Picture1);
  SaveDialog1.Filter := 'PNG|*.png|All Files|*.*';
  if SaveDialog1.Execute then
  begin
    ext:=UpperCase(ExtractFileExt(SaveDialog1.Filename));
    if ext = '.PNG' then Picture1.SaveToFile(SaveDialog1.FileName,'.PNG');
  end;
  Picture1.Free;
end;

procedure TFontSheetExportForm.FontDialog1ApplyClicked(Sender: TObject);
begin
  ApplyClick(Sender);
end;

procedure TFontSheetExportForm.FormActivate(Sender: TObject);
begin
  UpdateFontSheet;
end;

procedure TFontSheetExportForm.FontSheetPaintBoxPaint(Sender: TObject);
begin
  UpdateFontSheet;
end;

procedure TFontSheetExportForm.UpdateFontSheet;
begin
  FontSheetPaintBox.Canvas.CopyRect(Rect(0,0,FontSheetWidth*ZoomSize,FontSheetHeight*ZoomSize),FontSheetBitMap.Canvas,Rect(0,0,FontSheetWidth,FontSheetHeight));
end;

procedure TFontSheetExportForm.UpdatePaintBoxSize;
begin
  FontSheetPaintBox.Width:=FontSheetWidth*ZoomSize;
  FontSheetPaintBox.Height:=FontSheetHeight*ZoomSize;
end;

procedure TFontSheetExportForm.UpdateSpriteSheetSize;
begin
  FontSheetBitMap.SetSize(FontSheetWidth,FontSheetHeight);
end;

procedure TFontSheetExportForm.ZoomTrackBarChange(Sender: TObject);
begin
  ZoomSize:=ZoomTrackBar.Position;
  FontSheetPaintBox.Width:=FontSheetWidth*ZoomSize;
  FontSheetPaintBox.Height:=FontSheetHeight*ZoomSize;
  FontSheetPaintBox.Invalidate;
end;

procedure TFontSheetExportForm.UpdateBmInfo(var info : TBmInfo);
begin
  Info.face:=CharBitMap.Canvas.Font.FontData.Name;
  info.size:=CharBitMap.Canvas.Font.Size;
  Info.bold:=Integer(CharBitMap.Canvas.Font.Bold);
  Info.italic:=Integer(CharBitMap.Canvas.Font.Italic);
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

procedure TFontSheetExportForm.UpdateBmCommon(var common : TBmCommon);
begin
  common.LineHeight:=FindBigFontHeight;
  common.Base:=CharBitMap.Canvas.Font.GetTextHeight('H'); //baseLine
  common.scaleW:=FontSheetWidth;
  common.scaleH:=FontSheetHeight;
  common.pages:=1;      //we only support one page
  common.ppacked:=0;    // no packing
  common.alphaChnl:=0;
  common.redChnl:=4;
  common.greenChnl:=4;
  common.blueChnl:=4;
end;


procedure TFontSheetExportForm.UpdateFontValues;
begin
  Case SpriteSize.ItemIndex of 0:begin
                        CharWidth:=8;
                        CharHeight:=8;
                       end;
                     1:begin
                        CharWidth:=16;
                        CharHeight:=16;
                       end;
                     2:begin
                        CharWidth:=32;
                        CharHeight:=32;
                       end;
                     3:begin
                        CharWidth:=64;
                        CharHeight:=64;
                       end;
                     4:begin
                        CharWidth:=128;
                        CharHeight:=128;
                       end;
                     5:begin
                        CharWidth:=256;
                        CharHeight:=256;
                       end;
                     6:begin
                        CharWidth:=SpinEditCustomFontWidth.Value;
                        CharHeight:=SpinEditCustomFontHeight.Value;
                     end;
                     7:begin
                         SpinEditCustomFontWidth.Value:= FindBigFontWidth;
                         SpinEditCustomFontHeight.Value:= FindBigFontHeight;
                         CharWidth:=SpinEditCustomFontWidth.Value;
                         CharHeight:=SpinEditCustomFontHeight.Value;
                       end;
  end;
end;

//cycles through all the characters fonts and finds the one with biggest width
function TFontSheetExportForm.FindBigFontWidth : integer;
var
 i : integer;
 nwidth : integer;
begin
  nwidth:=0;
  for i:=SpinStartChar.Value to SpinEndChar.Value do
  begin
      if CharBitMap.Canvas.Font.GetTextWidth(chr(i)) > nwidth then nwidth:=CharBitMap.Canvas.Font.GetTextWidth(chr(i));
  end;
  result:=nwidth;
end;

//finds biggest height
function TFontSheetExportForm.FindBigFontHeight : integer;
var
 i : integer;
 nheight : integer;
begin
  nheight:=0;
  for i:=SpinStartChar.Value to SpinEndChar.Value do
  begin
      if CharBitMap.Canvas.Font.GetTextHeight(chr(i)) > nheight then nheight:=CharBitMap.Canvas.Font.GetTextHeight(chr(i));
  end;
  result:=nheight
end;

procedure TFontSheetExportForm.UpdateFontSheetValues;
begin
  Case FontSheet.ItemIndex of 0:begin
                        FontSheetWidth:=320;
                        FontSheetHeight:=200;
                       end;
                     1:begin
                        FontSheetWidth:=640;
                        FontSheetHeight:=200;
                       end;
                     2:begin
                        FontSheetWidth:=640;
                        FontSheetHeight:=350;
                       end;
                     3:begin
                        FontSheetWidth:=640;
                        FontSheetHeight:=480;
                       end;
                     4:begin
                        FontSheetWidth:=800;
                        FontSheetHeight:=600;
                       end;
                     5:begin
                        FontSheetWidth:=1024;
                        FontSheetHeight:=768;
                       end;
                     6:begin
                        FontSheetWidth:=CSWidth.Value;
                        FontSheetHeight:=CSHeight.Value;
                       end;

  end;
end;
function TFontSheetExportForm.CharToBmChar(x,y,c : integer) : TBmChar;
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

 bmc.height:=CharBitMap.Canvas.Font.GetTextHeight(chr(c));
 bmc.width:=CharBitMap.Canvas.Font.GetTextWidth(chr(c));
 bmc.xadvance:=bmc.width+1;
 result:=bmc;
end;

procedure TFontSheetExportForm.ExportToBMFontFiles(Sender: TObject);
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


procedure TFontSheetExportForm.CharToBitMap(c : integer);
begin
  CharBitMap.Canvas.Clear;
  CharBitMap.Canvas.Brush.Color:=clBlack;
  CharBitMap.Canvas.Pen.Color:=clWhite;
  CharBitMap.Canvas.TextOut(0,0,chr(c));
end;

procedure TFontSheetExportForm.ImportFontCharacters;
var
c   : integer;
ipr : integer;
xstart,ystart : integer;
begin
  ipr:=0;
  xstart:=0;
  ystart:=0;
  FontSheetBitMap.canvas.Clear;
  for c:=SpinStartChar.Value to SpinEndChar.Value do
  begin
    CharToBitMap(c);
    FontSheetBitMap.Canvas.CopyRect(Rect(xstart,ystart,xstart+CharWidth,ystart+CharHeight),CharBitMap.Canvas,Rect(0,0,CharWidth,CharHeight));
    inc(ipr);
    if ipr = ItemsPerRow.Value then
    begin
      ipr:=0;
      if Direction.ItemIndex = 0 then
      begin
        xstart:=0;
        inc(ystart,CharHeight);
      end
      else
      begin
        ystart:=0;
        inc(xstart,CharWidth);
      end;
    end
    else
    begin
      if Direction.ItemIndex = 0 then inc(xstart,CharWidth) else inc(ystart,CharHeight);
    end;
  end;
end;

end.

