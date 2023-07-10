unit rmclipboard;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,ClipBrd;

procedure EraseFile(const FileName: string);
function GenerateRandomFilename: string;
function GetTemporaryPath: string;
function GetTemporaryPathAndFileName: string;
function GetTemporaryPathWithProvidedFileName(filename : string) : string;

procedure ReadFileAndCopyToClipboard(const FileName: string);
implementation

procedure EraseFile(const FileName: string);
begin
  if FileExists(FileName) then
    DeleteFile(FileName);
end;

function GenerateRandomFilename: string;
var
  RandomString: string;
begin
  // Generate a random string or number to use in the filename
  RandomString := IntToHex(Random(MaxInt), 8); // Generate a random 8-character hexadecimal string

  // Get the current timestamp as a string
  Result := FormatDateTime('yyyymmdd_hhnnss', Now);

  // Combine the timestamp and random string to create the random filename
  Result := Result + '_' + RandomString + '.txt';
end;

function GetTemporaryPathAndFileName: string;
begin
  // Get the temporary directory based on the operating system
  Result := GetTempDir;
  // Generate a unique file name within the temporary directory
  Result := IncludeTrailingPathDelimiter(Result) + GenerateRandomFilename;
end;

function GetTemporaryPathWithProvidedFileName(filename : string) : string;
begin
  // Get the temporary directory based on the operating system
  Result := GetTempDir;
  // Generate a unique file name within the temporary directory
  Result := IncludeTrailingPathDelimiter(Result) + filename;
end;

function GetTemporaryPath: string;
begin
  // Get the temporary directory based on the operating system
  Result := GetTempDir;
end;

procedure ReadFileAndCopyToClipboard(const FileName: string);
var
  FileContents: TStringList;
begin
  // Create a TStringList to store the contents of the file
  FileContents := TStringList.Create;
  try
    // Load the file contents into the TStringList
    FileContents.LoadFromFile(FileName);
    // Copy the contents to the clipboard
    Clipboard.AsText := FileContents.Text;
  finally
    // Free the TStringList
    FileContents.Free;
  end;
end;

end.

