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
obfs_0 label far
    ; check interval
    push ds
jmp far ptr obfs_1
obfs_25 label far
  m:
    @breakline
jmp far ptr obfs_26
obfs_69 label far
    jmp menu
jmp far ptr obfs_70
obfs_27 label far
    cmp state_select_good, -1
jmp far ptr obfs_28
obfs_84 label far
    jmp menu
jmp far ptr obfs_85
obfs_8 label far
  another_stack:
    cli
jmp far ptr obfs_9
obfs_11 label far
    mov bx, [esp-2]
jmp far ptr obfs_12
obfs_88 label far
  ex:
    @exit
obfs_85 label far
case9:
    jmp exit
jmp far ptr obfs_86
obfs_22 label far
    cmp state_auth, 0
jmp far ptr obfs_23
obfs_76 label far
    call far ptr init_int
jmp far ptr obfs_77
obfs_41 label far
    @logln msg_menu_exit; case9
jmp far ptr obfs_42
obfs_56 label far
    jmp menu
jmp far ptr obfs_57
obfs_31 label far
  n:
    @breakline
jmp far ptr obfs_32
obfs_62 label far
    jmp menu
jmp far ptr obfs_63
obfs_45 label far
    mov ah,0
jmp far ptr obfs_46
obfs_54 label far
    mov bx,ax
jmp far ptr obfs_55
obfs_67 label far
    add di, type Good
jmp far ptr obfs_68
obfs_38 label far
    @logln msg_menu_modify_good; case6
jmp far ptr obfs_39
obfs_71 label far
case6:
    @cls
jmp far ptr obfs_72
obfs_37 label far
    @logln msg_menu_rank; case5
jmp far ptr obfs_38
obfs_53 label far
    shl al,1; x2
jmp far ptr obfs_54
obfs_19 label far
menu:
    ; pop ax
    ; cmp state_auth, al ; al ==0
    ; jne case9
    ; display menu
    mov ax, type Good
jmp far ptr obfs_20
obfs_77 label far
    jmp menu
jmp far ptr obfs_78
obfs_42 label far
    @getchar
jmp far ptr obfs_43
obfs_73 label far
    @logln msg_menu_hr
jmp far ptr obfs_74
obfs_5 label far
    jne check_countinue
jmp far ptr obfs_6
obfs_81 label far
    @dump state_ss,1,2
jmp far ptr obfs_82
obfs_17 label far
    ; push ax
    @cls
jmp far ptr obfs_18
obfs_59 label far
    jmp menu
jmp far ptr obfs_60
obfs_65 label far
    mov di,0
jmp far ptr obfs_66
obfs_68 label far
    loop recommend_loop_1
jmp far ptr obfs_69
obfs_44 label far
    @putchar 0ah
jmp far ptr obfs_45
obfs_78 label far
case8:
    @cls
jmp far ptr obfs_79
obfs_47 label far
    cmp al,1
jmp far ptr obfs_48
obfs_39 label far
    @logln msg_menu_transfer; case7
jmp far ptr obfs_40
obfs_10 label far
    pop ax
jmp far ptr obfs_11
obfs_32 label far
    @logln msg_menu_prompt
jmp far ptr obfs_33
obfs_2 label far
    mov ds, ax
jmp far ptr obfs_3
obfs_66 label far
  recommend_loop_1:
    call calc_rec_o
jmp far ptr obfs_67
obfs_74 label far
    jmp menu
jmp far ptr obfs_75
obfs_16 label far
	pop ds
jmp far ptr obfs_17
obfs_3 label far
    mov ax, ds:[01h*4]
    xor al, ah
jmp far ptr obfs_4
obfs_58 label far
    call query
jmp far ptr obfs_59
obfs_33 label far
    @logln msg_menu_login; case1
jmp far ptr obfs_34
obfs_75 label far
case7:
    @cls
jmp far ptr obfs_76
obfs_72 label far
    call modify
jmp far ptr obfs_73
obfs_7 label far
    db 'hk is dying!'
jmp far ptr obfs_8
obfs_57 label far
case2:; query
    @cls
jmp far ptr obfs_58
obfs_52 label far
    dec al; because there's no case0
jmp far ptr obfs_53
obfs_80 label far
    mov word ptr [state_ss], ss
jmp far ptr obfs_81
obfs_20 label far
    @logln msg_menu_state_prompt
jmp far ptr obfs_21
obfs_49 label far
    cmp al,9
jmp far ptr obfs_50
obfs_14 label far
  check_countinue:
    mov bx, ds:[03h*4]
    cmp ax, bx
jmp far ptr obfs_15
obfs_4 label far
    cmp al, 1
jmp far ptr obfs_5
obfs_12 label far
    sti
jmp far ptr obfs_13
obfs_48 label far
    jl menu
jmp far ptr obfs_49
obfs_50 label far
    jg menu
jmp far ptr obfs_51
obfs_55 label far
    jmp cs:jmptble[bx]
case1:; login
    call login
jmp far ptr obfs_56
obfs_79 label far
    @log msg_menu_cs_prompt
jmp far ptr obfs_80
obfs_83 label far
    @logln msg_menu_hr
jmp far ptr obfs_84
obfs_82 label far
    @breakline
jmp far ptr obfs_83
obfs_60 label far
case3:; order
    @cls
jmp far ptr obfs_61
obfs_86 label far
exit:
    cmp cs:int_installed, 1
    jne ex
jmp far ptr obfs_87
obfs_61 label far
    call order
jmp far ptr obfs_62
obfs_6 label far
    db 'fight for freedom, stand with CR.'
jmp far ptr obfs_7
obfs_63 label far
case4:;recommend
    mov cx, [goods_types]
jmp far ptr obfs_64
obfs_24 label far
    @log state_username
jmp far ptr obfs_25
obfs_18 label far
    jmp another_stack
jmp far ptr obfs_19
obfs_1 label far
    xor ax, ax
jmp far ptr obfs_2
obfs_13 label far
    jmp bx
jmp far ptr obfs_14
obfs_43 label far
    @putchar 0dh
jmp far ptr obfs_44
obfs_21 label far
    @log msg_menu_current_user
jmp far ptr obfs_22
obfs_23 label far
    jz m
jmp far ptr obfs_24
obfs_15 label far
    jne exit
jmp far ptr obfs_16
obfs_29 label far
    mov di, state_select_good
jmp far ptr obfs_30
obfs_34 label far
    @logln msg_menu_query_good; case2
jmp far ptr obfs_35
obfs_87 label far
    call far ptr rm_int
jmp far ptr obfs_88
obfs_64 label far
    dec cx
jmp far ptr obfs_65
obfs_28 label far
    jz n
jmp far ptr obfs_29
obfs_51 label far
    ;
jmp far ptr obfs_52
obfs_46 label far
    sub al,30h; convert ascii to real nu(cost/real_price+sv/(2*wv))*128mber
jmp far ptr obfs_47
obfs_9 label far
    push menu_var
jmp far ptr obfs_10
obfs_26 label far
    @log msg_menu_current_good
jmp far ptr obfs_27
obfs_40 label far
    @logln msg_menu_cs; case8
jmp far ptr obfs_41
obfs_35 label far
    @logln msg_menu_order; case3
jmp far ptr obfs_36
obfs_30 label far
    @log goods[di].gname
jmp far ptr obfs_31
obfs_70 label far
case5:
    jmp menu
jmp far ptr obfs_71
obfs_36 label far
    @logln msg_menu_recommend; case4
jmp far ptr obfs_37

code ends
end start