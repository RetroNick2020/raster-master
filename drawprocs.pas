unit drawprocs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, rmtools;


type
  DrawItemProc = procedure(x,y,index,mode : integer); //use mode to decide if we want to update maps/sprite values
  GetItemProc  = function(x,y : integer) : integer;

procedure SetDrawPixelProc(dic : drawitemproc);
procedure SetGetPixelProc(gic : GetItemProc);

procedure DrawItem(item,x,y,x2,y2,index,mode : integer);
procedure FloodFill(x,y, MaxX,MaxY,index,mode : integer);
procedure ReplaceFill(x, y, MaxX,MaxY,index,mode : integer);

implementation

var
  DefaultDrawItemProc : DrawItemProc;
  DefaultGetItemProc  : GetItemProc;
//putx - could be pixel or tile

procedure PutItemX(x,y,index,mode : integer);
begin
 DefaultDrawItemProc(x,y,index,mode);
end;

function GetItemX(x,y : integer) : integer;
begin
 result:=DefaultGetItemProc(x,y);
end;

const
 MaxQueueSize = 100;
Type
  TFPoint = record
            x,y : integer;
  end;

  TPixelQueue = Class
             Count : integer;
             PointList : array[1..MaxQueueSize] of TFPoint;
             constructor Create;
             procedure push(var pt : TFPoint);
             procedure popfirst(var pt : TFPoint);
             procedure pop(var pt : TFPoint);
             function GetCount : integer;
  end;

  TSprayPointsRec = Record
                      x,y : integer;
  end;

var
  SprayPoints : array[1..MaxSprayPoints] of TSprayPointsRec;

constructor TPixelQueue.Create;
begin
 count:=0;
end;

procedure TPixelQueue.push(var pt : TFPoint);
begin
 if (count+1) > MaxQueueSize then exit;
 inc(count);
 PointList[count]:=pt;
end;
procedure TPixelQueue.popfirst(var pt : TFPoint);
var
i : integer;
begin
 if count > 0 then
 begin
   pt:=PointList[1];
   dec(count);
   for i:=1 to count do
   begin
      PointList[i]:=PointList[i+1];
   end;
 end;
end;

procedure TPixelQueue.pop(var pt : TFPoint);
begin
 if count > 0 then
 begin
   pt:=PointList[count];
   dec(count);
 end;
end;

function TPixelQueue.GetCount : integer;
begin
  GetCount:=count;
end;

procedure FloodFill(x, y, MaxX,MaxY,index,mode : integer);
var
  x1 : integer;
  spanAbove, spanBelow : boolean;
  PQ     : TPixelQueue;
  temp   : TFPoint;
  oldColor : integer;
begin
  if GetItemX(x,y) = index then exit;
  oldColor:=GetItemX(x,y);

  PQ:=TPixelQueue.Create;
  temp.x:=x;
  temp.y:=y;
  PQ.push(temp);
  while PQ.GetCount>0 do
  begin
    PQ.popfirst(temp);
    x:=temp.x;
    y:=temp.y;

    x1 := x;
    while ((x1 >= 0) and (GetItemX(x1,y) = oldColor)) do
    begin
      x1:=x1-1;
    end;
    x1:=x1+1;
    spanAbove := false;
    spanBelow := false;

    while((x1 < MaxX) and (GetItemX(x1,y) = oldColor)) do
    begin
      PutItemX( x1,y, index,mode);
      if((NOT spanAbove) and  (y > 0) and (GetItemX(x1,(y - 1) ) = oldColor)) then
      begin
        temp.x:=x1;
        temp.y:=y-1;
        PQ.push(temp);
        spanAbove := true;
      end
      else if (spanAbove and (y > 0) and (GetItemX(x1,(y - 1)) <> oldColor)) then
      begin
        spanAbove := false;
      end;

      if ((NOT spanBelow) and (y < MaxY - 1) and (GetItemX(x1,(y + 1)) = oldColor)) then
      begin
        temp.x:=x1;
        temp.y:=y+1;
        PQ.push(temp);
        spanBelow := true;
      end
      else if(spanBelow and (y < MaxY - 1) and (GetItemX(x1,(y + 1)) <> oldColor)) then
      begin
        spanBelow := false;
      end;
      x1:=x1+1;
    end;
  end;
