
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

WindowName BYTE "Tank",0
className BYTE "Tank",0
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
WhichMenu DWORD 0			; 哪个界面，0表示开始，1表示选择游戏模式，2表示正在游戏，3表示游戏结束
ButtonNumber DWORD 2,3,0,2	; 每个界面下的图标数
SelectMenu DWORD 0			; 正在选择的菜单项
GameMode DWORD 0			; 游戏模式 0为闯关模式，1为挑战模式

UpKeyHold DWORD 0
DownKeyHold DWORD 0
LeftKeyHold DWORD 0
RightKeyHold DWORD 0
SpaceKeyHold DWORD 0
EnterKeyHold DWORD 0

; 0=土地,1=水,2=树,3=墙,4~7=各种墙(上下左右),8=老家,11=铁,12~15=各种铁
Map			DWORD 225 DUP(?)
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
		push 510
		push 650
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
		
		cmp eax,WM_KEYDOWN
		je KeyDownMessage
		cmp eax,WM_KEYUP
		je KeyUpMessage
		cmp eax,WM_CREATE
		je CreateWindowMessage
		cmp eax,WM_CLOSE
		je CloseWindowMessage
		cmp eax,WM_PAINT ;  The message is sent when the UpdateWindow or RedrawWindow function is called
		je PaintMessage
		cmp eax,WM_TIMER
		je TimerMessage
		
		jmp OtherMessage
	
	KeyDownMessage:
		mov eax,[ebp+16] ; 对应  wParam:DWORD, 含有 The virtual-key code of the nonsystem key.

		cmp eax,38
		jne @nup1
		call UpInMenu
		mov UpKeyHold,1
	@nup1:
		cmp eax,40
		jne @ndown1
		call DownInMenu
		mov DownKeyHold,1
	@ndown1:
		cmp eax,37
		jne @nleft1
		mov LeftKeyHold,1
	@nleft1:
		cmp eax,39
		jne @nright1
		mov RightKeyHold,1
	@nright1:
		cmp eax,32
		jne @nspace1
		mov SpaceKeyHold,1
		call EnterInMenu
	@nspace1:
		cmp eax,13
		jne @nenter1
		mov EnterKeyHold,1
		call EnterInMenu
	@nenter1:
		cmp eax,27
		jne @nescape1
		call EscapeInMenu
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
		push 480 ; he bitmap height, in pixels.
		push 640 ; The bitmap width, in pixels.
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

		jmp WinProcExit
		
	CloseWindowMessage:
		push 0
		call PostQuitMessage
		push 1
		push hMainWnd
		call KillTimer
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
		push 480 ; The y-coordinate, in logical coordinates, of the lower-right corner of the rectangle.
		push 640 ; The x-coordinate, in logical coordinates, of the lower-right corner of the rectangle.
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
		push 480
		push 640
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
		cmp WhichMenu,0 ; ; 哪个界面，0表示开始，1表示选择游戏模式，2表示正在游戏，3表示游戏结束
		je DrawMain
		cmp WhichMenu,1
		je DrawMode
		cmp WhichMenu,2
		je DrawGame
		cmp WhichMenu,3
		je DrawResult
		jmp DrawUIReturn

	DrawMain:
		push 0Fh
		push 0Eh
		push 0Dh
		push 0Ch
		push 160
		push 256
		push 4
		call DrawLine

		push 0Fh
		push 0Eh
		push 2Dh
		push 2Ch
		push 192
		push 256
		push 4
		call DrawLine

		jmp DrawMenuSelect
		
	DrawMode:
	
		push 17h
		push 16h
		push 15h
		push 14h
		push 160
		push 256
		push 4
		call DrawLine

		push 17h
		push 16h
		push 1Dh
		push 1Ch
		push 192
		push 256
		push 4
		call DrawLine
		
		push 27h
		push 26h
		push 25h
		push 24h
		push 224
		push 256
		push 4
		call DrawLine
	
		jmp DrawMenuSelect
		
	DrawResult:

		push 1Fh
		push 1Eh
		push 0Fh
		push 0Eh
		push 96
		push 256
		push 4
		call DrawLine
	
		push 27h
		push 26h
		push 25h
		push 24h
		push 160
		push 256
		push 4
		call DrawLine

		push 0Fh
		push 0Eh
		push 2Dh
		push 2Ch
		push 192
		push 256
		push 4
		call DrawLine
	
		jmp DrawMenuSelect
		
	DrawGame:

		call DrawGround
		call DrawWall
		call DrawTankAndBullet
		call DrawTree
		call DrawSideBar
		
		jmp DrawUIReturn
	
	DrawMenuSelect:
	
		push 0Bh
		push 09h
		push 36h
		push 35h
		push 34h
		push 448
		push 480
		push 5
		call DrawLine
		
		mov eax,SelectMenu
		sal eax,5
		add eax,160
		push eax
		push 224
		push 10
		call DrawSpirit
		
	DrawUIReturn:
		ret

