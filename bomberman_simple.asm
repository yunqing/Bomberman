
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




WhichMenu DWORD 0			; 哪个界面，0表示开始，1表示正在游戏，2表示游戏结束
ButtonNumber DWORD 2,0,2	; 每个界面下的图标数
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
my_BMP_TRANSPARENT_COLOR = 00ff00h

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
ID_BOMB_DYING_C_IN_BMP = 60
ID_BOMB_DYING_UD_IN_BMP = 70
ID_BOMB_DYING_LR_IN_BMP = 80


; 方向
DIRECTION_DOWN = 1
DIRECTION_LEFT = 2
DIRECTION_UP = 3
DIRECTION_RIGHT = 0

; 窗体大小
my_WINDOW_PX_WIDTH = 1034 ; 1024 + 10
my_WINDOW_PX_HEIGHT = 702 ; 672 + 31

; 游戏幕布大小，包括地图区域和左右空白（黑色）区域
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


MAX_BOMB_NUM = 2
MAX_GHOST_NUM = 10


MAN_SPRITE_ID_TIME_SCALE = 15
ManSpriteID DWORD 0,0,0 ; 小人存在时的运动状态(0收缩，1正常，2伸展), 在变大还是变小 (1变大, 2变小), timecounter(0~5,达到 MAN_SPRITE_ID_TIME_SCALE 时调整运动状态，随即清零)

GHOST_SPRITE_ID_TIME_SCALE = 9
GhostStretching DWORD 1 ; 鬼在变大还是变小（1 变大， 2 变小）
GhostTimeCounter DWORD 5 ; (0~5,达到 GHOST_SPRITE_ID_TIME_SCALE 时调整运动状态，随即清零)
GhostSpriteID DWORD 0 ; 鬼存在时的运动状态（0收缩，1正常，2伸展）

BOMB_SPRITE_ID_TIME_SCALE = 5
BombStretching DWORD 1 ; 炸弹在变大还是变小 (1=变大，2=变小)
BombTimeCounter DWORD 0 ; (0~5,达到 BOMB_SPRITE_ID_TIME_SCALE 时调整运动状态，随即清零)
BombSpriteID DWORD 0 ; 炸弹运动状态（0收缩，1正常，2伸展）


TRUE = 1
FALSE = 0
IsManOnBomb DWORD 0 ; 人是否在炸弹上
KIND_MAN = 1
KIND_GHOST = 2


GameOverFlag DWORD 0

; 0=土地,1=门,2（未使用）,3=砖墙,4~9(爆炸过程的砖墙),11=石头
;Map			DWORD 441 DUP(?)
Map			DWORD my_MAP_BLOCKS_TOTAL DUP(?)

MAN_RECT_LEFT_SHIFT = 8
MAN_RECT_UP_SHIFT = 8
MAN_RECT_WIDTH = 16
MAN_RECT_HEIGHT = 16
MAN_STEP = 3
IsManDie DWORD FALSE
; 约定所有实体上下移动时，面部朝右
; 类型(0表示不存在，1 表示正常, 2~7 表示死亡), X, Y, 方向
PlayerMan DWORD 1,32,32,2


BOMB_EXPL_TIME_SCALE = 90
BOMB_SIZE = 36
CurrentBombNum DWORD 0
; 类型(0=不存在,1=存在,2~7=爆炸), X, Y, timecounter(到达阈值才爆炸，爆炸后清零), L(左边是否有火焰，1 表示有火焰), U, R, D, 唯一编号（只读）
Bombs 	DWORD 0,96,128,0,1,1,1,1,1
		DWORD 0,96,224,0,1,0,1,1,2


GHOST_STATE_TIME_SCALE = 2
GHOST_DIR_TIME_SCALE = 64 ; 请确保 此值是 GHOST_STEP * 32 的偶数倍或奇数倍
GHOST_STEP = 1
GHOST_SIZE = 24  ; 一个鬼的内存大小 20个字节
IsAllGhostDie DWORD 0
; 类型(0=不存在,1=存在,2~7=死亡), X, Y, 方向,timecounter(到达阈值时改变运动方向),timecounter2(到达阈值时改变死亡状态)
Ghost	DWORD 1,288,64,0,0,0
		DWORD 1,480,416,3,0,0
		DWORD 0,32,128,2,0,0
		DWORD 0,32,160,1,0,0
		DWORD 0,32,192,0,0,0
		DWORD 0,32,224,3,0,0
		DWORD 1,32,288,0,0,0
		DWORD 1,224,288,0,0,0
		DWORD 1,96,320,0,0,0
		DWORD 0,0,0,0,0,0

StaticGhost	DWORD 1,288,64,0,0,0
			DWORD 1,480,416,3,0,0
			DWORD 0,32,128,2,0,0
			DWORD 0,32,160,1,0,0
			DWORD 0,32,192,0,0,0
			DWORD 0,32,224,3,0,0
			DWORD 1,32,288,0,0,0
			DWORD 1,224,288,0,0,0
			DWORD 1,96,320,0,0,0
			DWORD 0,0,0,0,0,0

Door DWORD 0,0 ; 门的位置(取值范围是 {1、3、5、7、9、11、13、15、17、19} ), 注意不能与地图中的石头重合
Round		DWORD 0


BomberManMap 	DWORD  11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
				DWORD  11, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 3, 0, 0, 3, 3, 0, 0, 0, 0, 3, 3, 0, 0, 0, 3, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 3,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 3, 0, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3,11
				DWORD  11, 0,11, 0,11, 3,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 3,11
				DWORD  11, 0, 0, 0, 3, 3, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 3, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 3,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 3, 3, 0, 0, 0, 3, 3, 3, 3, 3, 3, 0, 3, 3, 0, 0, 0,11
				DWORD  11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 3,11
				DWORD  11, 3, 3, 0, 0, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 3, 0, 3, 3,11
				DWORD  11, 0,11, 3,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11, 0,11
				DWORD  11, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0,11
				DWORD  11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11


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
		call UpInMenu ;[调试]暂时取消
		mov UpKeyHold,1
	@nup1:
		cmp eax,KEY_CODE_DOWN
		jne @ndown1
		call DownInMenu ;[调试]暂时取消
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
		call EnterInMenu ; [调试]暂时取消
	@nspace1:
		cmp eax,KEY_CODE_ENTER
		jne @nenter1
		mov EnterKeyHold,1
		call EnterInMenu  ; [调试]暂时取消
	@nenter1:
		cmp eax,KEY_CODE_ESC
		jne @nescape1
		call EscapeInMenu  ;
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
	
		call TimerTick

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

	cmp WhichMenu,0
	je DrawMain
	cmp WhichMenu,1
	je DrawGame
	cmp WhichMenu,2
	je DrawResult
	jmp DrawUIReturn

	DrawMain:
		;以下绘制开始界面的菜单
		call DrawBg

		push 400
		push 400
		push 49
		call DrawSpirit

		push 400
		push 440
		push 59
		call DrawSpirit

		push 400
		push 480
		push 29
		call DrawSpirit

		push 400
		push 520
		push 39
		call DrawSpirit

		push 460
		push 400
		push 9
		call DrawSpirit

		push 460
		push 440
		push 19
		call DrawSpirit

		push 460
		push 480
		push 29
		call DrawSpirit

		push 460
		push 520
		push 39
		call DrawSpirit

		jmp DrawMenuSelect

	DrawMenuSelect:
		;以下绘制制作者并且根据变量的值确定选择指针的位置
		push 630
		push 660
		push 56
		call DrawSpirit

		push 630
		push 700
		push 86
		call DrawSpirit

		push 630
		push 740
		push 87
		call DrawSpirit

		push 630
		push 780
		push 88
		call DrawSpirit

		push 630
		push 820
		push 69
		call DrawSpirit

		push 630
		push 860
		push 68
		call DrawSpirit

		push 630
		push 900
		push 76
		call DrawSpirit

		push 630
		push 940
		push 77
		call DrawSpirit

		push 630
		push 980
		push 78
		call DrawSpirit
		
		mov eax,SelectMenu
		sal eax,6
		add eax,400
		push eax
		push 360
		push 79
		call DrawSpirit
		jmp DrawUIReturn

	DrawResult:
		;以下绘制结束游戏时的界面并根据变量的值绘制选择指针的位置
		push 300
		push 400
		push 57
		call DrawSpirit

		push 300
		push 440
		push 58
		call DrawSpirit

		push 300
		push 480
		push 49
		call DrawSpirit

		push 300
		push 520
		push 59
		call DrawSpirit


		push 360
		push 400
		push 9
		call DrawSpirit

		push 360
		push 440
		push 19
		call DrawSpirit

		push 360
		push 480
		push 29
		call DrawSpirit

		push 360
		push 520
		push 39
		call DrawSpirit

		push 630
		push 660
		push 56
		call DrawSpirit

		push 630
		push 700
		push 86
		call DrawSpirit

		push 630
		push 740
		push 87
		call DrawSpirit

		push 630
		push 780
		push 88
		call DrawSpirit

		push 630
		push 820
		push 69
		call DrawSpirit

		push 630
		push 860
		push 68
		call DrawSpirit

		push 630
		push 900
		push 76
		call DrawSpirit

		push 630
		push 940
		push 77
		call DrawSpirit

		push 630
		push 980
		push 78
		call DrawSpirit
		
		mov eax,SelectMenu
		sal eax,6
		add eax,300
		push eax
		push 360
		push 79
		call DrawSpirit
		jmp DrawUIReturn
		

	DrawGame:

		call DrawGround
		call DrawWall
		call DrawBomb
		call DrawGhost
		call DrawMan
		
		
		
		jmp DrawUIReturn


	DrawUIReturn:
		ret
	
