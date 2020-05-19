.386

@exit macro
    mov ah,4ch
    int 21h
endm

@cls macro
	push ax
	mov ax,03h
	int 10h
	pop ax
endm

;Read the character from keyboard
;Mutate AL 
@getchar macro
	mov ah, 01h
	int 21h
endm


;Gets a string from the keyboard
;Change si, bx
;length into bx and data into si
@gets macro ofset:req, limit:req, termin:req
	push ax
	push dx
	push si
	lea dx, ofset
	mov ah, 0ah
	mov si, dx
	mov byte ptr[si], limit
	int 21h
	inc si
	mov bl, [si]
	sub bh, bh
	inc si
	mov byte ptr[bx+si], termin
	pop si
	pop dx
	pop ax
endm

;Display a character to screen
@putchar macro char
	push ax
	push dx
	mov dl, char
	mov ah, 02h
	int 21h
	pop dx
  pop ax
endm

@breakline macro
	@putchar 0ah
	@putchar 0dh
endm

@log macro str
	lea dx, str
	mov ah, 9
	int 21h
endm

@logln macro str
	@log str
	@breakline
endm

@strcmp macro str1:req, str2: req
	lea ax, str1
	push ax
	lea ax, str2
	push ax
	call far ptr strcmp
	add sp, 4
endm

@dump macro addr, n, unitsize
		push si
    lea si, addr
    mov cx, n
    mov bx, unitsize
    call far ptr dump
		pop si
endm

@mutate macro property,n, unitsize
    lea si, property
    mov ax, unitsize
    @dump property, n, unitsize
    @putchar '<'
    call far ptr mutate
    @breakline
endm

stack segment use16 stack
    db 200 dup(0)
stack ends
Good struct 
	gname db 10 dup(0)
	discount db 0
	cost dw 0
	price dw 0
	wv dw 0; wholesale volumes      
	sv dw 0; sale volumes
    rec dw 0;
Good ends

data segment use16 public
    ; configuration
    config_username db 'chenyang$'
    config_password db 'password$'
    ; state
    state_auth db 0
    state_select_good dw -1
	state_username_meta db 2 dup(0)
	state_username db 16 dup(0)
	state_password_meta db 2 dup(0)
	state_password db 16 dup(0)
    state_goodname_meta db 2 dup(0)
	state_goodname db 10 dup(0)
    state_cs dw ?
    state_edit_meta db 2 dup(0)
    state_edit_buf db 16 dup(0)
    ; model
    goods Good <'PEN$',3,56,70,10,0,0>, <'BOOK$',7,30,25,12,0,0>
    goods_types dw number+1;
    ; message for menu
    msg_menu_hr db '--------------------------------$'
    msg_menu_state_prompt db 'State:$'
    msg_menu_current_user db '  current user:$'
    msg_menu_current_good db '  current good:$'
    msg_menu_prompt db 'Options[1-9]:$'
    msg_menu_login db '  1. login/re-login$'
    msg_menu_query_good db '  2. query good$'
    msg_menu_order db '  3. order$'
    msg_menu_recommend db '  4. calculate recommend index$'
    msg_menu_rank db '  5. rank$'
    msg_menu_modify_good db '  6. modify good$'
    msg_menu_transfer db '  7. transfer$'
    msg_menu_cs db '  8. current cs$'
    msg_menu_exit db '  9. exit$'
    ; message for login
    msg_login_username db 'username:$'
    msg_login_password db 'password:$'
    msg_login_resolved db 'login successfully$'
    msg_login_rejected db 'bad login$'
    ; message for query
    msg_query_name db 'name of good:$'
    msg_query_err_not_found db 'no such good'
    msg_query_info_gname db 'name of good:$'
    msg_query_info_cost db 'cost of good:$'
    msg_query_info_price db 'price of good:$'
    msg_query_info_discount db 'discount of good:$'
    msg_query_info_wv db 'wv of good:$'
    msg_query_info_sv db 'sv of good:$'
    msg_query_info_rec db 'recommend index:$'
    ; message for order
    msg_order_done db 'order successfully$'
    msg_order_err_stock db 'error: out of stock$'
    msg_order_err_empty db 'error: cart is empty$'
    ; message for csip
    msg_menu_cs_prompt db 'cs:$'


