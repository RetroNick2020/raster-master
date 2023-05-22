# raster-master
Raster Master Sprite/Icon/Map editor for Windows 10/11 (64 bit) that generates RayLib code / putimage and map code for  Open Watcom, gcc, AmigaBASIC, Amiga C, Amiga Pascal ,QuickBasic, QB64, Quick C, Turbo Pascal, freepascal, Turbo C, Turbo Basic, Power Basic, FreeBASIC, GWBASIC, BASICA, and PC-BASIC. 

For DOS programming in VGA modex I have added support for DOS XLIB library LBM/PBM formats. Javascript putimagedata was added to the export options just because is so popular these days. My interest in Amiga coding also expanded to incluse Pascal and C instead of Just AmigaBASIC. I have added support for Hisoft and freepascal 68k and well as vbcc. 

![](https://github.com/nickshardware/raster-master/wiki/images/rm55.png)  
![](https://github.com/nickshardware/raster-master/wiki/images/rm55_2.png)  
![](https://github.com/nickshardware/raster-master/wiki/images/rm55_3.png) 

Why did this program return from the dead?
30 years ago i wrote a small uility in Turbo Pascal (DOS) that would allow me to create simple sprites/icons and generate code. I have always wanted to do a port of this utility to Windows and provide some updates. I may be the slowest programmer in the world but i have managed to get the hard parts completed. I will continue to work on this and even though i have managed to get most of the features from the original DOS version I did not get everything. Here is a list of things I did not get to yet or plan on supporting.

1. Fastgraph Support - At the time i wrote the original DOS version of Raster Master i was really interested in using fastgraph to create some sort of game. I purchased a copy and started playing around with making little demos. I was using Deluxe Paint along with Raster Master to create graphics and decided to add PPR and SPR. These are single pixel run and packed pixel run. Even though they are in the codebase There are not options in Raster Master to export to these formats. I am not sure how active this product is anymore and if anyone is using it.

2.  TEGL Support - The DEF format was supported in the original DOS version. I planned on using TEGL for creating graphical DOS programs but MS Windows was starting to become popular and graphical DOS programs were not getting much traction. I remember word perfect for DOS supporting a new GUI. I was amazed at the GUI they created in DOS - but it ran really slow compared to their Text versions.  And back to TEGL, I recently found a copy of my Turbo Pascal registered copy and I managed to compile the source and recreate the TPU's. I may the only person with a copy of this. I am not sure what to do with this. I would like to share it but I am not sure of how legal this is. I tried searching for Richard Tom who is the original author behind the TEGL products but no luck. Richard if you are out there and managed to google yourself and found this please contact me.

3. Mouse Shape export options - these eventually will come back. I did write some code to convert the output for 4 color (cga) format to mouse shape for Turbo Pascal and QuickBASIC. Check in the Channel Code repository.

4. Custom Format - The original DOS version allowed you to write small program that can be executed when saving/loading. Raster Master would create a simple RAW format for the data and your program would convert the RAW data to what ever format you coded for. I am not sure if anyone really used this but I decided not to implement this because of security reasons. Windows is becoming more and more restrictive on what you can do with your apps. This might be somthing i can waste alot of time that might not be garanteed to work in the future. I have added a RAW format for simple exports but nothing gets executed - it's just a RAW format you can do something with. I plan on adding scripting support as a way to solve this problem and also allow you to add features without having to learn how the entire program works.

5. Others - I will probably add support for XLIB sprites and other formats I may become interested in the future. Please let me know if there is something you are interested in.


What's happened lately?

Feb 13 - 2022 - We are at R35 currently. I have added PNG support and copy/paste palette options as well as fix some bugs in the most recent releases. There are probably not going to be any new releases for a few weeks. I am currently in the process of creating the map editor. Every feature now takes longer to create as i need to integrate with everything else. All the images now need to be accessible from the map editor and export format need to include the new map information. It's just going to be alot of work. Once the map editor portion is completed it will allow for the creation of simple 2D rpg and puzzle games really quickly. Raster Master will simplifiy the following tasts.

1. Image Editing - Even though the amount of drawing tools in Raster Master is small,  I don't expect anyone to be only using my program to create/edit their images. I have made sure you can get the best results from copying and pasting images from other programs as well as importing PNG files. More importing features will follow. I think i can do full sprite sheet importing and take every image and place it in own thumnail view.

2. Map Editing - There are great number of tools for Map editing, the only problem is that they don't work well with DOS languages. I have spent a good a amount of time looking at using Tiled.  I haven't been able to come up with a good solution that allows the data to be made easily useable in GWBASIC/QBASIC/QB64, Pascal, and C. You can export in all kinds of formats and even your own format. The main problem for me that it's reached a point that is too complex to integrate into DOS programming languages. i can probably do a CSV import but I would need to set bunch of limitations of what features can be used in Tiled and that just seems wrong.

The most reasonable solution is just to add a Map Editor. It will export data to all languages that are currently supported in Raster
Master. The Map editor work in a similar way as currently displaying images. I will relaease code that will just allow you to call simple routune/function/procedure. I am thinking something like

DrawMap(MapData,x,y,HTileStart,VTileStart,HTiles, VTiles)
-MapData will be an array to the map data
-x,y pixel co-rodinates of where to start drawing tiles
-HTileStart/VTileStart - MapData array starting index. which rows and columns of tiles we will draw. we will be able to scrolling by just chnging the start paremters
-HTiles/VTiles - the number columns and rows of tiles to draw

3. Exporting / Packaging  - This is a really hard problem to solve but i think i have managed to reach my goal. My number one requirement was that all data should be in your source code or can be easily linked to your exe file. This is currently true with the RES Export options and will remain true with the Map data.

4. Sound - this is something I have very little knowledge but I hope to add something like sfxr into Raster Master just like the map Editor. I put this as the end of my list because I won't get to this for a long time.

That's it for now - hit me up with a comment or an email. Sometimes it just feels good to know that there are real users instead of the  downloads/clone stats github shows me.



Jan 8 - 2022 - R25/R26 brings big features like saving all you images to a project file. This file is portable and is not just a directory on your hard drive. you can copy the project to another computer or share it with someone else to make edit changes.
The RES Export option for Text and Binary are completed for Turbo Pascal. I chose Turbo Pascal mainly for the testing options. All 
other compiler/targets will follow. 

The RES text export just like the Export to Array options but with all you images in one text file that can be included. this saves lots of time when working with multiple files. The RES binary allows you to do the same thing except with more options on how to utilize in your own programs. You can read the contents the RES file on demand saving on runtime memory. 

You can also attach the RES file to your EXE. With turbo pascal you can use the Binobj utility to link your RES file to your exe - see video https://youtu.be/_0k_uOKYMPU  There is also another way of attaching your RES to your exe with the DOS copy command and using some turbo pascal function to find your RES data. This gives the options on loading images on demand and also saving on memory because even though the images are attached to the EXE they are not actually loaded in DOS memory.

Jun 9 - 2021 - New Binary release Raster Master v1.0 beta R13 - Lots of new features since Apr 23 R9 Release. Fixed width sprites 8x8,16x16,32x32,64x64,128x128, and 256x256.
Multiple images can now be edited with a filmstrip icon view. The color match algorythm now is able match a greater range of colors to the 16/256 color palette in use. this is used when copying/pasting from external apps like ms paint.

Apr 23 - 2021 - New Binary release Raster Master v1.0 beta R9 - new oval/ellipse tools - new AmigaBASIC export formats for Bobs and VSprites

Mar 12 - 2021 - New Binary release Raster Master v1.0 beta R6 - copy/paste, palette open/save, xgf export format for all, palette export

Mar 1 - 2021 - New Binary release Raster Master v1.0 Beta R4

Feb 25 - 2021 -I forgot to post video for QuickBasic\QB64 https://youtu.be/rZPc7VJhbeE

Feb 25 - 2021 -I also figured out the AmigaBasic Bob and sprite formats also. Check out the video.
https://youtu.be/OGh5yVsTEcA   Note: Jan 8 - 2022 - I have removed the code from this section but please find lots of AmigaBASIC code in the Channel Code repository.

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