DrawHalfSpirit:
		push ebp
		mov ebp,esp
		push ecx
		push edx

		mov eax,[ebp+8]
		mov ebx,eax
		sar eax,3
		and ebx,7h
		sal eax,5
		sal ebx,5
		
		mov ecx,[ebp+12]

		push 0FF00h
		push [DrawHalfSpiritMask+16+ecx*4]
		push [DrawHalfSpiritMask+ecx*4]
		push eax
		push ebx
		push hdcPic
		push [DrawHalfSpiritMask+16+ecx*4]
		push [DrawHalfSpiritMask+ecx*4]
		mov edx,[DWORD PTR ebp+20]
		add edx,[DrawHalfSpiritMask+48+ecx*4]
		push edx
		mov edx,[DWORD PTR ebp+16]
		add edx,[DrawHalfSpiritMask+32+ecx*4]
		push edx
		push hdcMem
		call TransparentBlt

		pop edx
		pop ecx
		mov esp,ebp
		pop ebp

		ret 16
		
DrawSpirit:
		push ebp
		mov ebp,esp

		mov eax,[ebp+8] ; 对应图片块 id ， 第1个参数
		mov ebx,eax

		; 一个映射 ，从图片元素 id 到图片元素的 x, y 坐标
		; 因为位图是8块*8块的，其实就是除以8，得到行数，余8得到列数，再乘以32（一块的边长）就得到了坐标
		sar eax,3
		and ebx,7h  ; 0111b
		sal eax,5
		sal ebx,5

		push 0FF00h ; just green and no red and blue , 把这种颜色当做透明处理

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

DrawLine:
		mov ecx,[esp+4]
		cmp ecx,0
		je DrawLineReturn

		push ebp
		mov ebp,esp
		cmp ecx,0
		mov esi,ebp
		add esi,20
		mov eax,[ebp+12]
	DrawLineLoop:
		push ecx
		push eax
		
		push [ebp+16]
		push eax
		push [esi]
		call DrawSpirit

		pop eax
		pop ecx
		add esi,4
		add eax,32
		loop DrawLineLoop
		
		mov esp,ebp
		pop ebp
		sub esi,16
		mov eax,[esp]
		mov esp,esi
		mov [esp],eax

	DrawLineReturn:
		ret 12

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
		cmp SelectMenu,eax
		jng DownInMenuReturn
		mov SelectMenu,eax
	DownInMenuReturn:
		pop eax
		ret
		
EnterInMenu:
		push eax
		cmp WhichMenu,2
		je EnterInMenuReturn
		mov SpaceKeyHold,0
		mov EnterKeyHold,0
		
		cmp WhichMenu,0
		je EnterInMain
		cmp WhichMenu,1
		je EnterInMode
		cmp WhichMenu,3
		je EnterInResult
		
		jmp EnterInMenuReturn

	EnterInMain:
		cmp SelectMenu,0
		je EnterToMode
		jmp EnterToEndGame

	EnterInMode:
		cmp SelectMenu,2
		je EnterToMain
		mov eax,SelectMenu
		mov GameMode,eax
		mov WhichMenu,2
		call ResetField
		jmp EnterInMenuReturn

	EnterInResult:
		cmp SelectMenu,0
		je EnterToMain
		jmp EnterToEndGame
		
	EnterToMain:
		mov WhichMenu,0
		mov SelectMenu,0
		jmp EnterInMenuReturn
	
	EnterToMode:
		mov WhichMenu,1
		jmp EnterInMenuReturn
	
	EnterToEndGame:
		push 0
		call PostQuitMessage
		push 1
		push hMainWnd
		call KillTimer
	
	EnterInMenuReturn:
		pop eax
		ret

EscapeInMenu:

		mov SelectMenu,0
		mov WhichMenu,0
		cmp WhichMenu,2
		jne EscapeInMenuReturn
		mov WhichMenu,1
	EscapeInMenuReturn:
		ret
		
ResetField:
		mov [Score],0
		mov [Score+4],0
		mov eax,GameMode
		mov ebx,1
		sub ebx,eax
		mov [Round],ebx
		mov [YourLife],5
		mov [YourLife+4],0
		
		mov [YourTank+32],0
		mov [YourTank+48],0
		mov YouDie,0
		call NewRound
		ret
		
