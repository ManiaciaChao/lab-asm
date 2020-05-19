name lib
public dump,strcmp
.386

retsize EQU 4

lib segment use16

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

lib ends
end

