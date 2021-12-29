;-----------بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ------------;

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

    pusha
    mov ah,2
    mov dl,x
    mov dh,y
    mov bh,PageNO
    int 10h
    popa
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

    mov al,char
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
    pusha
    mov AH,9h
    mov bl,Purple
    lea DX,MyMessage
    int 21h
    popa
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

;-------Compare Strings-------
CompareStrings MACRO cmd1,cmd2,size,ok
    LOCAL endinggg,true
    pusha
    mov ok,0
    mov cx,size
    lea si,cmd1
    lea di,cmd2
    REPE CMPSB
    cmp cx,0
    je true
    mov ok,0
    jmp endinggg
true:
    mov ok,1
endinggg:
    popa
endm CompareStrings


;-------Check Empty String-------
isEmptyString MACRO msg,ok
     LOCAL is_empty,is_empty_end
     mov ok,0
     cmp msg[0],'$'
     je is_empty
     mov ok,0
     jmp is_empty_end
is_empty:
     mov ok,1
is_empty_end:

endm isEmptyString


;-------Check String Size-------
GetStringSize MACRO msg,size
     LOCAL find_string_size
     pusha
     mov si,0
find_string_size:
   inc si
   cmp msg[si-1],'$'
   jne find_string_size
   dec si
   mov size,si
   popa

endm GetStringSize

;-------Check String Size-------
CheckImmediate MACRO Operand,OK
     LOCAL check_all_dig,check_letter,end,cont
     pusha
     mov OK,0
     GetStringSize Operand,OperandLength
     mov si,0
     cmp OperandLength,4
     ja end
check_all_dig:
   cmp Operand[si],'0'
   jb end
   cmp Operand[si],'9'
   ja check_letter
   jmp cont
check_letter:
   cmp Operand[si],'A'
   jb end
   cmp Operand[si],'F'
   ja end
cont:
   inc si
   cmp si,OperandLength
   jb check_all_dig
   mov OK,1
end:
   popa

endm CheckImmediate

;-------Convert from Ascii (hexa) to number-------
AsciiToNumber MACRO current,val,answer
LOCAL looping,rest
    
    ;2 for al - 2 bytes
    ;0 for ax - 4 bytes

    pusha

    GetStringSize current,StringSize
    mov si,StringSize
    mov bx,0
    mov cx,1 

looping:
    mov ah,0
    mov al,current[si-1]
    sub al,30h
    cmp current[si-1],'A'
    jb rest
    sub al,7
rest:
    mul cx
    add bx,ax
    mov dx,16
    mov ax,cx
    mul dx
    mov cx,ax
    dec si
    cmp si,0
    ja looping

    mov answer,bx
popa
endm AsciiToNumber


;-------Convert from Number to Ascii 4 bytes-------
NumbertoAscii4byte MACRO current,answer
LOCAL looping,rest,rest2

    pusha
    mov si,0
    mov bx,0
    mov cx,1000h
looping:
    mov ax,current
    mov dx,0
    div cx
    mov current,dx 
    mov ah,0
    cmp ax,0Ah
    jb rest2
    add ax,37h
    jmp rest
rest2:
    add ax,30h
rest:
    shr cx,4
    mov answer[si],al
    inc si
    cmp si,4
    jb looping

    popa
endm NumbertoAscii4byte


;-------Convert from Number to Ascii 2 bytes-------
NumbertoAscii2byte MACRO current,answer
LOCAL looping,rest,rest2

    pusha
    mov si,0
    mov bx,0
    mov cl,10h
looping:
    mov al,current
    mov ah,0
    div cl
    mov current,ah 
    mov ah,0
    cmp al,0Ah
    jb rest2
    add al,37h
    jmp rest
rest2:
    add al,30h
rest:
    shr cl,4
    mov answer[si],al
    inc si
    cmp si,2
    jb looping

    popa
endm NumbertoAscii2byte

;-------Read message-------
ReadMessage MACRO msg
    mov ah,0Ah
    lea dx,msg
    int 21h
endm ReadMessage

;-------Scroll down-------
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

;-------Scroll Up-------
ScrollScreenUp MACRO x1,y1,x2,y2,Color,line

    mov ah,07h
    mov al,line
    mov bh,07
    mov cl,x1
    mov ch,y1
    mov dl,x2
    mov dh,y2
    int 10h

endm ScrollScreenUp

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

    DrawFilledRectangle x1,y1,x1+10,y1+43,White,Purple
    DrawFilledRectangle x1+16,y1,x1+26,y1+43,White,Purple
    DrawFilledRectangle x1+32,y1,x1+42,y1+43,White,Purple
    DrawFilledRectangle x1+48,y1,x1+58,y1+43,White,Purple

     ;DrawFilledRectangle x1+70,y1,x1+65,y1+43,White,Purple

ENDM DrawRegisters

;--------Draw circle----------
Drawcirc Macro x,y,r,color

    mov Xc, x
    mov Yc, y
    mov Radius,r
    mov CircColor, color
    call DrawCircle
    

ENDM Drawcirc
;--------Welcome Text----------
WelcomeText Macro
    SetCursor 23, 8, 0
    PrintMessage Welcome
    mov ah,0
    int 16h
    ClearScreen 0,0,80,25,0Fh
    SetCursor WindowStart,WindowStart,0
ENDM WelcomeText
;--------GoodBye Text----------
GoodByeText Macro
    changeTextmode
    ClearScreen 0,0,80,25,0Fh
    SetCursor 35, 8, 0
    PrintMessage GoodBye
    mov ah,0
    int 16h
ENDM GoodByeText
;--------Upper to lower case----------
UpperToLower Macro InputString
    Local loop1,loop2
pusha
    mov bx , 0h

    loop1:
    mov al, InputString[bx]
    cmp al , 'A'
    jb  loop2
    cmp al , 'Z'
    ja loop2
    add al , 20h

    loop2: 

    mov InputString[bx] , al 
    inc bx
    cmp bx , 16h
    jnz loop1

popa
endm UpperToLower
;--------Set 4 Digits----------
Set4Dig Macro IntialPoints,IntialPoints_Meg
    pusha
    mov ax,IntialPoints
    mov bl,10
    div bl

    add ah,30h
    mov IntialPoints_Meg[3],ah

    mov ah,0
    div bl

    add ah,30h
    mov IntialPoints_Meg[2],ah

    mov ah,0
    div bl

    add ah,30h
    mov IntialPoints_Meg[1],ah

    mov ah,0
    div bl

    add ah,30h
    mov IntialPoints_Meg[0],ah

    popa
ENDM Set4Dig
;--------Get Minimum----------
GetMin Macro x,y,Min
    Local Exit
    pusha
    mov ax,x
    mov min,ax
    mov ax,y
    cmp Min,ax
    jb Exit
    mov Min,ax
    popa
    Exit:

ENDM GetMin

;-------Load Registers-------
LoadReg Macro AX_Reg_Value,BX_Reg_Value,CX_Reg_Value,DX_Reg_Value,SI_Reg_Value,DI_Reg_Value,SP_Reg_Value,BP_Reg_Value,CF ;CF-> carry flag
    Local ClearCarry,Exit

    mov ax, AX_Reg_Value
    mov bx, BX_Reg_Value
    mov cx, CX_Reg_Value
    mov dx, DX_Reg_Value
    mov si, SI_Reg_Value
    mov di, DI_Reg_Value
    mov sp, SP_Reg_Value
    mov bp, BP_Reg_Value
    cmp CF,0
    je ClearCarry
    stc
    jmp Exit
    ClearCarry:
    clc
    Exit:
ENDM LoadReg


