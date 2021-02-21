{$mode TP}
{$PACKRECORDS 1}

Unit RWXgf;
 Interface
   uses RMCore,Bits;

Const
   TPLan   = 1;
   TCLan   = 2;
   QCLan   = 3;
   QBLan   = 4;
   PBLan   = 5;
   GWLan   = 6;
   FPLan   = 7;

   Binary2   = 1;
   Binary4   = 2;
   Binary16  = 3;
   Binary256 = 4;

   Source2   = 5;
   Source4   = 6;
   Source16  = 7;
   Source256 = 8;

   SPRBinary = 9;
   SPRSource = 10;

   PPRBinary = 11;
   PPRSource = 12;

   TEGLText  = 13;

   PALSource = 14;



Function WriteXgf(x,y,x2,y2,LanType : word;filename:string):word;
Function ReadRaw(x,y,x2,y2,pal : Word;FileName : String) : Word;
Function WriteRaw(x,y,x2,y2 : Word;FileName : String) : Word;
Function ReadPAL(Filename : String) : Word;
Function WritePAL(Filename : String) : Word;

Implementation

type
 linebuftype = array[0..1023] of byte;

function GetMaxColor : integer;
begin
  GetMaxColor:=RMCoreBase.Palette.GetColorCount -1;
end;

Function WriteXgfFP(x,y,x2,y2 : word;filename:string):word;
type
 //free pascal graph - each pixel takes a Word
 XGFHeadFP = Record
              Width,Height : LongInt;
              reserved     : LongInt;
 end;
 linebufFP = array[0..1023] of Word;
var
 Header : XGFHeadFP;
 lineBuf:linebufFP;
 counter : integer;
 F         : File;
 Error     : Word;
 j,i       : integer;
begin
 Header.Width:=x2-x+1;
 Header.Height:=y2-y+1;
 Header.reserved:=0;
{$I+}
 Assign(F,filename);
 Rewrite(F,1);
 Blockwrite(F,Header,sizeof(Header));

 Error:=IOResult;
 if Error <> 0 then
 begin
   close(F);
   WriteXgfFP:=Error;
   exit;
 end;

 For j:=y to y2 do
 begin
   counter:=0;
   for i:=x to x2 do
   begin
      linebuf[counter]:=RMCoreBase.GetPixel(i,j);
      inc(counter);
   end;
   blockwrite(F,linebuf,header.Width*sizeof(word));
 end;

 Close(F);
 WriteXgfFP:=IOResult;
{$I+}
end;


//2 color - 1 bitplanes - packed - 1 bits per color
Procedure WriteXgfLine2(Var F: File;xp,ln,width,bytesPerLine,LanType : word);
var
 cb,i : Word;
  mylinebuf : Linebuftype;
  mycolors  : LinebufType;
  x : integer;

begin
 {$I-}
 Fillchar(mylinebuf,sizeof(mylinebuf),0);
 Fillchar(mycolors,sizeof(mycolors),0);

 cb:=0;
 x:=0;

 for i:=0 to width-1 do
 begin
     mycolors[i]:=RMCoreBase.GetPixel(xp+i,ln);
 end;

 For i:=0 to BytesPerLine-1 do
 begin
   myLineBuf[i] := (mycolors[x] shl 7) + (mycolors[x+1] shl 6) + (mycolors[x+2] shl 5) + (mycolors[x+3] shl 4) +
                   (mycolors[x+4] shl 3) + (mycolors[x+5] shl 2) + (mycolors[x+6] shl 1) + mycolors[x+7];
   inc(x,8);
  end;

 BlockWrite(F,mylinebuf,BytesPerLine);
{$I+}
end;


//4 color - 1 bitplanes - packed - 2 bits per color
Procedure WriteXgfLine4(Var F: File;xp,ln,width,bytesPerLine,LanType : word);
var
 cb,i : Word;
  mylinebuf : Linebuftype;
  mycolors  : LinebufType;
  x : integer;

begin
 {$I-}
 Fillchar(mylinebuf,sizeof(mylinebuf),0);
 Fillchar(mycolors,sizeof(mycolors),0);

 cb:=0;
 x:=0;

 for i:=0 to width-1 do
 begin
     mycolors[i]:=RMCoreBase.GetPixel(xp+i,ln);
 end;

 For i:=0 to BytesPerLine-1 do
 begin
   myLineBuf[i] := (mycolors[x] shl 6) + (mycolors[x+1] shl 4) + (mycolors[x+2] shl 2) + mycolors[x+3];
   inc(x,4);
  end;

 BlockWrite(F,mylinebuf,BytesPerLine);
{$I+}
end;

//16 color - 4 bitplanes
Procedure WriteXgfLine16(Var F: File;xp,ln,width,bytesPerLine,LanType : word);
var
 BitPlane1 : Word;
 BitPlane2 : Word;
 BitPlane3 : Word;
 BitPlane4 : Word;
 cp,cl,x,
 xoff,j    : Word;
 mylinebuf : Linebuftype;
 Temp      : Word;