end;

//replaces all occurances in Map of selected  Tile - like flood fill but for all - does not need to be connected - mainly to be used for missing tiles
procedure ReplaceFill(x, y, MaxX,MaxY,index,mode : integer);
var
 i,j,ReplaceColor : integer;
begin
  if GetItemX(x,y) = index then exit;
  ReplaceColor:=GetItemX(x,y);
  for j:=0 to MaxY-1 do
  begin
    for i:=0 to MaxX-1 do
    begin
      if GetItemX(i,j) = ReplaceColor then  PutItemX( i,j, index,mode);
    end;
  end;
end;



Procedure CreateRandomSprayPoints;
var
 i : integer;
begin
  for i:=1 to MaxSprayPoints do
  begin
    SprayPoints[i].x:=randomrange(-5,5);
    SprayPoints[i].y:=randomrange(-5,5);
  end;
end;

procedure SprayPaint(x,y,index,mode : integer);
var
 i : integer;
begin
 CreateRandomSprayPoints;
 for i:=1 to MaxSprayPoints do
  begin
    PutItemX(x+SprayPoints[i].x,y+SprayPoints[i].y,index,mode);
  end;
end;


procedure HLine(x,x2,y,index, mode : integer);
var
  xx,newx, newx2 : integer;
begin
  newx:=x;
  newx2:=x2;
  if x2 < x then
  begin
    newx:=x2;
    newx2:=x;
  end;

  for xx:=newx to newx2 do
  begin
    PutItemX(xx,y,index,mode);
  end;
end;

procedure VLine(y,y2,x, index, mode : integer);
var
  yy,newy,newy2 : integer;
begin
  newy:=y;
  newy2:=y2;
  if y2 < y then
  begin
    newy:=y2;
    newy2:=y;
  end;
  for yy:=newy to newy2 do
  begin
    PutItemX(x,yy,index, mode);
  end;
end;

procedure Rectangle(x,y,x2,y2,index,full,mode : integer);
var
  newy,newy2 : integer;
  newx, newx2 : integer;
  i,j : integer;
begin
  newx:=x;
  newx2:=x2;
  if x2 < x then
  begin
    newx:=x2;
    newx2:=x;
  end;

  newy:=y;
  newy2:=y2;
  if y2 < y then
  begin
    newy:=y2;
    newy2:=y;
  end;

  if (full = 1) then
  begin
    for i:=newx to newx2 do
    begin
      for j:=newy to newy2 do
      begin
        PutItemX(i,j,index,mode);
      end;
    end;
    exit;
  end;

  if (newx=newx2) and (newy=newy2) then
  begin
    PutItemX(newx,newy,index,mode);
  end
  else if(newx+1=newx2) and(newy+1=newy2) then
  begin
    Hline(newx,newx2,newy,index,mode);
    Hline(newx,newx2,newy2,index,mode);
  end
  else if (newy+1=newy2) then
  begin
    Hline(newx,newx2,newy,index,mode);
    Hline(newx,newx2,newy2,index,mode);
  end
  else if (newx=newx2) and (newy<>newy2) then
  begin
    Vline(newy,newy2,newx,index,mode);
  end
  else if (newy=newy2) and (newx<>newx2) then
  begin
    Hline(newx,newx2,newy,index,mode);
  end
  else
  begin
    Hline(newx,newx2,newy,index,mode);
    Hline(newx,newx2,newy2,index,mode);
    Vline(newy+1,newy2-1,newx,index,mode);
    Vline(newy+1,newy2-1,newx2,index,mode);
  end;