;-------exc inc Command-------
excIncCommand Macro UserNum
    Local U1,skip, findLetter,axsah,bayz,tanyuser
    mov dl, 3
    cmp CurCommand+3,' '
    jne bayz
    findLetter: ;;;  removes spaces
        inc dl 
        ;cmp dl, actualSizeCommand
        ja bayz
        mov di, dl
        cmp CurCommand+di,' '
    je findLetter

    mov si, CurCommand+di
    mov di, AX_RegSmall
    mov cx, 2
    REPE CMPSB
    cmp cx, 0  
    je axsah


    

    axsah:
    mov CurReg,0
    
    cmp UserNum,1
    je U1
    LoadReg AX_Reg_Value1,BX_Reg_Value1,CX_Reg_Value1,DX_Reg_Value1,SI_Reg_Value1,DI_Reg_Value1,SP_Reg_Value1,BP_Reg_Value1,CF1


    jmp skip
    U1:
    
    LoadReg AX_Reg_Value2,BX_Reg_Value2,CX_Reg_Value2,DX_Reg_Value2,SI_Reg_Value2,DI_Reg_Value2,SP_Reg_Value2,BP_Reg_Value2,CF2

    skip:
    
    cmp CurReg,0
    jne bayz
    inc ax
    cmp UserNum,1
    jne tanyuser
    mov AX_Reg_Value1,ax
    jmp bayz

    tanyuser:
    mov AX_Reg_Value2,ax



    bayz:


ENDM excIncCommand
;--------Set Brush----------

SetBrush Macro realSize, Color

    mov ah,09
    mov bl, Color
    mov cx, realSize
    int 10h

endm SetBrush
;--------Main menu----------
MainMenu  MACRO 
    
    changeTextmode  
    WelcomeText
    ;Get Info  of user1 
    GetUserName User1Name
    ReadNumber IntialPoints1
    call GetEnter

    ;Get Info  of user2 
    GetUserName User2Name
    ReadNumber IntialPoints2
    call GetEnter
    GetMin IntialPoints1,IntialPoints2,MinIP
    pusha
    mov ax, MinIP
    mov IntialPoints1,ax
    mov IntialPoints2,ax
    popa
    
    Call MainScreen

ENDM MainMenu

;----------------------------------------
.model small
.stack 64
.386
.data 

User1                   db 'USER1$'
User1Name               DB 12,?,12 DUP('$') , '$'
realSize1               db ?
IntialPoints1           dw ?
IP1                     db '0000$'  ;IntialPoints1 as a message

    
User2                   db 'USER2$'
User2Name               DB 12,?,12 DUP('$') , '$'
realSize2               db ?
IntialPoints2           dw ?
IP2                     db '0000$' ;IntialPoints2 as a message 

MinIP                   dw ?       ;Minimum of IntialPoints
    
EnterName               db 'Please enter your name:',10, 13, '$'
    
InitialPointsMSG        db 10,13,'Initial points:',10,13, '$'
PressEnter              db 10,13,'Press ENTER to continue$'
    
;-----------MainScreenVariables-----------
Welcome                 db 'Welcome, Press any key to start', '$'
GoodBye                 db 'GoodBye... ','$'
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
CircColor               db 0fh 

;-----------Circle Text Coordinates-----------
CircX                   db 20
Circ1Y                  db 13
Circ2Y                  db 16
Circ3Y                  db 18
Circ4Y                  db 21

;-----------Game Mode Text Variables-----------
Levelmsg                db 'LV', '$'
AX_Reg                  db 'AX', '$'
BX_Reg                  db 'BX', '$'
CX_Reg                  db 'CX', '$'
DX_Reg                  db 'DX', '$'
SI_Reg                  db 'SI', '$'
DI_Reg                  db 'DI', '$'
SP_Reg                  db 'SP', '$'
BP_Reg                  db 'BP', '$'


AX_RegSmall             db 'ax', '$'
BX_RegSmall             db 'bx', '$'
CX_RegSmall             db 'cx', '$'
DX_RegSmall             db 'dx', '$'
SI_RegSmall             db 'si', '$'
DI_RegSmall             db 'di', '$'
SP_RegSmall             db 'sp', '$'
BP_RegSmall             db 'bp', '$'

Level                   db ?

AX_Reg_Value1           db '0000', '$'
BX_Reg_Value1           db '0000', '$'
CX_Reg_Value1           db '0000', '$'
DX_Reg_Value1           db '0000', '$'
SI_Reg_Value1           db '0000', '$'
DI_Reg_Value1           db '0000', '$'
SP_Reg_Value1           db '0000', '$'
BP_Reg_Value1           db '0000', '$'

AX_Reg_Value2           db '0000', '$'
BX_Reg_Value2           db '0000', '$'
CX_Reg_Value2           db '0000', '$'
DX_Reg_Value2           db '0000', '$'
SI_Reg_Value2           db '0000', '$'
DI_Reg_Value2           db '0000', '$'
SP_Reg_Value2           db '0000', '$'
BP_Reg_Value2           db '0000', '$'

CF1                     db 0
CF2                     db 0
CheckCarry              db 0


;----------Data Segment Variables----------
DS00                      db '0', '$'
DS01                      db '1', '$'
DS02                      db '2', '$'
DS03                      db '3', '$'
DS04                      db '4', '$'

DS00_Value1               db '00', '$'
DS01_Value1               db '00', '$'
DS02_Value1               db '00', '$'
DS03_Value1               db '00', '$'
DS04_Value1               db '00', '$'

DS00_Value2               db '00', '$'
DS01_Value2               db '00', '$'
DS02_Value2               db '00', '$'
DS03_Value2               db '00', '$'
DS04_Value2               db '00', '$'

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
test2                   db 25,?,25 dup('$')

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

Semicolon               db ':$'

;Chosen Commands
incCommand              db 'inc$'
decCommand              db 'dec$'
shlCommand              db 'shl$'
shrCommand              db 'shr$'
clcCommand              db 'clc$'
rorCommand              db 'ror$'
rolCommand              db 'rol$'
nopCommand              db 'nop$'
addCommand              db 'add$'
subCommand              db 'sub$'
adcCommand              db 'adc$'
SBBCommand              db 'sbb$'
xorCommand              db 'xor$'
andCommand              db 'and$'
movCommand              db 'mov$'
rclCommand              db 'rcl$'
rcrCommand              db 'rcr$'
popCommand              db 'pop$'
poppCommand             db 'pop$'
pushCommand             db 'push$'
orCommand               db 'or $'
found_cmd               db 0
Op_to_Execute           db 8 dup('$')
EmptyOp                 db 5 dup('$')
OK                      db ?
OperandLength           dw ?
Operand1                db 6 dup('$')
Operand1Type            db 0, '$'
Operand1Value           dw ?, '$'
startOperand2           dw ?, '$'
Operand2                db 6 dup('$')
Operand2Type            db 0, '$'
Operand2Value           dw ?, '$'

AX_op                   db 'ax', '$'
AL_op                   db 'al', '$'
AH_op                   db 'ah', '$'
BX_op                   db 'bx', '$'
BL_op                   db 'bl', '$'
BH_op                   db 'bh', '$'
CX_op                   db 'cx', '$'
CL_op                   db 'cl', '$'
CH_op                   db 'ch', '$'
DX_op                   db 'dx', '$'
DL_op                   db 'dl', '$'
DH_op                   db 'dh', '$'
SI_op                   db 'si', '$'
DI_op                   db 'di', '$'
SP_op                   db 'sp', '$'
BP_op                   db 'bp', '$'
BX_op_idx               db '[bx]', '$'
SI_op_idx               db '[si]', '$'
DI_op_idx               db '[di]', '$'
MEM0                    db '[0]', '$'
MEM1                    db '[1]', '$'
MEM2                    db '[2]', '$'
MEM3                    db '[3]', '$'
MEM4                    db '[4]', '$'
StringSize              dw ?

