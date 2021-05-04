unit RMTools;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,Graphics,Clipbrd,LCLIntf,LCLType,ColorPalette,RMCore,math;

const
  CellWidthBorderRemove  =2;
  CellHeightBorderRemove =2;

  DrawShapeNothing = 0;
  DrawShapePencil = 1;
  DrawShapeLine = 2;
  DrawShapeRectangle = 3;
  DrawShapeFRectangle = 4;
  DrawShapeCircle = 5;
  DrawShapeFCircle = 6;
  DrawShapeEllipse = 7;
  DrawShapeFEllipse = 8;
  DrawShapePaint = 9;
  DrawShapeSpray = 10;
  DrawShapeClip = 11;

  MaxSprayPoints = 3;

Type
  TClipAreaRec = Record
                    x,y,x2,y2 : integer;
                    status    : integer;
                    sized     : integer;
  end;

  TSprayPointsRec = Record
                      x,y : integer;
  end;

  TRMDrawTools = class(TObject)
    // drawcircle(Sender,x1,x2,y2,y2,DrawMode); drawmode = Normal or Xor
    //if Sender is Zoom draws in Zoom TImage
    //if Sender is Actual it Draw in Actual TImage
             private
                CellWidth : integer;
                CellHeight : integer;
                GridThickX : integer;
                GridThickY : integer;
                ZoomMode   : integer;
                ZoomSize   : integer;
                GridMode   : integer;
                DrawTool : integer;
                ClipArea : TClipAreaRec;
                SprayPoints : array[1..MaxSprayPoints] of TSprayPointsRec;
             public

             Constructor create;

             procedure DClip(Image : TCanvas; x,y,x2,y2 : integer;color : TColor; mode : integer);
             procedure ADrawShape(Image : TCanvas; x,y,x2,y2 : integer;color : TColor; mode,shape,full : Integer);
             procedure DrawShape(Image : TCanvas;x,y,x2,y2 : integer;color : TColor; mode,shape,full : integer);

             procedure ARectangle(Image : TCanvas; x,y,x2,y2 : integer;color : TColor; mode : Integer);
             procedure PutPixel(Image : TCanvas; x,y: integer; color : TColor; mode : integer);    // mode = 1 Xor 0 = Normal
             procedure SprayPaint(Image : TCanvas; x,y : integer;color : TColor; mode : integer);
             procedure HLine(Image : TCanvas;x,x2,y : integer;color : TColor; mode : integer);
             procedure VLine(Image : TCanvas;y,y2,x : integer;color : TColor; mode : integer);
             Procedure DLine(Image : TCanvas;x1,y1,x2,y2:Integer;color : TColor; mode : integer);
             procedure rRectFill(Image : TCanvas;x,y,w,h : integer;color : TColor; mode : integer);
             procedure rLine(Image : TCanvas;x,y,w : integer;color : TColor; mode : integer);
             procedure draw_ellipse(Image : TCanvas;xc,  yc,  a, b : Integer;color : TColor; mode : integer);
             procedure fill_ellipse(Image : TCanvas;xc, yc,  a,  b  : integer;color : TColor; mode : integer);
             Procedure DEllipse(Image : TCanvas;xc,yc,x2,y2:Integer;color : TColor; mode : integer;Full:integer);
             Procedure DCircle(Image : TCanvas;xc,yc,x2,y2:Integer;color : TColor; mode : integer;Full:integer);

             procedure Rect(Image : TCanvas;x,y,x2,y2 : integer;color : TColor; mode,full : integer);
             procedure SetGridThickX(amount : integer);
             procedure SetGridThickY(amount : integer);
             procedure SetCellWidth(cWidth : integer);
             procedure SetCellHeight(cHeight : integer);
             function GetCellsPerRow(ImageWidth : integer) : integer;
             function GetCellsPerCol(ImageHeight : integer) : integer;
             function GetMaxXOffset(ActualImageWidth,ZoomImageWidth : integer) : integer;
             function GetMaxYOffset(ActualImageHeight,ZoomImageHeight : integer) : integer;
             function GetZoomX(x : integer) : integer;
             function GetZoomY(y : integer) : integer;

             procedure SetClipStatus(mode : integer);
             function  GetClipStatus : integer;
             procedure  SetClipSizedStatus(mode : integer);
             function  GetClipSizedStatus : integer;
             procedure  GetClipAreaCoords(var ca : TClipAreaRec);

             procedure SaveClipCoords(x,y,x2,y2 : integer);
             procedure DrawClipArea(Image : TCanvas;color : TColor; mode : integer);




             procedure SetDrawTool(Tool : integer);
             function GetDrawTool : integer;

             procedure DrawGrid(Image : TCanvas;x,y,gWidth,gHeight,mode : integer);
             procedure SetZoomMode(mode : integer);   //0 = off 1 = on
             function  GetZoomMode : integer;
             procedure SetZoomSize(size : integer);
             function GetZoomSize : integer;
             procedure SetGridMode(mode : integer); //0 = off 1 = on
             function GetGridMode : integer;
             procedure AddMonoPalette(var CP : TColorPalette);
             procedure AddCGAPalette0(var CP : TColorPalette);
             procedure AddCGAPalette1(var CP : TColorPalette);
             procedure AddEGAPalette(var CP : TColorPalette);
             procedure AddVGAPalette(var CP : TColorPalette);
             procedure AddVGAPalette256(var CP : TColorPalette);
             procedure AddAmigaPalette(var CP : TColorPalette; ColorNum : integer);
             procedure CreateRandomSprayPoints;
             Procedure HFlip(x,y,x2,y2: word);
             Procedure VFlip(x,y,x2,y2: word);
             Procedure ScrollUp(x,y,x2,y2: word);
             Procedure ScrollDown(x,y,x2,y2: word);
             Procedure ScrollLeft(x,y,x2,y2: word);
             Procedure ScrollRight(x,y,x2,y2: word);
             Procedure Copy(x,y,x2,y2 : integer);
             Procedure Paste(x,y,x2,y2 : integer);

  end;
 var
  RMDrawTools : TRMDrawTools;

implementation

