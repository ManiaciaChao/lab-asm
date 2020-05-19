public 
.model small
.386
.stack
.data 
    res db 0h
.code
.startup
start:
; If the parameter in ebp + 8 is a lowercase character,
; convert it to uppercase by subtracting 20h from it
; otherwise return it as-is
to_uppercase:
    push    ebp
    mov     ebp, esp
    mov     eax, DWORD PTR[ebp + 8h]
    mov     BYTE PTR[ebp + 8h], al
    cmp     BYTE PTR[ebp + 8h], 60h
    jle     _copy_and_return
    cmp     BYTE PTR[ebp + 8h], 7ah
    jg      _copy_and_return
    movzx   eax, BYTE PTR[ebp + 8h]
    sub     eax, 20h
    jmp     _no_modification
_copy_and_return:
    movzx   eax, BYTE PTR[ebp + 8h]
_no_modification:
    mov     esp, ebp
    pop     ebp
    ret

is_uppercase:
    push    ebp
    mov     ebp, esp
    mov     eax, DWORD PTR[ebp + 8h]
    mov     BYTE PTR[ebp + 8h], al
    cmp     BYTE PTR[ebp + 8h], 40h
    jle     _not_uppercase
    cmp     BYTE PTR[ebp + 8h], 5ah
    jg      _not_uppercase
    mov     eax, 1
    jmp     _done
_not_uppercase:
    xor     eax, eax
_done:    
    mov     esp, ebp
    pop     ebp
    ret

; [ebp + 8h]     input
; [ebp + 0xc]     key
; [ebp + 0x10]    output
vigenere_encrypt:
    push    ebp
    mov     ebp, esp
; Return if any of the parameters is null
    cmp     DWORD PTR[ebp + 8h], 0
    je      _end
    cmp     DWORD PTR[ebp + 0ch], 0
    je      _end
    cmp     DWORD PTR[ebp + 10h], 0
    je      _end
    mov     edx, DWORD PTR[ebp + 8h]   ; Move the first param to EDX
    mov     eax, DWORD PTR[ebp + 0ch]   ; Move the second param to EAX
    xor     edi, edi                    ; i = 0
_loop:
; Stop at \0 null terminator character
    cmp     BYTE PTR[edx + edi], 0   ; while(input[i] != 0) ...
    je      _end
; [edx + edi]  =   input[i]
; [eax + edi]  =   key[i]
;  edi         =   i
    push    eax                         ; EAX stores the pointer to char* key
    push    ebx                         ; Pushing this would save us from segfaulting
    push    edx                         ; EDX stores the pointer to char* input
    movzx   edx, BYTE PTR[edx + edi]    ; Move the current character of input[i] to EDX
    movzx   ebx, BYTE PTR[eax + edi]    ; Move the current character of key[i] to EBX
    push    edx
    call    is_uppercase
    mov     BYTE PTR[res], al           ; save the result of is_uppercase to res
    add     esp, 4h
    push    edx
    call    to_uppercase
    add     esp, 4h
    mov     edx, eax                    ; edx = to_uppercase(edx)
    push    ebx
    call    to_uppercase
    add     esp, 4h
    mov     ebx, eax                    ; ebx = to_uppercase(ebx)
    add     bl, dl                      ; bl = input[i] + key[i]
    xor     edx, edx
    mov     eax, ebx
    mov     ebx, 1ah                   ; divisor = 26
    div     ebx                         ; edx = bl % 26
    test    BYTE PTR[res], 0
    jz      _lostr                      ; ZF = 1 if input[i] was lowercase
    add     edx, 41h                   ; input was not uppercase => convert it to lowercase
    jmp     _skip
_lostr:
    add     edx, 61h
_skip:      
    mov     ecx, [ebp + 10h]           ; acquire a pointer to char* output
    mov     DWORD PTR[ecx + edi], edx   ; output[i] = edx
    pop     edx                         ; Restore pointer char* input
    pop     ebx                         ; Leaving EBX dirty will segfault
    pop     eax                         ; Restore pointer char* key
    inc     edi                         ; i++
    jmp     _loop
_end:
    xor     eax, eax                    ; Return value is always 0
    mov     esp, ebp
    pop     ebp
    ret
end start