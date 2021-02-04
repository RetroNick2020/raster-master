Unit Bits;

Interface
Function BitOn(Position,Testbyte : Byte) : Boolean;
Procedure SetBit(Position, Value : Byte; Var Changebyte : Byte);

Implementation
Function BitOn(Position,Testbyte : Byte) : Boolean;
Var
  Bt : Byte;
Begin
  Bt :=$01;
  Bt :=Bt Shl Position;
  Biton :=(Bt And Testbyte) > 0;
End;

Procedure SetBit(Position, Value : Byte; Var Changebyte : Byte);
Var
  Bt : Byte;
Begin
  Bt :=$01;
  Bt :=Bt Shl Position;
  If Value = 1 then
     Changebyte :=Changebyte Or Bt
  Else
   Begin
     Bt :=Bt Xor $FF;
     Changebyte :=Changebyte And Bt;
  End;
End;

begin
end.