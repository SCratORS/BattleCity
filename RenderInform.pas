unit RenderInform;

interface

uses Windows, Utils;

  Type
  TRenderInform = Class
    Private
    HDC: LongWord;
    BufferedImage:LongWord;
    PbyteArray:Pointer;
    mDC:LongWord;
    PlayersCount:Byte;
    PlayersLives: Array of Byte;
    LevelNumer:Byte;
    maxTank:byte;
    Public
    Constructor Create(DC:LongWord);Overload;
    Destructor Destroy;Override;
    Procedure Render;
    Procedure SetLengthPlay(Leng:integer);
    Procedure SetLives(PlayerIndex,Count:byte);
    Procedure SetLevels(l:byte);
    Procedure DecTank;
    Procedure DecLives(pl:byte);
    Procedure SetMaxTank(m:byte);
  End;

implementation

{ TRenderInform }

constructor TRenderInform.Create(DC: LongWord);
begin
  HDC:=DC;
  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject(mdc, BufferedImage);
  ChangePallete(mdc, 0,0);
end;

procedure TRenderInform.DecLives(pl: byte);
begin
if PlayersLives[pl]>0 then 
 PlayersLives[pl]:=PlayersLives[pl]-1;
end;

procedure TRenderInform.DecTank;
begin
if maxTank>0 then Dec(maxTank);
end;

destructor TRenderInform.Destroy;
begin
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);
  inherited;
end;

procedure TRenderInform.Render;
var
i:byte;
ofset:byte;
dv:byte;
begin
if maxTank>0 then  begin
for I := 0 to maxTank-1 do Shtamps(HDC, mDC, PbyteArray,1,$6A,3,3,(77 + (i mod 2))*8,(2+(i div 2))*8,False,False);
end;
for I := 0 to PlayersCount-1 do begin
ofset:= i*3;
Shtamps(HDC, mDC, PbyteArray,1,$6F+I,3,3,77*8,(42+ofset)*8,False,False);
Shtamps(HDC, mDC, PbyteArray,1,$13,3,3,78*8,(42+ofset)*8,False,False);
if PlayersLives[i]>0 then begin
dv:=(PlayersLives[i]-1) div 10;
if dv = 0 then
Shtamps(HDC, mDC, PbyteArray,1,$14,3,3,77*8,(43+ofset)*8,False,False) else
Shtamps(HDC, mDC, PbyteArray,1,$6E+ dv,3,3,77*8,(43+ofset)*8,False,False);
Shtamps(HDC, mDC, PbyteArray,1,$6E+(PlayersLives[i]-1) mod 10 ,3,3,78*8,(43+ofset)*8,False,False);
end else
Shtamps(HDC, mDC, PbyteArray,1,$6E,3,3,78*8,(43+ofset)*8,False,False);
end;

Shtamps(HDC, mDC, PbyteArray,1,$6C,3,3,77*8,54*8,False,False);
Shtamps(HDC, mDC, PbyteArray,1,$FC,3,3,78*8,54*8,False,False);
Shtamps(HDC, mDC, PbyteArray,1,$6D,3,3,77*8,55*8,False,False);
Shtamps(HDC, mDC, PbyteArray,1,$FD,3,3,78*8,55*8,False,False);

dv:=LevelNumer div 10;
if dv = 0 then
Shtamps(HDC, mDC, PbyteArray,1,$11,3,3,77*8,56*8,False,False) else
Shtamps(HDC, mDC, PbyteArray,1,$6E+ dv,3,3,77*8,56*8,False,False);
Shtamps(HDC, mDC, PbyteArray,1,$6E+ LevelNumer mod 10 ,3,3,78*8,56*8,False,False);


end;

procedure TRenderInform.SetLengthPlay(Leng: integer);
begin
PlayersCount:=Leng;
SetLength(PlayersLives, Leng);
end;

procedure TRenderInform.SetLevels(l: byte);
begin
   LevelNumer:=l;
end;

procedure TRenderInform.SetLives(PlayerIndex, Count: byte);
begin
 PlayersLives[PlayerIndex]:=Count;
end;

procedure TRenderInform.SetMaxTank(m: byte);
begin
maxTank:=m;
end;

end.
