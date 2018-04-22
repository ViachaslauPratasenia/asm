.model small;   
.stack 100h;    
.data
    i dw 0h
    String db 'Enter the string : $' 
    arr db 100h dup(0h)     ;array for string
.code   
Start:
    mov ax, @data  
    mov ds, ax
    mov ah, 00h;         clear screen
    mov al, 2h;          number of func output 
    int 10h
    mov ah, 09h
    Lea dx, String
    int 21h 
    mov ah, 1h;          func input symbol
    mov bx, 0h
Input:                   ;input massiva
    int 21h
    mov cx, si
    mov arr[bx], cl;     lenght word
    cmp al, 32;          check space
    jne AddToArray
    cmp cl, 0h;	         if several spaces
    je Input;            equals
    mov si, 0h;
    add bx, 10h;         start next word (line translation)
    jmp Input
AddToArray:
    inc si
    mov arr[bx+si], al;  set symbol in array 
    cmp al, 13
    jne Input
    mov arr[bx+si], 0h   ;delete enter
    mov i, bx            ;quantity words
    mov bx, 0h
Sort:                    ;viborochnaya sort
    mov di, bx           ;index of minimal lenght
    mov ax, bx
    add ax, 10h
Compare:
    mov si, ax 
    mov cl, arr[di]
    cmp cl, arr[si]
    jae CompareEnd        ;jbe 
    mov di, si            ;if less
CompareEnd: 
    add ax, 10h
    cmp ax, i
    jle Compare
    mov si, 0h
Swap:
    mov cl, arr[bx+si]    ;swap words
    mov al, arr[di]
    mov arr[bx+si], al
    mov arr[di], cl
    inc si
    inc di
    cmp si, 10h
    jb Swap
    add bx, 10h
    cmp bx, i
    jb Sort
    mov ah, 02h           ;func setting pos cursor
    mov bh, 0h            ;num page 
    mov dh, 2h            ;num line
    mov dl, 0h            ;num column
    int 10h
    mov bx, 0h
    mov si, 0h
    mov ah, 2h            ;func output symbol
Output:                   ;output array
    inc si
    mov dx, word ptr arr[bx+si]
    cmp dx, 0h
    jne Skip
    cmp bx, i
    je Exit
    mov si, 0h
    add bx, 10h
    mov dx, ' ' 
Skip:
    int 21h
    cmp bx, i
    jbe Output
Exit:
    mov ah, 4ch;
    int 21h 
End Start