UpInMenu:
		dec SelectMenu
		cmp SelectMenu,0
		jnl UpInMenuReturn
		mov SelectMenu,0
	UpInMenuReturn:
		ret
		
DownInMenu:
		push eax
		inc SelectMenu
		mov ebx,WhichMenu
		mov eax,[ButtonNumber+ebx*4]
		dec eax
		cmp eax,0
		jl FixPos
		cmp SelectMenu,eax
		jng DownInMenuReturn
		mov SelectMenu,eax
		FixPos:                                ;修正可能出现的选择菜单变量小于0而导致选择指针位置不正确的情况
			mov eax,0
			cmp SelectMenu,eax
			jng DownInMenuReturn
			mov SelectMenu,eax
	DownInMenuReturn:
		pop eax
		ret
		
EnterInMenu:
		push eax
		cmp WhichMenu,1
		je EnterInMenuReturn
		mov SpaceKeyHold,0
		mov EnterKeyHold,0
		
		cmp WhichMenu,0
		je EnterInMain
		cmp WhichMenu,2
		je EnterInResult

		jmp EnterInMenuReturn

	EnterInMain:
		cmp SelectMenu,0
		je EnterInMainToGame
		jmp EnterToEndGame
	EnterInGame:
		mov WhichMenu,2
		jmp EnterInMenuReturn
	EnterInMainToGame:
		call ResetGame
		jmp EnterToGame
	EnterToGame:
		mov WhichMenu,1
		jmp EnterInMenuReturn
	EnterInResult:
		cmp SelectMenu,0
		je EnterInResultToGame
		jmp EnterToEndGame
	EnterInResultToGame:
		call ResetGame
		jmp EnterToGame
		
		

	EnterToEndGame:
		push 0
		call PostQuitMessage
		push 1
		push hMainWnd
		call KillTimer

	EnterInMenuReturn:
		pop eax
		ret

ResetGame:
		mov [GameOverFlag],0
	;Map
	;设置地图
		mov Round, 0 ; [调试]：为便于调试临时设为0 
		mov eax,[Round]
		mov ebx,my_MAP_BLOCKS_TOTAL*4    ; 一个地图的内存字节数，因为地图是 DWORD 类型的
		mul ebx
		mov ebx,eax
		mov ecx,my_MAP_BLOCKS_TOTAL
	SetMap2:     						; 通过一个循环复制地图
		mov eax,[BomberManMap+ebx+ecx*4-4]     ;  [调试]：修改了的语句
		mov [Map+ecx*4-4],eax
		loop SetMap2

	;ghost

		mov ecx,MAX_GHOST_NUM
		mov esi,0
	SetGhost:
		mov eax,[StaticGhost+esi]
		mov [Ghost+esi],eax

		mov eax,[StaticGhost+esi+4]
		mov [Ghost+esi+4],eax

		mov eax,[StaticGhost+esi+8]
		mov [Ghost+esi+8],eax

		mov eax,[StaticGhost+esi+12]
		mov [Ghost+esi+12],eax

		mov eax,[StaticGhost+esi+16]
		mov [Ghost+esi+16],eax

		mov eax,[StaticGhost+esi+20]
		mov [Ghost+esi+20],eax

		add esi,GHOST_SIZE

		loop SetGhost

	;man
		mov [PlayerMan],1
		mov [PlayerMan+4],32
		mov [PlayerMan+8],32
		mov [PlayerMan+12],2


	;bomb
		mov [Bombs],0
		mov eax,BOMB_SIZE
		mov [Bombs+eax],0
ResetGameReturn:
ret

EscapeInMenu:

		cmp WhichMenu,0
		je EscapeToEndGame
		cmp WhichMenu,1
		je EscapeInMenuReturn
	EscapeToEndGame:
		push 0
		call PostQuitMessage
		push 1
		push hMainWnd
		call KillTimer
	EscapeInMenuReturn:
		mov WhichMenu,0
		ret	

DrawBg:

		push 96
		push 316
		push 100
		call DrawSpirit
		push 96
		push 348
		push 101
		call DrawSpirit
		push 96
		push 380
		push 102
		call DrawSpirit
		push 96
		push 412
		push 103
		call DrawSpirit
		push 96
		push 444
		push 104
		call DrawSpirit
		push 96
		push 476
		push 105
		call DrawSpirit
		push 96
		push 508
		push 106
		call DrawSpirit
		push 96
		push 540
		push 107
		call DrawSpirit
		push 96
		push 572
		push 108
		call DrawSpirit
		push 96
		push 604
		push 109
		call DrawSpirit
		push 128
		push 316
		push 110
		call DrawSpirit
		push 128
		push 348
		push 111
		call DrawSpirit
		push 128
		push 380
		push 112
		call DrawSpirit
		push 128
		push 412
		push 113
		call DrawSpirit
		push 128
		push 444
		push 114
		call DrawSpirit
		push 128
		push 476
		push 115
		call DrawSpirit
		push 128
		push 508
		push 116
		call DrawSpirit
		push 128
		push 540
		push 117
		call DrawSpirit
		push 128
		push 572
		push 118
		call DrawSpirit
		push 128
		push 604
		push 119
		call DrawSpirit
		push 160
		push 316
		push 120
		call DrawSpirit
		push 160
		push 348
		push 121
		call DrawSpirit
		push 160
		push 380
		push 122
		call DrawSpirit
		push 160
		push 412
		push 123
		call DrawSpirit
		push 160
		push 444
		push 124
		call DrawSpirit
		push 160
		push 476
		push 125
		call DrawSpirit
		push 160
		push 508
		push 126
		call DrawSpirit
		push 160
		push 540
		push 127
		call DrawSpirit
		push 160
		push 572
		push 128
		call DrawSpirit
		push 160
		push 604
		push 129
		call DrawSpirit
		push 192
		push 316
		push 130
		call DrawSpirit
		push 192
		push 348
		push 131
		call DrawSpirit
		push 192
		push 380
		push 132
		call DrawSpirit
		push 192
		push 412
		push 133
		call DrawSpirit
		push 192
		push 444
		push 134
		call DrawSpirit
		push 192
		push 476
		push 135
		call DrawSpirit
		push 192
		push 508
		push 136
		call DrawSpirit
		push 192
		push 540
		push 137
		call DrawSpirit
		push 192
		push 572
		push 138
		call DrawSpirit
		push 192
		push 604
		push 139
		call DrawSpirit
		push 224
		push 316
		push 140
		call DrawSpirit
		push 224
		push 348
		push 141
		call DrawSpirit
		push 224
		push 380
		push 142
		call DrawSpirit
		push 224
		push 412
		push 143
		call DrawSpirit
		push 224
		push 444
		push 144
		call DrawSpirit
		push 224
		push 476
		push 145
		call DrawSpirit
		push 224
		push 508
		push 146
		call DrawSpirit
		push 224
		push 540
		push 147
		call DrawSpirit
		push 224
		push 572
		push 148
		call DrawSpirit
		push 224
		push 604
		push 149
		call DrawSpirit
		push 256
		push 316
		push 150
		call DrawSpirit
		push 256
		push 348
		push 151
		call DrawSpirit
		push 256
		push 380
		push 152
		call DrawSpirit
		push 256
		push 412
		push 153
		call DrawSpirit
		push 256
		push 444
		push 154
		call DrawSpirit
		push 256
		push 476
		push 155
		call DrawSpirit
		push 256
		push 508
		push 156
		call DrawSpirit
		push 256
		push 540
		push 157
		call DrawSpirit
		push 256
		push 572
		push 158
		call DrawSpirit
		push 256
		push 604
		push 159
		call DrawSpirit

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
		cmp [esi],DWORD PTR 0 ; 类型
		je DrawManReturn
		cmp [esi],DWORD PTR 1
		je DrawManWalk
		jmp DrawManDying


	DrawManWalk:
		cmp [esi + 12],DWORD PTR DIRECTION_LEFT
		je DrawManFaceLeft
		jmp DrawManFaceRight

		DrawManFaceLeft:
			mov ebx, [esi + 4] ; X
			add ebx, my_CANVAS_WINDOW_LEFT_SHIFT
			mov eax, [esi + 8] ; Y
			push eax
			push ebx
			mov edx,ID_LEFT_MAN_IN_BMP
			add edx,[ManSpriteID]
			
			push edx
			call DrawSpirit
			jmp PreAdjustManSpriteID

		DrawManFaceRight:
			mov ebx, [esi + 4] ; X
			add ebx, my_CANVAS_WINDOW_LEFT_SHIFT
			mov eax, [esi + 8] ; Y
			push eax
			push ebx
			mov edx,ID_RIGHT_MAN_IN_BMP
			add edx,[ManSpriteID]
			
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

					cmp [ManSpriteID],1 ; 正常大小
					je AdjustManSpriteIDByStretching
					cmp [ManSpriteID],0 ; 收缩
					je AdjustManSpriteIDBigger
					cmp [ManSpriteID],2 ; 拉伸状态
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

			AdjustManSpriteIDEnd:
				jmp DrawManWalkEnd


	DrawManWalkEnd:
		jmp DrawManReturn


	
		
	DrawManDying:
		cmp [esi + 12],DWORD PTR DIRECTION_LEFT
		je DrawManDyingLeft
		jmp DrawManDyingRight
		
		DrawManDyingLeft:
			mov edx,[esi]
			sub edx,2  ; 死亡状态
			add edx,ID_LEFT_DYING_MAN_IN_BMP
			mov ebx, [esi + 4] ; X
			add ebx, my_CANVAS_WINDOW_LEFT_SHIFT
			mov eax, [esi + 8] ; Y
			push eax
			push ebx
			push edx
			call DrawSpirit
			jmp DrawManDyingEnd

		DrawManDyingRight:
			mov edx,[esi]
			sub edx,2  ; 死亡状态
			add edx,ID_RIGHT_DYING_MAN_IN_BMP
			mov ebx, [esi + 4] ; X
			add ebx, my_CANVAS_WINDOW_LEFT_SHIFT
			mov eax, [esi + 8] ; Y
			push eax
			push ebx
			push edx
			call DrawSpirit
			jmp DrawManDyingEnd
		DrawManDyingEnd:
			jmp DrawManReturn

