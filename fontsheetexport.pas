//=============================================================================
// CHANGE LOG (Claude edits - newest first)
//-----------------------------------------------------------------------------
// 2026-08-12  SHADOW WAS INVISIBLE TO EVERY MEASUREMENT
//   * Enable Shadow draws a second copy of the glyph at (ShadowX,ShadowY) in
//     CharToBitMap, but NOTHING measured it. GetTextWidth/GetTextHeight report
//     the font only, so with a 2,2 shadow the exported width was 2px short in
//     each axis and a consumer blitting "width" clipped the shadow off.
//   * Three call sites were affected and all three are fixed:
//       GlyphSize        - descriptor width/height
//       CharToBmChar     - BMFont .fnt width/height
//       FindBigFontWidth/Height - the "auto size cell to font" option, which
//         sized cells too small and clipped the shadow at render time, so the
//         pixels were never in the sheet to begin with
//   * Only a POSITIVE offset grows the ink. A negative one draws up and left
//     of the origin, where TextOut clips it against the cell edge, so the
//     visible box is unchanged - hence max(offset,0) rather than abs().
//   * xadvance deliberately does NOT include the shadow. A drop shadow is
//     meant to tuck under the following character, not push it along; adding
//     it would space text out as the offset grew.
//   * New FONT_SHADOW_X / FONT_SHADOW_Y constants, and shadow fields in both
//     JSON outputs, so a consumer can tell ink from shadow if it wants to.
//-----------------------------------------------------------------------------
// 2026-08-12  FILE MENU ENTRY FOR THE JSON ATLAS
//   * File > Export JSON Atlas..., beside Export BMFont. Both are interchange
//     formats a user reaches for by name, so both ignore the combo and always
//     write a file - a menu item that silently did nothing because the combo
//     was on Turbo C would be worse than no menu item.
//   * The export body moved into ExportDescriptor(ToClipboard, ForceAtlas).
//     The old handler now just works out those two flags and calls it, so the
//     menu and combo paths cannot drift apart.
//-----------------------------------------------------------------------------
// 2026-08-12  ATLAS EXPORTS NOW WRITE THEIR COMPANION PNG
//   * The JSON formats name their image in the file ("image": "myfont.png"),
//     but only the .json was being written - the PNG was a separate manual
//     step. Pick a different name during that step and the reference dangles,
//     and a Phaser/Pixi loader fails on a file that looks correct.
//   * Both JSON targets now save the sheet beside the descriptor, under the
//     matching name, the same way ExportToBMFontFiles already did for .fnt.
//   * Clipboard export is unchanged: there is no path to write a PNG next to,
//     so it keeps the conventional fontsheet.png reference and copies only
//     the text. SaveAtlasImage is skipped entirely in that case.
//   * The PNG goes through FixPicture, so the transparency settings on the
//     form apply exactly as they do to a plain image export - an atlas whose
//     background was opaque would be useless for a font.
//-----------------------------------------------------------------------------
// 2026-08-12  FONT DESCRIPTOR v2 - xadvance and baseline
//   * Record grew from 7 fields to 8: xadvance is APPENDED, so fields 0..6
//     keep their meaning and position and only FONT_REC_SIZE changes.
//   * width is the ink you can blit, clamped to the cell. xadvance is where
//     the pen goes next and is NOT clamped. They are equal for a glyph that
//     fits, and differ exactly when one overflows its cell - which is the
//     case where advancing by the clamped width would overlap the neighbour.
//   * New FONT_ASCENT / FONT_DESCENT / FONT_BASELINE constants, read from
//     TCanvas.GetTextMetrics. Every glyph is drawn with TextOut(0,0) from the
//     cell's top left, so the baseline sits at the same offset inside every
//     cell and one global value describes them all. That is what lets a
//     caller mix sizes on a line, or sit text on a rule.
//   * GetTextMetrics returns a boolean and can fail on an exotic widgetset.
//     The fallback derives ascent from a cap height measurement rather than
//     writing a zero that a consumer would silently trust.
//-----------------------------------------------------------------------------
// 2026-08-12  FONT DESCRIPTOR FORMAT v1
//   * The description export was one detached blob per character, with no
//     count and no character code - the consumer had to know the range up
//     front and could not tell WHICH character a record described. Replaced
//     with one self describing table:
//
//        [0]      character count
//        then 8 integers per character, in ascending code order:
//        +0 ascii  +1 width  +2 height  +3 x  +4 y  +5 x2  +6 y2
//        +7 xadvance
//
//     BASIC gets a leading DATA with the count then one DATA line per
//     character. C, Pascal and JS get a single flat integer array whose
//     first element is the count.
//   * width/height are the GLYPH's own size (GetTextWidth/GetTextHeight),
//     clamped to the cell. They are NOT x2-x+1 - that is the CELL, which is
//     uniform and recoverable from the rect. Carrying the real glyph box is
//     what lets a caller draw proportional text instead of a fixed grid.
//   * Emits a block of named global constants next to the table: counts,
//     first/last code, sheet and cell size, padding, items per row, fill
//     direction, line height and a fixed-pitch flag. Kept OUT of the array
//     so the array stays exactly count-then-records.
//   * FIRST_CHAR + a contiguity flag let a consumer index straight to a
//     record with (code - FIRST_CHAR) * 7 + 1 instead of scanning.
//   * JSON was a bare unnamed array of objects - not a format anything
//     reads. It is now a structured document with a "font" metrics block
//     and a "chars" array.
//   * NEW export target: JSON - Atlas (TexturePacker). The TexturePacker
//     JSON (Hash) layout is the de-facto sprite atlas standard - Phaser,
//     PixiJS, PlayCanvas, cocos2d and Godot importers all read it. Font
//     metrics ride along under meta.font, which strict readers ignore.
//   * WriteDesc (one call per character) is replaced by a header/char/footer
//     trio, because a table needs a preamble and a terminator.
//=============================================================================

