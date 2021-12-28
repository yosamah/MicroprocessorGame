
;---------------------------
        .MODEL SMALL
        .STACK 64
        .DATA
string db 'abababa'
endd db 0
reverse db 7 dup(?) 
current db 2h
currentt dw 0ABA2h
current_dec db ?        
        .code
MAIN    PROC FAR               
        MOV AX,@DATA
        MOV DS,AX 
        MOV ES,AX
        



; convert ax to decimal
; apply operation
; convert to hexa
; put in register

;  convert to decimal  from hexa-ascii (4 bytes)
     
; ABCD in bx --> convert to decimal in aux

mov si,0
mov bx,0
mov cl,10h
loopingg:
mov al,current
mov ah,0
div cl
mov current,ah 
mov ah,0
cmp al,0Ah
jb rest33
add al,37h
jmp rest
rest33:
add al,30h
rest:
shr cl,4
mov current_dec[si],al
inc si
cmp si,2
jb loopingg




mov si,4
mov bx,0
mov cx,1 

looping:
mov ah,0
;mov al,current[si-1]
sub al,30h
cmp current[si-1],'A'
jb rest3
sub al,7
rest3:
mul cx
add bx,ax
mov dx,16
mov ax,cx
mul dx
mov cx,ax
dec si
cmp si,0
ja looping


;  convert to decimal  from hexa-ascii (2 bytes)

mov si,4
mov bx,0
mov cx,1 

looping2:
mov ah,0
mov al,current[si-1]
sub al,30h
cmp current[si-1],'A'
jb rest4
sub al,7
rest4:
mul cx
add bx,ax
mov dx,16
mov ax,cx
mul dx
mov cx,ax
dec si
cmp si,2
ja looping2


;mov ax,current[4]
sub ax,30h
cmp current[0],'A'
;jb rest: 
sub al,7h 
rest22:
mov bl,16
mul bl
mul bl
mul bl
add al,current[1]
sub al,30h


mov al,current[2]
sub al,30h 
cmp current[2],'A'
;jb rest: 
sub al,7h 
rest222:
mov bl,16
mul bl
add al,current[3]
sub al,30h




    mov ah,07
    int 21h
    mov ah,0 
    sub al,30h
    ;mov data1[si],ax
    add si,2
    ;loop get
    
    ;converting ascii to decimal
    
    mov si,6 ;si starts from end of number (units first)
    mov cl,1 ;starting value for 10^0 = 1 (powers of 10 stored in cl)
    mov bh,0
    ans:
    mov ax,data1[si-2] ;copy decimal digit into ax
    mul cl      ;multiply it by current power of 10 
    add bx,ax   ;final answer stored in bx, current digit added to bx
    sub si,2    ;go to previous digit 
    mov al,cl   ;the next lines are to get next power of ten
    mov cl,10
    mul cl
    mov cl,al
    cmp si,0    ;chech end of digits
    jne ans
       
        HLT        
MAIN    ENDP
        END MAIN



























