Unit bgiPal;

 Interface


Type
   PaletteT = Array[0..255,0..2] of Byte;
   Pal16    = Array[0..15,0..2] of Byte;

Procedure SetRGBColorX(ColorN,R,G,B : Word);
Procedure GetRgbColorX(NColor : Word;Var R,G,B : Word);
Procedure PalEdit(xp,yp,CurColor : Word);
Procedure SetPaletteList(Var Pal : PaletteT; NColors : Word);
Procedure GrabPaletteList(Var Pal : PaletteT;NColors : Word);
Procedure GrabPalette16(Var myPal : Pal16 );
Procedure SetPalette16(Var myPal : Pal16 );
Procedure SetDefaultPalette;
Procedure dumpPalToDisk;
 Implementation
   uses dos,graph,bgiMouse,bgiMisc,bgiText,bgiImage,bgigadge;

const
(*
 defaultPal : PaletteT=(

          ($00,$00,$00),($00,$00,$2A),($00,$2A,$00),($00,$2A,$2A),
          ($2A,$00,$00),($2A,$00,$2A),($2A,$15,$00),($2A,$2A,$2A),
          ($15,$15,$15),($15,$15,$3F),($15,$3F,$15),($15,$3F,$3F),
          ($3F,$15,$15),($3F,$15,$3F),($3F,$3F,$15),($3F,$3F,$3F),
          ($3F,$3F,$3F),($3B,$3B,$3B),($36,$36,$36),($32,$32,$32),
          ($2E,$2E,$2E),($2A,$2A,$2A),($26,$26,$26),($21,$21,$21),
          ($1D,$1D,$1D),($19,$19,$19),($15,$15,$15),($11,$11,$11),
          ($0D,$0D,$0D),($08,$08,$08),($04,$04,$04),($08,$08,$08),
          ($3F,$36,$36),($3F,$2E,$2E),($3F,$27,$27),($3F,$1F,$1F),
          ($3F,$17,$17),($3F,$10,$10),($3F,$08,$08),($3F,$00,$00),
          ($39,$00,$00),($33,$00,$00),($2D,$00,$00),($27,$00,$00),
          ($21,$00,$00),($1C,$00,$00),($16,$00,$00),($10,$00,$00),
          ($3F,$3A,$36),($3F,$36,$2E),($3F,$32,$27),($3F,$2E,$1F),
          ($3F,$2A,$17),($3F,$26,$10),($3F,$22,$08),($3F,$1E,$00),
          ($39,$1B,$00),($33,$18,$00),($2D,$15,$00),($27,$13,$00),
          ($21,$10,$00),($1C,$0E,$00),($16,$0B,$00),($10,$08,$00),
          ($3F,$3F,$36),($3F,$3F,$2E),($3F,$3F,$27),($3F,$3F,$1F),
          ($3F,$3E,$17),($3F,$3D,$10),($3F,$3D,$08),($3F,$3D,$00),
          ($39,$36,$00),($33,$31,$00),($2D,$2B,$00),($27,$27,$00),
          ($21,$21,$00),($1C,$1B,$00),($16,$15,$00),($10,$10,$00),
          ($3E,$3F,$36),($3D,$3F,$2E),($3A,$3F,$27),($38,$3F,$1F),
          ($34,$3F,$17),($31,$3F,$10),($2D,$3F,$08),($28,$3F,$00),
          ($24,$39,$00),($20,$33,$00),($1D,$2D,$00),($18,$27,$00),
          ($14,$21,$00),($11,$1C,$00),($0D,$16,$00),($0A,$10,$00),
          ($36,$3F,$36),($2F,$3F,$2E),($27,$3F,$27),($20,$3F,$1F),
          ($18,$3F,$17),($10,$3F,$10),($08,$3F,$08),($00,$3F,$00),
          ($00,$39,$00),($01,$33,$00),($01,$2D,$00),($01,$27,$00),
          ($02,$21,$00),($01,$1C,$00),($01,$16,$00),($01,$10,$00),
          ($36,$3F,$3F),($2E,$3F,$3F),($27,$3F,$3F),($1F,$3F,$3E),
          ($17,$3F,$3F),($10,$3F,$3F),($08,$3F,$3F),($00,$3F,$3F),
          ($00,$39,$39),($00,$33,$33),($00,$2D,$2D),($00,$27,$27),
          ($00,$21,$21),($00,$1C,$1C),($00,$16,$16),($00,$10,$10),
          ($36,$3B,$3F),($2E,$38,$3F),($27,$35,$3F),($1F,$32,$3F),
          ($17,$2F,$3F),($10,$2C,$3F),($08,$2A,$3F),($00,$27,$3F),
          ($00,$23,$39),($00,$1F,$33),($00,$1B,$2D),($00,$17,$27),
          ($00,$13,$21),($00,$10,$1C),($00,$0C,$16),($00,$09,$10),
          ($36,$36,$3F),($2E,$2F,$3F),($27,$27,$3F),($1F,$20,$3F),
          ($17,$18,$3F),($10,$10,$3F),($08,$09,$3F),($00,$01,$3F),
          ($00,$01,$39),($00,$01,$33),($00,$00,$2D),($00,$00,$27),
          ($00,$00,$21),($00,$00,$1C),($00,$00,$16),($00,$00,$10),
          ($3C,$36,$3F),($39,$2E,$3F),($36,$27,$3F),($34,$1F,$3F),
          ($32,$17,$3F),($2F,$10,$3F),($2D,$08,$3F),($2A,$00,$3F),
          ($26,$00,$39),($20,$00,$33),($1D,$00,$2D),($18,$00,$27),
          ($14,$00,$21),($11,$00,$1C),($0D,$00,$16),($0A,$00,$10),
          ($3F,$36,$3F),($3F,$2E,$3F),($3F,$27,$3F),($3F,$1F,$3F),
          ($3F,$17,$3F),($3F,$10,$3F),($3F,$08,$3F),($3F,$00,$3F),
          ($38,$00,$39),($32,$00,$33),($2D,$00,$2D),($27,$00,$27),
          ($21,$00,$21),($1B,$00,$1C),($16,$00,$16),($10,$00,$10),
          ($3F,$3A,$37),($3F,$38,$34),($3F,$36,$31),($3F,$35,$2F),
          ($3F,$33,$2C),($3F,$31,$29),($3F,$2F,$27),($3F,$2E,$24),
          ($3F,$2C,$20),($3F,$29,$1C),($3F,$27,$18),($3C,$25,$17),
          ($3A,$23,$16),($37,$22,$15),($34,$20,$14),($32,$1F,$13),
          ($2F,$1E,$12),($2D,$1C,$11),($2A,$1A,$10),($28,$19,$0F),
          ($27,$18,$0E),($24,$17,$0D),($22,$16,$0C),($20,$14,$0B),
          ($1D,$13,$0A),($1B,$12,$09),($17,$10,$08),($15,$0F,$07),
          ($12,$0E,$06),($10,$0C,$06),($0E,$0B,$05),($0A,$08,$03),
          ($37,$00,$00),($35,$06,$00),($34,$0D,$00),($32,$13,$00),
          ($31,$18,$00),($30,$1D,$00),($2F,$23,$00),($2D,$27,$00),
          ($2C,$2B,$00),($20,$2B,$00),($13,$2A,$00),($07,$2A,$00),
          ($00,$29,$05),($00,$28,$10),($00,$28,$1C),($00,$28,$25),
          ($00,$23,$29),($00,$1B,$2A),($00,$12,$2A),($00,$0A,$2B),
          ($13,$00,$2E),($1B,$00,$2E),($21,$00,$2E),($29,$00,$2E),
          ($2E,$00,$2B),($2E,$00,$23),($2E,$00,$1D),($2E,$00,$16),
          ($2E,$00,$0E),($2F,$00,$08),($2F,$00,$00),($3F,$3F,$3F));

*)

 defaultPal : PaletteT=(
(  0,  0,  0),(  0,  0, 42),(  0, 42,  0),(  0, 42, 42),
( 42,  0,  0),( 42,  0, 42),( 42, 21,  0),( 42, 42, 42),( 21, 21, 21),
( 21, 21, 63),( 21, 63, 21),( 21, 63, 63),( 63, 21, 21),( 63, 21, 63),
( 63, 63, 21),( 63, 63, 63),(  0,  0,  0),(  5,  5,  5),(  8,  8,  8),
( 11, 11, 11),( 14, 14, 14),( 17, 17, 17),( 20, 20, 20),( 24, 24, 24),
( 28, 28, 28),( 32, 32, 32),( 36, 36, 36),( 40, 40, 40),( 45, 45, 45),
( 50, 50, 50),( 56, 56, 56),( 63, 63, 63),(  0,  0, 63),( 16,  0, 63),
( 31,  0, 63),( 47,  0, 63),( 63,  0, 63),( 63,  0, 47),( 63,  0, 31),
( 63,  0, 16),( 63,  0,  0),( 63, 16,  0),( 63, 31,  0),( 63, 47,  0),
( 63, 63,  0),( 47, 63,  0),( 31, 63,  0),( 16, 63,  0),(  0, 63,  0),
(  0, 63, 16),(  0, 63, 31),(  0, 63, 47),(  0, 63, 63),(  0, 47, 63),
(  0, 31, 63),(  0, 16, 63),( 31, 31, 63),( 39, 31, 63),( 47, 31, 63),
( 55, 31, 63),( 63, 31, 63),( 63, 31, 55),( 63, 31, 47),( 63, 31, 39),
( 63, 31, 31),( 63, 39, 31),( 63, 47, 31),( 63, 55, 31),( 63, 63, 31),
( 55, 63, 31),( 47, 63, 31),( 39, 63, 31),( 31, 63, 31),( 31, 63, 39),
( 31, 63, 47),( 31, 63, 55),( 31, 63, 63),( 31, 55, 63),( 31, 47, 63),
( 31, 39, 63),( 45, 45, 63),( 49, 45, 63),( 54, 45, 63),( 58, 45, 63),
( 63, 45, 63),( 63, 45, 58),( 63, 45, 54),( 63, 45, 49),( 63, 45, 45),
( 63, 49, 45),( 63, 54, 45),( 63, 58, 45),( 63, 63, 45),( 58, 63, 45),
( 54, 63, 45),( 49, 63, 45),( 45, 63, 45),( 45, 63, 49),( 45, 63, 54),
( 45, 63, 58),( 45, 63, 63),( 45, 58, 63),( 45, 54, 63),( 45, 49, 63),
(  0,  0, 28),(  7,  0, 28),( 14,  0, 28),( 21,  0, 28),( 28,  0, 28),
( 28,  0, 21),( 28,  0, 14),( 28,  0,  7),( 28,  0,  0),( 28,  7,  0),
( 28, 14,  0),( 28, 21,  0),( 28, 28,  0),( 21, 28,  0),( 14, 28,  0),
(  7, 28,  0),(  0, 28,  0),(  0, 28,  7),(  0, 28, 14),(  0, 28, 21),
(  0, 28, 28),(  0, 21, 28),(  0, 14, 28),(  0,  7, 28),( 14, 14, 28),
( 17, 14, 28),( 21, 14, 28),( 24, 14, 28),( 28, 14, 28),( 28, 14, 24),
( 28, 14, 21),( 28, 14, 17),( 28, 14, 14),( 28, 17, 14),( 28, 21, 14),
( 28, 24, 14),( 28, 28, 14),( 24, 28, 14),( 21, 28, 14),( 17, 28, 14),
( 14, 28, 14),( 14, 28, 17),( 14, 28, 21),( 14, 28, 24),( 14, 28, 28),
( 14, 24, 28),( 14, 21, 28),( 14, 17, 28),( 20, 20, 28),( 22, 20, 28),
( 24, 20, 28),( 26, 20, 28),( 28, 20, 28),( 28, 20, 26),( 28, 20, 24),
( 28, 20, 22),( 28, 20, 20),( 28, 22, 20),( 28, 24, 20),( 28, 26, 20),
( 28, 28, 20),( 26, 28, 20),( 24, 28, 20),( 22, 28, 20),( 20, 28, 20),
( 20, 28, 22),( 20, 28, 24),( 20, 28, 26),( 20, 28, 28),( 20, 26, 28),
( 20, 24, 28),( 20, 22, 28),(  0,  0, 16),(  4,  0, 16),(  8,  0, 16),
( 12,  0, 16),( 16,  0, 16),( 16,  0, 12),( 16,  0,  8),( 16,  0,  4),
( 16,  0,  0),( 16,  4,  0),( 16,  8,  0),( 16, 12,  0),( 16, 16,  0),
( 12, 16,  0),(  8, 16,  0),(  4, 16,  0),(  0, 16,  0),(  0, 16,  4),
(  0, 16,  8),(  0, 16, 12),(  0, 16, 16),(  0, 12, 16),(  0,  8, 16),
(  0,  4, 16),(  8,  8, 16),( 10,  8, 16),( 12,  8, 16),( 14,  8, 16),
( 16,  8, 16),( 16,  8, 14),( 16,  8, 12),( 16,  8, 10),( 16,  8,  8),
( 16, 10,  8),( 16, 12,  8),( 16, 14,  8),( 16, 16,  8),( 14, 16,  8),
( 12, 16,  8),( 10, 16,  8),(  8, 16,  8),(  8, 16, 10),(  8, 16, 12),
(  8, 16, 14),(  8, 16, 16),(  8, 14, 16),(  8, 12, 16),(  8, 10, 16),
( 11, 11, 16),( 12, 11, 16),( 13, 11, 16),( 15, 11, 16),( 16, 11, 16),
( 16, 11, 15),( 16, 11, 13),( 16, 11, 12),( 16, 11, 11),( 16, 12, 11),
( 16, 13, 11),( 16, 15, 11),( 16, 16, 11),( 15, 16, 11),( 13, 16, 11),
( 12, 16, 11),( 11, 16, 11),( 11, 16, 12),( 11, 16, 13),( 11, 16, 15),
( 11, 16, 16),( 11, 15, 16),( 11, 13, 16),( 11, 12, 16),(  0,  0,  0),
(  0,  0,  0),(  0,  0,  0),(  0,  0,  0),(  0,  0,  0),(  0,  0,  0),
(  0,  0,  0),(  0,  0,  0));

