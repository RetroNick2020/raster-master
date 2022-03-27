// shapes2.inc was exported from Raster Master using RES Binary File
// and converted from shapes.res to shapes2.inc using bin2obj command
// the following res functions allow access to all the data in the
// original shapes.res file
// see video for example usage

Program fpresdemo2;
  uses  ptccrt,ptcgraph;

type
 reshead = packed Record
            sig : array[1..3] of char;
            ver : byte;
            resitemcount: integer;
           end;

 resrec = packed Record
             rt     : integer;
             rid    : array[1..20] of char;
             offset : longint;
             size   : longint;
          end;

 ResMemRec = packed Record
              head   : reshead;
              image  : array[1..1] of resrec;
             end;


{$I shapes2.inc}

{$R-}
Function GetResImagePtr(ResPtr : Pointer; index : integer) : pointer;
var
 RecItems : ^ResMemRec;
 ImgPtr   : ^Byte;
 Size     : Longint;
 i        : integer;
begin
 RecItems:=ResPtr;
 ImgPtr:=ResPtr;
 Size:=sizeof(reshead)+sizeof(resrec)*recItems^.head.resitemcount;

 for i:=1 to index-1 do
 begin
   Inc(Size,recItems^.image[i].size);
   end;
 inc(ImgPtr,Size);
 GetResImagePtr:=ImgPtr;
end;

procedure DelSpaces(var s : string);
begin
 while s[length(s)]=#32 do
 begin
   delete(s,length(s),1);
 end;
end;

Function GetResCount(ResPtr : Pointer) : integer;
var
 RecItems : ^ResMemRec;
begin
 RecItems:=ResPtr;
 GetResCount:=recItems^.head.resitemcount;
end;

Function GetResSig(ResPtr : Pointer) : string;
var
 RecItems : ^ResMemRec;
begin
 RecItems:=ResPtr;
 GetResSig:=recItems^.head.sig;
end;

Function GetResName(ResPtr : Pointer; index : integer) : string;
var
 RecItems : ^ResMemRec;
 name : string;
begin
 RecItems:=ResPtr;
 if index > GetResCount(ResPtr) then
    name:=''
 else name:=recItems^.image[index].rid;
 DelSpaces(name);
 GetResName:=name;
end;

Function GetResIndex(ResPtr : Pointer; Name : string) : integer;
var
 RecItems : ^ResMemRec;
 i        : integer;
 rid      : string;
begin
 RecItems:=ResPtr;
 for i:=1 to recItems^.head.resitemcount do
 begin
   rid:=recItems^.image[i].rid;
   delspaces(rid);
   if name = rid then
   begin
     GetResIndex:=i;
     exit;
   end;
 end;
 GetResIndex:=0;
end;
{$R+}

procedure setpal;
type
 paltype = array[0..47] of byte;
var
  i : integer;
  c : integer;
  pal : ^paltype;
begin
 pal:=GetResImagePtr(@resimages2,GetResIndex(@resimages2,'girlPal'));
 c:=0;
 for i:=0 to 15 do
 begin
  setrgbpalette(i,pal^[c],pal^[c+1],pal^[c+2]);
  inc(c,3);
 end;
end;

procedure waitforkey;
begin
 repeat until keypressed;
end;

var
 gd,gm : integer;

begin
 gd:=VGA;
 gm:=VGAHI;
 initgraph(gd,gm,'');


 setpal;
 SetFillStyle(xHatchFill,Green);
 Bar(10,10,400,400);
 putimage(10,10,GetResImagePtr(@resimages2,GetResIndex(@resimages2,'Image1Mask'))^,andput);
 putimage(10,10,GetResImagePtr(@resimages2,GetResIndex(@resimages2,'Image1'))^,orput);

 putimage(200,10,GetResImagePtr(@resimages2,6)^,andPut);
 putimage(200,10,GetResImagePtr(@resimages2,5)^,orPut);

 putimage(300,110,GetResImagePtr(@resimages2,GetResIndex(@resimages2,'girlMask'))^,andPut);
 putimage(300,110,GetResImagePtr(@resimages2,GetResIndex(@resimages2,'girl'))^,orPut);

 waitforkey;
 closegraph;
end.
