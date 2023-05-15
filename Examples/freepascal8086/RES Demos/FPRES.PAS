(* fpimg.RES was exported from Raster Master using RES Binary File
   and converted from fpimg.RES to fpimg.OBJ using RtBinObj utility.
   The following res functions allow access to all the data in the
   original fpimg.RES file.

   compile with: ppcross8086 -WmLarge FPRES.PAS 

   see video for example usage
*)

Program FPRES;
  uses Graph,dos;

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


{$L FPIMG.OBJ}
//procedure FPIMG; EXTERNAL; //make sure procedure name is uppercase if public name is uppercase
procedure fpimg; external name 'FPIMG';

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
 while (length(s)>0) and (s[length(s)]=#32) do
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

procedure setrespal;
type
 paltype = array[0..47] of byte;
var
  i : integer;
  c : integer;
  pal : ^paltype;
begin
 pal:=GetResImagePtr(@fpimg,GetResIndex(@fpimg,'squarePal'));
 c:=0;
 for i:=0 to 15 do
 begin
  // setrgbpalette takes 8 bit values 0 to 255 - unlike Turbo Pascal 0 to 63
  // we shift the 6 bit values and turn them to 8 bit values
  // you can also select palette format from Raster Master to be 8 bit without 
  // doing any bit shifting
  setrgbpalette(i,pal^[c] shl 2,pal^[c+1] shl 2,pal^[c+2] shl 2);
  inc(c,3);
 end;
end;

var
 gd,gm : integer;
     i : integer;
begin
 gd:=VGA;
 gm:=VGAHI;
 initgraph(gd,gm,'');

 for i:=0 to 15 do
 begin
   setfillstyle(solidfill,i);
   bar(i*20,20,i*20+19,180);
 end;
 readln;
 setrespal;
 readln;
 putimage(200, 20, GetResImagePtr(@fpimg, GetResIndex(@fpimg, 'squareMask'))^, ANDput);
 putimage(200, 20, GetResImagePtr(@fpimg, GetResIndex(@fpimg, 'square'))^, ORput);

 putimage(100, 20, GetResImagePtr(@fpimg, GetResIndex(@fpimg, 'circleMask'))^, ANDput);
 putimage(100, 20, GetResImagePtr(@fpimg, GetResIndex(@fpimg, 'circle'))^, ORput);

 putimage(150, 20, GetResImagePtr(@fpimg, GetResIndex(@fpimg, 'crossMask'))^, ANDput);
 putimage(150, 20, GetResImagePtr(@fpimg, GetResIndex(@fpimg, 'cross'))^, ORput);
 readln;
 closegraph;
end.