Var
 WorkPal : PaletteT;




Procedure SetRGBColorX(ColorN,R,G,B : Word);
Var
  reg : registers;
Begin

if (GetMaxColor=15) AND (ColorN <16) then
begin
 Reg.ah := $10;
 Reg.al := $0;
 Reg.bl := ColorN;
 Reg.bh := ColorN;
 intr ($10, Reg);
end;

 Reg.ah := $10;
 Reg.al := $10;
 Reg.bx := ColorN;
 Reg.dh := R;
 Reg.ch := G;
 Reg.cl := B;
 intr ($10, Reg);

 WorkPal[ColorN,0]:=R;
 WorkPal[ColorN,1]:=G;
 WorkPal[ColorN,2]:=B;

end;


Procedure GetRgbColorX(NColor : Word;Var R,G,B : Word);
var
  Reg : registers;
begin
(*
  Reg.ah:=$10;
  Reg.al:=$15;
  Reg.bx:=NColor;
  intr($10,reg);
  R:=reg.dh;
  G:=reg.ch;
  B:=reg.cl;
*)
 R:=WorkPal[NColor,0];
 G:=WorkPal[NColor,1];
 B:=WorkPal[NColor,2];

end;

Procedure SetDefaultPalette;
Var
 i : Word;
begin
 WorkPal:=DefaultPal;
 For i:=0 to GetMaxColor do
 begin
   SetRGBColorX(i,WorkPal[i,0],WorkPal[i,1],WorkPal[i,2]);
 end;
