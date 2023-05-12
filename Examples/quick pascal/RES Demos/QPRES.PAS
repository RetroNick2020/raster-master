(* QPIMG.RES was exported from Raster Master using RES Binary File
   and converted from QPIMG.RES to QPIMG.OBJ using RtBinObj utility.
   The following res functions allow access to all the data in the
   original QPIMG.RES file.

   see video for example usage
*)

Program QPRES;
  uses MSGRAPH;

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


{$L QPIMG.OBJ}
procedure QPIMG; EXTERNAL;


{$R-}
Function GetResImagePtr(ResPtr : Pointer; index : integer) : pointer;
var
 RecItems : ^ResMemRec;
 ImgPtr   : ^Byte;
 Size     : Longint;
 i        : integer;
 ImgA     : Longint;
begin
 RecItems:=ResPtr;
 ImgPtr:=ResPtr;
 Size:=sizeof(reshead)+sizeof(resrec)*recItems^.head.resitemcount;

 for i:=1 to index-1 do
 begin
   Inc(Size,recItems^.image[i].size);
   end;
  inc(LongInt(ImgPtr),Size);
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
procedure setrgb(index, r, g, b : integer);
var
 result : longint;
begin
  result:=_remappalette(index,(r+(longint(g) SHL 8) + (longint(b) SHL 16)));
end;



procedure setrespal;
type
 paltype = array[0..47] of byte;
var
  i : integer;
  c : integer;
  pal : ^paltype;
begin
 pal:=GetResImagePtr(@QPIMG,GetResIndex(@QPIMG,'squarePal'));
 c:=0;
 for i:=0 to 15 do
 begin
  setrgb(i,pal^[c],pal^[c+1],pal^[c+2]);

  inc(c,3);
 end;
end;

var
  i : integer;
  result : longint;
begin
 result:=_setvideomode(_VRES16COLOR);
 for i:=0 to 15 do
 begin
   _setcolor(i);
   _rectangle(_GFILLINTERIOR,i*20,20,i*20+19,180);
 end;
 readln;
 setrespal;
 readln;
 _putimage(200, 20, GetResImagePtr(@qpimg, GetResIndex(@qpimg, 'squareMask'))^, _GAND);
 _putimage(200, 20, GetResImagePtr(@qpimg, GetResIndex(@qpimg, 'square'))^, _GOR);

 _putimage(100, 20, GetResImagePtr(@qpimg, GetResIndex(@qpimg, 'circleMask'))^, _GAND);
 _putimage(100, 20, GetResImagePtr(@qpimg, GetResIndex(@qpimg, 'circle'))^, _GOR);

 _putimage(150, 20, GetResImagePtr(@qpimg, GetResIndex(@qpimg, 'crossMask'))^, _GAND);
 _putimage(150, 20, GetResImagePtr(@qpimg, GetResIndex(@qpimg, 'cross'))^, _GOR);
 readln;
 result:=_setvideomode(_DEFAULTMODE);
end.
