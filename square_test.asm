

.model small
.386
.stack 64
.data
color db 0fh 
.code
main proc far 
    mov ax,@DATA
    mov ds,ax 
    
    mov ah,0
    mov al,13h
    int 10h
    mov si,0
looping:    
    mov ah,0
    mov al,13h
    int 10h
    
    mov ah,1
    int 16h
    jz start
    
    cmp ah,48h
    jne start
    mov ah,7
    int 21h
    
    cmp color,0fh
    jae reset
    inc color
    jmp start
    
reset:
    mov color,1     

start:    
    mov cx,20d   ;horizontal line middle
    mov dx,si
    mov al,color
    mov ah,0ch
    draw:
    cmp cx,35d
    ja rest1
    int 10h
    inc cx
    jmp draw
rest1:     
    mov cx,20d   ;horizontal line middle
    mov dx,si
    add dx,15
    mov al,color
    mov ah,0ch
    draw2:
    cmp cx,35d
    ja rest2
    int 10h
    inc cx
    jmp draw2 
rest2:    
    mov dx,si
    mov cx,20d
    mov al,color
    mov ah,0ch
    draw3:
    mov di,si
    add di,15
    cmp dx,di
    ja rest3 
    int 10h
    inc dx
    jmp draw3
rest3:
    mov dx,si
    mov cx,35d
    mov al,color
    mov ah,0ch
    draw4:
    mov di,si
    add di,15
    cmp dx,di
    ja rest4 
    int 10h
    inc dx
    jmp draw4
rest4:
add si,5
cmp si,185
hlt
jb cont
mov si,0
cont:
jmp looping
    
    
    
    hlt
main endp

 
end main