unit fontsheetexport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, ComCtrls, Clipbrd, Menus, ColorBox, rmconst,rwxgf, rmcodegen, rmclipboard, rmthumb, rmconfig,
  rwpng, LazFileUtils, SpinEx, bmfontgen;

//Everything a consumer needs that is NOT per character. Held together in one
//record so the writers cannot be called with half the picture.
type
  TFontDescInfo = record
    Count       : integer;   //number of character records
    FirstChar   : integer;   //lowest character code
    LastChar    : integer;   //highest character code
    Contiguous  : integer;   //1 = codes run FirstChar..LastChar with no gaps
    SheetWidth  : integer;   //atlas pixel size
    SheetHeight : integer;
    CellWidth   : integer;   //grid cell, uniform for every character
    CellHeight  : integer;
    Padding     : integer;   //pixels between cells
    ItemsPerRow : integer;
    Direction   : integer;   //0 = fill across, 1 = fill down
    LineHeight  : integer;   //row pitch: CellHeight + Padding
    ShadowX     : integer;   //0 when the shadow is switched off
    ShadowY     : integer;
    Ascent      : integer;   //baseline offset from the top of a cell
    Descent     : integer;   //pixels below the baseline
    MaxWidth    : integer;   //widest glyph in the range
    MaxAdvance  : integer;   //widest pen advance in the range
    Fixed       : integer;   //1 = every glyph is the same width
    FontName    : string;
    FontSize    : integer;
    ImageName   : string;    //companion PNG, for the atlas formats
  end;

const
  //integers per character record: ascii,width,height,x,y,x2,y2,xadvance
  FontDescRecSize = 8;

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
    MnuExportJsonAtlas: TMenuItem;
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
    procedure ExportToJsonAtlasFiles(Sender: TObject);
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
     procedure BuildFontDescInfo(var fi : TFontDescInfo; const ImageName : string);
     procedure GlyphSize(c : integer; var w, h, xa : integer);
     procedure FontVertMetrics(var ascent, descent : integer);
     procedure ShadowExtent(var sx, sy : integer);
     procedure SaveAtlasImage(const DescFileName : string);
     procedure ExportDescriptor(ToClipboard, ForceAtlas : boolean);
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
procedure WriteDescHeader(var F : Text; lan : integer; const fi : TFontDescInfo;
            var lineno : integer); forward;
procedure WriteDescChar(var F : Text; lan : integer; const fi : TFontDescInfo;
            c, w, h, x, y, x2, y2, xa, cindex : integer; var lineno : integer); forward;
procedure WriteDescFooter(var F : Text; lan : integer; const fi : TFontDescInfo;
            var lineno : integer); forward;
procedure WriteAtlasHeader(var F : Text; const fi : TFontDescInfo); forward;
procedure WriteAtlasChar(var F : Text; const fi : TFontDescInfo;
            c, w, h, xa, x, y, cindex : integer); forward;
procedure WriteAtlasFooter(var F : Text; const fi : TFontDescInfo); forward;
function  JsonEsc(const t : string) : string; forward;
function  JsonBool(b : boolean) : string; forward;
function  CharComment(c : integer) : string; forward;

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

//The shadow offset in effect, or 0,0 when the shadow is switched off.
//
//Only a positive offset is reported. A negative one draws the shadow up and
//to the left of the origin, where TextOut clips it against the cell edge, so
//it adds no visible pixels and must not inflate any measurement.
procedure TFontSheetExportForm.ShadowExtent(var sx, sy : integer);
begin
  sx:=0;
  sy:=0;
  if not chkShadow.Checked then exit;
  if SpinShadowX.Value > 0 then sx:=SpinShadowX.Value;
  if SpinShadowY.Value > 0 then sy:=SpinShadowY.Value;
end;

