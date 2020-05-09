.model small
.data
snake dw 0302h
		dw 0303h
		dw 0304h
		dw 0305h
		dw 0306h
		dw 7CCh dup('?')
MOVING_UP equ 0FF00h
MOVING_DOWN equ 0100h 
MOVING_RIGHT equ 0001h
MOVING_LEFT equ 0FFFFh
up_boder_sign db 0C4h
count dw 00h
count_digit db 7 dup('0') 
.stack 100h


.code 
delay proc
    push cx
	mov ah, 0
	int 1Ah 
	add dx, 3
	mov bx, dx
repeat:   
	int 1Ah
	cmp dx, bx
	jl repeat
	pop cx
	ret   
delay endp  

key_press proc         
    is_key_not_pressed:
        mov ax, 0100h ; check for keyboard buffer
	    int 16h
	    jz end_of_key_press        
	xor ah, ah
	end_game:
	    int 16h	
	    cmp ah, 01h
	    jne move_down
	    jmp end_of_game    
	move_down:    
	    cmp ah, 50h
	    jne move_up
	    cmp cx, MOVING_UP   ; move to itself
	    je  end_of_key_press
	    mov cx, MOVING_DOWN
	    jmp end_of_key_press 
	move_up:
	    cmp ah, 48h
	    jne move_left
	    cmp cx, MOVING_DOWN
	    je end_of_key_press
	    mov cx, MOVING_UP
	    jmp end_of_key_press   
	move_left:
	    cmp ah, 4Bh
	    jne move_right
	    cmp cx, MOVING_RIGHT
	    je end_of_key_press
	    mov cx, MOVING_LEFT
	    jmp end_of_key_press   
	move_right:
	    cmp cx, MOVING_LEFT
	    je end_of_key_press
	    mov cx, MOVING_RIGHT         
	end_of_key_press:    
	    ret
key_press endp       
    
spawn_food proc
    push cx   
    mov ah, 0
	int 1Ah 
	mov bl, dl
	mov cx, 01h 
    check_for_random_number:
        inc bl
        cmp bx, 1
        jg continue_chaeck               
        inc bx                
        jmp check_for_random_number
        continue_chaeck:
	    cmp bx, 78       
	    jng write_coordinates
	    shr bl, 1     
	    jmp check_for_random_number
	write_coordinates:
	    mov dl, bl
	check_for_random_number2:
	    cmp bx, 13h
	    jg div_bx   
	    cmp bx, 3h
	    jl inc_bx        
	    jmp write_coordinates2
	    div_bx:
	        shr bl, 2
	        jmp check_for_random_number2    
	    inc_bx:
	        inc bl
	        jmp check_for_random_number2    
	write_coordinates2:
	    mov dh, bl        
	    mov ax, 0200h
	    int 10h
	    mov ax, 0800h
	    int 10h
	    cmp al, 2Ah       
	    je check_for_random_number
	    mov ax, 090Ch
	    mov bl, 0Ch
	    int 10h
	    pop cx
	    ret
spawn_food endp
 
chech_for_game_over proc  
    cmp al, 0C4h
    je move_around_vertical
    cmp al, 0B2h
    je move_around_horizontal   
    cmp al, 02Ah
    je game_over
       
	jmp continue		
	move_around_vertical:
	    cmp dh, 01h
	    je upper_border
	    lower_borde:
	        mov dh, 02h
	        jmp move_cursor        
	    upper_border:
	        mov dh, 20
	        jmp move_cursor           
	move_around_horizontal:
	    cmp dl, 00h
	    je left_border
	    right_border:
	        mov dl, 01h
	        jmp move_cursor     
	    left_border:
	        mov dl, 78
	        jmp move_cursor       
	move_cursor:
	    push ax
	    mov ah, 02h
	    int 10h    
	    pop ax        
	    jmp continue              
	game_over:
	    mov ax, 4c00h
        int 21h                   
    continue: 
        mov [snake+si], dx
        ret    
