/* Eg4.c Raster Master Bob and VSprite demo for vbcc                  */
/* vc eg4.c -o eg4 -lauto -lamiga                                      */
/* modified code from Robert Peck's book                               */

#include <proto/exec.h>
#include <proto/intuition.h>
#include <intuition/intuition.h>
#include <proto/graphics.h>
#include <graphics/gels.h>

/* Amiga C , Size= 32 Width= 16 Height= 16 Colors= 4 */
/* rename __chip to chip if using SAS compiler. remove __chip if compiler does not support it */
/* VSprite Bitmap */
 WORD __chip vsimg[32]  = {
  0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
  0x0000,0x0000,0x0fe0,0x0000,0x3ff8,0x0fe0,0x6eec,0x1110,
  0x4444,0x3bb8,0x6eec,0x1110,0x3ff8,0x0fe0,0x0fe0,0x0000,
  0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000};

/* VSprite Colors */
  WORD vspal[3] = {
   0x0d7f,
   0x0a32,
   0x0180};


/* Amiga C , Size= 128 Width= 32 Height= 32 Colors= 4 */
/* rename __chip to chip if using SAS compiler. remove __chip if compiler does not support it */
/* BOB Bitmap */
 WORD __chip img[128]  = {
  0x0080,0x0000,0x0080,0x0000,0x0080,0x07c0,0x0080,0x0fe0,
  0x0080,0x1c70,0x0080,0x3838,0x0080,0x3018,0x0080,0x3018,
  0x0080,0x3018,0x0080,0x3838,0x06b0,0x1c70,0x06b0,0x0fe0,
  0x0eb8,0x07c0,0x1ebc,0x0000,0x1ebc,0x0000,0x1ebc,0x0000,
  0x0000,0x3d78,0x0000,0x3d78,0x0000,0x3d78,0x03e0,0x1d70,
  0x07f0,0x0d60,0x0e38,0x0d60,0x1c1c,0x0100,0x180c,0x0100,
  0x180c,0x0100,0x180c,0x0100,0x1c1c,0x0100,0x0e38,0x0100,
  0x07f0,0x0100,0x03e0,0x0100,0x0000,0x0100,0x0000,0x0100,
  0x0140,0x0000,0x0140,0x0000,0x0140,0x0000,0x0140,0x0000,
  0x0140,0x0380,0x0140,0x07c0,0x0140,0x0fe0,0x0140,0x0fe0,
  0x0140,0x0fe0,0x0140,0x07c0,0x0770,0x0380,0x0770,0x0000,
  0x0f78,0x0000,0x1f7c,0x0000,0x1f7c,0x0000,0x1f7c,0x0000,
  0x0000,0x3ef8,0x0000,0x3ef8,0x0000,0x3ef8,0x0000,0x1ef0,
  0x0000,0x0ee0,0x01c0,0x0ee0,0x03e0,0x0280,0x07f0,0x0280,
  0x07f0,0x0280,0x07f0,0x0280,0x03e0,0x0280,0x01c0,0x0280,
  0x0000,0x0280,0x0000,0x0280,0x0000,0x0280,0x0000,0x0280};


struct Screen *my_screen;
struct NewScreen my_new_screen=
{
  0,            /* LeftEdge  Should always be 0. */
  0,            /* TopEdge   Top of the display.*/
  640,          /* Width     We are using a high-resolution screen. */
  200,          /* Height    Non-Interlaced NTSC (American) display. */
  2,            /* Depth     4 colours. */
  0,            /* DetailPen Text should be drawn with colour reg. 0 */
  1,            /* BlockPen  Blocks should be drawn with colour reg. 1 */
  HIRES|SPRITES,/* ViewModes High resolution, sprites will be used. */
  CUSTOMSCREEN, /* Type      Your own customized screen. */
  NULL,         /* Font      Default font. */
  "Bob and VSprite!",  /* Title     The screen's title. */
  NULL,         /* Gadget    Must for the moment be NULL. */
  NULL          /* BitMap    No special CustomBitMap. */
};

struct Window *my_window = NULL;
struct NewWindow my_new_window=
{
  0,             /* LeftEdge    x position of the window. */
  0,             /* TopEdge     y positio of the window. */
  640,           /* Width       640 pixels wide. */
  200,           /* Height      200 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  CLOSEWINDOW|   /* IDCMPFlags  The window will give us a message if the */
  RAWKEY,        /*             user has selected the Close window gad, */
                 /*             or if the user has pressed a key. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "RM Bob and VSprite Demo - Use the arrow keys to move the shapes!", /* Title */
  NULL,          /* Screen      Will later be connected to a custom scr. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  640,           /* MaxWidth    than 640 x 200. */
  200,           /* MaxHeight */
  CUSTOMSCREEN   /* Type        Connected to the Workbench Screen. */
};