end;

Procedure Line(x1,y1,x2,y2,index,mode : integer);
var
 xr,yr,dxr,dyr:real;
 x,y,dx,dy:integer;
begin
 if abs(x2-x1)>=abs(y2-y1) then
 begin
   if x1<=x2 then dx:=1 else dx:=-1;
   if x1<>x2 then dyr:=(y2-y1)/abs(x2-x1) else dyr:=0;
   x:=x1-dx;
   yr:=y1;
   repeat
     x:=x+dx;
     PutItemX(x,round(yr),index,mode);
     yr:=yr+dyr;
    until x=x2;
   end
   else
   begin
     dxr:=(x2-x1)/abs(y2-y1);
     if y1<y2 then dy:=1 else dy:=-1;
     y:=y1-dy;
     xr:=x1;
     repeat
       y:=y+dy;
       PutItemX(round(xr),y,index,mode);
       xr:=xr+dxr;
     until y=y2;
   end;
end;


procedure empty_ellipse(xc,  yc,  a, b,index, mode : integer);
var
 x,y : integer;
 a2,b2 : longint;
 crit1,crit2,crit3 : longint;
 t,dxt,d2xt,dyt,d2yt : longint;
begin
 x := 0;
 y := b;

 a2 :=a*a;
 b2 :=b*b;
 crit1 := -(a2 div 4 + a mod 2 + b2);
 crit2 := -(b2 div 4 + b mod 2 + a2);
 crit3 := -(b2 div 4 + b mod 2);
 t := -a2*y;
 dxt := 2*b2*x;
 dyt := -2*a2*y;
 d2xt := 2*b2;
 d2yt := 2*a2;

while (y>=0) AND (x<=a) do
begin
  PutItemX(xc+x, yc+y,index,mode);
  if (x<>0) OR (y<>0) then
  begin
    PutItemX(xc-x, yc-y,index,mode);
    if (x<>0) AND (y<>0) then
    begin
      PutItemX(xc+x, yc-y,index,mode);
      PutItemX(xc-x, yc+y,index,mode);
    end;
    if (t + b2*x <= crit1) OR  (t + a2*y <= crit3) then
    begin
      inc(x);
      inc(dxt,d2xt);
      inc(t,dxt);
    end
    else if (t - a2*y > crit2)	then
    begin
      dec(y);
      inc(dyt,d2yt);
      inc(t,dyt);
    end
    else
    begin
      inc(x);
      inc(dxt,d2xt);
      inc(t,dxt);

      dec(y);
      inc(dyt,d2yt);
      inc(t,dyt);
    end;
  end;
end;
end;

procedure rLine(x,y,w,index,mode : integer);
var
 i : integer;
begin
  for i:=x to x+w-1 do
  begin
    PutItemX(i,y,index,mode);
  end;
end;

procedure filled_ellipse(xc, yc,  a,  b ,index, mode : integer);
var
 x,y : integer;
 a2,b2 : longint;
 crit1,crit2,crit3 : longint;
 t,dxt,d2xt,dyt,d2yt : longint;
 width : word;
begin
  x := 0;
  y := b;
  width := 1;
  a2 := longint(a)*a;
  b2 := longint(b)*b;
  crit1 := -(a2 div 4 + (a mod 2) + b2);
  crit2 := -(b2 div 4 + (b mod 2) + a2);
  crit3 := -(b2 div 4 + (b mod 2));
  t := -a2*y;
  dxt := 2*b2*x;
  dyt := -2*a2*y;
  d2xt := 2*b2;
  d2yt := 2*a2;

  while (y>=0) AND (x<=a)  do
  begin
   if ((t + b2*x) <= crit1) OR ((t + a2*y) <= crit3) then
   begin
     inc(x);
     inc(dxt,d2xt);
     inc(t,dxt);
     inc(width,2);
    end
    else if ((t - a2*y) > crit2) then
    begin
      rline(xc-x, yc-y, width,index,mode);
      if (y<>0) then rline(xc-x, yc+y, width,index,mode);
      dec(y);
      inc(dyt,d2yt);
      inc(t,dyt);
    end
   else
   begin
     rline(xc-x, yc-y, width,index,mode);
     if (y<>0) then rline(xc-x, yc+y, width,index,mode);
     inc(x);
     inc(dxt,d2xt);
     inc(t,dxt);

     dec(y);
     inc(dyt,d2yt);
     inc(t,dyt);

     inc(width,2);
   end;
  end;
  if (b = 0) then rline(xc-a, yc, 2*a+1,index,mode);