NewRound:
		mov WaitingTime,-1

		mov [YourTank],1
		mov [YourTank+4],128
		mov [YourTank+8],448
		mov [YourTank+12],3
		mov [YourTank+16],0
		
		mov eax,[Round]
		mov ebx,12
		mul ebx
		mov ebx,eax
		mov eax,[RoundEnemy+ebx]
		mov [EnemyLife],eax
		mov eax,[RoundEnemy+ebx+4]
		mov [EnemyLife+4],eax
		mov eax,[RoundEnemy+ebx+8]
		mov [EnemyLife+8],eax

		mov ecx,10
		mov esi,offset EnemyTank
	RemoveEnemyTank:
		mov DWORD ptr [esi],0
		mov DWORD ptr [esi+16],0
		add esi,32
		loop RemoveEnemyTank
		
		mov eax,[Round]
		mov ebx,225*4    ; 一个地图的内存字节数，因为地图是 DWORD 类型的
		mul ebx
		mov ebx,eax
		mov ecx,225
	SetMap:     						; 通过一个循环复制地图
		mov eax,[RoundMap+ebx+ecx*4-4]
		mov [Map+ecx*4-4],eax
		loop SetMap

		ret

DrawGround:
		mov ecx,225  ;  15 * 15 ， 对于地图的每一个角落
	DrawGroundLoop:
		mov edx,0     ; 把 edx 置为 0, 使得 edx:eax 的高 32 位为 0
		mov eax,ecx   
		dec eax
		mov esi,15 ; 一行15个

		div esi     ; eax 除以 15
		sal edx,5   ; 余数 乘以 32 
		sal eax,5  ; 商 乘以 32
		add edx,80  ; 加上一个偏移，即地图范围到窗体左边的像素距离
		
		cmp [Map+ecx*4-4],1
		je DrawGroundWater
	
	; 画一块地面
		push ecx ; 把 ecx 压栈，为了保护 ecx 的值，之后会弹出
		push eax ; Y位置
		push edx ; X位置
		push 0 ; 元素id=0 表示地面
		call DrawSpirit 
		pop ecx
	
		loop DrawGroundLoop
		jmp DrawGroundReturn
		
	DrawGroundWater:
	
		push ecx
		mov ebx,[WaterSpirit]
		sar ebx,2
		sar eax,5
		sar edx,5
		add ebx,eax
		add ebx,edx
		and ebx,3
		add ebx,3
		sal eax,5
		sal edx,5
		add edx,16
		push eax
		push edx
		push ebx
		call DrawSpirit
		pop ecx
		
		loop DrawGroundLoop
		
	DrawGroundReturn:
		ret

DrawWall:

		; 遍历一遍地图，根据每一块的id号，进行相应的绘制
		mov ecx,225
	DrawWallLoop:
		mov edx,0
		mov eax,ecx
		dec eax
		mov esi,15
		div esi
		sal edx,5
		sal eax,5
		add edx,80
		
		test [Map+ecx*4-4],4
		jnz DrawWallHalf
		cmp [Map+ecx*4-4],3
		je DrawWallBlock
		cmp [Map+ecx*4-4],11
		je DrawWallMetal
		cmp [Map+ecx*4-4],8
		je DrawWallBase
		
	DrawWallDoLoop:
		loop DrawWallLoop
		jmp DrawWallReturn
	
	DrawWallBlock:
		push ecx
		push eax
		push edx
		push 1
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
	
	DrawWallMetal:
		push ecx
		push eax
		push edx
		push 2
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallBase:
		push ecx
		push eax
		push edx
		push 8
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
		
	DrawWallHalf:
		test [Map+ecx*4-4],8
		jnz DrawMetalWallHalf
		mov ebx,[Map+ecx*4-4]
		and ebx,3

		push ecx
		push eax
		push edx
		push ebx
		push 1
		call DrawHalfSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawMetalWallHalf:
		mov ebx,[Map+ecx*4-4]
		and ebx,3
		push ecx
		push eax
		push edx
		push ebx
		push 2
		call DrawHalfSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallReturn:
		ret

DrawTankAndBullet:
		mov esi,offset YourTank
		mov ecx,12   ; 对于所有的坦克，包括 玩家 和 敌方
	DrawTankAndBulletLoop:
		push esi   ; 坦克地址压栈
		mov eax,0
		cmp [esi],eax  ; 坦克是否存在
		je GoToDrawBulletIThink  ;如果坦克不存在，就不画坦克，就跳
		push ecx
		mov eax,[esi]
		inc eax
		sal eax,3
		add eax,[esi+12]  ;  以上，根据 坦克类型 算出 坦克图片块的 ID
		mov ebx,[esi+4]
		add ebx,80
		
		push [esi+8]
		push ebx
		push eax
		call DrawSpirit
		pop ecx

	GoToDrawBulletIThink:
		mov esi,[esp]
		add esi,16
		mov eax,0
		cmp [esi],eax
		je DrawTankAndBulletLoopContinue
		push ecx
		mov eax,[esi]
		add eax,54
		mov ebx,[esi+4]
		add ebx,80

		push [esi+8]
		push ebx
		push eax
		call DrawSpirit
		pop ecx
		
	DrawTankAndBulletLoopContinue:
		pop esi
		add esi,32   ; 下一行，下一个坦克
		loop DrawTankAndBulletLoop
		ret

