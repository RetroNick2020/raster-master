(* Saving a file from Raster Master as a BGF file and using the BINOBJ
   program to convert it to an object file allows you to include
   the image as a part of your executable.

   eg.

   DOS>BINOBJ DISK.BGF DISK.OBJ DISK


   Using the above format we create a procedure name DISK and
   link the object file.

   Procedure Disk; External;
   {$L DISK.OBJ}


   Because the PutImage procedure requires that the Image be in a pointer,
   we transfer the address of the procedure to a pointer. To display the
   Image use the PutImage procedure.

   Remarks: Do not try to use the FreeMem function on the pointer
            that the image resides in. Memory is already allocated
            at runtime. Your image resides in the code segment of
            your executable.  Use this method when you have many
            images rather than the method described in Demo5.pas.

*)


Program Demo6;
 Uses Graph;
Var
 Gd   : Integer;
 Gm   : Integer;
 Img  : Pointer;

Procedure Disk; External;
{$L DISK.OBJ}

Begin
 Gd:=EGA;
 Gm:=EGAhi;
 InitGraph(Gd,Gm,'');

 Img:=@Disk;                               (* Pass the Address of the *)
                                           (* Procedure to a pointer. *)

 PutImage(300,120,Img^,NormalPut);         (* Display Image *)

 ReadLn;                                   (* Wait for Enter Key *)

 CloseGraph;                               (* Close graphics *)
End.