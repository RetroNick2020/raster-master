{$mode TP}
{$PACKRECORDS 1}

unit rwgifcore;
{ ************************************************
  **    GIF Decoding and Encoding procedures    **
  **        for Borland/Turbo Pascal 7.0        **
  **                                            **
  **     Written by Tristan Tarrant, 1994       **
  **                                            **
  **        ( Supports GIF87a/GIF89a )          **
  **                                            **
  **   Additional fixes for reading palette     **
  **   correctly and reading control block      **
  **   correctly by RetroNick                   **
  **   Was not able to read images created by   **
  **   grafX2                                   **
  ************************************************ }

interface

uses  dos,xmisc;

const
	{ Error constants used in GIF decoder }
	GoodRead      = 0; { No errors encountered during encoding/decoding }
	BadFile       = 1; { Physical problem with the media}
	BadRead       = 2; { Could not read/interpret part of the file }
	UnexpectedEOF = 3; { File too short during decoding}
	BadCode       = 4; { Code encountered during decoding was not expected}
	BadFirstCode  = 5; { The first code was invalid}
	NoFile        = 6; { Could not open the file for read/write}
	BadSymbolSize = 7; { Number of bits not supported}
	NoCode        = -1;

Type
	GifLineProcType = procedure( Var pixels; line, width : integer );
	GifPixelProcType = function : integer;

