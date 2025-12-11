(******************************************************************************)
(* sfxr                                                            ??.??.???? *)
(*                                                                            *)
(* Version     : 1.02                                                         *)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : Sound generator, C-port from drpetter                        *)
(*                                                                            *)
(* License     : See the file license.md, located under:                      *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(* Warranty    : There is no warranty, neither in correctness of the          *)
(*               implementation, nor anything other that could happen         *)
(*               or go wrong, use at your own risk.                           *)
(*                                                                            *)
(* Known Issues: none                                                         *)
(*                                                                            *)
(* History     : 1.02 - Initial version                                       *)
(*                                                                            *)
(******************************************************************************)

(*
 * Original Source from : http://www.drpetter.se/project_sfxr.html
 *)

Unit soundgen;

{$MODE objfpc}{$H+}

Interface

(*
 * In case you downloaded and just want to test the app without ocnfiguring Bass
 * you can switch off usage of bass.
 * Save will still work, but no sound preview.
 *)
{$define .UseBass}

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, usfxr
{$IFDEF UseBass}
  , bass
{$ENDIF}
  ;

Type

  { TSoundGeneratorForm }

  TSoundGeneratorForm = Class(TForm)
    Button1: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    OpenDialog1: TOpenDialog;
    RadioGroup1: TRadioGroup;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    ScrollBar1: TScrollBar;
    ScrollBar10: TScrollBar;
    ScrollBar11: TScrollBar;
    ScrollBar12: TScrollBar;
    ScrollBar13: TScrollBar;
    ScrollBar14: TScrollBar;
    ScrollBar15: TScrollBar;
    ScrollBar16: TScrollBar;
    ScrollBar17: TScrollBar;
    ScrollBar18: TScrollBar;
    ScrollBar19: TScrollBar;
    ScrollBar2: TScrollBar;
    ScrollBar20: TScrollBar;
    ScrollBar21: TScrollBar;
    ScrollBar22: TScrollBar;
    ScrollBar23: TScrollBar;
    ScrollBar3: TScrollBar;
    ScrollBar4: TScrollBar;
    ScrollBar5: TScrollBar;
    ScrollBar6: TScrollBar;
    ScrollBar7: TScrollBar;
    ScrollBar8: TScrollBar;
    ScrollBar9: TScrollBar;
    Procedure Button14Click(Sender: TObject);
    Procedure Button15Click(Sender: TObject);
    Procedure Button16Click(Sender: TObject);
    Procedure Button17Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
    Procedure ComboBox1Change(Sender: TObject);
    Procedure ComboBox2Change(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure RadioGroup1Click(Sender: TObject);
    Procedure ScrollBar1Change(Sender: TObject);
  private
    { private declarations }
{$IFDEF UseBass}
    UseBass: Boolean;
    PreviewStream: HSTREAM;
{$ENDIF}
    SFXR: TSFXR;
    Vars: Array Of Pointer; //Mapper TScrollbar auf sfxr Parameter
    Procedure do_play; // Started das Abspielen, wenn Möglich
    Procedure ReloadLCL; // SFXR -> LCL
    Procedure Link(Const ScrollBar: TScrollBar; Data: Pointer; Bipolar: Boolean); // LCL -> SFXR
  public
    { public declarations }
  End;

Var
  SoundGeneratorForm: TSoundGeneratorForm;

  // Leider klappt es nicht, wenn man via Bass.dll die SynthSample Routine aufruft, deswegen muss hier der Umweg über den Stream gegangen werden.
  m: TMemoryStream;
  mp: int64;
  ms: int64;

Implementation

Uses math;

{$R *.lfm}

{$IFDEF UseBass}

Function GetPreviewData(handle: HSTREAM; buffer: Pointer; length: DWORD; user: Pointer): DWORD;
{$IFDEF Windows} stdcall;
{$ELSE} cdecl;
{$ENDIF}
Var
  i: integer;
  w: Word;
  buf: PWord;
Begin
  buf := buffer;
  w := 32767; // Beruhigt nur den Compiler
  For i := 0 To length Div 2 - 1 Do Begin // Puffergröße ist in Bytes, wir haben aber Word's die sind 2-Byte => also length / 2
    m.Read(w, 2);
    buf^ := w;
    inc(mp, 2);
    inc(buf);
  End;
  result := length;
  If mp >= ms Then Begin
    BASS_ChannelStop(SoundGeneratorForm.PreviewStream);
  End;
End;
{$ENDIF}

{ TSoundGeneratorForm }

Procedure TSoundGeneratorForm.FormCreate(Sender: TObject);
Begin
//  caption := 'sfxr ver. 1.02 by DrPetter, ported by corpsman';
  Randomize;
  SFXR := TSFXR.create;
  Vars := Nil;

  (*
   * !! ACHTUNG !!
   *
   * Die Reihenfolge der Scrollbars muss aufsteigend und zusammenhängend
   * von 1 bis k sein !!
   *)
  // Initialisieren der Scrollbars und verbinden mit der jeweiligen Variable
  Link(ScrollBar1, @sfxr.p_env_attack, false);
  Link(ScrollBar2, @sfxr.p_env_sustain, false);
  Link(ScrollBar3, @sfxr.p_env_punch, false);
  Link(ScrollBar4, @sfxr.p_env_decay, false);

  Link(ScrollBar5, @sfxr.p_base_freq, false);
  Link(ScrollBar6, @sfxr.p_freq_limit, false);
  Link(ScrollBar7, @sfxr.p_freq_ramp, true);
  Link(ScrollBar8, @sfxr.p_freq_dramp, true);

  Link(ScrollBar9, @sfxr.p_vib_strength, false);
  Link(ScrollBar10, @sfxr.p_vib_speed, false);

  Link(ScrollBar11, @sfxr.p_arp_mod, true);
  Link(ScrollBar12, @sfxr.p_arp_speed, false);

  Link(ScrollBar13, @sfxr.p_duty, false);
  Link(ScrollBar14, @sfxr.p_duty_ramp, true);

  Link(ScrollBar15, @sfxr.p_repeat_speed, false);

  Link(ScrollBar16, @sfxr.p_pha_offset, true);
  Link(ScrollBar17, @sfxr.p_pha_ramp, true);

  Link(ScrollBar18, @sfxr.p_lpf_freq, false);
  Link(ScrollBar19, @sfxr.p_lpf_ramp, true);
  Link(ScrollBar20, @sfxr.p_lpf_resonance, false);
  Link(ScrollBar21, @sfxr.p_hpf_freq, false);
  Link(ScrollBar22, @sfxr.p_hpf_ramp, true);
  Link(ScrollBar23, @sfxr.sound_vol, false);

  sfxr.ResetParams;
  ReloadLCL;

{$IFDEF UseBass}
  // Bass Sample : http://www.delphipraxis.net/180321-bass-dll-rauschen-erzeugen-create-noise.html
  // Bass Source : http://www.un4seen.com/
  // Laden der Bass.dll
  UseBass := true;
  If (BASS_GetVersion() Shr 16) <> Bassversion Then Begin
    showmessage('Unable to init the Bass Library ver. :' + BASSVERSIONTEXT);
    UseBass := false;
  End;
  If UseBass And (Not Bass_init(-1, 44100, 0, {$IFDEF Windows}0{$ELSE}Nil{$ENDIF}, Nil)) Then Begin
    showmessage('Unable to init sound device, playsound option will be disabled.');
    Button14.Enabled := false;
    UseBass := false;
  End;
  If UseBass Then Begin
    PreviewStream := BASS_StreamCreate(44100, 1, 0, @GetPreviewData, Nil);
    m := TMemoryStream.create;
  End;
{$ENDIF}
End;

Procedure TSoundGeneratorForm.FormDestroy(Sender: TObject);
Begin
{$IFDEF UseBass}
  If UseBass Then Begin
    BASS_ChannelStop(PreviewStream);
    BASS_StreamFree(PreviewStream);
    Bass_Free;
    m.free;
  End;
{$ENDIF}
  SFXR.free;
  setlength(Vars, 0);
End;

Procedure TSoundGeneratorForm.RadioGroup1Click(Sender: TObject);
Begin
  // Wellenform
  SFXR.wave_type := RadioGroup1.ItemIndex;
End;

Procedure TSoundGeneratorForm.ScrollBar1Change(Sender: TObject);
Var
  p: ^Single;
Begin
  p := vars[TScrollBar(sender).Tag];
  p^ := TScrollBar(sender).Position / 1000;
End;

Procedure TSoundGeneratorForm.ReloadLCL;
Var
  i: Integer;
  s: TScrollBar;
  p: ^Single;
Begin
  RadioGroup1.ItemIndex := SFXR.wave_type;
  For i := 0 To high(Vars) Do Begin
    s := TScrollBar(FindComponent('Scrollbar' + inttostr(i + 1)));
    p := vars[i];
    s.Position := round(p^ * 1000);
  End;
End;

Procedure TSoundGeneratorForm.do_play;
Begin
//{$IFDEF UseBass}
//  If UseBass Then Begin
    Button14.Click;
//  End;
//{$ENDIF}
End;

Procedure TSoundGeneratorForm.Link(Const ScrollBar: TScrollBar; Data: Pointer;
  Bipolar: Boolean);
Begin
  setlength(Vars, high(Vars) + 2);
  vars[high(Vars)] := Data;
  ScrollBar.Tag := high(Vars);
  ScrollBar.Position := 0;
  If Bipolar Then Begin
    ScrollBar.Min := -1000;
  End
  Else Begin
    ScrollBar.Min := 0;
  End;
  ScrollBar.Max := 1000;
  ScrollBar.OnChange := @ScrollBar1Change;
End;

Procedure TSoundGeneratorForm.Button17Click(Sender: TObject);
Begin
  // Export Wave
  If SaveDialog1.Execute Then Begin
    If Not SFXR.ExportWav(SaveDialog1.FileName) Then Begin
      showmessage('Could not export.');
    End;
  End;
End;

Procedure TSoundGeneratorForm.Button14Click(Sender: TObject);
Begin
{$IFDEF UseBass}
  // Play Sound
  If Not UseBass Then Begin
    showmessage('No preview available.');
    exit;
  End;
  // Wir spielen bereits -> abbruch
  If BASS_ChannelIsActive(PreviewStream) <> 0 Then Begin
    BASS_ChannelStop(PreviewStream);
  End;
  // Den Stream als Rohdatenstream empfangen
  m.Clear;
  SFXR.ExportBassStream(m);
  mp := 0;
  ms := m.Size;
  m.Position := 0;
  If Not BASS_ChannelPlay(PreviewStream, true) Then Begin
    showmessage('Could not start stream playback');
  End;
{$ELSE}
//  showmessage('Application was build without use of bass, so no preview available.' + LineEnding +
//    'You have to store the result and play it with your own player of choise.');
//  Sleep(500);
  SFXR.PlaySound;
{$ENDIF}
End;

Procedure TSoundGeneratorForm.Button15Click(Sender: TObject);
Begin
  // Load Settings
  If OpenDialog1.Execute Then Begin
    If Not SFXR.LoadSettings(OpenDialog1.FileName) Then Begin
      showmessage('Error, could not save settings.');
      exit;
    End;
    ReloadLCL;
  End;
End;

Procedure TSoundGeneratorForm.Button16Click(Sender: TObject);
Begin
  // Save Settings
  If SaveDialog2.Execute Then Begin
    If Not SFXR.SaveSettings(SaveDialog2.FileName) Then Begin
      showmessage('Error, could not save settings.');
    End;
  End;
End;

Procedure TSoundGeneratorForm.Button1Click(Sender: TObject);
Begin
  // pickup/coin
  SFXR.ResetParams();
  SFXR.p_base_freq := 0.4 + frnd(0.5);
  SFXR.p_env_attack := 0.0;
  SFXR.p_env_sustain := frnd(0.1);
  SFXR.p_env_decay := 0.1 + frnd(0.4);
  SFXR.p_env_punch := 0.3 + frnd(0.3);
  If (random(100) >= 50) Then Begin
    SFXR.p_arp_speed := 0.5 + frnd(0.2);
    SFXR.p_arp_mod := 0.2 + frnd(0.4);
  End;
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.Button2Click(Sender: TObject);
Begin
  // Laser Shoot
  SFXR.ResetParams();
  SFXR.wave_type := rnd(2);
  If (SFXR.wave_type = 2) And (random(100) >= 50) Then Begin
    SFXR.wave_type := rnd(1);
  End;
  SFXR.p_base_freq := 0.5 + frnd(0.5);
  SFXR.p_freq_limit := SFXR.p_base_freq - 0.2 - frnd(0.6);
  If (SFXR.p_freq_limit < 0.2) Then SFXR.p_freq_limit := 0.2;
  SFXR.p_freq_ramp := -0.15 - frnd(0.2);
  If (rnd(2) = 0) Then Begin
    SFXR.p_base_freq := 0.3 + frnd(0.6);
    SFXR.p_freq_limit := frnd(0.1);
    SFXR.p_freq_ramp := -0.35 - frnd(0.3);
  End;
  If (random(100) >= 50) Then Begin
    SFXR.p_duty := frnd(0.5);
    SFXR.p_duty_ramp := frnd(0.2);
  End
  Else Begin
    SFXR.p_duty := 0.4 + frnd(0.5);
    SFXR.p_duty_ramp := -frnd(0.7);
  End;
  SFXR.p_env_attack := 0.0;
  SFXR.p_env_sustain := 0.1 + frnd(0.2);
  SFXR.p_env_decay := frnd(0.4);
  If (random(100) >= 50) Then SFXR.p_env_punch := frnd(0.3);
  If (rnd(2) = 0) Then Begin
    SFXR.p_pha_offset := frnd(0.2);
    SFXR.p_pha_ramp := -frnd(0.2);
  End;
  If (random(100) >= 50) Then SFXR.p_hpf_freq := frnd(0.3);
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.Button3Click(Sender: TObject);
Begin
  // Explosion
  SFXR.ResetParams();
  SFXR.wave_type := 3;
  If (random(100) >= 50) Then Begin
    SFXR.p_base_freq := 0.1 + frnd(0.4);
    SFXR.p_freq_ramp := -0.1 + frnd(0.4);
  End
  Else Begin
    SFXR.p_base_freq := 0.2 + frnd(0.7);
    SFXR.p_freq_ramp := -0.2 - frnd(0.2);
  End;
  SFXR.p_base_freq := SFXR.p_base_freq * SFXR.p_base_freq;
  If (rnd(4) = 0) Then SFXR.p_freq_ramp := 0.0;
  If (rnd(2) = 0) Then SFXR.p_repeat_speed := 0.3 + frnd(0.5);
  SFXR.p_env_attack := 0.0;
  SFXR.p_env_sustain := 0.1 + frnd(0.3);
  SFXR.p_env_decay := frnd(0.5);
  If (rnd(1) = 0) Then Begin
    SFXR.p_pha_offset := -0.3 + frnd(0.9);
    SFXR.p_pha_ramp := -frnd(0.3);
  End;
  SFXR.p_env_punch := 0.2 + frnd(0.6);
  If (random(100) >= 50) Then Begin
    SFXR.p_vib_strength := frnd(0.7);
    SFXR.p_vib_speed := frnd(0.6);
  End;
  If (rnd(2) = 0) Then Begin
    SFXR.p_arp_speed := 0.6 + frnd(0.3);
    SFXR.p_arp_mod := 0.8 - frnd(1.6);
  End;
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.Button4Click(Sender: TObject);
Begin
  // Power Up
  SFXR.ResetParams();
  If (random(100) >= 50) Then Begin
    SFXR.wave_type := 1;
  End
  Else Begin
    SFXR.p_duty := frnd(0.6);
  End;
  If (random(100) >= 50) Then Begin
    SFXR.p_base_freq := 0.2 + frnd(0.3);
    SFXR.p_freq_ramp := 0.1 + frnd(0.4);
    SFXR.p_repeat_speed := 0.4 + frnd(0.4);
  End
  Else Begin
    SFXR.p_base_freq := 0.2 + frnd(0.3);
    SFXR.p_freq_ramp := 0.05 + frnd(0.2);
    If (random(100) >= 50) Then Begin
      SFXR.p_vib_strength := frnd(0.7);
      SFXR.p_vib_speed := frnd(0.6);
    End;
  End;
  SFXR.p_env_attack := 0.0;
  SFXR.p_env_sustain := frnd(0.4);
  SFXR.p_env_decay := 0.1 + frnd(0.4);
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.Button5Click(Sender: TObject);
Begin
  // Hit
  SFXR.ResetParams();
  SFXR.wave_type := rnd(2);
  If (SFXR.wave_type = 2) Then SFXR.wave_type := 3;
  If (SFXR.wave_type = 0) Then SFXR.p_duty := frnd(0.6);
  SFXR.p_base_freq := 0.2 + frnd(0.6);
  SFXR.p_freq_ramp := -0.3 - frnd(0.4);
  SFXR.p_env_attack := 0.0;
  SFXR.p_env_sustain := frnd(0.1);
  SFXR.p_env_decay := 0.1 + frnd(0.2);
  If (random(100) >= 50) Then SFXR.p_hpf_freq := frnd(0.3);
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.Button6Click(Sender: TObject);
Begin
  // Jump
  SFXR.ResetParams();
  SFXR.wave_type := 0;
  SFXR.p_duty := frnd(0.6);
  SFXR.p_base_freq := 0.3 + frnd(0.3);
  SFXR.p_freq_ramp := 0.1 + frnd(0.2);
  SFXR.p_env_attack := 0.0;
  SFXR.p_env_sustain := 0.1 + frnd(0.3);
  SFXR.p_env_decay := 0.1 + frnd(0.2);
  If (random(100) >= 50) Then SFXR.p_hpf_freq := frnd(0.3);
  If (random(100) >= 50) Then SFXR.p_lpf_freq := 1.0 - frnd(0.6);
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.Button7Click(Sender: TObject);
Begin
  // Blip
  SFXR.ResetParams();
  SFXR.wave_type := rnd(1);
  If (SFXR.wave_type = 0) Then SFXR.p_duty := frnd(0.6);
  SFXR.p_base_freq := 0.2 + frnd(0.4);
  SFXR.p_env_attack := 0.0;
  SFXR.p_env_sustain := 0.1 + frnd(0.1);
  SFXR.p_env_decay := frnd(0.2);
  SFXR.p_hpf_freq := 0.1;
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.Button8Click(Sender: TObject);
Begin
  // Mutate
  If (random(100) >= 50) Then SFXR.p_base_freq := SFXR.p_base_freq + frnd(0.1) - 0.05;
  //If (random(100) >= 50) Then SFXR.p_freq_limit := SFXR.p_freq_limit + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_freq_ramp := SFXR.p_freq_ramp + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_freq_dramp := SFXR.p_freq_dramp + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_duty := SFXR.p_duty + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_duty_ramp := SFXR.p_duty_ramp + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_vib_strength := SFXR.p_vib_strength + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_vib_speed := SFXR.p_vib_speed + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_vib_delay := SFXR.p_vib_delay + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_env_attack := SFXR.p_env_attack + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_env_sustain := SFXR.p_env_sustain + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_env_decay := SFXR.p_env_decay + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_env_punch := SFXR.p_env_punch + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_lpf_resonance := SFXR.p_lpf_resonance + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_lpf_freq := SFXR.p_lpf_freq + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_lpf_ramp := SFXR.p_lpf_ramp + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_hpf_freq := SFXR.p_hpf_freq + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_hpf_ramp := SFXR.p_hpf_ramp + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_pha_offset := SFXR.p_pha_offset + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_pha_ramp := SFXR.p_pha_ramp + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_repeat_speed := SFXR.p_repeat_speed + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_arp_speed := SFXR.p_arp_speed + frnd(0.1) - 0.05;
  If (random(100) >= 50) Then SFXR.p_arp_mod := SFXR.p_arp_mod + frnd(0.1) - 0.05;
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.Button9Click(Sender: TObject);
Begin
  // Randomize
  SFXR.p_base_freq := power(frnd(2.0) - 1.0, 2.0);
  If (random(100) >= 50) Then Begin
    SFXR.p_base_freq := power(frnd(2.0) - 1.0, 3.0) + 0.5;
  End;
  SFXR.p_freq_limit := 0.0;
  SFXR.p_freq_ramp := power(frnd(2.0) - 1.0, 5.0);
  If (SFXR.p_base_freq > 0.7) And (SFXR.p_freq_ramp > 0.2) Then Begin
    SFXR.p_freq_ramp := -SFXR.p_freq_ramp;
  End;
  If (SFXR.p_base_freq < 0.2) And (SFXR.p_freq_ramp < -0.05) Then Begin
    SFXR.p_freq_ramp := -SFXR.p_freq_ramp;
  End;
  SFXR.p_freq_dramp := power(frnd(2.0) - 1.0, 3.0);
  SFXR.p_duty := frnd(2.0) - 1.0;
  SFXR.p_duty_ramp := power(frnd(2.0) - 1.0, 3.0);
  SFXR.p_vib_strength := power(frnd(2.0) - 1.0, 3.0);
  SFXR.p_vib_speed := frnd(2.0) - 1.0;
  SFXR.p_vib_delay := frnd(2.0) - 1.0;
  SFXR.p_env_attack := power(frnd(2.0) - 1.0, 3.0);
  SFXR.p_env_sustain := power(frnd(2.0) - 1.0, 2.0);
  SFXR.p_env_decay := frnd(2.0) - 1.0;
  SFXR.p_env_punch := power(frnd(0.8), 2.0);
  If (SFXR.p_env_attack + SFXR.p_env_sustain + SFXR.p_env_decay < 0.2) Then Begin
    SFXR.p_env_sustain := SFXR.p_env_sustain + 0.2 + frnd(0.3);
    SFXR.p_env_decay := SFXR.p_env_decay + 0.2 + frnd(0.3);
  End;
  SFXR.p_lpf_resonance := frnd(2.0) - 1.0;
  SFXR.p_lpf_freq := 1.0 - power(frnd(1.0), 3.0);
  SFXR.p_lpf_ramp := power(frnd(2.0) - 1.0, 3.0);
  If (SFXR.p_lpf_freq < 0.1) And (SFXR.p_lpf_ramp < -0.05) Then Begin
    SFXR.p_lpf_ramp := -SFXR.p_lpf_ramp;
  End;
  SFXR.p_hpf_freq := power(frnd(1.0), 5.0);
  SFXR.p_hpf_ramp := power(frnd(2.0) - 1.0, 5.0);
  SFXR.p_pha_offset := power(frnd(2.0) - 1.0, 3.0);
  SFXR.p_pha_ramp := power(frnd(2.0) - 1.0, 3.0);
  SFXR.p_repeat_speed := frnd(2.0) - 1.0;
  SFXR.p_arp_speed := frnd(2.0) - 1.0;
  SFXR.p_arp_mod := frnd(2.0) - 1.0;
  ReloadLCL;
  do_play;
End;

Procedure TSoundGeneratorForm.ComboBox1Change(Sender: TObject);
Begin
  Case ComboBox1.ItemIndex Of
    0: SFXR.wav_freq := 44100;
    1: SFXR.wav_freq := 22050;
  End;
End;

Procedure TSoundGeneratorForm.ComboBox2Change(Sender: TObject);
Begin
  Case ComboBox2.ItemIndex Of
    0: SFXR.wav_bits := 16;
    1: SFXR.wav_bits := 8;
  End;
End;

End.

