.386
.model   flat,stdcall
option   casemap:none

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc proto :DWORD,:DWORD,:DWORD,:DWORD
Display proto :DWORD

include menuID.INC

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc

includelib masm32.lib
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib

Good struct 
	gname db 10 dup(0)
	discount db 0
	cost dw 0
	price dw 0
	wv dw 0; wholesale volumes      
	sv dw 0; sale volumes
  rec dw 0;
Good ends

.data
ClassName db 'TryWinClass',0
AppName db 'Lab 5',0
MenuName db 'MyMenu',0
DlgName db 'MyDialog',0
AboutMsg db 'I am Chenyang',0
hInstance dd 0
CommandLine dd 0

goods_count dd 9;
goods Good <'PEN',3,56,70,35,0,0>,
           <'BOOK',7,30,25,34,0,0>,
           <'ERASER',3,50,75,34,0,0>,
           <'DOLL',5,40,552,24,0,0>,
           <'VIBRATOR',6,30,35,34,0,0>,
           <'DILDO',5,20,35,34,0,0>,
           <'CONDOM',3,30,33,34,0,0>,
           <'ONACUP',8,10,53,30,0,0>,
           <'BUTT PLUG',7,5,12,13,0,0>
sequence dd 0,1,2,3,4,5,6,7,8

buffer db 16 dup(0);
format_d db "%d",0
format_s db "%s",0
msg_id db 'ID',0
msg_name db 'Name',0
msg_cost db 'Cost',0
msg_price db 'Price',0
msg_discount db 'Discount',0
msg_wv db 'Whole Volume',0
msg_sv db 'Sell Volume',0
msg_rec db 'Recommend',0
menuItem db 0;

.code
start: 
invoke GetModuleHandle,NULL
  mov    hInstance,eax
  invoke GetCommandLine
  mov    CommandLine,eax
  invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
  invoke ExitProcess,eax
  ;;
WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
  LOCAL  wc:WNDCLASSEX
  LOCAL  msg:MSG
  LOCAL  hWnd:HWND
  invoke RtlZeroMemory,addr wc,sizeof wc
  mov    wc.cbSize,SIZEOF WNDCLASSEX
  mov    wc.style, CS_HREDRAW or CS_VREDRAW
  mov    wc.lpfnWndProc, offset WndProc
  mov    wc.cbClsExtra,NULL
  mov    wc.cbWndExtra,NULL
  push   hInst
  pop    wc.hInstance
  mov    wc.hbrBackground,COLOR_WINDOW+1
  mov    wc.lpszMenuName, offset MenuName
  mov    wc.lpszClassName,offset ClassName
  invoke LoadIcon,NULL,IDI_APPLICATION
  mov    wc.hIcon,eax
  mov    wc.hIconSm,0
  invoke LoadCursor,NULL,IDC_ARROW
  mov    wc.hCursor,eax
  invoke RegisterClassEx, addr wc
  INVOKE CreateWindowEx,NULL,addr ClassName,addr AppName,\
               WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
               CW_USEDEFAULT,820,600,NULL,NULL,\
               hInst,NULL
  mov    hWnd,eax
  INVOKE ShowWindow,hWnd,SW_SHOWNORMAL
  INVOKE UpdateWindow,hWnd
  ;;
MsgLoop:
  INVOKE GetMessage,addr msg,NULL,0,0
  cmp    EAX,0
  je     ExitLoop
  INVOKE TranslateMessage,addr msg
  INVOKE DispatchMessage,addr msg
	jmp    MsgLoop 
ExitLoop:
  mov eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	     LOCAL  hdc:HDC
	     LOCAL  ps:PAINTSTRUCT
     .IF     uMsg == WM_DESTROY
	     invoke PostQuitMessage,NULL
     .ELSEIF uMsg == WM_KEYDOWN
	    .IF     wParam == VK_F1
             ;;your code
	    .ENDIF
     .ELSEIF uMsg == WM_COMMAND
	    .IF     wParam == IDM_FILE_EXIT
		    invoke SendMessage,hWnd,WM_CLOSE,0,0
	    .ELSEIF wParam == IDM_ACTION_REC
		    mov menuItem, 1
		    invoke InvalidateRect,hWnd,0,1  ;?????????????
		    invoke UpdateWindow, hWnd
	    .ELSEIF wParam == IDM_ACTION_SORT
		    mov menuItem, 2
		    invoke InvalidateRect,hWnd,0,1  ;?????????????
		    invoke UpdateWindow, hWnd
	    .ELSEIF wParam == IDM_HELP_ABOUT
		    invoke MessageBox,hWnd,addr AboutMsg,addr AppName,0
	    .ENDIF
     .ELSEIF uMsg == WM_PAINT
             invoke BeginPaint,hWnd, addr ps
             mov hdc,eax
	     .IF menuItem == 1
		      invoke Display,hdc
	     .ELSEIF menuItem == 2
          call bubble_sort
		      invoke Display,hdc
	     .ENDIF
	     invoke EndPaint,hWnd,addr ps
     .ELSE
             invoke DefWindowProc,hWnd,uMsg,wParam,lParam
             ret
     .ENDIF
  	     xor    eax,eax
	     ret
