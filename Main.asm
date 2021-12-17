;Besm alah

.model small
.stack 64
.data 

User1 db 'USER1$'
IntialPoints1 db ?

User2 db 'USER2$'
IntialPoints2 db ?

EnterName db 'Please enter your name: $'

InitialPointsMSG db 'Initial points: $'
PressEnter db 'Press ENTER to continue$'

StartChat db 'To start chatting press F1$'
StartGame db 'To start game press F2$'
EndProg db 'To end the program press ESC$'



.code
main proc far
    mov ax,@DATA
    mov ds,ax
    

    
    mov ah,4ch ;hlt
    int 21h

main endp
end main