unit rwilbm;

Interface
  uses bits,gPacker,npacker,packer,rmxgfcore,rmcore;
Type
  ChunkNameRec = array[1..4] of char;

  //FORM chunk is followed by longword total filesize-8
  //"PBM " is not followed size id
  //BMHD is followed by longword size id of 20
  //CMAP is followed by longword size n colors * 3
  //if CMAP size is an odd number a pad byte is added but not counted as part
  //of size. if there were 3 color - that would be 3*3 = 9 . so longword size
  // is 9 and followed by pad byte;

  ColorMapRec = Packed Record
    red   : Byte;
    green : Byte;
    blue  : Byte;
  End;

  BitMapHeaderRec = Packed Record
    w : Word;                    (* raster width in pixels  *)
    h : Word;                    (* raster height in pixels *)
    x : word;                    (* x offset in pixels *)
    y : word;                    (* y offset in pixels *)
    nplanes : Byte;              (* # source bitplanes *)
    masking : Byte;              (* masking technique, 0 = mskNone, 1 = mskHasMask, 2 = mskHasTransparentColor, 3 = mskLasso *)
    compression : Byte;          (* compression algoithm, 0 = cmpNone, 1 = cmpByteRun1 *)
    pad1 : Byte;                 (* UNUSED.  For consistency, put 0 here. *)
    transparentColor : Word;     (* transparent "color number" *)
    xaspect : Byte;              (* aspect ratio, a rational number x/y *)
    yaspect : byte;              (* aspect ratio, a rational number x/y *)
    pagewidth : word;            (* source "page" size in pixels *)
    pageheight : word;           (* source "page" size in pixels *)
 End;


function WriteILBM(filename : string; x,y,x2,y2 : word;cmp  :byte) : word;
function ReadILBM(filename : string; x,y,x2,y2,lp : integer) : word;

Implementation

Type
 LineBufType = Array[0..16023] of Byte;


Procedure mpTOsp(Var multiPlane,singlePlane : LineBufType; BytesPerPlane,nPlanes : Word);
Var
  i,j    : Word;
  xpos   : Word;
  Col    : Word;
  ImgOff2,ImgOff3,ImgOff4,ImgOff5,ImgOff6,ImgOff7,ImgOff8 : Word;
begin
   xpos:=0;
   ImgOff2:=BytesPerPlane;
   ImgOff3:=ImgOff2*2;
   ImgOff4:=ImgOff2*3;
   ImgOff5:=ImgOff2*4;
   ImgOff6:=ImgOff2*5;
   ImgOff7:=ImgOff2*6;
   ImgOff8:=ImgOff2*7;

   FillChar(singlePlane,SizeOf(singlePlane),0);
   For i:=0 to ImgOff2-1 do
   begin
     For j:=7 downto 0 do
     begin
        Col:=0;
        if biton(j,multiPlane[i]) then
        begin
        Inc(Col,1);
        end;

        if (nPlanes > 1) AND biton(j,multiplane[i+ImgOff2]) then
        begin
        Inc(Col,2);
        end;

        if (nPlanes > 2) AND biton(j,multiplane[i+ImgOff3]) then
        begin
        Inc(Col,4);
        end;

        if (nPlanes > 3) AND biton(j,multiplane[i+ImgOff4]) then
        begin
        Inc(Col,8);
        end;

        if (nPlanes > 4) AND biton(j,multiplane[i+ImgOff5]) then
        begin
        Inc(Col,16);
        end;

        if (nPlanes > 5) AND biton(j,multiplane[i+ImgOff6]) then
        begin
        Inc(Col,32);
        end;

        if (nPlanes > 6) AND biton(j,multiplane[i+ImgOff7]) then
        begin
        Inc(Col,64);
        end;

        if (nPlanes > 7) AND biton(j,multiplane[i+ImgOff8]) then
        begin
        Inc(Col,128);
        end;

        singlePlane[xpos]:=Col;
        Inc(xpos);
     end;
   end;
end;


Procedure spTOmp(Var singlePlane : LineBufType ;
                 var multiplane : LineBufType;
                 PixelWidth,BytesPerPlane,nPlanes : Word);

var
 BitPlane1 : Word;
 BitPlane2 : Word;
 BitPlane3 : Word;
 BitPlane4 : Word;
 BitPlane5 : Word;
 cp,cl,x,
 xoff,j    : Word;

begin

 Fillchar(multiplane,sizeof(multiplane),0);

 BitPlane1:=0;
 BitPlane2:=bytesPerPlane;
 BitPlane3:=BytesPerPlane*2;
 BitPlane4:=BytesPerPlane*3;
 BitPlane5:=BytesPerPlane*4;

 xoff:=0;
 cp:=0;
 for x:=0 to bytesPerPlane-1 do
 begin
   for j:=0 to 7 do
   begin
      cl:=SinglePlane[xoff+j];

      if biton(4,cl) then setbit((7-j),1,multiplane[BitPlane5+cp]);
      if biton(3,cl) then setbit((7-j),1,multiplane[BitPlane4+cp]);
      if biton(2,cl) then setbit((7-j),1,multiplane[BitPlane3+cp]);
      if biton(1,cl) then setbit((7-j),1,multiplane[BitPlane2+cp]);
      if biton(0,cl) then setbit((7-j),1,multiplane[BitPlane1+cp]);
   end;
   inc(cp);
   inc(xoff,8);
 end;
end;

Function LongToLE(myLongWord : LongWord) : LongWord;
var
 Temp : array[1..4] of Byte;
begin
  Move(myLongWord,Temp,sizeof(Temp));
  LongToLE := (Temp[1] shl 24) + (Temp[2] shl 16) + (Temp[3] shl 8) + Temp[4];
end;

Function WordToLE(myWord : Word) : Word; (* if its little endian to will become big endian vice versa*)
begin
  WordToLE:=LO(myWord) SHL 8 + HI(myWord);
end;

Function RowBytes(w : Word): word;
BEGIN
  RowBytes:= ((((w + 15) DIV 16) * 2));
END;
Function RowBytes2(w: Word): word;
BEGIN
  RowBytes2:= (w + 15) div 8;
END;

Procedure DrawImgLine(Ln : word;var singleBuf : linebuftype; width : word;x,y,x2,y2 : integer);
var
 i : word;
begin
 if (Ln+y) > y2 then exit;

 for i:=0 to width-1 do
 begin
   if (x+i) <= x2 then putpixel(x+i,Ln+y,singleBuf[i]);
 end;
end;


Procedure ProcessUBODY(var F : File;bmap : BitMapHeaderRec;pbm,ilbm : boolean;x,y,x2,y2 : integer);
var
  mybytes : longint;
  bwidth,bheight : word;
  Ln,k : integer;
  a  : byte;
  planarBuf,singleBuf : LineBufType;
  nplanes : word;
  rbytes : word;
begin
  fillchar(planarBuf,sizeof(planarBuf),0);
  bwidth:=WordToLE(bmap.w);
  bheight:=WordToLE(bmap.h);

  mybytes:=rowbytes(bwidth);
  nplanes:=bmap.nplanes;
  if pbm then
  begin
    rbytes:=bwidth;
    if odd(rbytes) then inc(rbytes);
  end
  else
  begin
    rbytes:=myBytes*nplanes;
  end;
    FOR Ln:=0 TO bheight-1 do
    begin
      FOR k:=0 TO rbytes-1 do
      begin
         Blockread(F,a,sizeof(a));
           planarBuf[k]:=a;
      end;

      if pbm then
      begin
         DrawImgLine(Ln,planarBuf,bwidth,x,y,x2,y2);
      end
      else
      begin   //ilbm
         mptosp(planarBuf,singleBuf,mybytes,nplanes);
         DrawImgLine(Ln,singleBuf,bwidth,x,y,x2,y2);
      end;
   end;  //next ln
end;


Procedure ProcessBODY(var F : File;bmap : BitMapHeaderRec;pbm,ilbm : boolean;x,y,x2,y2 : integer);
var
  mybytes : longint;
 // mybmap  : longint;
  bwidth,bheight : word;
  Ln,j,k : integer;
  a,b,c : byte;
  planarBuf,singleBuf : LineBufType;
  counter : word;
  n : integer;
  nplanes : word;
begin
  fillchar(planarBuf,sizeof(planarBuf),0);
  bwidth:=WordToLE(bmap.w);
  bheight:=WordToLE(bmap.h);

  mybytes:=rowbytes(bwidth);
  nplanes:=bmap.nplanes;
//  mybmap:=mybytes*bheight;
    FOR Ln:=0 TO bheight-1 do
    begin
        counter:=0;
        FOR j:=0 TO bmap.nplanes-1 do
        begin
          (*
            IF bmap.compression=0 THEN
            BEGIN
               FOR k:=0 TO mybytes-1 do
               begin
                 Blockread(F,a,sizeof(a));
                 planarBuf[k]:=a;
               END;
            end
            ELSE
            begin *)
              WHILE counter < (mybytes*bmap.nplanes-1) do
               begin
                 Blockread(F,c,1);
                 if c > 127 then n:=c-256 else n:=c;  //using 16 bit integer like 8 bit integer
                 //trying to avoid using freepascal int8 and still making code look like C algorithm
                 IF (n >=0) and (n<=127)  THEN
                 begin
                    FOR k:=0 TO n do
                     begin
                       Blockread(F,b,1);
                       planarBuf[counter+k]:=b;
                     end;
                     inc(counter,n+1);
                  end
                  ELSE IF (n<0) and (n>-128) THEN
                  begin
                     Blockread(F,b,1);
                     FOR k:=0 TO abs(n) do
                     begin
                       planarBuf[counter+k]:=b;
                     end;
                     inc(counter,abs(n)+1);
                  END;  //if
                END;   //while
           // END;  //if
          End;   // next j

          if pbm then
             DrawImgLine(Ln,planarBuf,bwidth,x,y,x2,y2)
          else
          begin
             mptosp(planarBuf,singleBuf,mybytes,nplanes);
             DrawImgLine(Ln,singleBuf,bwidth,x,y,x2,y2);
          end;
    end;  //next i
end;

Procedure ProcessCMAP(var F: File;cmapsize : longword; lp : integer);
var
 numColors,i : integer;
 cmap        : ColorMapRec;
 cr          : TRMColorRec;
begin
 numColors:=cmapsize div 3;
 for i:=0 to numColors-1 do
 begin
   BlockRead(F,cmap,sizeof(cmap));
   if lp = 1 then
   begin
     cr.r:=cmap.red;
     cr.g:=cmap.green;
     cr.b:=cmap.blue;
     SetColor(i,cr);
   end;
//    SetRGBPalette(i,cmap.red ,cmap.green ,cmap.blue );  //todo
 end;
end;

Procedure BuildChunkName(var chunkname : chunknamerec; newbyte : byte;var chunknamelength : integer);
begin
  if chunknamelength = 0 then chunkname:='****';
  inc(chunknamelength);
  if (chunknamelength > 4) then
  begin
    ChunkName[1]:=Chunkname[2];
    ChunkName[2]:=Chunkname[3];
    ChunkName[3]:=Chunkname[4];
    ChunkName[4]:=chr(newbyte);
    Chunknamelength:=4;
  end
  else
    chunkname[chunknamelength]:=chr(newbyte);
end;

Procedure Process(var F : File;x,y,x2,y2,lp : integer);
var
  chunkname : chunknamerec;
  chunknamelength : integer;
  mybyte : byte;
  FormSize : LongWord;
  bmap : BitMapHeaderRec;
  bmhdsize : LongWord;
  bodysize : longword;
  cmapsize : longword;
  foundBMap : boolean;
  ILBMFile : boolean;
  PBMFile : boolean;

begin
  ILBMFile:=false;
  PBMFile:=false;
  FoundBMap:=false;
  Chunknamelength:=0;
  While Not Eof(F) do
  begin
    BlockRead(F,mybyte,sizeof(mybyte));
    BuildChunkName(chunkname,mybyte,chunknamelength);
    if chunkname='FORM' then
    begin
      BlockRead(F,FormSize,sizeof(FormSize));
    end
    else if chunkname ='PBM ' then
    begin
      PBMFile:=true;
    end
    else if chunkname ='ILBM' then
    begin
      ILBMFile:=true;
    end
    else if chunkname ='BMHD' then
    begin
      BlockRead(F,bmhdsize,sizeof(bmhdsize));
      BlockRead(F,bmap,sizeof(bmap));
      FoundBMap:=true;
    end
    else if chunkname ='CMAP' then
    begin
      BlockRead(F,cmapsize,sizeof(cmapsize));
      cmapsize:=LongToLE(cmapsize);
      ProcessCMAP(F,cmapsize,lp);
    end
    else if (chunkname ='BODY') And FoundBMap   then
    begin
      BlockRead(F,bodysize,sizeof(bodysize));
      if bmap.compression=1 then ProcessBODY(F,bmap,pbmFile,ILBMFile,x,y,x2,y2)
      else ProcessUBODY(F,bmap,pbmFile,ILBMFile,x,y,x2,y2);
    end;
  end;
end;

Procedure UnPackBuffer(var packedBuf : lineBufType;
                       var unpackedBuf : LineBufType;
                           packedSize : integer;
                       var unpackedSize : integer);
var
 c,b : byte;
 k,n : integer;
 pcounter,counter : integer;
begin
   counter:=0;
   pcounter:=0;
   fillchar(unpackedbuf,sizeof(unpackedbuf),0);
   WHILE counter < unpackedSize do
   begin
                 c:=packedBuf[pcounter];
                 //writeln('c=',c);
                 inc(pcounter);
                 if c > 127 then n:=c-256 else n:=c;  //using 16 bit integer like 8 bit integer
                 //trying to avoid using freepascal int8 and still making code look like C algorithm
                 //writeln('n=',n);
                 IF (n >=0) and (n<=127)  THEN
                 begin
                    FOR k:=0 TO n do
                     begin
                       b:=packedBuf[pcounter+k];
                       unpackedBuf[counter+k]:=b;
                     end;
                     inc(counter,n+1);
                     inc(pcounter,n+1);
                  end
                  ELSE IF (n<0) and (n>-128) THEN
                  begin
                     b:=packedBuf[pcounter];
                     inc(pcounter);
                     FOR k:=0 TO abs(n) do
                     begin
                       unPackedBuf[counter+k]:=b;
                     end;
                     inc(counter,abs(n)+1);
                  END;  //if
                END;   //while
end;


Procedure WriteChunkName(var f : file; chunkname : chunknamerec);
begin
 blockwrite(f,chunkname,sizeof(chunkname));
end;

Procedure WriteChunkSize(var f : file; size : longword);
begin
 blockwrite(f,size,sizeof(size));
end;

Procedure WriteBMHD(var f : file; var bmhd: BitMapHeaderRec);
begin
 blockwrite(f,bmhd,sizeof(bmhd));
end;

Function GetCMAPSize : Longword;
var
 size: longword;
begin
 size:=(getmaxcolor+1)*3;
 if odd(size) then inc(size);
 GetCMAPSize:=size;
end;

Procedure WriteCMAP(var f : file);
var
 cmap  : array[0..255] of ColorMapRec;
 cr    : TRMColorRec;
 i     : integer;

 pad0  : byte;
begin
 pad0:=0;
 for i:= 0 to GetMaxColor do
 begin
//   GetRGBPalette(i,r,g,b); //todo
   GetColor(i,cr);
   cmap[i].red:=cr.r;
   cmap[i].green:=cr.g;
   cmap[i].blue:=cr.b;
 end;
 blockwrite(f,cmap,(GetMaxColor+1)*3);
 if ((GetMaxColor+1)*3)< GetCMAPSize then Blockwrite(f,pad0,sizeof(pad0));
end;

Function GetNPLanes : Byte;
begin
 GetNPlanes:=0;
 Case GetMaxColor of 1:GetNPlanes:=1;
                     3:GetNPlanes:=2;
                     7:GetNPlanes:=3;
                     15:GetNPlanes:=4;
                     31:GetNPlanes:=5;
                     63:GetNPlanes:=6;
                     127:GetNPlanes:=7;
                     255:GetNPlanes:=8;
 end;
end;

Function WriteBODY(var f : file; x,y,x2,y2 : word;cmp : byte) : longword;
var
 i,j : integer;
 singlePlane : LineBufType;
 multiPlane  : LineBufType;
 ImgPacked : LineBufType;
 PackedSize : integer;

 BodySize : longword;
 pad0 : byte;
  NPlanes : Byte;
  c : word;
  w : word;
  p : integer;
begin
 w:=x2-x+1;
 //h:=y2-y+1;
 BodySize:=0;
 pad0:=0;
 nPlanes:=GetNPlanes;
 for j:=y to y2 do
 begin
   c:=0;
   for i:=x to x2 do
   begin
     singlePlane[c]:=GetPixel(i,j);
     inc(c);
   end;

   spTOmp(singlePlane,multiPlane,w,RowBytes(w),nPlanes);

   for p:=0 to nplanes -1 do
   begin
     packedsize:=gPackRow(multiplane,p*rowbytes(w),imgpacked,RowBytes(w));
     blockwrite(f,imgpacked,packedsize);
     inc(Bodysize,packedsize);
   end;
 end;

 if Odd(BodySize) then  //if the BODY is odd Delexe Paint reports it mangled iff
 begin
   inc(BodySize);
   BlockWrite(f,pad0,sizeof(pad0));
 end;

 WriteBody:=BodySize;
end;
(*
Function WriteBODYbak(var f : file; x,y,x2,y2 : word;cmp : byte) : longword;
var
 i,j : integer;
 singlePlane : LineBufType;
 multiPlane  : LineBufType;
 ImgPacked : LineBufType;
 PackedSize : integer;

 BodySize : longword;
 pad0 : byte;
  NPlanes : Byte;
  c : word;
  w,h : word;
  n : integer;
  p : integer;
begin
 w:=x2-x+1;
 h:=y2-y+1;
 BodySize:=0;
 pad0:=0;
 nPlanes:=GetNPlanes;
 for j:=y to y2 do
 begin
   c:=0;
   for i:=x to x2 do
   begin
     singlePlane[c]:=GetPixel(i,j);
     inc(c);
//     putpixel(i,j,singleplane[i]);
   end;

   spTOmp(singlePlane,multiPlane,w,RowBytes(w),nPlanes);
 //  spTOmp(singlePlane,multiPlane,320,nPlanes);
   packedsize:=gPackRow(multiplane,0,imgpacked,RowBytes(w)*nplanes);
   blockwrite(f,imgpacked,packedsize);
   inc(Bodysize,packedsize);

 end;

 if Odd(BodySize) then  //if the BODY is odd Delexe Paint reports it mangled iff
 begin
   inc(BodySize);
   BlockWrite(f,pad0,sizeof(pad0));
 end;

 WriteBodybak:=BodySize;
end;
 *)
Procedure UpdateFormSize(var f : file);
var
 size : longword;
begin
 size:=LongToLE(filesize(f)-8);
 Seek(f,4);
 blockwrite(f,size,sizeof(size));
end;

function WriteILBM(filename : string; x,y,x2,y2 : word;cmp  :byte) : word;
var
 f : File;
 bmhd : BitMapHeaderRec;
 BodyFP : longint;
 BodySize : longword;
begin
SetCoreActive;

assign(f,filename);
{$I-}
 rewrite(f,1);

 WriteChunkName(f,'FORM');
 WriteChunkSize(f,0); //we don't know the final size yet - we will update below
 If GetNPlanes = 8 then
   WriteChunkName(f,'PBM ')
 else
   WriteChunkName(f,'ILBM');


 WriteChunkName(f,'BMHD');
 WriteChunkSize(f,LongToLE(20));

 bmhd.w:=WordToLE(x2-x+1);

 bmhd.h:=WordToLE(y2-y+1);

 bmhd.x:=WordToLE(0);

 bmhd.y:=WordToLE(0);

 bmhd.nplanes:=GetNPlanes;

 bmhd.masking:=0;

 bmhd.compression:=cmp;

 bmhd.pad1 :=0;

 bmhd.transparentColor:=WordToLE(GetMaxColor);

 bmhd.xaspect:= 4;

 bmhd.yaspect:= 5;

 bmhd.pagewidth:=bmhd.w;      // WordToLE(GetMaxX+1);

 bmhd.pageheight:=bmhd.h;            // WordToLE(GetMaxY+1);
 WriteBMHD(f,bmhd);
 WriteChunkName(f,'CMAP');
 WriteChunkSize(f,LongToLE(GetCMAPSize));
 WriteCMAP(f);

 WriteChunkName(f,'BODY');
 BodyFP:=FilePos(f); //save position where Body size should be updated
 WriteChunkSize(f,LongToLE(0)); //we don't know yet - update below
 BodySize:=LongToLE(WriteBODY(f,x,y,x2,y2,cmp));
 Seek(F,BodyFP);
 Blockwrite(f,bodysize,sizeof(bodysize));  //update body size
 UpdateFormSize(f);
 close(f);
 {$I+}
 WriteILBM:=IORESULT;
end;


function ReadILBM(filename : string; x,y,x2,y2,lp : integer) : word;
var
 f : file;
begin
  SetCoreActive;
  Assign(F,filename);
{$I-}
  Reset(F,1);
  Process(F,x,y,x2,y2,lp);
  Close(f);
{$I+}
ReadILBM:=IORESULT;
end;


begin
end.