Constructor TRMDrawTools.create;
begin
  //SetCellWidth(30);
  //SetCellHeight(30);
SetZoomMode(1);
SetZoomSize(2);
  //SetGridThickY(1);
  //SetGridThickX(1);
   SetGridMode(1);
  SetDrawTool(DrawShapePencil);
  SetClipStatus(0); //off
  SetClipSizedStatus(0);
end;


procedure TRMDrawTools.SetClipStatus(mode : integer);
begin
   ClipArea.status:=mode;
end;

function TRMDrawTools.GetClipStatus : integer;
begin
    GetClipStatus:=ClipArea.status;
end;

procedure TRMDrawTools.SetClipSizedStatus(mode : integer);
begin
   ClipArea.sized:=mode;
end;

function TRMDrawTools.GetClipSizedStatus : integer;
begin
    GetClipSizedStatus:=ClipArea.sized;
end;

procedure  TRMDrawTools.GetClipAreaCoords(var ca : TClipAreaRec);
begin
   ca:=ClipArea;
end;

procedure TRMDrawTools.SaveClipCoords(x,y,x2,y2 : integer);
begin
   ClipArea.x:=x;
   ClipArea.y:=y;
   ClipArea.x2:=x2;
   ClipArea.y2:=y2;
end;

procedure TRMDrawTools.DrawClipArea(Image : TCanvas;color : TColor; mode : integer);
begin
  DClip(Image,ClipArea.x,ClipArea.y,ClipArea.x2,ClipArea.y2,color,mode);
end;

procedure TRMDrawTools.DClip(Image : TCanvas; x,y,x2,y2 : integer;color : TColor; mode : integer);
var
  CellWidthTotal,CellHeightTotal : integer;
  temp : integer;
begin
  if GridMode = 1 then
  begin
    CellWidthTotal:=CellWidth+GridThickY;
    CellHeightTotal:=CellHeight+GridThickX;
  end
  else
  begin
    CellWidthTotal:=CellWidth;
    CellHeightTotal:=CellHeight;
  end;
  if mode = 1 then
  begin
      Image.Pen.Mode := pmXor;
  end
  else
  begin
      Image.Pen.Mode := pmCopy;
  end;
  if x > x2 then
  begin
      temp:=x;
      x:=x2;
      x2:=temp;
  end;
  if y > y2 then
  begin
     temp:=y;
     y:=y2;
     y2:=temp;
  end;

  Image.Brush.Style:=bsClear;
  Image.Pen.Color:=clYellow;
  Image.Rectangle(x*CellWidthTotal-1,y*CellHeightTotal-1,(x2+1)*CellWidthTotal+2,(y2+1)*CellHeightTotal+2);
end;

procedure TRMDrawTools.PutPixel(Image : TCanvas; x,y : integer;color : TColor; mode : integer);
var
 padx,padx2,pady,pady2: integer;
 CellWidthTotal,CellHeightTotal : integer;
begin
  if mode = 2 then    //just plot the pixel to the internal buffer - no need to draw ro zoom or actual area;
  begin
      RMCoreBase.PutPixel(x,y);
     exit;
  end;

  if GridMode = 1 then
  begin
    CellWidthTotal:=CellWidth+GridThickY;
    CellHeightTotal:=CellHeight+GridThickX;
    padx:=GridThickY+CellWidthBorderRemove;
    pady:=GridThickX+CellHeightBorderRemove;
    padx2:=CellWidth+GridThickY-CellWidthBorderRemove;
    pady2:=CellHeight+GridThickX-CellHeightBorderRemove;
  end
  else
  begin
    CellWidthTotal:=CellWidth;
    CellHeightTotal:=CellHeight;
    padx:=0;
    pady:=0;
    padx2:=CellWidth;
    pady2:=CellHeight;
  end;

  Image.Brush.Style := bsSolid;
  Image.Brush.Color := Color;
  Image.Pen.Color := Color;
  if mode = 1 then
  begin
      if Color = clBlack then
      begin
        Image.Brush.Color := clWhite;
        Image.Pen.Color := clWhite;
      end;
      Image.Pen.Mode := pmXor;
     // Image.Brush.mode :=pmXor;
      Image.Brush.Style := bsCross;

   end
  else
  begin
   Image.Pen.Mode := pmCopy;
   //Image.Brush.mode :=pmXor;
   Image.Brush.Color:=Color;
   //Image2.Canvas.Brush.Style := bsClear;
   Image.Pen.Color := Color;
  end;


  If GetZoomMode = 1 then
  begin
//    Image.Rectangle(X*(CellWidth+GridThickY)+GridThickY+CellWidthBorderRemove,
//                    Y*(CellHeight+GridThickX)+GridThickX+CellHeightBorderRemove,
//                    X*(CellWidth+GridThickY)+CellWidth+GridThickY-CellWidthBorderRemove,
//                    Y*(CellHeight+GridThickX)+CellHeight+GridThickX-CellHeightBorderRemove);
//
     Image.Rectangle(X*(CellWidthTotal)+padx,
                     Y*(CellHeightTotal)+pady,
                     X*(CellWidthTotal)+padx2,
                     Y*(CellHeightTotal)+pady2);
  end
  else
  begin
    if (mode = 1) AND (Color = clBlack) then
    begin
         Image.Pixels[x,y]:=clWhite;
    end
    else
    begin
     Image.Pixels[x,y]:=color;
    end;
   //RMCoreBase.PutPixel(x,y);
  end;
end;

Procedure TRMDrawTools.CreateRandomSprayPoints;
var
 i : integer;
begin
  for i:=1 to MaxSprayPoints do
  begin
    SprayPoints[i].x:=randomrange(-5,5);
    SprayPoints[i].y:=randomrange(-5,5);
  end;
end;

procedure TRMDrawTools.SprayPaint(Image : TCanvas; x,y : integer;color : TColor; mode : integer);
var
 i : integer;
begin
  for i:=1 to MaxSprayPoints do
  begin
    PutPixel(Image,x+SprayPoints[i].x,y+SprayPoints[i].y,color,mode);
  end;
end;


