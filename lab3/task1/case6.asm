name case6
extrn state_edit_meta:word
public mutate
.386
include m.asm

case segment use16

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

; read state_edit_buf, change bx
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

case ends
end