DrawTree:
		mov ecx,225
	DrawTreeLoop:
		mov edx,0
		mov eax,ecx
		dec eax
		mov esi,15
		div esi
		sal edx,5
		sal eax,5
		add edx,80
		
		cmp [Map+ecx*4-4],2
		je DrawTreeReal

		loop DrawTreeLoop
		jmp DrawTreeReturn
		
	DrawTreeReal:
	
		push ecx
		push eax
		push edx
		push 7
		call DrawSpirit
		pop ecx
		
		loop DrawTreeLoop

	DrawTreeReturn:
		ret
		
DrawSideBar:
		mov ecx,5
		mov eax,64
		mov ebx,16
		mov esi,offset YourLife
	DrawSideBarLoop:
		push esi
		push ebx
		push ecx
		push eax
		
		push eax
		push 568
		push ebx
		call DrawSpirit
		
		mov eax,[esi]
		mov edx,0
		mov ebx,10
		div ebx
		add edx,30h
		mov ScoreText,dl
		
		mov eax,[esp]
		add eax,8
		push 1
		push offset ScoreText
		push eax
		push 608
		push hdcMem
		call TextOut
		
		pop eax
		pop ecx
		pop ebx
		pop esi
		add esi,4
		add ebx,8
		add eax,48
		loop DrawSideBarLoop
		
		mov eax,0
	DrawSideBarRepeat:
		push eax
		sal eax,6
		add eax,320
		push 2Fh
		push 2Eh
		push eax
		push 568
		push 2
		call DrawLine

		mov esi,[esp]
		mov eax,[Score+4*esi]
		mov esi,offset ScoreText
		add esi,5
		mov ecx,6
		mov ebx,10
	DrawSideBarGetScoreText:
		mov edx,0
		div ebx
		add edx,30h
		mov [esi],dl
		dec esi
		loop DrawSideBarGetScoreText

		mov edi,[esp]
		sal edi,6
		add edi,360
		push 6
		push offset ScoreText
		push edi
		push 576
		push hdcMem
		call TextOut

		push 2Fh
		push 2Eh
		push 320
		push 568
		push 2
		call DrawLine
		
		pop eax
		cmp eax,0
		mov eax,1
		je DrawSideBarRepeat

		ret