DrawManReturn:
	ret


DrawGhost:

COMMENT !
	for ( ghost in Ghost)
	{
		if ghost.state == 0
			continue
		if ghost.state = 1
			DrawGhostWalk
			continue
		else
			DrawGhostDying
			continue
	}


	DrawGhostWalk()
	{
		if ghost.dir == left 
			DrawGhostWalkFaceLeft
		else
			DrawGhostWalkFaceRight

		DrawGhostWalkFaceLeft(){
			X = ghost.X
			adjust X　by my_CANVAS_WINDOW_LEFT_SHIFT
			Y = ghost.Y
			ID = ID_LEFT_GHOST_IN_BMP
			adjust id by GhostSpriteID
			call DrawSpirit(id, X, Y)
			jmp AdjustGhostSpriteID
		}
		DrawGhostWalkFaceRight(){
			X = ghost.X
			adjust X　by my_CANVAS_WINDOW_LEFT_SHIFT
			Y = ghost.Y 
			ID = ID_RIGHT_GHOST_IN_BMP
			adjust id by GhostSpriteID
			AdjustGhostSpriteID
		}
		AdjustGhostSpriteID(){
			if GhostTimeCounter == GHOST_SPRITE_ID_TIME_SCALE
				GhostTimeCounter =0
				if GhostSpriteID = 0 ; 收缩状态
					AdjustGhostSpriteIDBigger
				if GhostSpriteID == 2 ; 拉伸状态
					AdjustGhostSpriteIDSmaller
				if GhostSpriteID == 1
					AdjustGhostSpriteIDByStretching
			else 
				GhostTimeCounter++

		}
	}

!

	mov ecx,MAX_GHOST_NUM
	mov esi,0 ; 用于定位行
	DrawEachGhost:
		push ecx
		cmp [Ghost+esi],0
		je DrawEachGhostLoop
		cmp [Ghost+esi],1
		je DrawGhostWalk
		jmp DrawGhostDying

		DrawGhostWalk:
			cmp [Ghost+esi+12],DIRECTION_LEFT
			je DrawGhostWalkFaceLeft
			jmp DrawGhostWalkFaceRight

			DrawGhostWalkFaceLeft:
				mov ebx,[Ghost+esi+4] ; X位置
				mov eax,[Ghost+esi+8] ; Y
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				mov edx,ID_LEFT_GHOST_IN_BMP
				add edx,GhostSpriteID
				push eax
				push ebx
				push edx
				call DrawSpirit
				jmp DrawGhostWalkEnd

			DrawGhostWalkFaceRight:
				mov ebx,[Ghost+esi+4] ; X位置
				mov eax,[Ghost+esi+8] ; Y
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				mov edx,ID_RIGHT_GHOST_IN_BMP
				add edx,GhostSpriteID
				push eax
				push ebx
				push edx
				call DrawSpirit
				jmp DrawGhostWalkEnd

	DrawEachGhostLoop:
		add esi,GHOST_SIZE
		pop ecx
		loop DrawEachGhost
		jmp AdjustGhostSpriteID
		

			AdjustGhostSpriteID:
				cmp [GhostTimeCounter],GHOST_SPRITE_ID_TIME_SCALE
				je DoAdjustGhostSpriteID
				inc [GhostTimeCounter]
				jmp DrawGhostReturn

					DoAdjustGhostSpriteID:
						mov [GhostTimeCounter],0
						cmp [GhostSpriteID],0 ; 收缩状态
						je AdjustGhostSpriteIDBigger
						cmp [GhostSpriteID],2 ; 拉伸状态
						je AdjustGhostSpriteIDSmaller
						jmp AdjustGhostSpriteID_byStr

							AdjustGhostSpriteID_byStr:
								cmp [GhostStretching],1
								je AdjustGhostSpriteIDBigger
								jmp AdjustGhostSpriteIDSmaller


							AdjustGhostSpriteIDBigger:
								inc [GhostSpriteID]
								
								mov [GhostStretching],1
								jmp DrawGhostReturn

							AdjustGhostSpriteIDSmaller:
								dec [GhostSpriteID]
								
								mov [GhostStretching],2
								jmp DrawGhostReturn


		DrawGhostWalkEnd:
			jmp DrawEachGhostLoop


COMMENT !
DrawGhostDying()
{
	if ghost.dir = DIRECTION_LEFT
		DrawGhostDyingLeft()
		{
			X = ghost.x
			adjust x by my_CANVAS_WINDOW_LEFT_SHIFT
			Y = ghost.y 
			id = ID_LEFT_DYING_GHOST_IN_BMP
			adjust id by ghost.state - 2
			DrawSpirit(id, X, Y)
			

		}
	else
		DrawGhostDyingRight()
		{
			X = ghost.x
			adjust x by my_CANVAS_WINDOW_LEFT_SHIFT
			Y = ghost.y 
			id = ID_RIGHT_DYING_GHOST_IN_BMP
			adjust id by ghost.state - 2
			DrawSpirit(id, X, Y)
			
		}
}


!

		DrawGhostDying:
			cmp [Ghost+esi+12],DIRECTION_LEFT
			je DrawGhostDyingLeft
			jmp DrawGhostDyingRight

			DrawGhostDyingLeft:
				mov ebx,[Ghost+esi+4] ; X位置
				mov eax,[Ghost+esi+8] ; Y
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				mov edx,ID_LEFT_DYING_GHOST_IN_BMP
				add edx,[Ghost+esi]
				sub edx,2
				push eax
				push ebx
				push edx
				call DrawSpirit
				jmp DrawGhostDyingEnd

			DrawGhostDyingRight:
				mov ebx,[Ghost+esi+4] ; X位置
				mov eax,[Ghost+esi+8] ; Y
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				mov edx,ID_RIGHT_DYING_GHOST_IN_BMP
				add edx,[Ghost+esi]
				sub edx,2
				push eax
				push ebx
				push edx
				call DrawSpirit
				jmp DrawGhostDyingEnd

		DrawGhostDyingEnd:
			jmp DrawEachGhostLoop