UserCommand1            db 14,?,14 dup('$') 
UserCommand2            db 14,?,14 dup('$')

UserCommandSpaces       db 14 dup(' '),'$'


UserCommand1Col         db 0
UserCommand1row         db 10

UserCommand2Col         db 21
UserCommand2row         db 10

CurCommand              db 14 dup('$')
actualSizeCommand       dw ?
CurrUser                db ?
; ax = 0
; bx = 1
; cx = 2
; dx = 3
; si = 4
; di = 5
; sp = 6
; bp = 7

CurReg                  db ?  

;------GAME Variables-------
;TESTING
test3                   dw 93
test4                   dw 30
test5                   dw 120
test6                   dw 70
;;
gunX                   db 120   ;;Gunner coordinates
gunY                   db 70

gunX2                   db 250   ;;Gunner coordinates
gunY2                   db 70

gunXS                   db 120   ;;Gunner coordinates
gunYS                   db 70

gunSC                   db ?

gunShape                db 'W','$'

bulletX                 db ?   ;; Bullet coordinates and its state
bulletY                 db ?
IsFired                 db ?

;;Scan Codes
Arrow_Up                equ 48h
Arrow_Down              equ 50h
Arrow_Right             equ 4Dh
Arrow_Left              equ 4Bh


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
    mov es,ax

    MainMenu


    mov ah,0
    int 16h  
    GoodByeText
    mov ah,4ch ;hlt
    int 21h

main endp


;---------------------Proceduers---------------------

;-------Drawing Gun-------
DrawingGun proc

SetCursor gunX,gunY,0 
    PrintCharGraphics gunShape,Cyan,1
    
    mov ah,01h ;Get key without waiting
    int 16h

    cmp ah,Arrow_Left
    je Go_left
    cmp ah,Arrow_Right
    je Go_right
    cmp ah,Arrow_Down
    je Go_down
    cmp ah,Arrow_Up
    je Go_up    

    mov ah,7  ;Consuming the key
    int 21h

    Go_left:  
        SetCursor gunX,gunY,0 ;moving the cursor to the old pos to delete the old figure
        dec gunX   
        mov ah,7  
        int 21h       
        jmp endd
    Go_right:   
        SetCursor gunX,gunY,0 
        inc gunX       
        mov ah,7  
        int 21h      
        jmp endd
    Go_up:   
     SetCursor gunX,gunY,0
        dec gunY                         
        mov ah,7  
        int 21h
        jmp endd
    Go_down: 
     SetCursor gunX,gunY,0
        inc gunY                      
        mov ah,7  
        int 21h
        jmp endd
endd:     
    PrintCharGraphics gunShape,Black,1 

endp DrawingGun

;-------Flying objects-------
FlyingObj proc near

    mov cx,62
lef:
    push cx

    DrawFilledRectangle test3,test4,test5,test6,LightGreen,LightGreen
    ;;Time Delay 1 tick delay (18.2/sec)
    mov bp, 43690
    mov si, 43690
    delay2:
    dec bp
    nop
    jnz delay2
    delay1:
    dec si
    cmp si,0    
    jnz delay1
    ; end delay
    DrawFilledRectangle test3,test4,test5,test6,Black,Black
    
    ;if not valid -1 in points and take the other user command
    
    pop cx
    ;inc test3
    inc test4
    ;inc test5
    inc test6
    dec CX
    jnz lef
    ;DrawFilledRectangle test3,test4,test5,test6,Purple,White
    ;DrawFilledRectangle test3,test4,test5,test6,Black,Black
    mov cx,62
    mov test3,93                   
    mov test4,30                   
    mov test5,120                   
    mov test6,70        

lef2:
    push cx
    DrawFilledRectangle test3,test4,test5,test6,LightCyan,LightCyan
    DrawFilledRectangle test3,test4,test5,test6,Black,Black
    pop cx
    inc test3
    ;inc test4
    inc test5
    ;inc test6
    dec CX
    jnz lef2
    
    ret
endp FlyingObj


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
        changeGraphicsmode
        call GameScreen
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
;-------Writing commands-------

WriteCommand proc
    mov CurrUser,1
    ;SetCursor UserCommand1Col,UserCommand1row,0
    ;ReadMessage UserCommand1
    ;UpperToLower UserCommand1
    ;call excCommand
    ;check if command is valid -> change in the registers

    ;if not valid -1 in points and take the other user command
    
    ;SetCursor UserCommand1Col,UserCommand1row,0     2 commands
    ;PrintMessage UserCommandSpaces
    
    mov CurrUser,2
    ;SetCursor UserCommand2Col,UserCommand2row,0
    ;ReadMessage UserCommand2
    ;UpperToLower UserCommand2
    ;call excCommand

    call FlyingObj

    ret
endp WriteCommand


;-------Pick Command-------
PickCommand proc
    pusha
    lea si, UserCommand1+2
    lea di, incCommand
    mov cx, 3
    REPE CMPSB
    cmp cx,0
    jne next
    
    INCAcc:
    pusha
    mov SI,offset UserCommand1+2
    mov DI,offset CurCommand
    mov cl,UserCommand1+1
    mov ch,0
    REP MOVSW;Copies the first 10 words from SI to DI
    popa

    ;excIncCommand 1
   
    
    next:
    popa
    
    ret
ENDP PickCommand


;-------Execute Command-------
excCommand proc
    
    pusha
    ;moving UserCommand1 into CurCommand
    mov SI,offset UserCommand1+2
    mov DI,offset CurCommand
    mov cl,UserCommand1+1
    mov ch,0
    REP MOVSB
    popa

    GetStringSize CurCommand,actualSizeCommand


    call GetCommand
    cmp found_cmd,0
    je bayz

 SetCursor 26,10,0
 PrintMessage Op_to_Execute


    ; jumping to found command
    CompareStrings Op_to_Execute,orCommand,4,OK
    cmp OK,1
    je or_loop

    ; if third is not space, cmd is wrong
    mov dl, 3
    cmp CurCommand+3,' '
    jne bayz

    call GetOperandOne
    call ValidateOp1
    cmp OK,0
    je bayz
    call GetOperandTwo
    call TypeOp
 SetCursor 26,12,0
 PrintMessage Operand2
   SetCursor 26,14,0
 PrintMessage Operand2Type


    CompareStrings Op_to_Execute,incCommand,4,OK
    cmp OK,1
    je inc_loop
    CompareStrings Op_to_Execute,decCommand,4,OK
    cmp OK,1
    je dec_loop
    CompareStrings Op_to_Execute,shlCommand,4,OK
    cmp OK,1
    je shl_loop
    CompareStrings Op_to_Execute,shrCommand,4,OK
    cmp OK,1
    je shr_loop
    CompareStrings Op_to_Execute,clcCommand,4,OK
    cmp OK,1
    je clc_loop
    CompareStrings Op_to_Execute,rorCommand,4,OK
    cmp OK,1
    je ror_loop
    CompareStrings Op_to_Execute,rolCommand,4,OK
    cmp OK,1
    je rol_loop
    CompareStrings Op_to_Execute,nopCommand,4,OK
    cmp OK,1
    je nop_loop
    CompareStrings Op_to_Execute,addCommand,4,OK
    cmp OK,1
    je add_loop
    CompareStrings Op_to_Execute,subCommand,4,OK
    cmp OK,1
    je sub_loop
    CompareStrings Op_to_Execute,adcCommand,4,OK
    cmp OK,1
    je adc_loop
    CompareStrings Op_to_Execute,sbbCommand,4,OK
    cmp OK,1
    je sbb_loop
    CompareStrings Op_to_Execute,xorCommand,4,OK
    cmp OK,1
    je xor_loop
    CompareStrings Op_to_Execute,andCommand,4,OK
    cmp OK,1
    je and_loop
    CompareStrings Op_to_Execute,movCommand,4,OK
    cmp OK,1
    je mov_loop
    CompareStrings Op_to_Execute,rclCommand,4,OK
    cmp OK,1
    je rcl_loop
    CompareStrings Op_to_Execute,rcrCommand,4,OK
    cmp OK,1
    je rcr_loop