/* Declare a vsprite/GelsInfo structure: */
struct VSprite head, tail, my_vsprite, my_vsprite2;
struct GelsInfo ginfo;

struct Bob my_bob;
WORD  __chip Cmask[2*32]; /* 2 words wide* 32; 32x32 pixels */
WORD  __chip Bline[2];    /* 2 words wide  */
                          /* CMask and Bline must be changed to reflect different bob size*/

WORD  __chip VCmask[1*16]; /* 1 words wide* 16; 16x16 pixels */
WORD  __chip VBline[1];    /* 1 words wide  */

BOOL bob_on = FALSE;
BOOL vsprite_on = FALSE;


/* This function frees all allocated memory. */
void clean_up()
{
  /* Remove the Bob */
  if (bob_on) RemBob(&my_bob);
  if (my_bob.SaveBuffer != NULL) FreeMem(my_bob.SaveBuffer,sizeof(img));
  
  /* Remove the VSprite */
  if (vsprite_on) RemVSprite(&my_vsprite2);
  
  if (my_window) CloseWindow(my_window);
  if (my_screen) CloseScreen(my_screen);
  if (GfxBase) CloseLibrary((struct Library *)GfxBase);
  if (IntuitionBase) CloseLibrary((struct Library *)IntuitionBase);
}

int main()
{
  /* The GelsInfo structure needs the following arrays: */
  WORD nextline[8];
  WORD *lastcolor[8];
  
  /* Sprite position: */
  WORD x = 40;
  WORD y = 40;

  /* Direction of the sprite: */
  WORD x_direction = 0;
  WORD y_direction = 0;

  /* Boolean variable used for the while loop: */
  BOOL close_me = FALSE;

  ULONG class; /* IDCMP */
  USHORT code; /* Code */

  /* Declare a pointer to an IntuiMessage structure: */
  struct IntuiMessage *my_message;

  /* Open the Intuition Library: */
   IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 0 );
   if( IntuitionBase == NULL ) clean_up(); /* Could NOT open the Intuition Library! */

  /* Since we are using sprites we need to open the Graphics Library: */
  /* Open the Graphics Library: */
  GfxBase = (struct GfxBase *) OpenLibrary( "graphics.library", 0);
  if( GfxBase == NULL ) clean_up(); /* Could NOT open the Graphics Library! */

  /* We will now try to open the screen: */
  my_screen = (struct Screen *) OpenScreen( &my_new_screen );

  /* Have we opened the screen succesfully? */
  if(my_screen == NULL) clean_up();

  my_new_window.Screen = my_screen;

  /* We will now try to open the window: */
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  /* Have we opened the window succesfully? */
  if(my_window == NULL) clean_up(); /* Could NOT open the Window! */

  /* Initialize the GelsInfo structure: */
  /* All sprites except the first two may be used to draw */
  /* the VSprites: ( 11111100 = 0xFC )                    */
  ginfo.sprRsrvd = 0xFC;
  /* If we do not exclude the first two sprites, the mouse */
  /* pointer's colours may be affected.                    */

  /* Give the GelsInfo structure some memory: */
  ginfo.nextLine = nextline;    // used for vsprites - can be null if only using bobs
  ginfo.lastColor = lastcolor;  //used for vsprites

  /* Give the Rastport a pointer to the GelsInfo structure: */
  my_window->RPort->GelsInfo = &ginfo;
  
  /* Give the GelsInfo structure to the system: */
  InitGels( &head, &tail, &ginfo );

  /* Initialize the VSprite structure: */
  my_vsprite.Flags =  SAVEBACK | OVERLAY; /* It is a BOB.            */
  my_vsprite.X = x;           /* X position.                 */
  my_vsprite.Y = y;           /* Y position.                 */
  my_vsprite.Height = 32;     /* 16 lines tall.              */
  my_vsprite.Width = 2;       /* Two bytes (16 pixels) wide. */
  my_vsprite.Depth = 2;       /* Two bitplanes, 4 colours.   */
  my_vsprite.PlanePick =3;
  my_vsprite.PlaneOnOff =0;

  /* Pointer to the bob data: */
  my_vsprite.ImageData = img;
  my_vsprite.VSBob = &my_bob;
  my_vsprite.BorderLine = Bline;
  my_vsprite.CollMask = Cmask;

  /* Pointer to the colour table: */
  my_vsprite.SprColors = NULL;

  my_bob.Flags = 0;
  my_bob.SaveBuffer = (WORD *)AllocMem(sizeof(img), MEMF_CHIP);
  my_bob.ImageShadow = Cmask;
  my_bob.Before = NULL;
  my_bob.After = NULL;
  my_bob.BobVSprite = &my_vsprite;
  my_bob.BobComp = NULL;  
  my_bob.DBuffer = NULL;
  my_bob.BUserExt =0;

  InitMasks(&my_vsprite);
  /*  Add the Bob to the Bob list: */
  AddBob(&my_bob, my_window->RPort );

  /* The Bob is in the list. */
  bob_on = TRUE;

