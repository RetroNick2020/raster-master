(*

   ----------------------------------------------------------
   WriteBgf procedure                                   RWBgf
   ----------------------------------------------------------

   Function   : Writes an image as a BGF file.

   Decloration: WriteBgf(Filename : String; X1,Y1,X2,Y2 : Word; Img : Pointer)

   Remarks    : I/O checking is NOT performed.
                Images cannot be more than 64K.
                Images that are more than 100 pixels
                in width or height cannot be loaded
                in Raster Master.

*)




Program Demo2;
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

 SetFillStyle(SlashFill,LightGray);        (* Draw something to save *)
 Bar(2,2,49,49);
 SetColor(White);
 Rectangle(1,1,50,50);
 SetColor(LightGreen);
 OutTextXY(2,10,'RASTER');
 OutTextXY(2,30,'MASTER');

 Size:=ImageSize(1,1,50,50);               (* Grab the Image *)
 GetMem(Img,Size);
 GetImage(1,1,50,50,Img^);

 WriteBgf('BOX.BGF',1,1,50,50,Img);        (* Save the Image *)

 FreeMem(Img,Size);                        (* Release the memory *)

 ReadLn;                                   (* Wait for Enter Key *)

 CloseGraph;                               (* Close graphics *)
End.