DrawGhostReturn:
	ret

COMMENT !
DrawBomb()
{
	for each bomb in Bombs	
		x = bomb.x
		y = bomb.y
		adjust x by my_CANVAS_WINDOW_LEFT_SHIFT
		id = ID_BOMB_IN_BMP
		adjust id by BombSpriteID
		DrawSpirit(id, x, y)

	AdjustBombSpriteID()
	{
		if BombTimeCounter == BOMB_SPRITE_ID_TIME_SCALE
			BombTimeCounter = 0
			if BombSpriteID = 1
				AdjustBombSpriteID_ByStr
			if BombSpriteID == 0
				AdjustBombSpriteIDBigger
			if BombSpriteID = 2
				AdjustBombSpriteIDSmaller

				AdjustBombSpriteIDBigger()
				{
					BombSpriteID++
					BombStretching = 1

				}

				AdjustBombSpriteIDSmaller()
				{
					BombSpriteID--
					BombStretching = 2

				}

				AdjustBombSpriteID_ByStr()
				{
					if BombStretching == 1
						AdjustBombSpriteIDBigger
					else 
						AdjustBombSpriteIDSmaller

				}

		else BombTimeCounter++
	}
}

!

DrawBomb:
	mov ecx,MAX_BOMB_NUM
	mov esi,0

	DrawEachBomb:
		push ecx

		cmp [Bombs+esi],0
		je DrawEachBombLoop
		cmp [Bombs+esi],1
		je DrawBombNormal
		jmp DrawBombExplode

		DrawBombNormal:
			mov eax,[Bombs+esi+8] ; Y
			mov ebx,[Bombs+esi+4] ; x
			add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
			mov edx,ID_BOMB_IN_BMP
			add edx,BombSpriteID
			push eax
			push ebx
			push edx
			call DrawSpirit
			jmp DrawEachBombLoop


		DrawEachBombLoop:
			add esi,BOMB_SIZE
			pop ecx
			loop DrawEachBomb
			jmp AdjustBombSpriteID


		DrawBombExplode:
			DrawBombExplodeC:
				mov eax,[Bombs+esi+8] ; Y
				mov ebx,[Bombs+esi+4] ; x
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				mov edx,ID_BOMB_DYING_C_IN_BMP
				add edx,[Bombs+esi]    ; 根据爆炸状态调整
				sub edx,2
				push eax
				push ebx
				push edx
				call DrawSpirit            

			DrawBombExplodeLeft:
				cmp [Bombs+esi+16],0
				je DrawBombExplodeUp

				mov eax,[Bombs+esi+8] ; Y
				mov ebx,[Bombs+esi+4] ; x
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				sub ebx,32
				mov edx,ID_BOMB_DYING_LR_IN_BMP
				add edx,[Bombs+esi]    ; 根据爆炸状态调整
				sub edx,2
				push eax
				push ebx
				push edx
				call DrawSpirit 



			DrawBombExplodeUp:
				cmp [Bombs+esi+20],0
				je DrawBombExplodeRight

				mov eax,[Bombs+esi+8] ; Y
				mov ebx,[Bombs+esi+4] ; x
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				sub eax,32
				mov edx,ID_BOMB_DYING_UD_IN_BMP
				add edx,[Bombs+esi]    ; 根据爆炸状态调整
				sub edx,2
				push eax
				push ebx
				push edx
				call DrawSpirit 

			DrawBombExplodeRight:
				cmp [Bombs+esi+24],0
				je DrawBombExplodeDown

				mov eax,[Bombs+esi+8] ; Y
				mov ebx,[Bombs+esi+4] ; x
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				add ebx,32

				mov edx,ID_BOMB_DYING_LR_IN_BMP
				add edx,[Bombs+esi]    ; 根据爆炸状态调整
				sub edx,2
				push eax
				push ebx
				push edx
				call DrawSpirit 

			DrawBombExplodeDown:
				cmp [Bombs+esi+28],0
				je DrawEachBombLoop

				mov eax,[Bombs+esi+8] ; Y
				mov ebx,[Bombs+esi+4] ; x
				add ebx,my_CANVAS_WINDOW_LEFT_SHIFT
				add eax,32

				mov edx,ID_BOMB_DYING_UD_IN_BMP
				add edx,[Bombs+esi]    ; 根据爆炸状态调整
				sub edx,2
				push eax
				push ebx
				push edx
				call DrawSpirit 

				jmp DrawEachBombLoop






	AdjustBombSpriteID:
		cmp [BombTimeCounter],BOMB_SPRITE_ID_TIME_SCALE
		je DoAdjustBombSpriteID
		inc [BombTimeCounter]
		jmp DrawBombReturn

		DoAdjustBombSpriteID:
			mov [BombTimeCounter],0
			cmp [BombSpriteID],0 ; 收缩状态
			je AdjustBombSpriteIDBigger
			cmp [BombSpriteID],2 ; 拉伸状态
			je AdjustBombSpriteIDSmaller
			jmp AdjustBombSpriteID_byStr

				AdjustBombSpriteID_byStr:
					cmp [BombStretching],1
					je AdjustBombSpriteIDBigger
					jmp AdjustBombSpriteIDSmaller


				AdjustBombSpriteIDBigger:
					inc [BombSpriteID]
					
					mov [BombStretching],1
					jmp DrawBombReturn

				AdjustBombSpriteIDSmaller:
					dec [BombSpriteID]
					
					mov [BombStretching],2
					jmp DrawBombReturn


DrawBombReturn:
	ret

TimerTick:


	; 小人是否与炸弹重合 若是，则Ghost A = 1
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




	

	
	; 根据按键移动小人，碰撞检测
	cmp WhichMenu,1
	je TimerTickDontReturn
	jmp TimerTickReturn

	TimerTickDontReturn:



COMMENT !
; man
		if man on Bomb
			IsManOnBomb = TRUE
; ghost

; bomb


!

			; if all ghost die && man is on the door ,then you win 
			; 判断游戏是否结束(鬼是否都被消灭或者小人是否碰到门或者小人是否碰到爆炸或者小人是否碰到鬼)

			call IsGameOver


			; 小人是否与炸弹重合 若是，则set IsManOnBomb = 1
			call CheckManOnBomb
			call CheckManMeetExplode
			call CheckManMeetGhost
			call CheckManDying
			cmp ebx,1 ; 人已经开始死亡或正在死亡
			je TT_others



			cmp UpKeyHold,1
			jne TT@1
			mov [PlayerMan+12],3
			sub [PlayerMan+8],MAN_STEP

			push OFFSET PlayerMan
			
			call CheckManCanGo
			;测试结果
			test eax,1
			jz TT@1Bad
			jmp TT@1

		TT@1Bad:
			add [PlayerMan+8],MAN_STEP
			jmp TT@4
		TT@1:
			cmp DownKeyHold,1
			jne TT@2
			mov [PlayerMan+12],1
			add [PlayerMan+8],MAN_STEP

			push offset PlayerMan
			
			call CheckManCanGo
			;测试结果
			test eax,1
			jz TT@2Bad
			jmp TT@2

		TT@2Bad:
			sub [PlayerMan+8],MAN_STEP
			jmp TT@4
		TT@2:
			cmp LeftKeyHold,1
			jne TT@3
			mov [PlayerMan+12],2
			sub [PlayerMan+4],MAN_STEP
			push OFFSET PlayerMan
			
			call CheckManCanGo
			test eax,1
			jz TT@3Bad
			jmp TT@3

		TT@3Bad:
			add [PlayerMan+4],MAN_STEP
			jmp TT@4
		TT@3:
			cmp RightKeyHold,1
			jne TT@4
			mov [PlayerMan+12],0
			add [PlayerMan+4],MAN_STEP
			push OFFSET PlayerMan
			
			call CheckManCanGo
			test eax,1
			jz TT@4Bad
			jmp TT@4

		TT@4Bad:
			sub [PlayerMan+4],MAN_STEP
			jmp TT@4
		TT@4:
			cmp SpaceKeyHold,1
			jne TT_others
			call PlaceBomb

		TT_others:
			

		;TT_Bomb:
			call BombExploding

		TT_Ghost:

			call GhostsMoving
			call CheckGhostMeetExplode
			call CheckGhostDying
			call CheckAllGhostDie

			


		

		TT_Brick:
			call BrickDying




	TimerTickReturn:
		ret

