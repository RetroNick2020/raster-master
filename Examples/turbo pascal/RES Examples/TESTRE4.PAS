Program TestRE4;
 Uses graph;

type
 reshead = Record
            sig : array[1..3] of char;
            ver : byte;
            resitemcount: integer;
           end;

 resrec = Record
             rt     : integer;
             rid    : array[1..20] of char;
             offset : longint;
             size   : longint;
          end;



procedure resimages; external;
{$L resimage.obj }

type
 ResMemRec = Record
              head   : reshead;
              image  : array[1..1] of resrec;
             end;

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
 (* writeln(recItems^.head.sig);*)
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

Var
 gd, gm : integer;
Begin
 gd:=ega;
 gm:=egalo;
(*
 writeln(GetResCount(@resimages));
 writeln(GetResName(@resimages,4));
 readln;
*)

 initgraph(gd,gm,'c:\tp7\bgi');
 putimage(100,10,GetResImagePtr(@resimages,1)^,0);
 putimage(100,110,GetResImagePtr(@resimages,GetResIndex(@resimages,'Image4'))^,0);

 readln;
 closegraph;
end.
