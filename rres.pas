{$MODE TP}
{$PACKRECORDS 1}
Unit rres;

Interface
   uses rmconst,rmcore,rmthumb,rmxgfcore,rwxgf,rmamigarwxgf,rwpal,wmodex,rwmap,gwbasic,mapcore,rmcodegen,
     wraylib,rwaqb,wmouse,rwspriteanim,animbase,
     //IntToStr. Listed last so it cannot shadow anything this unit already uses.
     SysUtils;

//Function RESInclude(filename:string):word;
Function RESInclude(filename:string; index : integer; ExportOnlyIndex : Boolean):word;

Function RESBinary(filename:string):word;
//RES Binary v3 - adds map properties, strings and keys. Export only.
Function RESBinaryV3(filename:string):word;

//Generic indexed image export - the sprite editor Export menu uses this.
function WriteIndexedCodeToFile(x,y,x2,y2,Lan : integer; filename : string) : word;

//Map key/value properties, shared with the map editor's own Export menu so
//every route applies the same export rules. Call BuildPropExport(map) first,
//then read the result through the accessors.
procedure BuildPropExport(m : integer);
function  PropExportRowCount : integer;
function  PropExportField(r,f : integer) : integer;   //f 0..6 = id,idvalue,kind,a,b,key,value
function  PropExportStrCount : integer;
function  PropExportStr(i : integer) : string;
function  PropExportMaxStrLen : integer;
//One BASIC variable assignment for Lan, WITHOUT a line number - the naming
//rules WriteBasicVariable uses, for callers that number lines themselves.
function  BasicVariableText(Lan : integer;vname,vsubname : string;value : longint) : string;

const
 MaxResItems = 255;
type
 resheadrec = Packed Record
                   sig : array[1..3] of char;
                   ver : byte;
                   resitemcount : integer;
              end;

 resrec = Packed Record
             rt     : integer;
             rid    : array[1..20] of char;
             offset : longint;
             size   : longint;
          end;

 resIndex = array[1..MaxResItems] of resrec;

 RFILE = Packed Record
            ResFile  : File;
            ResList  : ^resIndex;
            ResItems : integer;
         end;

Procedure res_open(Var IRFILE : RFILE;filename : string);
Procedure res_close(var IRFILE : RFILE);
Function  res_getsize(VAR IRFILE : RFILE; ri : integer) : longint;
Procedure res_read(VAR IRFILE : RFILE; var rbuf; ri : integer);

{ RES binary v2 resource type encoding.

  The 16-bit rt field packs three values:

     rt = Category*4096 + Lan*64 + Format

  bits 12-14 : Category (1..7)
  bits  6-11 : Lan      (0..63) - compiler/language id
  bits  0-5  : Format   (0..63) - image type / map format / palette type

  Decoding (any language):
     Category := rt div 4096;
     Lan      := (rt div 64) mod 64;
     Format   := rt mod 64;

  QBasic:  cat% = rt% \ 4096 : lan% = (rt% \ 64) MOD 64 : fmt% = rt% MOD 64
  C:       cat = rt >> 12;  lan = (rt >> 6) & 63;  fmt = rt & 63;

  Max value = 7*4096 + 63*64 + 63 = 32767, so every encoded value fits
  a signed 16-bit integer - readers never see negative values.

  Category is only 3 bits, so 7 is the hard ceiling and all seven values are
  in use. Sprite and map hit boxes therefore share category 6 and are
  distinguished by Format (0 = pixel coords / sprite, 1 = tile coords / map).
  Reading hit boxes:
     if cat = 6 then it is a hit box list; fmt = 0 means the numbers are
     pixels and belong to a sprite, fmt = 1 means tiles and belong to a map.

  The RES header ver field distinguishes encodings:
  ver 1 = old ad-hoc scheme (Lan*100+Image / Lan*200+MapFormat)
  ver 2 = this scheme }

const
  ResTypePalette   = 1;
  ResTypeImage     = 2;
  ResTypeImageMask = 3;
  ResTypeMap       = 4;
  ResTypeAnimation = 5;
  ResTypeHitBox    = 6;   //hit boxes - Format says whose, see HitBoxSpace* below
  ResTypePath      = 7;   //map paths, as the flat array mapcore builds

  //Old name for category 6, kept so existing code still compiles.
  ResTypeSprHitBox = 6;

  //Format values for ResTypeHitBox. Category is only 3 bits wide and all
  //seven values were already taken, so sprite and map hit boxes share
  //category 6 and are told apart by Format instead. The payload layout is
  //identical either way - only the coordinate space differs.
  HitBoxSpacePixel = 0;   //sprite hit boxes, coordinates in pixels
  HitBoxSpaceTile  = 1;   //map hit boxes, coordinates in tiles

function EncodeResType(Category, Lan, Format : integer) : integer;
procedure DecodeResType(rt : integer; var Category, Lan, Format : integer);
(*
Procedure res_dis_xgf(Var IRFILE : RFILE; x,y : integer;ri : integer;dmode : integer);
*)

Implementation

function EncodeResType(Category, Lan, Format : integer) : integer;
begin
  //clamp fields to their bit ranges so a bad value can never corrupt
  //the neighbouring fields
  if Category < 0 then Category:=0;
  if Category > 7 then Category:=7;
  if Lan < 0 then Lan:=0;
  if Lan > 63 then Lan:=63;
  if Format < 0 then Format:=0;
  if Format > 63 then Format:=63;
  EncodeResType:=Category*4096 + Lan*64 + Format;
end;

procedure DecodeResType(rt : integer; var Category, Lan, Format : integer);
begin
  Category:=rt div 4096;
  Lan:=(rt div 64) mod 64;
  Format:=rt mod 64;
end;

Procedure res_open(Var IRFILE : RFILE;filename : string);
type
  ExeHeaderRec = Record
                    Sig    : Word; (* EXE File signature *)
                    bleft  : Word; (* Number of Bytes in last page of EXE image*)
                    nPages : Word; (* Number of 512 Byte pages in EXE image *)
                 end;

Var
 i,error   : word;
 ressig    : array[1..3] of char;
 ExeHeader : ExeHeaderRec;
 ExeSize   : LongInt;
begin
{$I-}
  assign(IRFILE.Resfile,filename);
  Reset(IRFILE.ResFile,1);
  error:=ioresult;
  if error <> 0 then
  begin
    writeln('error opening resource file ',filename);
    halt;
  end;

  exesize:=0;
  If Filename=ParamStr(0) then
  begin
    BlockRead(IRFILE.ResFile,ExeHeader,SizeOf(ExeHeaderRec));
    ExeSize:=Longint(ExeHeader.bleft)+LongInt((ExeHeader.npages-1))*512;
    Seek(IRFILE.ResFile,ExeSize);
  end;

  blockread(IRFILE.Resfile,ressig,3);
  if ressig <> 'RES' then
  begin
    writeln('not a valid resource file');
    halt;
  end;

  blockread(IRFILE.resfile,IRFILE.resitems,2);
  getmem(IRFILE.reslist,sizeof(resrec)*IRFILE.resitems);
  blockread(IRFILE.resfile,IRFILE.reslist^,sizeof(resrec)*IRFILE.resitems);
  error:=ioresult;
  if error<>0 then
  begin
    writeln('error reading resource file header');
    halt;
  end;

  For i:=1 to IRFILE.resitems do
  begin
    Inc(IRFILE.ResList^[i].offset,exesize);
  end;

{$I+}
end;

Procedure res_close(var IRFILE : RFILE);
var
 error : word;
begin
{$I-}
  close(IRFILE.resfile);
  Freemem(IRFILE.reslist,sizeof(resrec)*IRFILE.resitems);
  error:=ioresult;
  if error <> 0 then
  begin
    writeln('error closing resource file');
    halt;
  end;
{$I+}
end;

Function res_getsize(VAR IRFILE : RFILE; ri : integer) : longint;
begin
 res_getsize:=IRFILE.reslist^[ri].size;
end;

Procedure res_read(VAR IRFILE : RFILE; var rbuf; ri : integer);
var
 error        : word;
begin
{$I-}
   seek(IRFILE.resfile,IRFILE.reslist^[ri].offset);
   blockread(IRFILE.resfile,rbuf,IRFILE.reslist^[ri].size);
   error:=ioresult;
   if error <> 0 then
   begin
     writeln('error reading resource file');
     halt;
   end;
{$I+}
end;


//The generic languages have no dialect of their own, so anything that depends
//on one - labels, RESTORE, line numbering, palette syntax - uses its concrete
//equivalent. Identity for every other language.
function ConcreteLan(Lan : integer) : integer;
begin
  ConcreteLan:=Lan;
  case Lan of
    BasicLan   : ConcreteLan:=QBLan;
    BasicLNLan : ConcreteLan:=GWLan;
    CLan       : ConcreteLan:=TCLan;
    PascalLan  : ConcreteLan:=TPLan;
  end;
end;

function GetIndexedImageSize(width,height : integer) : longint;
begin
  //2 header values + one per pixel, as 16 bit words
  GetIndexedImageSize:=(2+longint(width)*height)*2;
end;

//Image Export Propertis Dialog box the image type changes depending on what compiler is selected
//we need a way to convert all the droplist combination to a simple format

function ImageIndexToFormat(Compiler,ImageIndex : integer) : integer;
var
  format : integer;
begin
  format:=0;
  case Compiler of
                  //generic targets - one indexed format, no dialect specifics
                  BasicLan,BasicLNLan,CLan,PascalLan:begin
                           case ImageIndex of 1:format:=IndexedExportFormat;
                           end;
                         end;
                  TPLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=XLibLBMExportFormat;
                                              3:format:=XLibPBMExportFormat;
                                              4:format:=MouseImageExportFormat;
                           end;
                         end;
                  TMTLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                           end;
                         end;
                   TCLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=XLibLBMExportFormat;
                                              3:format:=XLibPBMExportFormat;
                                              4:format:=MouseImageExportFormat;
                           end;
                         end;
                   QCLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   QBLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   BAMLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=RGBExportFormat;
                           end;
                         end;
                   QB64Lan:begin
                           case ImageIndex of 1:format:=RGBAFuchsiaExportFormat;
                                              2:format:=RGBAIndex0ExportFormat;
                                              3:format:=RGBACustomExportFormat;
                                              4:format:=RGBExportFormat;
                                              5:format:=RayLibRGBAFuchsiaExportFormat;
                                              6:format:=RayLibRGBAIndex0ExportFormat;
                                              7:format:=RayLibRGBACustomExportFormat;
                                              8:format:=RayLibRGBExportFormat;
                           end;
                         end;
                   QBJSLan:begin
                             case ImageIndex of 1:format:=RGBAFuchsiaExportFormat;
                                                2:format:=RGBAIndex0ExportFormat;
                                                3:format:=RGBACustomExportFormat;
                                                4:format:=RGBExportFormat;
                             end;
                           end;
                   PBLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   GWLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   FPLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=RGBAFuchsiaExportFormat;
                                              3:format:=RGBAIndex0ExportFormat;
                                              4:format:=RGBACustomExportFormat;
                                              5:format:=RGBExportFormat;
                                              6:format:=MouseImageExportFormat;
                           end;
                         end;
                   FBinQBModeLan:begin
                         case ImageIndex of 1:format:=PutImageExportFormat;
                                            2:format:=MouseImageExportFormat;
                         end;
                       end;
                   FBLan:begin
                           case ImageIndex of 1:format:=RGBAFuchsiaExportFormat;
                                              2:format:=RGBAIndex0ExportFormat;
                                              3:format:=RGBACustomExportFormat;
                                              4:format:=RGBExportFormat;
                           end;
                         end;
                   ABLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=AmigaBOBExportFormat;
                                              3:format:=AmigaVSpriteExportFormat;
                           end;
                         end;
                   APLan:begin
                           case ImageIndex of 1:format:=AmigaBOBExportFormat;
                                              2:format:=AmigaVSpriteExportFormat;
                           end;
                         end;
                   ACLan:begin
                           case ImageIndex of 1:format:=AmigaBOBExportFormat;
                                              2:format:=AmigaVSpriteExportFormat;
                           end;
                         end;
                   AQBLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=AmigaBOBExportFormat;
                                              3:format:=AmigaVSpriteExportFormat;
                           end;
                          end;
                   QPLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   gccLan:begin
                           case ImageIndex of 1:format:=RGBAFuchsiaExportFormat;
                                              2:format:=RGBAIndex0ExportFormat;
                                              3:format:=RGBACustomExportFormat;
                                              4:format:=RGBExportFormat;

                           end;
                         end;
                   OWLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
   end;
   ImageIndexToFormat:=format;
end;

function GetRESImageSize(width,height,nColors,Lan,ImageType : integer) : longint;
var
 size : longint;
 ImageFormat : integer;