data ends
code segment use16
	assume cs:code, ds:data, ss:stack
    jmptble dw case1,case2,case3,case4,case5,case6,case7,case8,case9

retsize EQU 0

whex proc
  push ax
  push cx
  push dx
  mov  ah, 2h
  mov  dh, dl
  mov  cl, 4
  shr  dl, cl
  and  dl, 0fh
  cmp  dl, 0ah
  jl  whex_add0
  sub  dl, 0ah
  add  dl, 'A'
  jmp  whex_of
  whex_add0:
  add  dl, '0'
  whex_of:
  int  21h
  mov  cl, 8
  shr  dx, cl
  and  dl, 0fh
  cmp  dl, 0ah
  jl  whex_add1
  sub  dl, 0ah
  add  dl, 'A'
  jmp  whex_over1
  whex_add1:
  add  dl, '0'
  whex_over1:
  int  21h
  pop dx
  pop cx
  pop ax
  ret
whex endp

dump proc far
  push ax
  push bx
  push cx
  push dx
  push si
  mov  ah, 02h
  dump_lop1:
  push cx
  mov  cx, bx
  push bx
  sub  bx, 1
  dump_lop2:
  mov  dl, [si+bx]
  call whex
  dec  bx
  loop dump_lop2
  pop bx
  pop cx
  mov  dl, 'H'
  int  21h
  mov  dl, ' '
  int  21h
  add  si, bx
  loop dump_lop1
  pop si
  pop dx
  pop cx
  pop bx
  pop ax
  ret
dump endp

strcmp proc far
  push bp
  mov bp, sp
  push bx
  push si
  mov bx, word ptr[bp + retsize + 2]
  mov si, word ptr[bp + retsize + 4]
  push cx
  strcmp_loop:
  mov cl, byte ptr[bx]
  cmp cl, 0
  jz strcmp_same
  mov ch, byte ptr[si]
  cmp ch, 0
  jz strcmp_same
  sub cl, ch
  cmp cl, 0
  jnz strcmp_diff
  inc bx
  inc si
  jmp strcmp_loop
  strcmp_same:
  mov ax, 0
  jmp strcmp_exit
  strcmp_diff:
  mov ax, 0
  mov al, cl
  jmp strcmp_exit
  strcmp_exit:
  pop cx
  pop si
  pop bx
  pop bp
  ret
strcmp endp

; optimized
calc_rec_o proc
    ; push ax
    ; push bx
    ; push cx
    ; push dx
    mov ax, goods[di].cost
    shl ax, 7; ax=cost*128
    push ax
    mov ax, goods[di].price
    xor dx,dx
    mul goods[di].discount
    mov bx,10
    div bx
    mov bx, ax; bx=price*discount/10=real_price
    pop ax; ax=cost*128
    xor dx,dx
    div bx; ax=cost*128/real_price
    mov si, ax; cx=cost*128/real_price
    mov ax, goods[di].sv; ax=sv
    shl ax, 6; ax <<6 /2
    xor dx, dx
    div goods[di].wv; ax=sv*128/wv
    add ax, si; ax=cost*128/real_price +sv*128/(wv*2)
    mov word ptr goods[di].rec, ax
    ; pop ax
    ; pop bx
    ; pop cx
    ; pop dx
    ret
calc_rec_o endp

login proc
    ; get input
    @log msg_login_username
    @gets state_username_meta,16,'$'
    @breakline
    @log msg_login_password
    @gets state_password_meta,16,'$'
    @breakline
    @cls
    ; check username
    @strcmp state_username, config_username
    cmp ax,0
    jnz login_rej
    ; check password    mov di, state_select_good
    @strcmp state_password, config_password
    cmp ax,0
    jnz login_rej
    @logln msg_login_resolved
    mov byte ptr[state_auth], 1
    @logln msg_menu_hr
    ret
  login_rej:
    mov byte ptr[state_auth], 0
    @logln msg_login_rejected
    ret
login endp

query proc
    mov cx, [goods_types]
    mov di,0
    @log msg_query_name
    @gets state_goodname_meta,10,'$'
    @breakline
  query_loop:
    @strcmp state_goodname, goods[di].gname
    cmp ax,0
    jz query_resolved
    add di, type Good
    loop query_loop
    ret
  query_resolved:
    mov word ptr[state_select_good], di
    call info
    ret
