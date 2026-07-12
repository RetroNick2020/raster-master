unit fontsheetexport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, ComCtrls, Clipbrd, Menus, ColorBox, rwxgf, rmcodegen, rmclipboard, rmthumb, rmconfig,
  rwpng, LazFileUtils, SpinEx, bmfontgen;

type

  { TSpriteSheetExportForm }

  { TFontSheetExportForm }

  TFontSheetExportForm = class(TForm)
    Apply: TButton;
    Button1: TButton;
    SavebackgroundAsTransparent: TCheckBox;
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
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    MenuFile: TMenuItem;
    MnuApply: TMenuItem;
    MnuSep1: TMenuItem;
    MnuExportImage: TMenuItem;
    MnuExportClipboard: TMenuItem;
    MnuSep2: TMenuItem;
    MnuExportDescFile: TMenuItem;
    MnuExportDescClip: TMenuItem;
    MnuSep3: TMenuItem;
    MnuExportBMFont: TMenuItem;
    MnuSep4: TMenuItem;
    MnuSelectFont: TMenuItem;
    MnuSep5: TMenuItem;
    MnuClose: TMenuItem;
    MenuView: TMenuItem;
    MnuZoomIn: TMenuItem;
    MnuZoomOut: TMenuItem;
    lblPadding: TLabel;
    SpinPadding: TSpinEdit;
    chkShadow: TCheckBox;
    lblShadowX: TLabel;
    SpinShadowX: TSpinEdit;
    lblShadowY: TLabel;
    SpinShadowY: TSpinEdit;
    lblShadowColor: TLabel;
    ShadowColorBox: TColorBox;
    lblBGColor: TLabel;
    BGColorBox: TColorBox;
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
    procedure ScrollBox1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure MnuCloseClick(Sender: TObject);
    procedure MnuZoomInClick(Sender: TObject);
    procedure MnuZoomOutClick(Sender: TObject);
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
     procedure ApplyZoom(newZoom : integer; useAnchor : boolean; anchorX : integer = 0; anchorY : integer = 0);
     procedure UpdateStatusBar;

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


procedure CalcHorizPad(spriteNum, sWidth, sHeight, ipr, pad : integer; var x, y, x2, y2 : integer); forward;
procedure CalcVertPad(spriteNum, sWidth, sHeight, ipr, pad : integer; var x, y, x2, y2 : integer); forward;
function menuToLan(menuid : integer) : integer; forward;
function LanToFileFilter(Lan : integer) : string; forward;
procedure WriteHeader(var F : Text; lan : integer); forward;
procedure WriteDesc(var F : Text; lan : integer; DescName : string; swidth, sheight, x, y, x2, y2 : integer; csprite, snum : integer); forward;

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
   FontSheetBitMap.Canvas.Brush.Color:=clBlack;
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
  UpdateStatusBar;
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
var
  DescName : String;
  F : Text;
  c : integer;
  Lan, snum, csprite : integer;
  SWidth, SHeight, x, y, x2, y2 : integer;
  FileName : string;
  pad : integer;
  ToClipboard : boolean;
