{$mode TP}
{$PACKRECORDS 1}

Unit wprf;
 Interface
      uses rmcore,rwxgf;
 Function WritePPR(x,y,x2,y2 : word; filename : string) : word;
 Function WriteSPR(x,y,x2,y2 : word; filename : string) : word;

 Implementation

function GetMaxColor : integer;
begin
  GetMaxColor:=RMCoreBase.Palette.GetColorCount -1;
end;

Function WritePPR(x,y,x2,y2 : word;filename:string):word;
Var
 f       : file;
 rc      :byte;
 i,j     : word;
 col     : byte;
 lastcol : byte;
 myWidth : word;
 myHeight: word;
 nc      : byte;
 cl      : Array[1..3] of byte;
 error   : word;
 myPprHeader : Array[1..24] of byte;
begin
{$I-}
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;

 Fillchar(myPprHeader,24,0);

 myPprHeader[1]:=ORD('P');
 myPprHeader[4]:=ORD('P');
 myPprHeader[7]:=ORD('R');

 myPprHeader[10]:=HI(myWidth);
 myPprHeader[13]:=LO(myWidth);

 myPprHeader[16]:=HI(myHeight);
 myPprHeader[19]:=LO(myHeight);

 myPPrHeader[22]:=4;

 assign(F,filename);
 rewrite(f,1);

 BlockWrite(F,myPprHeader,24);


 nc:=0;
 rc:=0;
 fillchar(cl,3,0);

 for j:=y2 downto y do
 begin
   for i:=x to x2 do
   begin
//     col:=IconImage[i,j];
     col:=RMCoreBase.GetPixel(i,j);

     inc(rc);
     if rc=1 then
     begin
       Lastcol:=col;
     end
     else if col<>lastcol then
     begin
       inc(nc);
       if nc=1 then
       begin
        cl[1]:=(lastcol shl 4);
        cl[2]:=rc-1;
       end
       else if nc=2 then
       begin
        inc(cl[1],lastcol);
        cl[3]:=rc-1;
        nc:=0;
        Blockwrite(f,cl[1],3);
        fillchar(cl,3,0);
       end;
       rc:=1;
       lastcol:=col;
     end
     else if rc=255 then
     begin
      inc(nc);
      if nc=1 then
      begin
       cl[1]:=(col shl 4);
       cl[2]:=rc;
      end
      else if nc=2 then
      begin
       inc(cl[1],col);
       cl[3]:=rc;
       nc:=0;
       blockwrite(f,cl[1],3);
       fillchar(cl,3,0);
      end;
      rc:=0;
     end;
   end;


   error:=ioresult;
   if error<>0 then
   begin
     close(f);
     erase(f);
     WritePPR:=error;
     exit;
   end;


  end;
  if rc>0 then
  begin
      if nc=0 then
      begin
       cl[1]:=(col shl 4);
       cl[2]:=rc;
       cl[3]:=0;
      end
      else
       begin
        inc(cl[1],col);
        cl[3]:=rc;
      end;
      Blockwrite(f,cl,3);
  end;
 close(F);
 error:=IOresult;
 WritePPR:=error;
{$I+}
end;


Function WriteSPR(x,y,x2,y2 : word;filename:string):word;
Var
 f: file;
 rc:byte;
 i,j : word;
 col : byte;
 lastcol:byte;
 myWidth:word;
 myHeight:word;

 error : word;
 mySprHeader : Array[1..16] of byte;
begin
{$I-}

 myWidth:=x2-x+1;
 myHeight:=y2-y+1;

 Fillchar(mySprHeader,16,0);
 mySprHeader[1]:=ORD('S');
 mySprHeader[3]:=ORD('P');
 mySprHeader[5]:=ORD('R');

 mySprHeader[7]:=HI(myWidth);
 mySprHeader[9]:=LO(myWidth);

 mySprHeader[11]:=HI(myHeight);
 mySprHeader[13]:=LO(myHeight);


 If GetMaxColor = 255 then
 begin
  mySprHeader[15]:=8;
 end
 else
 begin
  mySprHeader[15]:=4;
 end;
 assign(F,filename);
 rewrite(f,1);

 BlockWrite(F,mySprHeader,16);

 rc:=0;
 for j:=y2 downto y do
 begin
   for i:=x to x2 do
   begin
//     col:=IconImage[i,j];
        col:=RMCoreBase.GetPixel(i,j);

     inc(rc);
     if rc=1 then
     begin
       Lastcol:=col;
     end
     else if col<>lastcol then
     begin
       Blockwrite(f,lastcol,1);
       dec(rc);
       Blockwrite(f,rc,1);
       rc:=1;
       lastcol:=col;
     end
     else if rc=255 then
     begin
      blockwrite(f,col,1);
      blockwrite(f,rc,1);
      rc:=0;
     end;
   end;

   error:=ioresult;
   if error<>0 then
   begin
    close(f);
    erase(f);
    WriteSPR:=error;
    exit;
   end;

  end;
  if rc>0 then
  begin
    blockwrite(f,col,1);
    blockwrite(f,rc,1);
  end;
 close(F);
 error:=ioresult;
 WriteSPR:=error;
{$I+}
end;

begin
end.
