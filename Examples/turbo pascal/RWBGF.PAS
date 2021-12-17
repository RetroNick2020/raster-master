Unit RWbgf;

Interface

 Function ReadBGF(Filename  : String; Var Img : Pointer) : Word;
 Procedure WriteBGF(Filename : String; X1,Y1,X2,Y2 : Word; Img : Pointer);


Implementation
     Uses Graph;

 Function ReadBGF(Filename : String; Var Img : Pointer): Word;
 Var
  F    : File;
  Size : Word;
 Begin
  Assign(F,Filename);
  Reset(F,1);
  Size:=FileSize(F);
  GetMem(Img,Size);
  BlockRead(F,Img^,Size);
  Close(F);
  ReadBGF:=Size;
 End;


 Procedure WriteBGF(Filename : String; X1,Y1,X2,Y2 : Word; Img : Pointer);
 Var
  F    : File;
  Size : Word;
 Begin
  Size:=ImageSize(X1,Y1,X2,Y2);
  Assign(F,Filename);
  Rewrite(F,1);
  BlockWrite(F,Img^,Size);
  Close(F);
 End;

Begin
 (* No startup code Needed *)
End.

