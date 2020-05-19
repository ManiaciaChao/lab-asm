name task1

.386
include macros.asm

Good struct 
	gname db 10 dup(0)
	discount db 0
	cost dw 0
	price dw 0
	wv dw 0; wholesale volumes      
	sv dw 0; sale volumes
    rec dw 0;
Good ends

stack_size = 200
stack segment use16 stack; current_stack=0
    db stack_size dup(0)
stack ends
stackbak segment use16; current_stack=1
    db stack_size dup(0)
stackbak ends

data segment use16 public
    ; configuration
    username equ 'chenyang'
    key equ 64h
    config_username db username,'$'
    ; 70,61,73,73,77,6f,72,64;'password' xor username
    ; config_password db 70h,61h,73h,73h,77h,6fh,72h,64h,'$'
    config_password db 19d, 9d,22d,29d,14d,14d,28d, 3d,'$'
    ; state
    state_auth db 0
    state_select_good dw -1
	state_username_meta db 2 dup(0)
	state_username db 16 dup(0)
	state_password_meta db 2 dup(0)
	state_password db 16 dup(0)
    state_goodname_meta db 2 dup(0)
	state_goodname db 10 dup(0)
    state_ss dw ?
    state_int_installed db 0
    state_edit_meta db 2 dup(0)
    state_edit_buf db 16 dup(0)
    ; model
    number = 1
    goods Good <'PEN$',3,56 xor key,70,70,0,0>, number dup (<'BOOK$',7,30 xor key,25,70,0,0>)
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
    msg_menu_cs db '  8. current ss$'
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
    msg_menu_cs_prompt db 'current ss:$'


data ends
code segment use16
	assume cs:code, ds:data, ss:stack
    menu_var dw menu
    jmptble dw case1,case2,case3,case4,case5,case6,case7,case8,case9

include cases.asm

start:
    mov ax, data
    mov ds, ax
    mov ax, stackbak
    mov es, ax

    ; check interval
    push ds
    xor ax, ax
    mov ds, ax
    mov ax, ds:[01h*4]
    xor al, ah
    cmp al, 1
    jne check_countinue
    db 'fight for freedom, stand with CR.'
    db 'hk is dying!'
  another_stack:
    cli
    push menu_var
    pop ax
    mov bx, [esp-2]
    sti
    jmp bx
  check_countinue:
    mov bx, ds:[03h*4]
    cmp ax, bx
    jne exit
	pop ds
    ; push ax
    @cls
    jmp another_stack
menu:
    ; pop ax
    ; cmp state_auth, al ; al ==0
    ; jne case9
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
    mov cx, [goods_types]
    dec cx
    mov di,0
  recommend_loop_1:
    call calc_rec_o
    add di, type Good
    loop recommend_loop_1
    jmp menu
case5:
    jmp menu
case6:
    @cls
    call modify
    @logln msg_menu_hr
    jmp menu
case7:
    @cls
    call far ptr init_int
    jmp menu
case8:
    @cls
    @log msg_menu_cs_prompt
    mov word ptr [state_ss], ss
    @dump state_ss,1,2
    @breakline
    @logln msg_menu_hr
    jmp menu
case9:
    jmp exit
exit:
    cmp cs:int_installed, 1
    jne ex
    call far ptr rm_int
  ex:
    @exit
code ends
end start