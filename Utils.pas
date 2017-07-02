unit utils;

interface

uses mmsystem;

const
  SECOND = 1000000000;
  RC_FORM = 101;
  Width  = 640;
  Height = 480;

type
TPoint      = packed record
    x,y     : Longint;
  end;

TRect       = packed record
    case Integer of
      0     : (Left, Top, Right, Bottom  : Longint);
      1     : (TopLeft, BottomRight      : TPoint);
  end;

Results = packed record
  ResultCode:Byte;
  Attributes:Integer;
  Power:Byte;
 end;

ObjectPlayer = Packed record
  X,Y:integer;
  objectType:byte;
  Alive:Boolean;
  Lock:boolean;
end; 

TRespawnPoint = packed record
   Coordinates    : TPoint;
   Theams, Player : Byte;
   StatusPoint    : Byte;
   Vector         : SmallInt;
   CurrentCircle  : byte;
   Active         : Boolean;
 end;

type
ObjectPack = packed record
X,Y:Integer;
Theam, types:byte;
end;

function  IntToStr(I : Integer) : String; overload;
function Bit2Int(d0,d1:byte):integer;
function FillRect(hDC: LongWord; const lprc: TRect; hbr: LongWord): Integer; stdcall;
function GetClientRect(hWnd: LongWord; var lpRect: TRect): LongBOOL; stdcall;
function GetNanoTime:Extended;
procedure PaintObject(DC:LongWord; Mapper,Code,Palette,Index:Byte; X,Y:Integer; Transparent,NoPaint:boolean); overload;
procedure Shtamps(DC:longWord; mDC:LongWord; memory:Pointer; Mapper, Code, Palette, Index:Byte; X, Y:Integer;Transparent,NoPaint:boolean);overload;
procedure ChangePallete(mDC:Longword; Pall, index: byte);
procedure ChangeScenePalette(mDC:Longword; Pall:byte);
function CreateDIB(DC:LongWord; DWidth,DHeight:Integer; var PByteArray:Pointer):LongWord;
Procedure CopyBackground(Memory:Pointer;Mapper, Code, index:Byte; X, Y, MaxLineByte:Integer);
procedure TextOut(DC:LongWord; text:string; X,Y:Integer);overload;
function ModesOne(frame:Integer):Byte;overload;
Function SoundPreapare(var hwo:HWAVEOUT):Boolean;

implementation

uses   Windows, Resources;

function FillRect; external 'user32' name 'FillRect';
function GetClientRect; external 'user32' name 'GetClientRect';

Function SoundPreapare(var hwo:HWAVEOUT):Boolean;
var
  WOutCaps : TWAVEOUTCAPS;
  wfx : TWAVEFORMATEX;
  hEvent : THandle;
