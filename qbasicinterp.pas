{$MODE OBJFPC}{$H+}
unit qbasicinterp;

{
  QBasicInterp - QBasic Interpreter Unit for Raster Master
  
  This is a modified version of the standalone interpreter,
  converted to a reusable unit that can be embedded in applications.
  
  Key changes from standalone:
  - No console I/O (uses callbacks)
  - Custom function registration
  - Error handling with exceptions
}

interface

uses
  Classes, SysUtils, Math;

type
  TTokenType = (
    ttEOF, ttEOL, ttNumber, ttString, ttIdent, ttComma, ttSemicolon,
    ttPlus, ttMinus, ttMult, ttDiv, ttMod, ttPower,
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
  TBuiltinProc = procedure(const Args: array of Double; const StrArgs: array of string) of object;
  
  TBuiltinFunction = record
    Name: string;
    MinArgs: Integer;
    MaxArgs: Integer;
    ReturnsString: Boolean;
    NumFunc: TBuiltinFuncNum;
    StrFunc: TBuiltinFuncStr;
    ProcFunc: TBuiltinProc;
    IsProc: Boolean;
  end;

  { Event types }
  TPrintEvent = procedure(const Text: string) of object;
  TInputEvent = function(const Prompt: string; var Value: string): Boolean of object;

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
    FRunning: Boolean;
    FStopRequested: Boolean;
    
    FOnPrint: TPrintEvent;
    FOnInput: TInputEvent;
    
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
    procedure ScanSubPrograms;
    function FindLabel(const ALabel: string): Integer;
    function FindSubProgram(const AName: string): Integer;
    function FindBuiltin(const AName: string): Integer;
    function CallFunction(const AName: string): Double;
    function CallStringFunction(const AName: string): string;
    procedure CallBuiltinProc(const AName: string);
    
    function BuiltinABS(const Args: array of Double): Double;
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
    function BuiltinLEN(const Args: array of Double): Double;
    function BuiltinASC(const Args: array of Double): Double;
    function BuiltinVAL(const Args: array of Double): Double;
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
    procedure RegisterProcedure(const AName: string; AMinArgs, AMaxArgs: Integer;
      AProc: TBuiltinProc);
    
    { Set/Get global variables from host }
    procedure SetGlobalVariable(const AName: string; AValue: Double);
    procedure SetGlobalStringVariable(const AName: string; const AValue: string);
    function GetGlobalVariable(const AName: string): Double;
    function GetGlobalStringVariable(const AName: string): string;
    
    property OnPrint: TPrintEvent read FOnPrint write FOnPrint;
    property OnInput: TInputEvent read FOnInput write FOnInput;
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
    else if Ident = 'REM' then Result.TokenType := ttREM
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
    '\': begin Advance; Result.TokenType := ttDiv; end; // Integer division
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
    Advance;
    Result.TokenType := ttEOL; // Skip unknown characters
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
    raise EQBasicError.Create(Format('Expected token type %d, got %d', 
      [Ord(AType), Ord(CurrentToken.TokenType)]),
      CurrentToken.Line, CurrentToken.Col);
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
begin
  Result := 0;
  
  if Match(ttNumber) then
    Result := StrToFloatDef(FTokens[FPos - 1].Value, 0)
  else if CurrentToken.TokenType = ttIdent then
  begin
    VarName := CurrentToken.Value;
    
    // Check for function call
    if PeekToken.TokenType = ttLParen then
    begin
      BuiltinIdx := FindBuiltin(VarName);
      if BuiltinIdx >= 0 then
        Result := CallFunction(VarName)
      else if FindSubProgram(VarName) >= 0 then
        Result := CallFunction(VarName)
      else
      begin
        Advance;
        Result := 0;
      end;
    end
    else
    begin
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
    Result := EvaluateExpr;
    Expect(ttRParen);
  end
  else if Match(ttString) then
    Result := 0;
end;

function TQBasicInterpreter.EvaluateUnary: Double;
begin
  if Match(ttMinus) then
    Result := -EvaluateFactor
  else if Match(ttPlus) then
    Result := EvaluateFactor
  else if Match(ttNOT) then
  begin
    if EvaluateFactor <> 0 then
      Result := 0
    else
      Result := -1;
  end
  else
    Result := EvaluateFactor;
end;

function TQBasicInterpreter.EvaluateTerm: Double;
var
  Op: TTokenType;
begin
  Result := EvaluateUnary;
  while CurrentToken.TokenType in [ttMult, ttDiv, ttMod, ttPower] do
  begin
    Op := CurrentToken.TokenType;
    Advance;
    case Op of
      ttMult: Result := Result * EvaluateUnary;
      ttDiv: 
        begin
          if EvaluateUnary <> 0 then
            Result := Result / EvaluateUnary
          else
            raise EQBasicError.Create('Division by zero', CurrentToken.Line, CurrentToken.Col);
        end;
      ttMod: Result := Trunc(Result) mod Trunc(EvaluateUnary);
      ttPower: Result := Power(Result, EvaluateUnary);
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
begin
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
begin
  if Match(ttString) then
    Result := FTokens[FPos - 1].Value
  else if CurrentToken.TokenType = ttIdent then
  begin
    VarName := CurrentToken.Value;
    
    // Check for string function
    if PeekToken.TokenType = ttLParen then
    begin
      if (Length(VarName) > 0) and (VarName[Length(VarName)] = '$') then
        Result := CallStringFunction(VarName)
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
  
  // Handle string concatenation
  while Match(ttPlus) do
    Result := Result + EvaluateStrExpr;
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
begin
  NewLine := True;
  while not (CurrentToken.TokenType in [ttEOL, ttEOF, ttColon]) do
  begin
    if Match(ttSemicolon) then
      NewLine := False
    else if Match(ttComma) then
    begin
      if Assigned(FOnPrint) then
        FOnPrint(#9);
      NewLine := False;
    end
    else
    begin
      if IsStringExpr then
        Value := EvaluateStrExpr
      else
        Value := FloatToStr(EvaluateLogical);
      if Assigned(FOnPrint) then
        FOnPrint(Value);
      NewLine := True;
    end;
  end;
  if NewLine and Assigned(FOnPrint) then
    FOnPrint(#13#10);
end;

procedure TQBasicInterpreter.ExecuteINPUT;
var
  Prompt, VarName, Input: string;
begin
  Prompt := '';
  if Match(ttString) then
  begin
    Prompt := FTokens[FPos - 1].Value;
    Match(ttSemicolon);
    Match(ttComma);
  end;
  
  if Match(ttIdent) then
  begin
    VarName := FTokens[FPos - 1].Value;
    Input := '';
    if Assigned(FOnInput) then
      FOnInput(Prompt, Input);
    
    if (Length(VarName) > 0) and (VarName[Length(VarName)] = '$') then
      SetVariable(VarName, 0, Input, True)
    else
      SetVariable(VarName, StrToFloatDef(Input, 0), '', False);
  end;
end;

procedure TQBasicInterpreter.ExecuteLET;
var
  VarName: string;
begin
  if Match(ttIdent) then
  begin
    VarName := FTokens[FPos - 1].Value;
    Expect(ttEQ);
    
    if (Length(VarName) > 0) and (VarName[Length(VarName)] = '$') then
      SetVariable(VarName, 0, EvaluateStrExpr, True)
    else
      SetVariable(VarName, EvaluateLogical, '', False);
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
        while FRunning and not FStopRequested do
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
        
        // Skip ELSE/ELSEIF blocks if we executed THEN block
        if CurrentToken.TokenType in [ttELSE, ttELSEIF] then
        begin
          NestLevel := 1;
          while (NestLevel > 0) and (CurrentToken.TokenType <> ttEOF) do
          begin
            if CurrentToken.TokenType = ttIF then
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
          
          if CurrentToken.TokenType = ttIF then
          begin
            // Check if it's a block IF (not single-line)
            // For simplicity, we'll count all IFs
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
            while FRunning and not FStopRequested do
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
        while not (CurrentToken.TokenType in [ttEOL, ttEOF, ttELSE]) do
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
          while not (CurrentToken.TokenType in [ttEOL, ttEOF]) do
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
  LoopPos: Integer;
  Condition: Boolean;
begin
  LoopPos := FPos;
  Condition := EvaluateLogical <> 0;
  
  if Condition then
  begin
    while not (CurrentToken.TokenType in [ttWEND, ttEOF]) and not FStopRequested do
    begin
      if CurrentToken.TokenType = ttEOL then
        Advance
      else
        ExecuteStatement;
    end;
    if Match(ttWEND) then
      FPos := LoopPos;
  end
  else
  begin
    while not (CurrentToken.TokenType in [ttWEND, ttEOF]) do
      Advance;
    Match(ttWEND);
  end;
end;

procedure TQBasicInterpreter.ExecuteWEND;
begin
  // Handled by WHILE
end;

procedure TQBasicInterpreter.ExecuteDO;
begin
  // TODO: Implement DO...LOOP
end;

procedure TQBasicInterpreter.ExecuteLOOP;
begin
  // TODO: Implement DO...LOOP
end;

procedure TQBasicInterpreter.ExecuteGOTO;
var
  LabelPos: Integer;
begin
  if Match(ttIdent) then
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
  if Match(ttIdent) then
  begin
    LabelPos := FindLabel(FTokens[FPos - 1].Value);
    if LabelPos >= 0 then
    begin
      SetLength(FGosubStack, Length(FGosubStack) + 1);
      FGosubStack[High(FGosubStack)] := FPos;
      FPos := LabelPos;
    end;
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
  IsString: Boolean;
begin
  repeat
    if Match(ttIdent) then
    begin
      VarName := FTokens[FPos - 1].Value;
      IsString := False;
      
      if Match(ttAS) then
      begin
        if Match(ttINTEGER) or Match(ttSINGLE) or Match(ttDOUBLE) then
          IsString := False
        else if Match(ttSTRING_TYPE) then
          IsString := True;
      end
      else
      begin
        // Check if variable name ends with $ (string)
        IsString := (Length(VarName) > 0) and (VarName[Length(VarName)] = '$');
      end;
      
      SetVariable(VarName, 0, '', IsString, True);  // ForceLocal = True
    end;
  until not Match(ttComma);
end;

procedure TQBasicInterpreter.ExecuteCALL;
var
  SubName: string;
  SubIdx, i: Integer;
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
    if SubIdx < 0 then Exit;
    
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
    
    // Set parameters
    for i := 0 to High(FSubPrograms[SubIdx].Parameters) do
    begin
      if FSubPrograms[SubIdx].Parameters[i].IsString then
      begin
        if i < Length(StrArgs) then
          SetVariable(FSubPrograms[SubIdx].Parameters[i].Name, 0, StrArgs[i], True);
      end
      else
      begin
        if i < Length(Args) then
          SetVariable(FSubPrograms[SubIdx].Parameters[i].Name, Args[i], '', False);
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

procedure TQBasicInterpreter.ExecuteSELECT;
begin
  // TODO: Implement SELECT CASE
end;

function TQBasicInterpreter.CallFunction(const AName: string): Double;
var
  Args: array of Double;
  StrArgs: array of string;
  BuiltinIdx, SubIdx, i: Integer;
  SavePos, SaveSubIdx: Integer;
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
    if Assigned(FBuiltins[BuiltinIdx].NumFunc) then
      Result := FBuiltins[BuiltinIdx].NumFunc(Args);
    Exit;
  end;
  
  // User function
  SubIdx := FindSubProgram(AName);
  if SubIdx < 0 then Exit;
  
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
  
  // Initialize return variable
  SetVariable(AName, 0, '', False);
  
  // Set parameters
  for i := 0 to High(FSubPrograms[SubIdx].Parameters) do
  begin
    if i < Length(Args) then
      SetVariable(FSubPrograms[SubIdx].Parameters[i].Name, Args[i], '', False);
  end;
  
  // Execute
  FPos := FSubPrograms[SubIdx].StartPos;
  while (FPos <= FSubPrograms[SubIdx].EndPos) and
        (FPos < Length(FTokens)) and
        not FStopRequested do
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
  
  // Get return value
  Result := GetVariableValue(AName);
  
  // Restore state
  FPos := FCallStack[High(FCallStack)].ReturnPos;
  FInSubProgram := FCallStack[High(FCallStack)].WasInSub;
  FCurrentSubIdx := FCallStack[High(FCallStack)].PrevSubIdx;
  SetLength(FCallStack, Length(FCallStack) - 1);
end;

function TQBasicInterpreter.CallStringFunction(const AName: string): string;
var
  Args: array of Double;
  StrArgs: array of string;
  BuiltinIdx: Integer;
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
    Result := FBuiltins[BuiltinIdx].StrFunc(Args, StrArgs);
end;

procedure TQBasicInterpreter.CallBuiltinProc(const AName: string);
var
  Args: array of Double;
  StrArgs: array of string;
  BuiltinIdx: Integer;
begin
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
  if (BuiltinIdx >= 0) and Assigned(FBuiltins[BuiltinIdx].ProcFunc) then
    FBuiltins[BuiltinIdx].ProcFunc(Args, StrArgs);
end;

procedure TQBasicInterpreter.ExecuteStatement;
begin
  if FStopRequested then Exit;
  
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
        if Match(ttSUB) or Match(ttFUNCTION) then
          ExecuteRETURN
        else if Match(ttFOR) then
        begin
          if Length(FForStack) > 0 then
            SetLength(FForStack, Length(FForStack) - 1);
        end;
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
        else if PeekToken.TokenType = ttLParen then
        begin
          // Might be a SUB call or builtin proc
          ExecuteCALL;
        end
        else
          ExecuteLET;
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
          ExecuteRETURN;
          Advance; Advance;
        end
        else
        begin
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
  
  try
    while (CurrentToken.TokenType <> ttEOF) and not FStopRequested do
      ExecuteStatement;
  finally
    FRunning := False;
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
  if Length(Args) > 0 then Result := Int(Args[0]) else Result := 0;
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

function TQBasicInterpreter.BuiltinLEN(const Args: array of Double): Double;
begin
  Result := 0; // LEN needs string arg, handled specially
end;

function TQBasicInterpreter.BuiltinASC(const Args: array of Double): Double;
begin
  Result := 0; // ASC needs string arg
end;

function TQBasicInterpreter.BuiltinVAL(const Args: array of Double): Double;
begin
  Result := 0; // VAL needs string arg
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
  if Length(Args) >= 2 then
    Result := StringOfChar(Chr(Trunc(Args[1]) and 255), Trunc(Args[0]))
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
    ProcFunc := AProc;
    IsProc := True;
  end;
end;

end.
