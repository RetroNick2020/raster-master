unit wmodex;
interface
 uses bits;

 type
   linebuftype = array[0..2047] of byte;

 function BPLModeX(width : integer) : integer;
 Procedure SinglePlaneToModeXPlane(var sp,mp : linebuftype; width : integer);

implementation
(*
                        +--+--+--+--+-------------------------+
Plane 3                 |10|00|00|00|...                      |
                   +--+--+--+--+-------------------------+    |
Plane 2            |00|00|00|00|...                      |    |
              +--+--+--+--+-------------------------+    |
Plane 1       |11|00|00|00|...                      |    |
         +--+--+--+--+-------------------------+    |
Plane 0  |01|00|00|00|...                      |    |
         ---------------------------------------
The above diagram is not very good, but it should convey the general idea 
behind what is termed PLANAR memory addressing. This is the method used 
by Mode X and also by EGA/VGA 16 colour modes, so theory on this type of 
addressing should be fairly abundant. In the diagram, the pixel at 
coordinates (0,0) has a colour value of 10001101 in binary or 141 in decimal. 
Notice how this value is spread across the four video planes; 
bits 0&1 are on plane 0, bits 2&3 are on plane 1, 4&5 on plane 2, etc. 
The next pixel (at coordinates (1,0)) has bits 0&1 back on plane 0 and are 
stored directly after the first pixel's bits 0&1.
*)

function GetBitPairs(inByte,bp : byte) : byte;
var
 myPair : byte;
begin
  Case bp of 1:begin
                 myPair:=inByte SHR 6;
               end;
             2:begin
                 myPair:=(inByte SHL 2) SHR 6;
               end;    
             3:begin
                 myPair:=(inByte SHL 4) SHR 6;
               end;    
             4:begin
                 myPair:=(inByte SHL 6) SHR 6;
               end;    
  end;
  GetBitPairs:=myPair;
end;

(*
Function BitOn(Position,Testbyte : Byte) : Boolean;
Procedure SetBit(Position, Value : Byte; Var Changebyte : Byte);
*)
procedure SetBitPairs(Var dest : byte; bp, v : byte);
begin
 Case bp of 1:begin
                  if Biton(0,v) then SetBit(6,1,dest);
                  if Biton(1,v) then SetBit(7,1,dest);
               end;
             2:begin
                  if Biton(0,v) then SetBit(4,1,dest);
                  if Biton(1,v) then SetBit(5,1,dest);
               end;    
             3:begin
                  if Biton(0,v) then SetBit(2,1,dest);
                  if Biton(1,v) then SetBit(3,1,dest);
               end;    
             4:begin
                  if Biton(0,v) then SetBit(0,1,dest);
                  if Biton(1,v) then SetBit(1,1,dest);
               end;    
  end;
end;
(* Bytes Per Line for Single Plane *)
function BPLModeX(width : integer) : integer;
begin
  BPLModeX:=((width+3) * 2) div 8;
end;

Procedure SinglePlaneToModeXPlane(var sp,mp : linebuftype; width : integer);
var
 i   : integer;
 col : byte;
 p0,p1,p2,p3 : byte;
 BPL0,BPL1,BPL2,BPL3 : integer;
 bpc,bpOffset : integer;
begin
 BPL0:=0;
 BPL1:=BPLModeX(width);
 BPL2:=BPL1*2;
 BPL3:=BPL1*3;
 
 bpc:=1;
 bpOffset:=0;
 for i:=0 to width-1 do
 begin
   col:=sp[i];
   p3:=GetBitPairs(col,1); (* XX000000  *)
   p2:=GetBitPairs(col,2); (* 00XX0000  *)
   p1:=GetBitPairs(col,3); (* 0000XX00  *)
   p0:=GetBitPairs(col,4); (* 000000XX  *)

   SetBitPairs(mp[BPL0+bpOffset],bpc,p0); (* Plain 0 *)
   SetBitPairs(mp[BPL1+bpOffset],bpc,p1); (* Plain 1 *)
   SetBitPairs(mp[BPL2+bpOffset],bpc,p2); (* Plain 2 *)
   SetBitPairs(mp[BPL3+bpOffset],bpc,p3); (* Plain 3 *)

   inc(bpc);
   if bpc > 4 then 
   begin
     bpc:=1;
     inc(bpOffset);
   end;  
 end;  
end;

begin
end.


