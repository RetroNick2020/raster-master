// shapes.inc was exported from Raster Master using RES Text Include File
// see video for example usage

Program fpresdemo1;
    uses  ptccrt,ptcgraph;

const
{$I shapes.inc}

procedure setpal;
var
  i : integer;
  c : integer;
begin
 c:=0;
 for i:=0 to 15 do
 begin
  setrgbpalette(i,girlpal[c],girlpal[c+1],girlpal[c+2]);
  inc(c,3);
 end;
end;

procedure waitforkey;
begin
 repeat until keypressed;
end;

var
 gd,gm : integer;

begin
 gd:=VGA;
 gm:=VGAHI;
 initgraph(gd,gm,'');
 setpal;
 setFillStyle(xHatchFill,Green);
 Bar(10,10,400,400);
 putimage(10,10,Image1Mask,andPut);
 putimage(10,10,Image1,orPut);

 putimage(200,10,Image2Mask,andPut);
 putimage(200,10,Image2,orPut);

 putimage(300,110,girlMask,andPut);
 putimage(300,110,girl,orPut);

 waitforkey;
 closegraph;
end.