begin
 size:=0;
 ImageFormat:=ImageIndexToFormat(Lan,ImageType);
 Case Lan of BasicLan,BasicLNLan,CLan,PascalLan:begin
                      Case ImageFormat of IndexedExportFormat:size:=GetIndexedImageSize(width,height);
                      end;
                    end;

             TPLan:begin
                      Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                          XLibLBMExportFormat,
                                          XLibPBMExportFormat:size:=GetLBMPBMImageSize(width,height); // Xlib LBM/PBM
                                          MouseImageExportFormat:size:=GetMouseShapeSize;
                      end;
                   end;

            TMTLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSizeTMT(width,height,ncolors);
                     end;
                   end;
             TCLan:begin
                      Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                          XLibLBMExportFormat,
                                          XLibPBMExportFormat:size:=GetLBMPBMImageSize(width,height); // Xlib LBM/PBM
                                          MouseImageExportFormat:size:=GetMouseShapeSize;
                      end;
                   end;
             QCLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;
             QPLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;
             GWLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;
             PBLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;
             QBLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                    end;
             BAMLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSizeBAM(width,height,ncolors);
                                               RGBExportFormat:size:=GetRGBXImageSizeBAM(width,height);
                     end;
                    end;
             QB64Lan:begin
                       Case ImageFormat of RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBACustomExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,RGBSize);
                                           RayLibRGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RayLibRGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RayLibRGBACustomExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RayLibRGBExportFormat:size:=ResRayLibImageSize(width,height,RGBSize);
                       end;
                     end;
             QBJSLan:begin
                       Case ImageFormat of RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBACustomExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,RGBSize);
                       end;
                     end;

             FPLan:begin
                      Case ImageFormat of  PutImageExportFormat:size:=GetXImageSizeFP(width,height);
                                           RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBACustomExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,RGBSize);
                                           MouseImageExportFormat:size:=GetMouseShapeSize;
                      end;
                   end;
             FBinQBModeLan:begin
                             Case ImageFormat of PutImageExportFormat:size:=GetXImageSizeFB(width,height);
                                               MouseImageExportFormat:size:=GetMouseShapeSize;
                             end;
                           end;
             FBLan:begin
                      Case ImageFormat of  RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBACustomExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,RGBSize);
                      end;
                    end;
             ABLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetABXImageSize(width,height,nColors);
                                         AmigaBOBExportFormat:size:=GetBobDataSize(width,height,nColors,false); //bob
                                         AmigaVSpriteExportFormat:size:=GetBobDataSize(width,height,nColors,true);  //vsprite
                     end;
                   end;
             AQBLan:begin
                     Case ImageFormat of PutImageExportFormat,
                                         AmigaBOBExportFormat,
                                         AmigaVSpriteExportFormat:size:=width*height;
                     end;
                    end;
             APLan:begin
                      Case ImageFormat of AmigaBOBExportFormat,
                                          AmigaVSpriteExportFormat:size:=GetAmigaBitMapSize(width,height,ncolors);
                      end;
                   end;
             ACLan:begin
                      Case ImageFormat of AmigaBOBExportFormat,
                                          AmigaVSpriteExportFormat:size:=GetAmigaBitMapSize(width,height,ncolors);
                      end;
                   end;
             gccLan:begin
                      // size:=ResRayLibImageSize(width,height,ImageType);
                      Case ImageFormat of  RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBACustomExportFormat:size:=ResRayLibImageSize(width,height,RGBASize);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,RGBSize);
                      end;
                    end;
             OWLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSizeOW(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;

 end;

GetRESImageSize:=size;
end;

function GetRESPaletteSize(nColors,Lan,rgbFormat : integer) : longint;
var
 size : longint;
begin
  size:=0;
  //ColorVGADACFormat lands in the else branch and is correct there: the binary
  //payload is three six bit bytes per colour, same footprint as ColorSixBitFormat.
  //Only ColorIndexFormat is one byte per colour.
  if rgbFormat = ColorIndexFormat then Size:=nColors
    else Size:=nColors*3;
  GetRESPaletteSize:=Size;
end;

//Must match EXACTLY what ResExportMaps writes, because RR.size and the
//running RR.offset are both derived from it - get it wrong and every
//resource after this map points at the wrong place in the file.
//
//ResExportMaps writes SMALLINTS: a 5 value header (width, height, tilewidth,
//tileheight, layercount) followed by layercount x width x height tiles.
//
//Two things were wrong here before: the layer count was not counted at all,
//so a 2 layer map reported the size of 1; and the element size was
//sizeof(integer) (4 bytes) while the writer uses sizeof(smallint) (2).
//Must match EXACTLY what ResExportPaths writes: the flat array as smallints.
function GetRESPathSize(nv : integer) : longint;
begin
  GetRESPathSize:=longint(nv)*sizeof(smallint);
end;

//Writes each exported map's path array, in the same order the header pass
//walked them.
procedure ResExportPaths(var F : File);
var
  i,nv,j : integer;
  MPE : MapExportFormatRec;
  //longint, NOT integer: this unit is {$MODE TP} where integer is 16 bit,
  //but mapcore is objfpc where it is 32 bit, and the var parameter must
  //match the declared type exactly.
  vals : array[0..8191] of longint;
  w : smallint;
begin
  for i:=0 to MapCoreBase.GetMapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i,MPE);
    if MPE.MapFormat <= 0 then continue;
    if MapCoreBase.PathExportCount(i) = 0 then continue;

    nv:=MapCoreBase.BuildPathExportArray(i,vals);
    if nv <= 0 then continue;

    for j:=0 to nv-1 do
    begin
      w:=vals[j];
      {$I-}
      Blockwrite(F,w,sizeof(w));
      {$I+}
      if IORESULT <> 0 then exit;
    end;
  end;
end;

//Must match EXACTLY what ResExportSpriteHitBoxes / ResExportMapHitBoxes write:
//a count followed by 6 smallints per box. RR.size and the running RR.offset
//both derive from it, so an error here shifts every later resource in the file.
//Sprite and map hit boxes have the identical payload shape - only the
//coordinate space differs - so one size function serves both.
//
//SIX values per box, not four: id and value lead each record, ahead of the
//geometry, so a reader can classify a box before parsing its coordinates.
function GetRESHitBoxSize(hbcount : integer) : longint;
begin
  GetRESHitBoxSize:=(longint(hbcount)*6*sizeof(smallint))+sizeof(smallint);
end;

//Counts the maps that will produce a hit box resource.
//MUST use the same guard as the header pass and ResExportMapHitBoxes: the
//header is sized from this number, so counting a map the writer skips (or
//vice versa) desynchronises every offset in the file.
function GetExportMapHitBoxCount : integer;
var
  i,n : integer;
  MPE : MapExportFormatRec;
begin
  n:=0;
  for i:=0 to MapCoreBase.GetMapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i,MPE);
    if (MPE.MapFormat > 0) and (MapCoreBase.GetHitBoxCount(i) > 0) then inc(n);
  end;
  GetExportMapHitBoxCount:=n;
end;

//Writes the sprite hit boxes of every exported sprite, in the same order the
//header pass walked them.
procedure ResExportSpriteHitBoxes(var F : File);
var
  i,j,hbcount : integer;
  HB : HitBoxRec;
  EO : ImageExportFormatRec;
  Line : array[0..5] of smallint;
begin
  for i:=0 to ImageThumbBase.GetCount-1 do
  begin
    ImageThumbBase.GetExportOptions(i,EO);
    hbcount:=ImageThumbBase.GetHitBoxCount(i);
    if (EO.Image <= 0) or (hbcount = 0) then continue;

    Line[0]:=hbcount;
    {$I-}
    Blockwrite(F,Line,sizeof(smallint));
    {$I+}
    if IORESULT <> 0 then exit;

    for j:=0 to hbcount-1 do
    begin
      ImageThumbBase.GetHitBox(i,j,HB);
      //id and value lead, then the geometry
      Line[0]:=HB.id; Line[1]:=HB.value;
      Line[2]:=HB.x;  Line[3]:=HB.y;
      Line[4]:=HB.x2; Line[5]:=HB.y2;
      {$I-}
      Blockwrite(F,Line,6*sizeof(smallint));
      {$I+}
      if IORESULT <> 0 then exit;
    end;
  end;
end;

//Writes the map hit boxes of every exported map, in the same order the header
//pass walked them.
//
//Same payload as the sprite version - a count then id,value,x,y,x2,y2 per
//box - but
//the coordinates are TILES here, not pixels, which is what HitBoxSpaceTile in
//the resource type records. x2/y2 are inclusive, so a box is
//(x2-x+1) by (y2-y+1) tiles.
//
//active/id/value are not written, matching the sprite version and the text
//include output.
procedure ResExportMapHitBoxes(var F : File);
var
  i,j,hbcount : integer;
  HB : HitBoxRec;
  MPE : MapExportFormatRec;
  Line : array[0..5] of smallint;
begin
  for i:=0 to MapCoreBase.GetMapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i,MPE);
    hbcount:=MapCoreBase.GetHitBoxCount(i);
    if (MPE.MapFormat <= 0) or (hbcount = 0) then continue;

    Line[0]:=hbcount;
    {$I-}
    Blockwrite(F,Line,sizeof(smallint));
    {$I+}
    if IORESULT <> 0 then exit;

    for j:=0 to hbcount-1 do
    begin
      MapCoreBase.GetHitBox(i,j,HB);
      //id and value lead, then the geometry
      Line[0]:=HB.id; Line[1]:=HB.value;
      Line[2]:=HB.x;  Line[3]:=HB.y;
      Line[4]:=HB.x2; Line[5]:=HB.y2;
      {$I-}
      Blockwrite(F,Line,6*sizeof(smallint));
      {$I+}
      if IORESULT <> 0 then exit;
    end;
  end;
end;

function GetRESMapSize(mwidth,mheight,nlayers : integer) : longint;
var
 size : longint;
begin
  if nlayers < 1 then nlayers:=1;
  size:=(longint(nlayers)*mwidth*mheight*sizeof(smallint))+(5*sizeof(smallint));
  GetRESMapSize:=Size;
end;

Procedure WriteBasicLabel(var data : BufferRec;Lan : integer;LabelName : string);
begin
  //we don't want GWLan  - it has line number already
  case Lan of BAMLan,ABLan,AQBLan,FBinQBModeLan,FBLan,QBLan,QB64Lan,PBLan,QBJSLan:Writeln(data.fText,LabelName,'Label:');
  end;
end;

function BasicVariableText(Lan : integer;vname,vsubname : string;value : longint) : string;
var
 DotOrUnderScore : String;
begin
  DotOrUnderScore:='.';

  if (Lan=BAMLan) or (Lan=AQBLan) or (Lan = FBinQBModeLan) or (Lan = FBLan) or (Lan = QBJSLan) then
  begin
    DotOrUnderScore:='_';
  end;

  if (Lan=AQBLan) or (Lan = FBLan) then
    BasicVariableText:='Dim '+vname+DotOrUnderScore+vsubname+' As Integer = '+IntToStr(value)
  else if (Lan=QB64Lan) or (Lan=QBJSLan) then
    BasicVariableText:='Const '+vname+DotOrUnderScore+vsubname+' = '+IntToStr(value)
  else
    BasicVariableText:=vname+DotOrUnderScore+vsubname+' = '+IntToStr(value);
end;

procedure WriteBasicVariable(var data : BufferRec;Lan : integer;vname,vsubname : string;value : longint);
begin
  writeln(data.fText,LineCountToStr(Lan),BasicVariableText(Lan,vname,vsubname,value));
end;

procedure WriteFBBasicDimReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  if (Lan<>GWLan) then writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'(',size,') As Integer');
  writeln(data.fText,LineCountToStr(Lan),'For _rmi=0 to ',size-1);
  writeln(data.fText,LineCountToStr(Lan),'   Read ',name,'(_rmi)');
  writeln(data.fText,LineCountToStr(Lan),'Next _rmi');
end;


procedure WriteBasicDimReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  if (Lan<>GWLan) then writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'(',size,')');
  writeln(data.fText,LineCountToStr(Lan),'For i=0 to ',size-1);
  writeln(data.fText,LineCountToStr(Lan),'   Read ',name,'(i)');
  writeln(data.fText,LineCountToStr(Lan),'Next i');
end;

procedure WriteFBBasicReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
  writeln(data.fText,LineCountToStr(Lan),'Dim As Any Ptr ',name);
  writeln(data.fText,LineCountToStr(Lan),name,' = ImageCreate(',name,'_Width,',name,'_Height)');
  writeln(data.fText,LineCountToStr(Lan),'For _rmy=0 to ',name,'_Height-1');
  writeln(data.fText,LineCountToStr(Lan),'  For _rmx=0 to ',name,'_Width-1');
  writeln(data.fText,LineCountToStr(Lan),'   Read _rmr,_rmg,_rmb');
  writeln(data.fText,LineCountToStr(Lan),'   if ',name,'_Format = 7 Then');
  writeln(data.fText,LineCountToStr(Lan),'      Read _rma');
  writeln(data.fText,LineCountToStr(Lan),'      PSet ',name,',(_rmx, _rmy),RGBA(_rmr,_rmg,_rmb,_rma)');
  writeln(data.fText,LineCountToStr(Lan),'   else');
  writeln(data.fText,LineCountToStr(Lan),'       PSet ',name,',(_rmx, _rmy),RGB(_rmr,_rmg,_rmb)');
  writeln(data.fText,LineCountToStr(Lan),'   end if');

  writeln(data.fText,LineCountToStr(Lan),'  Next _rmx');
  writeln(data.fText,LineCountToStr(Lan),'Next _rmy');
end;

procedure WriteQBJSReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
 writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
 writeln(data.fText,LineCountToStr(Lan),'Dim ',name);
 writeln(data.fText,LineCountToStr(Lan),name,' = _NewImage(',name,'_Width,',name,'_Height,32)');
 writeln(data.fText,LineCountToStr(Lan),'rmprevdest = _Dest');
 writeln(data.fText,LineCountToStr(Lan),'_Dest ',name);
 writeln(data.fText,LineCountToStr(Lan),'For rmy=0 to ',name,'_Height-1');
 writeln(data.fText,LineCountToStr(Lan),'  For rmx=0 to ',name,'_Width-1');
 writeln(data.fText,LineCountToStr(Lan),'   Read rmr,rmg,rmb');
 writeln(data.fText,LineCountToStr(Lan),'   if ',name,'_Format = 7 Then');
 writeln(data.fText,LineCountToStr(Lan),'      Read rma');
 writeln(data.fText,LineCountToStr(Lan),'      PSet(rmx,rmy),_RGBA(rmr,rmg,rmb,rma)');
 writeln(data.fText,LineCountToStr(Lan),'   else');
 writeln(data.fText,LineCountToStr(Lan),'      PSet(rmx,rmy),_RGB(rmr,rmg,rmb)');
 writeln(data.fText,LineCountToStr(Lan),'   end if');
 writeln(data.fText,LineCountToStr(Lan),'  Next rmx');
 writeln(data.fText,LineCountToStr(Lan),'Next rmy');
 writeln(data.fText,LineCountToStr(Lan),'_Dest rmprevdest');
end;


procedure WriteQB64ReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'&');
  writeln(data.fText,LineCountToStr(Lan),name,'& = _NewImage(',name,'.Width,',name,'.Height,32)');
  writeln(data.fText,LineCountToStr(Lan),'rmprevdest = _Dest');
  writeln(data.fText,LineCountToStr(Lan),'_Dest ',name,'&');
  writeln(data.fText,LineCountToStr(Lan),'For rmy=0 to ',name,'.Height-1');
  writeln(data.fText,LineCountToStr(Lan),'  For rmx=0 to ',name,'.Width-1');
  writeln(data.fText,LineCountToStr(Lan),'   Read rmr,rmg,rmb');
  writeln(data.fText,LineCountToStr(Lan),'   if ',name,'.Format = 7 Then');
  writeln(data.fText,LineCountToStr(Lan),'      Read rma');
  writeln(data.fText,LineCountToStr(Lan),'      PSet(rmx,rmy),_RGBA(rmr,rmg,rmb,rma)');
  writeln(data.fText,LineCountToStr(Lan),'   else');
  writeln(data.fText,LineCountToStr(Lan),'      PSet(rmx,rmy),_RGB(rmr,rmg,rmb)');
  writeln(data.fText,LineCountToStr(Lan),'   end if');
  writeln(data.fText,LineCountToStr(Lan),'  Next rmx');
  writeln(data.fText,LineCountToStr(Lan),'Next rmy');
  writeln(data.fText,LineCountToStr(Lan),'_Dest rmprevdest');
end;