inc_loop:
    isEmptyString Operand2,OK
    cmp OK,0
    je bayz
    call GetOperandValueUser2
    pusha
    mov ax,Operand1Value
    inc ax
    mov Operand1Value,ax
    popa
    call LoadOperandValueUser2
    jmp msh_bayz

dec_loop:
    isEmptyString Operand2,OK
    cmp OK,0
    je bayz
    call GetOperandValueUser2
    pusha
    mov ax,Operand1Value
    dec ax
    mov Operand1Value,ax
    popa
    call LoadOperandValueUser2
    jmp msh_bayz

shl_loop:
    cmp Operand2Type,4
    jne bayz
    cmp Operand1Type,0
    je bayz
    cmp Operand1Type,4
    je bayz
    cmp Operand1Type,5
    je bayz
    call GetOperandValueUser2
    pusha
    cmp cf2,0
    je zero_shl_loop
    STC
    jmp start_shl_loop
zero_shl_loop:
    CLC
start_shl_loop:
    mov ax,Operand1Value
     ;SetCursor 26,16,0
     ;PrintMessage Operand1Value
    AsciiToNumber Operand2,0,Operand2Value
     ;SetCursor 26,18,0
     ;PrintMessage Operand2Value
    mov cx,Operand2Value
    mov ch,0
    shl ax,cl
    mov Operand1Value,ax
    adc CheckCarry,0
    mov bl,CheckCarry
    mov CF2,bl
    mov CheckCarry,0
    popa
    call LoadOperandValueUser2
    jmp msh_bayz

shr_loop:
    cmp Operand2Type,4
    jne bayz
    cmp Operand1Type,0
    je bayz
    cmp Operand1Type,4
    je bayz
    cmp Operand1Type,5
    je bayz
    call GetOperandValueUser2
    pusha
    cmp cf2,0
    je zero_shr_loop
    STC
    jmp start_shr_loop
zero_shr_loop:
    CLC
start_shr_loop:
    mov ax,Operand1Value
     ;SetCursor 26,16,0
     ;PrintMessage Operand1Value
    AsciiToNumber Operand2,0,Operand2Value
     ;SetCursor 26,18,0
     ;PrintMessage Operand2Value
    mov cx,Operand2Value
    mov ch,0
    shr ax,cl
    mov Operand1Value,ax
    adc CheckCarry,0
    mov bl,CheckCarry
    mov CF2,bl
    mov CheckCarry,0
    popa
    call LoadOperandValueUser2
    jmp msh_bayz

clc_loop:
    mov CF2,0
    jmp msh_bayz

ror_loop:
    cmp Operand2Type,4
    jne bayz
    cmp Operand1Type,0
    je bayz
    cmp Operand1Type,4
    je bayz
    cmp Operand1Type,5
    je bayz
    call GetOperandValueUser2
    pusha
    cmp cf2,0
    je zero_ror_loop
    STC
    jmp start_ror_loop
zero_ror_loop:
    CLC
start_ror_loop:
    mov ax,Operand1Value
     ;SetCursor 26,16,0
     ;PrintMessage Operand1Value
    AsciiToNumber Operand2,0,Operand2Value
     ;SetCursor 26,18,0
     ;PrintMessage Operand2Value
    mov cx,Operand2Value
    mov ch,0
    ror ax,cl
    mov Operand1Value,ax
    adc CheckCarry,0
    mov bl,CheckCarry
    mov CF2,bl
    mov CheckCarry,0
    popa
    call LoadOperandValueUser2
    jmp msh_bayz

rol_loop:
    cmp Operand2Type,4
    jne bayz
    cmp Operand1Type,0
    je bayz
    cmp Operand1Type,4
    je bayz
    cmp Operand1Type,5
    je bayz
    call GetOperandValueUser2
    pusha
    cmp cf2,0
    je zero_rol_loop
    STC
    jmp start_rol_loop
zero_rol_loop:
    CLC
start_rol_loop:
    mov ax,Operand1Value
     ;SetCursor 26,16,0
     ;PrintMessage Operand1Value
    AsciiToNumber Operand2,0,Operand2Value
     ;SetCursor 26,18,0
     ;PrintMessage Operand2Value
    mov cx,Operand2Value
    mov ch,0
    rol ax,cl
    mov Operand1Value,ax
    adc CheckCarry,0
    mov bl,CheckCarry
    mov CF2,bl
    mov CheckCarry,0
    popa
    call LoadOperandValueUser2
    jmp msh_bayz

rcl_loop:
    cmp Operand2Type,4
    jne bayz
    cmp Operand1Type,0
    je bayz
    cmp Operand1Type,4
    je bayz
    cmp Operand1Type,5
    je bayz
    call GetOperandValueUser2
    pusha
    cmp cf2,0
    je zero_rcl_loop
    STC
    jmp start_rcl_loop
zero_rcl_loop:
    CLC
start_rcl_loop:
    mov ax,Operand1Value
     ;SetCursor 26,16,0
     ;PrintMessage Operand1Value
    AsciiToNumber Operand2,0,Operand2Value
     ;SetCursor 26,18,0
     ;PrintMessage Operand2Value
    mov cx,Operand2Value
    mov ch,0
    rcl ax,cl
    mov Operand1Value,ax
    adc CheckCarry,0
    mov bl,CheckCarry
    mov CF2,bl
    mov CheckCarry,0
    popa
    call LoadOperandValueUser2
    jmp msh_bayz

rcr_loop:
    cmp Operand2Type,4
    jne bayz
    cmp Operand1Type,0
    je bayz
    cmp Operand1Type,4
    je bayz
    cmp Operand1Type,5
    je bayz
    call GetOperandValueUser2
    pusha
    cmp cf2,0
    je zero_rcr_loop
    STC
    jmp start_rcr_loop
zero_rcr_loop:
    CLC
start_rcr_loop:
    mov ax,Operand1Value
     ;SetCursor 26,16,0
     ;PrintMessage Operand1Value
    AsciiToNumber Operand2,0,Operand2Value
     ;SetCursor 26,18,0
     ;PrintMessage Operand2Value
    mov cx,Operand2Value
    mov ch,0
    rcl ax,cl
    mov Operand1Value,ax
    adc CheckCarry,0
    mov bl,CheckCarry
    mov CF2,bl
    mov CheckCarry,0
    popa
    call LoadOperandValueUser2
    jmp msh_bayz

nop_loop:
    cmp Operand1Type,0
    jne bayz
    cmp Operand2Type,0
    jne bayz
    jmp msh_bayz

add_loop:
sub_loop:
adc_loop:
sbb_loop:

or_loop:
    cmp CurCommand+2,' '
    jne bayz

xor_loop:
and_loop:
mov_loop:



bayz:  
 SetCursor 15,20,0
 PrintMessage ChatStatusMSG1
msh_bayz:
RET
ENDP excCommand

