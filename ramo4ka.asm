.model tiny
.code
org 100h

VIDEOMEM_START equ 0b800h

START_H equ 10
END_H equ 20

START_L equ 10
END_L equ 70

WORD_START_LINE equ 14
WORD_START_COL equ 20

BG_COLOR equ 40h
FONT_COLOR equ 2h

VERTICAL_STICK equ 0bah
HORIZONTAL_STICK equ 0cdh
RU_CORNER equ 0bbh
LU_CORNER equ 0c9h
RD_CORNER equ 0bch
LD_CORNER equ 0c8h

MAIN_COLOR equ 1fh
INSIDE_COLOR equ 1100h
TIMER_VAL equ 15000d
SHADOW_COLOR equ 07700h

start: 			;dh - ruy dl - rux, bh - ylen, bl - xlen
		mov	bx, VIDEOMEM_START
		mov es, bx
		
		mov ah, 09h
		
		mov dx, offset ask_len
		int 21h
		call scanf 
		mov bl, dl
		
		mov dx, offset ask_hei
		int 21h
		call scanf 
		mov bh, dl
		
		mov dx, offset ask_y
		int 21h
		call scanf 
		mov ch, dl
		
		mov dx, offset ask_x
		int 21h
		call scanf 
	                
		mov bh, dl
		mov dl, ch
		mov dh, bh
		
		call clear_screen
		
		xor ch, ch
		mov cl, bl
		mov bl, 0
		call get_position
		
	animation:
		inc bl
		call put_frame
		mov ah, 86h
		push cx
		push dx
		
		mov cx, 0
		mov dx, TIMER_VAL
		int 15h
		
		pop dx
		pop cx
		loop animation
		
		
	mov ax, offset text
	call put_text_into_center
		
		
		
	mov ax, 4c00h
	int 21h
	
	
	
	
;------------------------------------------
;Puts text into center of frame.
;Parameters: 
;	dl - starting line of frame
;	dh - starting pillar of frame
;	bl - frame length
;	dl - frame heigth
;	ax - offset of text
;Returns: no
;Destroyed: no
;------------------------------------------	
put_text_into_center:
		push bx
		push cx
		push dx
		
		shr bl, 1
		shr bh, 1
		
		add dl, bl
		add dh, bh
		
		;push bx
		mov bx, ax
		
		call strlen
		
		;pop bx
		shr cx, 1
		sub dl, cl
		
		call get_position
		
		call print_word
		
		pop dx
		pop cx
		pop bx
		
		ret
	
	
	
;------------------------------------------
;Puts frame.
;Parameters: 
;	dl - starting line of frame
;	dh - starting pillar of frame
;	bl - frame length
;	dl - frame heigth
;Returns: no
;Destroyed: no
;------------------------------------------	
put_frame:
		push ax
		push bx
		push cx
		push dx

		
		call get_position
		xor ch, ch
		mov cl, bh
		
		
		mov ax, MAIN_COLOR shl 8 + VERTICAL_STICK
		call put_vertical_line
		
		
		inc bl
		call get_position
		mov ax, MAIN_COLOR shl 8 + LU_CORNER
		stosw
		
		
		dec bl		
		mov cl, bl
		mov al, HORIZONTAL_STICK
		call put_horizontal_line

		
		mov ax, MAIN_COLOR shl 8 + RU_CORNER
		sub di, 2
		stosw

		
		
		mov ax, INSIDE_COLOR
		inc dh
		inc dl
		mov cl, bh
		dec bh
		call put_rectangle
		
		
		mov ah, MAIN_COLOR
		xor ch, ch
		mov cl, bh
		dec dh
		dec dl
		call get_position
		mov ax, MAIN_COLOR shl 8 + LD_CORNER
		stosw
		
		
		mov al, HORIZONTAL_STICK
		dec bl
		mov cl, bl
		call put_horizontal_line
		
		
		mov ax, MAIN_COLOR shl 8 + VERTICAL_STICK
		sub dh, bh
		add dl, bl
		inc dh
		inc dl
		call get_position
		mov cl, bh
		dec cl
		call put_vertical_line
		
		
		mov ax, MAIN_COLOR shl 8 + RD_CORNER
		stosw
		
	
		pop dx
		pop cx
		pop bx
		pop ax
		
		ret
	
	
	
;------------------------------------------
;Clears screen.
;Parameters: no
;Returns: no
;Destroyed: no
;------------------------------------------	
clear_screen:
		push dx
		push bx
		push ax
		
		mov dx, 0h
		mov bl, 80d
		mov bh, 25d
		mov ax, 011h
		
		call put_rectangle
		
		pop ax
		pop bx
		pop dx
		ret
		
		
		
