.386
.model flat, c

public login
public query
public order
public goods
public status
public calc_rec_all

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
    c_in_asm dd 10
  ; configuration
  config_username db 'chenyang',0
  config_password db 'password',0
  ; state
  state_auth db 0
  state_select_good dw -1
	state_username db 16 dup(0)
	state_password db 16 dup(0)
    state_goodname db 10 dup(0)
  state_cs dw ?
  state_edit_meta db 2 dup(0)
  state_edit_buf db 16 dup(0)
  ; model
  goods Good <'PEN',3,56,70,10,0,0>, <'BOOK',7,30,25,12,0,0>
  goods_types dw 2;
  ; message for menu
  msg_menu_hr db '--------------------------------',0
  msg_menu_state_prompt db 'State:',0
  msg_menu_current_user db '  current user: ',0
  msg_menu_current_good db '  current good: ',0
  msg_menu_prompt db 'Options[1-9]: ',0
  msg_menu_login db '  1. login/re-login',0
  msg_menu_query_good db '  2. query good',0
  msg_menu_order db '  3. order',0
  msg_menu_recommend db '  4. calculate recommend index',0
  msg_menu_rank db '  5. rank',0
  msg_menu_modify_good db '  6. modify good',0
  msg_menu_transfer db '  7. transfer',0
  msg_menu_cs db '  8. current cs',0
  msg_menu_exit db '  9. exit',0
  ; message for login
  msg_login_username db 'username: ',0
  msg_login_password db 'password: ',0
  msg_login_resolved db 'login successfully',0
  msg_login_rejected db 'bad login',0
  ; message for query
  msg_query_name db 'name of good: ',0
  msg_query_err_not_found db 'no such good'
  msg_query_info_gname db 'name of good: ',0
  msg_query_info_cost db 'cost of good: ',0
  msg_query_info_price db 'price of good: ',0
  msg_query_info_discount db 'discount of good: ',0
  msg_query_info_wv db 'wv of good: ',0
  msg_query_info_sv db 'sv of good: ',0
  msg_query_info_rec db 'recommend index: ',0
  ; message for order
  msg_order_done db 'order successfully',0
  msg_order_err_stock db 'error: out of stock',0
  msg_order_err_empty db 'error: cart is empty',0
  ; message for csip
  msg_menu_cs_prompt db 'cs:',0
  format_str db '%s',0
.code


printf proto C, format:dword, content:dword
gets_s proto c, buffer:dword, rsize_t:dword
strcmp proto c, str1:dword, str2:dword
log proto C, s:dword
log_int proto C, v:dword
log_short proto C, v:word
log_char proto C, v:byte
breakline proto C
cls proto C

@log macro str
    push eax
    lea eax, str
	invoke printf, offset format_str, eax
    pop eax
endm

@logln macro str
	@log str
    invoke breakline
endm

@strcmp macro str1:req, str2: req
    push ebx
    lea eax, str1
    lea ebx, str2
	invoke strcmp, eax, ebx
    pop ebx
endm

; optimized
calc_rec_o proc
  pusha
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
  popa
  ret
calc_rec_o endp

login proc
    pusha
    ; get input
    @log msg_login_username
    invoke gets_s, offset state_username, 16
    @log msg_login_password
    invoke gets_s, offset state_password, 16
    invoke cls
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
    popa
    ret
  login_rej:
    mov byte ptr[state_auth], 0
    @logln msg_login_rejected
    popa
    ret
login endp

query proc
    pusha
    mov cx, [goods_types]
    xor edi, edi 
    @log msg_query_name
    invoke gets_s, offset state_goodname,10
  query_loop:
    @strcmp state_goodname, goods[edi].gname
    cmp ax,0
    jz query_resolved
    add edi, type Good
    loop query_loop
    popa
    ret
  query_resolved:
    mov word ptr[state_select_good], di
    call info
    popa
    ret
query endp

info proc
    pusha
    movzx edi, state_select_good
    ; @dump goods[di].gname, 1, 2
    ; invoke breakline
    @log msg_query_info_discount
    invoke log_char, goods[edi].discount
    invoke breakline
    ; @log msg_query_info_cost
    ; @dump goods[di].cost, 1, 2
    ; invoke breakline
    @log msg_query_info_price
    invoke log_short, goods[edi].price
    invoke breakline
    @log msg_query_info_wv
    invoke log_short, goods[edi].wv
    invoke breakline
    @log msg_query_info_sv
    invoke log_short, goods[edi].sv
    invoke breakline
    @log msg_query_info_rec
    invoke log_short, goods[edi].rec
    invoke breakline
    @logln msg_menu_hr
    popa
    ret
info endp

order proc
    pusha
    cmp state_select_good, -1
    jz order_rejected_emtpy
    movzx edi, state_select_good
    mov cx, goods[edi].wv
    sub cx, goods[edi].sv
    jle order_rejected_stock
    add word ptr goods[edi].sv,1
    @logln msg_order_done
    @logln msg_menu_hr
    call calc_rec_all
    popa
    ret
  order_rejected_stock:
    @logln msg_order_err_stock
    @logln msg_menu_hr
    popa
    ret
  order_rejected_emtpy:
    @logln msg_order_err_empty
    @logln msg_menu_hr
    popa
    ret
order endp

modify proc
    ret
modify endp

status proc
    pusha
    ; display menu
    @logln msg_menu_state_prompt
    @log msg_menu_current_user
    cmp state_auth, 0
    jz m
    @log state_username
  m:
    invoke breakline
    @log msg_menu_current_good
    cmp state_select_good, -1
    jz n
    movzx edi, state_select_good
    @log goods[edi].gname
  n:
    invoke breakline
    popa
    ret
status endp

calc_rec_all proc
    pusha
    movzx ecx, [goods_types]
    dec ecx
    xor di, di
  recommend_all_loop:
    call calc_rec_o
    add di, type Good
    loop recommend_all_loop
    popa
    ret
calc_rec_all endp

end