begin
result:=false;
  // проверка наличия устройства вывода
  FillChar(WOutCaps,SizeOf(TWAVEOUTCAPS),#0);
  if MMSYSERR_NOERROR <> WaveOutGetDevCaps(0,@WOutCaps,SizeOf(TWAVEOUTCAPS)) then
  begin
   exit;
  end;
  // запуск потока вывода на выполнение
  // заполнение структуры формата
  FillChar(wfx,Sizeof(TWAVEFORMATEX),#0);
  with wfx do begin
    wFormatTag := WAVE_FORMAT_PCM;      // используется PCM формат
    nChannels := 1;                     // это стереосигнал
    nSamplesPerSec := 44100;            // частота дискретизации 44,1 Кгц
    wBitsPerSample := 16;                // выборка 16 бит
    nBlockAlign := wBitsPerSample div 8 * nChannels; // число байт в выбоке для стересигнала -- 4 байта
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign; // число байт в секундном интервале для стереосигнала
    cbSize := 0;     // не используется
  end;
  // открытие устройства
  hEvent := CreateEvent(nil,false,false,nil);
  if WaveOutOpen(@hwo,0,@wfx,0,0,0) <> MMSYSERR_NOERROR then begin
    CloseHandle(hEvent);
    Exit;
  end;
result:=true;
end;


function CreateDIB(DC:LongWord; DWidth,DHeight:Integer; var PByteArray:Pointer):LongWord;
var
  ImgBitInfo:BITMAPINFO;
begin
 with ImgBitInfo.bmiHeader do
 begin
  biSize:=sizeof(ImgBitInfo.bmiHeader);
  biWidth:=DWidth;
  biHeight:=DHeight;
  biPlanes:=1;
  biBitCount:=4;
  biCompression:=0;
  biClrUsed:=4;
end;
  Result:=CreateDIBSection(DC,ImgBitInfo,0,PbyteArray,0,0);
end;

function ModesOne(frame:Integer):Byte;
asm
  AND     AL, $01
end;

function GetNanoTime:Extended;
var
  lpPerformanceCount: Int64;
  lpFrequency: Int64;
begin
  QueryPerformanceCounter(lpPerformanceCount);
  QueryPerformanceFrequency(lpFrequency);
  Result:=lpPerformanceCount/lpFrequency * SECOND;//наносекунды
end;


function IntToStr(I : Integer) : String;
var
  St : String[31];	// for Delphi 2009
begin
  Str(I, St);
  Result := String(St);
end;

function Bit2Int(d0,d1:byte):integer;
asm
      SHL    AX,  3
      ROR    EAX, 4
      SHL    AX,  3
      ROR    EAX, 4
      SHL    AX,  3
      ROR    EAX, 4
      SHL    AX,  3
      ROR    EAX, 4
      SHL    AL,  3
      ROR    EAX, 4
      SHL    AL,  3
      ROR    EAX, 5
      SHL    AL,  3
      ROL    EAX, 1
      SHL    AL,  3
      ROR    EAX, 11
      SHL    DX,  3
      ROR    EDX, 4
      SHL    DX,  3
      ROR    EDX, 4
      SHL    DX,  3
      ROR    EDX, 4
      SHL    DX,  3
      ROR    EDX, 4
      SHL    DL,  3
      ROR    EDX, 4
      SHL    DL,  3
      ROR    EDX, 5
      SHL    DL,  3
      ROL    EDX, 1
      SHL    DL,  3
      ROR    EDX, 10
      OR     EAX, EDX
      BSWAP  EAX
end;




procedure ChangePallete(mDC: longWord; Pall, index: byte);
var
i:byte;
color:integer;
Palletes:array [0..3] of RGBQUAD;
begin
   for i := 0 to 3 do
   begin
    color:=NesColor[palettes[Pall,Index,i]];
    Palletes[i].rgbRed  := GetRValue(color);
    Palletes[i].rgbGreen:= GetGValue(color);
    Palletes[i].rgbBlue := GetBValue(color);
   end;
  SetDIBColorTable(mDC,0,4,Palletes);
end;

procedure ChangeScenePalette(mDC:Longword; Pall:byte);
var
i,l,m:byte;
color:integer;
Palletes:array [$00..$0F] of RGBQUAD;
begin
   for i := 0 to 3 do
   for l := 0 to 3 do
   begin
    m := i * 4 + l;
    color:=NesColor[palettes[pall,i,l]];
    Palletes[m].rgbRed  := GetRValue(color);
    Palletes[m].rgbGreen:= GetGValue(color);
    Palletes[m].rgbBlue := GetBValue(color);
   end;
  SetDIBColorTable(mDC,0,16,Palletes);
end;

procedure PaintObject(DC:LongWord; Mapper, Code, Palette, Index:Byte; X, Y:Integer;Transparent,NoPaint:boolean);
var
ImgBitInfo:BITMAPINFO;
hDC:LongWord;
BufferedImage:LongWord;
PImgArrayPix: Array [0..7] of Integer;
i,color:Integer;
PbyteArray:Pointer;
Palletes:array [0..3] of RGBQUAD;
begin

with ImgBitInfo.bmiHeader do
 begin
  biSize:=sizeof(ImgBitInfo.bmiHeader);
  biWidth:=8;
  biHeight:=8;
  biPlanes:=1;
  biBitCount:=4;
  biCompression:=0;
  biClrUsed:=4;
end;
  BufferedImage :=CreateDIBSection(DC,ImgBitInfo,0,PbyteArray,0,0);
  hdc           :=CreateCompatibleDC(DC);
  SelectObject(hdc, BufferedImage);

   for i := 0 to 3 do
   begin
    color:=NesColor[palettes[Palette,Index,i]];
    Palletes[i].rgbRed  := GetRValue(color);
    Palletes[i].rgbGreen:= GetGValue(color);
    Palletes[i].rgbBlue := GetBValue(color);
   end;
  SetDIBColorTable(hDC,0,4,Palletes);

  for i := 0 to 7 do PImgArrayPix[7-i]:=bit2Int(maps_Tables[Mapper,code,0, i],maps_Tables[Mapper,code,1,i]);
  CopyMemory(PbyteArray, @PImgArrayPix, 32);

  if not NoPaint then
  if Transparent then TransparentBlt(dc,x,y,8,8,hdc,0,0,8,8,NesColor[palettes[Palette,Index,0]])
  else BitBLT(DC,x,y,x+8,y+8,hdc,0,0,SRCCOPY);

  ReleaseDC(hDC,BufferedImage);
  DeleteDC(hDC);
  DeleteObject(BufferedImage);
end;

procedure Shtamps(DC:longWord; mDC:LongWord; memory:Pointer; Mapper, Code, Palette, Index:Byte; X, Y:Integer; Transparent,NoPaint:boolean);
var
PImgArrayPix: Array [0..7] of Integer;
i:Integer;
begin
  for i := 0 to 7 do PImgArrayPix[7-i]:=bit2Int(maps_Tables[Mapper,code,0, i],maps_Tables[Mapper,code,1,i]);
  CopyMemory(memory, @PImgArrayPix, 32);
  if not NoPaint then
  if Transparent then TransparentBlt(dc,x,y,8,8,mdc,0,0,8,8,NesColor[palettes[Palette,Index,0]])
  else BitBLT(DC,x,y,x+8,y+8,mdc,0,0,SRCCOPY);
end;

Procedure CopyBackground(Memory:Pointer; Mapper, Code, index:Byte; X, Y, MaxLineByte:Integer);
var
PImgArrayPix: Integer;
i:Integer;
mask:integer;
begin
  for i := 0 to 7 do begin
  PImgArrayPix:=bit2Int(maps_Tables[Mapper,code,0, i],maps_Tables[Mapper,code,1,i]);
  mask:= (PImgArrayPix and $11111111 shl 2) or (PImgArrayPix and $22222222 shl 1);
  mask:= (mask shl 1 or mask) and ($44444444 * index);
  PImgArrayPix := PImgArrayPix or mask;
  CopyMemory(pointer(integer(memory) + (Height - I - Y * 8) * MaxLineByte + X*4), @PImgArrayPix, 4);
  end;
end;

procedure TextOut(DC:LongWord; text:string; X,Y:Integer);
var
i:integer;
Begin
  for I := 1 to Length(Text) do PaintObject(DC,1,ORD(Text[i]),4,0,X+((i-1)*8),Y, True,false);
End;

end.