procedure TRMDrawTools.ARectangle(Image : TCanvas;x,y,x2,y2 : integer;color : TColor; mode : Integer);
begin
  Image.Pen.Color := Color;
  if mode = 1 then
  begin
    if Color = clBlack then  Image.Pen.Color := clWhite;
    Image.Pen.Mode := pmXor;
  end
  else
  begin
      Image.Pen.Mode :=pmCopy;
  end;

  Image.MoveTo(x,y);
  Image.LineTo(x2,y);
  Image.LineTo(x2,y2);
  Image.LineTo(x,y2);
  Image.LineTo(x,y);

end;



procedure TRMDrawTools.HLine(Image : TCanvas;x,x2,y : integer;color : TColor; mode : integer);
 var
 xx : integer;
 newx, newx2 : integer;
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
   PutPixel(Image,xx,y,color,mode);
 end;
end;

procedure TRMDrawTools.VLine(Image : TCanvas;y,y2,x : integer;color : TColor; mode : integer);
 var
  yy: integer;
  newy,newy2 : integer;
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
    PutPixel(Image,x,yy,color, mode);
  end;

end;

procedure TRMDrawTools.Rect(Image : TCanvas;x,y,x2,y2 : integer;color : TColor; mode,full : integer);
 var
  xx,yy : integer;
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
       PutPixel(Image,i,j,color,mode);
     end;
   end;
   exit;
 end;


 if (newx=newx2) and (newy=newy2) then
 begin
    PutPixel(Image,newx,newy,color,mode);
 end
 else if(newx+1=newx2) and(newy+1=newy2) then
 begin
    Hline(Image,newx,newx2,newy,color,mode);
    Hline(Image,newx,newx2,newy2,color,mode);
 end
 else if (newy+1=newy2) then
 begin
    Hline(Image,newx,newx2,newy,color,mode);
    Hline(Image,newx,newx2,newy2,color,mode);
 end
 else if (newx=newx2) and (newy<>newy2) then
 begin
    Vline(Image,newy,newy2,newx,color,mode);
  end
 else if (newy=newy2) and (newx<>newx2) then
 begin
    Hline(Image,newx,newx2,newy,color,mode);
 end
 else
 begin
   Hline(Image,newx,newx2,newy,color,mode);
   Hline(Image,newx,newx2,newy2,color,mode);

   Vline(Image,newy+1,newy2-1,newx,color,mode);
   Vline(Image,newy+1,newy2-1,newx2,color,mode);
  end;
end;

Procedure TRMDrawTools.DLine(Image : TCanvas;x1,y1,x2,y2:Integer;color : TColor; mode : integer);
var
 xr,yr,dxr,dyr:real;
 x,y,dx,dy:integer;
begin
 if abs(x2-x1)>=abs(y2-y1) then begin
    if x1<=x2 then dx:=1 else dx:=-1;
    if x1<>x2 then dyr:=(y2-y1)/abs(x2-x1) else dyr:=0;
  x:=x1-dx;
  yr:=y1;
  repeat
   x:=x+dx;
   //Rplot(x,round(yr),Rubber);
    PutPixel(Image,x,round(yr),color,mode);
   yr:=yr+dyr;
  until x=x2;
  end
  else begin
   dxr:=(x2-x1)/abs(y2-y1);
   if y1<y2 then dy:=1 else dy:=-1;
   y:=y1-dy;
   xr:=x1;
   repeat
    y:=y+dy;
   //round(xr),y,Rubber);
   PutPixel(Image,round(xr),y,color,mode);
    xr:=xr+dxr;
   until y=y2;
  end;
 end;




procedure TRMDrawTools.draw_ellipse(Image : TCanvas;xc,  yc,  a, b : Integer;color : TColor; mode : integer);
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
  putpixel(image,xc+x, yc+y,color,mode);
  if (x<>0) OR (y<>0) then
  begin
    putpixel(image,xc-x, yc-y,color,mode);
    if (x<>0) AND (y<>0) then
    begin
      putpixel(image,xc+x, yc-y,color,mode);
      putpixel(image,xc-x, yc+y,color,mode);
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


procedure TRMDrawTools.rLine(Image : TCanvas;x,y,w : integer;color : TColor; mode : integer);
var
 i : integer;
begin
  for i:=x to x+w-1 do
  begin
    putpixel(image,i,y,color,mode);
  end;
end;

procedure TRMDrawTools.rRectFill(Image : TCanvas;x,y,w,h : integer;color : TColor; mode : integer);
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
    putpixel(image,i,j,color,mode);
  end;
end;

end;



procedure TRMDrawTools.fill_ellipse(Image : TCanvas;xc, yc,  a,  b : integer;color : TColor; mode : integer);
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
      rline(Image,xc-x, yc-y, width,color,mode);
      if (y<>0) then rline(Image,xc-x, yc+y, width,color,mode);
      dec(y);
      inc(dyt,d2yt);
      inc(t,dyt);
    end
   else
   begin
     rline(Image,xc-x, yc-y, width,color,mode);
     if (y<>0) then   rline(Image,xc-x, yc+y, width,color,mode);
     inc(x);
     inc(dxt,d2xt);
     inc(t,dxt);

     dec(y);
     inc(dyt,d2yt);
     inc(t,dyt);

     inc(width,2);
   end;
  end;
  if (b = 0) then rline(Image,xc-a, yc, 2*a+1,color,mode);
end;



Procedure TRMDrawTools.DEllipse(Image : TCanvas;xc,yc,x2,y2:Integer;color : TColor; mode : integer;Full:integer);
var
 rx,ry : integer;
begin
 rx:=abs(x2-xc);
 if rx < 1 then rx:=1;
 ry:=abs(y2-yc);
 if ry < 1 then ry:=1;
 if full=1 then
 begin
  fill_ellipse(image,xc,yc,rx,ry,color,mode);
 end
 else
 begin
   draw_ellipse(image,xc,yc,rx,ry,color,mode);
 end;
end;

Procedure TRMDrawTools.DCircle(Image : TCanvas;xc,yc,x2,y2:Integer;color : TColor; mode : integer;Full:integer);
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
  fill_ellipse(image,xc,yc,radius,radius,color,mode);
 end
 else
 begin
   draw_ellipse(image,xc,yc,radius,radius,color,mode);
 end;
