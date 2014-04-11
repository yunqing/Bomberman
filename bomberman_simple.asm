
.386
.model flat,STDCALL


	INCLUDE gdi32.inc 
	INCLUDE msimg32.inc
	INCLUDELIB gdi32.lib
	INCLUDELIB msimg32.lib
INCLUDE GraphWin.inc
INCLUDELIB irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
	INCLUDE sth.inc ;自己写的头文件

WriteDec PROTO ; 打印十进制数，详情见Irvine32.asm
Crlf PROTO ; 打印换行到标准输出

.data

WindowName BYTE "BomberMan",0
className BYTE "BomberMan",0
imgName BYTE "djb.bmp",0

MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL,COLOR_WINDOW,NULL,className>

msg MSGStruct <>
winRect RECT <>
hMainWnd DWORD ?
hInstance DWORD ?

hbitmap DWORD ?
hdcMem DWORD ?
hdcPic DWORD ?
hdc DWORD ?
holdbr DWORD ?
holdft DWORD ?
ps PAINTSTRUCT <>

BreakWallType DWORD 0
BreakWallPos DWORD 0
TankToBreak DWORD 0
DirectionMapToW DWORD 4,2,3,1
BulletMove DWORD 7,0,-7,0,0,7,0,-7
TankMove DWORD 3,0,-3,0,0,3,0,-3,3,0,-3,0,0,3,0,-3,5,0,-5,0,0,5,0,-5
BulletPosFix DWORD 10,0,-10,0,0,10,0,-10
DrawHalfSpiritMask DWORD 32,32,16,16,16,16,32,32,0,0,0,16,0,16,0,0
ScoreText BYTE "000000",0
RandomPlace DWORD 64,224,384

WaterSpirit DWORD ?		; 水的图片，需要x/8+3
WhichMenu DWORD 2			; 哪个界面，0表示开始，1表示选择游戏模式，2表示正在游戏，3表示游戏结束
ButtonNumber DWORD 2,3,0,2	; 每个界面下的图标数
SelectMenu DWORD 0			; 正在选择的菜单项
GameMode DWORD 0			; 游戏模式 0为闯关模式，1为挑战模式

UpKeyHold DWORD 0
DownKeyHold DWORD 0
LeftKeyHold DWORD 0
RightKeyHold DWORD 0
SpaceKeyHold DWORD 0
EnterKeyHold DWORD 0




; my api




; BMP 的宽度（一行元素块的个数）
my_BMP_LENGTH = 10
; 绘图时当做透明处理的颜色
my_BMP_TRANSPARENT_COLOR = 7ac443h

; 位图中的元素块的位置编号 （从 0 开始）
ID_GROUND_IN_BMP = 90
ID_STONE_IN_BMP = 36
ID_BRICK_IN_BMP = 37
ID_BRICK_DYING_IN_BMP = 50
ID_DOOR_IN_BMP = 91
ID_RIGHT_MAN_IN_BMP = 16
ID_LEFT_MAN_IN_BMP = 26
ID_RIGHT_DYING_MAN_IN_BMP = 40
ID_LEFT_DYING_MAN_IN_BMP = 30
ID_RIGHT_GHOST_IN_BMP = 6
ID_LEFT_GHOST_IN_BMP = 3
ID_RIGHT_DYING_GHOST_IN_BMP = 20
ID_LEFT_DYING_GHOST_IN_BMP = 10

ID_BOMB_IN_BMP = 0


; 方向
DIRECTION_DOWN = 1
DIRECTION_LEFT = 2
DIRECTION_UP = 3
DIRECTION_RIGHT = 0

; 窗体大小
my_WINDOW_PX_WIDTH = 1034 ; 1024 + 10
my_WINDOW_PX_HEIGHT = 702 ; 672 + 31

; 游戏幕布大小，包括地图区域和
my_GAME_CANVAS_PX_WIDTH = 1024
my_GAME_CANVAS_PX_HEIGHT = 672

; 游戏幕布到窗体左边的距离
my_CANVAS_WINDOW_LEFT_SHIFT = 176

; 游戏地图像素大小(即元素出现的边界)
my_MAP_PX_WIDTH = 672
my_MAP_PX_HEIGHT = 672

; 地图大小，即一行内元素块的个数
my_MAP_BLOCKS_PER_ROW = 21
; 地图大小，所有元块的个数
my_MAP_BLOCKS_TOTAL = 441


