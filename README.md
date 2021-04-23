# raster-master
Sprite editor for QuickBasic\C Turbo Pascal\C

30 years ago i wrote a small uility in Turbo Pascal (DOS) that would allow me to create simple sprites/icons and generate code. I have always wanted to do a port of this utility to Windows and provide some updates. I may be the slowest programmer in the world but i have managed to get the hard parts completed. I am working on touching up the user interface. In a few days there should be something here.
Apr 23 - 2021 - New Binary release Raster Master v1.0 beta R9 - new oval/ellipse tools - new AmigaBASIC export formats for Bobs and VSprites
Mar 12 - 2021 - New Binary release Raster Master v1.0 beta R6 - copy/paste, palette open/save, xgf export format for all, palette export
Mar 1 - 2021 - New Binary release Raster Master v1.0 Beta R4
Feb 25 - 2021 -I forgot to post video for QuickBasic\QB64 https://youtu.be/rZPc7VJhbeE

Feb 25 - 2021 -I also figured out the AmigaBasic Bob and sprite formats also. Check out the video.
https://youtu.be/OGh5yVsTEcA Here is the code that is in the vedeo

    screen 1,300,190,4,1
    window 2,"RM",(1,1)-(275,170),15,1

    defint a-z
    option base 1

    dim image(1000)

    line(0,0)-(100,100),5,bf
    line(50,50)-(200,180),7,bf

    restore cross16
    size=151
    Call ReadPutImage(image(),size)
    put (100,40),image,and
    Call MakeSpriteImage(image(),SpriteImage$,size)

    restore face16
    size=963
    Call ReadPutImage(image(),size)
    Call MakeBobImage(image(),BobImage$,size)

    object.shape 1, BobImage$
    object.x 1,50
    object.y 1,50
    object.vx 1,10
    object.on 1
    object.start 1

    object.shape 2, SpriteImage$
    object.x 2,250
    object.y 2,50
    object.vx 2,-10
    object.on 2
    object.start 2

    a$=""
    while a$=""
    sleep
    a$=inkey$
    wend 

    SUB MakeSpriteImage(ImageBuf(),ObjectImage$,size) static
    'make 4 color sprite from 16 color Image - use frst 2 bitplanes - width must 16 pixels 
    if ImageBuf(1)<>16 or ImageBuf(3)<>4 then exit sub
    fVSprite=1
    SAVEBACK=8                'Hintergrund retten vor BOB-Zeichnen
    OVERLAY=16 
    Flags=SAVEBACK+OVERLAY+fVSprite
    ObjectImage$=MKL$(0) 'ColorSet
    ObjectImage$=ObjectImage$+MKL$(0) 'DataSet
    ObjectImage$=ObjectImage$+MKI$(0)+MKI$(2)  'Tiefe
    ObjectImage$=ObjectImage$+MKI$(0)+MKI$(ImageBuf(1))  'Breite
    ObjectImage$=ObjectImage$+MKI$(0)+MKI$(ImageBuf(2))  'H�he
    ObjectImage$=ObjectImage$+MKI$(Flags)
    ObjectImage$=ObjectImage$+MKI$(3)                    '(PlanePick)  planePick def 15
    ObjectImage$=ObjectImage$+MKI$(0)  'planeOnOff
    FOR i=4 TO ((size-3) / 2) +3       'Read only first 2 bitplanes from 4 bitplane  image
        ObjectImage$=ObjectImage$+MKI$(ImageBuf(i))
    NEXT i
    IF fVSprite THEN
        'Sprite-Farben ausgeben > Farbwerte �ndern
        ObjectImage$=ObjectImage$+MKI$(&HFF)  'Wei�    = Color 1
        ObjectImage$=ObjectImage$+MKI$(0)     'Schwarz = Color 2
        ObjectImage$=ObjectImage$+MKI$(&HF80) 'Orange  = Color 3
    END IF
    END SUB

    SUB MakeBobImage(ImageBuf(),ObjectImage$,size) static
    fVSprite=0
    SAVEBACK=8                'Hintergrund retten vor BOB-Zeichnen
    OVERLAY=16 
    Flags=SAVEBACK+OVERLAY+fVSprite
    ObjectImage$=MKL$(0) 'ColorSet
    ObjectImage$=ObjectImage$+MKL$(0) 'DataSet
    ObjectImage$=ObjectImage$+MKI$(0)+MKI$(ImageBuf(3))  'Tiefe
    ObjectImage$=ObjectImage$+MKI$(0)+MKI$(ImageBuf(1))  'Breite
    ObjectImage$=ObjectImage$+MKI$(0)+MKI$(ImageBuf(2))  'H�he
    ObjectImage$=ObjectImage$+MKI$(Flags)
    ObjectImage$=ObjectImage$+MKI$(15)                    '(PlanePick)  planePick def 15
    ObjectImage$=ObjectImage$+MKI$(0)  'planeOnOff
    FOR i=4 TO size     
        ObjectImage$=ObjectImage$+MKI$(ImageBuf(i))
    NEXT i
    END SUB

    SUB ReadPutImage(ImageBuf(),size) static
    for i=1 to size
        read ImageBuf(i)
    next i
    END SUB

    '  AmigaBASIC, Array Size= 963 Width= 60 Height= 60 Colors= 16
    '  face16
    face16:
    DATA &H003C,&H003C,&H0004,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H007F,&HF000,&H0000,&H0000,&H07FF,&HFF00,&H0000,&H0000
    DATA &H1FFF,&HFFC0,&H0000,&H0000,&H7FFF,&HFFF0,&H0000,&H0001
    DATA &HFFFF,&HFFFC,&H0000,&H0003,&HFFFF,&HFFFE,&H0000,&H0007
    DATA &HFFFF,&HFE0F,&H0000,&H001F,&H83FF,&HF803,&HC000,&H003E
    DATA &H00FF,&HF0E1,&HE000,&H007C,&H007F,&HE3F8,&HF000,&H0078
    DATA &H703F,&HE3F8,&HF000,&H00F9,&HFC3F,&HC7FC,&H7800,&H01F1
    DATA &HFC1F,&HC7FC,&H7C00,&H03F3,&HFE1F,&HC7FC,&H7E00,&H03F3
    DATA &HFE1F,&HC3F8,&H7E00,&H07F3,&HFE1F,&HC3F8,&H7F00,&H07F1
    DATA &HFC1F,&HE0E0,&HFF00,&H0FF9,&HFC3F,&HE000,&HFF80,&H0FF8
    DATA &H703F,&HF001,&HFF80,&H1FFC,&H007F,&HF803,&HFFC0,&H1FFE
    DATA &H00FF,&HFE0F,&HFFC0,&H1FFF,&H83FF,&HFFFF,&HFFC0,&H1FFF
    DATA &HFFFF,&HFFFF,&HFFC0,&H3FFF,&HFFFF,&HFFFF,&HFFE0,&H3FFF
    DATA &HFFFF,&HFFFF,&HFFE0,&H3FFF,&HFFFF,&HFFFF,&HFFE0,&H3FFF
    DATA &HFFFF,&HFFFF,&HFFE0,&H3FFF,&HFFFF,&HFFFF,&HFFE0,&H3FFF
    DATA &HFFFF,&HFFFF,&HBFE0,&H3FFF,&HFFFF,&HFFFF,&H7FE0,&H3FFF
    DATA &HBFFF,&HFFFE,&HDFE0,&H3FFF,&HC7FF,&HFFFD,&HBFE0,&H3FFF
    DATA &HDBFF,&HFFFB,&HBFE0,&H3FFF,&HEC7F,&HFFF7,&H7FE0,&H1FFF
    DATA &HF7BF,&HFFCE,&HFFC0,&H1FFF,&HF7C7,&HFE3E,&HFFC0,&H1FFF
    DATA &HFBF8,&H01FD,&HFFC0,&H1FFF,&HFDFF,&HFFFB,&HFFC0,&H0FFF
    DATA &HFDFF,&HFFF7,&HFF80,&H0FFF,&HFE3F,&HFFF7,&HFF80,&H07FF
    DATA &HFFC7,&HFF8F,&HFF00,&H07FF,&HFFF8,&H007F,&HFF00,&H03FF
    DATA &HFFFF,&HFFFF,&HFE00,&H03FF,&HFFFF,&HFFFF,&HFE00,&H01FF
    DATA &HFFFF,&HFFFF,&HFC00,&H00FF,&HFFFF,&HFFFF,&HF800,&H007F
    DATA &HFFFF,&HFFFF,&HF000,&H007F,&HFFFF,&HFFFF,&HF000,&H003F
    DATA &HFFFF,&HFFFF,&HE000,&H001F,&HFFFF,&HFFFF,&HC000,&H0007
    DATA &HFFFF,&HFFFF,&H0000,&H0003,&HFFFF,&HFFFE,&H0000,&H0001
    DATA &HFFFF,&HFFFC,&H0000,&H0000,&H7FFF,&HFFF0,&H0000,&H0000
    DATA &H1FFF,&HFFC0,&H0000,&H0000,&H07FF,&HFF00,&H0000,&H0000
    DATA &H007F,&HF000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0004,&H0000,&H0000,&H0000,&H0002,&H0000,&H0000,&H0000
    DATA &H0002,&H0000,&H0000,&H0000,&H0001,&H0000,&H0000,&H0000
    DATA &H0001,&H0000,&H0000,&H0000,&H0000,&H8000,&H0000,&H0000
    DATA &H0000,&H8000,&H0000,&H0000,&H0000,&H4000,&H0000,&H0000
    DATA &H0000,&H4000,&H0000,&H0000,&H0006,&H2000,&H0000,&H0000
    DATA &H0001,&HA000,&H0000,&H0000,&H0000,&H7000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H4000,&H0000,&H0000,&H0000,&H8000,&H0000
    DATA &H4000,&H0001,&H2000,&H0000,&H3800,&H0002,&H4000,&H0000
    DATA &H2400,&H0004,&H4000,&H0000,&H1380,&H0008,&H8000,&H0000
    DATA &H0840,&H0031,&H0000,&H0000,&H0838,&H01C1,&H0000,&H0000
    DATA &H0407,&HFE02,&H0000,&H0000,&H0200,&H0004,&H0000,&H0000
    DATA &H0200,&H0008,&H0000,&H0000,&H01C0,&H0008,&H0000,&H0000
    DATA &H0038,&H0070,&H0000,&H0000,&H0007,&HFF80,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H007F,&HF000,&H0000,&H0000,&H07FF,&HFF00,&H0000,&H0000
    DATA &H1FFF,&HFFC0,&H0000,&H0000,&H7FFF,&HFFF0,&H0000,&H0001
    DATA &HFFFF,&HFFFC,&H0000,&H0003,&HFFFF,&HFFFE,&H0000,&H0007
    DATA &HFFFF,&HFFFF,&H0000,&H001F,&HFFFF,&HFFFF,&HC000,&H003F
    DATA &HFFFF,&HFF1F,&HE000,&H007F,&HFFFF,&HFC07,&HF000,&H007F
    DATA &H8FFF,&HFC07,&HF000,&H00FE,&H03FF,&HF803,&HF800,&H01FE
    DATA &H03FF,&HF803,&HFC00,&H03FC,&H01FF,&HF803,&HFE00,&H03FC
    DATA &H01FB,&HFC07,&HFE00,&H07FC,&H01FD,&HFC07,&HFF00,&H07FE
    DATA &H03FD,&HFF1F,&HFF00,&H0FFE,&H03FE,&HFFFF,&HFF80,&H0FFF
    DATA &H8FFE,&HFFFF,&HFF80,&H1FFF,&HFFFF,&H7FFF,&HFFC0,&H1FFF
    DATA &HFFFF,&H7FFF,&HFFC0,&H1FFF,&HFFFF,&HBFFF,&HFFC0,&H1FFF
    DATA &HFFFF,&HBFFF,&HFFC0,&H3FFF,&HFFF9,&HDFFF,&HFFE0,&H3FFF
    DATA &HFFFE,&H5FFF,&HFFE0,&H3FFF,&HFFFF,&H8FFF,&HFFE0,&H3FFF
    DATA &HFFFF,&HFFFF,&HFFE0,&H3FFF,&HFFFF,&HFFFF,&HFFE0,&H3FFF
    DATA &HFFFF,&HFFFF,&HBFE0,&H3FFF,&HFFFF,&HFFFF,&H7FE0,&H3FFF
    DATA &HBFFF,&HFFFE,&HDFE0,&H3FFF,&HC7FF,&HFFFD,&HBFE0,&H3FFF
    DATA &HDBFF,&HFFFB,&HBFE0,&H3FFF,&HEC7F,&HFFF7,&H7FE0,&H1FFF
    DATA &HF7BF,&HFFCE,&HFFC0,&H1FFF,&HF7C7,&HFE3E,&HFFC0,&H1FFF
    DATA &HFBF8,&H01FD,&HFFC0,&H1FFF,&HFDFF,&HFFFB,&HFFC0,&H0FFF
    DATA &HFDFF,&HFFF7,&HFF80,&H0FFF,&HFE3F,&HFFF7,&HFF80,&H07FF
    DATA &HFFC7,&HFF8F,&HFF00,&H07FF,&HFFF8,&H007F,&HFF00,&H03FF
    DATA &HFFFF,&HFFFF,&HFE00,&H03FF,&HFFFF,&HFFFF,&HFE00,&H01FF
    DATA &HFFFF,&HFFFF,&HFC00,&H00FF,&HFFFF,&HFFFF,&HF800,&H007F
    DATA &HFFFF,&HFFFF,&HF000,&H007F,&HFFFF,&HFFFF,&HF000,&H003F
    DATA &HFFFF,&HFFFF,&HE000,&H001F,&HFFFF,&HFFFF,&HC000,&H0007
    DATA &HFFFF,&HFFFF,&H0000,&H0003,&HFFFF,&HFFFE,&H0000,&H0001
    DATA &HFFFF,&HFFFC,&H0000,&H0000,&H7FFF,&HFFF0,&H0000,&H0000
    DATA &H1FFF,&HFFC0,&H0000,&H0000,&H07FF,&HFF00,&H0000,&H0000
    DATA &H007F,&HF000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0004,&H0000,&H0000,&H0000,&H0002,&H0000,&H0000,&H0000
    DATA &H0002,&H0000,&H0000,&H0000,&H0001,&H0000,&H0000,&H0000
    DATA &H0001,&H0000,&H0000,&H0000,&H0000,&H8000,&H0000,&H0000
    DATA &H0000,&H8000,&H0000,&H0000,&H0000,&H4000,&H0000,&H0000
    DATA &H0000,&H4000,&H0000,&H0000,&H0006,&H2000,&H0000,&H0000
    DATA &H0001,&HA000,&H0000,&H0000,&H0000,&H7000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H4000,&H0000,&H0000,&H0000,&H8000,&H0000
    DATA &H4000,&H0001,&H2000,&H0000,&H3800,&H0002,&H4000,&H0000
    DATA &H2400,&H0004,&H4000,&H0000,&H1380,&H0008,&H8000,&H0000
    DATA &H0840,&H0031,&H0000,&H0000,&H0838,&H01C1,&H0000,&H0000
    DATA &H0407,&HFE02,&H0000,&H0000,&H0200,&H0004,&H0000,&H0000
    DATA &H0200,&H0008,&H0000,&H0000,&H01C0,&H0008,&H0000,&H0000
    DATA &H0038,&H0070,&H0000,&H0000,&H0007,&HFF80,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000

    '  AmigaBASIC, Array Size= 151 Width= 16 Height= 37 Colors= 16
    '  cross16
    cross16:
    DATA &H0010,&H0025,&H0004,&H0180,&H0180,&H0180,&H0180,&H0180
    DATA &H0180,&H0180,&H0180,&H0180,&H0180,&H0180,&H0180,&H0180
    DATA &H0180,&H0180,&H0180,&HFFFF,&HFFFF,&H0180,&H0180,&H0180
    DATA &H0180,&H0180,&H0180,&H0180,&H0180,&H0180,&H0180,&H0180
    DATA &H0180,&H0180,&H0180,&H0180,&H0180,&H0180,&H0180,&H0180
    DATA &H03C0,&H03C0,&H03C0,&H03C0,&H03C0,&H03C0,&H03C0,&H03C0
    DATA &H03C0,&H03C0,&H03C0,&H03C0,&H03C0,&H03C0,&H03C0,&HFFFF
    DATA &HFFFF,&HFFFF,&HFFFF,&H0380,&H0380,&H0380,&H0380,&H0380
    DATA &H0380,&H0380,&H0380,&H0380,&H0380,&H0380,&H0380,&H0380
    DATA &H0380,&H0380,&H0380,&H0380,&H0380,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
    DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000