end;
(*
Procedure TRMDrawTools.DCircle(Image : TCanvas;xc,yc,x2,y2:Integer;color : TColor; mode : integer;Full:integer);
var
 radius : Integer;
 x,y,d : Integer;
 r1,r2:Integer;
 i : word;
 CBuf : Array[0..255,0..255] of byte;


Function IsOn(x,y:integer) : Boolean;
begin
 IsOn:=True;
 if (x < 0) or (x > 255) or (y < 0) or (y > 255) then
 begin
    IsOn :=True;
    exit;
 end
 else if Cbuf[x,y] = 0 then
 begin
   IsOn :=False;
   Cbuf[x,y] :=1;
   exit;
 end;

end;

Procedure CircPoint(x,y,xc,yc: integer;Full:integer);
var
 xxcp,xxcm,xycp,xycm,yxcp,yxcm,yycp,yycm : integer;
i : integer;
begin
xxcp:=xc+x;
xxcm:=xc-x;
xycp:=xc+y;
xycm:=xc-y;
yxcp:=yc+x;
yxcm:=yc-x;
yycp:=yc+y;
yycm:=yc-y;

if full = 0 then
begin
  if IsOn(xxcp,yycp) = false then PutPixel(Image,xxcp,yycp,color,mode);
  if IsOn(xxcm,yycp) = false then PutPixel(Image,xxcm,yycp,color,mode);
  if IsOn(xxcp,yycm) = false then PutPixel(Image,xxcp,yycm,color,mode);
  if IsOn(xxcm,yycm) = false then PutPixel(Image,xxcm,yycm,color,mode);
  if IsOn(xycp,yxcp) = false then PutPixel(Image,xycp,yxcp,color,mode);
  if IsOn(xycp,yxcm) = false then PutPixel(Image,xycp,yxcm,color,mode);
  if IsOn(xycm,yxcp) = false then PutPixel(Image,xycm,yxcp,color,mode);
  if IsOn(xycm,yxcm) = false then PutPixel(Image,xycm,yxcm,color,mode);
end
else
begin
  for i:=xxcm to xxcp do
  begin
    PutPixel(Image,i,yycp,color,mode);
    PutPixel(Image,i,yycm,color,mode);
  end;
  for i:= xycm to xycp do
  begin
    PutPixel(Image,i,yxcp,color,mode);
    PutPixel(Image,i,yxcm,color,mode);
  end;
end;
end;



begin

  FillChar(CBuf,Sizeof(CBuf),0);
  r1:=abs(xc-x2);
  r2:=abs(yc-y2);
  radius:=r2;
  if r1>r2 then
  begin
    radius:=r1
  end;
  x:=0;
  y:=radius;
  d:=3-(2*radius);

  while x<y do
  begin
    Circpoint(x,y,xc,yc,Full);
    if d < 0 then
    begin
      d:=d+(4*x)+6;
    end
    else
    begin
      d:=d+4*(x-y)+10;
      y:=y-1;
    end;
    x:=x+1
   end;
   if (x=y)  then CircPoint(x,y,xc,yc,Full);
end;


 *)




procedure TRMDrawTools.ADrawShape(Image : TCanvas; x,y,x2,y2 : integer;color : TColor; mode,shape,full : Integer);
begin
   if shape = DrawShapeRectangle then
   begin
      ARectangle(Image,x,y,x2,y2,color,mode);
   end
   else if shape = DrawShapeFRectangle then
   begin
      SetZoomMode(0);
      Rect(Image,x,y,x2,y2,color,mode,full);
      SetZoomMode(1);
   end
   else if shape = DrawShapeLine then
   begin
      SetZoomMode(0);
      Dline(Image,x,y,x2,y2,color,mode);
      SetZoomMode(1);
   end
   else if shape = DrawShapeCircle then
   begin
      SetZoomMode(0);
      DCircle(Image,x,y,x2,y2,color,mode,0);
      SetZoomMode(1);
   end
   else if shape = DrawShapeFCircle then
   begin
      SetZoomMode(0);
      DCircle(Image,x,y,x2,y2,color,mode,full);
      SetZoomMode(1);
   end
   else if shape = DrawShapeEllipse then
   begin
      SetZoomMode(0);
      DEllipse(Image,x,y,x2,y2,color,mode,0);
      SetZoomMode(1);
   end
   else if shape = DrawShapeFEllipse then
   begin
      SetZoomMode(0);
      DEllipse(Image,x,y,x2,y2,color,mode,full);
      SetZoomMode(1);
   end
   else if shape = DrawShapePencil then
   begin
      SetZoomMode(0);
      PutPixel(Image,x,y,color,mode);
      SetZoomMode(1);
   end
   else if shape = DrawShapeSpray then
   begin
      SetZoomMode(0);
      SprayPaint(Image,x,y,color,mode);
      SetZoomMode(1);
   end;
end;

procedure TRMDrawTools.DrawShape(Image : TCanvas;x,y,x2,y2 : integer;color : TColor; mode,shape,full : integer);
begin
   if shape = DrawShapeRectangle then
   begin
     Rect(Image,x,y,x2,y2,color,mode,0);
   end
   else if shape = DrawShapeFRectangle then
   begin
      Rect(Image,x,y,x2,y2,color,mode,full);
    end
   else if shape = DrawShapeLine then
   begin
      Dline(Image,x,y,x2,y2,color,mode);
   end
   else if shape = DrawShapeCircle then
   begin
      DCircle(Image,x,y,x2,y2,color,mode,0);
   end
   else if shape = DrawShapeFCircle then
   begin
      DCircle(Image,x,y,x2,y2,color,mode,full);
   end
   else if shape = DrawShapeEllipse then
   begin
      DEllipse(Image,x,y,x2,y2,color,mode,0);
   end
   else if shape = DrawShapeFEllipse then
   begin
      DEllipse(Image,x,y,x2,y2,color,mode,full);
   end
   else if shape = DrawShapePencil then
   begin
     PutPixel(Image,x,y,color,mode);
   end
    else if shape = DrawShapeSpray then
     begin
       SprayPaint(Image,x,y,color,mode);
     end
  else if shape = DrawShapeClip then
   begin
     DClip(Image,x,y,x2,y2,color,mode);
   end;