end;

Procedure GrabPalette16(Var myPal : Pal16 );
var
  Reg : registers;
begin
  Reg.ax:=$1017;
  Reg.bx:=0;
  Reg.cx:=16;

  Reg.es:=Seg(myPal);
  Reg.dx:=ofs(myPal);
  intr($10,reg);

end;

Procedure SetPalette16(Var myPal : Pal16 );
var
  Reg : registers;
begin
  Reg.ax:=$1012;
  Reg.bx:=0;
  Reg.cx:=16;

  Reg.es:=Seg(myPal);
  Reg.dx:=ofs(myPal);
  intr($10,reg);

end;


Procedure SetPaletteList(Var Pal : PaletteT; NColors : Word);
Var
 PN,R,G,B : byte;
 I : Word;
Begin
For i:=0 to NColors-1 do
Begin
 R := Pal[i,0];
 G := pal[i,1];
 B := pal[i,2];
 SetRGBColorX(i,R,G,B);
end;
end;


Procedure GrabPaletteList(Var Pal : PaletteT;NColors : Word);
var
i : word;
r,g,b : word;
begin
 For i:=0 to NColors-1 do
 begin
  GetRGBColorX(i,R,G,B);
  Pal[i,0]:=R;
  Pal[i,1]:=G;
  pal[i,2]:=B;
 end;