//The glyph box for one character, plus its pen advance.
//
//w,h are CLAMPED to the cell: a font larger than the chosen cell is drawn
//clipped, so reporting the unclamped size would describe pixels that are not
//in the sheet and send a consumer reading into the next character. They
//INCLUDE the drop shadow when one is enabled, because that is ink too.
//
//xa is NOT clamped. It is where the pen goes next, which is a property of the
//font rather than of the grid. The two are equal for any glyph that fits; they
//separate exactly when one overflows its cell, and there advancing by the
//clamped width would run the next character over its neighbour.
procedure TFontSheetExportForm.GlyphSize(c : integer; var w, h, xa : integer);
var
  sx,sy : integer;
begin
  xa:=CharBitMap.Canvas.Font.GetTextWidth(chr(c));
  w:=xa;
  h:=CharBitMap.Canvas.Font.GetTextHeight(chr(c));

  //a drop shadow is real ink in the cell - a caller blitting w x h would
  //otherwise slice it off. The advance is left alone on purpose: the shadow
  //tucks under the next character rather than pushing it along.
  ShadowExtent(sx,sy);
  inc(w,sx);
  inc(h,sy);

  if w > CharWidth  then w:=CharWidth;
  if h > CharHeight then h:=CharHeight;
  if w  < 0 then w:=0;
  if h  < 0 then h:=0;
  if xa < 0 then xa:=0;
end;

//Ascent and descent for the whole face.
//
//Every glyph is drawn with TextOut(0,0) from its cell's top left corner, so
//the baseline lands at the same offset inside every cell and one pair of
//values describes the entire sheet.
//
//GetTextMetrics can fail on some widgetsets, and it reports that by returning
//false. The fallback measures a capital instead - close to the ascent for a
//Latin face - because emitting a silent zero would give a consumer a baseline
//it would trust and draw against.
procedure TFontSheetExportForm.FontVertMetrics(var ascent, descent : integer);
var
  tm : TLCLTextMetric;
  fullh : integer;
begin
  if CharBitMap.Canvas.GetTextMetrics(tm) then
  begin
    ascent :=tm.Ascender;
    descent:=tm.Descender;
  end
  else
  begin
    ascent :=CharBitMap.Canvas.Font.GetTextHeight('X');
    fullh  :=CharBitMap.Canvas.Font.GetTextHeight('Xg');
    descent:=fullh - ascent;
  end;

  if ascent  < 0 then ascent :=0;
  if descent < 0 then descent:=0;
  //the sheet only ever holds CellHeight rows of pixels, so a baseline past
  //the bottom of the cell would point outside the glyph that was drawn
  if ascent > CharHeight then ascent:=CharHeight;
end;

//Collects everything that is true of the sheet as a whole, once, before the
//per character loop. Glyph widths are measured here too, because the fixed
//pitch flag and the widest-glyph figure cannot be known until every character
//in the range has been looked at.
procedure TFontSheetExportForm.BuildFontDescInfo(var fi : TFontDescInfo;
            const ImageName : string);
var
  c,w,h,xa,firstw : integer;
begin
  fi.FirstChar   := SpinStartChar.Value;
  fi.LastChar    := SpinEndChar.Value;
  fi.Count       := fi.LastChar - fi.FirstChar + 1;
  //the editor exports one unbroken run, so codes are always contiguous. The
  //flag is emitted anyway: it is what tells a consumer it may index with
  //(code - FIRST_CHAR) instead of searching, and if a future build ever gains
  //a "skip blank glyphs" option this is the field that would go to 0.
  fi.Contiguous  := 1;
  fi.SheetWidth  := FontSheetWidth;
  fi.SheetHeight := FontSheetHeight;
  fi.CellWidth   := CharWidth;
  fi.CellHeight  := CharHeight;
  fi.Padding     := SpinPadding.Value;
  fi.ItemsPerRow := ItemsPerRow.Value;
  fi.Direction   := Direction.ItemIndex;
  fi.LineHeight  := CharHeight + SpinPadding.Value;
  ShadowExtent(fi.ShadowX,fi.ShadowY);
  FontVertMetrics(fi.Ascent,fi.Descent);
  fi.FontName    := CharBitMap.Canvas.Font.Name;
  fi.FontSize    := CharBitMap.Canvas.Font.Size;
  fi.ImageName   := ImageName;

  fi.MaxWidth:=0;
  fi.MaxAdvance:=0;
  fi.Fixed:=1;
  firstw:=-1;
  for c:=fi.FirstChar to fi.LastChar do
  begin
    GlyphSize(c,w,h,xa);
    if w  > fi.MaxWidth   then fi.MaxWidth:=w;
    if xa > fi.MaxAdvance then fi.MaxAdvance:=xa;
    //fixed pitch is judged on the ADVANCE, not the ink. Two glyphs can have
    //different ink widths and still be monospaced, and it is the advance a
    //renderer would skip the lookup for.
    if firstw < 0 then firstw:=xa
    else if xa <> firstw then fi.Fixed:=0;
  end;
end;

//Writes the sheet as a PNG beside a descriptor file, under the name the
//descriptor refers to. Kept separate from the image export button so that one
//keeps its own Save dialog and filter.
procedure TFontSheetExportForm.SaveAtlasImage(const DescFileName : string);
var
  Picture1 : TPicture;
  PngName  : string;
