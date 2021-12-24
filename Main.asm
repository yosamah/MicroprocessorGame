;-----------بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ------------

;-----------------MACROS-----------------

;-------Changing to graphics mode-------
changeGraphicsmode Macro

    mov ah,0
    mov al,13h
    int 10h

endm changeGraphicsmode

;-------Changing to text mode-------
changeTextmode Macro

    mov ah,0
    mov al,3
    int 10h

endm changeTextmode

;-------Clear Screen-------
ClearScreen MACRO x1,y1,x2,y2,Color

    mov ax,0600h
    mov bh,07
    mov cl,x1
    mov ch,y1
    mov dl,x2
    mov dh,y2
    int 10h

endm ClearScreen

;-------Set cursor-------
SetCursor MACRO x,y,PageNO

    mov ah,2
    mov dl,x
    mov dh,y
    mov bh,PageNO
    int 10h

endm SetCursor

;-------Print Character-------
PrintChar MACRO Type,Color,Len,PageNO

    mov ah,9
    mov bh,PageNO
    mov al,Type
    mov cx,Len
    mov bl,Color
    int 10h

endm PrintChar

;-------Print Character in graphics mode-------
PrintCharGraphics  MACRO char,color,times

    mov al.char
    mov ah,09h
    mov bh,0
    mov bl,color
    mov cx,times
    int 10h
    
ENDM PrintCharGraphics

;-------Draw MACRO-------
DrawLine MACRO x,y,HorLen,VerLen,Color,PageNO,Type

    SetCursor x,y,PageNO
    PrintChar Type,Color,HorLen,PageNO

endm DrawLine

;-------Print a message on the screen-------
PrintMessage MACRO MyMessage 
    mov AH,9h
    lea DX,MyMessage
    int 21h
ENDM PrintMessage

;-------Status Chat-------
StatusChat MACRO msg1

    DrawLine WindowStart,WindowEndY-2,WindowEndX,0,03h,0,'-'
    SetCursor WindowStart,WindowEndY-1,0
    PrintMessage msg1

endm StatusChat


;-------Show Mouse-------
ShowMouse MACRO

    mov ax,1
    int 33h

endm ShowMouse

;-------Get Cursor position-------
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

;-------Get key no wait-------
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

;-------Get key wait-------
GetKeyWait MACRO sc,char

    mov ah,0
    int 16h
    mov sc,ah
    mov char,al

endm GetKeyWait

;-------Read message-------
ReadMessage MACRO msg
    mov ah,0Ah
    lea dx,msg
    int 21h
endm ReadMessage

;-------Scroll-------
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

;--------Getting the username from the user----------
GetUserName MACRO UserName
    LOCAL loop_Name_main
    LOCAL invalidName
    LOCAL NameComplete 
    LOCAL clear_UserName

    loop_Name_main:
     
    PrintMessage EnterName
    
    mov BX, 0
    clear_UserName:
    mov UserName[BX], '$'
    inc BX
    cmp BX, 15
    jle clear_UserName
    
    ReadMessage UserName ;get the string from the user and save it in username
    
    
    ;checking if the name contain olnly chars
    cmp UserName[2], 'A'
    jb  invalidName
    cmp UserName[2], 'Z'
    jbe NameComplete

    cmp UserName[2], 'a'
    jb  invalidName
    cmp UserName[2], 'z'
    ja  invalidName

    jmp NameComplete     
        
    invalidName:
    mov ah,09h 
    lea dx, messageinvalidcharacter   
    int 21h     
    
    jmp loop_Name_main
         
    NameComplete: 
ENDM GetUserName

;--------Reading a number from the user----------
ReadNumber MACRO IntialPoints
    LOCAL loop_number_main
    LOCAL invalidcharacter
    LOCAL numbercomplete 
    LOCAL loop_read_number

    loop_number_main:  
    PrintMessage InitialPointsMSG     
    
    mov IntialPoints,0   
    loop_read_number:

    mov ah,01h
    int 21h
    
    cmp al,0dh  ; check if enter key is pressed
    je numbercomplete   
    
    cmp al,30h  ; check if input character is less then 0, 
    jl invalidcharacter 
 
    cmp al,39h  ; check if input character is great then 9
    jg invalidcharacter
    
    sub al,30h
    mov ah,00                            
    mov bx,ax 
    
    mov ax,IntialPoints
    mul MulNmber
    
    add ax,bx      
    mov IntialPoints,ax
    
   
    jmp loop_read_number
    
    
invalidcharacter:
    mov ah,09h 
    lea dx, messageinvalidcharacter   
    int 21h     
    
    jmp loop_number_main           
        
numbercomplete: 
ENDM ReadNumber

;--------Draw pixel----------
DrawPixel Macro row,col,color

    mov cx,col
    mov dx,row
    mov al,color
    mov ah,0ch
    int 10h 

endm DrawPixel

