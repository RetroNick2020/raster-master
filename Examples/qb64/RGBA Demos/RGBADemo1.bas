'Raster Master Example for Loading Export->RES Text Inlcude QB64 code
'Image& variables are auto dimed and loaded with image that is exported
'All you have to do is use _PutImage to display

Screen _NewImage(800, 600, 32)

'$include:'planes.bas'

Line (0, 0)-(799, 599), _RGB(0, 0, 222), BF
_PutImage (10, 120), Image1&, 0 'transparent image - index 0 as transparent color
_PutImage (60, 120)-(160, 240), Image2&, 0 'transparent image - fuschia as transparent color
_PutImage (200, 100)-(320, 220), Image3&, 0 'transparent image - fuschia as transparent color

