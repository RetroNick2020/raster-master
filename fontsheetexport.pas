unit fontsheetexport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, ComCtrls, Clipbrd, rmcodegen, rwxgf, rmclipboard, rmthumb, rmconfig,
  rwpng, LazFileUtils, SpinEx;

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
    procedure ExportToClipBoardClick(Sender: TObject);
    procedure ExportToFileClick(Sender: TObject);
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

     CharWidth : integer;
     CharHeight: integer;
     FontSheetWidth : integer;
     FontSheetHeight: integer;
     ZoomSize    : integer;

     procedure UpdateFontValues;
     procedure UpdateFontSheetValues;
     procedure UpdateFontSheet;
     procedure UpdatePaintBoxSize;
     procedure UpdateSpriteSheetSize;
     procedure UpdateItemsPerRow;
     procedure ImportFontCharacters;
     procedure CharToBitMap(c : integer);
     procedure ApplySettings;
  end;

var
  FontSheetExportForm: TFontSheetExportForm;

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

procedure TFontSheetExportForm.FormCreate(Sender: TObject);
begin
   CharWidth:=32;
   CharHeight:=32;
   FontSheetWidth:=320;
   FontSheetHeight:=200;

   ZoomSize:=ZoomTrackBar.Position;
   FontSheetBitMap:=TBitMap.Create;

  // SpriteSheetBitMap.PixelFormat:=pf32bit;
   FontSheetBitMap.SetSize(FontSheetWidth,FontSheetHeight);
   FontSheetBitMap.Canvas.FillRect(0,0,FontSheetWidth,FontSheetHeight);
   //UpdateSpriteSheet;


   CharBitMap:=TBitMap.Create;
   CharBitMap.SetSize(CharWidth,CharHeight);

   CharBitMap.Canvas.Font:=FontDialog1.Font;



   UpdateItemsPerRow;

//   UpdateFontValues;
//   UpdateFontSheetValues;

   //SpriteSheetBitMap.Clear;
   FontSheetPaintBox.Width:=FontSheetWidth*ZoomSize;
   FontSheetPaintBox.Height:=FontSheetHeight*ZoomSize;

//   ImportFontCharacters;

//   FontSheetPaintBox.Invalidate;
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
// SpriteSheetBitMap.Clear;
  UpdateFontValues;
  UpdateFontSheetValues;
  UpdateSpriteSheetSize;
  FontSheetBitMap.Canvas.FillRect(0,0,FontSheetWidth,FontSheetHeight);
  UpdatePaintBoxSize;
  //ImportSprites;
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

procedure TFontSheetExportForm.DescExportToFileClick(Sender: TObject);
  var
    DescName : String;
    F : Text;
    c : integer;
    Lan,snum : integer;
    SWidth,SHeight,x,y,x2,y2 : integer;
    FileName : string;
  begin
   Lan:=menutoLan(DescriptionFile.ItemIndex);
   if (Sender As TButton).Name = 'DescExportToFile' then
   begin
//     SaveDialog2.Filter := 'BAS|*.bas|All Files|*.*';
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

//    Writeln(F,#39,' Sprite Sheet Description Created By Raster Master');
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

//      Writeln(F,DescName,'Desc:');
//      Writeln(F,#39,' Width=',SWidth,' Height=',SHeight);
//      Writeln(F,'DATA ',x,',',y,',',x2,',',y2);
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

procedure TFontSheetExportForm.ExportToClipBoardClick(Sender: TObject);
begin
  Clipboard.Assign(FontSheetBitMap);
end;

procedure TFontSheetExportForm.ExportToFileClick(Sender: TObject);
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
  end;
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


procedure TFontSheetExportForm.CharToBitMap(c : integer);
begin
  CharBitMap.Canvas.Clear;
  CharBitMap.Canvas.Brush.Color:=clBlack;
  CharBitMap.Canvas.Pen.Color:=clWhite;
  CharBitMap.Canvas.TextOut(0,0,chr(c));
end;

procedure TFontSheetExportForm.ImportFontCharacters;
var
c : integer;
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

