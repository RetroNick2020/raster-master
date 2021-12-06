/* eg2.c Raster Master DrawImage demo for vbcc                         */
/* vbcc eg2.c -o eg2 -lauto -lamiga                                    */
/* modified code from Robert Peck's book                               */

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>

/* REMEMBER! Image data MUST be put in chip-memory! */
 
/* Amiga C , Size= 64 Width= 32 Height= 32 Colors= 2 */
/* BOB Bitmap */
 WORD __chip img[64] = {
  0x0000,0x0000,0x000f,0xe000,0x003f,0xf800,0x007f,0xfc00,
  0x018f,0x8f00,0x0107,0x0700,0x0307,0x0780,0x0707,0x07c0,
  0x078f,0x8fc0,0x0fff,0xffe0,0x0fff,0xffe0,0x0fff,0xffe0,
  0x0fff,0xffe0,0x0fdf,0xffe0,0x0fdf,0xffe0,0x0fef,0xffe0,
  0x07f7,0xcfc0,0x07f0,0x3fc0,0x03ff,0xff80,0x01ff,0xff00,
  0x01ff,0xff00,0x007f,0xfc00,0x003f,0xf800,0x000f,0xe000,
  0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
  0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
};

/* Amiga C , Size= 32 Width= 16 Height= 16 Colors= 4 */
/* rename __chip to chip if using SAS compiler. remove __chip if compiler does not support it */
/* BOB Bitmap */
 WORD __chip squareimage[32]  = {
  0x0000,0x7ffe,0x7fc6,0x7f82,0x7c02,0x7802,0x7806,0x783e,
  0x7c7e,0x71fe,0x60fe,0x60fe,0x60fe,0x71fe,0x7ffe,0x0000,
  0x0000,0x7ffe,0x63fe,0x41fe,0x407e,0x403e,0x603e,0x783e,
  0x7c7e,0x7ffe,0x7ff6,0x7fe2,0x7ff6,0x7ffe,0x7ffe,0x0000};

/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  40,            /* LeftEdge    x position of the window. */
  20,            /* TopEdge     y positio of the window. */
  300,           /* Width       300 pixels wide. */
  200,            /* Height     200 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "RM DrawImage example",       /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  0,             /* MinWidth    We do not need to care about these */
  0,             /* MinHeight   since we have not supplied the window */
  0,             /* MaxWidth    with a Sizing Gadget. */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};

struct Image my_image =
{
  45, 35,         /* LeftEdge, TopEdge. */
  16,              /* Width, 7 pixels/bitts wide. */
  16,              /* Height, 8 lines high. */
  2,              /* Depth, only one Bitplane. */
  squareimage  ,  /* ImageData, pointer to my_image_data. */
  0x0003,         /* PickPlane, bitplane Zero affects. */
  0x0000,         /* PlaneOnOff, 0's on all other Bitplanes. */
                  /* [The pixels' colour will be either 0000 (blue) or */
                  /* 0001 (white).] */
  NULL            /* NextImage, no more Images. */
};



int main()
{
  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)  OpenLibrary( "intuition.library", 0 );
  if( IntuitionBase == NULL ) return 0; /* Could NOT open the Intuition Library! */

  /* We will now try to open the window: */
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  /* Have we opened the window succesfully? */
  if(my_window == NULL)
  {
    /* Could NOT open the Window! */
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary((struct Library *)IntuitionBase);
    return 0;
  }
 
  /* for compilers that do not support __chip or chip array modifier  */
  /* my_image.ImageData =  (UWORD *) AllocMem(sizeof(img),MEMF_CHIP); */
  /* CopyMem(squareimage, my_image.ImageData,sizeof(squareimage));    */                 
  
  /* Tell Intuition to draw the image:  */
    DrawImage( my_window->RPort, &my_image, 0, 0 );

  /* We have opened the window, and everything seems to be OK. */
  /* Wait for 5 seconds: */
  Delay( 50 * 5 );

  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );

  /* Close the Intuition Library since we have opened it: */
  CloseLibrary((struct Library *)IntuitionBase);
  return 0;  
}