begin
  if DescriptionFile.ItemIndex = 13 then  //BMFont
  begin
    ExportToBMFontFiles(Sender);
    exit;
  end;

  Lan:=menuToLan(DescriptionFile.ItemIndex);
  pad:=SpinPadding.Value;

  //determine if this is a clipboard or file export
  ToClipboard:=true;
  if Sender is TButton then
    ToClipboard:=((Sender as TButton).Name = 'DescExportToClipboard')
  else if Sender is TMenuItem then
    ToClipboard:=((Sender as TMenuItem).Name = 'MnuExportDescClip');

  if ToClipboard then
  begin
    FileName:=GetTemporaryPathAndFileName;
  end
  else
  begin
    SaveDialog2.Filter := LanToFileFilter(Lan);
    if NOT SaveDialog2.Execute then exit;
    FileName:=SaveDialog2.FileName;
  end;

  {$I-}
  System.Assign(F, FileName);
  Rewrite(F);
  {$I+}
  if IORESULT <> 0 then exit;

  WriteHeader(F, Lan);
  snum:=SpinEndChar.Value - SpinStartChar.Value + 1;
  SWidth:=CharWidth;
  SHeight:=CharHeight;
  csprite:=0;

  for c:=SpinStartChar.Value to SpinEndChar.Value do
  begin
    inc(csprite);
    DescName:='chr' + IntToStr(c);
    if Direction.ItemIndex = 0 then
      CalcHorizPad(csprite, SWidth, SHeight, ItemsPerRow.Value, pad, x, y, x2, y2)
    else
      CalcVertPad(csprite, SWidth, SHeight, ItemsPerRow.Value, pad, x, y, x2, y2);

    WriteDesc(F, Lan, DescName, SWidth, SHeight, x, y, x2, y2, csprite, snum);
  end;

  {$I-}
  System.close(F);
  {$I+}

  if ToClipboard then
  begin
    ReadFileAndCopyToClipboard(FileName);
    EraseFile(FileName);
    ShowMessage('Exported to Clipboard!');
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
                //13 = BM Font (handled separately)
                14:menutoLan:=GWLan;
                15:menutoLan:=PBLan;
                16:menutoLan:=ABLan;
                17:menutoLan:=FBLan;
                18:menutoLan:=FBinQBModeLan;
                19:menutoLan:=AQBLan;
                20:menutoLan:=JSLan;
  end;
end;

function LanToFileFilter(Lan : integer) : string;
begin
  case Lan of QB64Lan,QBLan,GWLan,PBLan,ABLan,FBLan,FBinQBModeLan,AQBLan:
                LanToFileFilter:='BAS|*.bas|All Files|*.*';
              FPLan,TPLan,TMTLan,APLan,QPLan:
                LanToFileFilter:='PAS|*.pas|All Files|*.*';
              QCLan,gccLan,OWLan,TCLan,ACLan:
                LanToFileFilter:='C|*.c|All Files|*.*';
              JSonLan:LanToFileFilter:='JSON|*.json|All Files|*.*';
              JSLan:LanToFileFilter:='JS|*.js|All Files|*.*';
  end;
end;

procedure WriteHeader(var F : Text;lan : integer);
var
   headstr : string;
