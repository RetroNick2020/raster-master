{$MODE OBJFPC}{$H+}
unit QBasicInterp;

{
  QBasicInterp - QBasic Interpreter Unit for Font Editor
  
  This is a modified version of the standalone interpreter,
  converted to a reusable unit that can be embedded in applications.
  
  Key changes from standalone:
  - No console I/O (uses callbacks)
  - Custom function registration for Font API
  - Error handling with exceptions
}

interface

uses
  Classes, SysUtils, Math;

type
  TTokenType = (
    ttEOF, ttEOL, ttNumber, ttString, ttIdent, ttComma, ttSemicolon,
    ttPlus, ttMinus, ttMult, ttDiv, ttIntDiv, ttMod, ttPower,
    ttEQ, ttNE, ttLT, ttLE, ttGT, ttGE,
    ttLParen, ttRParen, ttColon,
    ttPRINT, ttINPUT, ttLET, ttIF, ttTHEN, ttELSE, ttELSEIF, ttEND,
    ttFOR, ttTO, ttSTEP, ttNEXT, ttWHILE, ttWEND, ttDO, ttLOOP,
    ttGOTO, ttGOSUB, ttRETURN, ttDIM, ttAS,
    ttINTEGER, ttSINGLE, ttDOUBLE, ttSTRING_TYPE, ttREM,
    ttCLS, ttLOCATE, ttCOLOR, ttSCREEN,
    ttAND, ttOR, ttNOT, ttXOR,
    ttSUB, ttFUNCTION, ttEXIT, ttCALL, ttSTATIC, ttSHARED,
    ttSELECT, ttCASE, ttIS
  );

  TToken = record
    TokenType: TTokenType;
    Value: string;
    Line: Integer;
    Col: Integer;
  end;

  TVariable = record
    Name: string;
    IsString: Boolean;
    NumValue: Double;
    StrValue: string;
    IsArray: Boolean;
    ArrayDims: array of Integer;
    ArrayData: array of Double;
    ArrayStrData: array of string;
    ArrayLo: array of Integer;     // lower bound per dimension (ArrayDims = upper)
  end;
  PVariable = ^TVariable;
  TIntArray = array of Integer;

  { one DATA item, collected when the program is loaded }
  TDataItem = record
    IsString: Boolean;
    NumValue: Double;
    StrValue: string;
    TokPos: Integer;     // token index of its DATA statement - for RESTORE label
  end;

  { an assignable target: NAME or NAME(i[,j...]) }
  TLValue = record
    Name: string;
    HasIdx: Boolean;
    Idx: TIntArray;
  end;

  TSubParameter = record
    Name: string;
    IsString: Boolean;
    ByRef: Boolean;
  end;

  TSubProgram = record
    Name: string;
    StartPos: Integer;
    EndPos: Integer;
    IsFunction: Boolean;
    Parameters: array of TSubParameter;
    LocalVars: array of TVariable;
  end;

  TCallStackEntry = record
    ReturnPos: Integer;
    SubName: string;
    SavedLocalVars: array of TVariable;
    PrevSubIdx: Integer;
    WasInSub: Boolean;
  end;

  TForStackEntry = record
    VarName: string;
    EndVal: Double;
    StepVal: Double;
    LoopPos: Integer;
  end;

  TLabelEntry = record
    Name: string;
    Position: Integer;
  end;

  { Custom function callback types }
  TBuiltinFuncNum = function(const Args: array of Double): Double of object;
  TBuiltinFuncStr = function(const Args: array of Double; const StrArgs: array of string): string of object;
  TBuiltinFuncMixed = function(const Args: array of Double; const StrArgs: array of string): Double of object;
  TBuiltinProc = procedure(const Args: array of Double; const StrArgs: array of string) of object;
  
  TBuiltinFunction = record
    Name: string;
    MinArgs: Integer;
    MaxArgs: Integer;
    ReturnsString: Boolean;
    NumFunc: TBuiltinFuncNum;
    StrFunc: TBuiltinFuncStr;
    MixedFunc: TBuiltinFuncMixed;
    ProcFunc: TBuiltinProc;
    IsProc: Boolean;
  end;

  { Event types }
  TPrintEvent = procedure(const Text: string) of object;
  TInputEvent = function(const Prompt: string; var Value: string): Boolean of object;
  TYieldProc = procedure of object;

  { Forward declaration }
  TQBasicInterpreter = class;

  { Lexer }
  TQBasicLexer = class
  private
    FText: string;
    FPos: Integer;
    FLine: Integer;
    FCol: Integer;
    function CurrentChar: Char;
    procedure Advance;
    procedure SkipWhitespace;
    function ReadNumber: string;
    function ReadString: string;
    function ReadIdent: string;
  public
    constructor Create(const AText: string);
    function GetNextToken: TToken;
    property Line: Integer read FLine;
    property Col: Integer read FCol;
  end;

  { Interpreter }
  TQBasicInterpreter = class
  private
    FTokens: array of TToken;
    FPos: Integer;
    FVariables: array of TVariable;
    FForStack: array of TForStackEntry;
    FGosubStack: array of Integer;
    FLabels: array of TLabelEntry;
    FSubPrograms: array of TSubProgram;
    FCallStack: array of TCallStackEntry;
    FInSubProgram: Boolean;
    FCurrentSubIdx: Integer;
    FBuiltins: array of TBuiltinFunction;
    FData: array of TDataItem;
    FExitDo: Boolean;
    FExitFunc: Boolean;    // EXIT FUNCTION seen - blocks unwind to RunUserFunction
    FFuncDepth: Integer;   // user FUNCTIONs running from expressions
    FPrintPending: string;  // text of a PRINT that ended with ; or ,     // EXIT DO seen - enclosing blocks unwind to the DO
    FDataPtr: Integer;
    FRunning: Boolean;
    FStopRequested: Boolean;
    
    FOnPrint: TPrintEvent;
    FOnInput: TInputEvent;
    FOnYield: TYieldProc;
    FStatementCount: Integer;
    
    function CurrentToken: TToken;
    procedure Advance;
    function Match(AType: TTokenType): Boolean;
    procedure Expect(AType: TTokenType);
    function PeekToken(Offset: Integer = 1): TToken;
    
    function GetVariable(const AName: string): Integer;
    function GetVariableValue(const AName: string): Double;
    function GetVariableStrValue(const AName: string): string;
    procedure SetVariable(const AName: string; AValue: Double; const AStrValue: string; AIsString: Boolean; ForceLocal: Boolean = False);
    
    function EvaluateExpr: Double;
    function EvaluateStrExpr: string;
    function EvaluateTerm: Double;
    function EvaluateUnary: Double;
    function EvaluateFactor: Double;
    function EvaluateComparison: Double;
    function EvaluateLogical: Double;
    function IsStringExpr: Boolean;
    
    procedure ExecuteStatement;
    procedure ExecutePRINT;
    procedure ExecuteINPUT;
    procedure ExecuteLET;
    procedure ExecuteIF;
    procedure ExecuteFOR;
    procedure ExecuteNEXT;
    procedure ExecuteWHILE;
    procedure ExecuteWEND;
    procedure ExecuteDO;
    procedure ExecuteLOOP;
    procedure ExecuteGOTO;
    procedure ExecuteGOSUB;
    procedure ExecuteRETURN;
    procedure ExecuteDIM;
    procedure ExecuteCALL;
    procedure ExecuteSUB;
    procedure ExecuteFUNCTION;
    procedure ExecuteSELECT;
    
    procedure ScanLabels;
    procedure ScanData;
    procedure SkipToBlockEnd(OpenTok, CloseTok: TTokenType);
    function  IsBlockIFAt(P: Integer): Boolean;
    procedure RaiseErr(const Msg: string);
    function  TokenName(T: TTokenType): string;
    function  FindVarRec(const AName: string): PVariable;
    function  IsArrayVar(const AName: string): Boolean;
    function  ParseIndices: TIntArray;
    function  ArrayOffset(V: PVariable; const Idx: TIntArray): Integer;
    procedure DimArray(const AName: string; const Lo, Hi: TIntArray; AIsString, ForceLocal: Boolean);
    procedure ImplicitDim(const AName: string; NDims: Integer);
    function  GetArrayNum(const AName: string; const Idx: TIntArray): Double;
    function  GetArrayStr(const AName: string; const Idx: TIntArray): string;
    procedure SetArrayNum(const AName: string; const Idx: TIntArray; AValue: Double);
    procedure SetArrayStr(const AName: string; const Idx: TIntArray; const AValue: string);
    function  ParseLValue: TLValue;
    function  LValueIsString(const L: TLValue): Boolean;
    function  GetLValueNum(const L: TLValue): Double;
    function  GetLValueStr(const L: TLValue): string;
    procedure SetLValueNum(const L: TLValue; AValue: Double);
    procedure SetLValueStr(const L: TLValue; const AValue: string);
    function  ExecuteNamedStatement: Boolean;
    procedure ExecuteREAD;
    procedure ExecuteRESTORE;
    procedure ExecuteSWAP;
    procedure ExecuteCONST;
    procedure ExecuteRANDOMIZE;
    procedure ExecuteERASE;
    function  EvaluateBound(IsUpper: Boolean): Double;
    function  EvaluatePower: Double;
    procedure ScanSubPrograms;
    function FindLabel(const ALabel: string): Integer;
    function FindSubProgram(const AName: string): Integer;
    function FindBuiltin(const AName: string): Integer;
    function CallFunction(const AName: string): Double;
    procedure RunUserFunction(SubIdx: Integer; const AName: string;
      const Args: array of Double; const StrArgs: array of string;
      var NumResult: Double; var StrResult: string);
    function CallStringFunction(const AName: string): string;
    procedure CallBuiltinProc(const AName: string);
    
    function BuiltinABS(const Args: array of Double): Double;
    function BuiltinFIX(const Args: array of Double): Double;
    function BuiltinCINT(const Args: array of Double): Double;
    function BuiltinTIMER(const Args: array of Double): Double;
    function BuiltinINSTR(const Args: array of Double; const StrArgs: array of string): Double;
    function BuiltinHEX(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinOCT(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinDATE(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinTIME(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinINT(const Args: array of Double): Double;
    function BuiltinSGN(const Args: array of Double): Double;
    function BuiltinSQR(const Args: array of Double): Double;
    function BuiltinSIN(const Args: array of Double): Double;
    function BuiltinCOS(const Args: array of Double): Double;
    function BuiltinTAN(const Args: array of Double): Double;
    function BuiltinATN(const Args: array of Double): Double;
    function BuiltinLOG(const Args: array of Double): Double;
    function BuiltinEXP(const Args: array of Double): Double;
    function BuiltinRND(const Args: array of Double): Double;
    function BuiltinLEN(const Args: array of Double; const StrArgs: array of string): Double;
    function BuiltinASC(const Args: array of Double; const StrArgs: array of string): Double;
    function BuiltinVAL(const Args: array of Double; const StrArgs: array of string): Double;
    function BuiltinMIN(const Args: array of Double): Double;
    function BuiltinMAX(const Args: array of Double): Double;
    
    function BuiltinCHR(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinSTR(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinLEFT(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinRIGHT(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinMID(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinUCASE(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinLCASE(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinLTRIM(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinRTRIM(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinSPACE(const Args: array of Double; const StrArgs: array of string): string;
    function BuiltinSTRING(const Args: array of Double; const StrArgs: array of string): string;
    
    procedure RegisterBuiltins;
    
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure LoadProgram(const ACode: string);
    procedure Execute;
    procedure Stop;
    procedure Reset;
    
    { Register custom functions }
    procedure RegisterFunction(const AName: string; AMinArgs, AMaxArgs: Integer;
      AFunc: TBuiltinFuncNum);
    procedure RegisterStringFunction(const AName: string; AMinArgs, AMaxArgs: Integer;
      AFunc: TBuiltinFuncStr);
    procedure RegisterMixedFunction(const AName: string; AMinArgs, AMaxArgs: Integer;
      AFunc: TBuiltinFuncMixed);
    procedure RegisterProcedure(const AName: string; AMinArgs, AMaxArgs: Integer;
      AProc: TBuiltinProc);
    
    { Set/Get global variables from host }
    procedure SetGlobalVariable(const AName: string; AValue: Double);
    procedure SetGlobalStringVariable(const AName: string; const AValue: string);
    function GetGlobalVariable(const AName: string): Double;
    function GetGlobalStringVariable(const AName: string): string;
    
    property OnPrint: TPrintEvent read FOnPrint write FOnPrint;
    property OnInput: TInputEvent read FOnInput write FOnInput;
    property OnYield: TYieldProc read FOnYield write FOnYield;
    property Running: Boolean read FRunning;
  end;

  EQBasicError = class(Exception)
  public
    Line: Integer;
    Col: Integer;
    constructor Create(const AMsg: string; ALine, ACol: Integer);
  end;

implementation

{ EQBasicError }

constructor EQBasicError.Create(const AMsg: string; ALine, ACol: Integer);
begin
  inherited CreateFmt('Line %d, Col %d: %s', [ALine, ACol, AMsg]);
  Line := ALine;
  Col := ACol;
end;

{ TQBasicLexer }

constructor TQBasicLexer.Create(const AText: string);
begin
  FText := AText + #0;
  FPos := 1;
  FLine := 1;
  FCol := 1;
end;

function TQBasicLexer.CurrentChar: Char;
begin
  if FPos <= Length(FText) then
    Result := FText[FPos]
  else
    Result := #0;
end;

procedure TQBasicLexer.Advance;
begin
  if CurrentChar = #10 then
  begin
    Inc(FLine);
    FCol := 1;
  end
  else
    Inc(FCol);
  Inc(FPos);
end;

procedure TQBasicLexer.SkipWhitespace;
begin
  while CurrentChar in [' ', #9] do
    Advance;
end;

function TQBasicLexer.ReadNumber: string;
var
  HasDot: Boolean;
begin
  Result := '';
  HasDot := False;
  while CurrentChar in ['0'..'9', '.'] do
  begin
    if CurrentChar = '.' then
    begin
      if HasDot then Break;
      HasDot := True;
    end;
    Result := Result + CurrentChar;
    Advance;
  end;
end;

function TQBasicLexer.ReadString: string;
begin
  Result := '';
  Advance; // Skip opening quote
  while (CurrentChar <> '"') and (CurrentChar <> #0) and (CurrentChar <> #10) do
  begin
    Result := Result + CurrentChar;
    Advance;
  end;
  if CurrentChar = '"' then
    Advance;
end;

function TQBasicLexer.ReadIdent: string;
begin
  Result := '';
  while CurrentChar in ['A'..'Z', 'a'..'z', '0'..'9', '_', '$', '%', '!', '#', '&'] do
  begin
    Result := Result + UpCase(CurrentChar);
    Advance;
  end;
end;

function TQBasicLexer.GetNextToken: TToken;
var
  Ident: string;
begin
  SkipWhitespace;
  
  Result.Line := FLine;
  Result.Col := FCol;
  Result.Value := '';
  
  if CurrentChar = #0 then
  begin
    Result.TokenType := ttEOF;
    Exit;
  end;
  
  if CurrentChar in [#10, #13] then
  begin
    while CurrentChar in [#10, #13] do
      Advance;
    Result.TokenType := ttEOL;
    Exit;
  end;
  
  if CurrentChar = ':' then
  begin
    Advance;
    Result.TokenType := ttColon;
    Exit;
  end;
  
  // Handle single-quote comments
  if CurrentChar = '''' then
  begin
    while not (CurrentChar in [#10, #13, #0]) do
      Advance;
    Result.TokenType := ttEOL;
    Exit;
  end;
  
  if CurrentChar in ['0'..'9'] then
  begin
    Result.TokenType := ttNumber;
    Result.Value := ReadNumber;
    Exit;
  end;
  
  if CurrentChar = '.' then
  begin
    if (FPos + 1 <= Length(FText)) and (FText[FPos + 1] in ['0'..'9']) then
    begin
      Result.TokenType := ttNumber;
      Result.Value := ReadNumber;
      Exit;
    end;
  end;
  
  if CurrentChar = '"' then
  begin
    Result.TokenType := ttString;
    Result.Value := ReadString;
    Exit;
  end;
  
  if CurrentChar in ['A'..'Z', 'a'..'z', '_'] then
  begin
    Ident := ReadIdent;
    
    // Keywords
    if Ident = 'PRINT' then Result.TokenType := ttPRINT
    else if Ident = 'INPUT' then Result.TokenType := ttINPUT
    else if Ident = 'LET' then Result.TokenType := ttLET
    else if Ident = 'IF' then Result.TokenType := ttIF
    else if Ident = 'THEN' then Result.TokenType := ttTHEN
    else if Ident = 'ELSE' then Result.TokenType := ttELSE
    else if Ident = 'ELSEIF' then Result.TokenType := ttELSEIF
    else if Ident = 'END' then Result.TokenType := ttEND
    else if Ident = 'FOR' then Result.TokenType := ttFOR
    else if Ident = 'TO' then Result.TokenType := ttTO
    else if Ident = 'STEP' then Result.TokenType := ttSTEP
    else if Ident = 'NEXT' then Result.TokenType := ttNEXT
    else if Ident = 'WHILE' then Result.TokenType := ttWHILE
    else if Ident = 'WEND' then Result.TokenType := ttWEND
    else if Ident = 'DO' then Result.TokenType := ttDO
    else if Ident = 'LOOP' then Result.TokenType := ttLOOP
    else if Ident = 'GOTO' then Result.TokenType := ttGOTO
    else if Ident = 'GOSUB' then Result.TokenType := ttGOSUB
    else if Ident = 'RETURN' then Result.TokenType := ttRETURN
    else if Ident = 'DIM' then Result.TokenType := ttDIM
    else if Ident = 'AS' then Result.TokenType := ttAS
    else if Ident = 'INTEGER' then Result.TokenType := ttINTEGER
    else if Ident = 'SINGLE' then Result.TokenType := ttSINGLE
    else if Ident = 'DOUBLE' then Result.TokenType := ttDOUBLE
    else if Ident = 'STRING' then Result.TokenType := ttSTRING_TYPE
    else if Ident = 'REM' then
    begin
      { A remark is everything to the end of the line, whatever it holds -
        read here like an apostrophe comment. As a token, a "!" or "?" in
        the text ended the remark early and the rest ran as code. }
      while not (CurrentChar in [#10, #13, #0]) do
        Advance;
      Result.TokenType := ttEOL;
    end
    else if Ident = 'CLS' then Result.TokenType := ttCLS
    else if Ident = 'LOCATE' then Result.TokenType := ttLOCATE
    else if Ident = 'COLOR' then Result.TokenType := ttCOLOR
    else if Ident = 'SCREEN' then Result.TokenType := ttSCREEN
    else if Ident = 'AND' then Result.TokenType := ttAND
    else if Ident = 'OR' then Result.TokenType := ttOR
    else if Ident = 'NOT' then Result.TokenType := ttNOT
    else if Ident = 'XOR' then Result.TokenType := ttXOR
    else if Ident = 'MOD' then Result.TokenType := ttMod
    else if Ident = 'SUB' then Result.TokenType := ttSUB
    else if Ident = 'FUNCTION' then Result.TokenType := ttFUNCTION
    else if Ident = 'EXIT' then Result.TokenType := ttEXIT
    else if Ident = 'CALL' then Result.TokenType := ttCALL
    else if Ident = 'STATIC' then Result.TokenType := ttSTATIC
    else if Ident = 'SHARED' then Result.TokenType := ttSHARED
    else if Ident = 'SELECT' then Result.TokenType := ttSELECT
    else if Ident = 'CASE' then Result.TokenType := ttCASE
    else if Ident = 'IS' then Result.TokenType := ttIS
    else
    begin
      Result.TokenType := ttIdent;
      Result.Value := Ident;
    end;
    Exit;
  end;
  
  case CurrentChar of
    '+': begin Advance; Result.TokenType := ttPlus; end;
    '-': begin Advance; Result.TokenType := ttMinus; end;
    '*': begin Advance; Result.TokenType := ttMult; end;
    '/': begin Advance; Result.TokenType := ttDiv; end;
    '\': begin Advance; Result.TokenType := ttIntDiv; end; // integer division - was lexed as plain /
    '^': begin Advance; Result.TokenType := ttPower; end;
    '(': begin Advance; Result.TokenType := ttLParen; end;
    ')': begin Advance; Result.TokenType := ttRParen; end;
    ',': begin Advance; Result.TokenType := ttComma; end;
    ';': begin Advance; Result.TokenType := ttSemicolon; end;
    '=': begin Advance; Result.TokenType := ttEQ; end;
    '<':
      begin
        Advance;
        if CurrentChar = '=' then
        begin
          Advance;
          Result.TokenType := ttLE;
        end
        else if CurrentChar = '>' then
        begin
          Advance;
          Result.TokenType := ttNE;
        end
        else
          Result.TokenType := ttLT;
      end;
    '>':
      begin
        Advance;
        if CurrentChar = '=' then
        begin
          Advance;
          Result.TokenType := ttGE;
        end
        else
          Result.TokenType := ttGT;
      end;
  else
    { A character that means nothing here is an error. It used to become an
      end-of-line token, silently splitting the statement - "a = 5 \ 2" ran
      as "a = 5". }
    raise EQBasicError.Create('Unexpected character "' + CurrentChar + '"', FLine, FCol);
  end;
end;

{ TQBasicInterpreter }

constructor TQBasicInterpreter.Create;
begin
  inherited Create;
  FPos := 0;
  SetLength(FTokens, 0);
  SetLength(FVariables, 0);
  SetLength(FForStack, 0);
  SetLength(FGosubStack, 0);
  SetLength(FLabels, 0);
  SetLength(FSubPrograms, 0);
  SetLength(FCallStack, 0);
  SetLength(FBuiltins, 0);
  FInSubProgram := False;
  FCurrentSubIdx := -1;
  FRunning := False;
  FStopRequested := False;
  RegisterBuiltins;
end;

destructor TQBasicInterpreter.Destroy;
begin
  Reset;
  inherited Destroy;
end;

procedure TQBasicInterpreter.Reset;
begin
  SetLength(FTokens, 0);
  SetLength(FVariables, 0);
  SetLength(FForStack, 0);
  SetLength(FGosubStack, 0);
  SetLength(FLabels, 0);
  SetLength(FSubPrograms, 0);
  SetLength(FCallStack, 0);
  FPos := 0;
  FInSubProgram := False;
  FCurrentSubIdx := -1;
  FRunning := False;
  FStopRequested := False;
  SetLength(FData, 0);
  FDataPtr := 0;
end;

procedure TQBasicInterpreter.LoadProgram(const ACode: string);
var
  Lexer: TQBasicLexer;
  Token: TToken;
begin
  Reset;
  
  Lexer := TQBasicLexer.Create(ACode);
  try
    repeat
      Token := Lexer.GetNextToken;
      SetLength(FTokens, Length(FTokens) + 1);
      FTokens[High(FTokens)] := Token;
    until Token.TokenType = ttEOF;
  finally
    Lexer.Free;
  end;
  
  ScanLabels;
  ScanData;
  ScanSubPrograms;
end;

function TQBasicInterpreter.CurrentToken: TToken;
begin
  if FPos < Length(FTokens) then
    Result := FTokens[FPos]
  else
  begin
    Result.TokenType := ttEOF;
    Result.Value := '';
    Result.Line := 0;
    Result.Col := 0;
  end;
end;

function TQBasicInterpreter.PeekToken(Offset: Integer): TToken;
begin
  if FPos + Offset < Length(FTokens) then
    Result := FTokens[FPos + Offset]
  else
  begin
    Result.TokenType := ttEOF;
    Result.Value := '';
  end;
end;

procedure TQBasicInterpreter.Advance;
begin
  Inc(FPos);
end;

function TQBasicInterpreter.Match(AType: TTokenType): Boolean;
begin
  Result := CurrentToken.TokenType = AType;
  if Result then
    Advance;
end;

procedure TQBasicInterpreter.Expect(AType: TTokenType);
begin
  if not Match(AType) then
  begin
    if CurrentToken.TokenType in [ttIdent, ttNumber, ttString] then
      RaiseErr('Expected ' + TokenName(AType) + ' but found "' + CurrentToken.Value + '"')
    else
      RaiseErr('Expected ' + TokenName(AType) + ' but found ' + TokenName(CurrentToken.TokenType));
  end;
end;

function TQBasicInterpreter.GetVariable(const AName: string): Integer;
var
  i: Integer;
begin
  // Check local variables first
  if FInSubProgram and (FCurrentSubIdx >= 0) then
  begin
    for i := 0 to High(FSubPrograms[FCurrentSubIdx].LocalVars) do
      if FSubPrograms[FCurrentSubIdx].LocalVars[i].Name = AName then
        Exit(-(i + 2));  // Use -2, -3, -4... to avoid conflict with -1 (not found)
  end;
  
  // Check global variables
  for i := 0 to High(FVariables) do
    if FVariables[i].Name = AName then
      Exit(i);
      
  Result := -1;  // Not found
end;

function TQBasicInterpreter.GetVariableValue(const AName: string): Double;
var
  Idx: Integer;
begin
  Idx := GetVariable(AName);
  if Idx >= 0 then
    Result := FVariables[Idx].NumValue
  else if Idx < -1 then
  begin
    Idx := -(Idx + 2);  // Decode: -2 -> 0, -3 -> 1, etc.
    Result := FSubPrograms[FCurrentSubIdx].LocalVars[Idx].NumValue;
  end
  else
    Result := 0;
end;

function TQBasicInterpreter.GetVariableStrValue(const AName: string): string;
var
  Idx: Integer;
begin
  Idx := GetVariable(AName);
  if Idx >= 0 then
    Result := FVariables[Idx].StrValue
  else if Idx < -1 then
  begin
    Idx := -(Idx + 2);
    Result := FSubPrograms[FCurrentSubIdx].LocalVars[Idx].StrValue;
  end
  else
    Result := '';
end;

procedure TQBasicInterpreter.SetVariable(const AName: string; AValue: Double;
  const AStrValue: string; AIsString: Boolean; ForceLocal: Boolean = False);
var
  Idx: Integer;
begin
  Idx := GetVariable(AName);
  
  // If ForceLocal and we're in a subprogram, always create/use local variable
  if ForceLocal and FInSubProgram and (FCurrentSubIdx >= 0) then
  begin
    if Idx < -1 then
    begin
      // Local already exists, update it
      Idx := -(Idx + 2);
      with FSubPrograms[FCurrentSubIdx].LocalVars[Idx] do
      begin
        IsString := AIsString;
        NumValue := AValue;
        StrValue := AStrValue;
      end;
    end
    else
    begin
      // Create new local (even if global exists)
      SetLength(FSubPrograms[FCurrentSubIdx].LocalVars,
                Length(FSubPrograms[FCurrentSubIdx].LocalVars) + 1);
      Idx := High(FSubPrograms[FCurrentSubIdx].LocalVars);
      with FSubPrograms[FCurrentSubIdx].LocalVars[Idx] do
      begin
        Name := AName;
        IsString := AIsString;
        NumValue := AValue;
        StrValue := AStrValue;
      end;
    end;
    Exit;
  end;
  
  if Idx < -1 then
  begin
    // Local variable
    Idx := -(Idx + 2);
    with FSubPrograms[FCurrentSubIdx].LocalVars[Idx] do
    begin
      IsString := AIsString;
      NumValue := AValue;
      StrValue := AStrValue;
    end;
  end
  else if Idx >= 0 then
  begin
    // Existing global
    FVariables[Idx].IsString := AIsString;
    FVariables[Idx].NumValue := AValue;
    FVariables[Idx].StrValue := AStrValue;
  end
  else
  begin
    // New variable
    if FInSubProgram and (FCurrentSubIdx >= 0) then
    begin
      // Create local
      SetLength(FSubPrograms[FCurrentSubIdx].LocalVars,
                Length(FSubPrograms[FCurrentSubIdx].LocalVars) + 1);
      Idx := High(FSubPrograms[FCurrentSubIdx].LocalVars);
      with FSubPrograms[FCurrentSubIdx].LocalVars[Idx] do
      begin
        Name := AName;
        IsString := AIsString;
        NumValue := AValue;
        StrValue := AStrValue;
      end;
    end
    else
    begin
      // Create global
      SetLength(FVariables, Length(FVariables) + 1);
      Idx := High(FVariables);
      FVariables[Idx].Name := AName;
      FVariables[Idx].IsString := AIsString;
      FVariables[Idx].NumValue := AValue;
      FVariables[Idx].StrValue := AStrValue;
    end;
  end;
end;

procedure TQBasicInterpreter.SetGlobalVariable(const AName: string; AValue: Double);
var
  i: Integer;
begin
  for i := 0 to High(FVariables) do
    if FVariables[i].Name = UpperCase(AName) then
    begin
      FVariables[i].NumValue := AValue;
      FVariables[i].IsString := False;
      Exit;
    end;
  
  SetLength(FVariables, Length(FVariables) + 1);
  FVariables[High(FVariables)].Name := UpperCase(AName);
  FVariables[High(FVariables)].NumValue := AValue;
  FVariables[High(FVariables)].IsString := False;
end;

procedure TQBasicInterpreter.SetGlobalStringVariable(const AName: string; const AValue: string);
var
  i: Integer;
begin
  for i := 0 to High(FVariables) do
    if FVariables[i].Name = UpperCase(AName) then
    begin
      FVariables[i].StrValue := AValue;
      FVariables[i].IsString := True;
      Exit;
    end;
  
  SetLength(FVariables, Length(FVariables) + 1);
  FVariables[High(FVariables)].Name := UpperCase(AName);
  FVariables[High(FVariables)].StrValue := AValue;
  FVariables[High(FVariables)].IsString := True;
end;

function TQBasicInterpreter.GetGlobalVariable(const AName: string): Double;
var
  i: Integer;
begin
  for i := 0 to High(FVariables) do
    if FVariables[i].Name = UpperCase(AName) then
      Exit(FVariables[i].NumValue);
  Result := 0;
end;

function TQBasicInterpreter.GetGlobalStringVariable(const AName: string): string;
var
  i: Integer;
begin
  for i := 0 to High(FVariables) do
    if FVariables[i].Name = UpperCase(AName) then
      Exit(FVariables[i].StrValue);
  Result := '';
end;

function TQBasicInterpreter.IsStringExpr: Boolean;
var
  VarIdx: Integer;
  VarName: string;
begin
  Result := False;
  if CurrentToken.TokenType = ttString then
    Result := True
  else if CurrentToken.TokenType = ttIdent then
  begin
    VarName := CurrentToken.Value;
    if (Length(VarName) > 0) and (VarName[Length(VarName)] = '$') then
      Result := True
    else
    begin
      VarIdx := GetVariable(VarName);
      if VarIdx >= 0 then
        Result := FVariables[VarIdx].IsString
      else if VarIdx < -1 then
      begin
        VarIdx := -(VarIdx + 2);
        Result := FSubPrograms[FCurrentSubIdx].LocalVars[VarIdx].IsString;
      end;
    end;
  end;
end;

function TQBasicInterpreter.EvaluateFactor: Double;
var
  VarName: string;
  VarIdx: Integer;
  BuiltinIdx: Integer;
  Idx: TIntArray;
begin
  Result := 0;
  
  if Match(ttNumber) then
    Result := StrToFloatDef(FTokens[FPos - 1].Value, 0)
  else if CurrentToken.TokenType = ttIdent then
  begin
    VarName := CurrentToken.Value;
    
    if (VarName = 'UBOUND') or (VarName = 'LBOUND') then
      Result := EvaluateBound(VarName = 'UBOUND')
    // Check for function call or array element
    else if PeekToken.TokenType = ttLParen then
    begin
      BuiltinIdx := FindBuiltin(VarName);
      if BuiltinIdx >= 0 then
        Result := CallFunction(VarName)
      else if FindSubProgram(VarName) >= 0 then
        Result := CallFunction(VarName)
      else if IsArrayVar(VarName) then
      begin
        Advance;
        Idx := ParseIndices;
        Result := GetArrayNum(VarName, Idx);
      end
      else   // used to return 0 silently, hiding typos
        RaiseErr('Unknown function or array: ' + VarName);
    end
    else
    begin
      { a numeric built-in that takes no arguments may be written without
        brackets: TIMER, GETWIDTH - unless a variable already has the name }
      if GetVariable(VarName) = -1 then
      begin
        BuiltinIdx := FindBuiltin(VarName);
        if (BuiltinIdx >= 0) and (FBuiltins[BuiltinIdx].MinArgs = 0) and
           not FBuiltins[BuiltinIdx].IsProc and not FBuiltins[BuiltinIdx].ReturnsString then
        begin
          Result := CallFunction(VarName);
          Exit;
        end;
        { a user FUNCTION too: PRINT Loopy used to read an unset variable
          and print 0. Inside the function its own name is its result
          variable, so GetVariable finds it and this call is not made. }
        BuiltinIdx := FindSubProgram(VarName);
        if (BuiltinIdx >= 0) and FSubPrograms[BuiltinIdx].IsFunction then
        begin
          Result := CallFunction(VarName);
          Exit;
        end;
      end;
      Advance;
      VarIdx := GetVariable(VarName);
      if VarIdx >= 0 then
        Result := FVariables[VarIdx].NumValue
      else if VarIdx < -1 then
      begin
        VarIdx := -(VarIdx + 2);
        Result := FSubPrograms[FCurrentSubIdx].LocalVars[VarIdx].NumValue;
      end;
    end;
  end
  else if Match(ttLParen) then
  begin
    { the full expression, comparisons and AND/OR included. EvaluateExpr
      stopped below comparisons, so IF (a > b) AND (c < d) failed. }
    Result := EvaluateLogical;
    Expect(ttRParen);
  end
  else if Match(ttString) then
    Result := 0
  else
    { Never return without consuming a token: callers loop until the end of
      the statement, so a factor that stays put hangs the interpreter. That is
      how IF ... THEN PRINT "a" ELSE ... used to loop forever. }
    RaiseErr('Unexpected ' + TokenName(CurrentToken.TokenType));
end;

function TQBasicInterpreter.EvaluateUnary: Double;
begin
  { EvaluateUnary() with brackets: in objfpc mode the bare name inside the
    function means its RESULT variable, not a recursive call }
  if Match(ttMinus) then
    Result := -EvaluateUnary()
  else if Match(ttPlus) then
    Result := EvaluateUnary()
  else if Match(ttNOT) then
  begin
    if EvaluateUnary() <> 0 then
      Result := 0
    else
      Result := -1;
  end
  else
    Result := EvaluatePower;
end;

function TQBasicInterpreter.EvaluateTerm: Double;
var
  Op: TTokenType;
  RightVal: Double;
begin
  Result := EvaluateUnary;
  while CurrentToken.TokenType in [ttMult, ttDiv, ttIntDiv, ttMod] do   // ^ is in EvaluatePower
  begin
    Op := CurrentToken.TokenType;
    Advance;
    case Op of
      ttMult: Result := Result * EvaluateUnary;
      ttDiv: 
        begin
          RightVal := EvaluateUnary;
          if RightVal <> 0 then
            Result := Result / RightVal
          else
            raise EQBasicError.Create('Division by zero', CurrentToken.Line, CurrentToken.Col);
        end;
      ttIntDiv:
        begin
          { QBasic's \ rounds both sides to whole numbers, divides and drops
            the fraction: 7 \ 2 = 3, -7 \ 2 = -3 }
          RightVal := EvaluateUnary;
          if Round(RightVal) <> 0 then
            Result := Round(Result) div Round(RightVal)
          else
            raise EQBasicError.Create('Division by zero', CurrentToken.Line, CurrentToken.Col);
        end;
      ttMod:
        begin
          RightVal := EvaluateUnary;
          if Trunc(RightVal) <> 0 then
            Result := Trunc(Result) mod Trunc(RightVal)
          else
            raise EQBasicError.Create('Division by zero', CurrentToken.Line, CurrentToken.Col);
        end;
    end;
  end;
end;

function TQBasicInterpreter.EvaluateExpr: Double;
begin
  Result := EvaluateTerm;
  while CurrentToken.TokenType in [ttPlus, ttMinus] do
  begin
    if Match(ttPlus) then
      Result := Result + EvaluateTerm
    else if Match(ttMinus) then
      Result := Result - EvaluateTerm;
  end;
end;

function TQBasicInterpreter.EvaluateComparison: Double;
var
  Left: Double;
  Op: TTokenType;
  LS, RS: string;
  B: Boolean;
begin
  { Strings compare as strings. Only numbers were compared before, and a
    string's numeric value is 0, so every string equalled every other:
    IF f$ = "" was always true and "abc" < "abd" was false. }
  if IsStringExpr then
  begin
    LS := EvaluateStrExpr();
    if not (CurrentToken.TokenType in [ttEQ, ttNE, ttLT, ttLE, ttGT, ttGE]) then
      RaiseErr('Type mismatch: a string was used where a number is needed');
    Op := CurrentToken.TokenType;
    Advance;
    RS := EvaluateStrExpr();
    case Op of
      ttEQ: B := LS = RS;
      ttNE: B := LS <> RS;
      ttLT: B := LS < RS;
      ttLE: B := LS <= RS;
      ttGT: B := LS > RS;
    else
      B := LS >= RS;
    end;
    if B then Result := -1 else Result := 0;
    Exit;
  end;

  Left := EvaluateExpr;
  if CurrentToken.TokenType in [ttEQ, ttNE, ttLT, ttLE, ttGT, ttGE] then
  begin
    Op := CurrentToken.TokenType;
    Advance;
    case Op of
      ttEQ: if Abs(Left - EvaluateExpr) < 0.00001 then Result := -1 else Result := 0;
      ttNE: if Abs(Left - EvaluateExpr) >= 0.00001 then Result := -1 else Result := 0;
      ttLT: if Left < EvaluateExpr then Result := -1 else Result := 0;
      ttLE: if Left <= EvaluateExpr then Result := -1 else Result := 0;
      ttGT: if Left > EvaluateExpr then Result := -1 else Result := 0;
      ttGE: if Left >= EvaluateExpr then Result := -1 else Result := 0;
    else
      Result := Left;
    end;
  end
  else
    Result := Left;
end;

function TQBasicInterpreter.EvaluateLogical: Double;
var
  Left: Double;
begin
  Left := EvaluateComparison;
  while CurrentToken.TokenType in [ttAND, ttOR, ttXOR] do
  begin
    if Match(ttAND) then
      Left := Trunc(Left) and Trunc(EvaluateComparison)
    else if Match(ttOR) then
      Left := Trunc(Left) or Trunc(EvaluateComparison)
    else if Match(ttXOR) then
      Left := Trunc(Left) xor Trunc(EvaluateComparison);
  end;
  Result := Left;
end;

function TQBasicInterpreter.EvaluateStrExpr: string;
var
  VarName: string;
  VarIdx: Integer;
  Idx: TIntArray;
  Tail: string;
begin
  if Match(ttString) then
    Result := FTokens[FPos - 1].Value
  else if CurrentToken.TokenType = ttIdent then
  begin
    VarName := CurrentToken.Value;
    
    // Check for string function
    if PeekToken.TokenType = ttLParen then
    begin
      if IsArrayVar(VarName) then
      begin
        Advance;
        Idx := ParseIndices;
        Result := GetArrayStr(VarName, Idx);
      end
      else if (Length(VarName) > 0) and (VarName[Length(VarName)] = '$') then
      begin
        if (FindBuiltin(VarName) < 0) and (FindSubProgram(VarName) < 0) then
          RaiseErr('Unknown function or array: ' + VarName);
        Result := CallStringFunction(VarName);
      end
      else
      begin
        VarIdx := FindBuiltin(VarName);
        if (VarIdx >= 0) and FBuiltins[VarIdx].ReturnsString then
          Result := CallStringFunction(VarName)
        else
          Result := FloatToStr(EvaluateLogical);
      end;
    end
    else
    begin
      { a string built-in without arguments: DATE$, TIME$ }
      VarIdx := FindBuiltin(VarName);
      if (GetVariable(VarName) = -1) and
         (((VarIdx >= 0) and FBuiltins[VarIdx].ReturnsString and (FBuiltins[VarIdx].MinArgs = 0)) or
          ((FindSubProgram(VarName) >= 0) and FSubPrograms[FindSubProgram(VarName)].IsFunction)) then
      begin
        Result := CallStringFunction(VarName);
        while Match(ttPlus) do
        begin
          Tail := EvaluateStrExpr();   // see the concatenation note below
          Result := Result + Tail;
        end;
        Exit;
      end;
      Advance;
      VarIdx := GetVariable(VarName);
      if VarIdx >= 0 then
      begin
        if FVariables[VarIdx].IsString then
          Result := FVariables[VarIdx].StrValue
        else
          Result := FloatToStr(FVariables[VarIdx].NumValue);
      end
      else if VarIdx < -1 then
      begin
        VarIdx := -(VarIdx + 2);
        with FSubPrograms[FCurrentSubIdx].LocalVars[VarIdx] do
        begin
          if IsString then
            Result := StrValue
          else
            Result := FloatToStr(NumValue);
        end;
      end
      else
        Result := '';
    end;
  end
  else
    Result := FloatToStr(EvaluateLogical);
  
  { String concatenation. EvaluateStrExpr() MUST have its brackets: in objfpc
    mode the bare name inside this function is its own result variable, not a
    call. The original "Result := Result + EvaluateStrExpr" therefore doubled
    the text so far and never read the tail: y$ + "!" gave "aa!", and the
    unread "!" was then printed as a separate PRINT item. }
  while Match(ttPlus) do
  begin
    Tail := EvaluateStrExpr();
    Result := Result + Tail;
  end;
end;

procedure TQBasicInterpreter.ScanLabels;
var
  i: Integer;
begin
  SetLength(FLabels, 0);
  for i := 0 to High(FTokens) - 1 do
  begin
    if (FTokens[i].TokenType = ttIdent) and 
       (FTokens[i + 1].TokenType = ttColon) then
    begin
      SetLength(FLabels, Length(FLabels) + 1);
      FLabels[High(FLabels)].Name := FTokens[i].Value;
      FLabels[High(FLabels)].Position := i + 2;
    end
    else if (FTokens[i].TokenType = ttNumber) and
            ((i = 0) or (FTokens[i - 1].TokenType = ttEOL)) then
    begin
      { a GW-BASIC line number - GOTO, GOSUB and RESTORE can target it.
        The number itself is skipped harmlessly when the line runs. }
      SetLength(FLabels, Length(FLabels) + 1);
      FLabels[High(FLabels)].Name := FTokens[i].Value;
      FLabels[High(FLabels)].Position := i + 1;
    end;
  end;
end;

procedure TQBasicInterpreter.ScanSubPrograms;
var
  i, j: Integer;
  SubName, ParamName: string;
  IsFunc: Boolean;
begin
  SetLength(FSubPrograms, 0);
  i := 0;
  
  while i < Length(FTokens) do
  begin
    if FTokens[i].TokenType in [ttSUB, ttFUNCTION] then
    begin
      IsFunc := FTokens[i].TokenType = ttFUNCTION;
      Inc(i);
      
      if (i < Length(FTokens)) and (FTokens[i].TokenType = ttIdent) then
      begin
        SubName := FTokens[i].Value;
        Inc(i);
        
        SetLength(FSubPrograms, Length(FSubPrograms) + 1);
        j := High(FSubPrograms);
        FSubPrograms[j].Name := SubName;
        FSubPrograms[j].IsFunction := IsFunc;
        SetLength(FSubPrograms[j].Parameters, 0);
        SetLength(FSubPrograms[j].LocalVars, 0);
        
        // Parse parameters
        if (i < Length(FTokens)) and (FTokens[i].TokenType = ttLParen) then
        begin
          Inc(i);
          while (i < Length(FTokens)) and (FTokens[i].TokenType <> ttRParen) do
          begin
            if FTokens[i].TokenType = ttIdent then
            begin
              ParamName := FTokens[i].Value;
              SetLength(FSubPrograms[j].Parameters, Length(FSubPrograms[j].Parameters) + 1);
              with FSubPrograms[j].Parameters[High(FSubPrograms[j].Parameters)] do
              begin
                Name := ParamName;
                IsString := (Length(ParamName) > 0) and (ParamName[Length(ParamName)] = '$');
                ByRef := False;
              end;
            end;
            Inc(i);
          end;
          if (i < Length(FTokens)) and (FTokens[i].TokenType = ttRParen) then
            Inc(i);
        end;
        
        FSubPrograms[j].StartPos := i;
        
        // Find END SUB/FUNCTION
        while (i < Length(FTokens)) and
              not ((FTokens[i].TokenType = ttEND) and
                   (i + 1 < Length(FTokens)) and
                   (FTokens[i + 1].TokenType in [ttSUB, ttFUNCTION])) do
          Inc(i);
        
        FSubPrograms[j].EndPos := i;
      end;
    end;
    Inc(i);
  end;
end;

function TQBasicInterpreter.FindLabel(const ALabel: string): Integer;
var
  i: Integer;
begin
  for i := 0 to High(FLabels) do
    if FLabels[i].Name = ALabel then
      Exit(FLabels[i].Position);
  Result := -1;
end;

function TQBasicInterpreter.FindSubProgram(const AName: string): Integer;
var
  i: Integer;
begin
  for i := 0 to High(FSubPrograms) do
    if FSubPrograms[i].Name = AName then
      Exit(i);
  Result := -1;
end;

function TQBasicInterpreter.FindBuiltin(const AName: string): Integer;
var
  i: Integer;
begin
  for i := 0 to High(FBuiltins) do
    if FBuiltins[i].Name = AName then
      Exit(i);
  Result := -1;
end;

procedure TQBasicInterpreter.ExecutePRINT;
var
  NewLine: Boolean;
  Value: string;
  NumV: Double;
  Line: string;
begin
  NewLine := True;
  Line := '';
  { ELSE ends the statement too: IF c THEN PRINT "a" ELSE PRINT "b" }
  while not (CurrentToken.TokenType in [ttEOL, ttEOF, ttColon, ttELSE]) do
  begin
    if Match(ttSemicolon) then
      NewLine := False
    else if Match(ttComma) then
    begin
      Line := Line + #9;
      NewLine := False;
    end
    else
    begin
      if IsStringExpr then
        Value := EvaluateStrExpr
      else
      begin
        { QBasic prints a number with a sign position - a space when it is
          not negative - and a trailing space, so PRINT "x"; 5 gives "x 5 " }
        NumV := EvaluateLogical;
        if NumV >= 0 then
          Value := ' ' + FloatToStr(NumV) + ' '
        else
          Value := FloatToStr(NumV) + ' ';
      end;
      Line := Line + Value;
      NewLine := True;
    end;
  end;
  { A PRINT ending in ; or , keeps the next PRINT on the same line. The host
    receives whole lines, so the text waits here until a line is finished. }
  Line := FPrintPending + Line;
  if NewLine then
  begin
    FPrintPending := '';
    if Assigned(FOnPrint) then
      FOnPrint(Line);
  end
  else
    FPrintPending := Line;
end;

procedure TQBasicInterpreter.ExecuteINPUT;
var
  Prompt, Input: string;
  L: TLValue;
begin
  Prompt := '';
  if Match(ttString) then
  begin
    Prompt := FTokens[FPos - 1].Value;
    Match(ttSemicolon);
    Match(ttComma);
  end;
  
  if CurrentToken.TokenType = ttIdent then
  begin
    L := ParseLValue;            // array elements too: INPUT a(i)
    Input := '';
    if Assigned(FOnInput) then
      FOnInput(Prompt, Input);
    if LValueIsString(L) then
      SetLValueStr(L, Input)
    else
      SetLValueNum(L, StrToFloatDef(Input, 0));
  end;
end;

procedure TQBasicInterpreter.ExecuteLET;
var
  L: TLValue;
  NumV: Double;
  StrV: string;
begin
  L := ParseLValue;
  if not Match(ttEQ) then
  begin
    if L.HasIdx then
      RaiseErr('Unknown procedure: ' + L.Name)
    else
      RaiseErr('Unknown statement: ' + L.Name);
  end;
  { value first, then store - evaluating it can create variables, which
    would move a pointer taken earlier }
  if LValueIsString(L) then
  begin
    StrV := EvaluateStrExpr;
    SetLValueStr(L, StrV);
  end
  else
  begin
    NumV := EvaluateLogical;
    SetLValueNum(L, NumV);
  end;
end;

procedure TQBasicInterpreter.ExecuteIF;
var
  Condition: Boolean;
  IsBlockIF: Boolean;
  NestLevel: Integer;
begin
  Condition := EvaluateLogical <> 0;
  
  if Match(ttTHEN) then
  begin
    // Check if this is a block IF (nothing after THEN on this line) or single-line IF
    IsBlockIF := CurrentToken.TokenType in [ttEOL, ttEOF];
    
    if IsBlockIF then
    begin
      // Multi-line block IF
      if Condition then
      begin
        // Execute statements until ELSE, ELSEIF, or END IF
        while FRunning and not FStopRequested and not FExitDo and not FExitFunc do
        begin
          if CurrentToken.TokenType = ttEOL then
          begin
            Advance;
            Continue;
          end;
          if CurrentToken.TokenType = ttEOF then
            Break;
          if CurrentToken.TokenType = ttELSE then
            Break;
          if CurrentToken.TokenType = ttELSEIF then
            Break;
          if (CurrentToken.TokenType = ttEND) and (PeekToken.TokenType = ttIF) then
            Break;
          ExecuteStatement;
        end;
        { EXIT DO inside this block: stop here, the DO skips to its LOOP }
        if FExitDo or FExitFunc then Exit;
        
        // Skip ELSE/ELSEIF blocks if we executed THEN block
        if CurrentToken.TokenType in [ttELSE, ttELSEIF] then
        begin
          NestLevel := 1;
          while (NestLevel > 0) and (CurrentToken.TokenType <> ttEOF) do
          begin
            if (CurrentToken.TokenType = ttIF) and IsBlockIFAt(FPos) then
              Inc(NestLevel)
            else if (CurrentToken.TokenType = ttEND) and (PeekToken.TokenType = ttIF) then
              Dec(NestLevel);
            Advance;
          end;
          // Skip the IF after END
          if CurrentToken.TokenType = ttIF then
            Advance;
        end
        else if (CurrentToken.TokenType = ttEND) and (PeekToken.TokenType = ttIF) then
        begin
          Advance; Advance; // Skip END IF
        end;
      end
      else
      begin
        // Skip THEN block, look for ELSE, ELSEIF, or END IF
        NestLevel := 1;
        while (NestLevel > 0) and (CurrentToken.TokenType <> ttEOF) do
        begin
          if CurrentToken.TokenType = ttEOL then
          begin
            Advance;
            Continue;
          end;
          
          { only a BLOCK IF nests. Counting every IF - as this did "for
            simplicity" - meant a single-line IF inside a skipped block raised
            the level with no END IF to lower it, and the skip ran off the end
            of the program: nothing after the block ever ran. }
          if (CurrentToken.TokenType = ttIF) and IsBlockIFAt(FPos) then
          begin
            Inc(NestLevel);
            Advance;
          end
          else if (CurrentToken.TokenType = ttEND) and (PeekToken.TokenType = ttIF) then
          begin
            Dec(NestLevel);
            if NestLevel = 0 then
            begin
              Advance; Advance; // Skip END IF
              Break;
            end;
            Advance; Advance;
          end
          else if (NestLevel = 1) and (CurrentToken.TokenType = ttELSEIF) then
          begin
            Advance; // Skip ELSEIF
            ExecuteIF; // Recursively handle ELSEIF
            Break;
          end
          else if (NestLevel = 1) and (CurrentToken.TokenType = ttELSE) then
          begin
            Advance; // Skip ELSE
            // Execute ELSE block
            while FRunning and not FStopRequested and not FExitDo and not FExitFunc do
            begin
              if CurrentToken.TokenType = ttEOL then
              begin
                Advance;
                Continue;
              end;
              if CurrentToken.TokenType = ttEOF then
                Break;
              if (CurrentToken.TokenType = ttEND) and (PeekToken.TokenType = ttIF) then
              begin
                Advance; Advance; // Skip END IF
                Break;
              end;
              ExecuteStatement;
            end;
            Break;
          end
          else
            Advance;
        end;
      end;
    end
    else
    begin
      // Single-line IF: IF condition THEN statement [ELSE statement]
      if Condition then
      begin
        { the stop checks matter: END, EXIT DO and the Stop button all leave
          the current token in place, so without them this spun forever -
          IF x THEN END hung the program }
        while not (CurrentToken.TokenType in [ttEOL, ttEOF, ttELSE]) and
              not FStopRequested and not FExitDo and not FExitFunc do
        begin
          if CurrentToken.TokenType = ttColon then
            Advance
          else
            ExecuteStatement;
        end;
        // Skip ELSE part
        if CurrentToken.TokenType = ttELSE then
        begin
          while not (CurrentToken.TokenType in [ttEOL, ttEOF]) do
            Advance;
        end;
      end
      else
      begin
        // Skip THEN block
        while not (CurrentToken.TokenType in [ttEOL, ttEOF, ttELSE]) do
          Advance;
        
        if Match(ttELSE) then
        begin
          while not (CurrentToken.TokenType in [ttEOL, ttEOF]) and
                not FStopRequested and not FExitDo and not FExitFunc do
          begin
            if CurrentToken.TokenType = ttColon then
              Advance
            else
              ExecuteStatement;
          end;
        end;
      end;
    end;
  end;
end;

procedure TQBasicInterpreter.ExecuteFOR;
var
  VarName: string;
  StartVal, EndVal, StepVal: Double;
  Idx: Integer;
begin
  if Match(ttIdent) then
  begin
    VarName := FTokens[FPos - 1].Value;
    Expect(ttEQ);
    StartVal := EvaluateLogical;
    SetVariable(VarName, StartVal, '', False);
    
    Expect(ttTO);
    EndVal := EvaluateLogical;
    
    if Match(ttSTEP) then
      StepVal := EvaluateLogical
    else
      StepVal := 1;

    { an empty range runs the body zero times - FOR i = 1 TO 0 used to run it once }
    if ((StepVal >= 0) and (StartVal > EndVal)) or
       ((StepVal < 0) and (StartVal < EndVal)) then
    begin
      SkipToBlockEnd(ttFOR, ttNEXT);
      if not Match(ttNEXT) then
        RaiseErr('FOR without NEXT');
      if CurrentToken.TokenType = ttIdent then Advance;   // NEXT i
      Exit;
    end;
    
    SetLength(FForStack, Length(FForStack) + 1);
    Idx := High(FForStack);
    FForStack[Idx].VarName := VarName;
    FForStack[Idx].EndVal := EndVal;
    FForStack[Idx].StepVal := StepVal;
    FForStack[Idx].LoopPos := FPos;
  end;
end;

procedure TQBasicInterpreter.ExecuteNEXT;
var
  VarName: string;
  ForIdx: Integer;
  NewVal: Double;
begin
  if Match(ttIdent) then
    VarName := FTokens[FPos - 1].Value
  else if Length(FForStack) > 0 then
    VarName := FForStack[High(FForStack)].VarName
  else
    Exit;
  
  ForIdx := High(FForStack);
  if (ForIdx >= 0) and (FForStack[ForIdx].VarName = VarName) then
  begin
    NewVal := GetVariableValue(VarName) + FForStack[ForIdx].StepVal;
    SetVariable(VarName, NewVal, '', False);
    
    if ((FForStack[ForIdx].StepVal > 0) and (NewVal <= FForStack[ForIdx].EndVal)) or
       ((FForStack[ForIdx].StepVal < 0) and (NewVal >= FForStack[ForIdx].EndVal)) then
      FPos := FForStack[ForIdx].LoopPos
    else
      SetLength(FForStack, Length(FForStack) - 1);
  end;
end;

procedure TQBasicInterpreter.ExecuteWHILE;
var
  CondPos: Integer;
  Condition: Boolean;
begin
  CondPos := FPos;  { position of condition (after WHILE keyword) }

  while True do
  begin
    FPos := CondPos;
    Condition := EvaluateLogical <> 0;

    if (not Condition) or FStopRequested then
    begin
      { Skip body to the MATCHING WEND - stopping at the first WEND found
        landed on an inner loop's WEND when loops were nested }
      SkipToBlockEnd(ttWHILE, ttWEND);
      Match(ttWEND);
      Break;
    end;

    { Execute body statements }
    while not (CurrentToken.TokenType in [ttWEND, ttEOF]) and not FStopRequested and not FExitDo and not FExitFunc do
    begin
      if CurrentToken.TokenType = ttEOL then
        Advance
      else
        ExecuteStatement;
    end;
    if FExitDo or FExitFunc then Exit;    // EXIT DO from inside this WHILE - the DO unwinds

    if not Match(ttWEND) then Break;

    { Yield to UI for responsiveness }
    if Assigned(FOnYield) then FOnYield();
  end;
end;

procedure TQBasicInterpreter.ExecuteWEND;
begin
  // Handled by WHILE
end;

{ DO [WHILE c | UNTIL c] ... LOOP [WHILE c | UNTIL c], with EXIT DO.
  This was a TODO stub: DO and LOOP did nothing, so the body ran exactly once.
  The body runs through ExecuteStatement, so nested loops complete inside it. }
procedure TQBasicInterpreter.ExecuteDO;
var
  Kind: Integer;          // 0 plain DO, 1 DO WHILE, 2 DO UNTIL
  CondPos, BodyPos: Integer;
  Go: Boolean;

  { from anywhere in the body: past the matching LOOP and its condition }
  procedure LeaveLoop;
  begin
    SkipToBlockEnd(ttDO, ttLOOP);
    if not Match(ttLOOP) then
      RaiseErr('DO without LOOP');
    while not (CurrentToken.TokenType in [ttEOL, ttEOF, ttColon]) do Advance;
  end;

begin
  Kind := 0;
  if Match(ttWHILE) then
    Kind := 1
  else if (CurrentToken.TokenType = ttIdent) and (CurrentToken.Value = 'UNTIL') then
  begin
    Advance;
    Kind := 2;
  end;
  CondPos := FPos;
  BodyPos := FPos;

  while True do
  begin
    if Kind <> 0 then
    begin
      FPos := CondPos;
      Go := EvaluateLogical <> 0;
      if Kind = 2 then Go := not Go;
      if (not Go) or FStopRequested then
      begin
        LeaveLoop;
        Exit;
      end;
    end
    else
      FPos := BodyPos;

    while not FStopRequested and not FExitDo and not FExitFunc do
    begin
      if CurrentToken.TokenType = ttLOOP then Break;
      if CurrentToken.TokenType = ttEOF then
        RaiseErr('DO without LOOP');
      if CurrentToken.TokenType = ttEOL then Advance else ExecuteStatement;
    end;
    if FExitFunc then Exit;          // unwinding to the function's end
    if FExitDo then
    begin
      FExitDo := False;
      LeaveLoop;
      Exit;
    end;
    if FStopRequested then Exit;

    Advance;   // LOOP
    if Match(ttWHILE) then
    begin
      if EvaluateLogical = 0 then Exit;
    end
    else if (CurrentToken.TokenType = ttIdent) and (CurrentToken.Value = 'UNTIL') then
    begin
      Advance;
      if EvaluateLogical <> 0 then Exit;
    end;

    if Assigned(FOnYield) then FOnYield();
  end;
end;

{ True when the IF token at P starts a BLOCK IF - nothing after THEN on its
  line. Single-line IFs have no END IF, and the IF of END IF is not an IF
  statement, so neither may count as nesting. }
function TQBasicInterpreter.IsBlockIFAt(P: Integer): Boolean;
begin
  Result := False;
  if (P > 0) and (FTokens[P - 1].TokenType = ttEND) then Exit;
  Inc(P);
  while (P < Length(FTokens)) and not (FTokens[P].TokenType in [ttTHEN, ttEOL, ttEOF]) do
    Inc(P);
  if (P < Length(FTokens)) and (FTokens[P].TokenType = ttTHEN) then
    Result := (P + 1 >= Length(FTokens)) or (FTokens[P + 1].TokenType in [ttEOL, ttEOF]);
end;

{ Moves FPos to the Close token matching the block we are inside, stepping
  over nested blocks of the same kind, and leaves FPos ON that token.
  Open tokens that are part of another statement don't count: the FOR of
  EXIT FOR, the DO of EXIT DO, and the WHILE of DO WHILE / LOOP WHILE. }
procedure TQBasicInterpreter.SkipToBlockEnd(OpenTok, CloseTok: TTokenType);
var
  Depth: Integer;
  Prev: TTokenType;
begin
  Depth := 0;
  while CurrentToken.TokenType <> ttEOF do
  begin
    if FPos > 0 then Prev := FTokens[FPos - 1].TokenType else Prev := ttEOL;
    if CurrentToken.TokenType = CloseTok then
    begin
      if Depth = 0 then Exit;
      Dec(Depth);
    end
    else if (CurrentToken.TokenType = OpenTok) and not (Prev in [ttEXIT, ttDO, ttLOOP]) then
      Inc(Depth);
    Advance;
  end;
end;

{ LOOP is handled by ExecuteDO. Reached on its own only by jumping into a
  loop body with GOTO - skip the statement rather than misread its condition. }
procedure TQBasicInterpreter.ExecuteLOOP;
begin
  while not (CurrentToken.TokenType in [ttEOL, ttEOF, ttColon]) do Advance;
end;

procedure TQBasicInterpreter.ExecuteGOTO;
var
  LabelPos: Integer;
begin
  if Match(ttIdent) or Match(ttNumber) then
  begin
    LabelPos := FindLabel(FTokens[FPos - 1].Value);
    if LabelPos >= 0 then
      FPos := LabelPos
    else
      raise EQBasicError.Create('Label not found: ' + FTokens[FPos - 1].Value,
        CurrentToken.Line, CurrentToken.Col);
  end;
end;

procedure TQBasicInterpreter.ExecuteGOSUB;
var
  LabelPos: Integer;
begin
  if Match(ttIdent) or Match(ttNumber) then
  begin
    LabelPos := FindLabel(FTokens[FPos - 1].Value);
    if LabelPos >= 0 then
    begin
      SetLength(FGosubStack, Length(FGosubStack) + 1);
      FGosubStack[High(FGosubStack)] := FPos;
      FPos := LabelPos;
    end
    else   // used to be ignored silently
      RaiseErr('Label not found: ' + FTokens[FPos - 1].Value);
  end;
end;

procedure TQBasicInterpreter.ExecuteRETURN;
begin
  if FInSubProgram then
  begin
    if Length(FCallStack) > 0 then
    begin
      with FCallStack[High(FCallStack)] do
      begin
        FPos := ReturnPos;
        FInSubProgram := WasInSub;
        FCurrentSubIdx := PrevSubIdx;
      end;
      SetLength(FCallStack, Length(FCallStack) - 1);
    end;
  end
  else if Length(FGosubStack) > 0 then
  begin
    FPos := FGosubStack[High(FGosubStack)];
    SetLength(FGosubStack, Length(FGosubStack) - 1);
  end;
end;

procedure TQBasicInterpreter.ExecuteDIM;
var
  VarName: string;
  IsString, IsShared, HasDims: Boolean;
  Lo, Hi: TIntArray;
  n: Integer;
  v: Double;
begin
  IsShared := Match(ttSHARED);
  repeat
    if not Match(ttIdent) then
      RaiseErr('Variable name expected after DIM');
    VarName := FTokens[FPos - 1].Value;
    HasDims := False;
    SetLength(Lo, 0);
    SetLength(Hi, 0);
    { DIM a(10), DIM a(3, 4), DIM a(1 TO 10) - bounds are inclusive and the
      default lower bound is 0, as QBasic's OPTION BASE 0 }
    if Match(ttLParen) then
    begin
      HasDims := True;
      repeat
        n := Length(Hi);
        SetLength(Lo, n + 1);
        SetLength(Hi, n + 1);
        v := EvaluateLogical;
        if Match(ttTO) then
        begin
          Lo[n] := Round(v);
          Hi[n] := Round(EvaluateLogical);
        end
        else
        begin
          Lo[n] := 0;
          Hi[n] := Round(v);
        end;
      until not Match(ttComma);
      Expect(ttRParen);
    end;

    IsString := (Length(VarName) > 0) and (VarName[Length(VarName)] = '$');
    if Match(ttAS) then
    begin
      if Match(ttINTEGER) or Match(ttSINGLE) or Match(ttDOUBLE) then
        IsString := False
      else if Match(ttSTRING_TYPE) then
        IsString := True
      else if CurrentToken.TokenType = ttIdent then
      begin
        Advance;             // LONG and other numeric type names
        IsString := False;
      end;
    end;

    if HasDims then
      DimArray(VarName, Lo, Hi, IsString, not IsShared)
    else
      SetVariable(VarName, 0, '', IsString, not IsShared);
  until not Match(ttComma);
end;

procedure TQBasicInterpreter.ExecuteCALL;
var
  SubName: string;
  SubIdx, i, NumI, StrI: Integer;
  Args: array of Double;
  StrArgs: array of string;
  BuiltinIdx: Integer;
begin
  if Match(ttIdent) then
  begin
    SubName := FTokens[FPos - 1].Value;
    
    // Check for builtin procedure
    BuiltinIdx := FindBuiltin(SubName);
    if (BuiltinIdx >= 0) and FBuiltins[BuiltinIdx].IsProc then
    begin
      CallBuiltinProc(SubName);
      Exit;
    end;
    
    SubIdx := FindSubProgram(SubName);
    if SubIdx < 0 then
      RaiseErr('Unknown procedure: ' + SubName);   // used to be ignored silently
    
    // Parse arguments
    SetLength(Args, 0);
    SetLength(StrArgs, 0);
    
    { Describe(x, 1), CALL Describe(x, 1) and QBasic's own Describe x, 1 -
      the unbracketed form used to pass no arguments at all }
    if Match(ttLParen) then
    begin
      if not Match(ttRParen) then
      begin
        repeat
          if IsStringExpr then
          begin
            SetLength(StrArgs, Length(StrArgs) + 1);
            StrArgs[High(StrArgs)] := EvaluateStrExpr;
          end
          else
          begin
            SetLength(Args, Length(Args) + 1);
            Args[High(Args)] := EvaluateLogical;
          end;
        until not Match(ttComma);
        Expect(ttRParen);
      end;
    end
    else if not (CurrentToken.TokenType in [ttEOL, ttEOF, ttColon, ttELSE]) then
    begin
      repeat
        if IsStringExpr then
        begin
          SetLength(StrArgs, Length(StrArgs) + 1);
          StrArgs[High(StrArgs)] := EvaluateStrExpr;
        end
        else
        begin
          SetLength(Args, Length(Args) + 1);
          Args[High(Args)] := EvaluateLogical;
        end;
      until not Match(ttComma);
    end;
    
    // Set up call
    SetLength(FCallStack, Length(FCallStack) + 1);
    with FCallStack[High(FCallStack)] do
    begin
      ReturnPos := FPos;
      SubName := SubName;
      WasInSub := FInSubProgram;
      PrevSubIdx := FCurrentSubIdx;
    end;
    
    FInSubProgram := True;
    FCurrentSubIdx := SubIdx;
    SetLength(FSubPrograms[SubIdx].LocalVars, 0);
    
    { Set parameters. Numbers and strings arrive in two separate lists, so
      each needs its own counter - indexing both by the parameter position
      lost b$ in SUB f (a, b$). }
    NumI := 0;
    StrI := 0;
    for i := 0 to High(FSubPrograms[SubIdx].Parameters) do
    begin
      if FSubPrograms[SubIdx].Parameters[i].IsString then
      begin
        if StrI < Length(StrArgs) then
          SetVariable(FSubPrograms[SubIdx].Parameters[i].Name, 0, StrArgs[StrI], True);
        Inc(StrI);
      end
      else
      begin
        if NumI < Length(Args) then
          SetVariable(FSubPrograms[SubIdx].Parameters[i].Name, Args[NumI], '', False);
        Inc(NumI);
      end;
    end;
    
    FPos := FSubPrograms[SubIdx].StartPos;
  end;
end;

procedure TQBasicInterpreter.ExecuteSUB;
begin
  // Skip to END SUB
  while not ((CurrentToken.TokenType = ttEND) and
             (PeekToken.TokenType = ttSUB)) and
        (CurrentToken.TokenType <> ttEOF) do
    Advance;
  Match(ttEND);
  Match(ttSUB);
end;

procedure TQBasicInterpreter.ExecuteFUNCTION;
begin
  // Skip to END FUNCTION
  while not ((CurrentToken.TokenType = ttEND) and
             (PeekToken.TokenType = ttFUNCTION)) and
        (CurrentToken.TokenType <> ttEOF) do
    Advance;
  Match(ttEND);
  Match(ttFUNCTION);
end;

{ SELECT CASE test
    CASE 1, 3 TO 5, IS > 10     values, ranges and comparisons
    CASE ELSE
  END SELECT
  Works for numbers and strings, nests, and allows CASE 3: PRINT "x" on one
  line. This was a TODO stub: the tokens after SELECT were skipped one by one
  and the test expression then failed as a statement. }
procedure TQBasicInterpreter.ExecuteSELECT;
var
  IsStr, Matched, ThisMatch: Boolean;
  TestNum: Double;
  TestStr: string;

  function AtClauseEnd: Boolean;
  begin
    Result := (CurrentToken.TokenType in [ttCASE, ttEOF]) or
              ((CurrentToken.TokenType = ttEND) and (PeekToken.TokenType = ttSELECT));
  end;

  { to the next CASE or END SELECT of THIS block, stepping over nested ones }
  procedure SkipClauseBody;
  var
    Depth: Integer;
  begin
    Depth := 0;
    while CurrentToken.TokenType <> ttEOF do
    begin
      if CurrentToken.TokenType = ttSELECT then
      begin
        Inc(Depth);
        Advance;
        if CurrentToken.TokenType = ttCASE then Advance;   // the CASE of SELECT CASE
        Continue;
      end;
      if (CurrentToken.TokenType = ttEND) and (PeekToken.TokenType = ttSELECT) then
      begin
        if Depth = 0 then Exit;
        Dec(Depth);
        Advance;
        Advance;
        Continue;
      end;
      if (CurrentToken.TokenType = ttCASE) and (Depth = 0) then Exit;
      Advance;
    end;
  end;

  function Compare(Op: TTokenType; const SA: string; A: Double): Boolean;
  begin
    Result := False;
    if IsStr then
      case Op of
        ttEQ: Result := TestStr = SA;
        ttNE: Result := TestStr <> SA;
        ttLT: Result := TestStr < SA;
        ttLE: Result := TestStr <= SA;
        ttGT: Result := TestStr > SA;
        ttGE: Result := TestStr >= SA;
      end
    else
      case Op of
        ttEQ: Result := TestNum = A;
        ttNE: Result := TestNum <> A;
        ttLT: Result := TestNum < A;
        ttLE: Result := TestNum <= A;
        ttGT: Result := TestNum > A;
        ttGE: Result := TestNum >= A;
      end;
  end;

  { one item of a CASE list }
  function MatchItem: Boolean;
  var
    Op: TTokenType;
    A, B: Double;
    SA, SB: string;
  begin
    A := 0;
    SA := '';
    if Match(ttIS) then
    begin
      Op := CurrentToken.TokenType;
      if not (Op in [ttEQ, ttNE, ttLT, ttLE, ttGT, ttGE]) then
        RaiseErr('Comparison expected after CASE IS');
      Advance;
      if IsStr then SA := EvaluateStrExpr() else A := EvaluateExpr;
      Result := Compare(Op, SA, A);
    end
    else if IsStr then
    begin
      SA := EvaluateStrExpr();
      if Match(ttTO) then
      begin
        SB := EvaluateStrExpr();
        Result := (TestStr >= SA) and (TestStr <= SB);
      end
      else
        Result := TestStr = SA;
    end
    else
    begin
      A := EvaluateExpr;
      if Match(ttTO) then
      begin
        B := EvaluateExpr;
        Result := (TestNum >= A) and (TestNum <= B);
      end
      else
        Result := TestNum = A;
    end;
  end;

begin
  Expect(ttCASE);
  TestNum := 0;
  TestStr := '';
  IsStr := IsStringExpr;
  if IsStr then TestStr := EvaluateStrExpr() else TestNum := EvaluateLogical;

  Matched := False;
  SkipClauseBody;                          // up to the first CASE
  while not FStopRequested do
  begin
    if CurrentToken.TokenType = ttEOF then
      RaiseErr('SELECT CASE without END SELECT');
    if CurrentToken.TokenType = ttEND then  // END SELECT
    begin
      Advance;
      Advance;
      Exit;
    end;

    Advance;                               // CASE
    if Match(ttELSE) then
      ThisMatch := not Matched
    else
    begin
      ThisMatch := False;
      repeat
        if MatchItem then ThisMatch := True;
      until not Match(ttComma);
      ThisMatch := ThisMatch and not Matched;   // only the first matching clause runs
    end;

    if ThisMatch then
    begin
      Matched := True;
      while not FStopRequested and not FExitDo and not FExitFunc and not AtClauseEnd do
        ExecuteStatement;
      if FExitDo or FExitFunc then Exit;
    end
    else
      SkipClauseBody;
  end;
end;

{ Runs user FUNCTION SubIdx and returns both views of its result, so numeric
  and string functions share one call path. CallStringFunction used to handle
  built-ins only, so a user FUNCTION NAME$ always returned "". }
procedure TQBasicInterpreter.RunUserFunction(SubIdx: Integer; const AName: string;
  const Args: array of Double; const StrArgs: array of string;
  var NumResult: Double; var StrResult: string);
var
  SavePos, SaveSubIdx, i, NumI, StrI, SaveForDepth: Integer;
  IsStrFunc: Boolean;
begin
  IsStrFunc := (Length(AName) > 0) and (AName[Length(AName)] = '$');
  SavePos := FPos;
  SaveSubIdx := FCurrentSubIdx;
  
  SetLength(FCallStack, Length(FCallStack) + 1);
  with FCallStack[High(FCallStack)] do
  begin
    ReturnPos := SavePos;
    WasInSub := FInSubProgram;
    PrevSubIdx := SaveSubIdx;
  end;
  
  FInSubProgram := True;
  FCurrentSubIdx := SubIdx;
  SetLength(FSubPrograms[SubIdx].LocalVars, 0);
  
  // Initialize return variable - a string for NAME$ functions
  SetVariable(AName, 0, '', IsStrFunc);
  
  { Set parameters - separate counters, as in ExecuteCALL. String arguments
    used to be dropped entirely for FUNCTIONs. }
  NumI := 0;
  StrI := 0;
  for i := 0 to High(FSubPrograms[SubIdx].Parameters) do
  begin
    if FSubPrograms[SubIdx].Parameters[i].IsString then
    begin
      if StrI < Length(StrArgs) then
        SetVariable(FSubPrograms[SubIdx].Parameters[i].Name, 0, StrArgs[StrI], True);
      Inc(StrI);
    end
    else
    begin
      if NumI < Length(Args) then
        SetVariable(FSubPrograms[SubIdx].Parameters[i].Name, Args[NumI], '', False);
      Inc(NumI);
    end;
  end;
  
  // Execute
  FPos := FSubPrograms[SubIdx].StartPos;
  Inc(FFuncDepth);
  SaveForDepth := Length(FForStack);
  while (FPos <= FSubPrograms[SubIdx].EndPos) and
        (FPos < Length(FTokens)) and
        not FStopRequested and not FExitFunc do
  begin
    if CurrentToken.TokenType = ttEOL then
      Advance
    else if (CurrentToken.TokenType = ttEND) and (PeekToken.TokenType = ttFUNCTION) then
      Break
    else if (CurrentToken.TokenType = ttEXIT) and (PeekToken.TokenType = ttFUNCTION) then
    begin
      Advance; Advance;
      Break;
    end
    else
      ExecuteStatement;
  end;
  
  // Get return value - read before the locals go out of scope
  NumResult := GetVariableValue(AName);
  StrResult := GetVariableStrValue(AName);
  
  // Restore state
  Dec(FFuncDepth);
  FExitFunc := False;
  { a FOR left open by EXIT FUNCTION must not stay on the stack for the
    caller's NEXT to find }
  if Length(FForStack) > SaveForDepth then
    SetLength(FForStack, SaveForDepth);
  FPos := FCallStack[High(FCallStack)].ReturnPos;
  FInSubProgram := FCallStack[High(FCallStack)].WasInSub;
  FCurrentSubIdx := FCallStack[High(FCallStack)].PrevSubIdx;
  SetLength(FCallStack, Length(FCallStack) - 1);
end;

function TQBasicInterpreter.CallFunction(const AName: string): Double;
var
  Args: array of Double;
  StrArgs: array of string;
  BuiltinIdx, SubIdx: Integer;
  S: string;
begin
  Result := 0;
  Advance; // Function name
  
  // Parse arguments
  SetLength(Args, 0);
  SetLength(StrArgs, 0);
  
  if Match(ttLParen) then
  begin
    if not Match(ttRParen) then
    begin
      repeat
        if IsStringExpr then
        begin
          SetLength(StrArgs, Length(StrArgs) + 1);
          StrArgs[High(StrArgs)] := EvaluateStrExpr;
        end
        else
        begin
          SetLength(Args, Length(Args) + 1);
          Args[High(Args)] := EvaluateLogical;
        end;
      until not Match(ttComma);
      Expect(ttRParen);
    end;
  end;
  
  // Check builtin first
  BuiltinIdx := FindBuiltin(AName);
  if BuiltinIdx >= 0 then
  begin
    try
      if Assigned(FBuiltins[BuiltinIdx].NumFunc) then
        Result := FBuiltins[BuiltinIdx].NumFunc(Args)
      else if Assigned(FBuiltins[BuiltinIdx].MixedFunc) then
        Result := FBuiltins[BuiltinIdx].MixedFunc(Args, StrArgs);
    except
      on E: EQBasicError do raise;
      on E: Exception do RaiseErr(E.Message);   // host API error, with this line
    end;
    Exit;
  end;
  
  // User function
  SubIdx := FindSubProgram(AName);
  if SubIdx < 0 then Exit;
  RunUserFunction(SubIdx, AName, Args, StrArgs, Result, S);
end;

function TQBasicInterpreter.CallStringFunction(const AName: string): string;
var
  Args: array of Double;
  StrArgs: array of string;
  BuiltinIdx, SubIdx: Integer;
  N: Double;
begin
  Result := '';
  Advance; // Function name
  
  SetLength(Args, 0);
  SetLength(StrArgs, 0);
  
  if Match(ttLParen) then
  begin
    if not Match(ttRParen) then
    begin
      repeat
        if IsStringExpr then
        begin
          SetLength(StrArgs, Length(StrArgs) + 1);
          StrArgs[High(StrArgs)] := EvaluateStrExpr;
        end
        else
        begin
          SetLength(Args, Length(Args) + 1);
          Args[High(Args)] := EvaluateLogical;
        end;
      until not Match(ttComma);
      Expect(ttRParen);
    end;
  end;
  
  BuiltinIdx := FindBuiltin(AName);
  if (BuiltinIdx >= 0) and Assigned(FBuiltins[BuiltinIdx].StrFunc) then
  begin
    try
      Result := FBuiltins[BuiltinIdx].StrFunc(Args, StrArgs);
    except
      on E: EQBasicError do raise;
      on E: Exception do RaiseErr(E.Message);
    end;
  end
  else
  begin
    SubIdx := FindSubProgram(AName);
    if SubIdx >= 0 then
      RunUserFunction(SubIdx, AName, Args, StrArgs, N, Result);
  end;
end;

procedure TQBasicInterpreter.CallBuiltinProc(const AName: string);
var
  Args: array of Double;
  StrArgs: array of string;
  BuiltinIdx: Integer;

  procedure ParseArg;
  begin
    if IsStringExpr then
    begin
      SetLength(StrArgs, Length(StrArgs) + 1);
      StrArgs[High(StrArgs)] := EvaluateStrExpr;
    end
    else
    begin
      SetLength(Args, Length(Args) + 1);
      Args[High(Args)] := EvaluateLogical;
    end;
  end;

begin
  SetLength(Args, 0);
  SetLength(StrArgs, 0);

  { PUTPIXEL(x, y, c) and QBasic's own PUTPIXEL x, y, c. A call written
    without brackets used to pass no arguments at all. }
  if Match(ttLParen) then
  begin
    if not Match(ttRParen) then
    begin
      repeat
        ParseArg;
      until not Match(ttComma);
      Expect(ttRParen);
    end;
    while Match(ttComma) do    // PUTPIXEL (x), y, c
      ParseArg;
  end
  else if not (CurrentToken.TokenType in [ttEOL, ttEOF, ttColon, ttELSE]) then
  begin
    repeat
      ParseArg;
    until not Match(ttComma);
  end;

  BuiltinIdx := FindBuiltin(AName);
  if (BuiltinIdx >= 0) and Assigned(FBuiltins[BuiltinIdx].ProcFunc) then
  try
    FBuiltins[BuiltinIdx].ProcFunc(Args, StrArgs);
  except
    on E: EQBasicError do raise;
    on E: Exception do RaiseErr(E.Message);   // host API error, with this line
  end;
end;

procedure TQBasicInterpreter.ExecuteStatement;
var
  i: Integer;
begin
  if FStopRequested then Exit;

  { Yield to UI every 100 statements to prevent "Not Responding" }
  Inc(FStatementCount);
  if (FStatementCount mod 100 = 0) and Assigned(FOnYield) then
    FOnYield;
  
  case CurrentToken.TokenType of
    ttEOL: Advance;
    ttPRINT: begin Advance; ExecutePRINT; end;
    ttINPUT: begin Advance; ExecuteINPUT; end;
    ttLET: begin Advance; ExecuteLET; end;
    ttIF: begin Advance; ExecuteIF; end;
    ttFOR: begin Advance; ExecuteFOR; end;
    ttNEXT: begin Advance; ExecuteNEXT; end;
    ttWHILE: begin Advance; ExecuteWHILE; end;
    ttWEND: begin Advance; ExecuteWEND; end;
    ttDO: begin Advance; ExecuteDO; end;
    ttLOOP: begin Advance; ExecuteLOOP; end;
    ttGOTO: begin Advance; ExecuteGOTO; end;
    ttGOSUB: begin Advance; ExecuteGOSUB; end;
    ttRETURN: begin Advance; ExecuteRETURN; end;
    ttDIM: begin Advance; ExecuteDIM; end;
    ttCALL: begin Advance; ExecuteCALL; end;
    ttSUB: begin Advance; ExecuteSUB; end;
    ttFUNCTION: begin Advance; ExecuteFUNCTION; end;
    ttSELECT: begin Advance; ExecuteSELECT; end;
    ttEXIT:
      begin
        Advance;
        if Match(ttSUB) then
          ExecuteRETURN
        else if Match(ttFUNCTION) then
        begin
          { A FUNCTION called from an expression runs in RunUserFunction's
            own loop, which restores the call stack when it ends. Going
            through ExecuteRETURN popped that stack from under it and jumped
            into the caller's expression - EXIT FUNCTION crashed. Unwind to
            the loop instead; a FUNCTION started with CALL still returns. }
          if FFuncDepth > 0 then
            FExitFunc := True
          else
            ExecuteRETURN;
        end
        else if Match(ttFOR) then
        begin
          { leave the loop: drop it AND continue after its NEXT. Only the pop
            was done before, so the rest of the body still ran. }
          if Length(FForStack) > 0 then
            SetLength(FForStack, Length(FForStack) - 1);
          SkipToBlockEnd(ttFOR, ttNEXT);
          if Match(ttNEXT) and (CurrentToken.TokenType = ttIdent) then
            Advance;                         // NEXT i
        end
        else if Match(ttDO) then
          FExitDo := True;                   // ExecuteDO sees it and leaves
      end;
    ttREM:
      while not (CurrentToken.TokenType in [ttEOL, ttEOF]) do Advance;
    ttCLS, ttLOCATE, ttCOLOR, ttSCREEN:
      while not (CurrentToken.TokenType in [ttEOL, ttEOF, ttColon]) do Advance;
    ttIdent:
      begin
        if PeekToken.TokenType = ttColon then
        begin
          Advance; Advance; // Skip label
        end
        else if not ExecuteNamedStatement then   // READ, DATA, SWAP, CONST ...
        begin
          { A procedure call - with or without brackets - or an assignment,
            including a(i) = x. NAME( used to go straight to ExecuteCALL, so an
            array element could never be assigned and an unknown name was
            silently skipped. ExecuteLET now reports unknown names. }
          i := FindBuiltin(CurrentToken.Value);
          { NAME = ... is always an assignment. Checked first because inside
            FUNCTION Twice, "Twice = v * 2" sets the return value - it used to
            be taken as a recursive call of Twice and never returned. }
          if PeekToken.TokenType = ttEQ then
            ExecuteLET
          else if (i >= 0) and FBuiltins[i].IsProc then
            ExecuteCALL
          else if FindSubProgram(CurrentToken.Value) >= 0 then
            ExecuteCALL
          else
            ExecuteLET;
        end;
      end;
    ttColon: Advance;
    ttEND:
      begin
        if PeekToken.TokenType = ttIF then
        begin
          // END IF - just skip both tokens, block IF handles this
          Advance; Advance;
        end
        else if FInSubProgram and (PeekToken.TokenType in [ttSUB, ttFUNCTION]) then
        begin
          { ExecuteRETURN jumps back to the caller, so there is nothing left
            to skip. The two Advance calls that followed skipped the CALLER's
            next two tokens - the statement after every SUB call lost its
            first word, e.g. GOSUB sr ran as a statement called SR. }
          ExecuteRETURN;
        end
        else
        begin
          Advance;                  // past END, so no caller can stall on it
          FStopRequested := True;
        end;
      end;
  else
    Advance;
  end;
end;

procedure TQBasicInterpreter.Execute;
begin
  FPos := 0;
  FRunning := True;
  FStopRequested := False;
  FStatementCount := 0;
  FDataPtr := 0;       // every run READs from the first DATA item
  FExitDo := False;
  FExitFunc := False;
  FFuncDepth := 0;
  FPrintPending := '';
  
  try
    while (CurrentToken.TokenType <> ttEOF) and not FStopRequested do
      ExecuteStatement;
  finally
    FRunning := False;
    { a last PRINT "x"; still shows }
    if (FPrintPending <> '') and Assigned(FOnPrint) then
      FOnPrint(FPrintPending);
    FPrintPending := '';
  end;
end;

procedure TQBasicInterpreter.Stop;
begin
  FStopRequested := True;
end;

{ Builtin functions }

function TQBasicInterpreter.BuiltinABS(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then Result := Abs(Args[0]) else Result := 0;
end;

function TQBasicInterpreter.BuiltinINT(const Args: array of Double): Double;
begin
  { QBasic's INT rounds DOWN: INT(-2.7) = -3. Int() truncates toward zero,
    which is FIX's job. }
  if Length(Args) > 0 then Result := Floor(Args[0]) else Result := 0;
end;

function TQBasicInterpreter.BuiltinSGN(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then
  begin
    if Args[0] > 0 then Result := 1
    else if Args[0] < 0 then Result := -1
    else Result := 0;
  end
  else Result := 0;
end;

function TQBasicInterpreter.BuiltinSQR(const Args: array of Double): Double;
begin
  if (Length(Args) > 0) and (Args[0] >= 0) then
    Result := Sqrt(Args[0])
  else
    Result := 0;
end;

function TQBasicInterpreter.BuiltinSIN(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then Result := Sin(Args[0]) else Result := 0;
end;

function TQBasicInterpreter.BuiltinCOS(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then Result := Cos(Args[0]) else Result := 0;
end;

function TQBasicInterpreter.BuiltinTAN(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then Result := Tan(Args[0]) else Result := 0;
end;

function TQBasicInterpreter.BuiltinATN(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then Result := ArcTan(Args[0]) else Result := 0;
end;

function TQBasicInterpreter.BuiltinLOG(const Args: array of Double): Double;
begin
  if (Length(Args) > 0) and (Args[0] > 0) then
    Result := Ln(Args[0])
  else
    Result := 0;
end;

function TQBasicInterpreter.BuiltinEXP(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then Result := Exp(Args[0]) else Result := 1;
end;

function TQBasicInterpreter.BuiltinRND(const Args: array of Double): Double;
begin
  Result := Random;
end;

{ LEN, ASC and VAL were stubs that always returned 0 and were never
  registered - nothing "handled them specially" as their comments claimed.
  They take a string, so they are mixed functions. }
function TQBasicInterpreter.BuiltinLEN(const Args: array of Double; const StrArgs: array of string): Double;
begin
  if Length(StrArgs) > 0 then Result := Length(StrArgs[0]) else Result := 0;
end;

function TQBasicInterpreter.BuiltinASC(const Args: array of Double; const StrArgs: array of string): Double;
begin
  if (Length(StrArgs) > 0) and (StrArgs[0] <> '') then
    Result := Ord(StrArgs[0][1])
  else
    RaiseErr('Illegal function call: ASC of an empty string');
end;

{ VAL reads the leading number and ignores the rest, as QBasic: VAL("12ab") = 12 }
function TQBasicInterpreter.BuiltinVAL(const Args: array of Double; const StrArgs: array of string): Double;
var
  S: string;
  i: Integer;
begin
  Result := 0;
  if Length(StrArgs) = 0 then Exit;
  S := Trim(StrArgs[0]);
  i := 1;
  if (i <= Length(S)) and (S[i] in ['+', '-']) then Inc(i);
  while (i <= Length(S)) and (S[i] in ['0'..'9', '.']) do Inc(i);
  S := Copy(S, 1, i - 1);
  if not TryStrToFloat(S, Result, DefaultFormatSettings) then
    Result := 0;
end;

function TQBasicInterpreter.BuiltinMIN(const Args: array of Double): Double;
begin
  if Length(Args) >= 2 then
    Result := Math.Min(Args[0], Args[1])
  else if Length(Args) = 1 then
    Result := Args[0]
  else
    Result := 0;
end;

function TQBasicInterpreter.BuiltinMAX(const Args: array of Double): Double;
begin
  if Length(Args) >= 2 then
    Result := Math.Max(Args[0], Args[1])
  else if Length(Args) = 1 then
    Result := Args[0]
  else
    Result := 0;
end;

function TQBasicInterpreter.BuiltinCHR(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  if Length(Args) > 0 then
    Result := Chr(Trunc(Args[0]) and 255)
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinSTR(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  if Length(Args) > 0 then
    Result := FloatToStr(Args[0])
  else
    Result := '0';
end;

function TQBasicInterpreter.BuiltinLEFT(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  if (Length(StrArgs) > 0) and (Length(Args) > 0) then
    Result := Copy(StrArgs[0], 1, Trunc(Args[0]))
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinRIGHT(const Args: array of Double;
  const StrArgs: array of string): string;
var
  S: string;
  N: Integer;
begin
  if (Length(StrArgs) > 0) and (Length(Args) > 0) then
  begin
    S := StrArgs[0];
    N := Trunc(Args[0]);
    if N >= Length(S) then
      Result := S
    else
      Result := Copy(S, Length(S) - N + 1, N);
  end
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinMID(const Args: array of Double;
  const StrArgs: array of string): string;
var
  Start, Len: Integer;
begin
  if (Length(StrArgs) > 0) and (Length(Args) >= 1) then
  begin
    Start := Trunc(Args[0]);
    if Length(Args) >= 2 then
      Len := Trunc(Args[1])
    else
      Len := Length(StrArgs[0]);
    Result := Copy(StrArgs[0], Start, Len);
  end
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinUCASE(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  if Length(StrArgs) > 0 then
    Result := UpperCase(StrArgs[0])
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinLCASE(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  if Length(StrArgs) > 0 then
    Result := LowerCase(StrArgs[0])
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinLTRIM(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  if Length(StrArgs) > 0 then
    Result := TrimLeft(StrArgs[0])
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinRTRIM(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  if Length(StrArgs) > 0 then
    Result := TrimRight(StrArgs[0])
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinSPACE(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  if Length(Args) > 0 then
    Result := StringOfChar(' ', Trunc(Args[0]))
  else
    Result := '';
end;

function TQBasicInterpreter.BuiltinSTRING(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  { STRING$(n, code) or STRING$(n, "c") - the character form arrives in
    StrArgs, which this used to ignore, returning "" }
  if Length(Args) >= 2 then
    Result := StringOfChar(Chr(Trunc(Args[1]) and 255), Trunc(Args[0]))
  else if (Length(Args) >= 1) and (Length(StrArgs) >= 1) and (StrArgs[0] <> '') then
    Result := StringOfChar(StrArgs[0][1], Trunc(Args[0]))
  else
    Result := '';
end;

procedure TQBasicInterpreter.RegisterBuiltins;

  procedure AddNum(const AName: string; AFunc: TBuiltinFuncNum; AMin: Integer = 1; AMax: Integer = 1);
  begin
    SetLength(FBuiltins, Length(FBuiltins) + 1);
    with FBuiltins[High(FBuiltins)] do
    begin
      Name := AName;
      MinArgs := AMin;
      MaxArgs := AMax;
      ReturnsString := False;
      NumFunc := AFunc;
      StrFunc := nil;
      MixedFunc := nil;
      ProcFunc := nil;
      IsProc := False;
    end;
  end;

  procedure AddStr(const AName: string; AFunc: TBuiltinFuncStr; AMin: Integer = 1; AMax: Integer = 1);
  begin
    SetLength(FBuiltins, Length(FBuiltins) + 1);
    with FBuiltins[High(FBuiltins)] do
    begin
      Name := AName;
      MinArgs := AMin;
      MaxArgs := AMax;
      ReturnsString := True;
      NumFunc := nil;
      StrFunc := AFunc;
      MixedFunc := nil;
      ProcFunc := nil;
      IsProc := False;
    end;
  end;

begin
  // Numeric functions
  AddNum('ABS', @BuiltinABS);
  AddNum('INT', @BuiltinINT);
  AddNum('SGN', @BuiltinSGN);
  AddNum('SQR', @BuiltinSQR);
  AddNum('SIN', @BuiltinSIN);
  AddNum('COS', @BuiltinCOS);
  AddNum('TAN', @BuiltinTAN);
  AddNum('ATN', @BuiltinATN);
  AddNum('LOG', @BuiltinLOG);
  AddNum('EXP', @BuiltinEXP);
  AddNum('RND', @BuiltinRND, 0, 1);
  AddNum('MIN', @BuiltinMIN, 2, 2);
  AddNum('MAX', @BuiltinMAX, 2, 2);
  
  // String functions
  AddStr('CHR$', @BuiltinCHR);
  AddStr('STR$', @BuiltinSTR);
  AddStr('LEFT$', @BuiltinLEFT, 2, 2);
  AddStr('RIGHT$', @BuiltinRIGHT, 2, 2);
  AddStr('MID$', @BuiltinMID, 2, 3);
  AddStr('UCASE$', @BuiltinUCASE);
  AddStr('LCASE$', @BuiltinLCASE);
  AddStr('LTRIM$', @BuiltinLTRIM);
  AddStr('RTRIM$', @BuiltinRTRIM);
  AddStr('SPACE$', @BuiltinSPACE);
  AddStr('STRING$', @BuiltinSTRING, 2, 2);

  // Raster Master additions
  AddNum('FIX', @BuiltinFIX);
  AddNum('CINT', @BuiltinCINT);
  AddNum('CLNG', @BuiltinCINT);
  AddNum('TIMER', @BuiltinTIMER, 0, 0);
  AddStr('HEX$', @BuiltinHEX);
  AddStr('OCT$', @BuiltinOCT);
  AddStr('DATE$', @BuiltinDATE, 0, 0);
  AddStr('TIME$', @BuiltinTIME, 0, 0);
  RegisterMixedFunction('INSTR', 2, 3, @BuiltinINSTR);
  RegisterMixedFunction('LEN', 1, 1, @BuiltinLEN);
  RegisterMixedFunction('ASC', 1, 1, @BuiltinASC);
  RegisterMixedFunction('VAL', 1, 1, @BuiltinVAL);
end;

procedure TQBasicInterpreter.RegisterFunction(const AName: string;
  AMinArgs, AMaxArgs: Integer; AFunc: TBuiltinFuncNum);
begin
  SetLength(FBuiltins, Length(FBuiltins) + 1);
  with FBuiltins[High(FBuiltins)] do
  begin
    Name := UpperCase(AName);
    MinArgs := AMinArgs;
    MaxArgs := AMaxArgs;
    ReturnsString := False;
    NumFunc := AFunc;
    StrFunc := nil;
    MixedFunc := nil;
    ProcFunc := nil;
    IsProc := False;
  end;
end;

procedure TQBasicInterpreter.RegisterStringFunction(const AName: string;
  AMinArgs, AMaxArgs: Integer; AFunc: TBuiltinFuncStr);
begin
  SetLength(FBuiltins, Length(FBuiltins) + 1);
  with FBuiltins[High(FBuiltins)] do
  begin
    Name := UpperCase(AName);
    MinArgs := AMinArgs;
    MaxArgs := AMaxArgs;
    ReturnsString := True;
    NumFunc := nil;
    StrFunc := AFunc;
    MixedFunc := nil;
    ProcFunc := nil;
    IsProc := False;
  end;
end;

procedure TQBasicInterpreter.RegisterMixedFunction(const AName: string;
  AMinArgs, AMaxArgs: Integer; AFunc: TBuiltinFuncMixed);
begin
  SetLength(FBuiltins, Length(FBuiltins) + 1);
  with FBuiltins[High(FBuiltins)] do
  begin
    Name := UpperCase(AName);
    MinArgs := AMinArgs;
    MaxArgs := AMaxArgs;
    ReturnsString := False;
    NumFunc := nil;
    StrFunc := nil;
    MixedFunc := AFunc;
    ProcFunc := nil;
    IsProc := False;
  end;
end;

procedure TQBasicInterpreter.RegisterProcedure(const AName: string;
  AMinArgs, AMaxArgs: Integer; AProc: TBuiltinProc);
begin
  SetLength(FBuiltins, Length(FBuiltins) + 1);
  with FBuiltins[High(FBuiltins)] do
  begin
    Name := UpperCase(AName);
    MinArgs := AMinArgs;
    MaxArgs := AMaxArgs;
    ReturnsString := False;
    NumFunc := nil;
    StrFunc := nil;
    MixedFunc := nil;
    ProcFunc := AProc;
    IsProc := True;
  end;
end;

{ =====================================================================
  Raster Master additions
  Arrays, DATA/READ/RESTORE, SWAP, CONST, RANDOMIZE, REDIM/ERASE,
  UBOUND/LBOUND and QBasic-style argument lists. Arrays live in the
  TVariable fields that already existed but were never used.
  ===================================================================== }

procedure TQBasicInterpreter.RaiseErr(const Msg: string);
begin
  raise EQBasicError.Create(Msg, CurrentToken.Line, CurrentToken.Col);
end;

function TQBasicInterpreter.TokenName(T: TTokenType): string;
begin
  case T of
    ttEOF: Result := 'end of program';
    ttEOL: Result := 'end of line';
    ttLParen: Result := '"("';
    ttRParen: Result := '")"';
    ttComma: Result := '","';
    ttSemicolon: Result := '";"';
    ttColon: Result := '":"';
    ttEQ: Result := '"="';
    ttPlus: Result := '"+"';
    ttMinus: Result := '"-"';
    ttMult: Result := '"*"';
    ttDiv: Result := '"/"';
    ttIntDiv: Result := '"\"';
    ttNumber: Result := 'a number';
    ttString: Result := 'a string';
    ttIdent: Result := 'a name';
  else
    begin
      WriteStr(Result, T);                 // e.g. ttTHEN
      Result := Copy(Result, 3, MaxInt);   // THEN
    end;
  end;
end;

function TQBasicInterpreter.FindVarRec(const AName: string): PVariable;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := GetVariable(AName);
  if Idx >= 0 then
    Result := @FVariables[Idx]
  else if Idx < -1 then
    Result := @FSubPrograms[FCurrentSubIdx].LocalVars[-(Idx + 2)];
end;

function TQBasicInterpreter.IsArrayVar(const AName: string): Boolean;
var
  V: PVariable;
begin
  V := FindVarRec(AName);
  Result := (V <> nil) and V^.IsArray;
end;

{ ( e [, e]... ) - subscripts are rounded, as QBasic does }
function TQBasicInterpreter.ParseIndices: TIntArray;
var
  n: Integer;
begin
  Result := nil;
  Expect(ttLParen);
  repeat
    n := Length(Result);
    SetLength(Result, n + 1);
    Result[n] := Round(EvaluateLogical);
  until not Match(ttComma);
  Expect(ttRParen);
end;

function TQBasicInterpreter.ArrayOffset(V: PVariable; const Idx: TIntArray): Integer;
var
  d, Span: Integer;
begin
  if Length(Idx) <> Length(V^.ArrayDims) then
    RaiseErr('Wrong number of subscripts for ' + V^.Name);
  Result := 0;
  for d := 0 to High(Idx) do
  begin
    if (Idx[d] < V^.ArrayLo[d]) or (Idx[d] > V^.ArrayDims[d]) then
      RaiseErr('Subscript out of range: ' + V^.Name + '(' + IntToStr(Idx[d]) + ')');
    Span := V^.ArrayDims[d] - V^.ArrayLo[d] + 1;
    Result := Result * Span + (Idx[d] - V^.ArrayLo[d]);
  end;
end;

{ Lo/Hi are inclusive bounds per dimension. Re-dimensioning clears the array. }
procedure TQBasicInterpreter.DimArray(const AName: string; const Lo, Hi: TIntArray;
  AIsString, ForceLocal: Boolean);
var
  V: PVariable;
  d: Integer;
  Total: Int64;
begin
  Total := 1;
  for d := 0 to High(Hi) do
  begin
    if Hi[d] < Lo[d] then
      RaiseErr('Array bounds out of range: ' + AName);
    Total := Total * (Int64(Hi[d]) - Lo[d] + 1);
    if Total > 16777216 then
      RaiseErr('Array too large: ' + AName);
  end;

  { create or reuse the record in the right scope, THEN take a pointer -
    SetVariable can grow the variable array and move it }
  SetVariable(AName, 0, '', AIsString, ForceLocal);
  V := FindVarRec(AName);
  V^.IsString := AIsString;
  V^.IsArray := True;
  SetLength(V^.ArrayLo, Length(Lo));
  SetLength(V^.ArrayDims, Length(Hi));
  for d := 0 to High(Hi) do
  begin
    V^.ArrayLo[d] := Lo[d];
    V^.ArrayDims[d] := Hi[d];
  end;
  SetLength(V^.ArrayData, 0);
  SetLength(V^.ArrayStrData, 0);
  if AIsString then
    SetLength(V^.ArrayStrData, Total)
  else
    SetLength(V^.ArrayData, Total);
end;

{ QBasic lets an array be used without DIM: every dimension becomes 0..10 }
procedure TQBasicInterpreter.ImplicitDim(const AName: string; NDims: Integer);
var
  Lo, Hi: TIntArray;
  d: Integer;
begin
  SetLength(Lo, NDims);
  SetLength(Hi, NDims);
  for d := 0 to NDims - 1 do
  begin
    Lo[d] := 0;
    Hi[d] := 10;
  end;
  DimArray(AName, Lo, Hi, (Length(AName) > 0) and (AName[Length(AName)] = '$'), False);
end;

function TQBasicInterpreter.GetArrayNum(const AName: string; const Idx: TIntArray): Double;
var
  V: PVariable;
  o: Integer;
begin
  Result := 0;
  V := FindVarRec(AName);
  if (V = nil) or not V^.IsArray then
    RaiseErr('Not an array: ' + AName);
  o := ArrayOffset(V, Idx);
  if V^.IsString then
    RaiseErr('Type mismatch: ' + AName + ' is a string array')
  else
    Result := V^.ArrayData[o];
end;

function TQBasicInterpreter.GetArrayStr(const AName: string; const Idx: TIntArray): string;
var
  V: PVariable;
  o: Integer;
begin
  V := FindVarRec(AName);
  if (V = nil) or not V^.IsArray then
    RaiseErr('Not an array: ' + AName);
  o := ArrayOffset(V, Idx);
  if V^.IsString then
    Result := V^.ArrayStrData[o]
  else
    Result := FloatToStr(V^.ArrayData[o]);
end;

procedure TQBasicInterpreter.SetArrayNum(const AName: string; const Idx: TIntArray;
  AValue: Double);
var
  V: PVariable;
  o: Integer;
begin
  V := FindVarRec(AName);
  if V = nil then
  begin
    ImplicitDim(AName, Length(Idx));
    V := FindVarRec(AName);
  end;
  if not V^.IsArray then
    RaiseErr('Not an array: ' + AName);
  o := ArrayOffset(V, Idx);
  if V^.IsString then
    RaiseErr('Type mismatch: ' + AName + ' is a string array');
  V^.ArrayData[o] := AValue;
end;

procedure TQBasicInterpreter.SetArrayStr(const AName: string; const Idx: TIntArray;
  const AValue: string);
var
  V: PVariable;
  o: Integer;
begin
  V := FindVarRec(AName);
  if V = nil then
  begin
    ImplicitDim(AName, Length(Idx));
    V := FindVarRec(AName);
  end;
  if not V^.IsArray then
    RaiseErr('Not an array: ' + AName);
  o := ArrayOffset(V, Idx);
  if not V^.IsString then
    RaiseErr('Type mismatch: ' + AName + ' is a numeric array');
  V^.ArrayStrData[o] := AValue;
end;

{ --- assignable targets: NAME or NAME(i[,j...]) --- }

function TQBasicInterpreter.ParseLValue: TLValue;
begin
  if not Match(ttIdent) then
    RaiseErr('Variable name expected');
  Result.Name := FTokens[FPos - 1].Value;
  Result.HasIdx := CurrentToken.TokenType = ttLParen;
  if Result.HasIdx then
    Result.Idx := ParseIndices
  else
    SetLength(Result.Idx, 0);
end;

function TQBasicInterpreter.LValueIsString(const L: TLValue): Boolean;
var
  V: PVariable;
begin
  Result := (Length(L.Name) > 0) and (L.Name[Length(L.Name)] = '$');
  if not Result then
  begin
    V := FindVarRec(L.Name);
    if V <> nil then
      Result := V^.IsString;
  end;
end;

function TQBasicInterpreter.GetLValueNum(const L: TLValue): Double;
begin
  if L.HasIdx then
    Result := GetArrayNum(L.Name, L.Idx)
  else
    Result := GetVariableValue(L.Name);
end;

function TQBasicInterpreter.GetLValueStr(const L: TLValue): string;
begin
  if L.HasIdx then
    Result := GetArrayStr(L.Name, L.Idx)
  else if LValueIsString(L) then
    Result := GetVariableStrValue(L.Name)
  else
    Result := FloatToStr(GetVariableValue(L.Name));
end;

procedure TQBasicInterpreter.SetLValueNum(const L: TLValue; AValue: Double);
begin
  if L.HasIdx then
    SetArrayNum(L.Name, L.Idx, AValue)
  else
    SetVariable(L.Name, AValue, '', False);
end;

procedure TQBasicInterpreter.SetLValueStr(const L: TLValue; const AValue: string);
begin
  if L.HasIdx then
    SetArrayStr(L.Name, L.Idx, AValue)
  else
    SetVariable(L.Name, 0, AValue, True);
end;

{ --- statements recognised by name, no lexer keywords needed --- }

function TQBasicInterpreter.ExecuteNamedStatement: Boolean;
var
  W: string;
begin
  Result := True;
  W := CurrentToken.Value;
  if W = 'DATA' then
  begin
    { not executable - the items were collected by ScanData }
    while not (CurrentToken.TokenType in [ttEOL, ttEOF]) do Advance;
  end
  else if W = 'READ' then begin Advance; ExecuteREAD; end
  else if W = 'RESTORE' then begin Advance; ExecuteRESTORE; end
  else if W = 'SWAP' then begin Advance; ExecuteSWAP; end
  else if W = 'CONST' then begin Advance; ExecuteCONST; end
  else if W = 'RANDOMIZE' then begin Advance; ExecuteRANDOMIZE; end
  else if W = 'REDIM' then begin Advance; ExecuteDIM; end
  else if W = 'ERASE' then begin Advance; ExecuteERASE; end
  else
    Result := False;
end;

{ Collects every DATA item at load time, in program order. Items are numbers
  (optionally signed), quoted strings, or unquoted text - which the lexer has
  already uppercased, so quote text whose case matters. }
procedure TQBasicInterpreter.ScanData;
var
  i, StmtPos: Integer;
  Neg: Boolean;
  Item: TDataItem;
  S: string;
begin
  SetLength(FData, 0);
  FDataPtr := 0;
  i := 0;
  while i < Length(FTokens) do
  begin
    if (FTokens[i].TokenType = ttIdent) and (FTokens[i].Value = 'DATA') and
       ((i = 0) or (FTokens[i - 1].TokenType in [ttEOL, ttColon, ttNumber])) then
    begin
      StmtPos := i;
      Inc(i);
      repeat
        Item.IsString := False;
        Item.NumValue := 0;
        Item.StrValue := '';
        Item.TokPos := StmtPos;
        Neg := False;
        S := '';
        while (i < Length(FTokens)) and
              not (FTokens[i].TokenType in [ttComma, ttEOL, ttEOF, ttColon]) do
        begin
          case FTokens[i].TokenType of
            ttMinus: Neg := not Neg;
            ttPlus: ;
            ttNumber: Item.NumValue := StrToFloatDef(FTokens[i].Value, 0);
            ttString:
              begin
                Item.IsString := True;
                S := S + FTokens[i].Value;
              end;
          else
            begin
              Item.IsString := True;
              if S <> '' then S := S + ' ';
              S := S + FTokens[i].Value;
            end;
          end;
          Inc(i);
        end;
        if Item.IsString then
          Item.StrValue := S
        else if Neg then
          Item.NumValue := -Item.NumValue;
        SetLength(FData, Length(FData) + 1);
        FData[High(FData)] := Item;
        if (i < Length(FTokens)) and (FTokens[i].TokenType = ttComma) then
          Inc(i)
        else
          Break;
      until False;
    end
    else
      Inc(i);
  end;
end;

procedure TQBasicInterpreter.ExecuteREAD;
var
  L: TLValue;
  D: TDataItem;
  V: Double;
begin
  repeat
    L := ParseLValue;
    if FDataPtr >= Length(FData) then
      RaiseErr('Out of DATA');
    D := FData[FDataPtr];
    Inc(FDataPtr);
    if LValueIsString(L) then
    begin
      if D.IsString then
        SetLValueStr(L, D.StrValue)
      else
        SetLValueStr(L, FloatToStr(D.NumValue));
    end
    else if D.IsString then
    begin
      if not TryStrToFloat(D.StrValue, V) then
        RaiseErr('Type mismatch: DATA item "' + D.StrValue + '" is not a number');
      SetLValueNum(L, V);
    end
    else
      SetLValueNum(L, D.NumValue);
  until not Match(ttComma);
end;

procedure TQBasicInterpreter.ExecuteRESTORE;
var
  P, i: Integer;
  LabelName: string;
begin
  if CurrentToken.TokenType in [ttIdent, ttNumber] then
  begin
    LabelName := CurrentToken.Value;
    Advance;
    P := FindLabel(LabelName);
    if P < 0 then
      RaiseErr('Label not found: ' + LabelName);
    FDataPtr := Length(FData);            // nothing after the label
    for i := 0 to High(FData) do
      if FData[i].TokPos >= P then
      begin
        FDataPtr := i;
        Break;
      end;
  end
  else
    FDataPtr := 0;
end;

procedure TQBasicInterpreter.ExecuteSWAP;
var
  A, B: TLValue;
  SA, SB: string;
  NA, NB: Double;
begin
  A := ParseLValue;
  Expect(ttComma);
  B := ParseLValue;
  if LValueIsString(A) <> LValueIsString(B) then
    RaiseErr('Type mismatch in SWAP');
  if LValueIsString(A) then
  begin
    SA := GetLValueStr(A);
    SB := GetLValueStr(B);
    SetLValueStr(A, SB);
    SetLValueStr(B, SA);
  end
  else
  begin
    NA := GetLValueNum(A);
    NB := GetLValueNum(B);
    SetLValueNum(A, NB);
    SetLValueNum(B, NA);
  end;
end;

{ CONST a = 1, b$ = "x" - stored as ordinary variables }
procedure TQBasicInterpreter.ExecuteCONST;
begin
  repeat
    ExecuteLET;
  until not Match(ttComma);
end;

procedure TQBasicInterpreter.ExecuteRANDOMIZE;
begin
  if CurrentToken.TokenType in [ttEOL, ttEOF, ttColon] then
    Randomize
  else
    RandSeed := Trunc(EvaluateLogical);
end;

procedure TQBasicInterpreter.ExecuteERASE;
var
  V: PVariable;
  i: Integer;
begin
  repeat
    if not Match(ttIdent) then
      RaiseErr('Array name expected');
    V := FindVarRec(FTokens[FPos - 1].Value);
    if (V = nil) or not V^.IsArray then
      RaiseErr('Not an array: ' + FTokens[FPos - 1].Value);
    for i := 0 to High(V^.ArrayData) do V^.ArrayData[i] := 0;
    for i := 0 to High(V^.ArrayStrData) do V^.ArrayStrData[i] := '';
  until not Match(ttComma);
end;

{ UBOUND(a [,dim]) / LBOUND(a [,dim]) - they take an array NAME, not a value }
function TQBasicInterpreter.EvaluateBound(IsUpper: Boolean): Double;
var
  ArrName: string;
  V: PVariable;
  D: Integer;
begin
  Advance;   // UBOUND / LBOUND
  Expect(ttLParen);
  if not Match(ttIdent) then
    RaiseErr('Array name expected');
  ArrName := FTokens[FPos - 1].Value;
  D := 1;
  if Match(ttComma) then
    D := Round(EvaluateLogical);
  Expect(ttRParen);
  V := FindVarRec(ArrName);
  if (V = nil) or not V^.IsArray then
    RaiseErr('Not an array: ' + ArrName);
  if (D < 1) or (D > Length(V^.ArrayDims)) then
    RaiseErr('Dimension out of range for ' + ArrName);
  if IsUpper then
    Result := V^.ArrayDims[D - 1]
  else
    Result := V^.ArrayLo[D - 1];
end;

{ ^ binds tighter than * and / and tighter than unary minus: -2^2 = -4.
  It used to be handled together with * and / left to right, so 2*3^2 = 36. }
function TQBasicInterpreter.EvaluatePower: Double;
var
  E: Double;
begin
  Result := EvaluateFactor;
  while Match(ttPower) do
  begin
    if Match(ttMinus) then        // 2^-1
      E := -EvaluateFactor
    else
    begin
      Match(ttPlus);
      E := EvaluateFactor;
    end;
    Result := Power(Result, E);
  end;
end;

{ --- extra built-in functions --- }

function TQBasicInterpreter.BuiltinFIX(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then Result := Trunc(Args[0]) else Result := 0;
end;

{ banker's rounding, which is also what QBasic's CINT does: CINT(2.5) = 2 }
function TQBasicInterpreter.BuiltinCINT(const Args: array of Double): Double;
begin
  if Length(Args) > 0 then Result := Round(Args[0]) else Result := 0;
end;

function TQBasicInterpreter.BuiltinTIMER(const Args: array of Double): Double;
begin
  Result := Frac(Now) * 86400;    // seconds since midnight
end;

{ INSTR([start,] text$, find$) }
function TQBasicInterpreter.BuiltinINSTR(const Args: array of Double;
  const StrArgs: array of string): Double;
var
  Start, P: Integer;
begin
  Result := 0;
  if Length(StrArgs) < 2 then Exit;
  Start := 1;
  if Length(Args) > 0 then Start := Trunc(Args[0]);
  if Start < 1 then Start := 1;
  if Start > Length(StrArgs[0]) then Exit;
  if StrArgs[1] = '' then Exit(Start);
  P := Pos(StrArgs[1], Copy(StrArgs[0], Start, MaxInt));
  if P > 0 then Result := P + Start - 1;
end;

function TQBasicInterpreter.BuiltinHEX(const Args: array of Double;
  const StrArgs: array of string): string;
var
  V: Int64;
begin
  if Length(Args) = 0 then Exit('0');
  V := Trunc(Args[0]);
  if (V < 0) and (V >= -32768) then V := V and $FFFF;   // 16-bit, as QBasic
  Result := IntToHex(V, 1);
end;

function TQBasicInterpreter.BuiltinOCT(const Args: array of Double;
  const StrArgs: array of string): string;
var
  V: Int64;
begin
  if Length(Args) = 0 then Exit('0');
  V := Trunc(Args[0]);
  if (V < 0) and (V >= -32768) then V := V and $FFFF;
  if V = 0 then Exit('0');
  Result := '';
  while V > 0 do
  begin
    Result := Chr(Ord('0') + (V and 7)) + Result;
    V := V shr 3;
  end;
end;

function TQBasicInterpreter.BuiltinDATE(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  Result := FormatDateTime('mm"-"dd"-"yyyy', Now);
end;

function TQBasicInterpreter.BuiltinTIME(const Args: array of Double;
  const StrArgs: array of string): string;
begin
  Result := FormatDateTime('hh":"nn":"ss', Now);
end;


end.