;-------Get First Operand-------
GetOperandOne proc

    pusha
    ; indexing CurrCommand with si
    ; starting with 3 to get operands only
    mov OK,0
    mov si,2
    findLetter: ;  removes spaces
        inc si
        cmp si,actualSizeCommand
        je wrong
        cmp CurCommand[si],' '
    je findLetter

    mov di,0

mov_to_operand1:
    cmp CurCommand[si],' '
    je rest
    cmp CurCommand[si],','
    je rest
    cmp CurCommand[si],'$'
    je rest
    mov al,CurCommand[si]
    mov Operand1[di],al
    inc di
    inc si 
    jmp mov_to_operand1   
    rest:
    mov startOperand2,si
    mov OK,1
wrong:
    popa
RET
endp GetOperandOne


;-------Get Second Operand-------
GetOperandTwo proc
    pusha
    ; indexing CurrCommand with si
    ; starting with 3 to get operands only
    mov OK,0
    mov si,startOperand2
    dec si
    findLetter_op2: ;  removes spaces
        inc si
        cmp si,actualSizeCommand
        je wrong_op2
        cmp CurCommand[si],' '
    je findLetter_op2
    
    cmp CurCommand[si],','
    jne wrong_op2
    inc si

    mov di,0

    findLetter_op22: ;  removes spaces
        inc si
        cmp si,actualSizeCommand
        je wrong_op2
        cmp CurCommand[si],' '
    je findLetter_op22

mov_to_operand2:
    cmp CurCommand[si],' '
    je rest_op2
    cmp CurCommand[si],'$'
    je rest_op2
    mov al,CurCommand[si]
    mov Operand2[di],al
    inc di
    inc si 
    jmp mov_to_operand2   
    rest_op2:
    mov ok,1
wrong_op2:
    popa
RET
endp GetOperandTwo


;-------Get Command-------
GetCommand proc

      pusha
      ;compare Curr_Command with command at loop_index
      mov found_cmd,0
      mov SI,offset EmptyOp
      mov DI,offset Op_to_Execute
      mov cl,4
      mov ch,0
      REP MOVSB
      mov bx,0

compare_loop:
      lea si,incCommand[bx]
      lea di,CurCommand
      mov cx,4
      REPE CMPSB
      cmp cx,0
      je found
      add bx,4
      cmp bx,80
      je not_found
      jmp compare_loop

 found:    
      lea si,incCommand[bx]
      lea di,Op_to_Execute 
      mov cx,5
      rep MOVSB 
      mov found_cmd,1
      jmp finished    

 not_found:
     mov found_cmd,0   
     
finished:
     popa
ret
endp GetCommand


;-------Validate Operand 1-------
ValidateOp1 proc

      pusha
      ;compare Curr_Command with command at loop_index
      mov OK,0
      mov bx,0

compare_registers:
      lea si,AX_op[bx]
      lea di,Operand1
      mov cx,3
      REPE CMPSB
      cmp cx,0
      je found_op1
      add bx,3
      cmp bx,48
      je compare_based
      jmp compare_registers

compare_based:  
      lea si,AX_op[bx]
      lea di,Operand1
      mov cx,4
      REPE CMPSB
      cmp cx,0
      je found_op1
      add bx,5
      cmp bx,63
      je compare_memory
      jmp compare_based

compare_memory:
      lea si,AX_op[bx]
      lea di,Operand1
      mov cx,3
      REPE CMPSB
      cmp cx,0
      je found_op1
      add bx,4
      cmp bx,83
      je not_found_op1
      jmp compare_based

 found_op1:    
      mov OK,1
      jmp finished_op1    

 not_found_op1:
     mov OK,0   
     
finished_op1:
    popa
    ret
endp ValidateOp1


;------Get Type of Operand-------
;------0 -> false type-----------
;------1 -> register-8-----------
;------2 -> register-16----------
;------3 -> immediate------------
;------4 -> memory---------------
TypeOp proc

      pusha
    ;Operand 1:
    isEmptyString Operand1,OK
    cmp OK,1
    je false_op1
    CompareStrings Operand1,AX_op,3,OK
    cmp OK,1
    je reg16_op1
    CompareStrings Operand1,AL_op,3,OK
    cmp OK,1
    je reg8_op1
    CompareStrings Operand1,AH_op,3,OK
    cmp OK,1
    je reg8_op1
    CompareStrings Operand1,BX_op,3,OK
    cmp OK,1
    je reg16_op1
    CompareStrings Operand1,BL_op,3,OK
    cmp OK,1
    je reg8_op1
    CompareStrings Operand1,BH_op,3,OK
    cmp OK,1
    je reg8_op1
    CompareStrings Operand1,CX_op,3,OK
    cmp OK,1
    je reg16_op1
    CompareStrings Operand1,CL_op,3,OK
    cmp OK,1
    je reg8_op1
    CompareStrings Operand1,CH_op,3,OK
    cmp OK,1
    je reg8_op1
    CompareStrings Operand1,DX_op,3,OK
    cmp OK,1
    je reg16_op1
    CompareStrings Operand1,DL_op,3,OK
    cmp OK,1
    je reg8_op1
    CompareStrings Operand1,DH_op,3,OK
    cmp OK,1
    je reg8_op1
    CompareStrings Operand1,SI_op,3,OK
    cmp OK,1
    je reg16_op1
    CompareStrings Operand1,DI_op,3,OK
    cmp OK,1
    je reg16_op1
    CompareStrings Operand1,SP_op,3,OK
    cmp OK,1
    je reg16_op1
    CompareStrings Operand1,BP_op,3,OK
    cmp OK,1
    je reg16_op1
    CompareStrings Operand1,BX_op_idx,5,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,SI_op_idx,5,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,DI_op_idx,5,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,MEM0,4,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,MEM1,4,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,MEM2,4,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,MEM3,4,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,MEM4,4,OK
    cmp OK,1
    je mem_op1
    CheckImmediate Operand1, OK
    cmp OK,0
    je false_op1
    GetStringSize Operand1,OperandLength
    cmp OperandLength,3
    jae imm4_op1
    cmp OperandLength,0
    ja imm2_op1
    jmp false_op1

false_op1:
      mov Operand1Type,0
      jmp finished_typeOP
reg8_op1:
      mov Operand1Type,1
      jmp finished_typeOP
reg16_op1:
      mov Operand1Type,2
      jmp finished_typeOP
mem_op1:
      mov Operand1Type,3
      jmp finished_typeOP
imm2_op1:
      mov Operand1Type,4
      jmp finished_typeOP
imm4_op1:
      mov Operand1Type,5
      jmp finished_typeOP
          
finished_typeOP:
;Operand 2:
    isEmptyString Operand2,OK
    cmp OK,1
    je false_op2
    CompareStrings Operand2,AX_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand1,AL_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,AH_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,BX_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand1,BL_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,BH_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,CX_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand2,CL_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,CH_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,DX_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand2,DL_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,DH_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,SI_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand2,DI_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand2,SP_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand2,BP_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand2,BX_op_idx,5,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,SI_op_idx,5,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,DI_op_idx,5,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,MEM0,4,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,MEM1,4,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,MEM2,4,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,MEM3,4,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,MEM4,4,OK
    cmp OK,1
    je mem_op2
    CheckImmediate Operand2, OK
    cmp OK,0
    je false_op2
    GetStringSize Operand2,OperandLength
    cmp OperandLength,3
    jae imm4_op2
    cmp OperandLength,0
    ja imm2_op2
    jmp false_op2

false_op2:
      mov Operand2Type,0
      jmp finished_typeOP_2
