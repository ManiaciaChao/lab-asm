.386
stack segment use16 stack
    db 200 dup(0)
stack ends
data segment use16
buf1 db 0,1,2,3,4,5,6,7,8,9
buf2 db 10 dup(0)
buf3 db 10 dup(0)
buf4 db 10 dup(0)
data ends
code segment use16
    assume cs:code,ds:data,ss:stack
start: mov ax,data
    mov ds,ax
    mov esi,offset buf1
    mov edi,offset buf2
    mov ebx,offset buf3
    mov ebp,offset buf4
    mov cx,10
lopa: mov al,[esi]
    mov [edi],al
    inc al
    mov [ebx], al
    add al,3
    mov ds:[ebp],al
    inc esi
    inc edi
    inc ebp
    inc ebx
    dec cx
    jnz lopa
    mov ah,4ch
    int 21h
code ends
end start