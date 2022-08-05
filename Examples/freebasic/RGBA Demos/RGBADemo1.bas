'* ************************************************************ *
'* RGBADemo1.bas For FreeBASIC                                  *
'*                                                              *
'* Images were created by using Raster Master RES export options*
'* ************************************************************ *
Dim a As Integer
ScreenRes 800, 600, 32
#include "planes.bas"
line(0,0)-(799,599),RGB(0,0,255),bf
put (120,120),Image1,alpha
put (220,120),Image2,alpha
put (320,120),Image3,alpha
input a