end;

procedure TRMDrawTools.SetGridThickX(amount : integer);
begin
  GridThickX:=amount;
end;

procedure TRMDrawTools.SetGridThickY(amount : integer);
begin
  GridThickY:=amount;
end;

procedure TRMDrawTools.SetCellWidth(cWidth : integer);
begin
  CellWidth:=cWidth;
end;

procedure TRMDrawTools.SetCellHeight(cHeight : integer);
begin
  CellHeight:=cHeight;
end;

function TRMDrawTools.GetCellsPerRow(ImageWidth : integer) : integer;
begin
 If GridMode = 1 then
 begin
   GetCellsPerRow:=ImageWidth div (CellWidth+GridThickY);
 end
 else
 begin
    GetCellsPerRow:=ImageWidth div (CellWidth);
 end;
end;

function TRMDrawTools.GetCellsPerCol(ImageHeight : integer) : integer;
begin
 If GridMode = 1 then
 begin
   GetCellsPerCol:=ImageHeight div (CellHeight+GridThickX);
 end
 else
 begin
   GetCellsPerCol:=ImageHeight div (CellHeight);
 end;
end;

//creates offsets for the scrollers based on Actual Image width and Zoom displayed area
function TRMDrawTools.GetMaxXOffset(ActualImageWidth,ZoomImageWidth : integer) : integer;
var
  xoff : integer;
begin
GetMaxXOffset:=ActualImageWidth-GetCellsPerRow(ZoomImageWidth)-1;
//xoff:=ActualImageWidth-GetCellsPerRow(ZoomImageWidth); //brackets matter
//GetMaxXOffset:=xoff-1;
//GetMaxXOffset:= 256 - ((690 div (20+1)) -1);
end;

function TRMDrawTools.GetMaxYOffset(ActualImageHeight,ZoomImageHeight : integer) : integer;
var
  yoff : integer;
begin
  GetMaxYOffset:=ActualImageHeight-GetCellsPerCol(ZoomImageHeight)-1;
  //yoff:=ActualImageHeight-GetCellsPerCol(ZoomImageHeight);
  //GetMaxYOffset:=yoff-1;
end;


function TRMDrawTools.GetZoomX(x : integer) : integer;
begin
  GetZoomX:=x div (CellWidth+GridThickY);
end;

function TRMDrawTools.GetZoomY(y : integer) : integer;
begin
 GetZoomY:=y div (CellHeight+GridThickX);
end;


procedure TRMDrawTools.DrawGrid(Image : TCanvas;x,y,gWidth,gHeight,mode : integer);
var
 startx,starty,x2,y2 : integer;
begin
   x2:=gWidth;
   y2:=gHeight;
   Image.Brush.Color := clBlack;
   Image.FillRect(0, 0, Image.Width, Image.Height);


   if mode = 1 then Image.Pen.Mode := pmNotXor else Image.Pen.Mode := pmCopy;
//   Image2.Canvas.Brush.Style := bsSolid;
//   Image2.Canvas.Brush.Color := clblue;
//   Image2.Canvas.FillRect(0,0,256,256);
   Image.Brush.Color := clwhite;
   startx:=x;
   while startx < x2 do
   begin
//      Image2.Canvas.Rectangle(startx,y,startx+GridYThick,y2);
      Image.FillRect(startx,y,startx+GridThickY,y2);
      inc(startx,CellWidth+GridThickY);
   end;
   starty:=y;
   while starty < y2 do
   begin
//      Image2.Canvas.Rectangle(startx,y,startx+GridYThick,y2);
      Image.FillRect(x,starty,x2,starty+GridThickX);
      inc(starty,CellHeight+GridThickX);
   end;
end;


procedure TRMDrawTools.SetZoomMode(mode : integer);
begin
  ZoomMode:=mode;
end;

procedure TRMDrawTools.SetZoomSize(size : integer);
begin
  if size > 10 then size:=10;
  if size < 1 then size:=1;
  ZoomSize:=size;
  SetCellWidth(size*10);
  SetCellHeight(size*10);
end;

function TRMDrawTools.GetZoomSize : integer;
begin
  GetZoomSize:=ZoomSize;
end;

function  TRMDrawTools.GetZoomMode : integer;
begin
  GetZoomMode:=ZoomMode;
end;

procedure TRMDrawTools.SetDrawTool(Tool : integer);
begin
   DrawTool:=Tool;
end;

function TRMDrawTools.GetDrawTool : integer;
begin
   GetDrawTool:=DrawTool;
end;

procedure TRMDrawTools.SetGridMode(mode:integer);
begin
  GridMode:=mode;
  if mode = 0 then
  begin
    SetGridThickY(0);
    SetGridThickX(0);
  end
  else
  begin
   SetGridThickY(1);
   SetGridThickX(1);
  end;
end;

function TRMDrawTools.GetGridMode : integer;
begin
  GetGridMode:=GridMode;
end;

