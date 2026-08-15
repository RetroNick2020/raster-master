unit rmconst;

{$mode ObjFPC}{$H+}

interface
uses
  Classes, SysUtils;

Const
   NoLan   = 0;
   TPLan   = 1;
   TCLan   = 2;
   QCLan   = 3;
   QBLan   = 4;
   QB64Lan = 5;

   PBLan   = 6;
   GWLan   = 7;    // also update GWLan in gbasic unit
   FPLan   = 8;

   FBinQBModeLan = 9;
   FBLan         = 10;  //modern mode - no legacy support for RGB/RGBA

   ABLan   = 11; //AmigaBasic
   APLan   = 12;
   ACLan   = 13;

   AQBLan  = 14; //Amiga APQBasic support - once we figure out how to access t_BitMap memory and stuff it with bitplane data
   QPLan   = 15; //Quick Pascal
   gccLan  = 16;
   OWLan   = 17; //Open Watcom C/C++ compiler
   BAMLan  = 18; //Basic Anywhere Machine
   TMTLan  = 19; // TMT Pascal Compiler - 32bit DOS
   QBJSLan = 20; // QB to JS transpiler
   JSONLan = 21; //for sprite sheet description


   BasicLan   = 22;
   BasicLNLan = 23;
   CLan       = 24;
   PascalLan  = 25;
   JSLan      = 26;  //JavaScript

   FBBasicLan   = 27;   //fix this in the future - just a hack right now to make things work with freebasic
   QB64BasicLan = 28; //fix this in the future - just a hack right now to make things work with Qb64
   AQBBasicLan  = 29;  //fix this in the future - just a hack right now to make things work with Amiga QuickBasic AQB
   BAMBasicLan  = 30;
   QBJSBasicLan = 31;

   //extended map compiler targets - match sprite editor compiler list
   GWBasicLan     = 32;  //GWBASIC - line numbered DATA
   QBBasicLan     = 33;  //QBasic\QuickBasic
   TBBasicLan     = 34;  //Turbo\Power Basic
   ABBasicLan     = 35;  //AmigaBasic
   FBQBBasicLan   = 36;  //FreeBASIC - QB Mode
   TPPascalLan    = 37;  //Turbo Pascal
   QPPascalLan    = 38;  //Quick Pascal
   FPPascalLan    = 39;  //FreePascal
   TMTPascalLan   = 40;  //TMT Pascal
   APPascalLan    = 41;  //Amiga Pascal
   TCCLan         = 42;  //Turbo C
   QCCLan         = 43;  //Quick C
   OWCLan         = 44;  //Open Watcom C
   GCCCLan        = 45;  //gcc \ Emscripten
   ACCLan         = 46;  //Amiga C

 //  JSONLan        = 26;  //JSON data descriptor


(* old values
BasicLan = 1;
  BasicLNLan = 2;
  CLan     = 3;
  PascalLan= 4;
  FBBasicLan = 5;   //fix this in the future - just a hack right now to make things work with freebasic
  QB64BasicLan = 6; //fix this in the future - just a hack right now to make things work with Qb64
  AQBBasicLan = 7;  //fix this in the future - just a hack right now to make things work with Amiga QuickBasic AQB
  BAMBasicLan = 8;
  QBJSBasicLan = 9;

  //extended map compiler targets - match sprite editor compiler list
  GWBasicLan     = 10;  //GWBASIC - line numbered DATA
  QBBasicLan     = 11;  //QBasic\QuickBasic
  TBBasicLan     = 12;  //Turbo\Power Basic
  ABBasicLan     = 13;  //AmigaBasic
  FBQBBasicLan   = 14;  //FreeBASIC - QB Mode
  TPPascalLan    = 15;  //Turbo Pascal
  QPPascalLan    = 16;  //Quick Pascal
  FPPascalLan    = 17;  //FreePascal
  TMTPascalLan   = 18;  //TMT Pascal
  APPascalLan    = 19;  //Amiga Pascal
  TCCLan         = 20;  //Turbo C
  QCCLan         = 21;  //Quick C
  OWCLan         = 22;  //Open Watcom C
  GCCCLan        = 23;  //gcc \ Emscripten
  ACCLan         = 24;  //Amiga C
  JSLan          = 25;  //JavaScript
//  JSONLan        = 26;  //JSON data descriptor


*)


   NoExportFormat = 0;
   PutImageExportFormat = 1;  //for all compilers the use put/putimage

   AmigaBOBExportFormat = 2;  //Amiga specific formats
   AmigaVSpriteExportFormat = 3;
   AmigaBitMap = 4;  //for Amiga C/Pascal

   XLibLBMExportFormat = 5; //Xlib format for TC/TP
   XLibPBMExportFormat = 6;

   RGBAFuchsiaExportFormat = 7;
   RGBAIndex0ExportFormat = 8;
   RGBExportFormat = 9;

   MouseImageExportFormat = 10;

   RayLibRGBAFuchsiaExportFormat = 11;
   RayLibRGBAIndex0ExportFormat = 12;
   RayLibRGBExportFormat = 13;

   RGBACustomExportFormat = 14;
   RayLibRGBACustomExportFormat = 15;

   Binary2   = 1;
   Binary4   = 2;
   Binary8   = 3;
   Binary16  = 4;
   Binary32  = 5;
   Binary256 = 6;

   Source2   = 7;
   Source4   = 8;
   Source8   = 9;
   Source16  = 10;
   Source32  = 11;
   Source256 = 12;

   SPRBinary = 13;
   SPRSource = 14;

   PPRBinary = 15;
   PPRSource = 16;

   TEGLText  = 17;

   PALSource = 18;



implementation

end.