KEY_CODE_UP = 38
KEY_CODE_DOWN = 40
KEY_CODE_LEFT = 37
KEY_CODE_RIGHT = 39
KEY_CODE_ENTER = 13
KEY_CODE_SPACE = 32
KEY_CODE_ESC = 27


MAX_GHOST_NUM = 10
MAX_BOMB_NUM = 2
MAN_SPRITE_ID_TIME_SCALE = 5
ManSpriteID DWORD 0,0,0 ; 小人存在时的运动状态(1收缩，2正常，3伸展), 在变大还是变小 (1变大, 2变小), timescale(0~5,达到 MAN_SPRITE_ID_TIME_SCALE 时调整运动状态，随机清零)
GhostStretching DWORD 0 ; 鬼在变大还是变小（1 变大， 2 变小）
GhostSpriteID DWORD MAX_GHOST_NUM DUP(0) ; 鬼存在时的运动状态（0无效，1收缩，2正常，3伸展）
BombStretching DWORD 0 ; 炸弹在变大还是变小 (1=变大，2=变小)
BombSpriteID DWORD MAX_BOMB_NUM DUP(0) ; 炸弹运动状态（0无效，1收缩，2正常，3伸展）

; 0=土地,1=水,2=树,3=墙,4~7=各种墙(上下左右),8=老家,11=铁,12~15=各种铁
; 0=土地,1=门,2（未使用）,3=砖墙,4~9(爆炸过程的砖墙),11=石头
;Map			DWORD 225 DUP(?)
Map			DWORD my_MAP_BLOCKS_TOTAL DUP(?)

; 约定所有实体上下移动时，面部朝右
; 类型(0表示不存在，1 表示正常, 2~7 表示死亡), X, Y, 方向
PlayerMan DWORD 0,0,0,0
; 类型(0=不存在,1=存在,2~7=爆炸), X, Y, timescale(到达阈值才爆炸，爆炸后清零), L(左边是否被炸), T, R, D
Bombs 	DWORD 0,0,0,0,0,0,0,0
		DWORD 0,0,0,0,0,0,0,0

; 类型(0=不存在,1=存在,2~7=死亡), X, Y, 方向
Ghost	DWORD 0,0,0,0
		DWORD 0,0,0,0
		DWORD 0,0,0,0
		DWORD 0,0,0,0
		DWORD 0,0,0,0
		DWORD 0,0,0,0
		DWORD 0,0,0,0
		DWORD 0,0,0,0
		DWORD 0,0,0,0
		DWORD 0,0,0,0

Door DWORD 0,0 ; 门的位置(取值范围是 {1、3、5、7、9、11、13、15、17、19} ), 注意必须与地图中的砖墙重合


; 类型(0=不存在,1=玩家坦克,2=未使用,3=普通,4=强化,5=快速),X,Y,方向,子弹类型(0=不存在,1=存在,2~9=爆炸),子弹X,Y,方向
YourTank	DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
EnemyTank	DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
YourLife	DWORD 0,0
EnemyLife	DWORD 0,0,0
Score		DWORD 0,0
Round		DWORD 0
WaitingTime	DWORD -1
YouDie		DWORD 0

			; Round 0 (挑战模式)
RoundMap	DWORD  3, 3, 0, 3, 3, 3, 3, 0, 3, 3, 3, 3, 0, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11, 3,11, 3,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3,11,11, 3,11, 3,11,11,11, 3,11, 3,11,11, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11,11, 3,11, 3,11,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11,11,11,11,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11, 3, 3, 3,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 0,11, 3, 8, 3,11, 0, 3, 3, 3, 3
			; Round 1                                    
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 3, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 3, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0,12, 0, 0, 0, 0, 0, 0, 0
			DWORD 11, 0, 3, 3, 0, 0,13, 0,13, 0, 0, 3, 3, 0,11
			DWORD  1, 0, 3, 0, 0, 0, 3, 3, 3, 0, 0, 0, 3, 0, 1
			DWORD  1, 0, 3, 0, 0, 0, 3, 8, 3, 0, 0, 0, 3, 0, 1
			; Round 2
			DWORD  0, 0, 0, 5, 6, 7, 0, 0,13,14,15, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 2, 2,11, 0, 0, 0, 0
			DWORD  0, 0, 3, 3, 0, 0, 3, 0, 2, 3,11, 0, 3, 3, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 0, 3, 0,11, 3, 0, 0, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 3, 0, 0,11, 0, 3, 3, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 3, 0, 0,11, 0, 0, 0, 1
			DWORD  0, 3, 0, 3, 3, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1
			DWORD  0, 0, 3, 3, 3, 1, 1, 1, 1, 1, 0, 3, 3, 3, 0
			DWORD  0, 0, 0, 0, 3, 0, 3, 2, 2, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 3, 3, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 3, 3, 3,11, 3, 3, 3, 3, 3, 3, 3
			DWORD  0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 3, 0, 0, 0, 3, 8, 3, 0, 0, 0, 0, 0, 1