end;


procedure rRectFill(x,y,w,h,index,mode : integer);
var
 i,j : integer;
 x2,y2 : integer;
 t     : integer;
begin
 x2:=x+w;
 y2:=y+h-1;
 if x2 < x then
 begin
   t:=x2;
   x2:=x;
   x:=t;
 end;

 if y2 < y then
 begin
   t:=y2;
   y2:=y;
   y:=t;
 end;

 for j:=y to y2 do
 begin
   for i:=x to x2 do
   begin
     PutItemX(i,j,index,mode);
  end;
 end;
end;

Procedure Ellipse(xc,yc,x2,y2,index,full, mode : integer);
var
 rx,ry : integer;
begin
 rx:=abs(x2-xc);
 if rx < 1 then rx:=1;
 ry:=abs(y2-yc);
 if ry < 1 then ry:=1;
 if full=1 then
 begin
  filled_ellipse(xc,yc,rx,ry,index,mode);
 end
 else
 begin
   empty_ellipse(xc,yc,rx,ry,index,mode);
 end;
end;

Procedure Circle(xc,yc,x2,y2,index,full, mode : integer);
var
  rx,ry,radius : integer;
begin
  rx:=abs(x2-xc);
  ry:=abs(y2-yc);
  radius:=rx;
  if ry > radius then radius:=ry;
  if radius < 1 then radius:=1;
  if full=1 then
  begin
    filled_ellipse(xc,yc,radius,radius,index,mode);
  end
  else
  begin
    empty_ellipse(xc,yc,radius,radius,index,mode);
  end;
end;

procedure dummyDrawPixelProc(x,y,index,mode : integer);
begin
  //this should be overwriten to support what ever target we want. plot pixel to screen or memory or something else
end;

function dummyGetPixelProc(x,y : integer) : integer;
begin
  //this should be overwriten to support what ever target we want. plot pixel to screen or memory or something else
  result:=0;
end;

procedure SetDrawPixelProc(dic : drawitemproc);
begin
  DefaultDrawItemProc:=dic;
end;

procedure SetGetPixelProc(gic : getitemproc);
begin
 DefaultGetItemProc:=gic;
end;

procedure DrawItem(item,x,y,x2,y2,index,mode : integer);
begin
 case item of DrawShapePencil:PutItemX(x,y,index,mode);
                DrawShapeLine:Line(x,y,x2,y2,index,mode);
           DrawShapeRectangle:Rectangle(x,y,x2,y2,index,0,mode);
          DrawShapeFRectangle:Rectangle(x,y,x2,y2,index,1,mode);
              DrawShapeCircle:Circle(x,y,x2,y2,index,0,mode);
             DrawShapeFCircle:Circle(x,y,x2,y2,index,1,mode);
             DrawShapeEllipse:Ellipse(x,y,x2,y2,index,0,mode);
            DrawShapeFEllipse:Ellipse(x,y,x2,y2,index,1,mode);
            DrawShapeSpray:SprayPaint(x,y,index,mode);
 end;
end;

procedure InitDrawPixelProc;
begin
  SetDrawPixelProc(@dummyDrawPixelProc);
  SetGetPixelProc(@dummyGetPixelProc);
end;

begin
  InitDrawPixelProc;
end.