TimerTick:
		cmp WaitingTime,0
		jl DontWait
		je ChangeGame
		dec WaitingTime
		jmp DontWait
	ChangeGame:
		cmp YouDie,1
		jne NotGameOver
		mov WhichMenu,3
		mov SelectMenu,0
	NotGameOver:
		call NewRound
		mov WaitingTime,-1
	DontWait:

		inc WaterSpirit    ; 给水的id加1，为了使得水有动态效果
		and WaterSpirit,0Fh

		cmp WhichMenu,2 ; ; 哪个界面，0表示开始，1表示选择游戏模式，2表示正在游戏，3表示游戏结束
		je TimerTickDontReturn
		jmp TimerTickReturn
	TimerTickDontReturn:
		
		cmp UpKeyHold,1
		jne TT@1
		mov [YourTank+12],3    ; 方向，3 表示向上
		sub [YourTank+8],4     ; Y位置 减 4
		push offset YourTank
		push 1
		call CheckCanGo
		test eax,1   ; 与 1 与，碰撞时 eax 等于 0 ，ZF = 1；无碰撞时 eax 等于 1 ，ZF = 0
		jz TT@1Bad   ; 如果是 ZF = 1 （即碰撞了），那么就跳
		push offset YourTank
		call GetTankRect
		push offset YourTank  ; 指定实体
		push edx   ; bottom 
		push ecx  ; right 
		push ebx  ; top
		push eax  ;left
		call GetTankInRect
		cmp eax,0
		je TT@4
	TT@1Bad:
		add [YourTank+8],4 ; Y位置 加 4，恢复
		jmp TT@4
	TT@1:
		cmp DownKeyHold,1
		jne TT@2
		mov [YourTank+12],1  ; 方向，1 表示向下
		add [YourTank+8],4   ; Y位置 加 4
		push offset YourTank
		push 1
		call CheckCanGo
		test eax,1
		jz TT@2Bad
		push offset YourTank
		call GetTankRect
		push offset YourTank
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@4
	TT@2Bad:
		sub [YourTank+8],4
		jmp TT@4
	TT@2:
		cmp LeftKeyHold,1
		jne TT@3
		mov [YourTank+12],2  ; 方向，2 表示向左
		sub [YourTank+4],4   ; X位置 减 4
		push offset YourTank
		push 1
		call CheckCanGo
		test eax,1
		jz TT@3Bad
		push offset YourTank
		call GetTankRect
		push offset YourTank
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@4
	TT@3Bad:
		add [YourTank+4],4
		jmp TT@4
	TT@3:
		cmp RightKeyHold,1
		jne TT@4
		mov [YourTank+12],0  ; 方向，0 表示向右
		add [YourTank+4],4    ; X位置 加 4
		push offset YourTank
		push 1
		call CheckCanGo
		test eax,1
		jz TT@4Bad
		push offset YourTank
		call GetTankRect
		push offset YourTank
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		je TT@4
	TT@4Bad:
		sub [YourTank+4],4
		jmp TT@4
	TT@4:   ; 发射子弹
		cmp SpaceKeyHold,1
		jne TT@5    ; SpaceKeyHold 不是 1 （未按下） 就跳
		cmp DWORD ptr [YourTank+16],0  ; 比较子弹类型
		jne TT@5    ; 如果子弹类型不是 0 （即存在或正在爆炸） 就跳
		cmp DWORD ptr [YourTank],0  ; 比较坦克类型
		je TT@5     ; 如果坦克类型是0， 即不存在，就跳
		mov ebx,[YourTank+12] ; 坦克方向
		mov [YourTank+16],1   ; 子弹类型改为 1 ，即存在
		mov eax,[YourTank+4]  ; 得到坦克 X 位置
		add eax,[BulletPosFix+4*ebx]  ; 修正 X位置，如果坦克向右，则加 10，如果坦克向左，则加 -10
		mov [YourTank+20],eax  ; 设置子弹的 X 位置
		mov eax,[YourTank+8]   ; 得到坦克 Y 位置
		add eax,[BulletPosFix+16+4*ebx]  ; 修正 Y位置
		mov [YourTank+24],eax  ; 设置子弹的 Y 位置
		mov eax,[YourTank+12]  ; 得到坦克方向
		mov [YourTank+28],eax  ; 设置子弹方向
	TT@5:
		mov ecx,12 ; 共有12辆坦克，遍历每个坦克的子弹
		lea esi,YourTank+16 ; 这个位置对应子弹类型(0=不存在,1=存在,2~9=爆炸)
		jmp TTLoopForBullet
		
	TTLoopForBulletContinue:
		add esi,32  ; 下一行，一行有32个字节（8个DWORD）
		loop TTLoopForBullet
		jmp TTLoopForBulletDone
		
	TTLoopForBullet:
		cmp DWORD ptr [esi],0 ; 0 不存在
		je TTLoopForBulletContinue
		cmp DWORD ptr [esi],1 ; 1 存在
		je TTBulletCanMove
		inc DWORD ptr [esi]
		cmp DWORD ptr [esi],10 ; 2~9 爆炸
		jl TTLoopForBulletContinue
		mov DWORD ptr [esi],0 ; 如果大于等于10，就爆炸结束，子弹类型改为不存在
		jmp TTLoopForBulletContinue
	TTBulletCanMove:
		mov ebx,[esi+12]   ; esi 指向 子弹类型， esi + 12 指向 子弹的方向
		mov eax,[esi+4]    ; 子弹 X 位置
		add eax,[BulletMove+4*ebx]   ; 修正子弹 X 位置，若向 右 则加 7，向 左 则加 -7
		mov [esi+4],eax    ; 写回
		mov eax,[esi+8]    ; 子弹 Y位置
		add eax,[BulletMove+16+4*ebx]  ; 修正子弹 Y 位置，向 下 加 7 ，向 上 加 -7
		mov [esi+8],eax    ; 写回
		push esi           ; 把 esi 压栈，保护 子弹类型
		push ecx
		push esi
		push 0 ; 不是 1（坦克），那么就是子弹
		call CheckCanGo
		test eax,1 
		jnz TTBreakDone             ; 如果 eax 是 1，即碰撞，就跳走
		mov esi,BreakWallType
		mov edi,BreakWallPos
		cmp edi,225
		jge TTBreakDone
		cmp esi,3                  ; 如果是墙
		je TTBreakWall
		cmp esi,11                 ; 如果是铁
		je TTBreakMetal
		test esi,4h                 ; 4h = 0100b  , 半个墙的id 的 低第3位 是1
		jnz TTBreakHalf
		jmp TTBreakDone
	TTBreakMetal:
		mov esi,[esp+4]
		mov ebx,[esi-16]
		cmp ebx,4
		jne TTBreakDone
	TTBreakWall:
		mov esi,[esp+4]
		mov ebx,[esi+12]
		mov eax,[Map+edi*4]
		add eax,[DirectionMapToW+4*ebx]
		mov [Map+edi*4],eax
		mov eax,0
		jmp TTBreakDone
	TTBreakHalf: 
		test esi,8h
		jz TTHalfNotMatel
		mov esi,[esp+4]
		mov ebx,[esi-16]
		cmp ebx,4
		jne TTBreakDone
	TTHalfNotMatel:
		mov [Map+edi*4],0
	TTBreakDone:
		pop ecx
		pop esi
		test eax,1
		jz TTBulletBoom
		push ecx
		
		push esi
		call GetBulletRect
		
		push esi
		sub esi,16
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		pop esi
		pop ecx
		cmp eax,0
		je TTCheckBulletDoom
		
		
		mov ebx,eax
		push esi
		push eax
		call FromOnePart
		test eax,1
		jz TTBulletHitTank
		jmp TTCheckBulletDoom
		
	TTBulletHitTank:
		mov edi,[ebx]
		mov DWORD ptr [ebx],0
		push ebx
		call IsEnemy
		cmp eax,1
		jne TTYouDie
		add [Score],200
		sub edi,3
		sal edi,6
		add [Score],edi
		call HaveEnemy
		test eax,1
		jnz TTBulletBoom
		cmp [EnemyLife],0
		jne TTBulletBoom
		cmp [EnemyLife+4],0
		jne TTBulletBoom
		cmp [EnemyLife+8],0
		jne TTBulletBoom
		mov WaitingTime,20
		inc DWORD ptr [Round]
		jmp TTBulletBoom
	TTYouDie:
		cmp DWORD ptr [YourLife],0
		je TTYouReallyDie
		jmp TTBulletBoom
		
	TTYouReallyDie:
		mov WaitingTime,20
		mov YouDie,1
		jmp TTBulletBoom
		
	TTCheckBulletDoom:
		push ecx
		push esi
		call GetBulletRect
		
		push esi
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetBulletInRect
		pop esi
		pop ecx
		cmp eax,0
		je TTLoopForBulletContinue
		
		mov ebx,eax
		push esi
		push eax
		call FromOnePart
		test eax,1
		jnz TTLoopForBulletContinue
		inc DWORD ptr [ebx]

	TTBulletBoom:
		inc DWORD ptr [esi]
		jmp TTLoopForBulletContinue
	TTLoopForBulletDone:
		mov ebx,[Round]
		mov eax,[RoundSpeed+ebx*4]
		call RandomRange
		cmp eax,0
		jne TTCreateNewEnemyDone
		call CreateRandomEnemy
	TTCreateNewEnemyDone:
	
		mov ecx,10
		mov esi,offset EnemyTank
		jmp TTLoopForEnemy
	TTEnemyLoopEnd:
		add esi,32
		loop TTLoopForEnemy
		jmp TTEnemyLoopDone
		
	TTLoopForEnemy:
		cmp DWORD ptr [esi],0
		je TTEnemyLoopEnd
		mov ebx,[esi]
		sub ebx,3
		sal ebx,3
		add ebx,[esi+12]
		mov eax,[esi+4]
		add eax,[TankMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		add eax,[TankMove+16+4*ebx]
		mov [esi+8],eax
		push esi
		push ecx
		push esi
		push 1
		call CheckCanGo
		pop ecx
		pop esi
		test eax,1
		jz TTEnemyCantGo

		push ecx
		push esi
		push esi
		call GetTankRect
		mov esi,[esp]
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetTankInRect
		cmp eax,0
		pop esi
		pop ecx
		je TTEnemyCanGo

	TTEnemyCantGo:
		mov ebx,[esi]
		sub ebx,3
		sal ebx,3
		add ebx,[esi+12]
		mov eax,[esi+4]
		sub eax,[TankMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		sub eax,[TankMove+16+4*ebx]
		mov [esi+8],eax
		mov eax,4
		call RandomRange
		mov [esi+12],eax
	TTEnemyCanGo:
	
		cmp DWORD ptr [esi+16],0
		jne TTEnemyDontShoot
		mov ebx,[esi+12]
		mov DWORD ptr [esi+16],1
		mov eax,[esi+4]
		add eax,[BulletPosFix+4*ebx]
		mov [esi+20],eax
		mov eax,[esi+8]
		add eax,[BulletPosFix+16+4*ebx]
		mov [esi+24],eax
		mov eax,[esi+12]
		mov [esi+28],eax
	TTEnemyDontShoot:
		jmp TTEnemyLoopEnd
	TTEnemyLoopDone:
		
		cmp DWORD ptr [Map+217*4],0
		je TTBeseNotThreatened
		push 0
		push 474
		push 250
		push 454
		push 230
		call GetBulletInRect
		cmp eax,0
		je TTBeseNotThreatened
		mov [Map+217*4],0
		mov DWORD ptr [eax],2
		mov YouDie,1
		mov WaitingTime,20
	TTBeseNotThreatened:
	
		cmp [YourTank],1
		je TTYouDontNeedResetTank
		cmp [YourLife],0
		jle TTYouDontNeedResetTank
		push 0
		push 480
		push 160
		push 448
		push 128
		call GetBulletInRect
		cmp eax,0
		jne TTYouDontNeedResetTank
		push 0
		push 480
		push 160
		push 448
		push 128
		call GetTankInRect
		cmp eax,0
		jne TTYouDontNeedResetTank
		mov [YourTank],1
		mov [YourTank+4],128
		mov [YourTank+8],448
		mov [YourTank+12],3
		dec [YourLife]
	TTYouDontNeedResetTank:
		
	TimerTickReturn:
		ret
		
FromOnePart:
		mov eax,1
		cmp DWORD ptr [esp+4],offset EnemyTank
		jb FOP1
		xor eax,1
	FOP1:
		cmp DWORD ptr [esp+8],offset EnemyTank
		jb FOP2
		xor eax,1
	FOP2:
		ret 8

IsEnemy:
		mov eax,0
		cmp DWORD ptr [esp+4],offset EnemyTank
		jb NoIsntEnemy
		mov eax,1
	NoIsntEnemy:
		ret 4

HaveEnemy:
		push ecx
		push esi
		mov eax,0
		mov ecx,10
		mov esi,offset EnemyTank
	HaveEnemyLoop:
		cmp DWORD ptr[esi],0
		je NoEnemy
		mov eax,1
		jmp HaveEnemyLoopDone
	NoEnemy:
		add esi,32
		loop HaveEnemyLoop
	HaveEnemyLoopDone:
		pop esi
		pop ecx
		ret

CreateRandomEnemy:
		mov eax,3
		call RandomRange
		mov edi,eax
		
		cmp DWORD ptr [EnemyLife+edi*4],0
		jle CreateEnemyRetry
		mov ecx,10
		mov esi,offset EnemyTank
		jmp SearchForIdle

	CreateEnemyRetry:
		cmp [EnemyLife],0
		jne CreateRandomEnemy
		cmp [EnemyLife+4],0
		jne CreateRandomEnemy
		cmp [EnemyLife+8],0
		jne CreateRandomEnemy
		jmp CreateRandomEnemyDone
	SearchForIdle:
		cmp DWORD ptr [esi],0
		je SearchForIdleDone
		add esi,32
		loop SearchForIdle
		jmp CreateRandomEnemyDone
	SearchForIdleDone:
		mov eax,3
		call RandomRange

		mov ebx,[RandomPlace+eax*4]

		push 0
		push 32
		add ebx,32
		push ebx
		push 0
		sub ebx,32
		push ebx
		call GetTankInRect
		cmp eax,0
		jne CreateRandomEnemyDone

		dec [EnemyLife+edi*4]
		add edi,3
		mov DWORD ptr [esi],edi
		mov DWORD ptr [esi+4],ebx
		mov DWORD ptr [esi+8],0
		mov DWORD ptr [esi+12],1
	CreateRandomEnemyDone:
		ret

GetTankInRect:   ; 返回实体的地址，或 0 表示没有实体
		push ebp
		mov ebp,esp
		push ecx
		push esi
		push ebx
		mov ecx,12
		mov esi,offset YourTank   ; 玩家坦克的地址
	GetTankLoop:
		cmp DWORD ptr [esi],0  ; esi 指向一个坦克的地址，如果该坦克不存在，则跳
		je GetTankLoopContinue
		cmp esi,[ebp+24]  ; ebp+24指向指定对象的地址
		je GetTankLoopContinue  ; 如果相同，即指定对象为玩家坦克
		push ecx
		push esi
		call GetTankRect  ; 获取坦克碰撞范围
		push edx   ; bottom 
		push ecx   ; right
		push ebx  ; top
		push eax  ; left
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call RectConflict
		test eax,1
		pop ecx
		jnz GetTankLoopSucceed
	GetTankLoopContinue:
		add esi,32  ; 下一行，下一个辆坦克
		loop GetTankLoop
	GetTankLoopFail:
		mov eax,0
		jmp GetTankDone
	GetTankLoopSucceed:
		mov eax,esi
	GetTankDone:
		pop ebx
		pop esi
		pop ecx
		mov esp,ebp
		pop ebp
		ret 20
		

GetBulletInRect:
		push ebp
		mov ebp,esp
		push ecx
		push esi
		push ebx
		mov ecx,12
		mov esi,offset YourTank
		add esi,16
	GetBulletLoop:
		cmp DWORD ptr [esi],1
		jne GetBulletLoopContinue
		cmp esi,[ebp+24]
		je GetBulletLoopContinue
		push ecx
		push esi
		call GetBulletRect
		push edx
		push ecx
		push ebx
		push eax
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call RectConflict
		test eax,1
		pop ecx
		jnz GetBulletLoopSucceed
	GetBulletLoopContinue:
		add esi,32
		loop GetBulletLoop
	GetBulletLoopFail:
		mov eax,0
		jmp GetBulletDone
	GetBulletLoopSucceed:
		mov eax,esi
	GetBulletDone:
		pop ebx
		pop esi
		pop ecx
		mov esp,ebp
		pop ebp
		ret 20


CheckCanGo:				; 判断实体是否与地形元素碰撞，参数：坦克or子弹（1表示坦克），实体地址
						; 返回后 ,eax 是 0 表示 发生碰撞。如果是 1 ，表示未发生碰撞
		push ebp
		mov ebp,esp
		mov esi,[ebp+12]   ; ebp + 12 表示第 2 个参数，这里是实体的地址
		cmp DWORD ptr [ebp+8],1 
		jne CheckBulletCanGo    ;  如果不是坦克，那么就是子弹，就跳

		push esi    ; 实体的地址，作为参数
		call GetTankRect
		jmp CheckTankCanGo
	CheckBulletCanGo:
	
		push esi
		call GetBulletRect
	CheckTankCanGo:
		mov BreakWallPos,1000
		; 碰到边界
		cmp eax,0
		jl CheckCanGoFail
		cmp ebx,0
		jl CheckCanGoFail
		cmp ecx,480
		jg CheckCanGoFail
		cmp edx,480
		jg CheckCanGoFail
		
		sub esp,24
		mov [ebp-4],eax  ; left
		mov [ebp-8],ebx ; top
		mov [ebp-12],ecx ; right
		mov [ebp-16],edx ; bottom
		
		mov esi,eax
		mov edi,ebx
		sar esi,5
		sar edi,5
		mov [ebp-20],esi
		mov [ebp-24],edi

		push [ebp+8]    ; 坦克 or 子弹， ebp + 8 表示第 1 个参数
		push [ebp-24]     ; Y
		push [ebp-20]   ; X
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
		test eax,1
		jnz CheckCanGoFail

		inc DWORD ptr [ebp-20]
		push [ebp+8]
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
		test eax,1
		jnz CheckCanGoFail

		inc DWORD ptr [ebp-24]
		push [ebp+8]
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
		test eax,1
		jnz CheckCanGoFail

		dec DWORD ptr [ebp-20]
		push [ebp+8]
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
		test eax,1
		jnz CheckCanGoFail

		mov eax,1
		jmp CheckCanGoReturn
		
	CheckCanGoFail:
		mov eax,0
	CheckCanGoReturn:
		mov esp,ebp
		pop ebp
		ret 8

GetBulletRect:	; &bullet
		mov esi,[esp+4]
		mov eax,[esi+4]
		mov ebx,[esi+8]
		add eax,10      ; 子弹 X 位置加10
		add ebx,10      ; 子弹 Y 位置加10
		mov ecx,eax
		mov edx,ebx
		add ecx,12       ; 12 表示子弹碰撞范围的 宽度
		add edx,12       ; 12 表示子弹碰撞范围的 高度
		ret 4
		
GetTankRect:	; &tank     ;  返回 eax(left), ebx(top) ,ecx(right), edx(bottom)
		mov esi,[esp+4]   ; esp 指向 函数的返回地址，esp + 4 指向之前压栈的数，即坦克的地址
		mov eax,[esi+4]   ; 坦克的 X位置
		mov ebx,[esi+8]  ; 坦克的 Y位置
		add eax,4       ; 坦克 X 位置加 4
		add ebx,4       ; 坦克 Y 位置 加 4
		mov ecx,eax     
		mov edx,ebx
		add ecx,23      ; 23 表示坦克碰撞范围的 宽度
		add edx,23      ; 23 表示坦克碰撞范围的 高度
		ret 4

 ; 获得地形的碰撞区域
GetBlockRect:	; x,y,istank
		push ebp
		mov ebp,esp
		mov eax,[ebp+12]
		mov ebx,15
		mul ebx
		mov ebx,[ebp+8]
		add eax,ebx
		mov ebx,eax
		mov eax,[Map+ebx*4]
		mov BreakWallType,eax
		mov BreakWallPos,ebx
		cmp DWORD ptr [ebp+8],15
		jge NoBlock
		cmp DWORD ptr [ebp+12],15
		jge NoBlock
		cmp ebx,225
		jge NoBlock
		cmp eax,0
		je NoBlock
		cmp eax,2
		je NoBlock
		cmp eax,8
		je NoBlock
		cmp DWORD ptr [ebp+16],1
		je @@notbullet
		cmp eax,1
		je NoBlock
	@@notbullet:
		cmp eax,1
		je AllBlock
		cmp eax,3
		je AllBlock
		cmp eax,11
		je AllBlock
	
		and eax,3h
		mov esi,eax
		mov eax,[ebp+8]
		sal eax,5
		mov ebx,[ebp+12]
		sal ebx,5
		add eax,[DrawHalfSpiritMask+32+esi*4]
		add ebx,[DrawHalfSpiritMask+48+esi*4]
		mov ecx,eax
		mov edx,ebx
		add ecx,[DrawHalfSpiritMask+esi*4]
		add edx,[DrawHalfSpiritMask+16+esi*4]

		jmp GetBlockRectReturn
	AllBlock:
		mov eax,[ebp+8]
		sal eax,5
		mov ebx,[ebp+12]
		sal ebx,5
		mov ecx,eax
		add ecx,32
		mov edx,ebx
		add edx,32
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
		ret 12
		
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

