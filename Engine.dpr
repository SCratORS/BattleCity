program Engine;
{$R Engine.res}
{$Hints off}
{$I-} {$D-}
{$SetPEFlags 1}

uses
  Windows,
  Utils in 'Utils.pas',
  GameThread in 'GameThread.pas',
  Resources in 'Resources.pas',
  Bulet in 'Bulet.pas',
  Enemy in 'Enemy.pas',
  Maps in 'Maps.pas',
  BoomAnim in 'BoomAnim.pas',
  CollisionMap in 'CollisionMap.pas',
  Respawn in 'Respawn.pas',
  PlayerBase in 'PlayerBase.pas',
  Bonus in 'Bonus.pas',
  RenderInform in 'RenderInform.pas',
  Shores in 'Shores.pas',
  Curtain in 'Curtain.pas';

var
GamesThread : TGameThread;
procedure FreeAll;
begin
  GamesThread.StopThread;
  ChangeDisplaySettings(devmode(nil^), 0);
  ShowCursor(True);
  PostQuitMessage(0);
  Halt;
end;

procedure resize(hwnd:LongWord);
begin
MoveWindow(hWnd,0,0,Width,Height,true);
MoveWindow(GetDlgItem(hWnd,1),0,0,Width,Height,true);
SetForegroundWindow(hwnd);
end;

function GetFullScreen(cd:word):boolean;
var
  dmScreenSettings : DEVMODE;
begin

 with dmScreenSettings do
 begin
  dmSize := SizeOf(dmScreenSettings);
  dmBitsPerPel := cd;
  dmPelsWidth := Width;
  dmPelsHeight := Height;
  dmFields := $40000 or $80000 or $100000;
end;
  result:=ChangeDisplaySettings(dmScreenSettings, $00000004) = 0;
  ShowCursor(not Result);
end;

function MainDlgFunc(hWnd : LongWord; uMsg : LongWord; wParam, lParam : Integer) : LongBOOL; stdcall;
begin
  Result := TRUE;
  case uMsg of
    $0110   : begin
              GetFullScreen(32);
              resize(hwnd);
              GamesThread := TGameThread.Create(hWnd);                          // WM_INITDIALOG:
              end;
    $0002,                                                                      // WM_DESTROY
    $0010   : FreeAll;                                                          // WM_CLOSE
    $0111: case wParam of                                                       // WM_COMMAND
           101: FreeAll;
           end;
  else begin
    Result := FALSE;
  end;
  end;
end;

begin
LoadGrafics;
DialogBox(hInstance, PChar(RC_FORM), 0, @MainDlgFunc);
end.