Feb 23 - 2021
Big milestone today. I managed to figure out the AmigaBasic PUT format. It will now be an export option!
Check out the video https://youtu.be/WCjZ0lyd_EM

Feb 21 - 2021
I have Added Export formats for Turbo\Power Basic, QB64. FreeBASIC, GWBASIC and PC-BASIC, Turbo C and QuickC

Feb 19 - 2021
I have added Freepascal Export menu option. I have tested this under FP Graph unit on GO32V2/Windows using PutImage 
![](https://github.com/nickshardware/raster-master/wiki/images/rmfp.png)

Feb 17 - 2021 later at 5:55pm EST
I have compiled a 32 bit version binary - it can be downloaded in the release secion RM32.EXE or RM32.ZIP

Feb 17 - 2021 later at 2:00pm EST
Turns out because i used Lazarus to port my Turbo Pascal code it compiles without any modifications on ubuntu Linux
![](https://github.com/nickshardware/raster-master/wiki/images/rmlinux.png)

Feb 17 - 2021
I have release version - all code uploaded
![](https://github.com/nickshardware/raster-master/wiki/images/RM.PNG)

Feb 15 - 2021
I have managed to Port 90% of the program features. I also managed to include some features not in the original. There are a few main pieces of code that have hard paths. Cleaning up code so that it can be compiled on other systems. Not cleaning up to make pretty!

Feb 4 - 2021
It turns out i was l little too optimistic - it might take me a little longer than a few days. I've decided to start commiting changes for some of the code. When it is mostly ported i will commit everything.