reg8_op2:
      mov Operand2Type,1
      jmp finished_typeOP_2
reg16_op2:
      mov Operand2Type,2
      jmp finished_typeOP_2
mem_op2:
      mov Operand2Type,3
      jmp finished_typeOP_2
imm2_op2:
      mov Operand2Type,4
      jmp finished_typeOP_2
imm4_op2:
      mov Operand2Type,5
      jmp finished_typeOP_2
          
finished_typeOP_2:
    popa
    ret
endp TypeOp


;-------Get Value from Operand1 for User1 Registers-------
GetOperandValueUser1 proc

    pusha
    CompareStrings Operand1,AX_op,3,OK
    cmp OK,1
    je AXisOP
    CompareStrings Operand1,AL_op,3,OK
    cmp OK,1
    je ALisOP
    CompareStrings Operand1,AH_op,3,OK
    cmp OK,1
    je AHisOP
    CompareStrings Operand1,BX_op,3,OK
    cmp OK,1
    je BXisOP
    CompareStrings Operand1,BL_op,3,OK
    cmp OK,1
    je BLisOP
    CompareStrings Operand1,BH_op,3,OK
    cmp OK,1
    je BHisOP
    CompareStrings Operand1,CX_op,3,OK
    cmp OK,1
    je CXisOP
    CompareStrings Operand1,CL_op,3,OK
    cmp OK,1
    je CLisOP
    CompareStrings Operand1,CH_op,3,OK
    cmp OK,1
    je CHisOP
    CompareStrings Operand1,DX_op,3,OK
    cmp OK,1
    je DXisOP
    CompareStrings Operand1,DL_op,3,OK
    cmp OK,1
    je DLisOP
    CompareStrings Operand1,DH_op,3,OK
    cmp OK,1
    je DHisOP
    CompareStrings Operand1,SI_op,3,OK
    cmp OK,1
    je SIisOP
    CompareStrings Operand1,DI_op,3,OK
    cmp OK,1
    je DIisOP
    CompareStrings Operand1,SP_op,3,OK
    cmp OK,1
    je SPisOP
    CompareStrings Operand1,BP_op,3,OK
    cmp OK,1
    je BPisOP
    CompareStrings Operand1,BX_op_idx,5,OK
    cmp OK,1
    je BXidxisOP
    CompareStrings Operand1,SI_op_idx,5,OK
    cmp OK,1
    je SIidxisOP
    CompareStrings Operand1,DI_op_idx,5,OK
    cmp OK,1
    je DIidxisOP
 
 AXisOP:
       AsciiToNumber AX_Reg_Value1,0,Operand1Value
       jmp finished_LoadOperandValueUser1
 ALisOP:
 AHisOP:
 BXisOP:
 BLisOP:
 BHisOP:
 CXisOP:
 CLisOP:
 CHisOP:
 DXisOP:
 DLisOP:
 DHisOP:
 SIisOP:
 DIisOP:
 SPisOP:
 BPisOP:
 BXidxisOP:
 SIidxisOP:
 DIidxisOP:
 

     
finished_GetOperandValueUser1:
    popa
    ret
endp GetOperandValueUser1


;-------Get Value from Operand1 for User2 Registers-------
GetOperandValueUser2 proc

    pusha
    CompareStrings Operand1,AX_op,3,OK
    cmp OK,1
    je AXisOP2
    CompareStrings Operand1,AL_op,3,OK
    cmp OK,1
    je ALisOP2
    CompareStrings Operand1,AH_op,3,OK
    cmp OK,1
    je AHisOP2
    CompareStrings Operand1,BX_op,3,OK
    cmp OK,1
    je BXisOP2
    CompareStrings Operand1,BL_op,3,OK
    cmp OK,1
    je BLisOP2
    CompareStrings Operand1,BH_op,3,OK
    cmp OK,1
    je BHisOP2
    CompareStrings Operand1,CX_op,3,OK
    cmp OK,1
    je CXisOP2
    CompareStrings Operand1,CL_op,3,OK
    cmp OK,1
    je CLisOP2
    CompareStrings Operand1,CH_op,3,OK
    cmp OK,1
    je CHisOP2
    CompareStrings Operand1,DX_op,3,OK
    cmp OK,1
    je DXisOP2
    CompareStrings Operand1,DL_op,3,OK
    cmp OK,1
    je DLisOP2
    CompareStrings Operand1,DH_op,3,OK
    cmp OK,1
    je DHisOP2
    CompareStrings Operand1,SI_op,3,OK
    cmp OK,1
    je SIisOP2
    CompareStrings Operand1,DI_op,3,OK
    cmp OK,1
    je DIisOP2
    CompareStrings Operand1,SP_op,3,OK
    cmp OK,1
    je SPisOP2
    CompareStrings Operand1,BP_op,3,OK
    cmp OK,1
    je BPisOP2
    CompareStrings Operand1,BX_op_idx,5,OK
    cmp OK,1
    je BXidxisOP2
    CompareStrings Operand1,SI_op_idx,5,OK
    cmp OK,1
    je SIidxisOP2
    CompareStrings Operand1,DI_op_idx,5,OK
    cmp OK,1
    je DIidxisOP2
 
 AXisOP2:
 cmp CurrUser,2
 je user2_ax      
       AsciiToNumber AX_Reg_Value2,0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_ax:
       AsciiToNumber AX_Reg_Value1,0,Operand1Value
       jmp finished_GetOperandValueUser2 

ALisOP2:
cmp CurrUser,2
je user2_al 
        AsciiToNumber AX_Reg_Value2[2],0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_al:
       AsciiToNumber AX_Reg_Value1[2],0,Operand1Value
       jmp finished_GetOperandValueUser2

AHisOP2:

BXisOP2:
cmp CurrUser,2
je user2_bx 
       AsciiToNumber BX_Reg_Value2,0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_bx:
       AsciiToNumber BX_Reg_Value1,0,Operand1Value
       jmp finished_GetOperandValueUser2 

BLisOP2:
cmp CurrUser,2
je user2_bl 
       AsciiToNumber BX_Reg_Value2[2],0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_bl:
       AsciiToNumber BX_Reg_Value1[2],0,Operand1Value
       jmp finished_GetOperandValueUser2

BHisOP2:

CXisOP2:
cmp CurrUser,2
je user2_cx 
       AsciiToNumber CX_Reg_Value2,0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_cx:
       AsciiToNumber CX_Reg_Value1,0,Operand1Value
       jmp finished_GetOperandValueUser2 

CLisOP2:
cmp CurrUser,2
je user2_cl 
       AsciiToNumber CX_Reg_Value2[2],0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_cl:
       AsciiToNumber CX_Reg_Value1[2],0,Operand1Value
       jmp finished_GetOperandValueUser2 

CHisOP2:

DXisOP2:
cmp CurrUser,2
je user2_dx 
       AsciiToNumber DX_Reg_Value2,0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_dx:
       AsciiToNumber DX_Reg_Value1,0,Operand1Value
       jmp finished_GetOperandValueUser2 

DLisOP2:
cmp CurrUser,2
je user2_dl
       AsciiToNumber DX_Reg_Value2[2],0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_dl:
       AsciiToNumber DX_Reg_Value1[2],0,Operand1Value
       jmp finished_GetOperandValueUser2 

DHisOP2:

SIisOP2:
cmp CurrUser,2
je user2_si
       AsciiToNumber SI_Reg_Value2,0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_si:
       AsciiToNumber SI_Reg_Value1,0,Operand1Value
       jmp finished_GetOperandValueUser2 

