unit animbase;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

Const
  MaxFrameList = 100;
  MaxAnimationList = 100;

Type
  FrameRec = Packed Record
                 ImageIndex : integer;
                 UID        : TGUID;
                 Tagged     : Boolean;
  end;

  FrameList = array[0..MaxFrameList-1] of FrameRec;
  FrameListRec = Packed Record
                   FrameCount : integer;
                   Frames     : FrameList;
                   Tagged     : Boolean;
  end;

  AnimationListRec = Packed Record
                     AnimCount : integer;
                     CurrentAnimation : integer;
                     AnimationList : array[0..MaxAnimationList-1] of FrameListRec;
  end;

  AnimClipBoardRec = Record
                     SourceImage : integer;
                     UID         : TGUID;
                     ClipBoardStatus : boolean;
  end;

TAnimateBase = Class
                 Animations : AnimationListRec;
                 AnimClipBoard : AnimClipBoardRec;

                 constructor Create;
                 function GetUID(FrameIndex : integer) : TGUID;
                 function FindUID(uid : TGUID) : integer;

                 procedure AddAnimation;
                 procedure DeleteAnimation(AnimationIndex : integer);

                 procedure InitAnimation;
                 function GetAnimationCount : integer;
                 function GetFrameCount : integer;
                 function GetImageIndex(FrameIndex : integer) : integer;
                 function GetImageIndex(AnimationIndex,FrameIndex : integer) : integer;

                 procedure AddFrame(ImageIndex : integer;uid : TGUID);
                 procedure InsertFrame(FrameIndex,ImageIndex : integer;uid : TGUID);
                 procedure ChangeFrame(FrameIndex,ImageIndex : integer;uid : TGUID);

                 procedure MoveFrame(FromFrameIndex,ToFrameIndex : integer);
                 procedure DeleteFrame(FrameIndex : integer);

                 procedure SetFrameTag(FrameIndex : integer;TagState : Boolean);
                 function GetFrameTag(FrameIndex : integer) : Boolean;
                 function GetFirstFrameTag : integer;
                 procedure ClearFrameTags;

                 procedure SetCurrentAnimation(AnimationIndex : integer);
                 function GetCurrentAnimation : integer;

                 procedure InitClipBoard;
                 procedure CopyToClipBoard(ImageIndex : integer; uid : TGUID);
                 procedure PasteFromClipBoard(var ImageIndex : integer;var uid : TGUID);
                 Function GetClipBoardStatus : boolean;

                 procedure Save(filename : string);
                 procedure Open(filename : string);
end;

var
 AnimateBase  : TAnimateBase;

implementation

constructor TAnimateBase.Create;
begin
 InitClipBoard;
 InitAnimation;
 AddAnimation;
end;

procedure TAnimateBase.InitAnimation;
begin
 Animations.Animcount:=0;
 Animations.CurrentAnimation:=0;   //zero is the first index item
 Animations.AnimationList[Animations.CurrentAnimation].FrameCount:=0;
end;

procedure TAnimateBase.InitClipBoard;
begin
  AnimClipBoard.ClipBoardStatus:=False;
end;

Function TAnimateBase.GetClipBoardStatus : boolean;
begin
  result:=AnimClipBoard.ClipBoardStatus;
end;

procedure TAnimateBase.CopyToClipBoard(ImageIndex : integer; uid : TGUID);
begin
 AnimClipBoard.ClipBoardStatus:=True;
 AnimClipBoard.SourceImage:=ImageIndex;
 AnimClipBoard.UID:=uid;
end;

procedure TAnimateBase.PasteFromClipBoard(var ImageIndex : integer;var uid : TGUID);
begin
 ImageIndex:=AnimClipBoard.SourceImage;
 uid:=AnimClipBoard.UID;
end;

procedure TAnimateBase.AddAnimation;
begin
 if Animations.AnimCount < MaxAnimationList then
 begin
   inc(Animations.AnimCount);
   Animations.AnimationList[Animations.AnimCount].FrameCount:=0;
 end;
end;

procedure TAnimateBase.DeleteAnimation(AnimationIndex : integer);
var
 i : integer;
begin
 if Animations.AnimCount > 1 then
 begin
    for i:=AnimationIndex to Animations.AnimCount-1 do
    begin
      Animations.AnimationList[i]:=Animations.AnimationList[i+1];
    end;
    dec(Animations.AnimCount);
 end
 else if Animations.AnimCount = 1 then
 begin
   InitAnimation;
   AddAnimation;
 end;
end;

procedure TAnimateBase.SetCurrentAnimation(AnimationIndex : integer);
begin
 Animations.CurrentAnimation:=AnimationIndex;
end;

function TAnimateBase.GetCurrentAnimation : integer;
begin
 result:=Animations.CurrentAnimation;
end;



procedure TAnimateBase.SetFrameTag(FrameIndex : integer;TagState : Boolean);
begin
  Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].Tagged:=TagState;
end;

function TAnimateBase.GetFrameTag(FrameIndex : integer) : Boolean;
begin
  result:=Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].Tagged;
end;

function TAnimateBase.GetFirstFrameTag : integer;
var
 i : integer;
begin
 for i:=0 to Animations.AnimationList[Animations.CurrentAnimation].FrameCount-1 do
 begin
    if Animations.AnimationList[Animations.CurrentAnimation].Frames[i].Tagged then
    begin
      result:=i;
      exit;
    end;
 end;
end;

procedure TAnimateBase.ClearFrameTags;
var
 i : integer;