begin
  headstr:='Sprite Sheet Description Created By Raster Master';
  case Lan of QB64Lan,QBLan,PBLan,ABLan,FBLan,FBinQBModeLan,AQBLan:
                Writeln(F,#39,' ',headstr);
              GWLan:
                Writeln(F,'1000 REM ',headstr);
              FPLan,TPLan,TMTLan,APLan,QPLan:
                Writeln(F,'(* ',headstr,' *)');
              QCLan,gccLan,OWLan,TCLan,ACLan:
                Writeln(F,'/* ',headstr,' */');
              JSLan:
                Writeln(F,'// ',headstr);
  end;
end;

procedure WriteDesc(var F : Text;lan : integer;DescName : string; swidth,sheight,x,y,x2,y2 : integer;csprite,snum : integer);
begin
  case Lan of QBLan,QB64Lan,PBLan,ABLan,FBLan,FBinQBModeLan,AQBLan:begin
                        Writeln(F,DescName,'Desc:');
                        Writeln(F,#39,' Width=',SWidth,' Height=',SHeight);
                        Writeln(F,'DATA ',x,',',y,',',x2,',',y2);
                      end;
              GWLan:begin
                        Writeln(F,IntToStr(1010 + (csprite-1)*30),' REM ',DescName,' Width=',SWidth,' Height=',SHeight);
                        Writeln(F,IntToStr(1020 + (csprite-1)*30),' DATA ',x,',',y,',',x2,',',y2);
                      end;
          APLan,QPLan,TMTLan,FPLan,TPLan:begin
                         Writeln(F,'(* ',DescName,' Width=',SWidth,' Height=',SHeight,' *)');
                         Writeln(F,DescName,'Desc: Array[1..4] of Integer=(',x,',',y,',',x2,',',y2,');');
                      end;
           gccLan,OWLan,TCLan,QCLan,ACLan:begin
                         Writeln(F,'/* ',DescName,' Width=',SWidth,' Height=',SHeight,' */');
                         Writeln(F,'int ',DescName,'[] = {',x,',',y,',',x2,',',y2,'};');
                                 end;
              JSLan:begin
                         Writeln(F,'// ',DescName,' Width=',SWidth,' Height=',SHeight);
                         Writeln(F,'const ',DescName,'Desc = [',x,',',y,',',x2,',',y2,'];');
                      end;
               JsonLan:begin
                         if csprite = 1 then Writeln(F,'[');
                         Writeln(F,' {');
                         Writeln(F,'  "name": "',DescName,'",');
                         Writeln(F,'  "width":',SWidth,',');
                         Writeln(F,'  "height":',SHeight,',');
                         Writeln(F,'  "x":',x,',');
                         Writeln(F,'  "y":',y,',');
                         Writeln(F,'  "x2":',x2,',');
                         Writeln(F,'  "y2":',y2);
                         if csprite < snum then Writeln(F,' },') else Writeln(F,' }');
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

      if SaveBackgroundAsTransparent.Checked and ((Red(cl)= 0) and (Green(cl)=0) and (Blue(cl)=0)) then   //if black then make transparent
      begin
        pixeldata[pixelpos+3]:=0;
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
  ApplyZoom(ZoomTrackBar.Position, False);
end;

procedure TFontSheetExportForm.ApplyZoom(newZoom : integer; useAnchor : boolean; anchorX : integer; anchorY : integer);
var
  oldZoom : integer;
  pixX, pixY : double;
  newScrollX, newScrollY : integer;
begin
  if newZoom < ZoomTrackBar.Min then newZoom:=ZoomTrackBar.Min;
  if newZoom > ZoomTrackBar.Max then newZoom:=ZoomTrackBar.Max;

  oldZoom:=ZoomSize;
  pixX:=0; pixY:=0;
  if useAnchor and (oldZoom > 0) then
  begin
    pixX:=(ScrollBox1.HorzScrollBar.Position + anchorX) / oldZoom;
    pixY:=(ScrollBox1.VertScrollBar.Position + anchorY) / oldZoom;
  end;

  ZoomTrackBar.OnChange:=nil;
  ZoomTrackBar.Position:=newZoom;
  ZoomTrackBar.OnChange:=@ZoomTrackBarChange;

  ZoomSize:=newZoom;
  FontSheetPaintBox.Width:=FontSheetWidth*ZoomSize;
  FontSheetPaintBox.Height:=FontSheetHeight*ZoomSize;

  if useAnchor then
  begin
    newScrollX:=Round(pixX * ZoomSize) - anchorX;
    newScrollY:=Round(pixY * ZoomSize) - anchorY;
    if newScrollX < 0 then newScrollX:=0;
    if newScrollY < 0 then newScrollY:=0;
    ScrollBox1.HorzScrollBar.Position:=newScrollX;
    ScrollBox1.VertScrollBar.Position:=newScrollY;
  end;

  UpdateStatusBar;
  FontSheetPaintBox.Invalidate;
end;

procedure TFontSheetExportForm.ScrollBox1MouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint;
begin
  pt:=ScrollBox1.ScreenToClient(MousePos);
  if WheelDelta > 0 then
    ApplyZoom(ZoomSize + 1, True, pt.X, pt.Y)
  else
    ApplyZoom(ZoomSize - 1, True, pt.X, pt.Y);
  Handled:=True;
end;

procedure TFontSheetExportForm.UpdateStatusBar;
var
  charCount : integer;
begin
  if StatusBar1.Panels.Count < 5 then exit;
  charCount:=SpinEndChar.Value - SpinStartChar.Value + 1;
  StatusBar1.Panels[0].Text:='Chars: '+IntToStr(charCount);
  StatusBar1.Panels[1].Text:='Sheet: '+IntToStr(FontSheetWidth)+'x'+IntToStr(FontSheetHeight);
  StatusBar1.Panels[2].Text:='Cell: '+IntToStr(CharWidth)+'x'+IntToStr(CharHeight);
  StatusBar1.Panels[3].Text:='Zoom: '+IntToStr(ZoomSize)+'x';
  if chkShadow.Checked then
    StatusBar1.Panels[4].Text:='Shadow: '+IntToStr(SpinShadowX.Value)+','+IntToStr(SpinShadowY.Value)+'  Padding: '+IntToStr(SpinPadding.Value)+'px'
  else
    StatusBar1.Panels[4].Text:='Padding: '+IntToStr(SpinPadding.Value)+'px';
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
        inc(ypos,CharHeight+SpinPadding.Value);
      end
      else
      begin
        ypos:=0;
        inc(xpos,CharWidth+SpinPadding.Value);
      end;
    end
    else
    begin
      if Direction.ItemIndex = 0 then inc(xpos,CharWidth+SpinPadding.Value) else inc(ypos,CharHeight+SpinPadding.Value);
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
var
  bgColor, fgColor, shadowColor : TColor;
  sx, sy : integer;
begin
  bgColor:=BGColorBox.Selected;
  fgColor:=FontDialog1.Font.Color;
  shadowColor:=ShadowColorBox.Selected;

  CharBitMap.Canvas.Brush.Color:=bgColor;
  CharBitMap.Canvas.FillRect(0, 0, CharWidth, CharHeight);
  CharBitMap.Canvas.Brush.Style:=bsClear;

  //draw shadow character first (behind the main character)
  if chkShadow.Checked then
  begin
    sx:=SpinShadowX.Value;
    sy:=SpinShadowY.Value;
    CharBitMap.Canvas.Font.Color:=shadowColor;
    CharBitMap.Canvas.TextOut(sx, sy, chr(c));
  end;

  //draw main character on top
  CharBitMap.Canvas.Font.Color:=fgColor;
  CharBitMap.Canvas.TextOut(0, 0, chr(c));
  CharBitMap.Canvas.Brush.Style:=bsSolid;
end;

procedure CalcHorizPad(spriteNum, sWidth, sHeight, ipr, pad : integer; var x, y, x2, y2 : integer);
var
  idx, col, row : integer;
begin
  idx:=spriteNum - 1;
  col:=idx mod ipr;
  row:=idx div ipr;
  x:=col * (sWidth + pad);
  y:=row * (sHeight + pad);
  x2:=x + sWidth - 1;
  y2:=y + sHeight - 1;
end;

procedure CalcVertPad(spriteNum, sWidth, sHeight, ipr, pad : integer; var x, y, x2, y2 : integer);
var
  idx, col, row : integer;
begin
  idx:=spriteNum - 1;
  row:=idx mod ipr;
  col:=idx div ipr;
  x:=col * (sWidth + pad);
  y:=row * (sHeight + pad);
  x2:=x + sWidth - 1;
  y2:=y + sHeight - 1;
end;

procedure TFontSheetExportForm.MnuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFontSheetExportForm.MnuZoomInClick(Sender: TObject);
begin
  ApplyZoom(ZoomSize + 1, False);
end;

procedure TFontSheetExportForm.MnuZoomOutClick(Sender: TObject);
begin
  ApplyZoom(ZoomSize - 1, False);
end;

procedure TFontSheetExportForm.ImportFontCharacters;
var
  c   : integer;
  ipr : integer;
  xstart,ystart : integer;
  pad : integer;
begin
  ipr:=0;
  xstart:=0;
  ystart:=0;
  pad:=SpinPadding.Value;

  FontSheetBitMap.Canvas.Brush.Color:=BGColorBox.Selected;
  FontSheetBitMap.Canvas.FillRect(0, 0, FontSheetWidth, FontSheetHeight);

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
        inc(ystart,CharHeight+pad);
      end
      else
      begin
        ystart:=0;
        inc(xstart,CharWidth+pad);
      end;
    end
    else
    begin
      if Direction.ItemIndex = 0 then inc(xstart,CharWidth+pad) else inc(ystart,CharHeight+pad);
    end;
  end;
end;

end.