query endp

info proc
    mov di, state_select_good
    ; @dump goods[di].gname, 1, 2
    ; @breakline
    @log msg_query_info_discount
    @dump goods[di].discount, 1, 1
    @breakline
    ; @log msg_query_info_cost
    ; @dump goods[di].cost, 1, 2
    ; @breakline
    @log msg_query_info_price
    @dump goods[di].price, 1, 2
    @breakline
    @log msg_query_info_wv
    @dump goods[di].wv, 1, 2
    @breakline
    @log msg_query_info_sv
    @dump goods[di].sv, 1, 2
    @breakline
    @log msg_query_info_rec
    @dump goods[di].rec, 1, 2
    @breakline
    @logln msg_menu_hr
    ret
info endp

order proc
    cmp state_select_good, -1
    jz order_rejected_emtpy
    mov di, state_select_good
    mov cx, goods[di].wv
    sub cx, goods[di].sv
    jle order_rejected_stock
    add word ptr goods[di].sv,1
    @logln msg_order_done
    @logln msg_menu_hr
    mov cx, [goods_types]
    sub cx, 1
    xor di, di
  recommend_loop:
    call calc_rec_o
    add di, type Good
    loop recommend_loop
    ret
  order_rejected_stock:
    @logln msg_order_err_stock
    @logln msg_menu_hr
    ret
  order_rejected_emtpy:
    @logln msg_order_err_empty
    @logln msg_menu_hr
    ret
order endp

modify proc
    cmp state_auth, 0
    jz menu
    cmp state_select_good, -1
    jz menu
; 折扣，进货价，销售价，进货总数
    mov di, state_select_good

    @log msg_query_info_discount
    @mutate goods[di].discount, 1,1
    @log msg_query_info_cost
    @mutate goods[di].cost, 1,2
    @log msg_query_info_price
    @mutate goods[di].price, 1,2
    @log msg_query_info_wv
    @mutate goods[di].wv,1, 2
    ret
modify endp



start:
    mov ax, data
    mov ds, ax
    @cls
    ; calc recomment
;     mov cx, [goods_types]
;     dec cx
;     mov di,0
;   recommend_loop:
;     call calc_rec
;     add di, type Good
;     loop recommend_loop
menu:
    ; display menu
    mov ax, type Good
    @logln msg_menu_state_prompt
    @log msg_menu_current_user
    cmp state_auth, 0
    jz m
    @log state_username
  m:
    @breakline
    @log msg_menu_current_good
    cmp state_select_good, -1
    jz n
    mov di, state_select_good
    @log goods[di].gname
  n:
    @breakline
    @logln msg_menu_prompt
    @logln msg_menu_login; case1
    @logln msg_menu_query_good; case2
    @logln msg_menu_order; case3
    @logln msg_menu_recommend; case4
    @logln msg_menu_rank; case5
    @logln msg_menu_modify_good; case6
    @logln msg_menu_transfer; case7
    @logln msg_menu_cs; case8
    @logln msg_menu_exit; case9
    @getchar
    @putchar 0dh
    @putchar 0ah
    mov ah,0
    sub al,30h; convert ascii to real nu(cost/real_price+sv/(2*wv))*128mber
    cmp al,1
    jl menu
    cmp al,9
    jg menu
    ;
    dec al; because there's no case0
    shl al,1; x2
    mov bx,ax
    jmp cs:jmptble[bx]
case1:; login
    call login
    jmp menu
case2:; query
    @cls
    call query
    jmp menu
case3:; order
    @cls
    call order
    jmp menu
case4:;recommend
;     mov cx, [goods_types]
;     dec cx
;     mov di,0
;   recommend_loop:
;     call calc_rec
;     add di, type Good
;     loop recommend_loop
    jmp menu
case5:
    jmp menu
case6:
    call modify
    @logln msg_menu_hr
    jmp menu
case7:
    jmp menu
case8:
    @cls
    @log msg_menu_cs_prompt
    mov word ptr [state_cs], cs
    @dump state_cs,1,2
    @breakline
    @logln msg_menu_hr
    jmp menu
case9:
    jmp exit
exit:
    @exit
code ends
end start