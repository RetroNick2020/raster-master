Unit RWDef;

Interface

 Procedure ReadDef(Filename : String; X,Y : Word);
 Procedure WriteDef(Filename    : String; X1,Y1,X2,Y2 : Word);

Implementation
    Uses Graph;

 Procedure ReadDef(Filename : String; X,Y : Word);
 Var
  F  : Text;
  Ch : Char;
  Col: Word;
  SX : Word;
 Begin
   SX:=X;
   Assign(F,Filename);
   Reset(F);
   Repeat
     Ch:=' ';
     Repeat
      Read(F,Ch);                                  (*Read a character *)
      Col:=0;
      Case Ord(Ch) of 48..57:Begin
                              Col:=Ord(Ch)-48;     (*Convert Hex character to*)
                              PutPixel(SX,Y,Col);  (*number. From 0 to 9 *)
                             End;
                      65..70:Begin
                              Col:=Ord(Ch)-55;     (*Convert Hex character to*)
                              PutPixel(SX,Y,Col);  (*number. From 10 to 15 *)
                             End;

      End;
      Inc(SX);
     Until Ch=chr(13);  (*Keep repeating the loop until we hit a carriage return*)
     Read(F,Ch);        (*This character should be a line feed, we just read it*)
     Inc(Y);            (*Increase Y by 1*)
     SX:=X;             (*Set SX to X*)
   Until Eof(F);        (*Keep repeating until we reach the end of the file*)
   Close(F);
 End;

 Procedure WriteDef(Filename    : String; X1,Y1,X2,Y2 : Word);
 Const
  Hex : array[0..15] of char = ('0','1','2','3','4','5','6','7','8','9',
                                'A','B','C','D','E','F');
 Var
  F   : Text;
  I   : Word;
  J   : Word;
  Col : Word;
 Begin
  Assign(F,Filename);
  Rewrite(F);
  For J:=Y1 to Y2 do
  Begin
   For I:=X1 to X2 do
   begin
     Col:=GetPixel(I,J);
     Write(F,Hex[Col]);
   End;
   Writeln(F);
  End;
  Close(F);
 End;

Begin
End.