(*
To easily convert between one format to another, some simple formulae can be used for each of the red, green and blue values:

// 6-bit VGA to 8-bit RGB:
eight_bit_value = (six_bit_value * 255) / 63

// 8-bit RGB to 6-bit VGA
six_bit_value = (eight_bit_value * 63) / 255
Performing the multiplication before the division removes the need to use floating point numbers and minimises any rounding errors.

More efficient conversions can also be used when speed is more important than code readability:

// 6-bit VGA to 8-bit RGB
eight_bit_value = (six_bit_value << 2) | (six_bit_value >> 4)

// 8-bit RGB to 6-bit VGA
six_bit_value = eight_bit_value >> 2

const clr:array[0..255] of colour=(
(r:0;g:0;b:0),
(r:0;g:170;b:0),
(r:0;g:0;b:170),
(r:0;g:170;b:170),
(r:170;g:0;b:0),
(r:170;g:170;b:0),
(r:170;g:0;b:85),
(r:170;g:170;b:170),
(r:85;g:85;b:85),
(r:85;g:255;b:85),
(r:85;g:85;b:255),
(r:85;g:255;b:255),
(r:255;g:85;b:85),
(r:255;g:255;b:85),
(r:255;g:85;b:255),
(r:255;g:255;b:255),
(r:0;g:0;b:0),
(r:20;g:20;b:20),
(r:32;g:32;b:32),
(r:44;g:44;b:44),
(r:56;g:56;b:56),
(r:68;g:68;b:68),
(r:80;g:80;b:80),
(r:97;g:97;b:97),
(r:113;g:113;b:113),
(r:129;g:129;b:129),
(r:145;g:145;b:145),
(r:161;g:161;b:161),
(r:182;g:182;b:182),
(r:202;g:202;b:202),
(r:226;g:226;b:226),
(r:255;g:255;b:255),
(r:0;g:255;b:0),
(r:64;g:255;b:0),
(r:125;g:255;b:0),
(r:190;g:255;b:0),
(r:255;g:255;b:0),
(r:255;g:190;b:0),
(r:255;g:125;b:0),
(r:255;g:64;b:0),
(r:255;g:0;b:0),
(r:255;g:0;b:64),
(r:255;g:0;b:125),
(r:255;g:0;b:190),
(r:255;g:0;b:255),
(r:190;g:0;b:255),
(r:125;g:0;b:255),
(r:64;g:0;b:255),
(r:0;g:0;b:255),
(r:0;g:64;b:255),
(r:0;g:125;b:255),
(r:0;g:190;b:255),
(r:0;g:255;b:255),
(r:0;g:255;b:190),
(r:0;g:255;b:125),
(r:0;g:255;b:64),
(r:125;g:255;b:125),
(r:157;g:255;b:125),
(r:190;g:255;b:125),
(r:222;g:255;b:125),
(r:255;g:255;b:125),
(r:255;g:222;b:125),
(r:255;g:190;b:125),
(r:255;g:157;b:125),
(r:255;g:125;b:125),
(r:255;g:125;b:157),
(r:255;g:125;b:190),
(r:255;g:125;b:222),
(r:255;g:125;b:255),
(r:222;g:125;b:255),
(r:190;g:125;b:255),
(r:157;g:125;b:255),
(r:125;g:125;b:255),
(r:125;g:157;b:255),
(r:125;g:190;b:255),
(r:125;g:222;b:255),
(r:125;g:255;b:255),
(r:125;g:255;b:222),
(r:125;g:255;b:190),
(r:125;g:255;b:157),
(r:182;g:255;b:182),
(r:198;g:255;b:182),
(r:218;g:255;b:182),
(r:234;g:255;b:182),
(r:255;g:255;b:182),
(r:255;g:234;b:182),
(r:255;g:218;b:182),
(r:255;g:198;b:182),
(r:255;g:182;b:182),
(r:255;g:182;b:198),
(r:255;g:182;b:218),
(r:255;g:182;b:234),
(r:255;g:182;b:255),
(r:234;g:182;b:255),
(r:218;g:182;b:255),
(r:198;g:182;b:255),
(r:182;g:182;b:255),
(r:182;g:198;b:255),
(r:182;g:218;b:255),
(r:182;g:234;b:255),
(r:182;g:255;b:255),
(r:182;g:255;b:234),
(r:182;g:255;b:218),
(r:182;g:255;b:198),
(r:0;g:113;b:0),
(r:28;g:113;b:0),
(r:56;g:113;b:0),
(r:85;g:113;b:0),
(r:113;g:113;b:0),
(r:113;g:85;b:0),
(r:113;g:56;b:0),
(r:113;g:28;b:0),
(r:113;g:0;b:0),
(r:113;g:0;b:28),
(r:113;g:0;b:56),
(r:113;g:0;b:85),
(r:113;g:0;b:113),
(r:85;g:0;b:113),
(r:56;g:0;b:113),
(r:28;g:0;b:113),
(r:0;g:0;b:113),
(r:0;g:28;b:113),
(r:0;g:56;b:113),
(r:0;g:85;b:113),
(r:0;g:113;b:113),
(r:0;g:113;b:85),
(r:0;g:113;b:56),
(r:0;g:113;b:28),
(r:56;g:113;b:56),
(r:68;g:113;b:56),
(r:85;g:113;b:56),
(r:97;g:113;b:56),
(r:113;g:113;b:56),
(r:113;g:97;b:56),
(r:113;g:85;b:56),
(r:113;g:68;b:56),
(r:113;g:56;b:56),
(r:113;g:56;b:68),
(r:113;g:56;b:85),
(r:113;g:56;b:97),
(r:113;g:56;b:113),
(r:97;g:56;b:113),
(r:85;g:56;b:113),
(r:68;g:56;b:113),
(r:56;g:56;b:113),
(r:56;g:68;b:113),
(r:56;g:85;b:113),
(r:56;g:97;b:113),
(r:56;g:113;b:113),
(r:56;g:113;b:97),
(r:56;g:113;b:85),
(r:56;g:113;b:68),
(r:80;g:113;b:80),
(r:89;g:113;b:80),
(r:97;g:113;b:80),
(r:105;g:113;b:80),
(r:113;g:113;b:80),
(r:113;g:105;b:80),
(r:113;g:97;b:80),
(r:113;g:89;b:80),
(r:113;g:80;b:80),
(r:113;g:80;b:89),
(r:113;g:80;b:97),
(r:113;g:80;b:105),
(r:113;g:80;b:113),
(r:105;g:80;b:113),
(r:97;g:80;b:113),
(r:89;g:80;b:113),
(r:80;g:80;b:113),
(r:80;g:89;b:113),
(r:80;g:97;b:113),
(r:80;g:105;b:113),
(r:80;g:113;b:113),
(r:80;g:113;b:105),
(r:80;g:113;b:97),
(r:80;g:113;b:89),
(r:0;g:64;b:0),
(r:16;g:64;b:0),
(r:32;g:64;b:0),
(r:48;g:64;b:0),
(r:64;g:64;b:0),
(r:64;g:48;b:0),
(r:64;g:32;b:0),
(r:64;g:16;b:0),
(r:64;g:0;b:0),
(r:64;g:0;b:16),
(r:64;g:0;b:32),
(r:64;g:0;b:48),
(r:64;g:0;b:64),
(r:48;g:0;b:64),
(r:32;g:0;b:64),
(r:16;g:0;b:64),
(r:0;g:0;b:64),
(r:0;g:16;b:64),
(r:0;g:32;b:64),
(r:0;g:48;b:64),
(r:0;g:64;b:64),
(r:0;g:64;b:48),
(r:0;g:64;b:32),
(r:0;g:64;b:16),
(r:32;g:64;b:32),
(r:40;g:64;b:32),
(r:48;g:64;b:32),
(r:56;g:64;b:32),
(r:64;g:64;b:32),
(r:64;g:56;b:32),
(r:64;g:48;b:32),
(r:64;g:40;b:32),
(r:64;g:32;b:32),
(r:64;g:32;b:40),
(r:64;g:32;b:48),
(r:64;g:32;b:56),
(r:64;g:32;b:64),
(r:56;g:32;b:64),
(r:48;g:32;b:64),
(r:40;g:32;b:64),
(r:32;g:32;b:64),
(r:32;g:40;b:64),
(r:32;g:48;b:64),
(r:32;g:56;b:64),
(r:32;g:64;b:64),
(r:32;g:64;b:56),
(r:32;g:64;b:48),
(r:32;g:64;b:40),
(r:44;g:64;b:44),
(r:48;g:64;b:44),
(r:52;g:64;b:44),
(r:60;g:64;b:44),
(r:64;g:64;b:44),
(r:64;g:60;b:44),
(r:64;g:52;b:44),
(r:64;g:48;b:44),
(r:64;g:44;b:44),
(r:64;g:44;b:48),
(r:64;g:44;b:52),
(r:64;g:44;b:60),
(r:64;g:44;b:64),
(r:60;g:44;b:64),
(r:52;g:44;b:64),
(r:48;g:44;b:64),
(r:44;g:44;b:64),
(r:44;g:48;b:64),
(r:44;g:52;b:64),
(r:44;g:60;b:64),
(r:44;g:64;b:64),
(r:44;g:64;b:60),
(r:44;g:64;b:52),
(r:44;g:64;b:48),
(r:0;g:0;b:0),
(r:0;g:0;b:0),
(r:0;g:0;b:0),
(r:0;g:0;b:0),
(r:0;g:0;b:0),
(r:0;g:0;b:0),
(r:0;g:0;b:0),
(r:0;g:0;b:0));

*)

 (*
 r:0;g:0;b:0),
