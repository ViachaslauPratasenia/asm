; multi-segment executable file template.

data segment
    pressAnyKey db "press any key...$" 
    fileName db 'c:\data.txt',0
    bufferString db 40  
    str2 db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    handleFile     dw  0
   
ends

stack segment
    dw   128  dup(0)
ends

;code segment
start:
; set segment registers:
    mov ax, data
    mov es, ax
    
    xor cx,cx
    mov cl,[80h] 
    
    
    cmp cx,0
    je exit
    
    dec cx

    file:
        mov si,82h
        lea di,fileName
        rep movsb  
    
        mov ds, ax

    ; add your code here  


        mov dx,offset fileName 

        mov ah,3Dh ;open        

        mov al,02h ;read write  

        int 21h  
        jc exit             

        mov handleFile,ax   ;bx,ax        
      
        mov    cx,0         ;set cursor in 0.0 
        mov    dx,0        
        mov    bx,handleFile   
        mov    ax,4200h  ;set handleFile file   
        int    21h  
       
        mov ah ,3fh      ;read in buder
        lea dx, bufferString
        mov cx,256 
        int 21h   
       
        mov ah,3Eh   ;close file     
        int 21h  
       
        mov di, offset bufferString     
        mov cx, 0FFh
        xor ax, ax
        repnz scasb 
        not cx  
        dec cx   
       
        xor ch,ch
        mov es,cx
         
        lea si,bufferString
        
    change:    ;change symbols to ' '
         
        xor bx,bx
        mov bx,[si]
        
        sub bx,10 ;jmp \n            10 karetka , 13 new string
        cmp bl,0       
        je end1
        
        sub bx,3   ;jmp \n      
        cmp bl,0       
        je end1

        mov [si],' '        
    end1: 
        lodsb
        loop change       
        
        mov dx,offset fileName 
        mov ah,3Dh         
        mov al,02h        

        int 21h  
        jc exit             

        mov handleFile,ax   ;bx,ax        
      
        mov cx,0         
        mov dx,0         
        mov bx,handleFile    
        mov ax,4200h     
        int 21h 
         
        xor cx,cx
        mov ah,40h
        lea dx,bufferString
        mov bx,handleFile
        mov cx,es
        int 21h
        jmp close_file
               
    close_file:

        mov ah,3Eh        
        int 21h                  
        lea dx, pressAnyKey
        mov ah, 9
        int 21h        ; output string at ds:dx
    
        ; wait for any key....    
        mov ah, 1
        int 21h
exit:   
    mov ax, 4c00h ; exit to operating system.
    int 21h    
;ends

end start ; set entry point and stop the assembler.
