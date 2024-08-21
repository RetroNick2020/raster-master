(******************************************************************************)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* This file is part of sfxr                                                  *)
(*                                                                            *)
(*  See the file license.md, located under:                                   *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(******************************************************************************)
Unit usfxr;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils;

Type

  PFloat = ^Single;

  { TSFXR }

  TSFXR = Class
  private
    file_sampleswritten: integer;
    filesample: Single;
    fileacc: integer;
    playing_sample: Boolean;

    mute_stream: Boolean;

    master_vol: Single;

    phase: integer;
    fperiod: double;
    fmaxperiod: double;
    fslide: double;
    fdslide: double;
    period: integer;
    square_duty: Single;
    square_slide: Single;
    env_stage: integer;
    env_time: integer;
    env_length: Array[0..2] Of integer;
    env_vol: Single;
    fphase: Single;
    fdphase: Single;
    iphase: integer;
    phaser_buffer: Array[0..1023] Of Single;
    ipp: integer;
    noise_buffer: Array[0..31] Of Single;
    fltp: Single;
    fltdp: Single;
    fltw: Single;
    fltw_d: Single;
    fltdmp: Single;
    fltphp: Single;
    flthp: Single;
    flthp_d: Single;
    vib_phase: Single;
    vib_speed: Single;
    vib_amp: Single;
    rep_time: integer;
    rep_limit: integer;
    arp_time: integer;
    arp_limit: integer;
    arp_mod: double;
    (*
     * Buffer wird als 44100, 16-Bit Puffer beschrieben => Genau Richtig für Bass.dll
     * m als das was eingestellt ist *g*
     *)
    Procedure SynthSample(len: integer; Const buffer: TStream; Const m: TStream);
    Procedure PlaySample; // Initialisiert alles notwendige, damit noch mal abgespielt werden kann (keine Parameter Änderung)

    Procedure ResetSample(restart: Boolean);
  public
    wave_type: integer; // 0..3
    wav_bits: integer; // [16, 8]
    wav_freq: integer; // [44100, 22050]

    p_env_attack: Single; // 0 .. 1
    p_env_sustain: Single; // 0 .. 1
    p_env_punch: Single; // 0 .. 1
    p_env_decay: Single; // 0 .. 1

    p_base_freq: Single; // 0 .. 1
    p_freq_limit: Single; // 0 .. 1
    p_freq_ramp: Single; // -1 .. 1
    p_freq_dramp: Single; // -1 .. 1

    p_vib_strength: Single; // 0 .. 1
    p_vib_speed: Single; // 0 .. 1

    p_arp_mod: Single; // -1 .. 1
    p_arp_speed: Single; // 0 .. 1

    p_duty: Single; // 0 .. 1
    p_duty_ramp: Single; // -1 .. 1

    p_repeat_speed: Single; // 0 .. 1

    p_pha_offset: Single; // -1 .. 1
    p_pha_ramp: Single; // -1 .. 1

    p_lpf_freq: Single; // 0 .. 1
    p_lpf_ramp: Single; // -1 .. 1
    p_lpf_resonance: Single; // 0 .. 1
    p_hpf_freq: Single; // 0 .. 1
    p_hpf_ramp: Single; // -1 .. 1

    sound_vol: Single; // 0 .. 1

    p_vib_delay: Single; // Egal wird nicht benutzt
    filter_on: Boolean; // Egal wird nicht benutzt

    Constructor Create;
    Destructor Destroy; override;

    Procedure ResetParams;

    Function ExportWav(Const Filename: String): Boolean;
    Procedure ExportBassStream(Const Stream: TStream);

    Function SaveSettings(Const Filename: String): Boolean;
    Function LoadSettings(Const Filename: String): Boolean;
  End;

Function frnd(range: Single): Single;
Function rnd(n: integer): integer;

Implementation

Uses math;

Function rnd(n: integer): integer;
Begin
  result := random(n + 1);
End;

Function frnd(range: Single): Single;
Begin
  result := (rnd(10000) / 10000) * range;
End;

{ TSFXR }

Constructor TSFXR.Create;
Begin
  Inherited create;
  wav_bits := 16;
  wav_freq := 44100;
  mute_stream := false;
  filesample := 0.0;
  fileacc := 0;
  playing_sample := false;
  master_vol := 0.05;

  sound_vol := 0.5;

  ResetParams;
End;

Destructor TSFXR.Destroy;
Begin

End;

Procedure TSFXR.SynthSample(len: integer; Const buffer: TStream;
  Const m: TStream);
Var
  si, i, ii: integer;
  rfperiod: Single;
  pp, fp, sample, ssample: Single;
  isamplew: word;
  isamplec: uint8;
Begin
  For i := 0 To len - 1 Do Begin
    If (Not playing_sample) Then break;

    rep_time := rep_time + 1;
    If (rep_limit <> 0) And (rep_time >= rep_limit) Then Begin
      rep_time := 0;
      ResetSample(true);
    End;

    // frequency envelopes/arpeggios
    arp_time := arp_time + 1;
    If (arp_limit <> 0) And (arp_time >= arp_limit) Then Begin
      arp_limit := 0;
      fperiod := fperiod * arp_mod;
    End;
    fslide := fslide + fdslide;
    fperiod := fperiod * fslide;
    If (fperiod > fmaxperiod) Then Begin
      fperiod := fmaxperiod;
      If (p_freq_limit > 0.0) Then playing_sample := false;
    End;
    rfperiod := fperiod;
    If (vib_amp > 0.0) Then Begin
      vib_phase := vib_phase + vib_speed;
      rfperiod := fperiod * (1.0 + sin(vib_phase) * vib_amp);
    End;
    period := trunc(rfperiod);
    If (period < 8) Then period := 8;
    square_duty := square_duty + square_slide;
    If (square_duty < 0.0) Then square_duty := 0.0;
    If (square_duty > 0.5) Then square_duty := 0.5;
    // volume envelope
    env_time := env_time + 1;
    If (env_time > env_length[env_stage]) Then Begin
      env_time := 0;
      env_stage := env_stage + 1;
      If (env_stage = 3) Then Begin
        playing_sample := false;
      End;
    End;
    If (env_stage = 0) Then env_vol := env_time / env_length[0];
    If (env_stage = 1) Then env_vol := 1.0 + power(1.0 - env_time / env_length[1], 1.0) * 2.0 * p_env_punch;
    If (env_stage = 2) Then env_vol := 1.0 - env_time / env_length[2];

    // phaser step
    fphase := fphase + fdphase;
    iphase := abs(trunc(fphase));
    If (iphase > 1023) Then iphase := 1023;

    If (flthp_d <> 0.0) Then Begin
      flthp := flthp * flthp_d;
      If (flthp < 0.00001) Then flthp := 0.00001;
      If (flthp > 0.1) Then flthp := 0.1;
    End;

    ssample := 0.0;
    For si := 0 To 7 Do Begin // 8x supersampling
      sample := 0.0;
      phase := phase + 1;
      If (phase >= period) Then Begin
        // phase:=0;
        phase := phase Mod period;
        If (wave_type = 3) Then Begin
          For ii := 0 To 31 Do Begin
            noise_buffer[ii] := frnd(2.0) - 1.0;
          End;
        End;
      End;
      // base waveform
      fp := phase / period;
      Case (wave_type) Of
        0: Begin // square
            If (fp < square_duty) Then Begin
              sample := 0.5;
            End
            Else Begin
              sample := -0.5;
            End;
          End;
        1: Begin // sawtooth
            sample := 1.0 - fp * 2;
          End;
        2: Begin // sine
            sample := sin(fp * 2 * PI);
          End;
        3: Begin // noise
            sample := noise_buffer[(phase * 32) Div period];
          End;
      End;
      // lp filter
      pp := fltp;
      fltw := fltw * fltw_d;
      If (fltw < 0.0) Then fltw := 0.0;
      If (fltw > 0.1) Then fltw := 0.1;
      If (p_lpf_freq <> 1.0) Then Begin
        fltdp := fltdp + (sample - fltp) * fltw;
        fltdp := fltdp - fltdp * fltdmp;
      End
      Else Begin
        fltp := sample;
        fltdp := 0.0;
      End;
      fltp := fltp + fltdp;
      // hp filter
      fltphp := fltphp + fltp - pp;
      fltphp := fltphp - fltphp * flthp;
      sample := fltphp;
      // phaser
      phaser_buffer[ipp And 1023] := sample;
      sample := sample + phaser_buffer[(ipp - iphase + 1024) And 1023];
      ipp := (ipp + 1) And 1023;
      // final accumulation and envelope application
      ssample := ssample + sample * env_vol;
    End;
    ssample := ssample / 8 * master_vol;

    ssample := ssample * 2.0 * sound_vol;
    (*
     * Dieser Code Ruiniert das ssample, wenn beide Puffer gleichzeitig
     * Aktiv sind.
     * => Es muss sicher gestellt sein, dass immer nur einer von Beiden definiert ist.
     *)
    If assigned(buffer) Then Begin
      ssample := ssample * 4.0; // arbitrary gain to get reasonable output volume...
      If (ssample > 1.0) Then ssample := 1.0;
      If (ssample < -1.0) Then ssample := -1.0;
      filesample := ssample;
      isamplew := trunc(filesample * 32000) And $FFFF;
      buffer.Write(isamplew, 2);
    End;
    If assigned(m) Then Begin
      // quantize depending on format
      // accumulate/count to accomodate variable sample rate?
      ssample := ssample * 4.0; // arbitrary gain to get reasonable output volume...
      If (ssample > 1.0) Then ssample := 1.0;
      If (ssample < -1.0) Then ssample := -1.0;
      filesample := filesample + ssample;
      fileacc := fileacc + 1;
      If (wav_freq = 44100) Or (fileacc = 2) Then Begin
        filesample := filesample / fileacc;
        fileacc := 0;
        If (wav_bits = 16) Then Begin
          isamplew := trunc(filesample * 32000) And $FFFF;
          m.Write(isamplew, 2);
        End
        Else Begin
          isamplec := trunc(filesample * 127 + 128) And $FF;
          m.Write(isamplec, 1);
        End;
        filesample := 0.0;
        file_sampleswritten := file_sampleswritten + 1;
      End;
    End;
  End;
End;

Procedure TSFXR.ResetSample(restart: Boolean);
Var
  i: integer;
Begin
  If (Not restart) Then phase := 0;
  fperiod := 100.0 / (p_base_freq * p_base_freq + 0.001);
  period := trunc(fperiod);
  fmaxperiod := 100.0 / (p_freq_limit * p_freq_limit + 0.001);
  fslide := 1.0 - power(p_freq_ramp, 3.0) * 0.01;
  fdslide := -power(p_freq_dramp, 3.0) * 0.000001;
  square_duty := 0.5 - p_duty * 0.5;
  square_slide := -p_duty_ramp * 0.00005;
  If (p_arp_mod >= 0.0) Then Begin
    arp_mod := 1.0 - power(p_arp_mod, 2.0) * 0.9;
  End
  Else Begin
    arp_mod := 1.0 + power(p_arp_mod, 2.0) * 10.0;
  End;
  arp_time := 0;
  arp_limit := trunc(power(1.0 - p_arp_speed, 2.0) * 20000 + 32);
  If (p_arp_speed = 1.0) Then Begin
    arp_limit := 0;
  End;
  If (Not restart) Then Begin
    // reset filter
    fltp := 0.0;
    fltdp := 0.0;
    fltw := power(p_lpf_freq, 3.0) * 0.1;
    fltw_d := 1.0 + p_lpf_ramp * 0.0001;
    fltdmp := 5.0 / (1.0 + power(p_lpf_resonance, 2.0) * 20.0) * (0.01 + fltw);
    If (fltdmp > 0.8) Then fltdmp := 0.8;
    fltphp := 0.0;
    flthp := power(p_hpf_freq, 2.0) * 0.1;
    flthp_d := 1.0 + p_hpf_ramp * 0.0003;
    // reset vibrato
    vib_phase := 0.0;
    vib_speed := power(p_vib_speed, 2.0) * 0.01;
    vib_amp := p_vib_strength * 0.5;
    // reset envelope
    env_vol := 0.0;
    env_stage := 0;
    env_time := 0;
    env_length[0] := max(1, trunc(p_env_attack * p_env_attack * 100000.0));
    env_length[1] := max(1, trunc(p_env_sustain * p_env_sustain * 100000.0));
    env_length[2] := max(1, trunc(p_env_decay * p_env_decay * 100000.0));

    fphase := power(p_pha_offset, 2.0) * 1020.0;
    If (p_pha_offset < 0.0) Then fphase := -fphase;
    fdphase := power(p_pha_ramp, 2.0) * 1.0;
    If (p_pha_ramp < 0.0) Then fdphase := -fdphase;
    iphase := abs(trunc(fphase));
    ipp := 0;

    For i := 0 To 1023 Do Begin
      phaser_buffer[i] := 0.0;
    End;

    For i := 0 To 31 Do Begin
      noise_buffer[i] := frnd(2.0) - 1.0;
    End;

    rep_time := 0;
    rep_limit := trunc(power(1.0 - p_repeat_speed, 2.0) * 20000 + 32);
    If (p_repeat_speed = 0.0) Then rep_limit := 0;
  End;
End;

Procedure TSFXR.ResetParams;
Begin
  wave_type := 0;

  p_base_freq := 0.3;
  p_freq_limit := 0.0;
  p_freq_ramp := 0.0;
  p_freq_dramp := 0.0;
  p_duty := 0.0;
  p_duty_ramp := 0.0;

  p_vib_strength := 0.0;
  p_vib_speed := 0.0;
  p_vib_delay := 0.0;

  p_env_attack := 0.0;
  p_env_sustain := 0.3;
  p_env_decay := 0.4;
  p_env_punch := 0.0;

  filter_on := false;
  p_lpf_resonance := 0.0;
  p_lpf_freq := 1.0;
  p_lpf_ramp := 0.0;
  p_hpf_freq := 0.0;
  p_hpf_ramp := 0.0;

  p_pha_offset := 0.0;
  p_pha_ramp := 0.0;

  p_repeat_speed := 0.0;

  p_arp_speed := 0.0;
  p_arp_mod := 0.0;
End;

Procedure TSFXR.PlaySample;
Begin
  ResetSample(false);
  playing_sample := true;
End;

Function TSFXR.ExportWav(Const Filename: String): Boolean;
Var
  F: Tfilestream;
  m: TMemoryStream;
  dword: uInt32;
  word: uInt16;
  foutstream_datasize: Int64;
Begin
  result := false;
  m := TMemoryStream.Create;

  // write wav header
  m.WriteBuffer('RIFF', 4); // "RIFF"
  dword := 0;
  m.Write(dword, 4); // remaining file size
  m.WriteBuffer('WAVE', 4); // "WAVE"
  m.WriteBuffer('fmt ', 4); // "fmt "
  dword := 16;
  m.Write(dword, 4); // chunk size
  word := 1;
  m.Write(word, 2); // compression code
  word := 1;
  m.Write(word, 2); // channels
  dword := wav_freq;
  m.Write(dword, 4); // sample rate
  dword := (wav_freq * wav_bits) Div 8;
  m.Write(dword, 4); // bytes/sec
  word := wav_bits Div 8;
  m.Write(word, 2); // block align
  word := wav_bits;
  m.Write(word, 2); // bits per sample

  m.WriteBuffer('data', 4); // "data"
  dword := 0;
  foutstream_datasize := m.Position;
  m.Write(dword, 4); // chunk size

  // write sample data
  mute_stream := true;
  file_sampleswritten := 0;
  filesample := 0.0;
  fileacc := 0;
  PlaySample();
  While (playing_sample) Do Begin
    SynthSample(256, Nil, m);
  End;
  mute_stream := false;

  // seek back to header and write size info
  m.Position := 4;
  dword := foutstream_datasize - 4 + (file_sampleswritten * wav_bits) Div 8;
  m.Write(dword, 4); // remaining file size
  m.Position := foutstream_datasize;
  dword := (file_sampleswritten * wav_bits) Div 8;
  m.Write(dword, 4); // chunk size (data)
  Try
    f := Tfilestream.Create(Filename, fmOpenWrite Or fmCreate);
  Except
    m.free;
    f.free;
    exit;
  End;
  m.position := 0;
  f.copyfrom(m, m.size);
  f.free;
  m.free;
  result := true;
End;

Procedure TSFXR.ExportBassStream(Const Stream: TStream);
Begin
  PlaySample;
  While (playing_sample) Do Begin
    SynthSample(256, Stream, Nil);
  End;
End;

Function TSFXR.SaveSettings(Const Filename: String): Boolean;
Var
  f: TFileStream;
  Version: integer;
Begin
  result := false;
  f := TFileStream.Create(Filename, fmOpenWrite Or fmCreate);
  version := 102;
  f.write(version, sizeof(Version));

  f.write(wave_type, sizeof(wave_type));

  f.write(sound_vol, sizeof(sound_vol));

  f.write(p_base_freq, sizeof(p_base_freq));
  f.write(p_freq_limit, sizeof(p_freq_limit));
  f.write(p_freq_ramp, sizeof(p_freq_ramp));
  f.write(p_freq_dramp, sizeof(p_freq_dramp));
  f.write(p_duty, sizeof(p_duty));
  f.write(p_duty_ramp, sizeof(p_duty_ramp));

  f.write(p_vib_strength, sizeof(p_vib_strength));
  f.write(p_vib_speed, sizeof(p_vib_speed));
  f.write(p_vib_delay, sizeof(p_vib_delay));

  f.write(p_env_attack, sizeof(p_env_attack));
  f.write(p_env_sustain, sizeof(p_env_sustain));
  f.write(p_env_decay, sizeof(p_env_decay));
  f.write(p_env_punch, sizeof(p_env_punch));

  f.write(filter_on, sizeof(filter_on));
  f.write(p_lpf_resonance, sizeof(p_lpf_resonance));
  f.write(p_lpf_freq, sizeof(p_lpf_freq));
  f.write(p_lpf_ramp, sizeof(p_lpf_ramp));
  f.write(p_hpf_freq, sizeof(p_hpf_freq));
  f.write(p_hpf_ramp, sizeof(p_hpf_ramp));

  f.write(p_pha_offset, sizeof(p_pha_offset));
  f.write(p_pha_ramp, sizeof(p_pha_ramp));

  f.write(p_repeat_speed, sizeof(p_repeat_speed));

  f.write(p_arp_speed, sizeof(p_arp_speed));
  f.write(p_arp_mod, sizeof(p_arp_mod));

  f.free;
  result := true;
End;

Function TSFXR.LoadSettings(Const Filename: String): Boolean;
Var
  Version: integer;
  f: TFileStream;
Begin
  result := false;
  f := TFileStream.Create(Filename, fmOpenRead);

  version := 0;
  f.Read(Version, sizeof(Version));

  If (version <> 100) And (version <> 101) And (version <> 102) Then Begin
    exit;
  End;

  f.Read(wave_type, sizeof(wave_type));

  sound_vol := 0.5;
  If (version = 102) Then Begin
    f.Read(sound_vol, sizeof(sound_vol));
  End;

  f.Read(p_base_freq, sizeof(p_base_freq));
  f.Read(p_freq_limit, sizeof(p_freq_limit));
  f.Read(p_freq_ramp, sizeof(p_freq_ramp));

  If (version >= 101) Then Begin
    f.Read(p_freq_dramp, sizeof(p_freq_dramp));
  End;
  f.Read(p_duty, sizeof(p_duty));
  f.Read(p_duty_ramp, sizeof(p_duty_ramp));

  f.Read(p_vib_strength, sizeof(p_vib_strength));
  f.Read(p_vib_speed, sizeof(p_vib_speed));
  f.Read(p_vib_delay, sizeof(p_vib_delay));

  f.Read(p_env_attack, sizeof(p_env_attack));
  f.Read(p_env_sustain, sizeof(p_env_sustain));
  f.Read(p_env_decay, sizeof(p_env_decay));
  f.Read(p_env_punch, sizeof(p_env_punch));

  f.Read(filter_on, sizeof(filter_on));
  f.Read(p_lpf_resonance, sizeof(p_lpf_resonance));
  f.Read(p_lpf_freq, sizeof(p_lpf_freq));
  f.Read(p_lpf_ramp, sizeof(p_lpf_ramp));
  f.Read(p_hpf_freq, sizeof(p_hpf_freq));
  f.Read(p_hpf_ramp, sizeof(p_hpf_ramp));

  f.Read(p_pha_offset, sizeof(p_pha_offset));
  f.Read(p_pha_ramp, sizeof(p_pha_ramp));

  f.Read(p_repeat_speed, sizeof(p_repeat_speed));

  If (version >= 101) Then Begin
    f.Read(p_arp_speed, sizeof(p_arp_speed));
    f.Read(p_arp_mod, sizeof(p_arp_mod));
  End;

  f.free;
  result := true;
End;

End.