/* Initialize the VSprite structure for my_vsprite2 */
  my_vsprite2.Flags = VSPRITE; /* It is a VSprite             */
  my_vsprite2.X = x+50;        /* X position.                 */
  my_vsprite2.Y = y;           /* Y position.                 */
  my_vsprite2.Height = 16;     /* 16 lines tall.              */
  my_vsprite2.Width = 1;       /* Two bytes (16 pixels) wide. */
  my_vsprite2.Depth = 2;       /* Two bitplanes, 4 colours.   */
  
  /* Pointer to the bob data: */
  my_vsprite2.ImageData = vsimg;
  my_vsprite2.BorderLine = VBline;
  my_vsprite2.CollMask = VCmask;

  /* Pointer to the colour table: */
  my_vsprite2.SprColors = vspal;

  InitMasks(&my_vsprite2);
  AddVSprite(&my_vsprite2,my_window->RPort );

/* The VSprite is in the list. */
  vsprite_on = TRUE;

  /* Stay in the while loop until the user has selected the Close window */
  /* gadget: */
  while( close_me == FALSE )
  {
    /* Stay in the while loop as long as we can collect messages */
    /* sucessfully: */
    while(my_message = (struct IntuiMessage *) GetMsg(my_window->UserPort))
    {
      /* After we have collected the message we can read it, and save any */
      /* important values which we maybe want to check later: */
      class = my_message->Class;
      code  = my_message->Code;

      /* After we have read it we reply as fast as possible: */
      /* REMEMBER! Do never try to read a message after you have replied! */
      /* Some other process has maybe changed it. */
      ReplyMsg((struct Message *) my_message );

      /* Check which IDCMP flag was sent: */
      switch( class )
      {
        case CLOSEWINDOW:     /* Quit! */
               close_me=TRUE;
               break;  

        case RAWKEY:          /* A key was pressed! */
               /* Check which key was pressed: */
               switch( code )
               {
                 /* Up Arrow: */
                 case 0x4C:      y_direction = -1; break; /* Pressed */
                 case 0x4C+0x80: y_direction = 0;  break; /* Released */
                 /* Down Arrow: */
                 case 0x4D:      y_direction = 1; break; /* Pressed */
                 case 0x4D+0x80: y_direction = 0; break; /* Released */
                 /* Right Arrow: */
                 case 0x4E:      x_direction = 2; break; /* Pressed */
                 case 0x4E + 0x80: x_direction = 0; break; /* Released */
                 /* Left Arrow: */
                 case 0x4F:      x_direction = -2; break; /* Pressed */
                 case 0x4F+0x80: x_direction = 0;  break; /* Released */
               }
               break;  
      }
    }

    /* Play around with the VSprite: */
    /* Change the x/y position: */
    x += x_direction;
    y += y_direction;

    /* Check that the sprite does not move outside the screen: */
    if (x > 640) x = 640;
    if (x < 0) x = 0;
    if (y > 200) y = 200;
    if (y < 0) y = 0;

    my_vsprite.X = x;
    my_vsprite.Y = y;

    my_vsprite2.X = x+50;
    my_vsprite2.Y = y;

    /* Sort the Gels list: */
    SortGList( my_window->RPort );

    /* Draw the Gels list: */
    DrawGList( my_window->RPort, &(my_screen->ViewPort) );
   
   /* Set the Copper and redraw the display: */
    MakeScreen( my_screen );
    RethinkDisplay();   
   
    /* Try commenting this command out to see if it makes a difference */
    WaitTOF();
  }

  /* Free all allocated memory: (Close the window, libraries etc) */
  clean_up();
  return 0;
}