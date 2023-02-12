(* Saving a file from Raster Master as a CON allows you to easily
   included as a part of your executable. All images saved in this
   format will be constants. The file is than inserted in the Const
   part of your program.  Because the PutImage procedure requires
   that the Image be in a pointer, we transfer the address of the
   constant to a pointer. To display the Image use the PutImage
   procedure.

   Remarks: Do not try to use the FreeMem function on the pointer
            that the image resides in. Memory is already allocated
            at runtime. Your image resides in the data segment of
            your executable.  Use this method when you have a few
            images. The data segment is limited to 64K. Use the
            method described in Demo6.pas if you require more than
            64K.

*)

Program Demo5;
 Uses Graph;
Const
{$I PAC.CON}
Var
 Gd   : Integer;
 Gm   : Integer;
 Img  : Pointer;
Begin
 Gd:=EGA;
 Gm:=EGAhi;
 InitGraph(Gd,Gm,'');

 Img:=@PacImage;                           (* Pass the Address of the*)
                                           (* PacImage constant to  *)
                                           (* a pointer.             *)

 PutImage(300,120,Img^,NormalPut);         (* Display Image *)

 ReadLn;                                   (* Wait for Enter Key *)

 CloseGraph;                               (* Close graphics *)
End.