BomberManMap_15	DWORD  11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11,11,11,11,11,11,11,11,11,11,11,11,11,11,11

BomberManMap 	DWORD  11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
				DWORD  11, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 3, 3, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 3,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,11
				DWORD  11, 0,11, 0,11, 3,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 4,11
				DWORD  11, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 5,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 6,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 3,11, 0,11, 0,11, 8,11
				DWORD  11, 0, 0, 3, 3, 0, 0, 0, 3, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 9,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 1,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
Door DWORD 12,15   ; 门的位置

RoundEnemy	DWORD 999,999,999,8,0,0,8,0,0
RoundSpeed	DWORD 1,60,60,60

.code
WinMain:
		call Randomize

		push NULL
		call GetModuleHandle
		mov hInstance,eax
		
		push 999
		push hInstance
		call LoadIcon
		mov MainWin.hIcon,eax

		push IDC_ARROW
		push NULL
		call LoadCursor
		mov MainWin.hCursor,eax
		
		push offset MainWin
		call RegisterClass
		cmp eax,0
		je ExitProgram
		
		push NULL
		push hInstance
		push NULL
		push NULL
		;push 510
		push my_WINDOW_PX_HEIGHT
		;push 650
		push my_WINDOW_PX_WIDTH
		push CW_USEDEFAULT
		push CW_USEDEFAULT
		push (WS_BORDER+WS_CAPTION+WS_SYSMENU) ;MAIN_WINDOW_STYLE
		push offset WindowName
		push offset className
		push 0
		call CreateWindowEx
		cmp eax,0
		je ExitProgram
		mov hMainWnd,eax
		
		push SW_SHOW
		push hMainWnd
		call ShowWindow
		
		push hMainWnd
		call UpdateWindow
		
	MessageLoop:
		push NULL
		push NULL
		push NULL
		push offset msg
		call GetMessage
		
		cmp eax,0
		je ExitProgram
		
		push offset msg
		call TranslateMessage ; Translates virtual-key messages into character messages. 
		push offset msg
		call DispatchMessage
		
		jmp MessageLoop

	ExitProgram:
		push 0
		call ExitProcess
	