(r:0;g:170;b:0),
(r:0;g:0;b:170),
(r:0;g:170;b:170),
(r:170;g:0;b:0),
(r:170;g:170;b:0),
(r:170;g:0;b:85),
(r:170;g:170;b:170),
(r:85;g:85;b:85),
(r:85;g:255;b:85),
(r:85;g:85;b:255),
(r:85;g:255;b:255),
(r:255;g:85;b:85),
(r:255;g:255;b:85),
(r:255;g:85;b:255),
(r:255;g:255;b:255),     *)

procedure TRMDrawTools.AddEGAPalette(var CP : TColorPalette);
var
  TC : TColor;
  i : integer;
begin
(*
    RMCoreBase.Palette.AddColor(0,0,0);    //black
    RMCoreBase.Palette.AddColor(0,0,170);   //blue
    RMCoreBase.Palette.AddColor(0,170,0);   //green
    RMCoreBase.Palette.AddColor(0,170,170);  //cyan?
    RMCoreBase.Palette.AddColor(170,0,0);  //red
    RMCoreBase.Palette.AddColor(170,0,170); //purple
    RMCoreBase.Palette.AddColor(170,85,0); //brown
    RMCoreBase.Palette.AddColor(170,170,170); //grey
    RMCoreBase.Palette.AddColor(85,85,85);//dark grey
    RMCoreBase.Palette.AddColor(85,85,255);  //light blue
    RMCoreBase.Palette.AddColor(85,255,85);  //light green
    RMCoreBase.Palette.AddColor(85,255,255);  //turqois
    RMCoreBase.Palette.AddColor(255,85,85); //light red
    RMCoreBase.Palette.AddColor(255,85,255);  //pink2
    RMCoreBase.Palette.AddColor(255,255,85);  //yellow
    RMCoreBase.Palette.AddColor(255,255,255);  //white
  *)
    CP.ClearColors;
    for i:=0 to 15 do
    begin
      TC:=RGBToColor(VGADefault256[i].r,
                     VGADefault256[i].g,
                     VGADefault256[i].b);
      CP.AddColor(TC);

    end;
end;

procedure TRMDrawTools.AddMonoPalette(var CP : TColorPalette);
var
  TC : TColor;
  i : integer;
begin
    CP.ClearColors;
    for i:=0 to 1 do
    begin
      TC:=RGBToColor(MonoDefault[i].r,
                     MonoDefault[i].g,
                     MonoDefault[i].b);
      CP.AddColor(TC);
    end;
end;

procedure TRMDrawTools.AddCGAPalette0(var CP : TColorPalette);
var
  TC : TColor;
  i : integer;
begin
    CP.ClearColors;
    for i:=0 to 3 do
    begin
      TC:=RGBToColor(CGADefault0[i].r,
                     CGADefault0[i].g,
                     CGADefault0[i].b);
      CP.AddColor(TC);
    end;
end;

procedure TRMDrawTools.AddCGAPalette1(var CP : TColorPalette);
var
  TC : TColor;
  i : integer;
begin
    CP.ClearColors;
    for i:=0 to 3 do
    begin
      TC:=RGBToColor(CGADefault1[i].r,
                     CGADefault1[i].g,
                     CGADefault1[i].b);
      CP.AddColor(TC);
    end;
end;





procedure TRMDrawTools.AddVGAPalette(var CP : TColorPalette);
var
  TC : TColor;
  i : integer;
