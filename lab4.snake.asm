model small
.data
    snake 
        dw 0000h
		dw 0001h
		dw 0002h
		dw 0003h
		dw 0004h
		dw 7CCh dup('?')
    
.stack 100h


.code 
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