begin
  PngName:=ChangeFileExt(DescFileName,'.png');
  Picture1:=TPicture.Create;
  try
    FixPicture(Picture1);   //applies the form's transparency settings
    Picture1.SaveToFile(PngName,'.PNG');
  finally
    Picture1.Free;
  end;
end;

//The whole descriptor export, with the two decisions the caller has already
//made passed in rather than sniffed from a Sender.
//
//ForceAtlas exists because the File menu offers the atlas directly, the same
//way it offers BM Font: those two are interchange formats a user reaches for
//by name, not language choices that belong in the combo. Routing both entry
//points through one body keeps them from drifting apart.
procedure TFontSheetExportForm.ExportDescriptor(ToClipboard, ForceAtlas : boolean);
var
  F : Text;
  c : integer;
  Lan, csprite : integer;
  gw, gh, gxa, x, y, x2, y2 : integer;
  FileName : string;
  pad : integer;
  lineno : integer;
  IsAtlas : boolean;
  fi : TFontDescInfo;
begin
  //TexturePacker JSON is picked by combo index or forced by the menu - it is
  //an interchange format, not a language, exactly like BM Font
  IsAtlas:=ForceAtlas or (DescriptionFile.ItemIndex = 21);

  if IsAtlas then Lan:=JSonLan
             else Lan:=menuToLan(DescriptionFile.ItemIndex);
  pad:=SpinPadding.Value;

  if ToClipboard then
  begin
    FileName:=GetTemporaryPathAndFileName;
  end
  else
  begin
    if IsAtlas then SaveDialog2.Filter := 'JSON|*.json|All Files|*.*'
               else SaveDialog2.Filter := LanToFileFilter(Lan);
    if NOT SaveDialog2.Execute then exit;
    FileName:=SaveDialog2.FileName;
  end;

  //the atlas formats name their companion image. Derive it from the chosen
  //file name so the pair matches on disk; a clipboard export has no name to
  //derive from, so it gets the conventional default.
  if ToClipboard then
    BuildFontDescInfo(fi,'fontsheet.png')
  else
    BuildFontDescInfo(fi,ChangeFileExt(ExtractFileName(FileName),'.png'));

  {$I-}
  System.Assign(F, FileName);
  Rewrite(F);
  {$I+}
  if IORESULT <> 0 then exit;

  lineno:=1000;   //GW-BASIC line numbering, ignored by every other target

  if IsAtlas then
    WriteAtlasHeader(F,fi)
  else
  begin
    WriteHeader(F, Lan);
    WriteDescHeader(F, Lan, fi, lineno);
  end;

  csprite:=0;
  for c:=SpinStartChar.Value to SpinEndChar.Value do
  begin
    inc(csprite);
    if Direction.ItemIndex = 0 then
      CalcHorizPad(csprite, CharWidth, CharHeight, ItemsPerRow.Value, pad, x, y, x2, y2)
    else
      CalcVertPad(csprite, CharWidth, CharHeight, ItemsPerRow.Value, pad, x, y, x2, y2);

    GlyphSize(c, gw, gh, gxa);

    if IsAtlas then
      WriteAtlasChar(F, fi, c, gw, gh, gxa, x, y, csprite)
    else
      WriteDescChar(F, Lan, fi, c, gw, gh, x, y, x2, y2, gxa, csprite, lineno);
  end;

  if IsAtlas then WriteAtlasFooter(F,fi)
             else WriteDescFooter(F, Lan, fi, lineno);

  {$I-}
  System.close(F);
  {$I+}

  if ToClipboard then
  begin
    ReadFileAndCopyToClipboard(FileName);
    EraseFile(FileName);
    ShowMessage('Exported to Clipboard!');
  end
  else if IsAtlas or (Lan = JSonLan) then
  begin
    //these two name their image inside the descriptor, so the PNG has to go
    //out with it or the reference points at nothing
    SaveAtlasImage(FileName);
    ShowMessage('Exported:'+sLineBreak+
                ExtractFileName(FileName)+sLineBreak+
                ExtractFileName(ChangeFileExt(FileName,'.png')));
  end;
end;

//Buttons and the two Description menu items. Which of the pair fired decides
//file versus clipboard; the combo decides the format.
procedure TFontSheetExportForm.DescExportToFileClick(Sender: TObject);
var
  ToClipboard : boolean;
begin
  if DescriptionFile.ItemIndex = 13 then  //BMFont
  begin
    ExportToBMFontFiles(Sender);
    exit;
  end;

  ToClipboard:=true;
  if Sender is TButton then
    ToClipboard:=((Sender as TButton).Name = 'DescExportToClipboard')
  else if Sender is TMenuItem then
    ToClipboard:=((Sender as TMenuItem).Name = 'MnuExportDescClip');

  ExportDescriptor(ToClipboard,false);