WinProc: ; hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
         ; 参数从右向左压栈，从左向右地址升高


		push ebp
		mov ebp,esp

		; 由于WinProc最后是ret的，所以，栈上面压了返回地址：[ebp+4]
		
		mov eax,[ebp+12] ; 对应 localMsg:DWORD
		
		cmp eax,WM_CREATE
		je CreateWindowMessage
		cmp eax,WM_CLOSE
		je CloseWindowMessage
		cmp eax,WM_PAINT ;  The message is sent when the UpdateWindow or RedrawWindow function is called
		je PaintMessage
		cmp eax,WM_TIMER
		je TimerMessage
		cmp eax,WM_KEYDOWN
		je KeyDownMessage
		cmp eax,WM_KEYUP
		je KeyUpMessage
		
		jmp OtherMessage
	

	CreateWindowMessage:
		mov eax,[ebp+8]
		mov hMainWnd,eax
	
	; 设置计时器
		push NULL ;If lpTimerFunc is NULL, the system posts a WM_TIMER message to the application queue
		push 30 ; The time-out value, in milliseconds.
		push 1 ; A nonzero timer identifier
		push hMainWnd ; A handle to the window to be associated with the timer.
		call SetTimer ;The time-out value, in milliseconds.
	; 获得设备上下文 hdc
		push hMainWnd
		call GetDC ; retrieves a handle to a device context (DC)
		mov hdc,eax
		
	; 根据刚获得的设备上下文 hdc，创建内存中设备上下文 hdcPic
		push eax
		call CreateCompatibleDC ; creates a memory device context (DC) compatible with the specified device.
		mov hdcPic,eax
	; 加载图片到模块 hInstance 中，得到 hbitmap
		push 0 ; LR_DEFAULTCOLOR = 0. The default flag; it does nothing. All it means is "not LR_MONOCHROME".
		push 0 ; If this parameter is zero and LR_DEFAULTSIZE is not used, the function uses the actual resource height.
		push 0 ; If this parameter is zero and LR_DEFAULTSIZE is not used, the function uses the actual resource width.
		push 0 ; IMAGE_BITMAP = 0, Loads a bitmap.
		push 1001 ; the lpszName parameter is a pointer to a null-terminated string that contains the name of the image resource.
		push hInstance
		call LoadImageA
		mov hbitmap,eax ;  the handle of the newly loaded image
	; 把刚加载的图片 hbitmap ，添加到内存中的设备上下文 hdcPic
		push hbitmap
		push hdcPic ; A handle to the DC.
		call SelectObject ;  selects an object into the specified device context (DC). The new object replaces the previous object of the same type.

	; 再根据设备上下文 hdc，创建一个内存中的设备上下文 hdcMem，用于双缓冲
		push hdc
		call CreateCompatibleDC
		mov hdcMem,eax
    ; 创建一个与设备上下文 hdc 一致的位图 hbitmap
		;push 480 ; he bitmap height, in pixels.
		push my_GAME_CANVAS_PX_HEIGHT ; he bitmap height, in pixels.
		;push 640 ; The bitmap width, in pixels.
		push my_GAME_CANVAS_PX_WIDTH ; The bitmap width, in pixels.
		push hdc ; A handle to a device context.
		call CreateCompatibleBitmap ; creates a bitmap compatible with the device that is associated with the specified device context.
		mov hbitmap,eax ; a handle to the compatible bitmap (DDB).
	; 把位图 hbitmap添加到内存中设备上下文 hdcMem
		push hbitmap
		push hdcMem
		call SelectObject
	; 设置内存缓冲区 hdcMem 文字颜色
		push 0FFFFFFh
		push hdcMem
		call SetTextColor ; sets the text color for the specified device context to the specified color.
	; 设置内存缓冲区 hdcMem 背景颜色	
		push 0
		push hdcMem
		call SetBkColor ; sets the current background color to the specified color value
    ; 释放设备上下文 hdc
		push hdc
		push hMainWnd
		call ReleaseDC ; releases a device context (DC), freeing it for use by other applications. 