begin
{$I-}
 Fillchar(mylinebuf,sizeof(mylinebuf),0);

 BitPlane1:=0;
 BitPlane2:=bytesPerLine;
 BitPlane3:=BytesPerLine*2;
 BitPlane4:=BytesPerLine*3;
 xoff:=xp;
 cp:=0;
 for x:=0 to bytesPerLine-1 do
 begin
   for j:=0 to 7 do
   begin
//      cl:=IconImage[xoff+j,ln];
      cl:=RMCoreBase.GetPixel(xoff+j,ln);

      if biton(3,cl) then setbit((7-j),1,mylinebuf[BitPlane4+cp]);
      if biton(2,cl) then setbit((7-j),1,mylinebuf[BitPlane3+cp]);
      if biton(1,cl) then setbit((7-j),1,mylinebuf[BitPlane2+cp]);
      if biton(0,cl) then setbit((7-j),1,mylinebuf[BitPlane1+cp]);
   end;
   inc(cp);
   inc(xoff,8);
 end;

 If (LanType=TPLan) OR (LanType=TCLan) OR (LanType=PBLan) then
 begin
   For x:=0 to BitPlane2-1 do
   begin
     Temp:=myLineBuf[x];
     mylineBuf[x]:=mylineBuf[x+BitPlane4];
     mylineBuf[x+BitPlane4]:=Temp;
     Temp:=mylineBuf[x+BitPlane2];
     mylineBuf[x+BitPlane2]:=mylineBuf[x+BitPlane3];
     mylineBuf[x+BitPlane3]:=Temp;
   end;
 end;
 BlockWrite(F,mylinebuf,BytesPerLine*4);
{$I+}
end;



Function WriteXgf(x,y,x2,y2,LanType : word;filename:string):word;
Type
 XgfHead = Record
             Width  : Word;
             Height : Word;
           End;
Var
 mylinebuf : Linebuftype;
 myHead    : XgfHead;
 mywidth   : word;
 myheight  : word;
 BPL       : Word;
 F         : File;
 Error     : Word;
 J,I       : Word;
 Temp         : Word;
begin
 if LanType = FPLan then
 begin
   WriteXGF:=WriteXgfFP(x,y,x2,y2,filename);
   exit;
 end;

 {$I-}
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;

 If (LanType=TPLan) OR (LanType=TCLan)  then
 begin
   myhead.Width:=mywidth-1;
   myhead.Height:=myheight-1;
 end
 else If (LanType=PBLan) then
 begin
   myhead.Width:=mywidth;
   myhead.Height:=myheight;
 end
 else  if (LanType=QBLan) OR (LanType=QCLan) then
 begin
   If GetMaxColor=3 then
   begin
     myhead.Width:=mywidth*2
   end
   else If GetMaxColor=255 then
   begin
     myhead.Width:=mywidth SHL 3;
   end
   else
   begin
     myhead.Width:=mywidth;
   end;
   myhead.Height:=myheight;
 end;

 Assign(F,filename);
 Rewrite(F,1);
 BlockWrite(F,myhead,4);

 Error:=IOResult;
 if Error <> 0 then
 begin
   close(F);
   WriteXgf:=Error;
   exit;
 end;

 if GetMaxColor=1 then
 begin
   BPL:=(mywidth+7) div 8;
   For j:=0 to myheight-1 do
   begin
     WriteXgfline2(F,x,y+j,mywidth,BPL,LanType);
     Error:=IOResult;
     if Error <> 0 then
     begin
       close(F);
       WriteXgf:=Error;
       exit;
     end;
    end;
 end
 else if GetMaxColor=3 then
 begin
   BPL:=(mywidth+3) div 4;
   For j:=0 to myheight-1 do
   begin
     WriteXgfline4(F,x,y+j,mywidth,BPL,LanType);
     Error:=IOResult;
     if Error <> 0 then
     begin
       close(F);
       WriteXgf:=Error;
       exit;
     end;
    end;
 end
 else if GetMaxColor=15 then
 begin
   BPL:=(mywidth+7) div 8;
   For j:=0 to myheight-1 do
   begin
     WriteXgfline16(F,x,y+j,mywidth,BPL,LanType);
     Error:=IOResult;
     if Error <> 0 then
     begin
       close(F);
       WriteXgf:=Error;
       exit;
     end;
    end;
 end
 else
 begin
   For j:=y to y2 do
   begin
     For i:=1 to myWidth do
     begin
     //  MyLineBuf[i-1]:=IconImage[i+x-1,j];
         MyLineBuf[i-1]:=RMCoreBase.getPixel(i+x-1,j);

     end;
     BlockWrite(F,MyLineBuf,myWidth);
   end;
 end;

 If (LanType = TPLan) OR (LanType=TCLan)  then
 begin
   Temp:=0;
   BlockWrite(F,Temp,2);
 end;

 Close(F);
 WriteXgf:=IOResult;
{$I+}
end;


Function WriteRaw(x,y,x2,y2 : Word;FileName : String) : Word;
Var
 Error,i ,j : Word;
    F : File;
 Width,Height,Colors : Word;
 Tbuf : array[1..100] of Byte;
  myPal : Array[0..255,0..2] of Byte;
