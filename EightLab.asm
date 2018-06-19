org 100h
start:

mov ah, 0
mov al, 3
int 10h
 
 
; установливаем es в 0000
mov ax, 0       
mov es, ax
; вычисляем векторный адрес для прерывания 23h
mov al, 23h    
; умножаем 23h на 4, сохранить результат в ax:
mov bl, 4h       
mul bl          
mov bx, ax
;  задаем смещение нового вектора прерывания:
mov si, offset [new23]
mov es:[bx], si
add bx, 2		;сегмент обработчика   
; копируем сегмент в вектор прерывания:    
mov ax, cs     
mov es:[bx], ax
    
int 23h   
  
mov si,offset bufer[0]  	;проверка буфера
l1:
cmp [si],0
je exit
  
mov ah,2h             
mov dl,[si]             ;выводим символ
int 21h
inc si
  
mov al,0                ;проверка на наличие символа в буфере клавиатуры
mov ah,01h
int 16h
cmp al,0  
je noRead
 
mov ah,00h              ;если в буфере  что-то есть.то читаем и сравниваем с символом завршения
int 16h
cmp al,3h				;символ ctrl+c
je exit
noRead:     
jmp l1
  
exit:
int 20h     ; остановка программы.

; новое прерывание 23h:
new23: 
	   pusha  ; сохранение всех регистров

; проверка что сегмент данных это сегмент кода:
       push cs
       pop ds

; установить регистр сегмента в видеопамять:
       mov     ax, 0b800h
       mov     es, ax
             
       mov dx,offset f_name 
       mov ah,3Dh         
       mov al,02h        
       int 21h  

       mov handle,ax       ;bx,ax              
       mov    cx,0         ;set cursor in 0.0 
       mov    dx,0        
       mov    bx,handle    ;set handleFile file  
       mov    ax,4200h     
       int    21h  
       
       mov ah ,3fh         ;read in bufer
       lea dx, bufer
       mov cx,es 
       int 21h   
       
       mov ah,3Eh          ;close file     
       int 21h 
stop:
       popa                  ; загрузка всех регистров.
       iret  				; возвращает прерыванние.
 
f_name db 'c:\text.txt',0  
handle     dw  0
bufer db 250 dup(0) 

