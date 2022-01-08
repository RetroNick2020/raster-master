Program TestRE3;
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


Var
 gd, gm : integer;
Begin
 gd:=ega;
 gm:=egalo;
 initgraph(gd,gm,'c:\tp7\bgi');

 putimage(100,10,GetResImagePtr(@resimages,1)^,0);
 readln;
 closegraph;
end.