WndProc endp


calc_rec_o proc
  pusha
  mov ax, goods[edi].cost
  shl ax, 7; ax=cost*128
  push ax
  mov ax, goods[edi].price
  xor dx,dx
  mul goods[edi].discount
  mov bx,10
  div bx
  mov bx, ax; bx=price*discount/10=real_price
  pop ax; ax=cost*128
  xor dx,dx
  div bx; ax=cost*128/real_price
  mov si, ax; cx=cost*128/real_price
  mov ax, goods[edi].sv; ax=sv
  shl ax, 6; ax <<6 /2
  xor dx, dx
  div goods[di].wv; ax=sv*128/wv
  add ax, si; ax=cost*128/real_price +sv*128/(wv*2)
  mov word ptr goods[edi].rec, ax
  popa
  ret
calc_rec_o endp

StrLen proc item:DWORD
  push ebx
  mov eax,item               ; get pointer to string
  lea edx,[eax+3]            ; pointer+3 used in the end
  @@:     
  mov ebx,[eax]              ; read first 4 bytes
  add eax,4                  ; increment pointer
  lea ecx,[ebx-01010101h]    ; subtract 1 from each byte
  not ebx                    ; invert all bytes
  and ecx,ebx                ; and these two
  and ecx,80808080h    
  jz @B                     ; no zero bytes, continue loop
  test ecx,00008080h          ; test first two bytes
  jnz @F
  shr ecx,16                 ; not in the first 2 bytes
  add eax,2
  @@:
  shl cl,1                   ; use carry flag to avoid branch
  sbb eax,edx                ; compute length
  pop ebx
  ret
StrLen endp

@display macro pos_x, pos_y, format
  pusha
  mov ebx, YY_GAP
  imul ebx, pos_y
  add ebx, YY
  invoke wsprintf, offset buffer,offset format, eax
  invoke StrLen,offset buffer
  invoke TextOut,hdc,XX+ pos_x *XX_GAP,ebx,offset buffer,eax  
  popa
endm

bubble_sort proc
  pusha
  mov ecx, 0; int i = 0
  .WHILE ecx < goods_count; while (i < goods_count) {
    mov esi, sequence[ecx*4]; i
    imul esi, type Good
    mov edx, 0; int j = 0
    inc edx; j++
    .WHILE edx < goods_count; while (j < goods_count) {
      mov edi, sequence[edx*4]; j=i+1
      imul edi, type Good
      movzx eax, goods[esi].rec;
      movzx ebx, goods[edi].rec 
      .IF eax<ebx; if (goods[i].rec < goods[j].rec) {
        ; swap(sequence[i],sequence[j])
        mov eax, sequence[ecx*4]
        xchg eax,sequence[edx*4]
        mov sequence[ecx*4],eax
      .ENDIF; }
      inc edx; j++
    .ENDW; }
    inc ecx; i++
  .ENDW; }
  popa
  ret
bubble_sort endp

Display proc hdc:HDC
  XX = 10
  YY = 10
	XX_GAP = 100
	YY_GAP = 30

  lea eax, msg_id
  @display 0,0, format_s
  lea eax, msg_name
  @display 1,0, format_s
  lea eax, msg_cost
  @display 2,0, format_s
  lea eax, msg_price
  @display 3,0, format_s
  lea eax, msg_discount
  @display 4,0, format_s
  lea eax, msg_wv
  @display 5,0, format_s
  lea eax, msg_sv
  @display 6,0, format_s
  lea eax, msg_rec
  @display 7,0, format_s
  invoke MoveToEx, hdc, 0, YY_GAP, NULL
  invoke LineTo, hdc, 8*XX_GAP, YY_GAP
  mov ecx, 1
    .while ecx <= goods_count
      push ecx
      
      mov ebx, YY_GAP
      imul ebx, ecx
      add ebx, YY

      dec ecx
      mov edi, sequence[ecx*4]
      mov edx, edi
      imul edi, type Good
      inc ecx
      mov eax, edx
      @display 0,ecx, format_d
      lea eax, goods[edi].gname
      @display 1,ecx, format_s
      movzx eax, goods[edi].cost
      @display 2,ecx, format_d
      movzx eax, goods[edi].price
      @display 3,ecx, format_d
      movzx eax, goods[edi].discount
      @display 4,ecx, format_d
      movzx eax, goods[edi].wv
      @display 5,ecx, format_d
      movzx eax, goods[edi].sv
      @display 6,ecx, format_d
      call calc_rec_o
      movzx eax, goods[edi].rec
      @display 7,ecx, format_d

      pop ecx
      inc ecx
    .endw
    ret
Display endp

end start
