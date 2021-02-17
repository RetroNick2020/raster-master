unit Flood;
{$mode objfpc}{$H+}
//{$mode TP}

interface
 uses
  Classes, SysUtils,RMCore;

Procedure Fill(xx,yy,NColor: Word);
implementation

Procedure Fill(xx,yy,NColor: Word);
const
 Left =1;
 right=2;
 up   =3;
 down =4;
 StackMax = 10000;
//Type
// stype = Array[0..10000] of byte;
// stypePtr=^Stype;
Var
 StackHolderX : Array[0..StackMax] of Integer;
 StackHolderY :  Array[0..StackMax] of Integer;
 StackHolderPos :  Array[0..StackMax] of Integer;
 sthnum    : word;
 pp        : Word;
 coltofill : Word;


Procedure AddToStack(nx,ny,np : integer);
begin
  if (sthnum >= StackMax) then exit;
  inc(sthnum);
  StackHolderx[sthnum]:=nx;
  StackHoldery[sthnum]:=ny;
  StackHolderpos[sthnum]:=np;
end;

Procedure CheckRight;
begin
if xx<255 then
begin
if RMCoreBase.getpixel(xx+1,yy) = ColTofill  then
//IconImage[xx+1,yy] = ColTofill then
   begin
(*   Pplot2(xx+1,yy,false);*)
//   IconImage[xx+1,yy] :=Ncolor;
    RMCoreBase.putpixel(xx+1,yy,Ncolor);

  // inc(sthnum);
 //  StackHolderx[sthnum]:=xx+1;
 //  StackHoldery[sthnum]:=yy;
 //  StackHolderpos[sthnum]:=Right;

 AddToStack(xx+1,yy,Right);
end;
end;
end;


Procedure CheckLeft;
Begin
if xx >0 then
begin
//if IconImage[xx-1,yy] = ColTofill then
if RMCoreBase.GetPixel(xx-1,yy) = ColTofill then

begin
(*     Pplot2(xx-1,yy,false);*)
//     IconImage[xx-1,yy]:=Ncolor;
    RMCoreBase.PutPixel(xx-1,yy,Ncolor);

//    inc(sthnum);
//   StackHolderx[sthnum]:=xx-1;
//   StackHoldery[sthnum]:=yy;
//   StackHolderpos[sthnum]:=left;
     AddToStack(xx-1,yy,Left);

end;
end;
end;

Procedure CheckUp;
begin
if yy>0 then
begin
//if IconImage[xx,yy-1] = ColTofill then
  if RMCoreBase.GetPixel(xx,yy-1) =ColTofill then
  begin
(*   Pplot2(xx,yy-1,false);*)
//   IconImage[xx,yy-1]:=Ncolor;
   RMCoreBase.PutPixel(xx,yy-1,Ncolor);

//   inc(sthnum);
//   StackHolderx[sthnum]:=xx;
//   StackHoldery[sthnum]:=yy-1;
//   StackHolderpos[sthnum]:=up;
     AddToStack(xx,yy-1,up);

end;
end;

end;

Procedure CheckDown;
begin
if yy<255 then
begin
//If IconImage[xx,yy+1]=ColTofill then
   If RMCoreBase.GetPixel(xx,yy+1)=ColTofill then
   begin
(*    Pplot2(xx,yy+1,false);*)
//    IconImage[xx,yy+1]:=Ncolor;
     RMCoreBase.PutPixel(xx,yy+1,Ncolor);

 //   inc(sthnum);
 //   StackHolderx[sthnum]:=xx;
 //   StackHoldery[sthnum]:=yy+1;
 //   StackHolderpos[sthnum]:=down;

  AddToStack(xx,yy+1,down);

end;
end;
end;

Procedure GetColortoFill;
begin
//ColToFill:=IconImage[xx,yy];
ColToFill:=RMCoreBase.GetPixel(xx,yy);

end;



Procedure GetNewCord;
begin
 if sthnum > 0 then
 begin
  xx:=StackHolderx[sthnum];
  yy:=StackHoldery[sthnum];
  pp:=StackHolderpos[sthnum];
  dec(sthnum);
 end;
end;




begin
//GetMem(StackHolderX,SizeOf(Stype));
//GetMem(StackHolderY,SizeOf(Stype));
//GetMem(StackHolderPos,SizeOf(Stype));


//FillChar(StackHolderX,SizeOf(StackHolderX),0);
//FillChar(StackHolderY,SizeOf(StackHolderY),0);
//FillChar(StackHolderPos,SizeOf(StackHolderPos),0);

sthnum:=1;
GetColorTofill;
If ColToFill = NColor then exit;
//IconImage[xx,yy]:=Ncolor;
RMCoreBase.PutPixel(xx,yy,Ncolor);

Repeat
 case pp of
 Left: begin
          CheckLeft;
          CheckDown;
          Checkup;
      end;
 Right:begin
          CheckRight;
          CheckUp;
          CheckDown;
       end;
 Up:   begin
           CheckRight;
           CheckLeft;
           Checkup;
       end;
 Down: begin
           CheckDown;
           CheckRight;
           CheckLeft;
       end;
 else
    begin
           CheckRight;
           CheckUP;
           CheckDown;
           CheckLeft;
    end;
 end;
 GetNewCord;
Until sthnum=0;
//FreeMem(StackHolderX,SizeOf(Stype));
//FreeMem(StackHolderY,SizeOf(Stype));
//FreeMem(StackHolderPos,SizeOf(Stype));

end;
end.

