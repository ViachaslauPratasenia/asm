; multi-segment executable file template.
.model small
.data
    errorMsg db "ERROR",13,10,"$"
    nextString db 13,10,'$'
    firstBaseInput db "Input first base in hex",13,10,'$'  
    secondBaseInput db "Input second base in hex",13,10,'$' 
    inputNumber db "Input number",13,10,'$'
    outputResult db "Your result",13,10,'$'
    table db '0123456789ABCDEF'   

    number db 40
    lenNumber db 0
    strNumber db 38 dup("$") ;
  
    firstBase db 40  
    lenghtFirstBase db 0
    stringFirstBase db 38 dup("$") ;
        
    secondBase db 40
    lenghtSecondBase db 0
    stringSecondBase db 38  dup("$");
                                                                              
    result db 40  
    lenResult db 0
    strResult db 38 dup(0),"$" ;                                                                          
  
 
ends

.stack
    dw   128  dup(0)
ends

.code
start:
; set segment registers:
    mov ax, @data
    mov ds, ax
    mov es, ax

     
    lea dx,firstBaseInput    ;"Input first base"
    call output


    lea dx,firstBase
    call input

    lea dx,nextString  
    call output


    lea dx,secondBaseInput         ;"Input second base"
    call output 

    lea dx,secondBase
    call input 
     
    lea dx,nextString  
    call output
         
   
    lea dx,inputNumber
    call output
    
    lea dx,number
    call input 
    
    call Base1ToInt    
    
    call Base2ToInt

    call transferNumToTen
    
    call transferNumToBase2  
    
    lea dx,nextString  
    call output
    
    lea dx,outputResult
    call output
   
    lea dx,result
    call output
    
  exit:
    mov ax, 4ch ; exit to operating system.
    int 21h    
ends    

    output PROC
    mov ah,9h
    int 21h
    ret
    output ENDP 
    
    input PROC
    mov ah,0Ah
    int 21h
    ret
    input ENDP
       
    
    
    Base1ToInt proc  ;FromSystem  
        xor ax,ax
        xor bx,bx
        xor cx,cx  
        xor di,di
        mov cl,lenghtFirstBase  
        mov si,cx
        mov cl,10     
        l1:
        mov bl,stringFirstBase[di]
        sub bl,'0'
        jb error1
        cmp bl,9
        ja error1 
        mul cx
        add ax,bx
        inc di
        cmp di,si
        jne l1        
        mov es,ax     ;first base to es
        ret
             
        error1: 
         lea dx,nextString  
         call output
         
         lea dx,errorMsg
         call output
         jmp exit
         ret                    
    Base1ToInt endp  
    
    Base2ToInt proc
        xor ax,ax
        xor bx,bx
        xor cx,cx  
        xor di,di      
        mov cl,lenghtSecondBase  
        mov si,cx
        mov cl,10     
        l2:
        mov bl,stringSecondBase[di]
        sub bl,'0'
        jb error2
        cmp bl,9
        ja error2 
        mul cx
        add ax,bx
        inc di
        cmp di,si
        jne l2        
        mov bp,ax     ;second base to ds
        ret
             
        error2:
        lea dx,nextString  
        call output
         
        lea dx,errorMsg
        call output
        jmp exit
        ret                    
     Base2ToInt endp 
    
       transferNumToTen proc  
    
        xor ax,ax
        xor bx,bx
        xor cx,cx  
        xor di,di     
        mov cl,lenNumber
        mov si,cx
        mov cx,es 
        dec cx
        mov es,cx
        inc cx   
        l3:
        mov bl,strNumber[di]
        sub bl,'0'
        jb error3
      
        cmp bl,11h
        je A   
        
        cmp bl,12h
        je B  
        
        cmp bl,13h
        je C
     
        cmp bl,14h
        je D
 
        cmp bl,15h
        je E
  
        cmp bl,16h
        je F
         
        K:
        mov dx,es
        sub dx,bx
        jb error3 
        
        mul cx
        add ax,bx
        inc di
        cmp di,si
        jne l3        
        mov es,ax     ;second base to ds
        ret
        A:
        mov bl, 0Ah
        jmp K
        B:
        mov bl,0Bh
        jmp K
        C:
        mov bl,0Ch
        jmp K
        D:
        mov bl,0Dh
        jmp K
        E:
        mov bl,0Eh
        jmp K
        F:
        mov bl,0Fh
        jmp K
              
        error3:
         lea dx,nextString  
        call output
         
         lea dx,errorMsg
         call output  
         jmp exit
        ret 
    
      transferNumToTen endp
     
      transferNumToBase2 proc  
    
        xor ax,ax
        xor bx,bx
        xor cx,cx 
        xor di,di

        ;xor di,di
        mov di,offset result+15  

        mov ax,es         
        mov cx,bp
        l4:
        xor dx,dx
        mov si,offset table
        div cx      ;ostatok v dx
        add si,dx
        mov dl,[si]
        mov [di],dl 
        
        dec di
        cmp ax,0   
        jne l4     
        mov dx,di
        ret     
        error4:
        lea dx,errorMsg
        call output  
        jmp exit
        ret   
    transferNumToBase2 endp 
    

end start ; set entry point and stop the assembler.