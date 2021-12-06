/* eg1.c Raster Master vsprite demo for vbcc                           */
/* vbcc eg1.c -o eg1 -lauto -lamiga                                    */
/* modified code from Robert Peck's book                               */

#include <proto/exec.h>
#include <proto/intuition.h>
#include <intuition/intuition.h>
#include <proto/graphics.h>
#include <graphics/gels.h>

/* Amiga C , Size= 32 Width= 16 Height= 16 Colors= 4 */
/* rename __chip to chip if using SAS compiler. remove __chip if compiler does not support it */
/* VSprite Bitmap */
 WORD __chip img[32]  = {
  0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
  0x0000,0x0000,0x0fe0,0x0000,0x3ff8,0x0fe0,0x6eec,0x1110,
  0x4444,0x3bb8,0x6eec,0x1110,0x3ff8,0x0fe0,0x0fe0,0x0000,
  0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000};

/* Amiga C , Size= 32 Width= 16 Height= 16 Colors= 4 */
/* rename __chip to chip if using SAS compiler. remove __chip if compiler does not support it */
/* VSprite Bitmap */
 WORD __chip crossImage[32]  = {
  0x0180,0x03c0,0x0180,0x03c0,0x0180,0x03c0,0x0180,0x03c0,
  0x0180,0x0240,0x0180,0xfe7f,0xffff,0xf81f,0xffff,0xf81f,
  0x0180,0xfe7f,0x0180,0x0240,0x0180,0x03c0,0x0180,0x03c0,
  0x0180,0x03c0,0x0180,0x03c0,0x0180,0x03c0,0x0180,0x03c0};


/* VSprite Colors */
  WORD imgpal[3] = {
   0x0d7f,
   0x0a32,
   0x0180};

/* VSprite Colors */
  WORD crossImagepal[3] = {
   0x0fff,
   0x0002,
   0x0f80};

struct Screen *my_screen;
struct NewScreen my_new_screen=
{
  0,            /* LeftEdge  Should always be 0. */
  0,            /* TopEdge   Top of the display.*/
  640,          /* Width     We are using a high-resolution screen. */
  200,          /* Height    Non-Interlaced NTSC (American) display. */
  4,            /* Depth     4 colours. */
  0,            /* DetailPen Text should be drawn with colour reg. 0 */
  1,            /* BlockPen  Blocks should be drawn with colour reg. 1 */
  HIRES|SPRITES,/* ViewModes High resolution, sprites will be used. */
  CUSTOMSCREEN, /* Type      Your own customized screen. */
  NULL,         /* Font      Default font. */
  "VSprites!",  /* Title     The screen's title. */
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
  "RM VSprite Demo - Use the arrow keys to move the VSprite!", /* Title */
  NULL,          /* Screen      Will later be connected to a custom scr. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  640,           /* MaxWidth    than 640 x 200. */
  200,           /* MaxHeight */
  CUSTOMSCREEN   /* Type        Connected to the Workbench Screen. */
};

/* Declare a vsprite/GelsInfo structure: */
struct VSprite head, tail, vsprite;
struct GelsInfo ginfo;
BOOL vsprite_on = FALSE;

/* This function frees all allocated memory. */
void clean_up()
{
  /* Remove the VSprites: */
  if (vsprite_on) RemVSprite(&vsprite);
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
  ginfo.nextLine = nextline;
  ginfo.lastColor = lastcolor;

  /* Give the Rastport a pointer to the GelsInfo structure: */
  my_window->RPort->GelsInfo = &ginfo;
  
  /* Give the GelsInfo structure to the system: */
  InitGels( &head, &tail, &ginfo );

  /* Initialize the VSprite structure: */
  vsprite.Flags = VSPRITE; /* It is a VSprite.            */
  vsprite.X = x;           /* X position.                 */
  vsprite.Y = y;           /* Y position.                 */
  vsprite.Height = 16;     /* 16 lines tall.              */
  vsprite.Width = 1;       /* Two bytes (16 pixels) wide. */
  vsprite.Depth = 2;       /* Two bitplanes, 4 colours.   */

  /* Pointer to the sprite data: */
  vsprite.ImageData = crossImage;

  /* Pointer to the colour table: */
  vsprite.SprColors = crossImagepal;

  /*  Add the VSprites to the VSprite list: */
  AddVSprite( &vsprite, my_window->RPort );

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

    vsprite.X = x;
    vsprite.Y = y;

    /* Sort the Gels list: */
    SortGList( my_window->RPort );

    /* Draw the Gels list: */
    DrawGList( my_window->RPort, &(my_screen->ViewPort) );

    /* Set the Copper and redraw the display: */
    MakeScreen( my_screen );
    RethinkDisplay();    
  }

  /* Free all allocated memory: (Close the window, libraries etc) */
  clean_up();
  return 0;
}