end;

//File > Export JSON Atlas. Always a file export and always the atlas format,
//whatever the combo happens to be set to - same contract as Export BMFont.
procedure TFontSheetExportForm.ExportToJsonAtlasFiles(Sender: TObject);
begin
  ExportDescriptor(false,true);
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

//Escapes the few characters JSON forbids in a string. Font names come from a
//system font dialog, so a stray quote or backslash is unlikely but cheap to
//guard against - and an unescaped one produces a file no parser will load.
function JsonEsc(const t : string) : string;
var
  i : integer;
  r : string;
begin
  r:='';
  for i:=1 to Length(t) do
    case t[i] of
      '"'  : r:=r+'\"';
      '\'  : r:=r+'\\';
      #8   : r:=r+'\b';
      #9   : r:=r+'\t';
      #10  : r:=r+'\n';
      #12  : r:=r+'\f';
      #13  : r:=r+'\r';
    else
      if t[i] < ' ' then r:=r+'\u00'+HexStr(Ord(t[i]),2)
                    else r:=r+t[i];
    end;
  JsonEsc:=r;
end;

//A character code as a comment, only when it is safe to print. Codes below 32
//and 127+ would put control bytes or codepage dependent glyphs straight into
//the generated source.
//Writeln renders a boolean as TRUE/FALSE. JSON only accepts true/false, so
//booleans are built as text rather than written directly.
function JsonBool(b : boolean) : string;
begin
  if b then JsonBool:='true' else JsonBool:='false';
end;

function CharComment(c : integer) : string;
begin
  if (c >= 32) and (c < 127) then CharComment:='''' + chr(c) + ''''
  else CharComment:='#' + IntToStr(c);
end;

//=============================================================================
// FONT DESCRIPTOR - v1
//
// One self describing table, in ascending character code order:
//
//    [0]                       character count
//    [1 + i*7 .. 7 + i*7]      ascii, width, height, x, y, x2, y2
//
// width/height are the GLYPH box. x,y,x2,y2 are the CELL rect in the atlas,
// inclusive, so cell width is x2-x+1. The two differ for every proportional
// font and that difference is the point: it is what lets a caller advance by
// the glyph rather than by the grid.
//
// Global metrics are emitted as named constants BESIDE the table, never
// inside it, so element 0 is always the count and the stride is always 7.
//=============================================================================

//Comment banner plus the global constants, then opens the table.
procedure WriteDescHeader(var F : Text; lan : integer; const fi : TFontDescInfo;
            var lineno : integer);

  //one "NAME = value" in whatever the target spells a constant
  procedure K(const nm : string; v : integer);
  begin
    case Lan of
      QBLan,QB64Lan,PBLan,ABLan,FBLan,FBinQBModeLan,AQBLan:
        Writeln(F,'CONST ',nm,' = ',v);
      GWLan:
        begin
          Writeln(F,lineno,' REM ',nm,' = ',v);
          inc(lineno,10);
        end;
      APLan,QPLan,TMTLan,FPLan,TPLan:
        Writeln(F,'  ',nm,' = ',v,';');
      gccLan,OWLan,TCLan,QCLan,ACLan:
        Writeln(F,'#define ',nm,' ',v);
      JSLan:
        Writeln(F,'const ',nm,' = ',v,';');
    end;
  end;