begin
    CP.ClearColors;
    for i:=0 to 15 do
    begin
      TC:=RGBToColor(VGADefault256[i].r,
                     VGADefault256[i].g,
                     VGADefault256[i].b);
      CP.AddColor(TC);
    end;
end;

procedure TRMDrawTools.AddVGAPalette256(var CP : TColorPalette);
var
  TC : TColor;
  i : integer;
begin
    CP.ClearColors;
    for i:=0 to 255 do
    begin
      TC:=RGBToColor(VGADefault256[i].r,
                     VGADefault256[i].g,
                     VGADefault256[i].b);
      CP.AddColor(TC);

    end;
end;

procedure TRMDrawTools.AddAmigaPalette(var CP : TColorPalette; ColorNum : integer);
var
  TC : TColor;
  i : integer;
begin
    CP.ClearColors;
    for i:=0 to ColorNum-1 do
    begin
      TC:=RGBToColor(AmigaDefault32[i].r,
                     AmigaDefault32[i].g,
                     AmigaDefault32[i].b);
      CP.AddColor(TC);

    end;
end;

Procedure TRMDrawTools.Hflip(x,y,x2,y2: word);
Var
 i,j : word;
 L,T   : word;
 C,C2,A  : Word;
begin
  L :=(x2-x) Div 2;
  A :=x2;
  For i:=x to (x2-L-1) do
  begin
    For j:=y to y2 do
    begin
     C:=RMCoreBase.GetPixel(i,j);
     C2:=RMCoreBase.GetPixel(A,j);
     RMCoreBase.PutPixel(i,j,C2);
     RMCoreBase.PutPixel(A,J,C);
    end;
    Dec(A);
  end;

end;

Procedure TRMDrawTools.VFlip(x,y,x2,y2 : word);
Var
 i,j : word;
 L,T   : word;
 C,C2,A  : Word;
begin
  L :=(y2-y) Div 2;
  A :=y2;
  For j:=y to (y2-L-1) do
  begin
    For i:=x to x2 do
    begin
     C:=RMCoreBase.GetPixel(i,j);
     C2:=RMCoreBase.GetPixel(i,A);
     RMCoreBase.PutPixel(i,j,C2);
     RMCoreBase.PutPixel(i,A,C);
    end;
    Dec(A);
  end;
end;

Procedure TRMDrawTools.ScrollLeft(x,y,x2,y2 : word);
Var
 i,j,c,d : Word;
begin
 For j:=y to y2 do
 begin
   d:=RMCoreBase.GetPixel(x,j);
   For i:=x+1 to x2 do
   begin
    c:=RMCoreBase.GetPixel(i,j);
    RMCoreBase.PutPixel(i-1,j,c);
   end;
   RMCoreBase.PutPixel(x2,j,d);
 end;
end;

Procedure TRMDrawTools.ScrollRight(x,y,x2,y2 : word);
Var
 i,j,c,d : Word;
begin
 For j:=y to y2 do
 begin
   d:=RMCoreBase.GetPixel(x2,j);
   For i:=x2-1 downto x do
   begin
    c:=RMCoreBase.GetPixel(i,j);
    RMCoreBase.PutPixel(i+1,j,c);
   end;
   RMCoreBase.PutPixel(x,j,d);
 end;
end;

Procedure TRMDrawTools.ScrollUp(x,y,x2,y2 : word);
Var
 i,j,c,d : Word;
begin
 For i:=x to x2 do
 begin
   d:=RMCoreBase.GetPixel(i,y);
   For j:=y to y2-1 do
   begin
    c:=RMCoreBase.GetPixel(i,j+1);
    RMCoreBase.PutPixel(i,j,c);
   end;
   RMCoreBase.PutPixel(i,y2,d);
 end;
end;

Procedure TRMDrawTools.ScrollDown(x,y,x2,y2 : word);
Var
 i,j,c,d : Word;
begin
 For i:=x to x2 do
 begin
   d:=RMCoreBase.GetPixel(i,y2);
   For j:=y2  downto y+1 do
   begin
    c:=RMCoreBase.GetPixel(i,j-1);
   RMCoreBase.PutPixel(i,j,c);
   end;
   RMCoreBase.PutPixel(i,y,d);
 end;
end;

Procedure TRMDrawTools.Copy(x,y,x2,y2 : integer);
var
 bmp : TBitmap;
 tcol : TColor;
 colindex : integer;
 i,j : integer;
 width,height : integer;
begin
 bmp:=TBitmap.Create;
 Width:=x2-x+1;
 height:=y2-y+1;
 bmp.Width:=width;
 bmp.height:=height;

 for j:=0 to height-1 do
 begin
   for i:=0 to width-1 do
   begin
        colIndex:=RMCoreBase.GetPixel(x+i,y+j);
        tcol:=RGBToColor(RMCoreBase.Palette.GetRed(colIndex),
                         RMCoreBase.Palette.GetGreen(colIndex),
                         RMCoreBase.Palette.GetBlue(colIndex));
        bmp.canvas.Pixels[i,j]:=tcol;
   end;
 end;
 Clipboard.Assign(bmp);
 bmp.Free;
end;

Procedure TRMDrawTools.Paste(x,y,x2,y2 : integer);
var
 bmp : TBitmap;
 pwidth,pheight : integer;
 width,height  : integer;
 i,j           : integer;
 tcol : TColor;
 colindex : integer;

begin
 width:=x2-x+1;
 height:=y2-y+1;

 bmp:=TBitmap.Create;

 if Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
 begin
   bmp.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));

   if bmp.width > width then pwidth:=width else pwidth:=bmp.Width;
   if bmp.height > height then pHeight:=height else pheight:=bmp.height;

   for j:=0 to pheight-1 do
   begin
     for i:=0 to pwidth-1 do
     begin
       tcol :=bmp.canvas.Pixels[i,j];
       colindex:=RMCoreBase.Palette.FindColorMatch(Red(tcol),Green(tcol),blue(tcol));
       RMCoreBase.PutPixel(x+i,y+j,colindex);
     end;
   end;
 end;
 bmp.Free;
end;


initialization
  RMDrawTools:=TRMDrawTools.Create;



end.


