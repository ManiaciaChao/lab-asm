extrn mutate:far
@mutate macro property,n, unitsize
    lea si, property
    mov ax, unitsize
    @dump property, n, unitsize
    @putchar '<'
    call far ptr mutate
    @breakline
endm
