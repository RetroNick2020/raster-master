//Example script to show usage in RM
//From Script Menu - Select Load from file
//After script is loaded you may run the script from Script->Run
//You can run script as many times as you want. Select Load  from file
//to change script files
Program RMScript1;
var
 i,j : integer;
 filename,ext : string;
 active,x1,x2,y1,y2,size : integer;
begin
  getselectarea(active,x1,y1,x2,y2);

  if active = 0 then  //select area tool not active - save entire image
  begin
    x1:=0;
    y1:=0;
    x2:=getwidth-1;  //get width of current image
    y2:=getheight-1; //get height of current image
  end;
  size:=(x2-x1+1)*(y2-y1+1);

  filename:='';
  ext:='';
  if getsavefilename(filename,ext,'Pascal|*.pas|All Files|*.*')  then
  begin
   if cgopen(filename) then
   begin
    //cgoptions must be passed as string values otherwise i would need to create too many wrapper functions 
    cgoptions('Lan','PascalLan');
    cgoptions('ValueFormat','Hex');  //Decimal is the other options
   
    cgoptions('ValuesTotal',IntToStr(size)); // important - this is required put total # of elements we will need for array
    cgoptions('ValuesPerLine','20'); // array elements per line
    cgoptions('Indent','10'); // how many columns to indent
    cgoptions('IndentOnFirstLine','Yes'); // first line of array elements

    cgwrite('(* Pascal code generated from Raster Master Script File *)');
    cgwriteln;
    // we add the begining of the array const - top bun
    cgwrite(' Image1 : array[0..');
    cgwrite(IntToStr(size-1));
    cgwrite('] of Byte = (');
    cgwriteln;

    // we add the middle code - meat pattie
    for j:=y1 to y2 do 
    begin
      for i:=x1 to x2 do
      begin
        // use cgwritebyte or cgwriteinteger to dump array values
        cgwritebyte(getpixel(i,j));  // we just dump data - code gen will format where to put comma/line feed    
      end;
    end;
    // we add the bottom bun
    cgwrite(');');  
    cgwriteln;
    cgclose;
   end;
 end; 
// you can add message if you like to indicate script finisged
// ShowMessage('Code generated for your Image!');
end.