COMMENT !
	CheckManMeetGhost:
		GetManRect()
		for each ghost in Ghost
			GetGhostRect(ghost)
			RectConflict
			if conflict
				call ManDie
				return
!

CheckManMeetGhost:
	push ebp
	mov ebp,esp

	cmp [PlayerMan],1
	jne CheckManMeetGhostReturn

	mov ecx,MAX_GHOST_NUM
	mov esi,OFFSET Ghost

	CheckManMeetEachGhost:
		push ecx

		cmp DWORD PTR [esi],1
		jne CheckManMeetEachGhostLoop

		call GetManRect
		push edx
		push ecx
		push ebx
		push eax
		push esi
		call GetGhostRect
		push edx
		push ecx
		push ebx
		push eax
		call RectConflict
		cmp eax,1
		je ManMeetGhost
		jmp CheckManMeetEachGhostLoop

		ManMeetGhost:
			mov [PlayerMan],2
			pop ecx 
			jmp CheckManMeetGhostReturn	

	CheckManMeetEachGhostLoop:

		add esi,GHOST_SIZE
		pop ecx
		loop CheckManMeetEachGhost
		jmp CheckManMeetGhostReturn

CheckManMeetGhostReturn:
	mov esp,ebp
	pop ebp
	ret


CheckManMeetExplode:
	push ebp
	mov ebp,esp

	cmp [PlayerMan],1
	jne CheckManMeetExplodeReturn

	mov ecx,MAX_BOMB_NUM
	mov esi,0
	CheckManMeetExplode_each:
		push ecx

		cmp [Bombs+esi],0
		je CheckManMeetExplode_each_loop

		cmp [Bombs+esi],1
		je CheckManMeetExplode_each_loop

		mov eax,[Bombs+esi+4] ; x
		mov ebx,[Bombs+esi+8] ; y

		add ebx,64
		add eax,32

		push ebx
		push eax

		sub eax,32
		sub ebx,96

		push ebx
		push eax
	
		call GetManRect
		push edx
		push ecx
		push ebx
		push eax
		
		call RectConflict
		
		cmp eax,1
		je ManDoMeetExplode
		jmp L_CheckManMeetExplode_each2

	CheckManMeetExplode_each_loop:
		pop ecx
		add esi,BOMB_SIZE
		loop CheckManMeetExplode_each
		jmp CheckManMeetExplodeReturn

	L_CheckManMeetExplode_each2:
		mov eax,[Bombs+esi+4] ; x
		mov ebx,[Bombs+esi+8] ; y

		add eax,64
		add ebx,32

		push ebx
		push eax

		sub eax,96
		sub ebx,32

		push ebx
		push eax

	
		call GetManRect
		push edx
		push ecx
		push ebx
		push eax
		
		call RectConflict
		
		cmp eax,1
		je ManDoMeetExplode

		jmp CheckManMeetExplode_each_loop

	ManDoMeetExplode:
		pop ecx
		mov [PlayerMan],2
		jmp CheckManMeetExplodeReturn


CheckManMeetExplodeReturn:
	mov esp,ebp
	pop ebp
	ret


CheckGhostMeetExplode:
	push ebp
	mov ebp,esp

	mov ecx,MAX_GHOST_NUM
	mov esi,0
	CheckEachGhostExp:
			push ecx

			cmp [Ghost+esi],1
			jne CheckEachGhostExpLoop


			mov ecx,MAX_BOMB_NUM
			mov edi,0

			CheckGhostExpEachBomb:
				push esi
				push ecx

				cmp [Bombs+edi],0
				je CheckGhostExpEachBombLoop

				cmp [Bombs+edi],1
				je CheckGhostExpEachBombLoop

				mov eax,[Bombs+edi+4] ; x
				mov ebx,[Bombs+edi+8] ; y

				add ebx,64
				add eax,32

				push ebx
				push eax

				sub eax,32
				sub ebx,96

				push ebx
				push eax

				mov eax, OFFSET Ghost
				add eax, esi
				push esi
				push eax
				call GetGhostRect
				pop esi
				push edx
				push ecx
				push ebx
				push eax
				
				call RectConflict
				
				cmp eax,1
				je ThisGhostMeetExp
				jmp L_CheckGhostExpEachBomb_2

		CheckGhostExpEachBombLoop:
			pop ecx
			pop esi
			add edi,BOMB_SIZE
			loop CheckGhostExpEachBomb
			jmp CheckEachGhostExpLoop

	CheckEachGhostExpLoop:
		pop ecx
		add esi,GHOST_SIZE
		loop CheckEachGhostExp
		jmp CheckGhostMeetExplodeReturn

				ThisGhostMeetExp:
					mov [Ghost+esi],2
					pop ecx
					pop esi
					jmp CheckEachGhostExpLoop

			L_CheckGhostExpEachBomb_2:
				mov eax,[Bombs+edi+4] ; x
				mov ebx,[Bombs+edi+8] ; y

				add eax,64
				add ebx,32

				push ebx
				push eax

				sub eax,96
				sub ebx,32

				push ebx
				push eax

				mov eax, OFFSET Ghost
				add eax, esi
				push esi
				push eax
				call GetGhostRect
				pop esi
				push edx
				push ecx
				push ebx
				push eax
				
				call RectConflict
				
				cmp eax,1
				je ThisGhostMeetExp
				jmp CheckGhostExpEachBombLoop

CheckGhostMeetExplodeReturn:
	mov esp,ebp
	pop ebp
	ret



CheckGhostOnBomb:
	push ebp
	mov ebp,esp
	mov ecx,GHOST_SIZE

	CheckEachGhostOnBomb:
		push ecx

	CheckEachGhostOnBombLoop:
		pop ecx
		loop CheckEachGhostOnBomb

CheckGhostOnBombReturn:
	mov esp,ebp
	pop ebp
	ret


CheckManDying:
	push ebp
	mov ebp,esp

	cmp [PlayerMan],1
	je CheckManDyingReturn

	cmp [PlayerMan],0
	je CheckManDyingReturn

	cmp [PlayerMan],7
	je ManDie

	inc [PlayerMan]
	mov ebx,1
	jmp CheckManDyingReturn

	ManDie:
		mov [IsManDie],TRUE
		mov [WhichMenu],2
		mov ebx,1
		mov [PlayerMan],0
		jmp CheckManDyingReturn

CheckManDyingReturn:
	mov esp,ebp
	pop ebp
	ret


CheckGhostDying:  ; 推进鬼的死亡状态
	push ebp
	mov ebp,esp

	mov ecx,MAX_GHOST_NUM
	mov esi,0

	CheckGhostDyingEach:
		push ecx

		cmp [Ghost+esi],1
		je CheckGhostDyingEachLoop
		cmp [Ghost+esi],0
		je CheckGhostDyingEachLoop

		cmp [Ghost+esi],7
		je ThisGhostDie


		cmp [Ghost+esi+20],GHOST_STATE_TIME_SCALE
		je nextGhostDyingState
		inc [Ghost+esi+20]
		jmp CheckGhostDyingEachLoop

		nextGhostDyingState:
			mov [Ghost+esi+20],0
			inc [Ghost+esi]
			jmp CheckGhostDyingEachLoop

		ThisGhostDie:
			mov [Ghost+esi],0
			jmp CheckGhostDyingEachLoop

	CheckGhostDyingEachLoop:
		pop ecx
		add esi,GHOST_SIZE
		loop CheckGhostDyingEach
		jmp CheckGhostDyingReturn
CheckGhostDyingReturn:
	mov esp,ebp
	pop ebp
	ret


; ebx = 1 表示所有的鬼已经死亡  ; IsAllGhostDie = 1 表示所有的鬼已经死亡
CheckAllGhostDie:  
	push ebp
	mov ebp,esp

	mov ecx,MAX_GHOST_NUM
	mov esi,0
	mov ebx,1
	mov [IsAllGhostDie],TRUE

	CheckAllGhostDieEach:
		push ecx

		
		cmp [Ghost+esi],0
		jne SomeGhostExist
		jmp CheckAllGhostDieEachLoop

		
		SomeGhostExist:
			mov ebx,0
			mov [IsAllGhostDie],FALSE
			pop ecx
			jmp CheckAllGhostDieReturn

	CheckAllGhostDieEachLoop:
		pop ecx
		add esi,GHOST_SIZE
		loop CheckAllGhostDieEach

		mov [IsAllGhostDie],TRUE
		jmp CheckAllGhostDieReturn


