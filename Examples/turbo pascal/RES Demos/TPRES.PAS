(* tpimg.RES was exported from Raster Master using RES Binary File
   and converted from tpimg.RES to tpimg.OBJ using RtBinObj utility.
   The following res functions allow access to all the data in the
   original tpimg.RES file.

   see video for example usage
*)

Program TPRES;
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


{$L TPIMG.OBJ}
procedure TPIMG; EXTERNAL;


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

(* r,g,b values 0 to 63 *)
Procedure SetRGB(Index,R,G,B : integer);
Var
  reg : registers;
Begin

if (GetMaxColor=15) AND (index <16) then
begin
 Reg.ah := $10;
 Reg.al := $0;
 Reg.bl := index;
 Reg.bh := index;
 intr ($10, Reg);
end;

 Reg.ah := $10;
 Reg.al := $10;
 Reg.bx := index;
 Reg.dh := R;
 Reg.ch := G;
 Reg.cl := B;
 intr ($10, Reg);
end;



procedure setrespal;
type
 paltype = array[0..47] of byte;
var
  i : integer;
  c : integer;
  pal : ^paltype;
begin
 pal:=GetResImagePtr(@tpimg,GetResIndex(@tpimg,'squarePal'));
 c:=0;
 for i:=0 to 15 do
 begin
  setrgb(i,pal^[c],pal^[c+1],pal^[c+2]);
  inc(c,3);
 end;
end;

var
 gd,gm : integer;
     i : integer;
begin
 gd:=VGA;
 gm:=VGAHI;
 initgraph(gd,gm,'c:\tp7\bgi');

 for i:=0 to 15 do
 begin
   setfillstyle(solidfill,i);
   bar(i*20,20,i*20+19,180);
 end;
 readln;
 setrespal;
 readln;
 putimage(200, 20, GetResImagePtr(@tpimg, GetResIndex(@tpimg, 'squareMask'))^, ANDput);
 putimage(200, 20, GetResImagePtr(@tpimg, GetResIndex(@tpimg, 'square'))^, ORput);

 putimage(100, 20, GetResImagePtr(@tpimg, GetResIndex(@tpimg, 'circleMask'))^, ANDput);
 putimage(100, 20, GetResImagePtr(@tpimg, GetResIndex(@tpimg, 'circle'))^, ORput);

 putimage(150, 20, GetResImagePtr(@tpimg, GetResIndex(@tpimg, 'crossMask'))^, ANDput);
 putimage(150, 20, GetResImagePtr(@tpimg, GetResIndex(@tpimg, 'cross'))^, ORput);
 readln;
 closegraph;
end.