DIisOP2:
cmp CurrUser,2
je user2_di
       AsciiToNumber DI_Reg_Value2,0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_di:
       AsciiToNumber DI_Reg_Value1,0,Operand1Value
       jmp finished_GetOperandValueUser2 

SPisOP2:
cmp CurrUser,2
je user2_sp
       AsciiToNumber SP_Reg_Value2,0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_sp:
       AsciiToNumber SP_Reg_Value1,0,Operand1Value
       jmp finished_GetOperandValueUser2 

BPisOP2:
cmp CurrUser,2
je user2_bp
       AsciiToNumber BP_Reg_Value2,0,Operand1Value
       jmp finished_GetOperandValueUser2
user2_bp:
       AsciiToNumber BP_Reg_Value1,0,Operand1Value
       jmp finished_GetOperandValueUser2 

BXidxisOP2:
SIidxisOP2:
DIidxisOP2:
 

     
finished_GetOperandValueUser2:
    popa
    ret
endp GetOperandValueUser2

;-------Load Value in Operand1 for User1 Registers-------
LoadOperandValueUser1 proc

    pusha
    CompareStrings Operand1,AX_op,3,OK
    cmp OK,1
    je AXisLoad
    CompareStrings Operand1,AL_op,3,OK
    cmp OK,1
    je ALisLoad
    CompareStrings Operand1,AH_op,3,OK
    cmp OK,1
    je AHisLoad
    CompareStrings Operand1,BX_op,3,OK
    cmp OK,1
    je BXisLoad
    CompareStrings Operand1,BL_op,3,OK
    cmp OK,1
    je BLisLoad
    CompareStrings Operand1,BH_op,3,OK
    cmp OK,1
    je BHisLoad
    CompareStrings Operand1,CX_op,3,OK
    cmp OK,1
    je CXisLoad
    CompareStrings Operand1,CL_op,3,OK
    cmp OK,1
    je CLisLoad
    CompareStrings Operand1,CH_op,3,OK
    cmp OK,1
    je CHisLoad
    CompareStrings Operand1,DX_op,3,OK
    cmp OK,1
    je DXisLoad
    CompareStrings Operand1,DL_op,3,OK
    cmp OK,1
    je DLisLoad
    CompareStrings Operand1,DH_op,3,OK
    cmp OK,1
    je DHisLoad
    CompareStrings Operand1,SI_op,3,OK
    cmp OK,1
    je SIisLoad
    CompareStrings Operand1,DI_op,3,OK
    cmp OK,1
    je DIisLoad
    CompareStrings Operand1,SP_op,3,OK
    cmp OK,1
    je SPisLoad
    CompareStrings Operand1,BP_op,3,OK
    cmp OK,1
    je BPisLoad
    CompareStrings Operand1,BX_op_idx,5,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,SI_op_idx,5,OK
    cmp OK,1
    je SIidxisLoad
    CompareStrings Operand1,DI_op_idx,5,OK
    cmp OK,1
    je DIidxisLoad
    jmp finished_LoadOperandValueUser1
 AXisLoad:
       NumbertoAscii4byte Operand1Value,AX_Reg_Value1
 ALisLoad:
 AHisLoad:
 BXisLoad:
 BLisLoad:
 BHisLoad:
 CXisLoad:
 CLisLoad:
 CHisLoad:
 DXisLoad:
 DLisLoad:
 DHisLoad:
 SIisLoad:
 DIisLoad:
 SPisLoad:
 BPisLoad:
 BXidxisLoad:
 SIidxisLoad:
 DIidxisLoad:
 

     
finished_LoadOperandValueUser1:
    call Refresh
    popa
    ret
endp LoadOperandValueUser1

;-------Load Value in Operand1 for User2 Registers-------
LoadOperandValueUser2 proc

    pusha
    CompareStrings Operand1,AX_op,3,OK
    cmp OK,1
    je AXisLoad2
    CompareStrings Operand1,AL_op,3,OK
    cmp OK,1
    je ALisLoad2
    CompareStrings Operand1,AH_op,3,OK
    cmp OK,1
    je AHisLoad2
    CompareStrings Operand1,BX_op,3,OK
    cmp OK,1
    je BXisLoad2
    CompareStrings Operand1,BL_op,3,OK
    cmp OK,1
    je BLisLoad2
    CompareStrings Operand1,BH_op,3,OK
    cmp OK,1
    je BHisLoad2
    CompareStrings Operand1,CX_op,3,OK
    cmp OK,1
    je CXisLoad2
    CompareStrings Operand1,CL_op,3,OK
    cmp OK,1
    je CLisLoad2
    CompareStrings Operand1,CH_op,3,OK
    cmp OK,1
    je CHisLoad2
    CompareStrings Operand1,DX_op,3,OK
    cmp OK,1
    je DXisLoad2
    CompareStrings Operand1,DL_op,3,OK
    cmp OK,1
    je DLisLoad2
    CompareStrings Operand1,DH_op,3,OK
    cmp OK,1
    je DHisLoad2
    CompareStrings Operand1,SI_op,3,OK
    cmp OK,1
    je SIisLoad2
    CompareStrings Operand1,DI_op,3,OK
    cmp OK,1
    je DIisLoad2
    CompareStrings Operand1,SP_op,3,OK
    cmp OK,1
    je SPisLoad2
    CompareStrings Operand1,BP_op,3,OK
    cmp OK,1
    je BPisLoad2
    CompareStrings Operand1,BX_op_idx,5,OK
    cmp OK,1
    je BXidxisLoad2
    CompareStrings Operand1,SI_op_idx,5,OK
    cmp OK,1
    je SIidxisLoad2
    CompareStrings Operand1,DI_op_idx,5,OK
    cmp OK,1
    je DIidxisLoad2
    jmp finished_LoadOperandValueUser2
 AXisLoad2:
       NumbertoAscii4byte Operand1Value,AX_Reg_Value2
 ALisLoad2:
 AHisLoad2:
 BXisLoad2:
 BLisLoad2:
 BHisLoad2:
 CXisLoad2:
 CLisLoad2:
 CHisLoad2:
 DXisLoad2:
 DLisLoad2:
 DHisLoad2:
 SIisLoad2:
 DIisLoad2:
 SPisLoad2:
 BPisLoad2:
 BXidxisLoad2:
 SIidxisLoad2:
 DIidxisLoad2:
 

     
finished_LoadOperandValueUser2:
    ;call Refresh
    call GameScreen
    popa
    ret
endp LoadOperandValueUser2

;-------Game Screen-------
GameScreen proc

    DrawLineGraphics WindowGStart,WindowGEndY,WindowGStart+9,0,Purple
    DrawLineGraphics WindowGStart,WindowGEndY,WindowGStart+78,0,Purple
    DrawLineGraphics WindowGStart,WindowGEndY,WindowGStart+92,0,Purple
    DrawLineGraphics WindowGStart,WindowGEndY,WindowGStart+183,0,Purple

    DrawLineGraphics WindowGStart+10, WindowGStart+92 ,WindowGStart+161 ,1, Purple
    DrawLineGraphics WindowGStart,WindowGStart+9,WindowGStart+148,1,Purple ; level line 1
    DrawLineGraphics WindowGStart,WindowGStart+9,WindowGStart+177,1,Purple ; level line 2
    DrawLineGraphics WindowGStart+93,WindowGStart+183,WindowGStart+148,1,Purple
    DrawLineGraphics WindowGStart+93,WindowGStart+183,WindowGStart+175,1,Purple