chech_for_game_over endp     

itoa proc
    pusha 
    mov di, offset count_digit
    mov [di+6], '$'
    add di, 5        
    xor bx, bx
    mov ax, word ptr [count]   
    outer_loop:
        mov bx, 10
        xor dx, dx
        div bx
        add dl, '0'
        mov [di], dl
        dec di
        cmp ax, 0
        je end_outer_loop
        jmp outer_loop   
    end_outer_loop:
        popa
        ret        
itoa endp    

set_count proc
    call itoa
    mov ah, 02h
    mov dh, 00h
    mov dl, 70
    int 10h   
    mov ah, 09h
    mov dx, offset count_digit
    int 21h  
    ret
set_count endp        
    
increment_count proc
    pusha
    mov ax, word ptr[count]
    inc ax
    mov word ptr[count], ax
    call itoa
    mov ah, 02h
    mov dh, 00h
    mov dl, 70
    int 10h   
    mov ah, 09h
    mov dx, offset count_digit
    int 21h    
    popa 
    ret
increment_count endp    

paint_game_area proc    
    mov ah, 02h
    mov dh, 01h
    int 10h
    paint_upper_border:
        mov ax, 09C4h        
        mov bl, 09h
        mov cx, 80  
        int 10h       
    paint_left_border:
        mov ah, 02h
        mov dh, 20
        mov dl, 00h
        int 10h
        mov cx, 20
        paint_left_border_loop:
            push cx
            mov ax, 09B2h
            mov bl, 09h                      
            mov cx, 1
            int 10h
            pop cx 
            mov ah, 02h
            mov dh, cl
            mov dl, 00h
            int 10h
            loop paint_left_border_loop
    paint_right_border:
        mov ah, 02h
        mov dh, 20
        mov dl, 79
        int 10h
        mov cx, 20
        paint_right_border_loop:
            push cx
            mov ax, 09B2h
            mov bl, 09h                      
            mov cx, 1
            int 10h
            pop cx 
            mov ah, 02h
            mov dh, cl
            mov dl, 79
            int 10h
            loop paint_right_border_loop
    paint_lower_border:
        mov ah, 02h
        mov dh, 21
        mov dl, 0
        int 10h
        mov ax, 09C4h        
        mov bl, 09h
        mov cx, 80  
        int 10h                                           
    ret                
paint_game_area endp

start:
    mov ax, @data
    mov ds, ax
    mov es, ax

	mov ax, 0003h
	int	10h
    call paint_game_area 
    call set_count
    
    mov ah, 02h
    mov dx, 0302h
    int 10h
                      
    mov cx, 5              
    mov ah, 09h
    mov bl, 0Ah ; color         
    mov al, 002Ah ; *   
    int 10h               

	mov si, 8    ; head coordinates
	xor di, di			
	mov cx, MOVING_RIGHT
	mov bl, 51h
    call spawn_food     
    game_cycle:
        call delay  
        call key_press
        xor bh, bh
	    mov ax, [snake+si]
	    add ax, cx     
	    add si, 2
	    mov dx, ax			
	    mov ax, 0200h ; move pointer
	    int 10h
	    
	    mov ax, 0800h   ; read symbol in head
	    int 10h    
	    
	    call chech_for_game_over
	    mov dh, al
	        
	    mov ah, 09h
        mov bl, 0Ah ; color  
        push cx
        mov al, 002Ah ; *
        mov cx, 1   ; single char 
        int 10h               
        pop cx   
	    
	    check_for_eating_food:
	      cmp dh, 0Ch   
	      jne remove_tail
	      call increment_count
	      call spawn_food
	      jmp game_cycle
	    remove_tail:
	        mov ax, 0200h 		
	        mov dx, [snake+di]
	        int 10h
	        mov ax, 0200h
	        mov dl, 0020h ; print spase
	        int 21h
	        add di, 2
	        jmp game_cycle
	    end_of_game:    
end start