;--------Draw line----------
DrawLineGraphics Macro start,end,HV,flag,color
    LOCAL vertical
    LOCAL horizontal
    LOCAL bara

    pusha
    mov ax,flag
    cmp ax,0 ;If flag = 0 -> draw horizontal line

    mov si,start
    mov di,end

    jne vertical

    horizontal:
    DrawPixel HV,si,color
    inc si
    cmp si,di
    jbe horizontal

    jmp bara

    vertical:
    DrawPixel si,HV,color
    inc si
    cmp si,di
    jbe vertical

    bara: popa

endm DrawLineGraphics

;--------Draw filled rectangle----------
DrawFilledRectangle macro x1,y1,x2,y2,colorBorder,colorFill
    LOCAL MyZeft

    pusha
    mov dx,x1
    mov di,x2
MyZeft:     
    DrawLineGraphics y1,y2,dx,0,colorFill
    inc dx
    cmp dx,di
    jbe MyZeft

    DrawLineGraphics y1,y2,x1,0,colorBorder
    DrawLineGraphics y1,y2,x2,0,colorBorder
    DrawLineGraphics x1,x2,y1,1,colorBorder
    DrawLineGraphics x1,x2,y2,1,colorBorder
    
    popa

endm DrawFilledRectangle


;--------Draw registers----------
DrawRegisters  MACRO x1,y1

    DrawFilledRectangle x1,y1,x1+9,y1+36,White,Purple
    DrawFilledRectangle x1+13,y1,x1+22,y1+36,White,Purple
    DrawFilledRectangle x1+26,y1,x1+35,y1+36,White,Purple
    DrawFilledRectangle x1+39,y1,x1+48,y1+36,White,Purple

ENDM DrawRegisters

;--------Main menu----------
MainMenu  MACRO 
    
     changeTextmode  
    ;Get Info  of user1 
    GetUserName User1Name
    ReadNumber IntialPoints1
    call GetEnter

    ;Get Info  of user2 
    GetUserName User2Name
    ReadNumber IntialPoints2
    call GetEnter

    
    Call MainScreen

ENDM MainMenu

;----------------------------------------
.model small
.stack 64
.386
.data 

User1                   db 'USER1$'
User1Name               DB 15,?,15 DUP('$') , '$'
IntialPoints1           dw ?
    
User2                   db 'USER2$'
User2Name               DB 15,?,15 DUP('$') , '$'
IntialPoints2           dw ?      
    
EnterName               db 'Please enter your name:',10, 13, '$'
    
InitialPointsMSG        db 10,13,'Initial points:',10,13, '$'
PressEnter              db 10,13,'Press ENTER to continue$'
    
;-----------MainScreenVariables-----------
StartChat               db 'To start chatting press F1         $'
StartGame               db 'To start game press F2             $'
EndProg                 db 'To end the program press ESC       $'
f1Pressed               db 'Chat request has been sent         $'
f2Pressed               db 'A game will start now!             $'
escPressed              db 'The game will terminate            $'
undefinedMsg            db 'Please enter a valid key(F1/F2/ESC)$'
char                    db '-'
IsF1pressed             db 0
IsF2pressed             db 0
IsESCpressed            db 0
startrow                db 2
startcol                db 0
endcol                  db 20

;-----------Circle variables-----------
XC                      dw 50
YC                      dw 50
X_Circle                dw 0
Y_Circle                dw 0
Radius                  dw 8
P                       dw 0

;Geting username variables 
MulNmber                db 10
messageinvalidcharacter DB 'Invalid Input',10,13, '$'


;Chat Variables
ChatHeight              equ 11
ChatLength              equ 80
ChatStatusMSG1          db 'To end chat press F3 $'
User1CursorX            db ?
User1CursorY            db ?
User2CursorX            db ?
User2CursorY            db ?
ChatMessage             db 70,?,70 dup('$')
ChatMessage2            db ?,'$'


;Global window variables
WindowStart             equ 0
WindowEndX              equ 80
WindowEndY              equ 24

WindowGStart            equ 0
WindowGEndX             equ 199
WindowGEndY             equ 319
        
MousePosX               dw ?
MousePosY               dw ?
MouseStat               dw ?
ScanCode                db ?
        
F3Scancode              equ 61d
F2Scancode              equ 60d
F1Scancode              equ 59d
ESCScancode             equ 1d


;Colors
Black                   equ 0
Blue                    equ 1
Green                   equ 2 
Cyan                    equ 3
Red                     equ 4
Magenta                 equ 5
Brown                   equ 6
LightGray               equ 7
DarkGray                equ 8
Purple                  equ 9
LightGreen              equ 0Ah
LightCyan               equ 0Bh
LightRed                equ 0Ch
LightMagenta            equ 0Dh
Yellow                  equ 0Eh
White                   equ 0Fh
        