;Data Segment of user 1
    DrawLineGraphics WindowGStart+93,WindowGStart+169,WindowGStart+18,1,Purple
    DrawLineGraphics 0,18,105,0,Purple
    SetCursor 0,12,0
    PrintMessage DS00_Value1
    DrawLineGraphics 0,18,121,0,Purple
    SetCursor 0,14,0
    PrintMessage DS01_Value1
    DrawLineGraphics 0,18,137,0,Purple
    SetCursor 0,16,0
    PrintMessage DS02_Value1
    DrawLineGraphics 0,18,153,0,Purple
    SetCursor 0,18,0
    PrintMessage DS03_Value1
    DrawLineGraphics 0,18,169,0,Purple
    SetCursor 0,20,0
    PrintMessage DS04_Value1

    SetCursor 3,12,0
    PrintMessage DS00
    SetCursor 3,14,0
    PrintMessage DS01
    SetCursor 3,16,0
    PrintMessage DS02
    SetCursor 3,18,0
    PrintMessage DS03
    SetCursor 3,20,0
    PrintMessage DS04

    ;Data Segment of user 2
    DrawLineGraphics WindowGStart+93,WindowGStart+169,WindowGStart+302,1,Purple
    DrawLineGraphics 302,319,105,0,Purple
    SetCursor 38,12,0
    PrintMessage DS00_Value2
    DrawLineGraphics 302,319,121,0,Purple
    SetCursor 38,14,0
    PrintMessage DS01_Value2
    DrawLineGraphics 302,319,137,0,Purple
    SetCursor 38,16,0
    PrintMessage DS02_Value2
    DrawLineGraphics 302,319,153,0,Purple
    SetCursor 38,18,0
    PrintMessage DS03_Value2
    DrawLineGraphics 302,319,169,0,Purple
    SetCursor 38,20,0
    PrintMessage DS04_Value2

    SetCursor 36,12,0
    PrintMessage DS00
    SetCursor 36,14,0
    PrintMessage DS01
    SetCursor 36,16,0
    PrintMessage DS02
    SetCursor 36,18,0
    PrintMessage DS03
    SetCursor 36,20,0
    PrintMessage DS04

;----------End of Data Segment---------

    DrawRegisters 15,40 ;MACROO
    DrawRegisters 15,85

    DrawRegisters 15,200 ;MACROO
    DrawRegisters 15,245

    DrawCirc 162,106,9,LightGreen
    DrawCirc 162,128,9,LightRed
    DrawCirc 162,149,9,LightCyan
    DrawCirc 162,172,9,Yellow

    SetCursor 19,0,0
    PrintMessage Levelmsg
    ;PrintMessage Level
    SetCursor 2,2,0
    PrintMessage AX_Reg
    SetCursor 2,4,0
    PrintMessage BX_Reg
    SetCursor 2,6,0
    PrintMessage CX_Reg
    SetCursor 2,8,0
    PrintMessage DX_Reg
    SetCursor 17,2,0
    PrintMessage SI_Reg
    SetCursor 17,4,0
    PrintMessage DI_Reg
    SetCursor 17,6,0
    PrintMessage SP_Reg
    SetCursor 17,8,0
    PrintMessage BP_Reg

    SetCursor 22,2,0
    PrintMessage AX_Reg
    SetCursor 22,4,0
    PrintMessage BX_Reg
    SetCursor 22,6,0
    PrintMessage CX_Reg
    SetCursor 22,8,0
    PrintMessage DX_Reg
    SetCursor 37,2,0
    PrintMessage SI_Reg
    SetCursor 37,4,0
    PrintMessage DI_Reg
    SetCursor 37,6,0
    PrintMessage SP_Reg
    SetCursor 37,8,0
    PrintMessage BP_Reg

    ;setting the values of registers to 0000

    SetCursor 6,2,0
    PrintMessage AX_Reg_Value1
    SetCursor 6,4,0
    PrintMessage BX_Reg_Value1
    SetCursor 6,6,0
    PrintMessage CX_Reg_Value1
    SetCursor 6,8,0
    PrintMessage DX_Reg_Value1
    SetCursor 11,2,0
    PrintMessage SI_Reg_Value1
    SetCursor 11,4,0
    PrintMessage DI_Reg_Value1
    SetCursor 11,6,0
    PrintMessage SP_Reg_Value1
    SetCursor 11,8,0
    PrintMessage BP_Reg_Value1

    SetCursor 26,2,0
    PrintMessage AX_Reg_Value2
    SetCursor 26,4,0
    PrintMessage BX_Reg_Value2
    SetCursor 26,6,0
    PrintMessage CX_Reg_Value2
    SetCursor 26,8,0
    PrintMessage DX_Reg_Value2
    SetCursor 31,2,0
    PrintMessage SI_Reg_Value2
    SetCursor 31,4,0
    PrintMessage DI_Reg_Value2
    SetCursor 31,6,0
    PrintMessage SP_Reg_Value2
    SetCursor 31,8,0
    PrintMessage BP_Reg_Value2

    ;Name of the Users to Print it at the Top for the IntialPoints
    
    SetCursor 0,0,0
    PrintMessage User1Name+2
    SetCursor User1Name+1,0,0
    PrintMessage Semicolon
    Set4Dig IntialPoints1,IP1
    PrintMessage IP1


    SetCursor 23,0,0
    PrintMessage User2Name+2
    pusha
    mov al, [User2Name+1]
    add al,23
    SetCursor al,0,0
    PrintMessage Semicolon
    popa
    Set4Dig IntialPoints2,IP2
    PrintMessage IP2

    ;Print the Names for the chat Mode
    SetCursor 0,23,0
    PrintMessage User1Name+2
    SetCursor User1Name+1,23,0
    PrintMessage Semicolon
    SetCursor 0,24,0
    PrintMessage User2Name+2
    SetCursor User2Name+1,24,0
    PrintMessage Semicolon
    Call WriteCommand
    


    ret
GameScreen endp


;--------Refresh----------
Refresh proc
    SetCursor 6,2,0
    PrintMessage AX_Reg_Value1
    SetCursor 6,4,0
    PrintMessage BX_Reg_Value1
    SetCursor 6,6,0
    PrintMessage CX_Reg_Value1
    SetCursor 6,8,0
    PrintMessage DX_Reg_Value1
    SetCursor 11,2,0
    PrintMessage SI_Reg_Value1
    SetCursor 11,4,0
    PrintMessage DI_Reg_Value1
    SetCursor 11,6,0
    PrintMessage SP_Reg_Value1
    SetCursor 11,8,0
    PrintMessage BP_Reg_Value1

    SetCursor 26,2,0
    PrintMessage AX_Reg_Value2
    SetCursor 26,4,0
    PrintMessage BX_Reg_Value2
    SetCursor 26,6,0
    PrintMessage CX_Reg_Value2
    SetCursor 26,8,0
    PrintMessage DX_Reg_Value2
    SetCursor 31,2,0
    PrintMessage SI_Reg_Value2
    SetCursor 31,4,0
    PrintMessage DI_Reg_Value2
    SetCursor 31,6,0
    PrintMessage SP_Reg_Value2
    SetCursor 31,8,0
    PrintMessage BP_Reg_Value2

    SetCursor 3,12,0
    PrintMessage DS00
    SetCursor 3,14,0
    PrintMessage DS01
    SetCursor 3,16,0
    PrintMessage DS02
    SetCursor 3,18,0
    PrintMessage DS03
    SetCursor 3,20,0
    PrintMessage DS04

    SetCursor 36,12,0
    PrintMessage DS00
    SetCursor 36,14,0
    PrintMessage DS01
    SetCursor 36,16,0
    PrintMessage DS02
    SetCursor 36,18,0
    PrintMessage DS03
    SetCursor 36,20,0
    PrintMessage DS04
     ret
Refresh endp   


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
    mov al,CircColor

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