procedure WriteQB64RayLibReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'Data AS _MEM');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'Image AS Image');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'Texture AS Texture');

  writeln(data.fText,LineCountToStr(Lan),name,'Data = _MemNew(',name,'.Size)');
  writeln(data.fText,LineCountToStr(Lan),'rmc = 0');
  writeln(data.fText,LineCountToStr(Lan),'For rmy=0 to ',name,'.Height-1');
  writeln(data.fText,LineCountToStr(Lan),'  For rmx=0 to ',name,'.Width-1');
  writeln(data.fText,LineCountToStr(Lan),'   Read rmr,rmg,rmb');
  writeln(data.fText,LineCountToStr(Lan),'   _MemPut ',name,'Data, ',name,'Data.OFFSET + rmc, rmr As _UNSIGNED _BYTE ');
  writeln(data.fText,LineCountToStr(Lan),'   _MemPut ',name,'Data, ',name,'Data.OFFSET + rmc + 1, rmg As _UNSIGNED _BYTE ');
  writeln(data.fText,LineCountToStr(Lan),'   _MemPut ',name,'Data, ',name,'Data.OFFSET + rmc + 2, rmb As _UNSIGNED _BYTE ');
  writeln(data.fText,LineCountToStr(Lan),'   if ',name,'.Format = 7 Then');
  writeln(data.fText,LineCountToStr(Lan),'      Read rma');
  writeln(data.fText,LineCountToStr(Lan),'      _MemPut ',name,'Data, ',name,'Data.OFFSET + rmc + 3, rma As _UNSIGNED _BYTE ');
  writeln(data.fText,LineCountToStr(Lan),'      rmc = rmc + 4 ');
  writeln(data.fText,LineCountToStr(Lan),'   else');
  writeln(data.fText,LineCountToStr(Lan),'      rmc = rmc + 3 ');
  writeln(data.fText,LineCountToStr(Lan),'   end if');
  writeln(data.fText,LineCountToStr(Lan),'  Next rmx');
  writeln(data.fText,LineCountToStr(Lan),'Next rmy');

  writeln(data.fText,LineCountToStr(Lan),name,'Image.dat =  ',name,'Data.OFFSET');
  writeln(data.fText,LineCountToStr(Lan),name,'Image.W = ',name,'.Width');
  writeln(data.fText,LineCountToStr(Lan),name,'Image.H = ',name,'.Height');
  writeln(data.fText,LineCountToStr(Lan),name,'Image.mipmaps = 1');
  writeln(data.fText,LineCountToStr(Lan),name,'Image.format = ',name,'.Format');
  writeln(data.fText,LineCountToStr(Lan),'LoadTextureFromImage ',name,'Image, ',name,'Texture');
end;


procedure WriteAQBImageStub(var data : BufferRec;Lan,Image,Mask : integer; name : string;size : longint);
begin
 writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
 writeln(data.fText,LineCountToStr(Lan),'Dim As BITMAP_t PTR ',name,'BitMap = NULL');
 if Image = 2 then
 begin
   writeln(data.fText,LineCountToStr(Lan),'Dim As BOB_t PTR ',name,'Bob');
 end
 else if Image = 3 then
 begin
   writeln(data.fText,LineCountToStr(Lan),'Dim As SPRITE_t PTR ',name,'Sprite');
 end;
 writeln(data.fText,LineCountToStr(Lan),name,'BitMap = BITMAP(',name,'_Width,',name,'_Height,',name,'_Depth,TRUE)');
 writeln(data.fText,LineCountToStr(Lan),'BITMAP OUTPUT ',name,'BitMap');
 writeln(data.fText,LineCountToStr(Lan),'For _rmj=0 to ',name,'_Height-1');
 writeln(data.fText,LineCountToStr(Lan),'   For _rmi=0 to ',name,'_Width-1');
 writeln(data.fText,LineCountToStr(Lan),'      Read _rma');
 writeln(data.fText,LineCountToStr(Lan),'      Pset(_rmi,_rmj),_rma');
 writeln(data.fText,LineCountToStr(Lan),'   Next _rmi');
 writeln(data.fText,LineCountToStr(Lan),'Next _rmj');
 if Mask = 1 then writeln(data.fText,LineCountToStr(Lan),'BITMAP MASK ',name,'BitMap');
 if Image = 2 then
  begin
    writeln(data.fText,LineCountToStr(Lan),name,'Bob = BOB(',name,'BitMap)');
  end
  else if Image = 3 then
  begin
    writeln(data.fText,LineCountToStr(Lan),name,'Sprite = SPRITE(',name,'BitMap)');
  end;
  writeln(data.fText,LineCountToStr(Lan),'WINDOW OUTPUT 1');
end;

procedure WriteAmigaBasicBobVSprite(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
 writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

 writeln(data.fText,LineCountToStr(Lan),name,'$=""');
 writeln(data.fText,LineCountToStr(Lan),'For i=0 to ',size-1);
 writeln(data.fText,LineCountToStr(Lan),'   Read a');
 writeln(data.fText,LineCountToStr(Lan),'   ',name,'$=',name,'$+chr$(a)');
 writeln(data.fText,LineCountToStr(Lan),'Next i');
end;

procedure WriteAmigaBasicPaletteReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
var
 fv : string;
begin
  fv:='i';
  if Lan = AQBLan then fv:='_rmi';
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'!(',size,')');
  writeln(data.fText,LineCountToStr(Lan),'For ',fv,'=0 to ',size-1);
  writeln(data.fText,LineCountToStr(Lan),'   Read ',name,'!(',fv,')');
  writeln(data.fText,LineCountToStr(Lan),'Next ',fv);
end;


//=============================================================================
// GENERIC INDEXED IMAGE EXPORT (generic Basic / Basic Line# / C / Pascal)
//
// One layout for every target: width, height, then one colour index per pixel,
// row by row. Used by the sprite editor's Export menu, RES Text Include and
// RES Binary, so all three always agree.
//
// Values go out through the rmcodegen writer (MWWriteInteger), which already
// knows each language's commas, DATA statements, line wrapping and GW-BASIC
// line numbers - the same path rwmap.ExportMap uses for maps.
//=============================================================================

//x,y..x2,y2 is inclusive. WriteLabel is for the standalone menu export; the
//RES include writes its own label first, so it passes false.
procedure WriteIndexedCode(var F : Text; x,y,x2,y2,Lan : integer;
                           ImageName : string; WriteLabel : boolean);
var
  AsmOn : boolean;
  mc : CodeGenRec;
  w,h,i,j,nColors : integer;
  size : longint;