;------------------------------------------
;Prints text in videomemory.
;Parameters: 
;	bx - offset of text
;	di - videoseg position
;	es - offset for videoseg
;Returns: no
;Destroyed: no
;------------------------------------------	
print_word:
		push ax
		push bx
		push cx
		
		call strlen
		mov ah, 1fh
kek:	mov al, [bx]
		stosw
		inc bx
		loop kek
		
		pop cx
		pop bx
		pop ax
		ret
		
		
		
		
;-----------------------------------------
;Puts rectangle with current parameters:
;	dh - starting line
;	dl - starting pillarillar
;	bh - heigth
;	bl - length
;	ah color
;	al character
;	di - videoseg position
;	es - offset for videoseg
;Returns: no
;Destroyed: no
;-----------------------------------------
put_rectangle:
		push bx
		push cx
		
		mov cl, bl
		mov ch, 0h
		
		add bh, dh
				
		rep_line:
			
			call get_position
			call put_horizontal_line
			
			inc dh
			cmp dh, bh
			
			jne rep_line
		
		pop cx
		pop bx
		ret
		


;------------------------------------------
;Puts horizontal line.
;Parameters:
;	di - videoseg position
;	es - offset for videoseg
; 	ax - char to print with colors
;Returns: no
;Destroys: no
;------------------------------------------
put_horizontal_line:
		push cx
		rep stosw
		pop cx
		ret


;------------------------------------------
;Puts vertical line.
;Parameters:
;	di - videoseg position
;	es - offset for videoseg
; 	ax - char to print with colors
;Returns: no
;Destroys: no
;------------------------------------------
put_vertical_line:
		push cx

vert:	stosw
		add di, 158
		dec cx
		cmp cx, 0
		jne vert
		
		pop cx
		ret
		
		
		
;------------------------------------------
;Makes di value correct for this parameters:
;Parameters:
;	dh - pillar
;	dl - line
;Returns: di = 2 * (dh * 80 + dl)
;Destroys: no
;------------------------------------------

get_position:

		push ax
		push dx
		
		mov al, 80
		mul dh
		xor dh, dh
		add ax, dx
		shl ax, 1
		mov di, ax
        
		pop dx
		pop ax
		
		ret



;------------------------------------------
;Scans integer from console
;Parameters: no
;Returns: dx - scanned integer
;Destroys: dx
;------------------------------------------	
scanf:
	push cx
	push bx
	push ax
	
	mov dx, 0h
	mov cx, 0h

	scanf_loop:
		mov ah, 01h
		int 21h
		mov ah, 0h
		
		cmp al, 0dh
		je scanf_pop
		
		cmp al, '9'
		ja print_err
		cmp al, '0'
		jb print_err
		
		sub al, '0'
		push ax
		inc ch
	jmp scanf_loop
	
	scanf_pop:
		cmp ch, 0h
		je scanf_ext
		pop ax
		push cx
		
		power:
			cmp cl, 0h
			je power_end

			shl ax, 1
			mov bx, ax
			shl ax, 2
			add bx, ax
			mov ax, bx

			dec cl
		jmp power
		
		power_end:
			pop cx
			add dx, ax
			inc cl
			dec ch
			jmp scanf_pop

	scanf_ext:
	
		pop ax
		pop bx
		pop cx
		ret
	


;------------------------------------------
;Prints scanf error with wrong input and closes the program.
;Parameters: dl - wrong character
;Destroyed: all program
;------------------------------------------	
print_err:
	mov dx, offset err_msg
	mov ah, 09h
	int 21h
	
	mov ah, 02h
	mov dl, al
	int 21h
	
	
	mov ax, 4c00h
	int 21h



;------------------------------------------
;Counts length of string
;Parameters:
;	bx - offset of string
;Returns:
;	cx - length of string
;Destroyed: cx
;------------------------------------------	
strlen:
		mov cx, 0
		push bx
	
		looop:
			cmp byte ptr [bx], '$'
			je strlen_end
			inc bx
			inc cx
			jmp looop

		strlen_end:
			pop bx
			ret


;.data
ask_len db 'Push rectangle length: $'
ask_hei db 'Push rectangle heigth: $'
ask_y db 'Push start y coordinate: $'
ask_x db 'Push start x coordinate: $'

err_msg: db 0ah, 'Error: unknown symbol: $'

text:   db 'XTO YA?$'

	
end start