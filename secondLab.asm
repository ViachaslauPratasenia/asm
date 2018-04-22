.model small
.stack 100h
.data

first dw 0
second dw 0
input_first db 'Input first number in hex : $'
input_second db 'Input second number in hex : $'
new_str db 0dh,0ah,'$' 
xor_mes db 'XOR $'
not_mes db 'NOT first number $'
and_mes db 'AND $'
or_mes db 'OR $' 
result_mes db 'result : $' 
ccc db 'chisla in hex : $'
.code
start: 
mov ax,@data
mov ds,ax
mov ah,09h
lea dx,input_first
int 21h
call read_number
mov first,dx
call newStr
 
lea dx,input_second
int 21h
call read_number
mov second,dx
call newStr
       
call load_numbers
xor ax,dx
lea dx,xor_mes
call print_result


call load_numbers
not ax
lea dx,not_mes
call print_result


call load_numbers
and ax,dx
lea dx,and_mes
call print_result


call load_numbers
or ax,dx
lea dx,or_mes
call print_result

mov ah,4ch
int 21h 

load_numbers proc
    mov ax,first
    mov dx,second
    ret
load_numbers endp


check_input proc
    
    push bx
    push dx
    push ax
    xor bx,bx 
    
    mov ax,0300h
    int 10h 
    pop ax 
    

    cmp ax,0000h  ;<0
    jl del
    cmp si,0000h  ;if namber
    je exit 
    cmp si,0100h  ;if big letters
    je s
    cmp si,0101h   ;if little letter
    je s
    jmp sq
s:
    cmp ax,000Ah     ; if less than the first letter
    jl del
sq: 
    cmp ax,000Fh       ; for everyone if >f
    ja del

    
    mov si,0001h   ; if no errors
    jmp exit
del:                      ;delete entered simbol
    push ax
    mov si,0000h         ; for error code
    dec dx              ;  return pointer 1 simbol less
    mov ax,0200h        ;pointer to dx
    int 10h
    push dx
    mov dx,0020h       ; instead of wrong simbol '_'
    int 21h
    pop dx
    int 10h
    pop ax
exit:
    pop dx
    pop bx
    ret
check_input endp

read_number proc
    xor dx,dx
    mov bl,10h
l1:
    mov ah,01h
    int 21h
    
    cmp al,0dh        ; if 'enter'
    je end_of_input
    mov si,0000h
    sub ax,0130h    ;ah minus command, al minus '0'    
    cmp ax,0009h
    jl n
    sub ax,0007h          ;for big letters
    mov si,0100h
    cmp ax,000Fh
    jl n
    sub ax,0020h           ; for little letters
    mov si,0101h
    n:
    call check_input
    cmp si,0000h
    ;je l1
    mov si,ax
    mov ax,dx
    mul bl
    mov dx,ax
    add dx,si
    loop l1
end_of_input:
    ret
read_number endp

print_result proc
    push ax
    mov ah,09h
    int 21h
    lea dx,result_mes
    int 21h
    mov bx,10h    ;zadaem sistemu schislenija
    pop ax
    call convert
    call newStr
    ret
print_result endp    
 
 
convert proc   ;pered call bx - zadat' ss
    xor cx,cx
again:
    xor dx,dx
    div bx
    inc cx
    push dx
    cmp ax,0
    jne again 
    mov ah,02h
output:
    pop dx
    add dx,30h
    
    cmp dx,39h
    jle no_more_nine
    add dx,7
no_more_nine:
    int 21h
    loop output    
    ret
convert endp

newStr proc
    mov ah,09h
    lea dx,new_str
    int 21h
    ret
newStr endp
end start