;设置地图
		mov Round, 0 ; [调试]：为便于调试临时设为0 

		mov eax,[Round]
		;mov ebx,225*4    ; 一个地图的内存字节数，因为地图是 DWORD 类型的
		mov ebx,my_MAP_BLOCKS_TOTAL*4    ; 一个地图的内存字节数，因为地图是 DWORD 类型的

		mul ebx
		mov ebx,eax
		;mov ecx,225
		mov ecx,my_MAP_BLOCKS_TOTAL
	SetMap:     						; 通过一个循环复制地图
		;mov eax,[RoundMap+ebx+ecx*4-4]   ;  [调试]：原来的语句
		mov eax,[BomberManMap+ebx+ecx*4-4]     ;  [调试]：修改了的语句
		mov [Map+ecx*4-4],eax
		loop SetMap

		jmp WinProcExit
		
	CloseWindowMessage:
		push 0
		call PostQuitMessage
		push 1
		push hMainWnd
		call KillTimer
		jmp WinProcExit

	KeyDownMessage:
		mov eax,[ebp+16] ; 对应  wParam:DWORD, 含有 The virtual-key code of the nonsystem key.

		cmp eax,KEY_CODE_UP
		jne @nup1
		;call UpInMenu ;[调试]暂时取消
		mov UpKeyHold,1
	@nup1:
		cmp eax,KEY_CODE_DOWN
		jne @ndown1
		;call DownInMenu ;[调试]暂时取消
		mov DownKeyHold,1
	@ndown1:
		cmp eax,KEY_CODE_LEFT
		jne @nleft1
		mov LeftKeyHold,1
	@nleft1:
		cmp eax,KEY_CODE_RIGHT
		jne @nright1
		mov RightKeyHold,1
	@nright1:
		cmp eax,KEY_CODE_SPACE
		jne @nspace1
		mov SpaceKeyHold,1
		; call EnterInMenu ; [调试]暂时取消
	@nspace1:
		cmp eax,KEY_CODE_ENTER
		jne @nenter1
		mov EnterKeyHold,1
		;call EnterInMenu  ; [调试]暂时取消
	@nenter1:
		cmp eax,KEY_CODE_ESC
		jne @nescape1
		;call EscapeInMenu  ;
	@nescape1:
		
		jmp WinProcExit
		
	KeyUpMessage:
		mov eax,[ebp+16]

		cmp eax,38
		jne @nup2
		mov UpKeyHold,0
	@nup2:
		cmp eax,40
		jne @ndown2
		mov DownKeyHold,0
	@ndown2:
		cmp eax,37
		jne @nleft2
		mov LeftKeyHold,0
	@nleft2:
		cmp eax,39
		jne @nright2
		mov RightKeyHold,0
	@nright2:
		cmp eax,32
		jne @nspace2
		mov SpaceKeyHold,0
	@nspace2:
		cmp eax,13
		jne @nenter2
		mov EnterKeyHold,0
	@nenter2:
	
		jmp WinProcExit
		

	PaintMessage:
		push offset ps
		push hMainWnd
		call BeginPaint ;  prepares the specified window for painting and fills a PAINTSTRUCT structure with information about the painting.
		mov hdc,eax ;  the handle to a display device context for the specified window.

	; 把黑色刷子添加到内存缓冲区 hdcMem	
		push BLACK_BRUSH
		call GetStockObject ; retrieves a handle to one of the stock pens, brushes, fonts, or palettes.
		
		push eax ; a handle to the requested logical object.
		push hdcMem
		call SelectObject
		mov holdbr,eax  ; a handle to the object being replaced. 旧刷子
	
	; 把fixed的font添加到内存缓冲区 hdcMem	
		push SYSTEM_FIXED_FONT
		call GetStockObject
		
		push eax
		push hdcMem
		call SelectObject
		mov holdft,eax ; 旧 font

	; 画一个矩形	
		;push 480 ; The y-coordinate, in logical coordinates, of the lower-right corner of the rectangle.
		push my_GAME_CANVAS_PX_HEIGHT ;  [调试]The y-coordinate, in logical coordinates, of the lower-right corner of the rectangle.
		;push 640 ; The x-coordinate, in logical coordinates, of the lower-right corner of the rectangle.
		push my_GAME_CANVAS_PX_WIDTH ; [调试]The x-coordinate, in logical coordinates, of the lower-right corner of the rectangle.
		push 0 ; The y-coordinate, in logical coordinates, of the upper-left corner of the rectangle.
		push 0 ; The x-coordinate, in logical coordinates, of the upper-left corner of the rectangle.
		push hdcMem
		call Rectangle ; draws a rectangle

		call DrawUI
		
	; 恢复原来的刷子	
		push holdbr
		push hdcMem
		call SelectObject
	; 恢复原来的font
		push holdft
		push hdcMem
		call SelectObject
		
	; 把内存中的设备上下文 hdcMem 拷到设备上下文 hdc 中
		push SRCCOPY
		push 0
		push 0
		push hdcMem
		;push 480
		push my_GAME_CANVAS_PX_HEIGHT ; [调试]
		;push 640
		push my_GAME_CANVAS_PX_WIDTH ; [调试]
		push 0
		push 0
		push hdc
		call BitBlt
		
		push offset ps
		push hMainWnd
		call EndPaint
		
		jmp WinProcExit
	
	TimerMessage:
	
		;call TimerTick

	; 调用 RedrawWindow，会 post WM_PAINT 消息
		push 1 ; RDW_INVALIDATE. Invalidates lprcUpdate or hrgnUpdate (only one may be non-NULL). If both are NULL, the entire window is invalidated.
		push NULL
		push NULL ;  If both the hrgnUpdate and lprcUpdate parameters are NULL, the entire client area is added to the update region.
		push hMainWnd ; A handle to the window to be redrawn.
		call RedrawWindow ; updates the specified rectangle or region in a window's client area.

		jmp WinProcExit
		
	OtherMessage:
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call DefWindowProc
		
	WinProcExit:
		mov esp,ebp
		pop ebp
		ret 16
		
