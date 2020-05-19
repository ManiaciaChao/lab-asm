extrn strcmp:far
extrn dump:far

@exit macro
    mov ah,4ch
    int 21h
endm

@cls macro
	push ax
	mov ax,03h
	int 10h
	pop ax
endm

;Read the character from keyboard
;Mutate AL 
@getchar macro
	mov ah, 01h
	int 21h
endm


;Gets a string from the keyboard
;Change si, bx
;length into bx and data into si
@gets macro ofset:req, limit:req, termin:req
	push ax
	push dx
	push si
	lea dx, ofset
	mov ah, 0ah
	mov si, dx
	mov byte ptr[si], limit
	int 21h
	inc si
	mov bl, [si]
	sub bh, bh
	inc si
	mov byte ptr[bx+si], termin
	pop si
	pop dx
	pop ax
endm

;Display a character to screen
@putchar macro char
	push ax
	push dx
	mov dl, char
	mov ah, 02h
	int 21h
	pop dx
  pop ax
endm

@breakline macro
	@putchar 0ah
	@putchar 0dh
endm

@log macro str
	lea dx, str
	mov ah, 9
	int 21h
endm

@logln macro str
	@log str
	@breakline
endm

@strcmp macro str1:req, str2: req
	lea ax, str1
	push ax
	lea ax, str2
	push ax
	call far ptr strcmp
	add sp, 4
endm

@dump macro addr, n, unitsize
		push si
    lea si, addr
    mov cx, n
    mov bx, unitsize
    call far ptr dump
		pop si
endm


