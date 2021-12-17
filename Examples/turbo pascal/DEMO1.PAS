(*

   ----------------------------------------------------------
   ReadBgf function                                     RWBgf
   ----------------------------------------------------------

   Function   : Reads a BGF file in memory.

   Decloration: ReadBgf(Filename : String; Var Img : Pointer)

   Result type: Word

   Remarks    : This function automatically allocates the
                required memory and reads in the Image.
                The return value is the size of the Image.
                NO checking is done to verify that the file
                being loaded is a valid BGF file.  I/O
                checking is NOT performed.
*)




Program Demo1;
 Uses Graph,RWBgf;
Var
 Img  : Pointer;
 Size : Word;
 Gd   : Integer;
 Gm   : Integer;
Begin
 Gd:=EGA;
 Gm:=EGAhi;
 InitGraph(Gd,Gm,'');
 Size:=ReadBgf('GCAR.BGF',Img);
 PutImage(300,120,Img^,NormalPut);
 FreeMem(Img,Size);
 Readln;
 CloseGraph;
End.