DrawUI:
		

	DrawGame:

		call DrawGround
		call DrawWall
		call DrawMan
		call DrawBomb
		call DrawGhost
		
		jmp DrawUIReturn


	DrawUIReturn:
		ret
	

		
DrawSpirit:
		push ebp
		mov ebp,esp

		;mov eax,[ebp+8] ; 对应图片块 id ， 第1个参数
		;mov ebx,eax

		mov eax,[ebp+8]
		mov edx,0
		mov ebx,my_BMP_LENGTH
		div ebx

		sal eax,5   ; Y
		sal edx,5   ; X
		mov ebx,edx

		; 由 id（位图中图片块的顺序编号） 计算出图片块的坐标
		;sar eax,3
		;and ebx,7h
		;sal eax,5
		;sal ebx,5




		;push 0FF00h ; just green and no red and blue , 把这种颜色当做透明处理
		push my_BMP_TRANSPARENT_COLOR ;  把这种颜色当做透明处理
		

		push 32      ; 源矩形高度
		push 32      ; 源矩形宽度
		push eax	 ; 源矩形Y坐标，逻辑单位
		push ebx     ; 源矩形X坐标，逻辑单位

		push hdcPic ; A handle to the source device context.

		push 32 ; 目标矩形高度
		push 32 ; 目标矩形宽度
		push [DWORD PTR ebp+16] ; 目标Y位置，逻辑单位，矩形的左上角 
								; The y-coordinate, in logical units, of the upper-left corner of the destination rectangle.
		push [DWORD PTR ebp+12] ; 目标X位置，逻辑单位，矩形的左上角 
								; The x-coordinate, in logical units, of the upper-left corner of the destination rectangle.

		push hdcMem 		; A handle to the destination device context.

		call TransparentBlt 	; The TransparentBlt function performs a bit-block transfer 
								; of the color data corresponding to a rectangle of pixels 
								; from the specified source device context
								; into a destination device context.

		mov esp,ebp
		pop ebp

		ret 12




		
; 画地面，地毯式绘图
DrawGround:
		;mov ecx,225  ;  15 * 15 ， 对于地图的每一个角落
		mov ecx,my_MAP_BLOCKS_TOTAL  ;  15 * 15 ， 对于地图的每一个角落

	DrawGroundLoop:
		mov edx,0
		mov eax,ecx
		dec eax

		;mov esi,15 ; 一行15个
		mov esi, my_MAP_BLOCKS_PER_ROW ; 一行多少个元素块

		div esi
		sal edx,5   ; 相当于 乘以 32
		sal eax,5

		;add edx,80  ; 80  = 0101 0000  
		add edx,my_CANVAS_WINDOW_LEFT_SHIFT  ; 加上与窗体左边缘的距离偏移

	
	; 画一块地面
		push ecx ; 把 ecx 压栈，为了保护 ecx 的值，之后会弹出
		push eax ; Y位置
		push edx ; X位置
		push ID_GROUND_IN_BMP ; 表示地面
		call DrawSpirit 
		pop ecx
	
		loop DrawGroundLoop
		jmp DrawGroundReturn
		
	DrawGroundReturn:
		ret


DrawWall:

		; 遍历一遍地图，根据每一块的id号，进行相应的绘制
		;mov ecx,225
		mov ecx,my_MAP_BLOCKS_TOTAL
	DrawWallLoop:
		mov edx,0
		mov eax,ecx
		dec eax
		;mov esi,15
		mov esi,my_MAP_BLOCKS_PER_ROW
		div esi
		sal edx,5
		sal eax,5
		;add edx,80 
		add edx,my_CANVAS_WINDOW_LEFT_SHIFT		
		
		cmp [Map+ecx*4-4],3
		je DrawBrick

		cmp [Map+ecx*4-4],4
		je DrawBrickDying_1
		cmp [Map+ecx*4-4],5
		je DrawBrickDying_2
		cmp [Map+ecx*4-4],6
		je DrawBrickDying_3
		cmp [Map+ecx*4-4],7
		je DrawBrickDying_4
		cmp [Map+ecx*4-4],8
		je DrawBrickDying_5
		cmp [Map+ecx*4-4],9
		je DrawBrickDying_6		

		cmp [Map+ecx*4-4],11
		je DrawStone
		cmp [Map+ecx*4-4],1
		je DrawDoor

	DrawWallDoLoop:
		loop DrawWallLoop
		jmp DrawWallReturn
	
	DrawBrick:   ; 画砖头
		push ecx
		push eax
		push edx
		push ID_BRICK_IN_BMP
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	; 画正在死亡的砖头，共6个
	DrawBrickDying_1:
		push ecx
		push eax
		push edx
		push ID_BRICK_DYING_IN_BMP
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawBrickDying_2:
		push ecx
		push eax
		push edx
		push ID_BRICK_DYING_IN_BMP + 1
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
	DrawBrickDying_3:
		push ecx
		push eax
		push edx
		push ID_BRICK_DYING_IN_BMP + 2
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
	DrawBrickDying_4:
		push ecx
		push eax
		push edx
		push ID_BRICK_DYING_IN_BMP + 3
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
	DrawBrickDying_5:
		push ecx
		push eax
		push edx
		push ID_BRICK_DYING_IN_BMP + 4
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
	DrawBrickDying_6:
	push ecx
		push eax
		push edx
		push ID_BRICK_DYING_IN_BMP + 5
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawStone:   ; 画石头，石头不能被炸弹炸开
		push ecx
		push eax
		push edx
		push ID_STONE_IN_BMP ; 石头
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawDoor:
		push ecx
		push eax
		push edx
		push ID_DOOR_IN_BMP ; 门
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallReturn:
		ret