begin
 Width:=x2-x+1;
 Height:=y2-y+1;
 Colors:=GetMaxColor+1;

// GrabPaletteList(myPal,Colors);
For i:=0 to 255 do
begin
  myPal[i,0]:=RMCoreBase.Palette.GetRed(i);
  myPal[i,1]:=RMCoreBase.Palette.GetGreen(i);
  myPal[i,2]:=RMCoreBase.Palette.GetBlue(i);
end;


{$I-}
 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,Width,2);
 BlockWrite(F,Height,2);
 BlockWrite(F,Colors,2);

 BlockWrite(F,myPal,Colors*3);

 For j:=y to y2 do
 begin
   For i:=1 to Width do
   begin
  //   Tbuf[i]:=IconImage[x+i-1,j];
       Tbuf[i]:=RMCoreBase.GetPixel(x+i-1,j);

   end;
   BlockWrite(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     WriteRaw:=Error;
     Exit;
   end;
 end;

 Close(F);
 Error:=IORESULT;
 WriteRaw:=Error;
{$I+}
end;

Function ReadRaw(x,y,x2,y2,pal : Word;FileName : String) : Word;
Var
 Error,i ,j : Word;
    F : File;
 Width,Height,Colors : Word;
 myWidth,myHeight : Word;
 Fcol : Byte;
 Tbuf : LineBufType;
  myPal :  Array[0..255,0..2] of Byte;
 size,fsize  : LongInt;
 cr : TRMColorRec;
begin
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
{$I-}
 Assign(F,FileName);
 Reset(F,1);
 Error:=IORESULT;
 if Error <>0 then
 begin
   ReadRaw:=Error;
   Exit;
 end;

 fsize:=FileSize(F);

 BlockRead(F,Width,2);
 BlockRead(F,Height,2);
 BlockRead(F,Colors,2);

 size:=Width*Height+(Colors*3)+6;
 if size<>fsize then
 begin
  Close(f);
  ReadRaw:=1000;
  Error:=IORESULT;
  Exit;
 end;
 If Colors > 0 Then
 begin
   BlockRead(F,myPal,Colors*3);
 end;
 If myHeight > Height then myHeight:=Height;
 if myWidth >  Width then myWidth:=Width;
 For j:=1 to myHeight do
 begin
   BlockRead(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     ReadRaw:=Error;
     Exit;
   end;
   For i:=1 to myWidth do
   begin
       //IconImage[x+i-1,y+j-1]:=Tbuf[i-1];
       RMCoreBase.PutPixel(x+i-1,y+j-1,Tbuf[i-1]);

   end;
 end;
 Close(F);
 If (GetMaxColor=15) AND (Colors>16) then
 begin
   //ReduceTo16;
 end;
 if Colors > (GetMaxColor+1) then Colors:=GetMaxColor+1;
 If Pal=1 then
 begin
   If Colors > 0 Then
   begin
     //SetPaletteList(myPal,Colors);
     for i:=0 to Colors-1 do
     begin
       cr.r:=mypal[i,0];
       cr.g:=mypal[i,1];
       cr.b:=mypal[i,2];

       RMCoreBase.Palette.SetColor(i,cr);
     end;
   end;
 end;
 Error:=IORESULT;
 ReadRaw:=Error;
{$I+}
end;


Function WritePAL(FileName : String): Word;
Var
 F : File;
  myPal :  Array[0..255,0..2] of Byte;
 Colors : Word;
 Error : Word;
 i : integer;

begin
{$I-}
 Colors:=GetMaxColor+1;
 //GrabPaletteList(myPal,Colors);

 For i:=0 to 255 do
begin
  myPal[i,0]:=RMCoreBase.Palette.GetRed(i);
  myPal[i,1]:=RMCoreBase.Palette.GetGreen(i);
  myPal[i,2]:=RMCoreBase.Palette.GetBlue(i);
end;

 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,myPAL,Colors*3);
 Close(F);
 Error:=IORESULT;
 WritePAL:=Error;
{$I+}
end;

Function ReadPAL(Filename : String) : Word;
Var
 F      : File;
 Fsize  : LongInt;
 Colors : word;
 Error  : Word;
  myPal :  Array[0..255,0..2] of Byte;
  cr : TRMColorRec;
  i : integer;
begin
 Colors:=GetMaxCOlor+1;
 Assign(F,FileName);
 Reset(F,1);
 Fsize:=FIleSize(F);
 If (Fsize<>48) AND (Fsize<>768) then
 begin
  ReadPAL:=1000;
  Exit;
 end;
 BlockRead(F,myPAL,Fsize);
 Close(F);
 Error:=IORESULT;
 ReadPAl:=Error;
 If Error = 0 then
 begin
  If Colors > (Fsize div 3) then
  begin
    Colors:=(Fsize div 3);
  end;
  //SetPaletteList(myPal,Colors);
  for i:=0 to Colors-1 do
     begin
       cr.r:=mypal[i,0];
       cr.g:=mypal[i,1];
       cr.b:=mypal[i,2];

       RMCoreBase.Palette.SetColor(i,cr);
     end;
 end;
end;

begin
end.
