;-----------بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ------------

;-----------------MACROS-----------------

;changing to  text mode
changeTextmode Macro

    mov ah,0
    mov al,3
    int 10h

endm changeTextmode

;---Clear Screen---
ClearScreen MACRO x1,y1,x2,y2,Color

    mov ax,0600h
    mov bh,07
    mov cl,x1
    mov ch,y1
    mov dl,x2
    mov dh,y2
    int 10h

endm ClearScreen

;---Set cursor---
SetCursor MACRO x,y,PageNO

    mov ah,2
    mov dl,x
    mov dh,y
    mov bh,PageNO
    int 10h

endm SetCursor

;---Print Character---
PrintChar MACRO Type,Color,Len,PageNO

    mov ah,9
    mov bh,PageNO
    mov al,Type
    mov cx,Len
    mov bl,Color
    int 10h

endm PrintChar

;---Draw MACRO---
DrawLine MACRO x,y,HorLen,VerLen,Color,PageNO,Type

    SetCursor x,y,PageNO
    PrintChar Type,Color,HorLen,PageNO

endm DrawLine

;---Print a message on the screen---
PrintMessage MACRO MyMessage 
    mov AH,9h
    lea DX,MyMessage
    int 21h
ENDM PrintMessage

;---Status Chat---
StatusChat MACRO msg1

    DrawLine WindowStart,WindowEndY-2,WindowEndX,0,03h,0,'-'
    SetCursor WindowStart,WindowEndY-1,0
    PrintMessage msg1

endm StatusChat


;---Show Mouse---
ShowMouse MACRO

    mov ax,1
    int 33h

endm ShowMouse

;---Get Cursor position---
GetCursorPos MACRO x,y,stat

    mov si,200
    mov ax,3
    mPos:int 33h
    cmp bx,0
    jnz TheEnd
    dec si
    jnz mPos
    jmp TheEnd2

TheEnd:
    mov x,cx
    mov y,dx
    mov stat,bx
TheEnd2:
    mov stat,0

endm GetCursorPos

;---Get key no wait---
GetKeyNoWait MACRO SC

    mov al,0
    mov ah,1
    int 16h

    cmp al,0
    jz EndKeyNoWait

    mov SC,ah
    mov ah,7
    int 21h

    EndKeyNoWait:

endm GetKeyNoWait

;---Get key wait---
GetKeyWait MACRO sc,char

    mov ah,0
    int 16h
    mov sc,ah
    mov char,al

endm GetKeyWait

;---Read message---
ReadMessage MACRO msg
    mov ah,0Ah
    lea dx,msg
    int 21h
endm ReadMessage

;---Scroll---
Scroll MACRO x1,y1,x2,y2,Color,line

    mov ah,06h
    mov al,line
    mov bh,07
    mov cl,x1
    mov ch,y1
    mov dl,x2
    mov dh,y2
    int 10h

endm Scroll


;----------------------------------------

.model small
.stack 64
.386
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

UserName1 db 'BoodyBeeh :$'
UserName2 db 'Farooha :$'

;Chat Variables
ChatHeight equ 11
ChatLength equ 80
ChatStatusMSG1 db 'To end chat press F3 $'
User1CursorX db ?
User1CursorY db ?
User2CursorX db ?
User2CursorY db ?
ChatMessage db 70,?,70 dup('$')
ChatMessage2 db ?,'$'


;Global window variables
WindowStart equ 0
WindowEndX equ 80
WindowEndY equ 24

MousePosX dw ?
MousePosY dw ?
MouseStat dw ?
ScanCode db ?

F3Scancode equ 61d
F2Scancode equ 60d
F1Scancode equ 59d
ESCScancode equ 1d

.code
main proc far
    mov ax,@DATA
    mov ds,ax
    
    mov ah,0
    mov al,03h
    int 10h

    ;DrawLine 0,0,80,0,06h,0,'-'
    ;ClearScreen 0,0,80h,25h,00h
    ;DrawLine 0,22,80,0,06h,0,'-'
    
    Call ChatWindow

    mov ah,4ch ;hlt
    int 21h

main endp
;---------------------Proceduers-------------------

;----Chat Proc----
ChatWindow proc near

    ClearScreen WindowStart,WindowStart,WindowEndX,WindowEndY,0
    
    DrawLine WindowStart,WindowStart,WindowEndX,0,03h,0,'-'

    SetCursor WindowStart,WindowStart+1,0
    PrintMessage UserName1

    DrawLine WindowStart,ChatHeight,WindowEndX,0,03h,0,'-'

    SetCursor WindowStart,ChatHeight+1,0
    PrintMessage UserName2

    StatusChat ChatStatusMSG1

    mov User1CursorX,4
    mov User1CursorY,WindowStart+2

    mov User2CursorX,4
    mov User2CursorY,ChatHeight+2

CursorLoop:

    SetCursor User1CursorX,User1CursorY,0
    GetKeyWait ScanCode,ChatMessage2
    
    cmp ScanCode,F3Scancode
    jz Khalas

    PrintMessage ChatMessage2
    ReadMessage ChatMessage
    inc User1CursorY

    SetCursor User2CursorX,User2CursorY,0
    GetKeyWait ScanCode,ChatMessage2
    cmp ScanCode,F3Scancode
    
    jz Khalas
    PrintMessage ChatMessage2

    ReadMessage ChatMessage
    inc User2CursorY

    call CheckCursor 
        
    jmp CursorLoop
Khalas:
    ret
ChatWindow endp 

;------Checking cursor position to scroll-------
CheckCursor proc near

    cmp User1CursorY,ChatHeight-1
    jb scrollUP
    
    Scroll WindowStart,WindowStart+2,WindowEndX,User1CursorY,00h,1
    dec User1CursorY
    scrollUP:
        
    cmp User2CursorY,WindowEndY-3
    jb TheEndd
    Scroll WindowStart,ChatHeight+2,WindowEndX,User2CursorY,00h,1
    dec User2CursorY
    TheEndd:
ret
endp CheckCursor


end main