end;




Procedure DrawCurCol(x,y,col : Word);
begin
 SetFIllStyle(SolidFill,col);
 Bar(x,y,x+22,y+9+(15*8));
end;

Procedure DrawColors(x,y : Word);
Var
 I,J,C : Word;
begin
 SetColor(Black);
 If GetMaxColor = 15 then
 begin
   Rectangle(x,y,x+22,y+8+(15*8)+1);
   For i:=0 To 15 do
   begin
     SetFIllStyle(SolidFill,i);
     Bar(x+1,y+(i*8)+1,x+21,y+8+(i*8));
   end;
 end
 else if GetMaxColor = 255 then
 begin
  Rectangle(x-1,y,x+160,y+8+(15*8)+1);
  C:=0;
  For j:=0 to 15 do
  begin
   For i:=0 To 15 do
   begin
     SetFIllStyle(SolidFill,c);
     Bar(x+(j*10),y+(i*8)+1,x+(J*10)+9,y+8+(i*8));
     inc(c);
   end;
  end;
 end;
end;

Procedure DrawPalFrame(x,y,Width,Height : Word);
Var
 x2,y2 : Word;
begin
 x2:=x+Width-1;
 y2:=y+Height-1;
 SetFillStyle(SolidFill,Black);
 Bar(x,y,x2,y2);
 Border(x,y,x2,y2);
 SetFillStyle(SolidFill,White);
 Bar(x+3,y+22,x2-3,y2-3);
 SetFillStyle(SolidFill,LightGray);
 Bar(x+3,y+3,x2-3,y+20);
 ShadowText(x+5,y+8,'Palette Editor');