;----------------------------------------------
.code
main proc far
    mov ax,@DATA
    mov ds,ax

    ;MainMenu

    changeGraphicsmode
    
    ;DrawLineGraphics 100,200,50,1,0Fh
    ;DrawFilledRectangle 50,50,120,150,06,0Fh

    call DrawCircle
    dec Radius
    call DrawCircle


    ;call GameScreen
    

    mov ah,4ch ;hlt
    int 21h

main endp


;---------------------Proceduers---------------------

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
        Call ChatWindow
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


;-------Chat Proc-------
ChatWindow proc near

    ClearScreen WindowStart,WindowStart,WindowEndX,WindowEndY,0
    
    DrawLine WindowStart,WindowStart,WindowEndX,0,03h,0,'-'

    SetCursor WindowStart,WindowStart+1,0
    PrintMessage User1Name+2

    DrawLine WindowStart,ChatHeight,WindowEndX,0,03h,0,'-'

    SetCursor WindowStart,ChatHeight+1,0
    PrintMessage User2Name+2

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
    call MainScreen
    ret
ChatWindow endp 


;-------Checking cursor position to scroll-------
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


;-------Clearing screen after ENTER-------
GetEnter Proc
    
    return: 
    
    PrintMessage PressEnter
    mov ah,0h
    int 16h    
    cmp ah,28
    jnz return

    ClearScreen 0,0,80,25,0Fh
    SetCursor WindowStart,WindowStart,0
    RET
GetEnter ENDP


;-------Game Screen-------
GameScreen proc

    DrawLineGraphics WindowGStart,WindowGEndY,WindowGStart+16,0,Purple
    DrawLineGraphics WindowGStart,WindowGEndY,WindowGStart+78,0,Purple
    DrawLineGraphics WindowGStart,WindowGEndY,WindowGStart+89,0,Purple
    DrawLineGraphics WindowGStart,WindowGEndY,WindowGStart+180,0,Purple

    DrawLineGraphics WindowGStart+17, WindowGStart+89 ,WindowGStart+160 ,1, Purple
    DrawLineGraphics WindowGStart,WindowGStart+16,WindowGStart+147,1,Purple
    DrawLineGraphics WindowGStart,WindowGStart+16,WindowGStart+173,1,Purple
    DrawLineGraphics WindowGStart+90,WindowGStart+180,WindowGStart+150,1,Purple
    DrawLineGraphics WindowGStart+90,WindowGStart+180,WindowGStart+170,1,Purple

    DrawRegisters 24,40 ;MACROO
    DrawRegisters 24,85

    DrawRegisters 24,200 ;MACROO
    DrawRegisters 24,245

    ret
GameScreen endp

;--------Draw Circle----------
DrawCircle proc

        pusha

        mov ax,Radius 
        mov Y_Circle,ax

        ;plot initial point
        call plot
        ;P=1-Radius
        mov ax,01
        mov dx,Radius
        xor dx,0ffffh
        inc dx
        add ax,dx
        mov P,ax

        ;while(X_Circle<Y_Circle) 
    loop1:  mov ax,X_Circle
        cmp ax,Y_Circle
        jnc stop

        ;X_Circle++
        inc X_Circle

        ;if(P<0)
        mov ax,P
        rcl ax,01
        jnc jump2

        ;P+=2X_Circle+1
        mov ax,X_Circle
        rcl ax,01
        inc ax
        add ax,P
        jmp jump3

        ;else
        ;Y_Circle++
        ;P+=2(X_Circle-Y_Circle)+1;
    jump2:  dec Y_Circle
        mov ax,X_Circle
        mov dx,Y_Circle
        xor dx,0ffffh
        inc dx
        add ax,dx
        rcl ax,01
        jnc jump4
        or ax,8000h
    jump4: inc ax
        add ax,P

    jump3:  mov P,ax
        ;plot point
        call plot
        jmp loop1
stop:
        mov X_Circle,0
        mov Y_Circle,0
        mov P,0
        popa
endp DrawCircle

;-------Plotting circle-------
plot proc
    mov ah,0ch
    mov al,02

    mov cx,XC
    add cx,X_Circle
    mov dx,YC
    add dx,Y_Circle
    int 10h

    mov cx,XC
    add cx,X_Circle
    mov dx,YC
    sub dx,Y_Circle
    int 10h

    mov cx,XC
    sub cx,X_Circle
    mov dx,YC
    add dx,Y_Circle
    int 10h

    mov cx,XC
    sub cx,X_Circle
    mov dx,YC
    sub dx,Y_Circle
    int 10h

    mov cx,XC
    add cx,Y_Circle
    mov dx,YC
    add dx,X_Circle
    int 10h

    mov cx,XC
    add cx,Y_Circle
    mov dx,YC
    sub dx,X_Circle
    int 10h

    mov cx,XC
    sub cx,Y_Circle
    mov dx,YC
    add dx,X_Circle
    int 10h

    mov cx,XC
    sub cx,Y_Circle
    mov dx,YC
    sub dx,X_Circle
    int 10h

    ret
    plot endp

end main