unit gwbasic;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure SetGWStartLineNumber(start : integer);
function GetGWNextLineNumber : string;
function LineCountToStr(Lan : integer) : string;

implementation
const
 GWLan   = 7;
var
 GWBasicLineNumber : integer;

procedure SetGWStartLineNumber(start : integer);
begin
 GWBasicLineNumber :=start;
end;

function GetGWNextLineNumber : string;
begin
 GetGWNextLineNumber:=IntToStr(GWBasicLineNumber);
 inc(GWBasicLineNumber,10);
end;


function LineCountToStr(Lan : integer) : string;
begin
 LineCountToStr:='';
 if (lan=GWLan) then
 begin
   LineCountToStr:=GetGWNextLineNumber+' ';
 end;
end;

end.