end;
Procedure PrintRGB(xp,yp : Word);
begin
 SetColor(Black);
 OutTextXY(xp,yp,' R');
 OutTextXY(xp+20,yp,' G');
 OutTextXY(xp+40,yp,' B');
end;

Procedure PrintRGBV(xp,yp,r,g,b : Word);
Var
cStr : String[2];
begin
 SetFillStyle(SolidFill,White);
 Bar(xp,yp,xp+60,yp+10);
 SetColor(Black);
 Str(r:2,cStr);
 OutTextXY(xp,yp,cStr);
 Str(g:2,cStr);
 OutTextXY(xp+20,yp,cStr);
 Str(b:2,cStr);
 OutTextXY(xp+40,yp,cStr);
end;

Procedure PalSlider(x,y,Width,Height,Brange,ws,cc : Word);
Var
 h,n : Word;
 st,mx,my : Integer;
 Old_my   : Integer;
 f        : boolean;
 x2,y2 : Word;
 ty : Integer;
 v  : Word;
 r,g,b : Word;
begin
 x2:=x+Width-1;
 y2:=y+Height;
 MouseHide;
 SetFillStyle(SolidFill,LightGray);
 Bar(x+1,y+1,x2-1,y2-1);
 MouseShow;
 dec(y2,15);
 f:=false;
 GetRGBColorX(cc,r,g,b);
Repeat
 mouseGetStatus(st,my,mx);
 dec(my,7);
 if my < y then my:=y;
 if my > y2 then my:=y2;
 if Old_my <> my then
 begin
   MouseHide;                  (* mouse hide *)
   if f then
   begin
     SetColor(LightGray);
     Rectangle(x+1,Old_my+1,x2-1,old_my+14);
   end;
   f:=true;
   SetColor(White);
   Rectangle(x+1,my+1,x2-1,my+14);


  ty:=my;
  if ty < y then ty:=y;
  h:=y2-y;
  v:=(Brange*(ty-y)) div h;
  if ws=1 then
  begin
    r:=v;
  end
  else if ws=2 then
  begin
    g:=v;
  end
  else if ws=3 then
  begin
    b:=v;
  end;
  SetRGBColorX(cc,r,g,v);
  PrintRGBV(x-(ws*20)+20,y+110,r,g,b);
  MouseShow;

   Old_my:=my;                   (* mouse show *)
 end;
Until st =0;
  MouseHide;
  DrawVSlider(x,y,Width,Height+1,v+1,64);
  MouseShow;
end;

Procedure PalEdit(xp,yp,CurColor : Word);
Const
 ngads = 11;
Var
 PalGads  : GLPtr;
     P,P2 : Pointer;
       gn : Word;
 r,g,b    : Word;
 st,mx,my : Integer;
 x,y,x2,y2: Word;
      xoff: Word;
     Img  : Pointer;
