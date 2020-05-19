count db 18; 18 interuptions in 1 second
origin_int dw ?,?; store offset of original interupt 8h
int_installed db 0; indicate whether new interupt is installed
current_stack db 0; indicate current stack: 0 for stack, 1 for stackbak

;change ss
switch_stack proc far uses ax si
    cmp cs:current_stack, 0
    jne cs1
  cs0:
    mov cs:current_stack, 1
    mov ax, stackbak
    jmp switch_start
  cs1:
    mov cs:current_stack, 0
    mov ax, stack
  switch_start:
    mov es, ax; assign es to next stack
    mov si, stack_size+1;
  switch_loop:; copy from top to sp
    dec si
    ; copy from ss to es
    mov ah, ss:[si]
    mov es:[si], ah
    cmp si, sp; stop until reach top
    jne switch_loop
  switch_done:
    ; assign ss to next stack
    mov ax, es
    mov ss, ax
    ret
switch_stack endp

; change al, where saves 2 BCD-digit
get_sec proc far
    mov al, 0
    out 70h, al
    jmp $+2
    in al, 71h; now al is two BCD
    ret
get_sec endp 

new08h proc far
    pushf
    call dword ptr cs:origin_int
    dec cs:count
    jnz int_ret
  switch:
    mov cs:count, 18 
    sti
    call far ptr get_sec
    cmp al, 00110000b
    jne int_ret
    pusha
    call far ptr switch_stack
    popa
  int_ret:
    iret
new08h endp

reg_int proc far uses ax bx dx ds es
    push cs; ds cs
    pop ds; ds
    mov ax, 3508h
    int 21h
    mov origin_int, bx
    mov origin_int+2,es
    mov dx, offset new08h
    mov ax, 2508h
    int 21h
    mov int_installed, 1
    ret
reg_int endp

rm_int proc far uses ax dx
    lds dx, dword ptr cs:origin_int
    mov ax, 2508h
    int 21h
    ret
rm_int endp

init_int proc far
    cmp cs:int_installed, 1
    je c7
    call far ptr reg_int
    c7:; already installed
    ret
init_int endp

; optimized
calc_rec_o proc far
    ; push ax
    ; push bx
    ; push cx
    ; push dx
    mov ax, goods[di].cost
    xor ax, key
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

login proc far
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
    call get_sec;
    push ax
  start_xor:
    lea si, config_username
    lea di, state_password
  xor_pw:
    mov bh, byte ptr [si]
    mov bl, byte ptr [di]
    xor bh, bl
    mov [di], bh
    inc si
    inc di
    mov bl, [si]
    cmp bl, '$'
    je cmp_pw
    jmp xor_pw
  cmp_pw:
    pop ax
    mov ah,al

    call get_sec;
    sub ah,al
    cmp ah, 2
    je login_rej

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

query proc far
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

info proc far
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

order proc far
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

modify proc far
    cmp state_auth, 0
    jz menu
    cmp state_select_good, -1
    jz menu
  ; 折扣，进货价，销售价，进货总数
    mov di, state_select_good

    @log msg_query_info_discount
    @mutate goods[di].discount, 1,1
    @log msg_query_info_cost
    @mutate_xor goods[di].cost, 1,2
    @log msg_query_info_price
    @mutate goods[di].price, 1,2
    @log msg_query_info_wv
    @mutate goods[di].wv,1, 2
    ret
modify endp

; read state_edit_buf, change ax
vaild_num proc far uses ax cx si di
    lea di, state_edit_meta+1
    movzx cx, byte ptr [di];size
    cmp cx, 0
    je blank
    xor si,si; si=0
    xor ax,ax
    xor bx,bx
  vl1:
    lea di, state_edit_meta+1
    add di, cx
    mov al, [di];
    cmp al,'0'
    jb err
    cmp al,'9'
    ja err
    sub al, '0'; now ax=digit
  vl2:
    cmp si, 0
    je vl4 ; skip
    push cx
    pop cx
  vl4: ; isDigit
    add bx, ax
    inc si
    loop vl1
    mov ax, 1
    ret
  blank:
    mov bx, -2
    ret
  err: ; NaN
    mov bx, -1
    ret
vaild_num endp

mutate proc far
  m_start:
    @gets state_edit_meta,16,'$'
    call far ptr vaild_num; bx
    cmp bx, -2 
    je m_exit
    cmp bx, -1 
    @breakline
    je m_start
    mov [si], bx
  m_exit:
    ret
mutate endp

mutate_xor proc far
  mx_start:
    @gets state_edit_meta,16,'$'
    call far ptr vaild_num; bx
    cmp bx, -2 
    je m_exit
    cmp bx, -1 
    @breakline
    je m_start
    xor bx, key
    mov [si], bx
  mx_exit:
    ret
mutate_xor endp