.model small
.stack 100h
.data                                                  
    start_msg db 10, 13, "Enter digit: ", 10, 13, '$'        
    end_msg db 10, 13, "Count of digits in interval: ", 10, 13, '$'
    enter_lower_border_msg db 10, 13, "Eneter lower border: ", 10, 13, '$'
    enter_upper_border_msg db 10, 13, "Eneter upper border: ", 10, 13, '$'
    array dw ARRAY_SIZE dup(?)
    digit db 8
          db ?
          db 8 dup(?)      
    max_count_digit_symbol db 7 dup('0')
    digit_symb_limit equ 5     
    ARRAY_SIZE equ 5
    LOWER_BORDER equ 10
    UPPER_BORDER equ 2
    
.code         
    get_digit proc
        pusha
        cld   
        print_start_msg:
            mov dx, offset start_msg
            mov ah, 09h
            int 21h
        get_dgt:           
            mov dx, offset digit   
            mov ah, 0ah
            int 21h
        check_for_dgt:
            mov di, offset digit + 2 
            xor cx, cx
            mov cl, byte ptr[digit + 1]
            xor ax, ax
            jmp check_for_negative
            check_for_negative:   
                mov al, '-'
                xor bx, bx
                mov bl, byte ptr[di]
                cmp al, bl
                je is_negative               
                cmp cx, digit_symb_limit
                ja _exit            ;edit
                jmp start_check                  
            is_negative:
                inc di
                dec cx
                cmp cx, digit_symb_limit
                ja _exit
                jmp start_check   
            start_check:
                xor bx, bx
                mov bl, byte ptr[di]        
                mov al, '0'
                cmp al, bl
                ja _exit    ; edit
                mov al, '9'
                cmp al, bl
                jb _exit
                inc di
                loop start_check                 
        popa
        ret
    get_digit endp   
    
    get_low_border proc
        lower_print_msg:
            mov dx, offset enter_lower_border_msg
            mov ah, 09h
            int 21h
        call get_digit    
        call atoi_borders
                xor dx, dx               
                xor bx, bx                        
        ret              
    get_low_border endp
     
         
    get_upper_border proc
        push ax
        xor bx, bx
        upper_print_msg:
            mov dx, offset enter_upper_border_msg
            mov ah, 09h
            int 21h
        call get_digit
        call atoi_borders
        mov bx, ax        
            xor dx, dx 
            xor ax, ax           
        pop ax
        ret
    get_upper_border endp        
     
    atoi_borders proc       
            mov di, offset digit + 2
            push di
            xor cx, cx
            xor dx, dx
            xor ax, ax
            xor bx, bx
            mov cl, byte ptr[digit + 1]
            jmp check_minus_borders
            check_minus_borders:
                mov al, '-'
                cmp al, byte ptr[di]
                je skip_minus_borders
                xor ax, ax
                jmp converting_borders           
            skip_minus_borders:
                inc di
                dec cx
                xor ax, ax              
            converting_borders:
                mov bl, 10
                mul bx 
                mov bl, byte ptr [di]
                sub bl, '0'
                add ax, bx
                inc di
                loop converting_borders
            pop di
            check_negative_borders:
                xor bx, bx
                mov bl, '-'
                cmp bl, byte ptr[di]               
                je make_negative_borders
                jmp make_digit_borders 
            make_negative_borders:
                neg ax
                jmp make_digit_borders
            make_digit_borders:
        ret 
    atoi_borders endp       
         
    atoi proc
        pop bp
        pop si
        push bp
        pusha
        convert_to_int:
            mov di, offset digit + 2
            push di
            xor cx, cx
            xor dx, dx
            xor ax, ax
            xor bx, bx
            mov cl, byte ptr[digit + 1]
            jmp check_minus
            check_minus:
                mov al, '-'
                cmp al, byte ptr[di]
                je skip_minus
                xor ax, ax
                jmp converting           
            skip_minus:
                inc di
                dec cx
                xor ax, ax              
            converting:
                mov bl, 10
                mul bx 
                mov bl, byte ptr [di]
                sub bl, '0'
                add ax, bx
                inc di
                loop converting
            pop di
            check_negative:
                xor bx, bx
                mov bl, '-'
                cmp bl, byte ptr[di]               
                je make_negative
                jmp make_digit 
            make_negative:
                neg ax
                jmp make_digit                      
            make_digit:
                mov word ptr[si], ax  
        popa
        ret
    atoi endp            
    
    get_count_of_digits proc                
        xor cx, cx
        xor di, di
        xor si, si
        xor dx, dx       
        add dx, 0
        mov di, offset array
        mov cx, ARRAY_SIZE
        find_digits:           
            check_lower_border:                
                cmp ax, word ptr[di]         
                jl check_upper_border                
                jmp decrement_index                 
            check_upper_border:
                cmp bx, word ptr[di]
                jg increment_counter
            decrement_index:                                                       
                add di, 2
        loop find_digits
        jmp end_of_proc
        
        increment_counter: 
            inc dx
            add di, 2
            loop find_digits                                                   
        end_of_proc:       
        ret  
    get_count_of_digits endp                
    
    itoa proc
        pusha
         xor di, di
         xor si, si
         mov si, dx
         mov di, offset max_count_digit_symbol
         mov [di+6], '$'
         add di, 5        
         xor bx, bx
         mov ax, si
         _outer_loop_:
            mov bx, 10
            xor dx, dx
            div bx
            add dl, '0'
            mov [di], dl
            dec di
            cmp ax, 0
            je _end_outer_loop_
            jmp _outer_loop_
        
        _end_outer_loop_:
        _set_plus_:
            mov byte ptr[di], '+'
            jmp _ret_itoa
        _ret_itoa:       
        popa
        ret
    itoa endp
          
    print_number_of_digits proc  
        xor ah, ah
        xor dx, dx 
        mov dx, offset end_msg
        mov ah, 09h
        int 21h
        mov dx, offset max_count_digit_symbol
        mov ah, 09h
        int 21h         
        ret 
    print_number_of_digits endp          
                   
 _start:
    mov ax, @data
    mov ds, ax
    mov es, ax                                 
    call get_low_border     ; ax
    call get_upper_border   ; bx
    mov di, offset max_count_digit_symbol
    mov [di+6], '$'           
    xor dx, dx
    xor cx, cx
    mov dx, offset array
    mov cx, ARRAY_SIZE   
    initializate_array:
        call get_digit
        push dx
        call atoi
        add dx, 2
        loop initializate_array                      
    call get_count_of_digits      ; dx
    call itoa
    call print_number_of_digits 
    _exit:                  
 end _start