begin
 Xoff:=0;
 if GetMaxColor=255 then
 begin
  xoff:=140;
 end;
 GetMem(Img,ImageSize(xp,yp,xp+135+xoff,yp+210));
 MouseHide;
 GetImage(xp,yp,xp+135+xoff,yp+210,Img^);
 DrawPalFrame(xp,yp,135+xoff,210);
 DrawColors(xp+35,yp+40);
 DrawCurCol(xp+10,yp+40,CurColor);

 GetGadgetMem(PalGads,Ngads);
 If GetMaxColor=15 then
 begin
   P:=@Up16a;
   P2:=@Up16b;
 end
 else
 begin
   P:=@Up256a;
   P2:=@Up256b;
 end;
 DefineImageGadget(PalGads,1,xp+xoff+60,yp+104,17,16,P,P2,TRUE,FALSE);
 DefineImageGadget(PalGads,2,xp+xoff+80,yp+104,17,16,P,P2,TRUE,FALSE);
 DefineImageGadget(PalGads,3,xp+xoff+100,yp+104,17,16,P,P2,TRUE,FALSE);

 If GetMaxColor=15 then
 begin
   P:=@Down16a;
   P2:=@Down16b;
 end
 else
 begin
   P:=@Down256a;
   P2:=@Down256b;
 end;
 DefineImageGadget(PalGads,4,xp+xoff+60,yp+121,17,16,P,P2,TRUE,FALSE);
 DefineImageGadget(PalGads,5,xp+xoff+80,yp+121,17,16,P,P2,TRUE,FALSE);
 DefineImageGadget(PalGads,6,xp+xoff+100,yp+121,17,16,P,P2,TRUE,FALSE);

 DefineBlankGadget(PalGads,7,xp+xoff+60,yp+40,17,64,TRUE,FALSE);
 DefineBlankGadget(PalGads,8,xp+xoff+80,yp+40,17,64,TRUE,FALSE);
 DefineBlankGadget(PalGads,9,xp+xoff+100,yp+40,17,64,TRUE,FALSE);

 if GetMaxColor = 15 then
 begin
  DefineBlankGadget(PalGads,10,xp+35,yp+40,22,128,TRUE,FALSE);
 end
 else if GetMaxColor = 255 then
 begin
  DefineBlankGadget(PalGads,10,xp+35,yp+40,160,128,TRUE,FALSE);
 end;


 DefineStringGadget(PalGads,11,xp+xoff+60,yp+180,'   OK   ',TRUE,FALSE);

 DrawAllGadgets(PalGads,Ngads);

 GetRGBColorX(CurColor,r,g,b);
 GetGadgetCords(PalGads,7,x,y,x2,y2);
 DrawVSlider(x,y,17,64,r+1,64);
 GetGadgetCords(PalGads,8,x,y,x2,y2);
 DrawVSlider(x,y,17,64,g+1,64);
 GetGadgetCords(PalGads,9,x,y,x2,y2);
 DrawVSlider(x,y,17,64,b+1,64);

 PrintRGB(xp+xoff+60,yp+140);
 PrintRGBV(xp+xoff+60,yp+150,r,g,b);

 MouseShow;
 Repeat
   MouseWaitForAnyKey;
   gn:=GetGadgetPressed(PalGads,Ngads);
   if (gn > 0) AND (gn < 7) then
   begin
    MouseHide;
    DrawGadget(PalGads,gn,TRUE);
    MouseShow;
    GetRGBColorX(CurColor,r,g,b);
    Repeat
      If gn=1 then
      begin
        if r > 0 then
        begin
         Dec(r);
         MouseHide;
         PrintRGBV(xp+xoff+60,yp+150,r,g,b);
         GetGadgetCords(PalGads,7,x,y,x2,y2);
         DrawVSlider(x,y,x2-x+1,y2-y+1,r+1,64);
         MouseShow;

        end;
      end
      else if gn=4 then
      begin
        if r < 63 then
        begin
         Inc(r);
         MouseHide;
         PrintRGBV(xp+xoff+60,yp+150,r,g,b);
         GetGadgetCords(PalGads,7,x,y,x2,y2);
         DrawVSlider(x,y,x2-x+1,y2-y+1,r+1,64);
         MouseShow;
        end;
      end
      else if gn=2 then
      begin
        if g > 0  then
        begin
         Dec(g);
         MouseHide;
         PrintRGBV(xp+xoff+60,yp+150,r,g,b);
         GetGadgetCords(PalGads,8,x,y,x2,y2);
         DrawVSlider(x,y,x2-x+1,y2-y+1,g+1,64);
         MouseShow;
        end;
      end
      else if gn=5 then
      begin
        if g < 63 then
        begin
         Inc(g);
         MouseHide;
         PrintRGBV(xp+xoff+60,yp+150,r,g,b);
         GetGadgetCords(PalGads,8,x,y,x2,y2);
         DrawVSlider(x,y,x2-x+1,y2-y+1,g+1,64);
         MouseShow;
        end;
      end
      else if gn=3 then
      begin
        if b > 0  then
        begin
         Dec(b);
         MouseHide;
         PrintRGBV(xp+xoff+60,yp+150,r,g,b);
         GetGadgetCords(PalGads,9,x,y,x2,y2);
         DrawVSlider(x,y,x2-x+1,y2-y+1,b+1,64);
         MouseShow;
        end;
      end
      else if gn=6 then
      begin
        if b < 63 then
        begin
         Inc(b);
         MouseHide;
         PrintRGBV(xp+xoff+60,yp+150,r,g,b);
         GetGadgetCords(PalGads,9,x,y,x2,y2);
         DrawVSlider(x,y,x2-x+1,y2-y+1,b+1,64);
         MouseShow;
        end;
      end;

      SetRGBColorX(CurColor,r,g,b);
      MouseGetStatus(st,my,mx);
      Until st <> 2;
      MouseWaitForKeyRelease;
      MouseHide;
      DrawGadget(PalGads,gn,False);
      MouseShow;
   end
   else if gn = 7 then
   begin
    GetGadgetCords(PalGads,7,x,y,x2,y2);
    PalSlider(x,y,17,63,63,1,CurColor);
   end
   else if gn = 8 then
   begin
    GetGadgetCords(PalGads,8,x,y,x2,y2);
    PalSlider(x,y,17,63,63,2,CurColor);
   end
   else if gn = 9 then
   begin
    GetGadgetCords(PalGads,9,x,y,x2,y2);
    PalSlider(x,y,17,63,63,3,CurColor);
   end
   else if gn = 10 then
   begin
     MouseGetStatus(st,my,mx);
     GetGadgetCords(PalGads,10,x,y,x2,y2);
     If GetMaxColor = 15 then
     begin
      CurColor:=(my-y) div 8;
     end
     else if GetMaxColor=255 then
     begin
      CurColor:=(my-y) div 8+(((mx-x) div 10)*16);
     end;
     MouseHide;
     DrawCurCol(xp+10,yp+40,CurColor);
     GetRGBColorX(CurColor,r,g,b);
     GetGadgetCords(PalGads,7,x,y,x2,y2);
     DrawVSlider(x,y,17,64,r+1,64);
     GetGadgetCords(PalGads,8,x,y,x2,y2);
     DrawVSlider(x,y,17,64,g+1,64);
     GetGadgetCords(PalGads,9,x,y,x2,y2);
     DrawVSlider(x,y,17,64,b+1,64);
     PrintRGBV(xp+xoff+60,yp+150,r,g,b);
     MouseShow;
   end
   else if gn = 11 then
   begin
     MouseHide;
     DrawGadget(PalGads,11,TRUE);
     MouseShow;
     MouseWaitForKeyRelease;
     MouseHide;
     DrawGadget(PalGads,11,FALSE);
     PutImage(xp,yp,Img^,NormalPut);
     MouseShow;
     FreeMem(Img,ImageSize(xp,yp,xp+135+xoff,yp+210));
     FreeGadgetMem(PalGads,Ngads);
     exit;
   end;
 Until 0=1;

end;

Procedure dumpPalToDisk;
Var
 i,j : Word;
 f : Text;
 c : Word;
 tPal : PaletteT;
 r,g,b : Word;
begin
 c:=0;

 Assign(F,'pal.con');
 Rewrite(f);
 For i:=0 to 255 do
 begin
  GetrgbColorX(i,r,g,b);
  inc(c);
  if c=5 then
  begin
   Writeln(f);
   c:=0;
  end;
  Write(F,'(',r:3,',',g:3,',',b:3,'),');
 end;

close(f);
end;

begin
 WorkPal:=DefaultPal;
end.