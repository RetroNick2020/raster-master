'Demos on how to load RGB and RGBA Images from Raster Master
'Use RayLib RGB and RGBA as export options
'$include: 'images.bas'

Dim image1&, image2&, image3&
Dim myMem As _MEM

Screen _NewImage(800, 600, 32)
oldmode% = _Dest 'points to _NewImage - our screen


'create unage handles
image1& = _NewImage(Image1.Width, Image1.Height, 32)
image2& = _NewImage(Image2.Width, Image2.Height, 32)
image3& = _NewImage(Image3.Width, Image3.Height, 32)


'Method 1 on how to read from the RGBA data statements - we don't need to use _Dest here
'writing directly to memory - notice the  order on wrting to  memory it's BGRA - NOT RGBA
myMem = _MemImage(image1&)
counter = 0

For j = 0 To Image1.Height - 1
    For i = 0 To Image1.Width - 1
        Read r, g, b, a
        _MemPut myMem, myMem.OFFSET + counter, b As _UNSIGNED _BYTE
        _MemPut myMem, myMem.OFFSET + counter + 1, g As _UNSIGNED _BYTE
        _MemPut myMem, myMem.OFFSET + counter + 2, r As _UNSIGNED _BYTE
        _MemPut myMem, myMem.OFFSET + counter + 3, a As _UNSIGNED _BYTE
        counter = counter + 4
    Next i
Next j

'Method 2 on how to read from the RGBA data statements - we use _Dest abd PSET here
_Dest image2&

For j = 0 To Image2.Height - 1
    For i = 0 To Image2.Width - 1
        Read r, g, b, a
        PSet (i, j), _RGBA(r, g, b, a)
    Next i
Next j

'Method 3 - our data statements only have RGB values for this last image
_Dest image3&

For j = 0 To Image3.Height - 1
    For i = 0 To Image3.Width - 1
        Read r, g, b
        PSet (i, j), _RGB(r, g, b) 'notice _RGB - not _RGBA
    Next i
Next j

_Dest oldmode& 'return back to displaying to screen

Line (0, 0)-(799, 599), _RGB(0, 0, 222), BF
_PutImage (10, 120), image1&, 0 'transparent image - index 0 as transparent color
_PutImage (60, 120), image2&, 0 'transparent image - fuschia as transparent color
_PutImage (110, 120), image3&, 0 'not transpaeent



