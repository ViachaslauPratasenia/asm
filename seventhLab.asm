.model tiny
.code
.186
org 100h                     
jmp start  

bad_args_message db "Bad command-line arguments. I want only 1 number: N", '$'   
bad_program_path_message db "Bad program path", '$'
input_error_message db 'Incorrect number$'
max_n_error_message db 'You exceeded the maximal N$'     
min_n_error_message db 'You exceeded the minimal N$' 

n_string db max_cmd_size + 2 dup(0)

max_cmd_size equ 127  
buffer db max_cmd_size + 2 dup(0)

cmd_size db ?
cmd_text db max_cmd_size + 2 dup(0) 

space_symbol equ 32
new_line_symbol equ 13
return_symbol equ 10
tabulation equ 9
endl equ 0

n_max_size equ 255  
n_min_size equ 1
n dw 0  
counter dw 0

print_message macro out_message
	push ax
	push dx
	mov ah, 09h
	mov dx, offset out_message
	int 21h
	mov dl, 10
	mov ah, 02h
	int 21h
	mov dl, 13
	mov ah, 02h
	int 21h
	pop dx
	pop ax
endm

strlen proc
	push bx si
	xor ax, ax
start_calculate:
	mov bl, ds:[si] 
	cmp bl, endl
	je end_calculate
	inc si
	inc ax
	jmp start_calculate
end_calculate:
	pop si bx
	ret
endp

is_empty macro line, marker
	push si
	mov si, offset line
	call strlen
	pop si
	cmp ax, 0
	je marker
endm

read_from_cmd proc
	push bx
	push cx
	push dx
	mov cl, cmd_size
	xor ch, ch
	mov si, offset cmd_text
	mov di, offset buffer
	call rewrite_word
	dec si
loop1:
    inc si
    mov al, ds:[si]
    cmp al, 32
    je loop1
    cmp al, 9
    je loop1
next1:
	mov di, offset n_string
	call rewrite_word
	is_empty n_string, bad_args 
	mov di, offset buffer
	call rewrite_word
	is_empty buffer, good_args
bad_args:
	print_message bad_args_message
	mov ax, 1
	jmp end_proc
good_args:
	mov ax, 0
end_proc:
	pop dx
	pop cx
	pop bx
	ret	
endp

rewrite_word proc
	push ax
	push cx
	push di
loop_rewrite:
	mov al, ds:[si]
	cmp al, space_symbol
	je stopped_symbol
	cmp al, new_line_symbol
	je stopped_symbol
	cmp al, tabulation
	je stopped_symbol
	cmp al, return_symbol
	je stopped_symbol
	cmp al, endl
	je stopped_symbol
	mov es:[di], al
	inc di
	inc si
	loop loop_rewrite
stopped_symbol:
	mov al, endl
	mov es:[di], al
	inc si
	pop di
	pop cx
	pop ax
	ret
endp

macro exit_app
   mov ax,4C00h
   int 21h  
endm

atoi proc
    xor ax, ax
    xor cx, cx
    mov bx,10  
until_the_end:
    mov cl,[si]          
    
    cmp cl,0dh  
    jz exit
    
    cmp cl,endl
    jz exit
    
    cmp cl,'0'  
    jb error
    cmp cl,'9'  
    ja error
 
    sub cl,'0' 
    mul bx
    jo error
    jc error    
    add ax, cx
    inc si     
    jmp until_the_end     
error:   
    print_message input_error_message
    exit_app  
exit:
    ret
atoi endp

check_number proc
    pusha
    xor bx, bx
check_start:
    mov cl, [si]
    cmp cl, 0
    je check_exit
    inc si
    inc bx
    jmp check_start
check_exit:
    mov ax, bx
    mov bl, 2
    div bl
    mov ah, 0
    sub si, ax
    mov [si], 0
    popa
    ret
check_number endp 

check_path proc
    pusha
    mov si, offset program_path
while_not_dot:
    cmp ds:[si], '.'
    je end_while_not_dot
    cmp ds:[si], 0
    je bad_path
    inc si
    jmp while_not_dot 
end_while_not_dot:    
    call check_exe
    cmp ax, 1
    je end_check_path_proc 
    call check_com
    cmp ax, 0
    je bad_path
    jmp end_check_path_proc
bad_path:
    print_message bad_program_path_message 
    exit_app
end_check_path_proc: 
    popa
    ret
check_path endp

check_exe proc
    push si
    push ds
    inc si
    cmp ds:[si], 'e'
    jne bad_exe
    inc si
    cmp ds:[si], 'x'
    jne bad_exe
    inc si
    cmp ds:[si], 'e'
    jne bad_exe
    inc si
    cmp ds:[si], 0
    jne bad_exe
    mov ax, 1
    jmp end_check_exe_proc
bad_exe:
    mov ax, 0
end_check_exe_proc: 
    pop ds
    pop si
    ret
check_exe endp

check_com proc
    push si
    push ds
    inc si
    cmp ds:[si], 'c'
    jne bad_com
    inc si
    cmp ds:[si], 'o'
    jne bad_com
    inc si
    cmp ds:[si], 'm'
    jne bad_com
    inc si
    cmp ds:[si], 0
    jne bad_com
    mov ax, 1
    jmp end_check_com_proc
bad_com:
    mov ax, 0
end_check_com_proc: 
    pop ds
    pop si
    ret
check_com endp

start:
    mov ax, @data
	mov es, ax
    pusha
    xor ch, ch
	mov cl, ds:[80h]			
	mov cmd_size, cl 		
	mov si, 81h
	mov di, offset cmd_text
	rep movsb

	mov ds, ax
    call read_from_cmd
	cmp ax, 0
	jne end_main
	popa
    call check_path
	mov si,offset n_string
	call check_number
	call atoi
	mov n, ax
check_min_size:	
	cmp ax, n_min_size
	jae check_max_size
    print_message min_n_error_message
	exit_app
check_max_size:		
	cmp ax, n_max_size
	jbe good_n
	print_message max_n_error_message
	exit_app
good_n:
    mov ax, counter
    cmp ax, n
    jae end_main

    mov sp,program_length + 100h + 200h				;перемещение стека на 200h после конца программы
    mov ah,4Ah										;изменить размер блока памяти
    stack_shift = program_length + 100h + 200h		;освободить всю память после конца программы и стека
    mov bx,stack_shift shr 4 + 1 					;новый размер в 16-байтных параграфах 
    int 21h
    mov ax,cs										;заполнение полей EPB, содержащих сегментные адреса
    mov word ptr EPB + 4,ax          				;сегмент командной строки
    mov word ptr EPB + 8,ax         				;сегмент первого FCB
    mov word ptr EPB + 0Ch,ax        				;сегмент второго FCB
    mov ax,4B00h             						;загрузка и выполнение программы     
    mov dx,offset program_path     					;адрес строки с полным именем программы
    mov bx,offset EPB    							;адрес блока параметров          
    int 21h
    inc counter
    jmp good_n
end_main:                 
    int 20h 										;нельзя ret - стек перемещен

program_path  db "test.com", 0       

EPB dw 0000                			;текущее окружение
    dw offset commandline,0  		;адрес командной строки
    dw 005Ch,0,006Ch,0       		;адреса FCB программы
commandline db 125                  ;длина командной строки
    db " /?"                 		;командная строка (3)
command_text db 122 dup (?)         ;командная строка (122)
program_length equ $-start          ;считывание длина программы   
end start