Var
	{ Pointers to custom procedures to deal with lines. GifOutLineProc
		is called with three parameters : an untyped var, containing
		the uncompressed data, and two integer values, containing the
		line number and the width of the line.
		GifInPixelProc should instead return a pixels value, -1 if at the
		end of the data. }

	GifOutLineProc : GifLineProcType;
{ GifOutLineProc is called with an untyped variable containing a row's
	worth of pixels. The current line is given in line and the number of
	pixels in a line is given in width}
	GifInPixelProc : GifPixelProcType;
{ GifInPixelProc should return a pixel value, -1 if at the end of the data.
	Data should be returned width first (i.e. all pixels in row 0, then all
	pixels in row 1, etc.}
	GifPalette : array[0..767] of byte;
{ GifPalette is an array which contains the palette of the last loaded
	GIF file}



function LoadGif( f : string ) : integer;
{ This function loads a GIF file f and returns an error code.
	It uses the #GIFLineProc# procedure to send the decoded picture
	to the application. The palette of the picture is stored in the
	global variable #GifPalette#}
function SaveGif( f : string; width, depth, bits : integer; var palette ) : integer;
{ This function saves a GIF file f with using screen size width*depth
	and with a color resolution of bits. For a 256 colour image bits is 8.
	Palette contains the palette of the picture that is being saved.
	SaveGIF uses #GIFInPixelProc# to get the picture data from the application.
	It returns an error code}
function GifError( ErrorCode : integer ) : string;
{ This function converts an error code returned by SaveGIF into a string}

Implementation

type
	GifHeader =
		record
			sig : array[1..6] of char;
			screenwidth, screendepth : word;
			flags, background, aspect : byte;
		end;

	ImageBlock =
		record
			left, top, width, depth : word;
			flags : byte;
		end;

	FileInfo =
		record
			width, depth, bits,
			flags, background : integer;
			palette : array[1..768] of byte;
		end;

	ControlBlock =
		record
			blocksize, flags : byte;
			delay : word;
			transparentcolour, terminator : byte;
		end;

	PlainText =
		record
			blocksize : byte;
			left, top, gridwidth, gridheight : word;
			cellwidth, cellheight, forecolour, backcolour : byte;
		end;

	Application =
		record
			blocksize : byte;
			applstring : array[1..8] of char;
			authentication : array[1..3] of char;
		end;


const
	TableSize = 5003;
	{ These values will be masked with the codes output from the
		decoder to remove spurious bits }
	CodeMask : array[1..13] of word =
		( $0000,
			$0001, $0003,
			$0007, $000F,
			$001F, $003F,
			$007F, $00FF,
			$01FF, $03FF,
			$07FF, $0FFF );
	LargestCode = 4095;

function UnpackImage( var F : File; bits : integer; Var fi : FileInfo ) : integer;
var
	bits2, codesize, codesize2, nextcode, thiscode,
	oldtoken, currentcode, oldcode, bitsleft, blocksize,
	line, pass, byt, p, q, u : integer;
	b : array[0..255] of byte;
	linebuffer, firstcodestack, lastcodestack : ^TByteArray;
	codestack : ^TIntArray;
const
	wordmasktable : array[0..15] of word =
		( $0000, $0001, $0003, $0007, $000F, $001F,
			$003F, $007F, $00FF, $01FF, $03FF, $07FF,
			$0FFF, $1FFF, $3FFF, $7FFF );
	inctable : array[0..4] of integer = ( 8, 8, 4, 2, 0 );
	starttable : array[0..4] of integer = ( 0, 4, 2, 1, 0 );
begin
	pass := 0;
	line := 0;
	byt := 0;
	p := 0;
	q := 0;
	blocksize := 0;
	fillchar( b, 256, 0 );
	bitsleft := 8;
	if ( bits < 2 ) or ( bits > 8 ) then
	begin
		UnpackImage := BadSymbolSize;
		exit;
	end;
	bits2 := 1 shl bits;
	nextcode := bits2 + 2;
	codesize := bits + 1;
	codesize2 := 1 shl codesize;
	oldcode := NoCode;
	oldtoken := NoCode;
	getmem( firstcodestack, 4096 );
	getmem( lastcodestack, 4096 );
	getmem( codestack, 8192 );
	getmem( linebuffer, fi.width );
	while true do
	begin
		if bitsleft = 8 then
		begin
			inc(p);
			if p>=q then
			begin
				blocksize := 0;
				blockread( F, blocksize, 1);
				if blocksize>0 then
				begin
					p:=0;
					blockread( F, b, blocksize, q );
					if q<>blocksize then
					begin
						freemem( firstcodestack, 4096 );
						freemem( lastcodestack, 4096 );
						freemem( codestack, 8192 );
						freemem( linebuffer, fi.width );
						UnpackImage := UnexpectedEOF;
						exit;
					end;
				end else
				begin
					freemem( firstcodestack, 4096 );
					freemem( lastcodestack, 4096 );
					freemem( codestack, 8192 );
					freemem( linebuffer, fi.width );
					UnpackImage := UnexpectedEOF;
					exit;
				end;
			end;
			bitsleft := 0;
		end;
		thiscode := b[p];
		currentcode := codesize + bitsleft;
		if currentcode <=8 then
		begin
			b[p] := b[p] shr codesize;
			bitsleft := currentcode;
		end else
		begin
			inc(p);
			if p>=q then
			begin
				blocksize := 0;
				blockread( F, blocksize, 1);
				if blocksize>0 then
				begin
					p:=0;
					blockread( F, b, blocksize, q );
					if q<>blocksize then
					begin
						freemem( firstcodestack, 4096 );
						freemem( lastcodestack, 4096 );
						freemem( codestack, 8192 );
						freemem( linebuffer, fi.width );
						UnpackImage := UnexpectedEOF;
						exit;
					end;
				end else
				begin
					freemem( firstcodestack, 4096 );
					freemem( lastcodestack, 4096 );
					freemem( codestack, 8192 );
					freemem( linebuffer, fi.width );
					UnpackImage := UnexpectedEOF;
					exit;
				end;
			end;
			thiscode := thiscode or ( b[p] shl (8-bitsleft) );
			if currentcode <= 16 then
			begin
				bitsleft := currentcode - 8;
				b[p] := b[p] shr bitsleft;
			end else
			begin
				inc(p);
				if p>=q then
				begin
					blocksize := 0;
					blockread( F, blocksize, 1);
					if blocksize>0 then
					begin
						p:=0;
						blockread( F, b, blocksize, q );
						if q<>blocksize then
						begin
							freemem( firstcodestack, 4096 );
							freemem( lastcodestack, 4096 );
							freemem( codestack, 8192 );
							freemem( linebuffer, fi.width );
							UnpackImage := UnexpectedEOF;
							exit;
						end;
					end else
					begin
						freemem( firstcodestack, 4096 );
						freemem( lastcodestack, 4096 );
						freemem( codestack, 8192 );
						freemem( linebuffer, fi.width );
						UnpackImage := UnexpectedEOF;
						exit;
					end;
				end;
				thiscode := thiscode or ( b[p] shl (16-bitsleft) );
				bitsleft := currentcode - 16;
				b[p] := b[p] shr bitsleft;
			end;
		end;
		thiscode := thiscode and wordmasktable[codesize];
		currentcode := thiscode;
		if thiscode = bits2+1 then break;
		if thiscode > nextcode then
		begin
			freemem( firstcodestack, 4096 );
			freemem( lastcodestack, 4096 );
			freemem( codestack, 8192 );
			freemem( linebuffer, fi.width );
			UnpackImage := BadCode;
			exit;
		end;
		if thiscode = bits2 then
		begin
			nextcode := bits2+2;
			codesize := bits + 1;
			codesize2 := 1 shl codesize;
			oldtoken := NoCode;
			OldCode := NoCode;
			continue;
		end;
		u := 0;
		if thiscode = nextcode then
		begin
			if oldcode = NoCode then
			begin
				freemem( firstcodestack, 4096 );
				freemem( lastcodestack, 4096 );
				freemem( codestack, 8192 );
				freemem( linebuffer, fi.width );
				UnpackImage := BadFirstCode;
				exit;
			end;
			firstcodestack^[u] := oldtoken;
			inc( u );
			thiscode := oldcode;
		end;
		while thiscode >= bits2 do
		begin
			firstcodestack^[u] := lastcodestack^[thiscode];
			inc( u );
			thiscode := codestack^[thiscode];
		end;
		oldtoken := thiscode;
		while true do
		begin
			linebuffer^[byt] := thiscode;
			inc( byt );
			if byt >= fi.width then
			begin
				GifOutLineProc( linebuffer^, line, fi.width );
				byt := 0;
				if fi.flags and $40 = $40 then
				begin
					line := line + inctable[pass];
					if line >= fi.depth then
					begin
						inc(pass);
						line := starttable[pass];
					end;
				end else inc(line);
			end;
			if u <= 0 then break;
			dec( u );
			thiscode := firstcodestack^[u];
		end;
		if (nextcode < 4096) and (oldcode <> NoCode) then
		begin
			codestack^[nextcode] := oldcode;
			lastcodestack^[nextcode] := oldtoken;
			inc( nextcode );
			if (nextcode >= codesize2) and (codesize < 12) then
			begin
				inc( codesize );
				codesize2 := 1 shl codesize;
			end;
		end;
		oldcode := currentcode;
	end;
	freemem( firstcodestack, 4096 );
	freemem( lastcodestack, 4096 );
	freemem( codestack, 8192 );
	freemem( linebuffer, fi.width );
	UnpackImage := GoodRead;
end; { UnpackImage }

{ *** FIXED SkipExtension procedure ***
  The original code had issues with:
  1. Graphics Control Extension ($F9) - was reading struct directly but
     the terminator byte needs to be read after the fixed-size data
  2. Generic extension handling needed to skip sub-blocks properly
}
procedure SkipExtension( Var F : File );
var
	n, a : byte;
	i : integer;
begin
	{ Read extension label }
	blockread( F, a, 1 );

	{ Now skip all sub-blocks until we hit a zero-length block terminator }
	{ This works for ALL extension types uniformly }
	blockread( F, n, 1 );
	while n > 0 do
	begin
		{ Skip n bytes of sub-block data }
		for i := 1 to n do
			blockread( F, a, 1 );
		{ Read next sub-block size (0 = terminator) }
		blockread( F, n, 1 );
	end;
end; { SkipExtension }

function UnpackGIF( Var F : File ) : integer;
var
	gh : GifHeader;
	iblk : ImageBlock;
	t : longint;
	b, c : integer;
	r : word;
	ch : char;
	fi : FileInfo;
begin
	blockread( F, gh, SizeOf(GifHeader), r );
	if ( gh.sig[1]+gh.sig[2]+gh.sig[3]<>'GIF' ) or ( r<>SizeOf(GifHeader) ) then
	begin
		UnpackGIF := BadFile;
		exit;
	end;
	fi.width := gh.screenwidth;
	fi.depth := gh.screendepth;
	fi.bits := gh.flags and $07 + 1;
	fi.background := gh.background;
	if ( gh.flags and $80 )=$80 then
	begin
		c:=3*( 1 shl fi.bits );
		blockread( F, fi.palette, c, r );
		if r<>c then
		begin
			UnpackGIF := BadRead;
			exit;
		end;
		for b := 0 to 255 do
		begin
		//	GIFPalette[b*3] := fi.palette[b*3+1] shr 2;
		//	GIFPalette[b*3+1] := fi.palette[b*3+2] shr 2;
		//	GIFPalette[b*3+2] := fi.palette[b*3+3] shr 2;

      			GIFPalette[b*3] := fi.palette[b*3+1];
			GIFPalette[b*3+1] := fi.palette[b*3+2];
			GIFPalette[b*3+2] := fi.palette[b*3+3];

		end;

	end;
	blockread( F, ch, 1 );
	while ( ch = ',' ) or ( ch = '!' ) or ( ch = #0 ) do
	begin
		case ch of
			',' : begin
							blockread( F, iblk, SizeOf(ImageBlock), r );
							if r<>SizeOf(ImageBlock) then
							begin
								UnpackGIF := BadRead;
								Exit;
							end;
							fi.width := iblk.width;
							fi.depth := iblk.depth;
							if ( iblk.flags and $80 )=$80 then
							begin
								b := 3*(1 shl (iblk.flags and $07 + 1));
								blockread( F, fi.palette, b, r );
								if r<>b then
								begin
									UnpackGIF := BadRead;
									Exit;
								end;
								for b := 0 to 255 do
								begin
								//	GIFPalette[b*3] := fi.palette[b*3+1] shr 2;
								//	GIFPalette[b*3+1] := fi.palette[b*3+2] shr 2;
								//	GIFPalette[b*3+1] := fi.palette[b*3+3] shr 2;

                                                             	GIFPalette[b*3] := fi.palette[b*3+1];
									GIFPalette[b*3+1] := fi.palette[b*3+2];
									GIFPalette[b*3+2] := fi.palette[b*3+3];

								end;
							end;
							if EOF( F ) then
							begin
								UnpackGIF := BadFile;
								Exit;
							end;
							c:=0;
							blockread( F, c, 1 );
							fi.flags:=iblk.flags;
							t := UnpackImage( F, c, fi );
							UnpackGif:=t;
							exit;
						end;
			'!' : SkipExtension( F );
		end;
		blockread( F, ch, 1 );
	end;
	UnpackGIF := BadFile; { No image found }
end; { UnpackGIF }

function LoadGif;
var
	D: DirStr;
	N: NameStr;
	E: ExtStr;
	FileHandle : File;
begin
	FSplit( F, D, N, E );
	if E='' then E:='.GIF';
	F := D+N+E;
	{$I-}
		assign( FileHandle, F );
		reset( FileHandle, 1 );
	{$I+}
	if ioresult = 0 then
		LoadGif := UnpackGif( FileHandle )
	else
		LoadGif := NoFile;
	{$I-}
		close( FileHandle );
	{$I+}
end; { LoadGif }

function WriteScreenDesc( var fp : file; width, depth, bits, background : integer; var palette ) : integer;
var
	gh : GIFHeader;
	i : integer;
	gifsig : string;
	pal : TByteArray absolute palette;
	a : byte;
begin
	FillChar( gh, sizeof(GIFHeader),0 );
	gifsig := 'GIF87a';

	move( gifsig[1], gh.sig[1], 6 );
	gh.screenwidth := width;
	gh.screendepth := depth;
	gh.background := background;
	gh.aspect := 0;
	gh.flags := $80 or ((bits-1) shl 4) or ((bits-1) and $07);
	blockwrite( fp, gh, sizeof(GIFHeader) );
	for i := 0 to (1 shl bits)*3-1 do
	begin
//		a := pal[i] shl 2;
            		a := pal[i];

		blockwrite( fp, a, 1 );
	end;
	WriteScreenDesc := 0;
end;

function WriteImageDesc( var fp : file; left, top, width, depth, bits : integer ) : integer;
var
	ib : ImageBlock;
	ch : char;
begin
	fillchar( ib, sizeof(ImageBlock), 0 );
	ch := ',';
	blockwrite( fp, ch, 1 );
	ib.left := left;
	ib.top := top;
	ib.width := width;
	ib.depth := depth;
//	ib.flags := bits-1;
        ib.flags := 0;

	blockwrite( fp, ib, sizeof(ImageBlock) );
	WriteImageDesc := 0;
end;


function CompressImage( var fp : file; mincodesize : word ) : integer;
var
	prefixcode, suffixchar, hx, d : integer;
	codebuffer, newcode : ^TByteArray;
	oldcode, currentcode : ^TIntArray;
	codesize, clearcode, eofcode, bitoffset,
	byteoffset, bitsleft, maxcode, freecode : integer;


	procedure InitTable( mincodesize : integer );
	var
		i : integer;
	begin
		codesize := mincodesize + 1;
		clearcode := 1 shl mincodesize;
		eofcode := clearcode+1;
		freecode := clearcode+2;
		maxcode := 1 shl codesize;
		for i := 0 to tablesize-1 do
			currentcode^[i] := 0;
	end;

	procedure Deallocate;
	begin
		freemem( newcode, tablesize+1 );
		freemem( currentcode, (tablesize+1)*2 );
		freemem( oldcode, (tablesize+1)*2 );
		freemem( codebuffer, 260 );
	end;

	procedure FlushFile( var fp : file; n : integer );
	var
		a : byte;
	begin
		a := n;
		blockwrite( fp, a, 1 );
		blockwrite( fp, codebuffer^[0], n );
	end;

	procedure WriteCode( var fp : file; code : integer );
	var
		temp : longint;
	begin
		byteoffset := bitoffset shr 3;
		bitsleft := bitoffset and 7;
		if byteoffset >= 254 then
		begin
			FlushFile( fp, byteoffset );
			codebuffer^[0] := codebuffer^[byteoffset];
			bitoffset := bitsleft;
			byteoffset := 0;
		end;
		if bitsleft > 0 then
		begin
			temp := ( longint(code) shl bitsleft ) or codebuffer^[byteoffset];
			codebuffer^[byteoffset] := temp;
			codebuffer^[byteoffset+1] := temp shr 8;
			codebuffer^[byteoffset+2] := temp shr 16;
		end else
		begin
			codebuffer^[byteoffset] := code;
			codebuffer^[byteoffset+1] := code shr 8;
		end;
		bitoffset := bitoffset + codesize;
	end;


begin
	if (mincodesize<2) or (mincodesize>9) then
		if mincodesize = 1 then
			mincodesize := 2
		else
		begin
			CompressImage := 1;
			exit;
		end;
	getmem( codebuffer, 260 );
	getmem( oldcode, (tablesize+1)*2 );
	getmem( currentcode, (tablesize+1)*2 );
	getmem( newcode, tablesize+1 );
	bitoffset := 0;
	InitTable( mincodesize );
	blockwrite( fp, mincodesize, 1 );
	suffixchar := GIFInPixelProc;
	if suffixchar < 0 then
	begin
		CompressImage := 1;
		Deallocate;
		exit;
	end;
	prefixcode := suffixchar;
	suffixchar := GIFInPixelProc;
	while suffixchar>=0 do
	begin
		hx := (prefixcode xor (suffixchar shl 5)) mod tablesize;
		d := 1;
		while true do
		begin
			if currentcode^[hx] = 0 then
			begin
				writecode( fp, prefixcode );
				d := freecode;
				if freecode <= largestcode then
				begin
					oldcode^[hx] := prefixcode;
					newcode^[hx] := suffixchar;
					currentcode^[hx] := freecode;
					inc(freecode);
				end;
				if d=maxcode then
				begin
					if codesize<12 then
					begin
						inc(codesize);
						maxcode := maxcode shl 1;
					end else
					begin
						writecode( fp, clearcode );
						InitTable( mincodesize );
					end;
				end;
				prefixcode := suffixchar;
				break;
			end;
			if (oldcode^[hx] = prefixcode) and (newcode^[hx] = suffixchar ) then
			begin
				prefixcode := currentcode^[hx];
				break;
			end;
			hx := hx + d;
			d := d + 2;
			if hx >= tablesize then hx := hx - tablesize;
		end;
		suffixchar := GIFInPixelProc;
	end;
	writecode( fp, prefixcode );
	writecode( fp, eofcode );
	if bitoffset >0 then FlushFile( fp, (bitoffset+7) div 8 );
	FlushFile( fp, 0 );
	CompressImage := 0;
	Deallocate;
end;


function WriteGif( var fp : file; width, depth, bits : integer; var palette ) : integer;
var
	ch : char;
begin
	if WriteScreenDesc( fp, width, depth, bits, 0, palette )>0 then
		WriteGIF := 1
	else
	if WriteImageDesc( fp, 0, 0, width, depth, bits )>0 then
		WriteGIF := 2
	else
	if CompressImage( fp, bits )>0 then
		WriteGIF := 3
	else
	begin
		WriteGIF := 0;
		ch := ';';
		blockwrite( fp, ch, 1 );
	end;
end;

function SaveGif( f : string; width, depth, bits : integer; var palette ) : integer;
var
	D: DirStr;
	N: NameStr;
	E: ExtStr;
	FileHandle : File;
begin
	FSplit( F, D, N, E );
	if E='' then E:='.GIF';
	F := D+N+E;
	{$I-}
		assign( FileHandle, F );
		rewrite( FileHandle, 1 );
	{$I+}
	if ioresult = 0 then
		SaveGif := WriteGif( FileHandle, width, depth, bits, palette  )
	else
		SaveGif := NoFile;
	{$I-}
		close( FileHandle );
	{$I+}
end;

function GifError;
begin
	case ErrorCode of
		GoodRead : GifError := 'Ok';
		BadFile  : GifError := 'Bad File';
		BadRead  : GifError := 'Bad Read';
		UnexpectedEOF : GifError := 'Unexpected End';
		BadCode       : GifError := 'Bad LZW Code';
		BadFirstCode  : GifError := 'Bad First Code';
		BadSymbolSize : GifError := 'Bad Symbol Size';
		NoFile        : GifError := 'File Not Found';
		else GifError := 'Unknown';
	end;
end; { GifError }


end.
