.386
time segment use16
public timer
timer	proc far
	push  dx
	push  cx
	push  bx
	mov   bx, ax
	mov   ah, 2ch
	int   21h	     ;ch=hour(0-23),cl=minute(0-59),dh=second(0-59),dl=centisecond(0-100)
	mov   al, dh
	mov   ah, 0
	imul  ax,ax,1000
	mov   dh, 0
	imul  dx,dx,10
	add   ax, dx
	cmp   bx, 0
	jnz   _t1
	mov   cs:_ts, ax
_t0:	pop   bx
	pop   cx
	pop   dx
	ret
_t1:	sub   ax, cs:_ts
	jnc   _t2
	add   ax, 60000
_t2:	mov   cx, 0
	mov   bx, 10
_t3:	mov   dx, 0
	div   bx
	push  dx
	inc   cx
	cmp   ax, 0
	jnz   _t3
	mov   bx, 0
_t4:	pop   ax
	add   al, '0'
	mov   cs:_tmsg[bx], al
	inc   bx
	loop  _t4
	push  ds
	mov   cs:_tmsg[bx+0], 0ah
	mov   cs:_tmsg[bx+1], 0dh
	mov   cs:_tmsg[bx+2], '$'
	lea   dx, _ts+2
	push  cs
	pop   ds
	mov   ah, 9
	int   21h
	pop   ds
	jmp   _t0
_ts	dw    ?
 	db    'time elapsed in ms is '
_tmsg	db    12 dup(0)
timer   endp

time ends
end