CheckAllGhostDieReturn:
	mov esp,ebp
	pop ebp
	ret



COMMENT !
	if CurrentBombNum == MAX_BOMB_NUM
		return
	x = man.x
	y = man.y
	adjust x
	adjust y
	for each bomb in Bombs
		if bomb.state = 0
			place here()
			{
				state = 1
				x *= 32
				y*=32
			}
		continue
	CurrentBombNum ++

!
; 放炸弹
PlaceBomb:
	;cmp [CurrentBombNum],MAX_BOMB_NUM
	;je PlaceBombReturn
	mov eax,[PlayerMan+4] ; x
	mov ebx,[PlayerMan+8] ; y

	add eax,16
	add ebx,16
	sar eax,5
	sar ebx,5
	sal eax,5
	sal ebx,5
	mov ecx,MAX_BOMB_NUM
	mov esi,0

	PlaceSingleBomb:
		push ecx

		cmp [Bombs+esi],0
		jne PlaceSingleBombLoop
		mov [Bombs+esi],1
		mov [Bombs+esi+4],eax
		mov [Bombs+esi+8],ebx
		mov [Bombs+esi+12],0 ; timecounter
		jmp PlaceBombSucceed
	PlaceSingleBombLoop:
		add esi,BOMB_SIZE 
		pop ecx
		loop PlaceSingleBomb
		jmp PlaceBombReturn

	PlaceBombSucceed:
		;inc [CurrentBombNum]
		pop ecx
		jmp PlaceBombReturn

PlaceBombReturn:
	ret

COMMENT !
	for each bomb in Bombs
		if bomb.state == 0
			continue
		if bomb.state == 1
			if bomb.timecounter == BOMB_EXPL_TIME_SCALE
				bomb.timecounter = 0
				explode()
				{
					CanExplodeLURD()
					{
						if bomb.left is Brick
							brick  = 4
							bomb.L = 0
						if bomb.left is Stone
							bomb.L = 0
						else
							bomb.L = 1
							
						If .....

					}
					
					bomb.state = 2

				}
				continue
			bomb.timecounter++
			continue
		if bomb.state == 7
			bomb.state = 0
			continue
		else
			bomb.state++
			continue

!

BombExploding:
	push ebp
	mov ebp,esp

	mov ecx,MAX_BOMB_NUM
	mov esi,0
	BombExplodingEach:
		push ecx

		cmp [Bombs+esi],0
		je BombExplodingEachLoop

		cmp [Bombs+esi],7
		je CancelBomb

		cmp [Bombs+esi],1
		je PreExplode

		inc [Bombs+esi]
		jmp BombExplodingEachLoop


	BombExplodingEachLoop:
		add esi,BOMB_SIZE
		pop ecx
		loop BombExplodingEach
		jmp BombExplodingReturn

		CancelBomb:
			mov [Bombs+esi],0
			;dec [CurrentBombNum]
			jmp BombExplodingEachLoop

		PreExplode:
			cmp [Bombs+esi+12],BOMB_EXPL_TIME_SCALE
			je DoExplode
			inc [Bombs+esi+12]
			jmp BombExplodingEachLoop

		DoExplode:
			mov [Bombs+esi+12],0
			mov eax,[Bombs+esi+4] ; x
			mov ebx,[Bombs+esi+8] ; y
			;add eax,5
			;add ebx,5
			sar eax,5
			sar ebx,5
			sub esp,16
			mov [ebp-4],eax ; x(0-20)   炸弹所在的x
			mov [ebp-8],ebx ; y(0-20)   炸弹所在的y

			L_exp_L:
				mov eax,[ebp-4]
				dec eax
				mov [ebp-4],eax
		
				mov ebx,my_MAP_BLOCKS_PER_ROW
				mov eax,4
				mul ebx
				mul DWORD PTR [ebp-8]
				mov [ebp-12],eax ; 上方所有行的字节数和

				mov eax,4
				mul DWORD PTR [ebp-4]
				mov [ebp-16],eax ; 此行左边的字节数和

				mov edx,[ebp-12]
				add edx,[ebp-16]

				cmp [Map+edx],3 ; 砖头
				je L_exp_Brick_L
				cmp [Map+edx],11 ; 石头
				je L_exp_Stone_L
				cmp [Map+edx],0 ; 土地
				je L_exp_fire_L
				jmp L_exp_no_fire_L
				

				L_exp_Brick_L:
					mov [Map+edx],4
					mov [Bombs+esi+16],0
					jmp L_exp_U

				L_exp_Stone_L:
					mov [Bombs+esi+16],0
					jmp L_exp_U

				L_exp_fire_L:
					mov [Bombs+esi+16],1
					jmp L_exp_U

				L_exp_no_fire_L:
					mov [Bombs+esi+16],0
					jmp L_exp_U


			L_exp_U:
				;add [ebp-4],1
				mov eax,[ebp-4]
				inc eax
				mov [ebp-4],eax

				;sub [ebp-8],1
				mov eax,[ebp-8]
				dec eax
				mov [ebp-8],eax

				mov ebx,my_MAP_BLOCKS_PER_ROW
				mov eax,4
				mul ebx
				mul DWORD PTR [ebp-8]
				mov [ebp-12],eax ; 上方所有行的字节数和

				mov eax,4
				mul DWORD PTR [ebp-4]
				mov [ebp-16],eax ; 此行左边的字节数和

				mov edx,[ebp-12]
				add edx,[ebp-16]


				cmp [Map+edx],3 ; 砖头
				je L_exp_Brick_U
				cmp [Map+edx],11 ; 石头
				je L_exp_Stone_U
				cmp [Map+edx],0 ; 土地
				je L_exp_fire_U
				jmp L_exp_no_fire_U
				

				L_exp_Brick_U:
					mov [Map+edx],4
					mov [Bombs+esi+20],0
					jmp L_exp_R

				L_exp_Stone_U:
					mov [Bombs+esi+20],0
					jmp L_exp_R

				L_exp_fire_U:
					mov [Bombs+esi+20],1
					jmp L_exp_R

				L_exp_no_fire_U:
					mov [Bombs+esi+20],0
					jmp L_exp_R


			L_exp_R:
				;add [ebp-4],1
				mov eax,[ebp-4]
				inc eax
				mov [ebp-4],eax

				;add [ebp-8],1
				mov eax,[ebp-8]
				inc eax
				mov [ebp-8],eax

				mov ebx,my_MAP_BLOCKS_PER_ROW
				mov eax,4
				mul ebx
				mul DWORD PTR [ebp-8]
				mov [ebp-12],eax ; 上方所有行的字节数和

				mov eax,4
				mul DWORD PTR [ebp-4]
				mov [ebp-16],eax ; 此行左边的字节数和

				mov edx,[ebp-12]
				add edx,[ebp-16]

				cmp [Map+edx],3 ; 砖头
				je L_exp_Brick_R
				cmp [Map+edx],11 ; 石头
				je L_exp_Stone_R

				cmp [Map+edx],0 ; 土地
				je L_exp_fire_R
				jmp L_exp_no_fire_R

				L_exp_Brick_R:
					mov [Map+edx],4
					mov [Bombs+esi+24],0
					jmp L_exp_D

				L_exp_Stone_R:
					mov [Bombs+esi+24],0
					jmp L_exp_D

				L_exp_fire_R:
					mov [Bombs+esi+24],1
					jmp L_exp_D

				L_exp_no_fire_R:
					mov [Bombs+esi+24],0
					jmp L_exp_D


			L_exp_D:
				;sub [ebp-4],1
				mov eax,[ebp-4]
				dec eax
				mov [ebp-4],eax

				;add [ebp-8],1
				mov eax,[ebp-8]
				inc eax
				mov [ebp-8],eax

				mov ebx,my_MAP_BLOCKS_PER_ROW
				mov eax,4
				mul ebx
				mul DWORD PTR [ebp-8]
				mov [ebp-12],eax ; 上方所有行的字节数和

				mov eax,4
				mul DWORD PTR [ebp-4]
				mov [ebp-16],eax ; 此行左边的字节数和

				mov edx,[ebp-12]
				add edx,[ebp-16]


				cmp [Map+edx],3 ; 砖头
				je L_exp_Brick_D
				cmp [Map+edx],11 ; 石头
				je L_exp_Stone_D
				cmp [Map+edx],0 ; 土地
				je L_exp_fire_D
				jmp L_exp_no_fire_D
				

				L_exp_Brick_D:
					mov [Map+edx],4
					mov [Bombs+esi+28],0
					jmp L_exp_end

				L_exp_Stone_D:
					mov [Bombs+esi+28],0
					jmp L_exp_end

				L_exp_fire_D:
					mov [Bombs+esi+28],1
					jmp L_exp_end

				L_exp_no_fire_D:
					mov [Bombs+esi+28],0
					jmp L_exp_end

			L_exp_end:
				mov [Bombs+esi],2
				add esp,16
				jmp BombExplodingEachLoop