begin
  w:=x2-x+1;
  h:=y2-y+1;
  size:=2+longint(w)*h;          //values, not bytes
  nColors:=GetMaxColor+1;

  MWInit(mc,F);
  MWSetValuesTotal(mc,size);
  MWSetLan(mc,Lan);
  AsmOn:=PascalAsmProcs and PascalAsmAllowed(Lan);   //generic Pascal qualifies
  MWSetAsm(mc,AsmOn);
  MWSetValueFormat(mc,ValueFormatDecimal);

  if MapLanIsC(Lan) then
  begin
    Writeln(F,'/* C Indexed Image Created By Raster Master */');
    Writeln(F,'/* Size =',size,' Width=',w,' Height=',h,' Colors=',nColors,' */');
    Writeln(F,'/* width, height, then one colour index per pixel, row by row */');
    Writeln(F,'#define ',ImageName,'_Size   ',size);
    Writeln(F,'#define ',ImageName,'_Width  ',w);
    Writeln(F,'#define ',ImageName,'_Height ',h);
    Writeln(F,'#define ',ImageName,'_Colors ',nColors);
    Writeln(F,'  ','int ',ImageName,'[',size,']  = {');
  end
  else if MapLanIsPascal(Lan) then
  begin
    Writeln(F,'(* Pascal Indexed Image Created By Raster Master *)');
    Writeln(F,'(* Size =',size,' Width=',w,' Height=',h,' Colors=',nColors,' *)');
    Writeln(F,'(* width, height, then one colour index per pixel, row by row *)');
    WritePascalConstStart(F,AsmOn);
    Writeln(F,'  ',ImageName,'_Size   = ',size,';');
    Writeln(F,'  ',ImageName,'_Width  = ',w,';');
    Writeln(F,'  ',ImageName,'_Height = ',h,';');
    Writeln(F,'  ',ImageName,'_Colors = ',nColors,';');
    WritePascalDataStart(F,AsmOn,'  ',ImageName,size,'integer',Lan);
  end
  else if MapLanIsBasicLN(Lan) then
  begin
    //line numbered BASIC has no labels - READs run in DATA order
    Writeln(F,GetGWNextLineNumber,' ',#39,' Basic Indexed Image Created By Raster Master');
    Writeln(F,GetGWNextLineNumber,' ',#39,' Size =',size,' Width=',w,' Height=',h,' Colors=',nColors);
    Writeln(F,GetGWNextLineNumber,' ',#39,' width, height, then one colour index per pixel');
  end
  else
  begin
    if WriteLabel then Writeln(F,ImageName+'Label:');
    Writeln(F,#39,' Basic Indexed Image Created By Raster Master');
    Writeln(F,#39,' Size =',size,' Width=',w,' Height=',h,' Colors=',nColors);
    Writeln(F,#39,' width, height, then one colour index per pixel, row by row');
  end;

  MWWriteInteger(mc,w);
  MWWriteInteger(mc,h);
  for j:=y to y2 do
    for i:=x to x2 do
    begin
      {$I-}
      MWWriteInteger(mc,GetPixel(i,j));
      {$I+}
      if IORESULT<>0 then exit;
    end;

  if MapLanIsC(Lan) then Writeln(F,'};')
  else if MapLanIsPascal(Lan) then WritePascalDataEnd(F,AsmOn)
  else Writeln(F);
end;

//standalone file for the sprite editor's Export menu
//base file name without directory or extension. Done here rather than with
//LazFileUtils.ExtractFileNameWithoutExt, which this unit does not use.
function NameFromFileName(filename : string) : string;
var
  nm : string;
  p  : integer;
begin
  nm:=ExtractFileName(filename);
  p:=Length(nm);
  while (p > 0) and (nm[p] <> '.') do dec(p);
  if p > 1 then nm:=Copy(nm,1,p-1);
  NameFromFileName:=nm;
end;

function WriteIndexedCodeToFile(x,y,x2,y2,Lan : integer; filename : string) : word;
var
  F : Text;
  ImageName : string;
  err : word;
begin
  SetCoreActive;   //pixels come from the image being edited, not a thumbnail
  SetGWStartLineNumber(1000);
  ImageName:=NameFromFileName(filename);
  {$I-}
  Assign(F,filename);
  Rewrite(F);
  {$I+}
  //via a local: reading the function name back is a recursive CALL in {$MODE TP}
  err:=IORESULT;
  WriteIndexedCodeToFile:=err;
  if err <> 0 then exit;

  WriteIndexedCode(F,x,y,x2,y2,Lan,ImageName,true);

  {$I-}
  close(F);
  {$I+}
  WriteIndexedCodeToFile:=IORESULT;
end;

//RES binary payload: width, height, then the pixels, all as 16 bit words
procedure WriteIndexedToBuffer(width,height : integer; var F : File);
var
  row : array[0..1023] of integer;
  i,j,n : integer;
begin
  row[0]:=width;
  row[1]:=height;
  {$I-}
  Blockwrite(F,row,2*sizeof(integer));
  {$I+}
  if IORESULT<>0 then exit;

  for j:=0 to height-1 do
  begin
    n:=0;
    for i:=0 to width-1 do
    begin
      row[n]:=GetPixel(i,j);
      inc(n);
      if n = 1024 then      //flush - a row wider than the buffer
      begin
        {$I-}
        Blockwrite(F,row,longint(n)*sizeof(integer));
        {$I+}
        if IORESULT<>0 then exit;
        n:=0;
      end;
    end;
    if n > 0 then
    begin
      {$I-}
      Blockwrite(F,row,longint(n)*sizeof(integer));
      {$I+}
      if IORESULT<>0 then exit;
    end;
  end;
end;

//=============================================================================
// MAP KEY/VALUE PROPERTIES - export side. See the RES Binary v3 spec.
//
// BuildPropExport is the ONE place that decides which rows export and how
// their owners translate from editor terms to exported terms. RES Text
// Include and RES Binary v3 both call it, so the two can never disagree.
//=============================================================================
const
  ResTypeProperties = 8;
  ResTypeStrings    = 9;
  ResTypeKeyDefs    = 10;
  PropRowWords      = 7;   //id, idvalue, kind, a, b, key, value

type
  PropExportRec = record
                    nrows : integer;
                    rows  : array[0..MaxMapProps*PropRowWords-1] of integer;
                    nstr  : integer;
                    strs  : array[0..MaxMapProps-1] of string[MaxPropStrLen];
                  end;
var
  PEx : PropExportRec;

function Clamp16(v : longint) : integer;
begin
  if v < -32768 then v:=-32768;
  if v > 32767 then v:=32767;
  Clamp16:=v;
end;

//identical texts share one string table entry
function PExAddString(const s : string) : integer;
var
  i : integer;
begin
  for i:=0 to PEx.nstr-1 do
    if PEx.strs[i] = s then
    begin
      PExAddString:=i;
      exit;
    end;
  PEx.strs[PEx.nstr]:=s;
  PExAddString:=PEx.nstr;
  inc(PEx.nstr);
end;

//Fills PEx with the exportable rows of map m, owners already translated.
//Rows that no longer point at anything are dropped here, never in the editor:
//  paths  -> the EXPORTED position; inactive or short paths are not exported
//  tiles  -> held by uid, written as the tile's current image index
//  cells  -> must be inside the exported map area
//  keys   -> must still be defined
procedure BuildPropExport(m : integer);
var
  n, w, h, hbc, ks, base : integer;
  id, idvalue, kind, a, b, key, value : longint;
  uid : TGUID;
  txt : ShortString;
  K   : KeyDefRec;
begin
  PEx.nrows:=0;
  PEx.nstr:=0;
  w:=MapCoreBase.GetExportWidth(m);
  h:=MapCoreBase.GetExportHeight(m);
  hbc:=MapCoreBase.GetHitBoxCount(m);

  for n:=0 to MapCoreBase.GetPropCount(m)-1 do
  begin
    //field-by-field read: KeyValueRec holds an AnsiString and this unit is TP
    MapCoreBase.GetPropFields(m,n,id,idvalue,kind,a,b,key,value,uid,txt);

    ks:=MapCoreBase.FindKeyDef(key);
    if ks < 0 then continue;
    MapCoreBase.GetKeyDef(ks,K);

    case kind of
      PropKindMap    : begin
                         a:=0;
                         b:=0;
                       end;
      PropKindHitBox : begin
                         if (a < 0) or (a >= hbc) then continue;
                         b:=0;
                       end;
      PropKindPath   : begin
                         a:=MapCoreBase.PathExportIndex(m,a);
                         if a < 0 then continue;
                         b:=0;
                       end;
      PropKindCell   : begin
                         if (a < 0) or (a >= w) or (b < 0) or (b >= h) then continue;
                       end;
      PropKindTile   : begin
                         a:=ImageThumbBase.FindUID(uid);
                         if a < 0 then continue;
                         b:=0;
                       end;
    else
      continue;
    end;

    if K.ktype = PropTypeString then value:=PExAddString(txt);

    base:=PEx.nrows*PropRowWords;
    PEx.rows[base]  :=Clamp16(id);
    PEx.rows[base+1]:=Clamp16(idvalue);
    PEx.rows[base+2]:=Clamp16(kind);
    PEx.rows[base+3]:=Clamp16(a);
    PEx.rows[base+4]:=Clamp16(b);
    PEx.rows[base+5]:=Clamp16(key);
    PEx.rows[base+6]:=Clamp16(value);
    inc(PEx.nrows);
  end;
end;

//offset table + one length byte per string + the characters
function PExStrPayloadSize : longint;
var
  i : integer;
  t : longint;
begin
  t:=longint(PEx.nstr)*2;
  for i:=0 to PEx.nstr-1 do inc(t,1+Length(PEx.strs[i]));
  PExStrPayloadSize:=t;
end;

//Longest string in the current table. Pascal targets declare the string
//array with this length: a plain "array of string" is 256 bytes an entry,
//and 256 of those would fill Turbo Pascal's whole 64K data segment.
function PExMaxStrLen : integer;
var
  i,m : integer;
begin
  m:=1;
  for i:=0 to PEx.nstr-1 do
    if Length(PEx.strs[i]) > m then m:=Length(PEx.strs[i]);
  PExMaxStrLen:=m;
end;

//accessors for callers outside this unit - see the interface
function PropExportRowCount : integer;
begin
  PropExportRowCount:=PEx.nrows;
end;

function PropExportField(r,f : integer) : integer;
begin
  PropExportField:=0;
  if (r < 0) or (r >= PEx.nrows) or (f < 0) or (f >= PropRowWords) then exit;
  PropExportField:=PEx.rows[r*PropRowWords+f];
end;

function PropExportStrCount : integer;
begin
  PropExportStrCount:=PEx.nstr;
end;

function PropExportStr(i : integer) : string;
begin
  PropExportStr:='';
  if (i >= 0) and (i < PEx.nstr) then PropExportStr:=PEx.strs[i];
end;

function PropExportMaxStrLen : integer;
begin
  PropExportMaxStrLen:=PExMaxStrLen;
end;

//The same map Lan -> BASIC Lan mapping the hit box writer uses inline.
function MapLanToBasicLan(MapLan : integer) : integer;
begin
  MapLanToBasicLan:=QBLan;
  if (MapLan = BasicLnLan) or (MapLan = GWBasicLan) then MapLanToBasicLan:=GWLan
  else if MapLan = FBBasicLan then MapLanToBasicLan:=FBLan
  else if MapLan = AQBBasicLan then MapLanToBasicLan:=AQBLan
  else if MapLan = BAMBasicLan then MapLanToBasicLan:=BAMLan;
end;

procedure WritePropRowNumbers(var t : text; r : integer);
var
  j : integer;
begin
  for j:=0 to PropRowWords-1 do
  begin
    if j > 0 then write(t,',');
    write(t,PEx.rows[r*PropRowWords+j]);
  end;
end;

//Strings are written a piece at a time and never assembled into one string:
//in {$MODE TP} a string is a 255 character shortstring, and a 240 character
//value with its quotes and escapes would not fit in one.
procedure WriteCQuoted(var t : text; const s : string);   //C and JS
var
  i : integer;
begin
  write(t,'"');
  for i:=1 to Length(s) do
    if (s[i] = '\') or (s[i] = '"') then write(t,'\',s[i]) else write(t,s[i]);
  write(t,'"');
end;

procedure WritePasQuoted(var t : text; const s : string);
var
  i : integer;
begin
  write(t,'''');
  for i:=1 to Length(s) do
    if s[i] = '''' then write(t,'''''') else write(t,s[i]);
  write(t,'''');
end;

procedure WriteBasicStrDimReadStub(var data : BufferRec;Lan : integer; name : string;count : longint);
begin
  if (Lan<>GWLan) then writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

  if (Lan = FBLan) or (Lan = AQBLan) then
  begin
    writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'(',count,') As String');
    writeln(data.fText,LineCountToStr(Lan),'For _rmi=0 to ',count-1);
    writeln(data.fText,LineCountToStr(Lan),'   Read ',name,'(_rmi)');
    writeln(data.fText,LineCountToStr(Lan),'Next _rmi');
  end
  else
  begin
    writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'$(',count,')');
    writeln(data.fText,LineCountToStr(Lan),'For i=0 to ',count-1);
    writeln(data.fText,LineCountToStr(Lan),'   Read ',name,'$(i)');
    writeln(data.fText,LineCountToStr(Lan),'Next i');
  end;
end;

//BASIC variables and DIM/READ stubs for properties, called at the END of
//WriteBasicRMInit. GW-BASIC has no RESTORE to a label, so its READs consume
//DATA strictly in file order: these stubs come right after the map hit box
//stubs, and WritePropDataToBuffer runs right after the hit box DATA.
procedure WritePropBasicStubs(var data : BufferRec);
var
  i, kn, Lan : integer;
  MPE : MapExportFormatRec;
  K : KeyDefRec;
  nm : string;
  keysdone : boolean;
begin
  keysdone:=false;
  for i:=0 to MapCoreBase.GetMapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i,MPE);
    if MPE.MapFormat <= 0 then continue;
    if not (MapLanIsBasic(MPE.Lan) or MapLanIsBasicLN(MPE.Lan)) then continue;
    BuildPropExport(i);
    if PEx.nrows = 0 then continue;

    nm:=MPE.Name;
    if nm = '' then nm:='map'+IntToStr(i);
    Lan:=MapLanToBasicLan(MPE.Lan);

    //RMKey, not Key: KEY is a reserved word in GW-BASIC and QBasic
    if not keysdone then
    begin
      for kn:=0 to MapCoreBase.GetKeyDefCount-1 do
      begin
        MapCoreBase.GetKeyDef(kn,K);
        WriteBasicVariable(data,Lan,'RMKey',K.name,K.key);
      end;
      keysdone:=true;
    end;

    WriteBasicVariable(data,Lan,nm+'Prop','Count',PEx.nrows);
    WriteBasicVariable(data,Lan,nm+'Prop','Size',PEx.nrows*PropRowWords);
    WriteBasicVariable(data,Lan,nm+'Prop','Id',i);
    if (Lan = FBLan) or (Lan = AQBLan) then
      WriteFBBasicDimReadStub(data,Lan,nm+'Prop',PEx.nrows*PropRowWords)
    else
      WriteBasicDimReadStub(data,Lan,nm+'Prop',PEx.nrows*PropRowWords);

    if PEx.nstr > 0 then
    begin
      WriteBasicVariable(data,Lan,nm+'Str','Count',PEx.nstr);
      WriteBasicStrDimReadStub(data,Lan,nm+'Str',PEx.nstr);
    end;
  end;
end;

procedure WriteBasicRMInit(var data : BufferRec);
var
 count : integer;
 width,height : integer;
 EO : ImageExportFormatRec;
 nColors : integer;
 Size    : LongInt;
 PalSize : Longint;
 i       : integer;
 DefIntFlag : Boolean;
 MP : MapPropsRec;
 MPE : MapExportFormatRec;
 mwidth,mheight : integer;
 Lan   : integer;
 BLan  : integer;   //concrete BASIC dialect for a generic target
 Format : integer;
 ImageExportFormat : integer;
begin
  DefIntFlag:=True;
  count:=ImageThumbBase.GetCount;
  for i:=0 to count-1 do
  begin
     width:=ImageThumbBase.GetExportWidth(i);
     height:=ImageThumbBase.GetExportHeight(i);
     ImageThumbBase.GetExportOptions(i,EO);
     //start using ImageExportFormat instead of EO.Image because it give us more correct information without addtional condistions to check
     ImageExportFormat:=ImageIndexToFormat(EO.Lan,EO.Image);

     nColors:=ImageThumbBase.GetMaxColor(i)+1;
     size:=GetRESImageSize(width,height,nColors,EO.Lan,EO.Image);

     if (EO.LAN in [QB64Lan,FBLan]) then         //GetRESImageSize works most of the time but not for this - we need to use RayLibImageSize here
     begin
        Case ImageExportFormat of RGBAFuchsiaExportFormat:size:=RayLibImageSize(width,height,RGBASize);
                                   RGBAIndex0ExportFormat:size:=RayLibImageSize(width,height,RGBASize);
                                   RGBACustomExportFormat:size:=RayLibImageSize(width,height,RGBASize);
                                          RGBExportFormat:size:=RayLibImageSize(width,height,RGBSize);
                                  RayLibRGBAFuchsiaExportFormat:size:=RayLibImageSize(width,height,RGBASize);
                                   RayLibRGBAIndex0ExportFormat:size:=RayLibImageSize(width,height,RGBASize);
                                   RayLibRGBACustomExportFormat:size:=RayLibImageSize(width,height,RGBASize);
                                          RayLibRGBExportFormat:size:=RayLibImageSize(width,height,RGBSize);
        end;
     end;


     //Generic Basic and Basic (Line#). The stubs are written for the concrete
     //dialect, which is what decides labels, RESTORE and line numbers. Sizes
     //are in VALUES here, not bytes, because BASIC reads integers.
     if (EO.Lan = BasicLan) or (EO.Lan = BasicLNLan) then
     begin
       BLan:=ConcreteLan(EO.Lan);
       if DefIntFlag then
       begin
         Writeln(data.fText,LineCountToStr(BLan),'DEFINT A-Z');
         DefIntFlag:=False;
       end;

       if EO.Palette > 0 then
       begin
         PalSize:=GetRESPaletteSize(nColors,EO.Lan,EO.Palette);
         WriteBasicVariable(data,BLan,EO.Name+'Pal','Size',PalSize);
         WriteBasicVariable(data,BLan,EO.Name+'Pal','Colors',nColors);
         WriteBasicVariable(data,BLan,EO.Name+'Pal','Id',i);
         WriteBasicDimReadStub(data,BLan,EO.Name+'Pal',PalSize);
       end;

       if ImageExportFormat = IndexedExportFormat then
       begin
         size:=2+longint(width)*height;
         WriteBasicVariable(data,BLan,EO.Name,'Size',size);
         WriteBasicVariable(data,BLan,EO.Name,'Width',width);
         WriteBasicVariable(data,BLan,EO.Name,'Height',height);
         WriteBasicVariable(data,BLan,EO.Name,'Colors',nColors);
         WriteBasicVariable(data,BLan,EO.Name,'Id',i);
         WriteBasicDimReadStub(data,BLan,EO.Name,size);
       end;
     end;

     if (EO.LAN in [BAMLan,ABLan,AQBLan,GWLan,QBLan,QB64Lan,QBJSLan,FBinQBModeLan,FBLan,PBLan]) then
     begin
       if DefIntFlag then
       begin
          if (EO.Lan in [AQBLan,FBLan]) then
          begin
            writeln(data.fText,LineCountToStr(EO.Lan),'Dim As Integer _rmx,_rmy,_rmr,_rmg,_rmb,_rma,_rmi,_rmj');
          end
          else if (EO.Lan = QB64Lan) then
          begin
            if ImageExportFormat in [RayLibRGBAFuchsiaExportFormat,RayLibRGBAIndex0ExportFormat,RayLibRGBACustomExportFormat,RayLibRGBExportFormat] then
            begin
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmx,rmy,rmi,rmj,rmc AS Integer');
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmr, rmg, rmb, rma As _Unsigned _Byte');
            end
            else
            begin
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmx,rmy,rmi,rmj,rmc,rmprevdest AS Integer');
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmr, rmg, rmb, rma As _Unsigned _Byte');
            end;
          end
          else if (EO.Lan = QBJSLan) then
          begin
            if ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBACustomExportFormat,RGBExportFormat] then
            begin
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmx,rmy,rmi,rmj,rmc AS Integer');
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmr, rmg, rmb, rma As _Unsigned _Byte');
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmprevdest');
            end;
          end
          else
          begin
            Writeln(data.fText,LineCountToStr(EO.Lan),'DEFINT A-Z');
          end;
          DefIntFlag:=False;  // we only write this once - we put it here because we don't know which language until we pull the first image
       end;

       //write palette first
       if EO.Palette > 0 then
       begin
         PalSize:=GetRESPaletteSize(nColors,EO.Lan,EO.Palette);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Pal','Size',PalSize);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Pal','Colors',nColors);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Pal','Id',i);
         if ((EO.Lan=ABLan) or (EO.Lan=AQBLan)) and  (EO.Palette=5) then   // uses SINGLE(!) variable for palette in n.nn format
         begin
           WriteAmigaBasicPaletteReadStub(data,EO.Lan,EO.Name+'Pal',PalSize);
         end
         else
         begin
           //ColorVGADACFormat comes through here too - it is a six bit array in
           //a RES include, so it loads with the normal DIM/READ stub.
           WriteBasicDimReadStub(data,EO.Lan,EO.Name+'Pal',PalSize);
         end;
       end;

       if ImageExportFormat > 0 then
       begin
          if (ImageExportFormat = PutImageExportFormat) and (EO.Lan in [BAMLan,FBinQBModeLan,ABLan,QBLan,GWLan,PBLan]) then size := size div 2;  //we writing basic integers for Image format 1
          if (ImageExportFormat = RGBExportFormat) and (EO.Lan =BAMLan) then size := size div 2;  //we writing basic integers for BAM RGB format
          if (ImageExportFormat = MouseImageExportFormat) and (EO.Lan in [FBinQBModeLan,QBLan,GWLan,PBLan]) then size := size div 2;  //we writing basic integers for Image format 1

          WriteBasicVariable(data,EO.Lan,EO.Name,'Size',size);
          if ((EO.Lan = QB64Lan) or (EO.Lan = QBJSLan) or (EO.Lan = FBLan)) then
          begin
            if  ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBACustomExportFormat,RGBExportFormat,RayLibRGBAFuchsiaExportFormat,RayLibRGBAIndex0ExportFormat,RayLibRGBExportFormat] then
            begin
               Format:=7;
               if ImageExportFormat in [RGBExportFormat,rayLibRGBExportFormat] then Format:=4;
               WriteBasicVariable(data,EO.Lan,EO.Name,'Format',Format);   // for QB64/Freebasic RayLib formats
            end;
          end;
          if (ImageExportFormat = RGBExportFormat) and (EO.Lan = BAMLan) then
          begin
            Format:=4;
            WriteBasicVariable(data,EO.Lan,EO.Name,'Format',Format);
          end;

          WriteBasicVariable(data,EO.Lan,EO.Name,'Width',width);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Height',height);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Colors',nColors);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Id',i);

          if (EO.Lan=ABLan) and (ImageExportFormat in [AmigaBOBExportFormat,AmigaVSpriteExportFormat]) then   //these are stored in strings so we need a diffent way
          begin
            WriteAmigaBasicBobVSprite(data,EO.Lan,EO.Name,size);
          end
          else if (EO.Lan=AQBLan) then
          begin
            WriteBasicVariable(data,EO.Lan,EO.Name,'Depth',nColorsToBitPlanes(nColors));
            WriteAQBImageStub(data,EO.Lan,EO.Image,EO.Mask,EO.Name,size);
          end
          else if (EO.Lan=FBLan) then
          begin
           if  (ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBExportFormat]) then
           begin
             WriteFBBasicReadStub(data,EO.Lan,EO.Name,size);   //FreeBASIC - not QB mode - RGB/RGBA Load code
           end;
          end
          else if (EO.Lan=QB64Lan) then
          begin
            if  (ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBACustomExportFormat,RGBExportFormat]) then
            begin
              WriteQB64ReadStub(data,EO.Lan,EO.Name,size);   //QB64 - Use Internal Graphics
            end
            else if  (ImageExportFormat in [RayLibRGBAFuchsiaExportFormat,RayLibRGBAIndex0ExportFormat,RayLibRGBACustomExportFormat,RayLibRGBExportFormat]) then
            begin
              WriteQB64RayLibReadStub(data,EO.Lan,EO.Name,size);  //QB64 - Use RayLib Graphics
            end;
          end
          else if (EO.Lan=BAMLan) then
          begin
              WriteBasicDimReadStub(data,EO.Lan,EO.Name,size);   //loading stub for putimage code.
          end
          else if (EO.Lan=QBJSLan) then
          begin
            if  (ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBACustomExportFormat,RGBExportFormat]) then
            begin
              WriteQBJSReadStub(data,EO.Lan,EO.Name,size);   //QBJS
            end;
          end
          else
          begin
            if (ImageExportFormat in[PutImageExportFormat,MouseImageExportFormat]) then WriteBasicDimReadStub(data,EO.Lan,EO.Name,size);   //loading stub for putimage code.
          end;
       end;

      if (ImageExportFormat = PutImageExportFormat) and (EO.Mask > 0)  then    //we have putimage mask - except for
      begin
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Size',size);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Width',width);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Height',height);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Colors',nColors);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Id',i);
         if (EO.LAN<>AQBLan) then WriteBasicDimReadStub(data,EO.Lan,EO.Name+'Mask',size);  //aqb does need this. it uses different format for mask
       end;
     end;
  end;


  //write map info
 count:=MapCoreBase.GetMapCount;
 For i:=0 to count-1 do
 begin
   MapCoreBase.GetMapProps(i,MP);
   MapCoreBase.GetMapExportProps(i,MPE);
   mwidth:=MapCoreBase.GetExportWidth(i);
   mheight:=MapCoreBase.GetExportHeight(i);
   size:=mwidth*mheight+4;

   if (MapLanIsBasic(MPE.Lan) or MapLanIsBasicLN(MPE.Lan)) and (MPE.MapFormat=1) then
   begin
     Lan:=QBLan;
     if (MPE.Lan = BasicLnLan) or (MPE.Lan = GWBasicLan) then
     begin
       Lan:=GWLan;
     end
     else if MPE.Lan = FBBasicLan then
     begin
       Lan:=FBLan;
     end
     else if MPE.Lan = AQBBasicLan then
     begin
       Lan:=AQBLan;
     end
     else if MPE.Lan = BAMBasicLan then
     begin
        Lan:=BAMLan;
     end;

     WriteBasicVariable(data,Lan,MPE.Name+'Map','Size',size);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','Width',mwidth);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','Height',mheight);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','TileWidth',MP.tilewidth);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','TileHeight',MP.tileheight);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','Id',i);
     if (Lan = FBLan) or (Lan = AQBLan) then
     begin
        WriteFBBasicDimReadStub(data,Lan,MPE.Name+'Map',size);
     end
     else
     begin
        WriteBasicDimReadStub(data,Lan,MPE.Name+'Map',size)
     end;
   end;
 end;

 //write hitbox info for maps that have hitboxes
 For i:=0 to count-1 do
 begin
   MapCoreBase.GetMapExportProps(i,MPE);
   if (MPE.MapFormat > 0) and (MapCoreBase.GetHitBoxCount(i) > 0) and
      (MapLanIsBasic(MPE.Lan) or MapLanIsBasicLN(MPE.Lan)) then
   begin
     Lan:=QBLan;
     if (MPE.Lan = BasicLnLan) or (MPE.Lan = GWBasicLan) then Lan:=GWLan
     else if MPE.Lan = FBBasicLan then Lan:=FBLan
     else if MPE.Lan = AQBBasicLan then Lan:=AQBLan
     else if MPE.Lan = BAMBasicLan then Lan:=BAMLan;

     //6 per box now (id,value,x,y,x2,y2) - must match the DATA the
     //hit box writer emits or the READ loop runs past the end
     size:=MapCoreBase.GetHitBoxCount(i) * 6;
     WriteBasicVariable(data,Lan,MPE.Name+'HitBox','Count',MapCoreBase.GetHitBoxCount(i));
     WriteBasicVariable(data,Lan,MPE.Name+'HitBox','Size',size);
     WriteBasicVariable(data,Lan,MPE.Name+'HitBox','Id',i);
     if (Lan = FBLan) or (Lan = AQBLan) then
       WriteFBBasicDimReadStub(data,Lan,MPE.Name+'HitBox',size)
     else
       WriteBasicDimReadStub(data,Lan,MPE.Name+'HitBox',size);
   end;
 end;

 //properties - MUST stay after the hit box stubs, see WritePropBasicStubs
 WritePropBasicStubs(data);
