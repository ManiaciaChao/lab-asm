.386
.model flat, stdcall
menu proto c

.stack
.code

start:

    
    call menu

exit:
    mov ah,4ch
    int 21h
end start
end