BombExplodingReturn:
	mov esp,ebp
	pop ebp
	ret

BrickDying:
	push ebp
	mov ebp,esp

	; 遍历一遍地图，根据每一块的id号
	
	mov ecx,my_MAP_BLOCKS_TOTAL
		BrickDyingEach:
			cmp [Map+ecx*4-4],4
			jge PreNextDyingBrick
			jmp BrickDyingEachLoop

			PreNextDyingBrick:
				cmp [Map+ecx*4-4],9
				jle NextDyingBrickState
				jmp BrickDyingEachLoop

				NextDyingBrickState:
					inc [Map+ecx*4-4]
					cmp [Map+ecx*4-4],10
					je CancelBrick
					jmp BrickDyingEachLoop

					CancelBrick:
						mov [Map+ecx*4-4],0

			cmp [Map+ecx*4-4],4
			je DrawBrickDying_1

	BrickDyingEachLoop:
		loop BrickDyingEach
		jmp BrickDyingReturn

BrickDyingReturn:
	mov esp,ebp
	pop ebp
	ret


GhostsMoving:
	mov ecx,MAX_GHOST_NUM
	mov esi,0

	GhostsMovingEach:
		push ecx

		cmp [Ghost+esi],1
		jne GhostsMovingEachLoop

		cmp [Ghost+esi+16],GHOST_DIR_TIME_SCALE
		je ChangeGhostDir
		inc [Ghost+esi+16]
		L_G_L:
		cmp [Ghost+esi+12],DIRECTION_LEFT
		je MoveGhostLeft
		L_G_U:
		cmp [Ghost+esi+12],DIRECTION_UP
		je MoveGhostUp
		L_G_R:
		cmp [Ghost+esi+12],DIRECTION_RIGHT
		je MoveGhostRight
		L_G_D:
		cmp [Ghost+esi+12],DIRECTION_DOWN
		je MoveGhostDown

	GhostsMovingEachLoop:
		add esi,GHOST_SIZE
		pop ecx
		loop GhostsMovingEach
		jmp GhostsMovingReturn

		CheckMoveGhostLeft:
			mov eax,OFFSET Ghost
			add eax,esi
			push esi
			push eax
			call CheckGhostCanGo
			pop esi
			add [Ghost+esi+4],GHOST_STEP
			cmp eax,1
			jne MoveGhostBackToRight     ; 1 表示可以走
			sub [Ghost+esi+4],GHOST_STEP
			jmp GhostsMovingEachLoop

		CheckMoveGhostUp:
			mov eax,OFFSET Ghost
			add eax,esi
			push esi
			push eax
			call CheckGhostCanGo
			pop esi
			add [Ghost+esi+8],GHOST_STEP
			cmp eax,1
			jne MoveGhostBackToDown     ; 1 表示可以走
			sub [Ghost+esi+8],GHOST_STEP
			jmp GhostsMovingEachLoop

		CheckMoveGhostRight:
			mov eax,OFFSET Ghost
			add eax,esi
			push esi
			push eax
			call CheckGhostCanGo
			pop esi
			sub [Ghost+esi+4],GHOST_STEP
			cmp eax,1
			jne MoveGhostBackToLeft    ; 1 表示可以走
			add [Ghost+esi+4],GHOST_STEP

			jmp GhostsMovingEachLoop
		CheckMoveGhostDown:
			mov eax,OFFSET Ghost
			add eax,esi
			push esi
			push eax
			call CheckGhostCanGo
			pop esi
			sub [Ghost+esi+8],GHOST_STEP

			cmp eax,1
			jne MoveGhostBackToUp    ; 1 表示可以走
			add [Ghost+esi+8],GHOST_STEP

			jmp GhostsMovingEachLoop

	

		ChangeGhostDir:
			mov [Ghost+esi+16],0
			mov eax,4
			call RandomRange
			mov [Ghost+esi+12],eax
			jmp GhostsMovingEachLoop

		MoveGhostLeft:
			sub [Ghost+esi+4],GHOST_STEP
			jmp CheckMoveGhostLeft

		MoveGhostUp:
			sub [Ghost+esi+8],GHOST_STEP
			jmp CheckMoveGhostUp

		MoveGhostRight:
			add [Ghost+esi+4],GHOST_STEP
			jmp CheckMoveGhostRight
		MoveGhostDown:
			add [Ghost+esi+8],GHOST_STEP
			jmp CheckMoveGhostDown


		MoveGhostBackToRight:
			;add [Ghost+esi+4],GHOST_STEP
			jmp ChangeGhostDir
			;jmp GhostsMovingEachLoop

		MoveGhostBackToDown:
			;add [Ghost+esi+8],GHOST_STEP
			jmp ChangeGhostDir
			;jmp GhostsMovingEachLoop

		MoveGhostBackToLeft:
			;sub [Ghost+esi+4],GHOST_STEP
			jmp ChangeGhostDir
			;jmp GhostsMovingEachLoop

		MoveGhostBackToUp:
			;sub [Ghost+esi+8],GHOST_STEP
			jmp ChangeGhostDir
			;jmp GhostsMovingEachLoop

GhostsMovingReturn:
	ret



IsGameOver:
	cmp [GameOverFlag],1
	je IsGameOverRET


	cmp [IsAllGhostDie],TRUE
	je yesalldie
	mov [GameOverFlag],0
	jmp IsGameOverRET

	yesalldie:
		mov [GameOverFlag],1
		mov [WhichMenu],2
		mov [IsAllGhostDie],FALSE

IsGameOverRET:
ret


; 1 表示可以走； 0 表示不能走（发生碰撞）
CheckManCanGo:  ; 参数：人的地址   ; 功能： 判断人是否与地形元素碰撞
	push ebp
	mov ebp,esp

	;mov esi,[ebp+8]
	call GetManRect

	; 是否到地图边界
	cmp eax,0
	jl CheckManCanGoFail
	cmp ebx,0
	jl CheckManCanGoFail
	cmp ecx,my_MAP_PX_WIDTH
	jg CheckManCanGoFail
	cmp edx,my_MAP_PX_HEIGHT
	jg CheckManCanGoFail

	sub esp,24
	mov [ebp-4],eax  ; left
	mov [ebp-8],ebx ; top
	mov [ebp-12],ecx ; right
	mov [ebp-16],edx ; bottom


	mov esi,eax
	mov edi,ebx
	sar esi,5   ; 除以 32
	sar edi,5   ; 除以 32
	mov [ebp-20],esi      ; X位置(0-20)
	mov [ebp-24],edi      ; Y位置(0-20)
	push [ebp-24]
	push [ebp-20]
	call GetBlockRect

	push edx
	push ecx
	push ebx
	push eax
	push [ebp-16]
	push [ebp-12]
	push [ebp-8]
	push [ebp-4]
	call RectConflict
	cmp eax,1
	je CheckManCanGoFail

	inc DWORD ptr [ebp-20] ;  X ++
	push [ebp-24]
	push [ebp-20]        ;
	call GetBlockRect
	
	push edx
	push ecx
	push ebx
	push eax
	push [ebp-16]
	push [ebp-12]
	push [ebp-8]
	push [ebp-4]
	call RectConflict
	cmp eax,1
	je CheckManCanGoFail

	inc DWORD ptr [ebp-24] ;  Y ++
	push [ebp-24]
	push [ebp-20]        ;
	call GetBlockRect
	
	push edx
	push ecx
	push ebx
	push eax
	push [ebp-16]
	push [ebp-12]
	push [ebp-8]
	push [ebp-4]
	call RectConflict
	cmp eax,1
	je CheckManCanGoFail

	dec DWORD ptr [ebp-20] ;  X --
	push [ebp-24]
	push [ebp-20]        ;
	call GetBlockRect
	
	push edx
	push ecx
	push ebx
	push eax
	push [ebp-16]
	push [ebp-12]
	push [ebp-8]
	push [ebp-4]
	call RectConflict
	cmp eax,1
	je CheckManCanGoFail

	mov eax,1
	jmp CheckManCanGoReturn

	CheckManCanGoFail:
		mov eax,0