begin
  case Lan of
    QBLan,QB64Lan,PBLan,ABLan,FBLan,FBinQBModeLan,AQBLan:
      begin
        Writeln(F,#39,' Font: ',fi.FontName,' ',fi.FontSize);
        Writeln(F,#39,' Sheet ',fi.SheetWidth,'x',fi.SheetHeight,
                    '  Cell ',fi.CellWidth,'x',fi.CellHeight,
                    '  Padding ',fi.Padding);
        Writeln(F,#39,' Record: ascii,width,height,x,y,x2,y2,xadvance');
        Writeln(F);
      end;
    GWLan:
      begin
        Writeln(F,lineno,' REM Font: ',fi.FontName,' ',fi.FontSize); inc(lineno,10);
        Writeln(F,lineno,' REM Record: ascii,width,height,x,y,x2,y2,xadvance'); inc(lineno,10);
      end;
    APLan,QPLan,TMTLan,FPLan,TPLan:
      begin
        Writeln(F,'(* Font: ',fi.FontName,' ',fi.FontSize,' *)');
        Writeln(F,'(* Sheet ',fi.SheetWidth,'x',fi.SheetHeight,
                    '  Cell ',fi.CellWidth,'x',fi.CellHeight,
                    '  Padding ',fi.Padding,' *)');
        Writeln(F,'(* Record: ascii,width,height,x,y,x2,y2,xadvance *)');
        Writeln(F);
        Writeln(F,'const');
      end;
    gccLan,OWLan,TCLan,QCLan,ACLan:
      begin
        Writeln(F,'/* Font: ',fi.FontName,' ',fi.FontSize,' */');
        Writeln(F,'/* Sheet ',fi.SheetWidth,'x',fi.SheetHeight,
                    '  Cell ',fi.CellWidth,'x',fi.CellHeight,
                    '  Padding ',fi.Padding,' */');
        Writeln(F,'/* Record: ascii,width,height,x,y,x2,y2,xadvance */');
        Writeln(F);
      end;
    JSLan:
      begin
        Writeln(F,'// Font: ',fi.FontName,' ',fi.FontSize);
        Writeln(F,'// Record: ascii,width,height,x,y,x2,y2,xadvance');
        Writeln(F);
      end;
  end;

  //global metrics - deliberately outside the table
  case Lan of
    QBLan,QB64Lan,PBLan,ABLan,FBLan,FBinQBModeLan,AQBLan,GWLan,
    APLan,QPLan,TMTLan,FPLan,TPLan,
    gccLan,OWLan,TCLan,QCLan,ACLan,JSLan:
      begin
        K('FONT_CHAR_COUNT' ,fi.Count);
        K('FONT_FIRST_CHAR' ,fi.FirstChar);
        K('FONT_LAST_CHAR'  ,fi.LastChar);
        K('FONT_CONTIGUOUS' ,fi.Contiguous);
        K('FONT_REC_SIZE'   ,FontDescRecSize);
        K('FONT_SHEET_W'    ,fi.SheetWidth);
        K('FONT_SHEET_H'    ,fi.SheetHeight);
        K('FONT_CELL_W'     ,fi.CellWidth);
        K('FONT_CELL_H'     ,fi.CellHeight);
        K('FONT_PADDING'    ,fi.Padding);
        K('FONT_PER_ROW'    ,fi.ItemsPerRow);
        K('FONT_DIRECTION'  ,fi.Direction);
        K('FONT_LINE_H'     ,fi.LineHeight);
        K('FONT_SHADOW_X'   ,fi.ShadowX);
        K('FONT_SHADOW_Y'   ,fi.ShadowY);
        K('FONT_ASCENT'     ,fi.Ascent);
        K('FONT_DESCENT'    ,fi.Descent);
        K('FONT_BASELINE'   ,fi.Ascent);   //baseline offset from a cell's top
        K('FONT_MAX_W'      ,fi.MaxWidth);
        K('FONT_MAX_ADV'    ,fi.MaxAdvance);
        K('FONT_FIXED'      ,fi.Fixed);
      end;
  end;

  //open the table and write the count as its first value
  case Lan of
    QBLan,QB64Lan,PBLan,ABLan,FBLan,FBinQBModeLan,AQBLan:
      begin
        Writeln(F);
        Writeln(F,#39,' character count');
        Writeln(F,'DATA ',fi.Count);
        Writeln(F,#39,' ascii,width,height,x,y,x2,y2,xadvance');
      end;
    GWLan:
      begin
        Writeln(F,lineno,' REM character count'); inc(lineno,10);
        Writeln(F,lineno,' DATA ',fi.Count);      inc(lineno,10);
      end;
    APLan,QPLan,TMTLan,FPLan,TPLan:
      begin
        Writeln(F);
        Writeln(F,'  FontDesc : array[0..',fi.Count*FontDescRecSize,
                  '] of integer = (');
        Writeln(F,'    ',fi.Count,',   (* character count *)');
        Writeln(F,'    (* ascii, width, height,   x,   y,  x2,  y2, xadv *)');
      end;
    gccLan,OWLan,TCLan,QCLan,ACLan:
      begin
        Writeln(F);
        Writeln(F,'int FontDesc[',fi.Count*FontDescRecSize+1,'] = {');
        Writeln(F,'    ',fi.Count,',   /* character count */');
        Writeln(F,'    /* ascii, width, height,   x,   y,  x2,  y2, xadv */');
      end;
    JSLan:
      begin
        Writeln(F);
        Writeln(F,'// [0] = character count, then ',FontDescRecSize,
                  ' values per character');
        Writeln(F,'const FontDesc = [');
        Writeln(F,'  ',fi.Count,',');
      end;
    JsonLan:
      begin
        Writeln(F,'{');
        Writeln(F,'  "format": "rastermaster-font",');
        Writeln(F,'  "version": 1,');
        Writeln(F,'  "image": "',JsonEsc(fi.ImageName),'",');
        Writeln(F,'  "font": {');
        Writeln(F,'    "name": "',JsonEsc(fi.FontName),'",');
        Writeln(F,'    "size": ',fi.FontSize,',');
        Writeln(F,'    "charCount": ',fi.Count,',');
        Writeln(F,'    "firstChar": ',fi.FirstChar,',');
        Writeln(F,'    "lastChar": ',fi.LastChar,',');
        Writeln(F,'    "contiguous": ',JsonBool(fi.Contiguous = 1),',');
        Writeln(F,'    "sheetWidth": ',fi.SheetWidth,',');
        Writeln(F,'    "sheetHeight": ',fi.SheetHeight,',');
        Writeln(F,'    "cellWidth": ',fi.CellWidth,',');
        Writeln(F,'    "cellHeight": ',fi.CellHeight,',');
        Writeln(F,'    "padding": ',fi.Padding,',');
        Writeln(F,'    "itemsPerRow": ',fi.ItemsPerRow,',');
        Writeln(F,'    "direction": ',fi.Direction,',');
        Writeln(F,'    "lineHeight": ',fi.LineHeight,',');
        Writeln(F,'    "shadowX": ',fi.ShadowX,',');
        Writeln(F,'    "shadowY": ',fi.ShadowY,',');
        Writeln(F,'    "ascent": ',fi.Ascent,',');
        Writeln(F,'    "descent": ',fi.Descent,',');
        Writeln(F,'    "baseline": ',fi.Ascent,',');
        Writeln(F,'    "maxWidth": ',fi.MaxWidth,',');
        Writeln(F,'    "maxAdvance": ',fi.MaxAdvance,',');
        Writeln(F,'    "fixedPitch": ',JsonBool(fi.Fixed = 1));
        Writeln(F,'  },');
        Writeln(F,'  "chars": [');
      end;
  end;
end;

//=============================================================================
// TEXTUREPACKER JSON (HASH)
//
// The de-facto sprite atlas interchange format. Phaser, PixiJS, PlayCanvas,
// cocos2d and the Godot/Unity importers all read it, so an atlas written this
// way drops into an existing engine with no custom loader.
//
// The shape is fixed by those readers and must not be improvised:
//
//   frames : { "<name>": { frame, rotated, trimmed,
//                          spriteSourceSize, sourceSize } }
//   meta   : { app, version, image, format, size, scale }
//
// "rotated" and "trimmed" are false throughout - the sheet is a plain grid,
// nothing is packed at an angle and nothing is cropped, so every frame's
// source size equals its cell and spriteSourceSize starts at 0,0.
//
// Font metrics have no home in the standard, so they ride under meta.font.
// Unknown keys are ignored by every reader above, so the file stays valid for
// a plain atlas consumer while a font-aware one gets the full picture.
//=============================================================================
procedure WriteAtlasHeader(var F : Text; const fi : TFontDescInfo);
begin
  Writeln(F,'{');
  Writeln(F,'"frames": {');
end;

procedure WriteAtlasChar(var F : Text; const fi : TFontDescInfo;
            c, w, h, xa, x, y, cindex : integer);
var
  tail : string;
  cw,ch : integer;
begin
  if cindex < fi.Count then tail:=',' else tail:='';

  //the frame is the CELL, not the glyph - a reader blits the whole cell, and
  //a glyph box smaller than the cell would clip the character
  cw:=fi.CellWidth;
  ch:=fi.CellHeight;

  Writeln(F,'"chr',c,'": {');
  Writeln(F,'	"frame": {"x":',x,',"y":',y,',"w":',cw,',"h":',ch,'},');
  Writeln(F,'	"rotated": false,');
  Writeln(F,'	"trimmed": false,');
  Writeln(F,'	"spriteSourceSize": {"x":0,"y":0,"w":',cw,',"h":',ch,'},');
  Writeln(F,'	"sourceSize": {"w":',cw,',"h":',ch,'},');
  //non standard, ignored by plain atlas readers, needed by font aware ones
  Writeln(F,'	"charCode": ',c,',');
  Writeln(F,'	"glyph": {"w":',w,',"h":',h,'},');
  Writeln(F,'	"xadvance": ',xa);
  Writeln(F,'}',tail);
end;

procedure WriteAtlasFooter(var F : Text; const fi : TFontDescInfo);
begin
  Writeln(F,'},');
  Writeln(F,'"meta": {');
  Writeln(F,'	"app": "Raster Master",');
  Writeln(F,'	"version": "1.0",');
  Writeln(F,'	"image": "',JsonEsc(fi.ImageName),'",');
  Writeln(F,'	"format": "RGBA8888",');
  Writeln(F,'	"size": {"w":',fi.SheetWidth,',"h":',fi.SheetHeight,'},');
  Writeln(F,'	"scale": "1",');
  Writeln(F,'	"font": {');
  Writeln(F,'		"name": "',JsonEsc(fi.FontName),'",');
  Writeln(F,'		"size": ',fi.FontSize,',');
  Writeln(F,'		"charCount": ',fi.Count,',');
  Writeln(F,'		"firstChar": ',fi.FirstChar,',');
  Writeln(F,'		"lastChar": ',fi.LastChar,',');
  Writeln(F,'		"contiguous": ',JsonBool(fi.Contiguous = 1),',');
  Writeln(F,'		"cellWidth": ',fi.CellWidth,',');
  Writeln(F,'		"cellHeight": ',fi.CellHeight,',');
  Writeln(F,'		"padding": ',fi.Padding,',');
  Writeln(F,'		"lineHeight": ',fi.LineHeight,',');
  Writeln(F,'		"shadowX": ',fi.ShadowX,',');
  Writeln(F,'		"shadowY": ',fi.ShadowY,',');
  Writeln(F,'		"ascent": ',fi.Ascent,',');
  Writeln(F,'		"descent": ',fi.Descent,',');
  Writeln(F,'		"baseline": ',fi.Ascent,',');
  Writeln(F,'		"maxWidth": ',fi.MaxWidth,',');
  Writeln(F,'		"maxAdvance": ',fi.MaxAdvance,',');
  Writeln(F,'		"fixedPitch": ',JsonBool(fi.Fixed = 1));
  Writeln(F,'	}');
  Writeln(F,'}');
  Writeln(F,'}');
end;

//One character record.
procedure WriteDescChar(var F : Text; lan : integer; const fi : TFontDescInfo;
            c, w, h, x, y, x2, y2, xa, cindex : integer; var lineno : integer);
var
  tail : string;
begin
  //every record but the last needs a separator - a trailing comma is legal in
  //neither JSON nor Turbo Pascal's initialiser syntax
  if cindex < fi.Count then tail:=',' else tail:='';

  case Lan of
    QBLan,QB64Lan,PBLan,ABLan,FBLan,FBinQBModeLan,AQBLan:
      Writeln(F,'DATA ',c,',',w,',',h,',',x,',',y,',',x2,',',y2,',',xa,
                '    ',#39,' ',CharComment(c));
    GWLan:
      begin
        Writeln(F,lineno,' DATA ',c,',',w,',',h,',',x,',',y,',',x2,',',y2,',',xa);
        inc(lineno,10);
      end;
    APLan,QPLan,TMTLan,FPLan,TPLan:
      Writeln(F,'    ',c:5,',',w:5,',',h:5,',',x:5,',',y:5,',',x2:5,',',y2:5,',',xa:5,
                tail,'   (* ',CharComment(c),' *)');
    gccLan,OWLan,TCLan,QCLan,ACLan:
      Writeln(F,'    ',c:5,',',w:5,',',h:5,',',x:5,',',y:5,',',x2:5,',',y2:5,',',xa:5,
                tail,'   /* ',CharComment(c),' */');
    JSLan:
      Writeln(F,'  ',c:5,',',w:5,',',h:5,',',x:5,',',y:5,',',x2:5,',',y2:5,',',xa:5,
                tail,'   // ',CharComment(c));
    JsonLan:
      begin
        Write  (F,'    { "char": ',c,', "width": ',w,', "height": ',h);
        Writeln(F,', "x": ',x,', "y": ',y,', "x2": ',x2,', "y2": ',y2,
                  ', "xadvance": ',xa,' }',tail);
      end;
  end;
end;

//Terminates the table.
procedure WriteDescFooter(var F : Text; lan : integer; const fi : TFontDescInfo;
            var lineno : integer);
begin
  case Lan of
    APLan,QPLan,TMTLan,FPLan,TPLan:
      Writeln(F,'  );');
    gccLan,OWLan,TCLan,QCLan,ACLan:
      Writeln(F,'};');
    JSLan:
      Writeln(F,'];');
    JsonLan:
      begin
        Writeln(F,'  ]');
        Writeln(F,'}');
      end;
    GWLan:
      begin
        Writeln(F,lineno,' REM end of font descriptor');
        inc(lineno,10);
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
 i,w,sx,sy : integer;
 nwidth : integer;
begin
  nwidth:=0;
  //the shadow has to be counted here or the auto sized cell is too small and
  //clips it at RENDER time - the pixels would never reach the sheet, so no
  //amount of correct measurement afterwards could recover them
  ShadowExtent(sx,sy);
  for i:=SpinStartChar.Value to SpinEndChar.Value do
  begin
      w:=CharBitMap.Canvas.Font.GetTextWidth(chr(i)) + sx;
      if w > nwidth then nwidth:=w;
  end;
  result:=nwidth;
end;

//finds biggest height
function TFontSheetExportForm.FindBigFontHeight : integer;
var
 i,h,sx,sy : integer;
 nheight : integer;
begin
  nheight:=0;
  ShadowExtent(sx,sy);   //see FindBigFontWidth
  for i:=SpinStartChar.Value to SpinEndChar.Value do
  begin
      h:=CharBitMap.Canvas.Font.GetTextHeight(chr(i)) + sy;
      if h > nheight then nheight:=h;
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
 gw,gh,gxa : integer;
begin
 bmc.chnl:=15;
 bmc.id:=c;
 bmc.page:=0;
 bmc.x:=x;
 bmc.y:=y;
 bmc.xoffset:=0;
 bmc.yoffset:=0;

 //GlyphSize already folds in the drop shadow and clamps to the cell, so the
 //.fnt rect matches the pixels actually rendered into the page
 GlyphSize(c,gw,gh,gxa);
 bmc.height:=gh;
 bmc.width:=gw;
 //advance stays font based - the shadow tucks under the next character
 bmc.xadvance:=gxa+1;
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