begin
 for i:=0 to Animations.AnimationList[Animations.CurrentAnimation].FrameCount-1 do
 begin
   Animations.AnimationList[Animations.CurrentAnimation].Frames[i].Tagged:=False;
 end;
end;

function TAnimateBase.GetUID(FrameIndex : integer) : TGUID;
begin
  GetUID:=Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].UID;
end;

function TAnimateBase.GetAnimationCount : integer;
begin
  result:=Animations.AnimCount;
end;

function TAnimateBase.GetFrameCount : integer;
begin
  result:=Animations.AnimationList[Animations.CurrentAnimation].FrameCount;
end;

function TAnimateBase.GetImageIndex(FrameIndex : integer) : integer;
begin
  result:=Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].ImageIndex;
end;

function TAnimateBase.GetImageIndex(AnimationIndex,FrameIndex : integer) : integer;
begin
  if Animations.AnimationList[AnimationIndex].FrameCount = 0 then  result:=-1
  else
   result:=Animations.AnimationList[AnimationIndex].Frames[FrameIndex].ImageIndex;
end;


function TAnimateBase.FindUID(uid : TGUID) : integer;
var
 i : integer;
begin
 FindUID:=-1;
 for i:=0 to Animations.AnimationList[Animations.CurrentAnimation].FrameCount -1 do
 begin
   if IsEqualGUID(uid,Animations.AnimationList[Animations.CurrentAnimation].Frames[i].UID) then
   begin
      FindUID:=i;
      exit;
   end;
 end;
end;

procedure TAnimateBase.AddFrame(ImageIndex : integer;uid : TGUID);
var
 FrameCount : integer;
begin
  if Animations.AnimationList[Animations.CurrentAnimation].FrameCount < MaxFrameList then
  begin
     inc(Animations.AnimationList[Animations.CurrentAnimation].FrameCount);
     FrameCount:=Animations.AnimationList[Animations.CurrentAnimation].FrameCount;

     Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameCount-1].ImageIndex:=ImageIndex;
     Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameCount-1].UID:=uid;
     Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameCount-1].Tagged:=False;
  end;
end;

procedure TAnimateBase.InsertFrame(FrameIndex,ImageIndex : integer;uid : TGUID);
var
 i : integer;
 FrameCount : integer;
 begin
  if Animations.AnimationList[Animations.CurrentAnimation].FrameCount < MaxFrameList then
  begin
     inc(Animations.AnimationList[Animations.CurrentAnimation].FrameCount);
     FrameCount:=Animations.AnimationList[Animations.CurrentAnimation].FrameCount;

     for i:=FrameCount downto FrameIndex+1 do
     begin
       Animations.AnimationList[Animations.CurrentAnimation].Frames[i]:=Animations.AnimationList[Animations.CurrentAnimation].Frames[i-1];
     end;

     Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].ImageIndex:=ImageIndex;
     Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].uid:=uid;
     Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].Tagged:=False;
  end;
end;

procedure TAnimateBase.ChangeFrame(FrameIndex,ImageIndex : integer;uid : TGUID);
begin
  Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].ImageIndex:=ImageIndex;
  Animations.AnimationList[Animations.CurrentAnimation].Frames[FrameIndex].UID:=uid;
end;

procedure TAnimateBase.MoveFrame(FromFrameIndex,ToFrameIndex : integer);
begin
  ClearFrameTags;
  SetFrameTag(FromFrameIndex,True);
  InsertFrame(ToFrameIndex,GetImageIndex(FromFrameIndex),GetUID(FromFrameIndex));
//  Animations[CurrentAnimation].Frames[ToFrameIndex]:=Animations[CurrentAnimation].Frames[ToFrameIndex];
  DeleteFrame(GetFirstFrameTag);
end;

procedure TAnimateBase.DeleteFrame(FrameIndex : integer);
var
 i : integer;
begin
 if Animations.AnimationList[Animations.CurrentAnimation].FrameCount > 0 then
 begin
    for i:=FrameIndex to Animations.AnimationList[Animations.CurrentAnimation].FrameCount-1 do
    begin
      Animations.AnimationList[Animations.CurrentAnimation].Frames[i]:=Animations.AnimationList[Animations.CurrentAnimation].Frames[i+1];
    end;
    dec(Animations.AnimationList[Animations.CurrentAnimation].FrameCount);
 end;
end;

procedure TAnimateBase.Save(filename : string);
var
 F : file;
 i : integer;
begin
 Assign(f,filename);
 Rewrite(f,1);
 Blockwrite(f,Animations.AnimCount,sizeof(Animations.AnimCount));
 Blockwrite(f,Animations.CurrentAnimation,sizeof(Animations.CurrentAnimation));

 for i:=0 to Animations.AnimCount-1 do
 begin
   Blockwrite(f,Animations.AnimationList[i],sizeof(Animations.AnimationList[i]));
 end;
 close(f);
end;

procedure TAnimateBase.Open(filename : string);
var
 F : file;
 i : integer;
begin
 Assign(f,filename);
 Reset(f,1);
 Blockread(f,Animations.AnimCount,sizeof(Animations.AnimCount));
 Blockread(f,Animations.CurrentAnimation,sizeof(Animations.CurrentAnimation));

 for i:=0 to Animations.AnimCount-1 do
 begin
   Blockread(f,Animations.AnimationList[i],sizeof(Animations.AnimationList[i]));
 end;
 close(f);
end;


begin
  AnimateBase := TAnimateBase.Create;
end.