CheckManCanGoReturn:
	mov esp,ebp
	pop ebp
	ret 4


; 1 表示可以走； 0 表示不能走（发生碰撞）
CheckGhostCanGo:  ; 参数：鬼的地址   ; 功能： 判断鬼是否与地形元素碰撞
	push ebp
	mov ebp,esp

	mov esi,[ebp+8]
	push esi
	call GetGhostRect

	; 是否到地图边界
	cmp eax,0
	jl CheckGhostCanGoFail
	cmp ebx,0
	jl CheckGhostCanGoFail
	cmp ecx,my_MAP_PX_WIDTH
	jg CheckGhostCanGoFail
	cmp edx,my_MAP_PX_HEIGHT
	jg CheckGhostCanGoFail

	sub esp,24
	mov [ebp-4],eax  ; left
	mov [ebp-8],ebx ; top
	mov [ebp-12],ecx ; right
	mov [ebp-16],edx ; bottom


	mov esi,eax
	mov edi,ebx
	sar esi,5   ; 除以 32
	sar edi,5   ; 除以 32
	mov [ebp-20],esi      ; X位置(0-20)
	mov [ebp-24],edi      ; Y位置(0-20)
	push [ebp-24]
	push [ebp-20]
	call GetBlockRect

	push edx
	push ecx
	push ebx
	push eax
	push [ebp-16]
	push [ebp-12]
	push [ebp-8]
	push [ebp-4]
	call RectConflict
	cmp eax,1
	je CheckGhostCanGoFail

	inc DWORD ptr [ebp-20] ;  X ++
	push [ebp-24]
	push [ebp-20]        ;
	call GetBlockRect
	
	push edx
	push ecx
	push ebx
	push eax
	push [ebp-16]
	push [ebp-12]
	push [ebp-8]
	push [ebp-4]
	call RectConflict
	cmp eax,1
	je CheckGhostCanGoFail

	inc DWORD ptr [ebp-24] ;  Y ++
	push [ebp-24]
	push [ebp-20]        ;
	call GetBlockRect
	
	push edx
	push ecx
	push ebx
	push eax
	push [ebp-16]
	push [ebp-12]
	push [ebp-8]
	push [ebp-4]
	call RectConflict
	cmp eax,1
	je CheckGhostCanGoFail

	dec DWORD ptr [ebp-20] ;  X --
	push [ebp-24]
	push [ebp-20]        ;
	call GetBlockRect
	
	push edx
	push ecx
	push ebx
	push eax
	push [ebp-16]
	push [ebp-12]
	push [ebp-8]
	push [ebp-4]
	call RectConflict
	cmp eax,1
	je CheckGhostCanGoFail

	mov eax,1
	jmp CheckGhostCanGoReturn

	CheckGhostCanGoFail:
		mov eax,0
CheckGhostCanGoReturn:
	mov esp,ebp
	pop ebp
	ret 4

; 求出阻塞区域 eax(left),ebx(top),ecx(right),edx(down)
GetBlockRect:   ; 参数 x, y (0-20)
	push ebp
	mov ebp,esp

	mov eax,[ebp+12] ;y
	mov ebx,my_MAP_BLOCKS_PER_ROW
	mul ebx     ;edx:eax = y*21
	mov ebx,[ebp+8] ; x
	add eax,ebx      ; y* 21+x
	mov ebx,eax      ; y*21 + x
	mov eax,[Map+ebx*4]  ; 取得地图元素

	cmp DWORD ptr [ebp+8],my_MAP_BLOCKS_PER_ROW  ; x 是 21 吗
	jge NoBlock                ; x >= 21 , 没有地图块
	cmp DWORD ptr [ebp+12],my_MAP_BLOCKS_PER_ROW ; y 是 21 吗
	jge NoBlock               ; y >= 21, 没有地图块
	cmp ebx,my_MAP_BLOCKS_TOTAL               
	jge NoBlock				; y * 21 + x >= 441 没有地图块

	cmp eax,3          ; 砖墙
	je DoBlock
	cmp eax,11        ; 石头
	je DoBlock
	jmp NoBlock

	DoBlock:
		mov eax,[ebp+8]      
		sal eax,5            ; x*32
		mov ebx,[ebp+12]
		sal ebx,5                ; y*32
		mov ecx,eax
		add ecx,32            ;x*32+32
		mov edx,ebx
		add edx,32            ;y*32+32
		jmp GetBlockRectReturn
	NoBlock:
		mov eax,-1
		mov ebx,-1
		mov ecx,-1
		mov edx,-1
		jmp GetBlockRectReturn
GetBlockRectReturn:
	mov esp,ebp
	pop ebp
	ret 8



; eax == 1 表示人站在炸弹上, 并修改 IsManOnBomb 的值
CheckManOnBomb:
	cmp [PlayerMan],1
	jne CheckManOnBombReturn
	mov ecx,MAX_BOMB_NUM
	mov esi,OFFSET Bombs

	CheckManOnEachBomb:
		push ecx
		push esi

		call GetManRect
		pop esi
		push edx
		push ecx
		push ebx
		push eax

		push esi
		call GetBombRect
		push edx
		push ecx
		push ebx
		push eax
		call RectConflict
		cmp eax, 1
		jne CheckManOnEachBombLoop
		ManOnBomb:
			pop ecx
			mov eax,1
			mov [IsManOnBomb],TRUE
			ret
	CheckManOnEachBombLoop:
		add esi,BOMB_SIZE
		pop ecx
		loop CheckManOnEachBomb
		mov [IsManOnBomb],FALSE
		jmp CheckManOnBombReturn

CheckManOnBombReturn:
	ret	




; 得到炸弹的碰撞区域
GetBombRect:   ; 参数：炸弹的地址  ;  返回 eax(left), ebx(top) ,ecx(right), edx(bottom)
	push ebp
	mov ebp,esp

	mov esi,[ebp+8]
	mov eax,[esi+4] ; x
	mov ebx,[esi+8] ; y
	add eax,1
	add ebx,1
	mov ecx,eax
	mov edx,ebx
	add ecx,30
	add edx,30

GetBombRectReturn:
	mov esp,ebp
	pop ebp
	ret 4

; 得到人的碰撞区域
GetManRect:   ; 参数：无  ;  返回 eax(left), ebx(top) ,ecx(right), edx(bottom)
	push ebp
	mov ebp,esp
	
	mov eax,[PlayerMan+4] ; x
	mov ebx,[PlayerMan+8] ; y
	add eax,8
	add ebx,8
	mov ecx,eax
	mov edx,ebx
	add ecx,16
	add edx,16

GetManRectReturn:
	mov esp,ebp
	pop ebp
	ret

; 得到鬼的碰撞区域
GetGhostRect:   ; 参数：鬼的地址  ;  返回 eax(left), ebx(top) ,ecx(right), edx(bottom)
	push ebp
	mov ebp,esp
	
	mov esi,[ebp+8]
	mov eax,[esi+4] ; x
	mov ebx,[esi+8] ; y
	add eax,2
	add ebx,2
	mov ecx,eax
	mov edx,ebx
	add ecx,27
	add edx,27

GetGhostRectReturn:
	mov esp,ebp
	pop ebp
	ret 4

; eax == 1 表示有碰撞
RectConflict:	;r1x1,r1y1,r1x2,r1y2,r2x1,r2y1,r2x2,r2y2
		push ebp
		mov ebp,esp
		
		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		push [ebp+12]
		push [ebp+8]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		push [ebp+20]
		push [ebp+8]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		push [ebp+12]
		push [ebp+16]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		push [ebp+20]
		push [ebp+16]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		push [ebp+28]
		push [ebp+24]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		push [ebp+36]
		push [ebp+24]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		push [ebp+28]
		push [ebp+32]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		push [ebp+36]
		push [ebp+32]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		mov eax,0
		jmp RectConflictFail
	RectConflictSucceed:
		mov eax,1
	RectConflictFail:
		mov esp,ebp
		pop ebp
		ret 32

PointInRect:	;x1,y1,rx1,ry1,rx2,ry2
		mov eax,0
		mov ebx,[esp+4]
		mov ecx,[esp+8]
		cmp [esp+12],ebx
		jg PointInRectFail
		cmp [esp+20],ebx
		jle PointInRectFail
		cmp [esp+16],ecx
		jg PointInRectFail
		cmp [esp+24],ecx
		jle PointInRectFail
		mov eax,1
	PointInRectFail:
		ret 24
END WinMain

