# raster-master
Sprite editor for QuickBasic\C Turbo Pascal\C

30 years ago i wrote a small uility in Turbo Pascal (DOS) that would allow me to create simple sprites/icons and generate code. I have always wanted to do a port of this utility to Windows and provide some updates. I may be the slowest programmer in the world but i have managed to get the hard parts completed. I am working on touching up the user interface. In a few days there should be something here.

Feb 4 - 2021
It turns out i was l little too optimistic - it might take me a little longer than a few days. I've decided to start commiting changes for some of the code. When it is mostly ported i will commit everything.

Feb 15 - 2021
I have managed to Port 90% of the program features. I also managed to include some features not in the original. There are a few main pieces of code that have hard paths. Cleaning up code so that it can be compiled on other systems. Not cleaning up to make pretty!

Feb 17 - 2021
I have release version - all code uploaded
![](https://github.com/nickshardware/raster-master/wiki/images/RM.PNG)

Feb 17 - 2021 later at 2:00pm EST
Turns out because i used Lazarus to port my Turbo Pascal code it compiles without any modifications on ubuntu Linux
![](https://github.com/nickshardware/raster-master/wiki/images/rmlinux.png)

Feb 17 - 2021 later at 5:55pm EST
I have compiled a 32 bit version binary - it can be downloaded in the release secion RM32.EXE or RM32.ZIP

Feb 19 - 2021
I have added Freepascal Export menu option. I have tested this under FP Graph unit on GO32V2/Windows using PutImage 
![](https://github.com/nickshardware/raster-master/wiki/images/rmfp.png)

Feb 21 - 2021
I have Added Export formats for Turbo\Power Basic, QB64. FreeBASIC, GWBASIC and PC-BASIC, Turbo C and QuickC
