{$mode TP}
{$PACKRECORDS 1}
unit xmisc;

interface

Type
	TByteArray = array[0..0] of byte; {Array of bytes, useful for typecasting}
	TIntArray  = array[0..0] of integer; {Array of integers, useful for typecasting}
	TWordArray = array[0..0] of integer; {Array of words, useful for typecasting}
	TCharArray = array[0..0] of char; {Array of chars, useful for typecasting}

//function  XIntToStr( n : integer; w : byte ) : string;
{ This function transforms the integer n into a string with with w}
//function  XCompare( var a, b; l : word ) : boolean;
{ This function compares variables a and b for l bytes and, if equal
	it returns TRUE. It returns FALSE otherwise}
//function  XExists( filename : string ) : boolean;
{ This functions returns TRUE if the file "filename" exists. It
	returns false otherwise}
//procedure XStrUpCase( var s : string );
{ This procedure makes all the characters in a string uppercase}

implementation

function xinttostr( n : integer; w : byte ) : string;
var
	s : string;
begin
	str( n:w, s );
	xinttostr := s;
end;
(*
function xcompare( var a, b; l : word ) : boolean; assembler;
asm
	cld
	push ds
	lds  si, a
	les  di, b
	mov  cx, l
	repe cmpsb
	or   cx, cx
	jz   @@Ok
	mov  ax, 0
	jmp  @@Done

@@Ok:
	mov  ax, 1

@@Done:
	pop  ds

end;
 *)
function xexists( filename : string ) : boolean;
var
	f : file;
	tmp : boolean;
begin
	{$I-}
	assign( f, filename );
	reset( f );
	{$I+}
	tmp := ioresult=0;
	if tmp then close(f);
	xexists := tmp;
end;
(*
procedure xstrupcase( var s : string ); assembler;
asm
	les di, s
	mov cx, 0
	mov cl, es:[di]
	inc di
	or  cl, cl
	jz @@Done

@@ChangeChar:
	mov al, es:[di]
	cmp al, 'a'
	jl @@Next
	cmp al, 'z'
	jg @@Next
	sub al, 32
	mov es:[di], al
@@Next:
	inc di
	loop @@ChangeChar
@@Done:
end;
 *)
end.
