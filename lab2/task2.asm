.386
include m.asm

loopc equ 30000

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

data segment use16
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
    ; model
    number equ 500
    goods Good <'PEN$',3,56,70,loopc,0,0>, number dup (<'BOOK$',7,30,25,loopc,0,0>)
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

; ; imul and div
; calc_rec_i proc
;     push ax
;     push bx
;     push cx
;     push dx
;     mov ax, goods[di].cost
;     imul ax, 128
;     ; shl ax, 7; ax=cost*128
;     push ax
;     mov ax, goods[di].price
;     mov dx, 0
;     mul goods[di].discount
;     mov bx,10
;     idiv bx
;     mov bx, ax; bx=price*discount/10
;     pop ax; ax=cost*128
;     mov dx, 0
;     idiv bx; ax=cost*128/real_price
;     mov cx, ax; cx=cost*128/real_price
;     mov ax, goods[di].sv; ax=sv
;     imul ax, 128
;     ; shl ax, 7; ax <<7
;     mov dx, 0
;     idiv goods[di].wv; ax=sv*128/wv
;     ; shr ax, 1; ax=sv*128/(wv*2)
;     mov bx, 2
;     mov dx, 0
;     idiv bx
;     add ax, cx; ax=cost*128/real_price +sv*128/(wv*2)
;     mov word ptr goods[di].rec, ax
;     pop ax
;     pop bx
;     pop cx
;     pop dx
;     ret
; calc_rec_i endp

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
    jmp menu
  login_rej:
    mov byte ptr[state_auth], 0
    @logln msg_login_rejected
    jmp menu
case2:; query
    @cls
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
    jmp menu
  query_resolved:
    mov word ptr[state_select_good], di
    @log msg_query_info_cost
    @dump goods[di].cost, 1, 2
    @breakline
    @log msg_query_info_price
    @dump goods[di].price, 1, 2
    @breakline
    @log msg_query_info_sv
    @dump goods[di].sv, 1, 2
    @breakline
    @log msg_query_info_rec
    @dump goods[di].rec, 1, 2
    @breakline
    @logln msg_menu_hr
    jmp menu
case3:; order
    @cls
    mov cx, loopc
    @timer_begin
  time_loop:
    push cx
    cmp state_select_good, -1
    jz order_rejected_emtpy

    mov di, state_select_good
    mov cx, goods[di].wv
    sub cx, goods[di].sv
    jle order_rejected_stock
    add word ptr goods[di].sv,1
    @logln msg_order_done
    @logln msg_menu_hr

    mov cx, 2
    ; dec cx
    sub cx, 1
    xor di, di
  recommend_loop:
    ; call calc_rec_o

    add di, 21
    loop recommend_loop
    
    pop cx
    loop time_loop

    @timer_end
    jmp menu
    ; jmp case4

  order_rejected_stock:
    @logln msg_order_err_stock
    @logln msg_menu_hr
    jmp menu
  order_rejected_emtpy:
    @logln msg_order_err_empty
    @logln msg_menu_hr
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