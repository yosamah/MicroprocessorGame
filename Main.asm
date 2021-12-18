;Besm alah


;-----------------MACROS-----------------
;changing to  text mode
changeTextmode Macro
    mov ah,0
    mov al,3
    int 10h
endm changeTextmode
;Set cursor
SetCursor MACRO x,y,PageNO

    mov ah,2
    mov dl,x
    mov dh,y
    mov bh,PageNO
    int 10h

endm SetCursor

;Print Character
PrintChar MACRO Type,Color,Len,PageNO

    mov ah,9
    mov bh,PageNO
    mov al,Type
    mov cx,Len
    mov bl,Color
    int 10h

endm PrintChar

;Draw MACRO
DrawLine MACRO x,y,HorLen,VerLen,Color,PageNO,Type

    SetCursor x,y,PageNO
    PrintChar Type,Color,HorLen,PageNO

endm DrawLine

PrintMessage MACRO MyMessage ;print a message on the screen
    mov AH,9h
    lea DX,MyMessage
    int 21h
ENDM PrintMessage

;----------------------------------------
.model small
.stack 64
.data 

User1            db 'USER1$'
IntialPoints1    db ?

User2            db 'USER2$'
IntialPoints2    db ?

EnterName        db 'Please enter your name:            $'

InitialPointsMSG db 'Initial points:                    $'
PressEnter       db 'Press ENTER to continue            $'
;-----------MainScreenVariables-----------
StartChat        db 'To start chatting press F1         $'
StartGame        db 'To start game press F2             $'
EndProg          db 'To end the program press ESC       $'
f1Pressed        db 'Chat request has been sent         $'
f2Pressed        db 'A game will start now!             $'
escPressed       db 'The game will terminate            $'
undefinedMsg     db 'Please enter a valid key(F1/F2/ESC)$'
char             db '-'
IsF1pressed      db 0
IsF2pressed      db 0
IsESCpressed     db 0
startrow         db 2
startcol         db 0
endcol           db 20




.code
main proc far
    mov ax,@DATA
    mov ds,ax
    
   Call MainScreen

    
    mov ah,4ch ;hlt
    int 21h

main endp
;-------MainScreen-------
MainScreen proc near
        changeTextmode
        SetCursor 25, 8, 0
        PrintMessage StartChat
        SetCursor 27, 10, 0
        PrintMessage StartGame
        SetCursor 24, 12, 0
        PrintMessage EndProg
        DrawLine 0,20,80,0,0fh,0,'-'

    myLoop:
        mov ah,0
        int 16h
        cmp ah, 59
        jnz check2ndkey
        SetCursor 0, 21, 0
        PrintMessage f1Pressed
        mov IsF1pressed, 1
        jmp finishd
        check2ndkey:
        cmp ah, 60
        jnz check3rdkey
        SetCursor 0, 21, 0
        PrintMessage f2Pressed
        mov IsF2pressed, 1
        jmp finishd
        check3rdkey:
        cmp ah, 1
        jnz undefined
        SetCursor 0,21,0
        PrintMessage escPressed
        mov IsESCpressed, 1
        jmp finishd
        undefined:
        SetCursor 0, 21, 0
        PrintMessage undefinedMsg
    jmp myLoop 
        finishd:
    RET
endp MainScreen

end main