end;



//Map hit boxes as source code. Coordinates are TILES here - the sprite
//version emits pixels.
//
//Emitted for EVERY language family. This used to be BASIC only, so a map
//exported to C or Pascal silently lost its hit boxes.
procedure WriteHitBoxDataToBuffer(var data : BufferRec);
var
  i, j, hbcount : integer;
  HB : HitBoxRec;
  MPE : MapExportFormatRec;
  Lan : integer;
  nm, line : string;
begin
  for i:=0 to MapCoreBase.GetMapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i, MPE);
    hbcount:=MapCoreBase.GetHitBoxCount(i);
    if (MPE.MapFormat <= 0) or (hbcount = 0) then continue;

    nm:=MPE.Name;
    if nm = '' then nm:='map'+IntToStr(i);

    if MapLanIsC(MPE.Lan) then
    begin
      writeln(data.fText,'/* hit boxes for ',nm,' - tiles, id,value,x,y,x2,y2 */');
      writeln(data.fText,'#define ',nm,'_hitbox_count ',hbcount);
      writeln(data.fText,'const int ',nm,'_hitbox[',hbcount*6,'] = {');
      for j:=0 to hbcount-1 do
      begin
        MapCoreBase.GetHitBox(i,j,HB);
        line:='  '+IntToStr(HB.id)+','+IntToStr(HB.value)+','+
                   IntToStr(HB.x)+','+IntToStr(HB.y)+','+
                   IntToStr(HB.x2)+','+IntToStr(HB.y2);
        if j < hbcount-1 then line:=line+',';
        writeln(data.fText,line);
      end;
      writeln(data.fText,'};');
    end
    else if MapLanIsPascal(MPE.Lan) then
    begin
      writeln(data.fText,'{ hit boxes for ',nm,' - tiles, id,value,x,y,x2,y2 }');
      writeln(data.fText,'const');
      writeln(data.fText,'  ',nm,'_hitbox_count = ',hbcount,';');
      writeln(data.fText,'  ',nm,'_hitbox : array[0..',hbcount*6-1,'] of integer = (');
      for j:=0 to hbcount-1 do
      begin
        MapCoreBase.GetHitBox(i,j,HB);
        line:='    '+IntToStr(HB.id)+','+IntToStr(HB.value)+','+
                     IntToStr(HB.x)+','+IntToStr(HB.y)+','+
                     IntToStr(HB.x2)+','+IntToStr(HB.y2);
        if j < hbcount-1 then line:=line+',' else line:=line+');';
        writeln(data.fText,line);
      end;
    end
    else if MapLanIsJS(MPE.Lan) then
    begin
      writeln(data.fText,'// hit boxes for ',nm,' - tiles');
      writeln(data.fText,'const ',nm,'HitBoxes = [');
      for j:=0 to hbcount-1 do
      begin
        MapCoreBase.GetHitBox(i,j,HB);
        line:='  {id:'+IntToStr(HB.id)+', value:'+IntToStr(HB.value)+
              ', x:'+IntToStr(HB.x)+', y:'+IntToStr(HB.y)+
              ', x2:'+IntToStr(HB.x2)+', y2:'+IntToStr(HB.y2)+
              ', w:'+IntToStr(HB.x2-HB.x+1)+', h:'+IntToStr(HB.y2-HB.y+1)+'}';
        if j < hbcount-1 then line:=line+',';
        writeln(data.fText,line);
      end;
      writeln(data.fText,'];');
    end
    else
    begin
      Lan:=QBLan;
      if (MPE.Lan = BasicLnLan) or (MPE.Lan = GWBasicLan) then Lan:=GWLan
      else if MPE.Lan = FBBasicLan then Lan:=FBLan
      else if MPE.Lan = AQBBasicLan then Lan:=AQBLan
      else if MPE.Lan = BAMBasicLan then Lan:=BAMLan;

      writeln(data.fText,LineCountToStr(Lan),'''HitBox data for ',nm,' (tiles)');
      WriteBasicVariable(data,Lan,nm+'HitBox','Count',hbcount);
      WriteBasicLabel(data,Lan,nm+'HitBox');
      for j:=0 to hbcount-1 do
      begin
        MapCoreBase.GetHitBox(i, j, HB);
        writeln(data.fText,LineCountToStr(Lan),'DATA ',HB.id,',',HB.value,',',HB.x,',',HB.y,',',HB.x2,',',HB.y2);
      end;
    end;
  end;
end;

//Key constants, once per language family - keys are project wide.
procedure WritePropKeys(var data : BufferRec; family : integer);   //1 C, 2 Pascal, 3 JS
var
  i : integer;
  K : KeyDefRec;
begin
  case family of
    1 : writeln(data.fText,'/* property keys - shared by every map */');
    2 : begin
          writeln(data.fText,'{ property keys - shared by every map }');
          writeln(data.fText,'const');
        end;
    3 : begin
          writeln(data.fText,'// property keys - shared by every map');
          write(data.fText,'const RMKey = {');
        end;
  end;
  for i:=0 to MapCoreBase.GetKeyDefCount-1 do
  begin
    MapCoreBase.GetKeyDef(i,K);
    case family of
      1 : writeln(data.fText,'#define RMKEY_',K.name,' ',K.key);
      2 : writeln(data.fText,'  RMKey_',K.name,' = ',K.key,';');
      3 : begin
            if i > 0 then write(data.fText,', ');
            write(data.fText,K.name,':',K.key);
          end;
    end;
  end;
  if family = 3 then writeln(data.fText,'};');
end;

//Map properties as source code, for every language family. Called straight
//after WriteHitBoxDataToBuffer - see WritePropBasicStubs for why the
//position matters to GW-BASIC.
procedure WritePropDataToBuffer(var data : BufferRec);
var
  i, r, s2, Lan : integer;
  MPE : MapExportFormatRec;
  nm : string;
  keysC, keysPas, keysJS : boolean;
begin
  keysC:=false;
  keysPas:=false;
  keysJS:=false;
  for i:=0 to MapCoreBase.GetMapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i,MPE);
    if MPE.MapFormat <= 0 then continue;
    BuildPropExport(i);
    if PEx.nrows = 0 then continue;

    nm:=MPE.Name;
    if nm = '' then nm:='map'+IntToStr(i);

    if MapLanIsC(MPE.Lan) then
    begin
      if not keysC then begin WritePropKeys(data,1); keysC:=true; end;
      writeln(data.fText,'/* properties for ',nm,' - id,idvalue,kind,a,b,key,value */');
      writeln(data.fText,'#define ',nm,'_prop_count ',PEx.nrows);
      writeln(data.fText,'const int ',nm,'_prop[',PEx.nrows*PropRowWords,'] = {');
      for r:=0 to PEx.nrows-1 do
      begin
        write(data.fText,'  ');
        WritePropRowNumbers(data.fText,r);
        if r < PEx.nrows-1 then writeln(data.fText,',') else writeln(data.fText);
      end;
      writeln(data.fText,'};');
      if PEx.nstr > 0 then
      begin
        writeln(data.fText,'#define ',nm,'_str_count ',PEx.nstr);
        writeln(data.fText,'const char *',nm,'_str[',PEx.nstr,'] = {');
        for s2:=0 to PEx.nstr-1 do
        begin
          write(data.fText,'  ');
          WriteCQuoted(data.fText,PEx.strs[s2]);
          if s2 < PEx.nstr-1 then writeln(data.fText,',') else writeln(data.fText);
        end;
        writeln(data.fText,'};');
      end;
    end
    else if MapLanIsPascal(MPE.Lan) then
    begin
      if not keysPas then begin WritePropKeys(data,2); keysPas:=true; end;
      writeln(data.fText,'{ properties for ',nm,' - id,idvalue,kind,a,b,key,value }');
      writeln(data.fText,'const');
      writeln(data.fText,'  ',nm,'_prop_count = ',PEx.nrows,';');
      writeln(data.fText,'  ',nm,'_prop : array[0..',PEx.nrows*PropRowWords-1,'] of integer = (');
      for r:=0 to PEx.nrows-1 do
      begin
        write(data.fText,'    ');
        WritePropRowNumbers(data.fText,r);
        if r < PEx.nrows-1 then writeln(data.fText,',') else writeln(data.fText,');');
      end;
      if PEx.nstr > 0 then
      begin
        writeln(data.fText,'  ',nm,'_str_count = ',PEx.nstr,';');
        writeln(data.fText,'  ',nm,'_str : array[0..',PEx.nstr-1,'] of string[',PExMaxStrLen,'] = (');
        for s2:=0 to PEx.nstr-1 do
        begin
          write(data.fText,'    ');
          WritePasQuoted(data.fText,PEx.strs[s2]);
          if s2 < PEx.nstr-1 then writeln(data.fText,',') else writeln(data.fText,');');
        end;
      end;
    end
    else if MapLanIsJS(MPE.Lan) then
    begin
      if not keysJS then begin WritePropKeys(data,3); keysJS:=true; end;
      writeln(data.fText,'// properties for ',nm);
      writeln(data.fText,'const ',nm,'Props = [');
      for r:=0 to PEx.nrows-1 do
      begin
        write(data.fText,'  {id:',PEx.rows[r*PropRowWords],
                         ', idvalue:',PEx.rows[r*PropRowWords+1],
                         ', kind:',PEx.rows[r*PropRowWords+2],
                         ', a:',PEx.rows[r*PropRowWords+3],
                         ', b:',PEx.rows[r*PropRowWords+4],
                         ', key:',PEx.rows[r*PropRowWords+5],
                         ', value:',PEx.rows[r*PropRowWords+6],'}');
        if r < PEx.nrows-1 then writeln(data.fText,',') else writeln(data.fText);
      end;
      writeln(data.fText,'];');
      if PEx.nstr > 0 then
      begin
        writeln(data.fText,'const ',nm,'Strings = [');
        for s2:=0 to PEx.nstr-1 do
        begin
          write(data.fText,'  ');
          WriteCQuoted(data.fText,PEx.strs[s2]);
          if s2 < PEx.nstr-1 then writeln(data.fText,',') else writeln(data.fText);
        end;
        writeln(data.fText,'];');
      end;
    end
    else
    begin
      //BASIC. LineCountToStr hands out one GW-BASIC line number per call, so
      //it is called exactly once per output line.
      Lan:=MapLanToBasicLan(MPE.Lan);
      writeln(data.fText,LineCountToStr(Lan),'''Property data for ',nm,' - id,idvalue,kind,a,b,key,value');
      WriteBasicLabel(data,Lan,nm+'Prop');
      for r:=0 to PEx.nrows-1 do
      begin
        write(data.fText,LineCountToStr(Lan),'DATA ');
        WritePropRowNumbers(data.fText,r);
        writeln(data.fText);
      end;
      if PEx.nstr > 0 then
      begin
        writeln(data.fText,LineCountToStr(Lan),'''String data for ',nm);
        WriteBasicLabel(data,Lan,nm+'Str');
        //no escaping needed: the editor never allows a double quote
        for s2:=0 to PEx.nstr-1 do
        begin
          write(data.fText,LineCountToStr(Lan),'DATA "');
          write(data.fText,PEx.strs[s2]);
          writeln(data.fText,'"');
        end;
      end;
    end;
  end;
end;

//Map paths as source code, for every language family.
//
//The array itself is built by MapCoreBase.BuildPathExportArray, which the
//standalone "Path Data Statements" menu export uses too - one builder means
//the two can never disagree about the layout.
procedure WritePathDataToBuffer(var data : BufferRec);
var
  i,j,nv,per,a,b2,Lan : integer;
  MPE : MapExportFormatRec;
  //longint, NOT integer: this unit is {$MODE TP} where integer is 16 bit,
  //but mapcore is objfpc where it is 32 bit, and the var parameter must
  //match the declared type exactly.
  vals : array[0..8191] of longint;
  nm, line : string;
begin
  for i:=0 to MapCoreBase.GetMapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i, MPE);
    if MPE.MapFormat <= 0 then continue;
    if MapCoreBase.PathExportCount(i) = 0 then continue;

    nv:=MapCoreBase.BuildPathExportArray(i,vals);
    if nv <= 0 then continue;

    nm:=MPE.Name;
    if nm = '' then nm:='map'+IntToStr(i);

    if MapLanIsC(MPE.Lan) then
    begin
      writeln(data.fText,'/* paths for ',nm,' - [0]=count, [1..count]=header offsets */');
      writeln(data.fText,'#define ',nm,'_path_size ',nv);
      writeln(data.fText,'const int ',nm,'_paths[',nv,'] = {');
      per:=12; a:=0;
      while a < nv do
      begin
        line:='  ';
        for b2:=a to a+per-1 do
        begin
          if b2 >= nv then break;
          if b2 > a then line:=line+',';
          line:=line+IntToStr(vals[b2]);
        end;
        if (a+per) < nv then line:=line+',';
        writeln(data.fText,line);
        a:=a+per;
      end;
      writeln(data.fText,'};');
    end
    else if MapLanIsPascal(MPE.Lan) then
    begin
      writeln(data.fText,'{ paths for ',nm,' - [0]=count, [1..count]=header offsets }');
      writeln(data.fText,'const');
      writeln(data.fText,'  ',nm,'_path_size = ',nv,';');
      writeln(data.fText,'  ',nm,'_paths : array[0..',nv-1,'] of integer = (');
      per:=12; a:=0;
      while a < nv do
      begin
        line:='    ';
        for b2:=a to a+per-1 do
        begin
          if b2 >= nv then break;
          if b2 > a then line:=line+',';
          line:=line+IntToStr(vals[b2]);
        end;
        if (a+per) < nv then line:=line+',' else line:=line+');';
        writeln(data.fText,line);
        a:=a+per;
      end;
    end
    else if MapLanIsJS(MPE.Lan) then
    begin
      writeln(data.fText,'// paths for ',nm,' - [0]=count, [1..count]=header offsets');
      writeln(data.fText,'const ',nm,'Paths = [');
      per:=12; a:=0;
      while a < nv do
      begin
        line:='  ';
        for b2:=a to a+per-1 do
        begin
          if b2 >= nv then break;
          if b2 > a then line:=line+',';
          line:=line+IntToStr(vals[b2]);
        end;
        if (a+per) < nv then line:=line+',';
        writeln(data.fText,line);
        a:=a+per;
      end;
      writeln(data.fText,'];');
    end
    else
    begin
      Lan:=QBLan;
      if (MPE.Lan = BasicLnLan) or (MPE.Lan = GWBasicLan) then Lan:=GWLan
      else if MPE.Lan = FBBasicLan then Lan:=FBLan
      else if MPE.Lan = AQBBasicLan then Lan:=AQBLan
      else if MPE.Lan = BAMBasicLan then Lan:=BAMLan;

      writeln(data.fText,LineCountToStr(Lan),'''Path data for ',nm);
      WriteBasicVariable(data,Lan,nm+'Path','Size',nv);
      WriteBasicLabel(data,Lan,nm+'Path');
      per:=10; a:=0;
      while a < nv do
      begin
        line:='';
        for b2:=a to a+per-1 do
        begin
          if b2 >= nv then break;
          if b2 > a then line:=line+',';
          line:=line+IntToStr(vals[b2]);
        end;
        //DATA lines must NOT carry a trailing comma
        writeln(data.fText,LineCountToStr(Lan),'DATA ',line);
        a:=a+per;
      end;
    end;
  end;
end;

//ImageExportFormatRec.Lan uses the SPRITE compiler constants (TPLan, TCLan,
//QBLan ...), which are a DIFFERENT numbering from the map ones (TPPascalLan,
//TCCLan, QBBasicLan ...). Passing a sprite Lan to MapLanIsPascal silently
//returns false, which is how Turbo Pascal sprites ended up emitting BASIC.
function SprLanIsC(Lan : integer) : boolean;
begin
  SprLanIsC:=(Lan=TCLan) or (Lan=QCLan) or (Lan=OWLan) or (Lan=gccLan) or
             (Lan=ACLan);
end;

function SprLanIsPascal(Lan : integer) : boolean;
begin
  SprLanIsPascal:=(Lan=TPLan) or (Lan=QPLan) or (Lan=FPLan) or (Lan=TMTLan) or
                  (Lan=APLan);
end;

function SprLanIsJS(Lan : integer) : boolean;
begin
  SprLanIsJS:=(Lan=QBJSLan);
end;

//Sprite hit boxes as source code. Coordinates are PIXELS within the sprite,
//where the map version emits tiles.
//
//Emitted for EVERY language family, not just BASIC. Sprites export to C,
//Pascal and JS as well, and those targets were silently getting no hit box
//data at all.
//
//startindex/count let the single sprite "Export Include" path emit just its
//own sprite - that path skips the whole-project block below.
procedure WriteSpriteHitBoxDataToBuffer(var data : BufferRec; startindex,stopcount : integer);
var
  i, j, hbcount : integer;
  HB : HitBoxRec;
  EO : ImageExportFormatRec;
  Lan : integer;
  nm, line : string;
begin
  for i:=startindex to stopcount-1 do
  begin
    ImageThumbBase.GetExportOptions(i, EO);
    hbcount:=ImageThumbBase.GetHitBoxCount(i);
    if (EO.Image <= 0) or (hbcount = 0) then continue;

    nm:=EO.Name;
    if nm = '' then nm:='sprite'+IntToStr(i);

    if SprLanIsC(EO.Lan) then
    begin
      writeln(data.fText,'/* hit boxes for ',nm,' - pixels, id,value,x,y,x2,y2 */');
      writeln(data.fText,'#define ',nm,'_hitbox_count ',hbcount);
      writeln(data.fText,'const int ',nm,'_hitbox[',hbcount*6,'] = {');
      for j:=0 to hbcount-1 do
      begin
        ImageThumbBase.GetHitBox(i,j,HB);
        line:='  '+IntToStr(HB.id)+','+IntToStr(HB.value)+','+
                   IntToStr(HB.x)+','+IntToStr(HB.y)+','+
                   IntToStr(HB.x2)+','+IntToStr(HB.y2);
        if j < hbcount-1 then line:=line+',';
        writeln(data.fText,line);
      end;
      writeln(data.fText,'};');
    end
    else if SprLanIsPascal(EO.Lan) then
    begin
      writeln(data.fText,'{ hit boxes for ',nm,' - pixels, id,value,x,y,x2,y2 }');
      writeln(data.fText,'const');
      writeln(data.fText,'  ',nm,'_hitbox_count = ',hbcount,';');
      writeln(data.fText,'  ',nm,'_hitbox : array[0..',hbcount*6-1,'] of integer = (');
      for j:=0 to hbcount-1 do
      begin
        ImageThumbBase.GetHitBox(i,j,HB);
        line:='    '+IntToStr(HB.id)+','+IntToStr(HB.value)+','+
                     IntToStr(HB.x)+','+IntToStr(HB.y)+','+
                     IntToStr(HB.x2)+','+IntToStr(HB.y2);
        if j < hbcount-1 then line:=line+',' else line:=line+');';
        writeln(data.fText,line);
      end;
    end
    else if SprLanIsJS(EO.Lan) then
    begin
      writeln(data.fText,'// hit boxes for ',nm,' - pixels');
      writeln(data.fText,'const ',nm,'HitBoxes = [');
      for j:=0 to hbcount-1 do
      begin
        ImageThumbBase.GetHitBox(i,j,HB);
        line:='  {id:'+IntToStr(HB.id)+', value:'+IntToStr(HB.value)+
              ', x:'+IntToStr(HB.x)+', y:'+IntToStr(HB.y)+
              ', x2:'+IntToStr(HB.x2)+', y2:'+IntToStr(HB.y2)+
              ', w:'+IntToStr(HB.x2-HB.x+1)+', h:'+IntToStr(HB.y2-HB.y+1)+'}';
        if j < hbcount-1 then line:=line+',';
        writeln(data.fText,line);
      end;
      writeln(data.fText,'];');
    end
    else
    begin
      //BASIC, with or without line numbers. EO.Lan is ALREADY a sprite
      //compiler constant, so it can be used directly - the old code compared
      //it against map constants and always fell through to QBLan.
      Lan:=EO.Lan;
      if Lan = 0 then Lan:=QBLan;

      writeln(data.fText,LineCountToStr(Lan),'''HitBox data for ',nm,' (pixels)');
      WriteBasicVariable(data,Lan,nm+'HitBox','Count',hbcount);
      WriteBasicLabel(data,Lan,nm+'HitBox');
      for j:=0 to hbcount-1 do
      begin
        ImageThumbBase.GetHitBox(i, j, HB);
        writeln(data.fText,LineCountToStr(Lan),'DATA ',HB.id,',',HB.value,',',HB.x,',',HB.y,',',HB.x2,',',HB.y2);
      end;
    end;
  end;
end;

//exportonlyindex means export only the index, none of the other images.palette maps
Function RESIncludeWork(filename:string; index : integer; ExportOnlyIndex : Boolean):word;
var
 data    : BufferRec;
 EO      : ImageExportFormatRec;
 ImageExportFormat : integer;
 i       : integer;
 count   : integer;
 width   : integer;
 height  : integer;
 StartIndex : integer;
begin
 SetThumbActive;   // we are getting pixel data from core object ThumbBase
 SetGWStartLineNumber(1000); // this is only used for exporting GWBASIC/PCBASIC code

 assign(data.fText,filename);
{$I-}
 rewrite(data.fText);

 if ExportOnlyIndex then
 begin
   StartIndex:=index;
   count:=StartIndex+1;
 end
 else
 begin
   WriteBasicRMinit(data);      //generates the dims, variable assignments,  and loader code for all the basic languages
   StartIndex:=0;
   count:=ImageThumbBase.GetCount;
 end;

 for i:=StartIndex to count-1 do
 begin
   width:=ImageThumbBase.GetExportWidth(i);
   height:=ImageThumbBase.GetExportHeight(i);
   ImageThumbBase.GetExportOptions(i,EO);
   ImageExportFormat:=ImageIndexToFormat(EO.Lan,EO.Image);
   SetThumbIndex(i);  //important - otherwise the GetMaxColor and GetPixel functions will not get the right data

   if (EO.Lan>0) and (EO.Palette > 0) then
   begin
     //ConcreteLan: the generic targets borrow QBasic/GW-BASIC/TC/TP syntax
     WriteBasicLabel(data,ConcreteLan(EO.Lan),EO.Name+'Pal');
     WritePalToArrayBuffer(data,EO.Name+'Pal',ConcreteLan(EO.Lan),EO.Palette);
   end;

   case EO.Lan of TPLan,TMTLan,TCLan,FPLan,FBinQBModeLan,BAMLan,QBLan,GWLan,QCLan,QPLan,PBLan,OWLan:
        begin
//          if EO.Image = 1 then   //put image format

          if ImageExportFormat = PutImageExportFormat then   //put image format
          begin
            WriteBasicLabel(data,EO.Lan,EO.Name);  //checks if it's basic lan then writes lable - ignoes other lan
            WriteXGFCodeToBuffer(data,0,0,width-1,height-1,EO.Lan,0,EO.Name);
          end;

//          if (EO.Image = 1) and (EO.Mask=1) and (EO.Lan<>AQBLan) then    //put image mask
          if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) and (EO.Lan<>AQBLan) then    //put image mask
          begin
            WriteBasicLabel(data,EO.Lan,EO.Name+'Mask');
            WriteXGFCodeToBuffer(data,0,0,width-1,height-1,EO.Lan,1,EO.Name+'Mask');
          end;

          if (ImageExportFormat = MouseImageExportFormat) then
          begin
            WriteBasicLabel(data,EO.Lan,EO.Name);
            WriteMShapeCodeToBuffer(data,0,0,EO.Lan,i,EO.Name);
          end;
        end;
   end;

//   if (EO.LAN=TPLan) AND (EO.Image = 2) then  // XLib LBM
  //generic Basic / Basic Line# / C / Pascal - indexed pixels
  if (EO.Lan in [BasicLan,BasicLNLan,CLan,PascalLan]) and (ImageExportFormat = IndexedExportFormat) then
  begin
    WriteBasicLabel(data,ConcreteLan(EO.Lan),EO.Name);
    WriteIndexedCode(data.fText,0,0,width-1,height-1,EO.Lan,EO.Name,false);
  end;

  if (EO.LAN=TPLan) AND (ImageExportFormat = XLibLBMExportFormat) then  // XLib LBM
  begin
     WriteTPLBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TPLan) AND (ImageExportFormat = XLibPBMExportFormat) then // XLib PBM
   begin
     WriteTPPBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TCLan) AND (ImageExportFormat = XLibLBMExportFormat) then  // XLib LBM
   begin
     WriteTCLBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TCLan) AND (ImageExportFormat = XLibPBMExportFormat) then // XLib PBM
   begin
     WriteTCPBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=ABLan) and (ImageExportFormat = PutImageExportFormat) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicXGFDataBuffer(0,0,width-1,height-1,0,data,EO.Name);        // put
   end;
   if (EO.LAN=ABLan) and (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name+'Mask');
     WriteAmigaBasicXGFDataBuffer(0,0,width-1,height-1,1,data,EO.Name+'Mask');        // mask
   end;

   if (EO.LAN=ABLan) and (ImageExportFormat = AmigaBOBExportFormat) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicBobDataBuffer(0,0,width-1,height-1,data,EO.Name,false); //bob
   end;
   if (EO.LAN=ABLan) and (ImageExportFormat = AmigaVSpriteExportFormat) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicBobDataBuffer(0,0,width-1,height-1,data,EO.Name,true); // vsprite
   end;

   if (EO.LAN=ACLan) and (ImageExportFormat = AmigaBOBExportFormat) then WriteAmigaCBobCodeToBuffer(0,0,width-1,height-1,EO.Name,data,false);        // bob
   if (EO.LAN=ACLan) and (ImageExportFormat = AmigaVSpriteExportFormat) then WriteAmigaCBobCodeToBuffer(0,0,width-1,height-1,EO.Name,data,true);  //vsprite

   if (EO.LAN=APLan) and (ImageExportFormat = AmigaBOBExportFormat) then WriteAmigaPascalBobCodeToBuffer(0,0,height-1,width-1,EO.Name,data,false);        // bob
   if (EO.LAN=APLan) and (ImageExportFormat = AmigaVSpriteExportFormat) then WriteAmigaPascalBobCodeToBuffer(0,0,height-1,width-1,EO.Name,data,true);  //vsprite

   if (EO.LAN=AQBLan) and (ImageExportFormat in [AmigaBOBExportFormat,AmigaVSpriteExportFormat,PutImageExportFormat]) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAQBBitMapCodeToBuffer(data.fText,0,0,height-1,width-1,EO.Name);
   end;

   if (EO.LAN=BAMLan) and (ImageExportFormat = RGBExportFormat) then
   begin
        WriteBasicLabel(data,EO.Lan,EO.Name);
        WriteRGBXGFCodeToBuffer(data,0,0,height-1,width-1,EO.Lan,EO.Mask,EO.Name);
    end;

   //RGBA/RayLib formats
   if (EO.Lan in [FPLan,QB64Lan,QBJSLan,FBLan,gccLan]) and (ImageExportFormat in [RGBAFuchsiaExportFormat,
                                                                          RGBAIndex0ExportFormat,
                                                                          RGBACustomExportFormat,
                                                                          RGBExportFormat,
                                                                          RayLibRGBAFuchsiaExportFormat,
                                                                          RayLibRGBAIndex0ExportFormat,
                                                                          RayLibRGBACustomExportFormat,
                                                                          RayLibRGBExportFormat]) then
   begin
     if (EO.Lan in [QB64Lan,QBJSLan,FBLan]) then WriteBasicLabel(data,EO.Lan,EO.Name);
     Case ImageExportFormat of RGBAFuchsiaExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,1,EO.Name);
                                RGBAIndex0ExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,2,EO.Name);
                                RGBACustomExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,4,EO.Name);
                                       RGBExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,3,EO.Name);
                         RayLibRGBAFuchsiaExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,1,EO.Name);
                          RayLibRGBAIndex0ExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,2,EO.Name);
                          RayLibRGBACustomExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,4,EO.Name);
                                 RayLibRGBExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,3,EO.Name);
     end;
   end;
 end;

 if ExportOnlyIndex = false then     //export the maps  and  sprite animations
 begin
     WriteMapsCodeToBuffer(data.fText);
     WriteHitBoxDataToBuffer(data);
     //properties right after hit boxes and BEFORE paths - GW-BASIC reads DATA
     //in file order, and the RMInit stubs expect them here
     WritePropDataToBuffer(data);
     WritePathDataToBuffer(data);
     WriteSpriteHitBoxDataToBuffer(data,0,ImageThumbBase.GetCount);
     WriteAllAnimationCodeToBuffer(data.fText);
 end
 else
 begin
     //single sprite export. The block above is skipped, so its hit boxes
     //would otherwise be left out entirely.
     WriteSpriteHitBoxDataToBuffer(data,StartIndex,count);
 end;
 WritePascalIncludeEnd(data.fText,filename);   //only if a procedure re-opened const
 close(data.fText);
 {$I+}
 RESIncludeWork:=IOResult;
end;

//RES Text Include, and the single-image include from a thumbnail. With the
//Export menu's assembler option on, Pascal images and maps are written as
//assembler procedures in INCLUDE MODE: the file still goes inside your const
//section as before - each procedure re-opens const after it, and the file
//ends with one constant so it never ends on a bare const. See rmcodegen.
Function RESInclude(filename:string; index : integer; ExportOnlyIndex : Boolean):word;
var
  SaveInclude : boolean;
begin
  SaveInclude:=PascalAsmInclude;
  PascalAsmInclude:=true;
  PascalAsmReopened:=false;
  RESInclude:=RESIncludeWork(filename,index,ExportOnlyIndex);
  PascalAsmInclude:=SaveInclude;
end;


//dumps the frame data for every export-enabled animation into the RES
//binary. layout per animation: frame count (word) followed by each
//frame's image index (word) - matches the size written in the header
procedure ResExportAnimations(var F : File);
var
  AnimExport : AnimExportFormatRec;
  i, j, fcount : integer;
  w : word;
begin
  for i:=0 to AnimateBase.GetAnimationCount-1 do
  begin
    AnimateBase.GetAnimExportProps(i,AnimExport);
    if AnimExport.AnimateFormat > 0 then
    begin
      fcount:=AnimateBase.GetFrameCount(i);
      w:=fcount;
      {$I-}
      Blockwrite(F,w,sizeof(w));
      for j:=0 to fcount-1 do
      begin
        w:=AnimateBase.GetImageIndex(i,j);
        Blockwrite(F,w,sizeof(w));
      end;
      {$I+}
      if IOResult <> 0 then exit;
    end;
  end;
end;

//=============================================================================
// RES BINARY - shared directory builder (v2 and v3)
//
// BuildRESEntryList walks the project ONCE and records every resource in
// payload order. RESBinary (v2) and RESBinaryV3 both write their directories
// from this list, and both write payloads with WriteRESPayloads, so the two
// formats can never disagree about sizes or order. Before this, the header
// pass and the payload pass were two hand-kept copies of the same walk.
//=============================================================================
const
  MaxRESEntries    = 4096;
  RESErrTooMany    = 1000;   //more resources than MaxRESEntries

type
  RESEntryRec = record
                  category, format, lan, subtype, parent, count, recsize : integer;
                  size   : longint;
                  name   : string[24];
                  source : integer;   //image or map index the entry came from
                end;

  //v3 header and directory entry - 32 and 48 bytes, see the v3 spec
  resv3headrec = packed record
                   sig        : array[1..3] of char;
                   ver        : byte;
                   headersize : integer;
                   entrysize  : integer;
                   itemcount  : integer;
                   bytecheck  : integer;
                   diroffset  : longint;
                   reserved   : array[1..16] of byte;
                 end;

  resv3rec = packed record
               category, format, lan, subtype, parent, count, recsize, reserved : integer;
               offset : longint;
               size   : longint;
               name   : array[1..24] of char;
             end;

  resv3keyrec = packed record
                  key   : integer;
                  ktype : integer;
                  name  : array[1..16] of char;
                end;

var
  RESEntries       : array[0..MaxRESEntries-1] of RESEntryRec;
  RESEntryCount    : integer;
  RESEntryOverflow : boolean;

function AddRESEntry(category,format,lan,subtype,parent,count,recsize : integer;
                     size : longint; const name : string; source : integer) : integer;
begin
  AddRESEntry:=-1;
  if RESEntryCount >= MaxRESEntries then
  begin
    RESEntryOverflow:=true;
    exit;
  end;
  RESEntries[RESEntryCount].category:=category;
  RESEntries[RESEntryCount].format:=format;
  RESEntries[RESEntryCount].lan:=lan;
  RESEntries[RESEntryCount].subtype:=subtype;
  RESEntries[RESEntryCount].parent:=parent;
  RESEntries[RESEntryCount].count:=count;
  RESEntries[RESEntryCount].recsize:=recsize;
  RESEntries[RESEntryCount].size:=size;
  RESEntries[RESEntryCount].name:=name;
  RESEntries[RESEntryCount].source:=source;
  AddRESEntry:=RESEntryCount;
  inc(RESEntryCount);
end;

function FindRESEntry(category,source : integer) : integer;
var
  i : integer;
begin
  FindRESEntry:=-1;
  for i:=0 to RESEntryCount-1 do
    if (RESEntries[i].category = category) and (RESEntries[i].source = source) then
    begin
      FindRESEntry:=i;
      exit;
    end;
end;

//Raster Master Lan -> frozen v3 language id. The sprite set (0..26) already
//matches the v3 table; the map set folds onto the same language.
function LanToV3(Lan : integer) : integer;
begin
  if (Lan >= 0) and (Lan <= 26) then
    LanToV3:=Lan
  else
    case Lan of
      FBBasicLan   : LanToV3:=10;
      QB64BasicLan : LanToV3:=5;
      AQBBasicLan  : LanToV3:=14;
      BAMBasicLan  : LanToV3:=18;
      QBJSBasicLan : LanToV3:=20;
      GWBasicLan   : LanToV3:=7;
      QBBasicLan   : LanToV3:=4;
      TBBasicLan   : LanToV3:=6;
      ABBasicLan   : LanToV3:=11;
      FBQBBasicLan : LanToV3:=9;
      TPPascalLan  : LanToV3:=1;
      QPPascalLan  : LanToV3:=15;
      FPPascalLan  : LanToV3:=8;
      TMTPascalLan : LanToV3:=19;
      APPascalLan  : LanToV3:=12;
      TCCLan       : LanToV3:=2;
      QCCLan       : LanToV3:=3;
      OWCLan       : LanToV3:=17;
      GCCCLan      : LanToV3:=16;
      ACCLan       : LanToV3:=13;
    else
      LanToV3:=0;
    end;
end;

//Order here IS the payload order - WriteRESPayloads, then (v3 only)
//WriteRESV3Extras, must write in exactly this sequence.
function BuildRESEntryList(v3 : boolean) : boolean;
var
 EO          : ImageExportFormatRec;
 MapExport   : MapExportFormatRec;
 AnimExport  : AnimExportFormatRec;
 i, e, img, mp, par, count, width, height, nColors, hbcount, frames : integer;
 pathvals    : integer;
 ImageExportFormat : integer;
 Size        : longint;
 anyprops    : boolean;
 //longint - see RESBinary: {$MODE TP} integer is 16 bit
 pathbuf     : array[0..8191] of longint;
begin
 RESEntryCount:=0;
 RESEntryOverflow:=false;
 count:=ImageThumbBase.GetCount;

 //per image: palette, image, mask
 for i:=0 to count-1 do
 begin
   ImageThumbBase.GetExportOptions(i,EO);
   ImageExportFormat:=ImageIndexToFormat(EO.Lan,EO.Image);
   width:=ImageThumbBase.GetExportWidth(i);
   height:=ImageThumbBase.GetExportHeight(i);
   nColors:=ImageThumbBase.GetMaxColor(i)+1;
   Size:=GetRESImageSize(width,height,nColors,EO.Lan,EO.Image);

   if EO.Palette > 0 then
   begin
     par:=-1;
     if EO.Image > 0 then par:=RESEntryCount+1;   //its image is the next entry
     e:=AddRESEntry(ResTypePalette,EO.Palette,EO.Lan,0,par,nColors,0,
                    GetRESPaletteSize(nColors,EO.Lan,EO.Palette),EO.Name+'Pal',i);
   end;

   if EO.Image > 0 then
   begin
     img:=AddRESEntry(ResTypeImage,EO.Image,EO.Lan,0,-1,1,0,Size,EO.Name,i);
     //only putimage gets a mask - but not Amiga AQB
     if (ImageExportFormat=PutImageExportFormat) and (EO.Mask = 1) and (EO.Lan<>AQBLan) then
       e:=AddRESEntry(ResTypeImageMask,EO.Image,EO.Lan,0,img,1,0,Size,EO.Name+'Mask',i);
   end;
 end;

 //maps
 for i:=0 to MapCoreBase.GetMapCount-1 do
 begin
   MapCoreBase.GetMapExportProps(i,MapExport);
   if MapExport.MapFormat > 0 then
   begin
     width:=MapCoreBase.GetExportWidth(i);
     height:=MapCoreBase.GetExportHeight(i);
     //ExportLayerCount honours MapFormat: Simple exports one layer,
     //Layered exports them all - the same rule the writer uses
     e:=AddRESEntry(ResTypeMap,MapExport.MapFormat,MapExport.Lan,0,-1,ExportLayerCount(i),0,
                    GetRESMapSize(width,height,ExportLayerCount(i)),MapExport.Name,i);
   end;
 end;

 //sprite hit boxes. format carries the coordinate space for v2; v3 moves it
 //to subtype and writes format 0
 for i:=0 to ImageThumbBase.GetCount-1 do
 begin
   ImageThumbBase.GetExportOptions(i,EO);
   hbcount:=ImageThumbBase.GetHitBoxCount(i);
   if (EO.Image > 0) and (hbcount > 0) then
     e:=AddRESEntry(ResTypeHitBox,HitBoxSpacePixel,EO.Lan,HitBoxSpacePixel,
                    FindRESEntry(ResTypeImage,i),hbcount,0,GetRESHitBoxSize(hbcount),
                    EO.Name+'HitBox',i);
 end;

 //map hit boxes
 for i:=0 to MapCoreBase.GetMapCount-1 do
 begin
   MapCoreBase.GetMapExportProps(i,MapExport);
   hbcount:=MapCoreBase.GetHitBoxCount(i);
   if (MapExport.MapFormat > 0) and (hbcount > 0) then
     e:=AddRESEntry(ResTypeHitBox,HitBoxSpaceTile,MapExport.Lan,HitBoxSpaceTile,
                    FindRESEntry(ResTypeMap,i),hbcount,0,GetRESHitBoxSize(hbcount),
                    MapExport.Name+'HitBox',i);
 end;

 //map paths
 for i:=0 to MapCoreBase.GetMapCount-1 do
 begin
   MapCoreBase.GetMapExportProps(i,MapExport);
   if (MapExport.MapFormat > 0) and (MapCoreBase.PathExportCount(i) > 0) then
   begin
     pathvals:=MapCoreBase.BuildPathExportArray(i,pathbuf);
     if pathvals > 0 then
       e:=AddRESEntry(ResTypePath,MapExport.MapFormat,MapExport.Lan,0,
                      FindRESEntry(ResTypeMap,i),MapCoreBase.PathExportCount(i),0,
                      GetRESPathSize(pathvals),MapExport.Name+'Path',i);
   end;
 end;

 //animations - frame count word, then each frame's image index word
 for i:=0 to AnimateBase.GetAnimationCount-1 do
 begin
   AnimateBase.GetAnimExportProps(i,AnimExport);
   if AnimExport.AnimateFormat > 0 then
   begin
     frames:=AnimateBase.GetFrameCount(i);
     e:=AddRESEntry(ResTypeAnimation,AnimExport.AnimateFormat,AnimExport.Lan,0,-1,
                    frames,0,longint(1+frames)*2,AnimExport.Name,i);
   end;
 end;

 //v3 only: per map properties then strings, then the key table once
 if v3 then
 begin
   anyprops:=false;
   for i:=0 to MapCoreBase.GetMapCount-1 do
   begin
     MapCoreBase.GetMapExportProps(i,MapExport);
     if MapExport.MapFormat <= 0 then continue;
     BuildPropExport(i);
     if PEx.nrows = 0 then continue;
     mp:=FindRESEntry(ResTypeMap,i);
     e:=AddRESEntry(ResTypeProperties,0,MapExport.Lan,0,mp,PEx.nrows,PropRowWords*2,
                    longint(PEx.nrows)*PropRowWords*2,MapExport.Name+'Prop',i);
     if PEx.nstr > 0 then
       e:=AddRESEntry(ResTypeStrings,0,MapExport.Lan,0,mp,PEx.nstr,0,
                      PExStrPayloadSize,MapExport.Name+'Str',i);
     anyprops:=true;
   end;
   if anyprops then
     e:=AddRESEntry(ResTypeKeyDefs,0,NoLan,0,-1,MapCoreBase.GetKeyDefCount,
                    sizeof(resv3keyrec),longint(MapCoreBase.GetKeyDefCount)*sizeof(resv3keyrec),
                    'KeyDefs',-1);
 end;

 BuildRESEntryList:=not RESEntryOverflow;
end;

//Every payload of categories 1-7, in BuildRESEntryList order. Moved here
//VERBATIM from RESBinary so v2 and v3 write byte-identical payloads.
procedure WriteRESPayloads(var data : BufferRec);
var
 EO    : ImageExportFormatRec;
 i     : integer;
 count : integer;
 width : integer;
 height: integer;
 ImageExportFormat : integer;
begin
 count:=ImageThumbBase.GetCount;
 InitBufferRec(data);
 //convert and dump image
 for i:=0 to count-1 do
 begin
   width:=ImageThumbBase.GetExportWidth(i);
   height:=ImageThumbBase.GetExportHeight(i);
   ImageThumbBase.GetExportOptions(i,EO);

   ImageExportFormat:=ImageIndexToFormat(EO.Lan,EO.Image);
   SetThumbIndex(i);  //important - otherwise the GetMaxColor and GetPixel functions will not get the right data

   if EO.Palette > 0 then WritePalToBuffer(data,EO.Palette);

   Case EO.Lan of BasicLan,BasicLNLan,CLan,PascalLan:  //generic - indexed pixels
                                    begin
                                      if (ImageExportFormat = IndexedExportFormat) then
                                        WriteIndexedToBuffer(width,height,data.f);
                                    end;

                  QCLan,QPLan,QBLan,GWLan,PBLan,BAMLan,QBJSLan:   //BAM and QBJS use the standard QB-family XGF binary format
                                    begin
                                      if (ImageExportFormat = PutImageExportFormat) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,0,data);
                                      if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,1,data);
                                      if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);
                                    end;
                              QB64Lan:begin
                                        //if (EO.Image > 0) and (EO.Image<4) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                        case ImageExportFormat of RGBAFuchsiaExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,1);
                                                                   RGBAIndex0ExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,2);
                                                                   RGBACustomExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,4);
                                                                          RGBExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,3);
                                        end;
                                      end;
                        TPLan,TCLan,TMTLan: begin   //TMT uses the standard TP-family XGF binary format
                                       if (ImageExportFormat = PutImageExportFormat) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,0,data);
                                       if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,1,data);
                                       if (ImageExportFormat = XLibLBMExportFormat) then WriteLBMToBuffer(0,0,width-1,height-1,data);   //xlib lbm
                                       if (ImageExportFormat = XLibPBMExportFormat) then WritePBMToBuffer(0,0,width-1,height-1,data);   //xlib pbm
                                       if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);

                                     end;
                              FPLan: begin
                                       if (ImageExportFormat = PutImageExportFormat) then WriteXGFToBufferFP(0,0,width-1,height-1,0,data);
                                       if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXGFToBufferFP(0,0,width-1,height-1,1,data);
                                       //if (EO.Image > 1) and (EO.Image<5) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image-1);
                                       case ImageExportFormat of RGBAFuchsiaExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,1);
                                                                   RGBAIndex0ExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,2);
                                                                   RGBACustomExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,4);
                                                                          RGBExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,3);
                                       end;
                                       if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);
                                     end;
                              FBinQBModeLan: begin
                                       if (ImageExportFormat = PutImageExportFormat) then WriteXGFToBufferFB(0,0,width-1,height-1,0,data);
                                       if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXGFToBufferFB(0,0,width-1,height-1,1,data);
                                       if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);
                                     end;
                              FBLan:begin
                                       //if (EO.Image > 0) and (EO.Image<4) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                       case ImageExportFormat of RGBAFuchsiaExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,1);
                                                                   RGBAIndex0ExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,2);
                                                                   RGBACustomExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,4);
                                                                          RGBExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,3);
                                       end;
                                    end;
                              ABLan:begin
                                      if (ImageExportFormat = PutImageExportFormat) then WriteAmigaBasicXGFBuffer(0,0,width-1,height-1,data);
                                      if (ImageExportFormat = AmigaBOBExportFormat) then WriteAmigaBasicBobBuffer(0,0,width-1,height-1,data,false); //bob
                                      if (ImageExportFormat = AmigaVSpriteExportFormat) then WriteAmigaBasicBobBuffer(0,0,width-1,height-1,data,true);  //sprite
                                    end;
                        ACLan,APLan:begin
                                      if (ImageExportFormat = AmigaBOBExportFormat) then WriteAmigaBobBuffer(0,0,width-1,height-1,data,false);
                                      if (ImageExportFormat = AmigaVSpriteExportFormat) then WriteAmigaBobBuffer(0,0,width-1,height-1,data,true);
                                    end;
                             gccLan:begin
                                      //ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                       case ImageExportFormat of RGBAFuchsiaExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,1);
                                                                   RGBAIndex0ExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,2);
                                                                   RGBACustomExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,4);
                                                                          RGBExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,3);
                                       end;
                                    end;

                             OWLan:
                                    begin
                                      if (ImageExportFormat = PutImageExportFormat) then WriteXgfToBufferOW(0,0,width-1,height-1,0,data);
                                      if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXgfToBufferOW(0,0,width-1,height-1,1,data);
                                      if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);
                                    end;

   end;
 end;

 ResExportMaps(data.f); //export the maps
 ResExportSpriteHitBoxes(data.f); //sprite hit boxes, in header pass order
 ResExportMapHitBoxes(data.f);    //map hit boxes, in header pass order
 ResExportPaths(data.f);          //map paths, in header pass order
 ResExportAnimations(data.f); //export the animations
end;

//v3 only payloads, in BuildRESEntryList order. Returns an IO error, 0 = ok.
function WriteRESV3Extras(var F : File) : integer;
var
  i, s2, kn, err : integer;
  MapExport : MapExportFormatRec;
  anyprops : boolean;
  offs : word;
  wbuf : array[0..MaxMapProps-1] of word;
  kr : resv3keyrec;
  K : KeyDefRec;
begin
  WriteRESV3Extras:=0;
  anyprops:=false;
  for i:=0 to MapCoreBase.GetMapCount-1 do
  begin
    MapCoreBase.GetMapExportProps(i,MapExport);
    if MapExport.MapFormat <= 0 then continue;
    BuildPropExport(i);
    if PEx.nrows = 0 then continue;

    {$I-}
    Blockwrite(F,PEx.rows,longint(PEx.nrows)*PropRowWords*2);
    {$I+}
    err:=IOResult;
    if err <> 0 then begin WriteRESV3Extras:=err; exit; end;

    if PEx.nstr > 0 then
    begin
      //offset of each string's length byte, from the payload start. Unsigned:
      //the largest table is about 62K.
      offs:=PEx.nstr*2;
      for s2:=0 to PEx.nstr-1 do
      begin
        wbuf[s2]:=offs;
        inc(offs,1+Length(PEx.strs[s2]));
      end;
      {$I-}
      Blockwrite(F,wbuf,longint(PEx.nstr)*2);
      //a shortstring is its length byte followed by its characters - which
      //is exactly the on-disk layout the spec asks for
      for s2:=0 to PEx.nstr-1 do
        Blockwrite(F,PEx.strs[s2],1+Length(PEx.strs[s2]));
      {$I+}
      err:=IOResult;
      if err <> 0 then begin WriteRESV3Extras:=err; exit; end;
    end;
    anyprops:=true;
  end;

  if anyprops then
    for kn:=0 to MapCoreBase.GetKeyDefCount-1 do
    begin
      MapCoreBase.GetKeyDef(kn,K);
      kr.key:=K.key;
      kr.ktype:=K.ktype;
      fillchar(kr.name,sizeof(kr.name),32);
      if Length(K.name) > 0 then Move(K.name[1],kr.name,Length(K.name));
      {$I-}
      Blockwrite(F,kr,sizeof(kr));
      {$I+}
      err:=IOResult;
      if err <> 0 then begin WriteRESV3Extras:=err; exit; end;
    end;
end;

Function RESBinary(filename:string):word;
var
 data        : BufferRec;
 RR          : resrec;
 RH          : resheadrec;
 i           : integer;
 SLen        : integer;
 Error       : integer;
 HeaderSize  : LongInt;
 OffsetCount : LongInt;
begin
 SetThumbActive;   // we are getting pixel data from core object ThumbBase
 if not BuildRESEntryList(false) then
 begin
   RESBinary:=RESErrTooMany;
   exit;
 end;
 if RESEntryCount = 0 then exit;

 assign(data.f,filename);
{$I-}
 rewrite(data.f,1);
{$I+}
 Error:=IORESULT;
 if Error<>0 then
 begin
    RESBinary:=Error;
    exit;
 end;
 HeaderSize:=sizeof(RH)+longint(RESEntryCount)*sizeof(resrec);
 OffsetCount:=HeaderSize;

 //write the signature and record count
 RH.sig:='RES';
 RH.ver:=2;   //v2 = structured resource type encoding (see EncodeResType)
 RH.resitemcount:=RESEntryCount;
 {$I-}
 Blockwrite(data.f,RH,sizeof(RH));
 {$I+}
 Error:=IORESULT;
 if Error<>0 then
 begin
  RESBinary:=Error;
  exit;
 end;

 //directory, straight from the shared list - v2 has no parent/count fields,
 //so only category, lan, format, name and size are used
 for i:=0 to RESEntryCount-1 do
 begin
   fillchar(RR.rid,sizeof(RR.rid),32);
   slen:=Length(RESEntries[i].name);
   if slen > 20 then slen:=20;
   if slen > 0 then Move(RESEntries[i].name[1],RR.rid,slen);

   RR.size:=RESEntries[i].size;
   RR.offset:=OffsetCount;
   RR.rt:=EncodeResType(RESEntries[i].category,RESEntries[i].lan,RESEntries[i].format);
   inc(OffsetCount,RR.size);
   {$I-}
   Blockwrite(data.f,RR,sizeof(RR));
   {$I+}
   Error:=IORESULT;
   if Error<>0 then
   begin
     RESBinary:=Error;
     exit;
   end;
 end;

 WriteRESPayloads(data);

 {$I-}
 close(data.f);
 {$I+}
 RESBinary:=IOResult;
end;

//RES Binary v3 - see the spec. Export only; Raster Master never reads it.
Function RESBinaryV3(filename:string):word;
var
 data        : BufferRec;
 H           : resv3headrec;
 E           : resv3rec;
 i           : integer;
 SLen        : integer;
 Error       : integer;
 OffsetCount : LongInt;
begin
 RESBinaryV3:=0;
 SetThumbActive;
 if not BuildRESEntryList(true) then
 begin
   RESBinaryV3:=RESErrTooMany;
   exit;
 end;
 if RESEntryCount = 0 then exit;

 assign(data.f,filename);
{$I-}
 rewrite(data.f,1);
{$I+}
 Error:=IORESULT;
 if Error<>0 then
 begin
   RESBinaryV3:=Error;
   exit;
 end;

 fillchar(H,sizeof(H),0);
 H.sig:='RES';
 H.ver:=3;
 H.headersize:=sizeof(resv3headrec);
 H.entrysize:=sizeof(resv3rec);
 H.itemcount:=RESEntryCount;
 H.bytecheck:=$1234;   //a reader seeing $3412 knows to byte-swap
 H.diroffset:=sizeof(resv3headrec);
 {$I-}
 Blockwrite(data.f,H,sizeof(H));
 {$I+}
 Error:=IORESULT;
 if Error<>0 then
 begin
   RESBinaryV3:=Error;
   exit;
 end;

 OffsetCount:=sizeof(resv3headrec)+longint(RESEntryCount)*sizeof(resv3rec);
 for i:=0 to RESEntryCount-1 do
 begin
   E.category:=RESEntries[i].category;
   E.format:=RESEntries[i].format;
   if E.category = ResTypeHitBox then E.format:=0;   //space lives in subtype in v3
   E.lan:=LanToV3(RESEntries[i].lan);
   E.subtype:=RESEntries[i].subtype;
   E.parent:=RESEntries[i].parent;
   E.count:=RESEntries[i].count;
   E.recsize:=RESEntries[i].recsize;
   E.reserved:=0;
   E.offset:=OffsetCount;
   E.size:=RESEntries[i].size;
   fillchar(E.name,sizeof(E.name),32);
   slen:=Length(RESEntries[i].name);
   if slen > 24 then slen:=24;
   if slen > 0 then Move(RESEntries[i].name[1],E.name,slen);
   inc(OffsetCount,E.size);
   {$I-}
   Blockwrite(data.f,E,sizeof(E));
   {$I+}
   Error:=IORESULT;
   if Error<>0 then
   begin
     RESBinaryV3:=Error;
     exit;
   end;
 end;

 WriteRESPayloads(data);          //categories 1-7, byte-identical to v2
 Error:=WriteRESV3Extras(data.f); //properties, strings, key table

 {$I-}
 close(data.f);
 {$I+}
 if Error <> 0 then
 begin
   i:=IOResult;   //clear the pending close status
   RESBinaryV3:=Error;
   exit;
 end;
 RESBinaryV3:=IOResult;
end;



begin
end.