DrawMan:
		mov esi, OFFSET PlayerMan
		cmp [esi],0 ; 类型
		je DrawManReturn
		cmp [esi],1
		je DrawManWalk
		jmp DrawManDying

	DrawManWalk:
		cmp [esi + 12],DIRECTION_LEFT
		je DrawManFaceLeft
		jmp DrawManFaceRight

		DrawManFaceLeft:
			mov ebx, [esi + 4] ; X
			mov eax, [esi + 8] ; Y
			push eax
			push ebx
			mov edx,ID_LEFT_MAN_IN_BMP
			add edx,[ManSpriteID]
			dec edx
			push edx
			call DrawSpirit
			jmp PreAdjustManSpriteID

		DrawManFaceRight:
			mov ebx, [esi + 4] ; X
			mov eax, [esi + 8] ; Y
			push eax
			push ebx
			mov edx,ID_RIGHT_MAN_IN_BMP
			add edx,[ManSpriteID]
			dec edx
			push edx
			call DrawSpirit
			jmp PreAdjustManSpriteID

		PreAdjustManSpriteID:
			cmp [ManSpriteID+8], MAN_SPRITE_ID_TIME_SCALE
			je AdjustManSpriteID
			inc [ManSpriteID+8]
			jmp AdjustManSpriteIDEnd

			AdjustManSpriteID:
					mov [ManSpriteID+8],0

					cmp [ManSpriteID],2 ; 正常大小
					je AdjustManSpriteIDByStretching
					cmp [ManSpriteID],1 ; 收缩
					je AdjustManSpriteIDBigger
					cmp [ManSpriteID],3 ; 拉伸状态
					je AdjustManSpriteIDSmaller

				AdjustManSpriteIDByStretching:
					cmp [ManSpriteID+4],1 ; 在变大
					je AdjustManSpriteIDBigger
					cmp [ManSpriteID+4],2 ; 在变小
					je AdjustManSpriteIDSmaller


				AdjustManSpriteIDBigger:
					inc [ManSpriteID]
					mov [ManSpriteID+4],1
					jmp AdjustManSpriteIDEnd

				AdjustManSpriteIDSmaller:

					dec [ManSpriteID]
					mov [ManSpriteID+4],2
					jmp AdjustManSpriteIDEnd

			AdjustManSpriteIDEnd：
	DrawManWalkEnd:
		jmp DrawManReturn



	DrawManDying:
		

	


	DrawManReturn:
		ret


TimerTick:


	; 小人是否与炸弹重合 若是，则set A = 1
	; 小人是否碰到地形元素或边界
	; 小人是碰到门
	; 小人是否碰到正在爆炸的炸弹
	; 小人是否碰到鬼
	; is A == 0 小人是否碰到炸弹



	; 鬼是否碰到地形元素或边界
	; 鬼是否碰到炸弹
	; 鬼是否碰到正在爆炸的炸弹




	; 炸弹时间累计
	; 触发爆炸时，判断四周是否可爆炸，如果是石头什么都不做，如果是砖头让砖头爆炸，其他情况炸弹射出火焰









END WinMain

