unit SpriteSheetExport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, ComCtrls,Clipbrd,rmthumb,rmconfig,rwpng;

type

  { TSpriteSheetExportForm }

  TSpriteSheetExportForm = class(TForm)
    Apply: TButton;
    ExportToClipBoard: TButton;
    ExportToFile: TButton;
    SaveDialog1: TSaveDialog;
    SpriteSheet: TComboBox;
    SpriteSize: TComboBox;
    Direction: TComboBox;
    SpriteSheetPaintBox: TPaintBox;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    ItemsPerRow: TSpinEdit;
    Splitter1: TSplitter;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    ZoomTrackBar: TTrackBar;
    procedure ApplyClick(Sender: TObject);
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

  end;

var
  SpriteSheetExportForm: TSpriteSheetExportForm;

implementation


{$R *.lfm}

{ TSpriteSheetExportForm }

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
  // SpriteSheetBitMap.PixelFormat:=pf32bit;
   SpriteSheetBitMap.SetSize(SpriteSheetWidth,SpriteSheetHeight);
   SpriteSheetBitMap.Canvas.FillRect(0,0,SpriteSheetWidth,SpriteSheetHeight);
   UpdateSpriteSheet;
   //SpriteSheetBitMap.Clear;
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

