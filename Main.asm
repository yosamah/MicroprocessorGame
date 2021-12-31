;-----------بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ------------;

;-----------------MACROS-----------------

;-------Debug------
Debug macro charDebug
    SetCursor 10,10,0
    PrintCharGraphics charDebug, White,1
endm Debug


;-------Empty the string-------
EmptyTheString macro string2,size
local myLoop
pusha
    ;mov SI,offset string1
    ;mov DI,offset string2
    ;mov cl,size
    ;mov ch,0
    ;REP MOVSB
    mov si, offset string2
    mov cl,size
    mov ch,0
    myLoop:
        mov [si], '$'
        inc si
        dec cx
        cmp cx, 0
    jnz myLoop
               
    ;mov si, offset string2
    ;mov cl,size
    ;mov ch,0
    ;myLoop:
    ;    mov [si], '$'
    ;    inc si
    ;    dec cx
    ;    cmp cx, 0
    ;jnz myLoop
   
popa
endm EmptyTheString

;------PUT ZERO IN ALL REGISTERS--------------
;------FOR START GAME AND POWER UP------------
;------0 for all registers and data segment---
ZeroALL macro user
LOCAL user_2_zeroing,user_1_zeroing,ending_zeroall
    pusha
    mov al,user
    cmp al,2 
    je user_2_zeroing
    cmp al,1
    je user_1_zeroing
    MoveString2Bytes ZerosMSG,DS00_Value1
    MoveString2Bytes ZerosMSG,DS00_Value2
    MoveString2Bytes ZerosMSG,DS01_Value1
    MoveString2Bytes ZerosMSG,DS01_Value2
    MoveString2Bytes ZerosMSG,DS02_Value1
    MoveString2Bytes ZerosMSG,DS02_Value2
    MoveString2Bytes ZerosMSG,DS03_Value1
    MoveString2Bytes ZerosMSG,DS03_Value2
    MoveString2Bytes ZerosMSG,DS04_Value1
    MoveString2Bytes ZerosMSG,DS04_Value2

user_1_zeroing:
    MoveString4Bytes ZerosMSG,AX_Reg_Value1
    UpdateSmallReg AX_Reg_Value1,AH_Reg_Value1,AL_Reg_Value1

    MoveString4Bytes ZerosMSG,BX_Reg_Value1
    UpdateSmallReg BX_Reg_Value1,BH_Reg_Value1,BL_Reg_Value1

    MoveString4Bytes ZerosMSG,CX_Reg_Value1
    UpdateSmallReg CX_Reg_Value1,CH_Reg_Value1,CL_Reg_Value1

    MoveString4Bytes ZerosMSG,DX_Reg_Value1
    UpdateSmallReg DX_Reg_Value1,DH_Reg_Value1,DL_Reg_Value1

    MoveString4Bytes ZerosMSG,SI_Reg_Value1
    MoveString4Bytes ZerosMSG,DI_Reg_Value1
    MoveString4Bytes ZerosMSG,BP_Reg_Value1
    MoveString4Bytes ZerosMSG,SP_Reg_Value1
    cmp al, 1
    je ending_zeroall

user_2_zeroing:
    MoveString4Bytes ZerosMSG,AX_Reg_Value2
    UpdateSmallReg AX_Reg_Value2,AH_Reg_Value2,AL_Reg_Value2

    MoveString4Bytes ZerosMSG,BX_Reg_Value2
    UpdateSmallReg BX_Reg_Value2,BH_Reg_Value2,BL_Reg_Value2

    MoveString4Bytes ZerosMSG,CX_Reg_Value2
    UpdateSmallReg CX_Reg_Value2,CH_Reg_Value2,CL_Reg_Value2

    MoveString4Bytes ZerosMSG,DX_Reg_Value2
    UpdateSmallReg DX_Reg_Value2,DH_Reg_Value2,DL_Reg_Value2

    MoveString4Bytes ZerosMSG,SI_Reg_Value2
    MoveString4Bytes ZerosMSG,DI_Reg_Value2
    MoveString4Bytes ZerosMSG,BP_Reg_Value2
    MoveString4Bytes ZerosMSG,SP_Reg_Value2
    

 ending_zeroall:   
    popa
endm ZeroALL

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

;-------MOVE STRING 2 BYTES-------
MoveString2Bytes Macro  source,dest
pusha
    mov al,  source[0]
    mov dest[0], al
    mov al,  source[1]
    mov dest[1], al
popa
endm MoveString2Bytes

;-------MOVE STRING 4 BYTES-------
MoveString4Bytes Macro  source,dest
pusha
    mov al,  source[0]
    mov dest[0], al
    mov al,  source[1]
    mov dest[1], al
    mov al,  source[2]
    mov dest[2], al
    mov al,  source[3]
    mov dest[3], al
popa
endm MoveString4Bytes


;-------Update small registers-------
UpdateSmallReg Macro  regX, regH, regL
pusha
    mov al,  regX[0]
    mov regH[0], al
    mov al,  regX[1]
    mov regH[1], al
    mov al,  regX[2]
    mov regL[0], al
    mov al,  regX[3]
    mov regL[1], al
popa
endm UpdateSmallReg

;-------Update big registers-------
;;;Called when we change AL;;; 
UpdateBigRegL Macro  regX, regL
pusha
    mov al,  regL[0]
    mov regX[2], al
    mov al,  regL[1]
    mov regX[3], al
popa
endm UpdateBigRegL

;-------Update big registers-------
UpdateBigRegH Macro  regX, regH
pusha
    mov al,  regH[0]
    mov regX[0], al
    mov al,  regH[1]
    mov regX[1], al
popa
endm UpdateBigRegH


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
   cmp Operand[si],'a'
   jb end
   cmp Operand[si],'f'
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
;;;If u know the size send it in "val" 
;;;if not it automatically calculates size and send 0 in "val"
AsciiToNumber MACRO current,val,answer
LOCAL looping,rest,setSize
    
    ;2 for al - 2 bytes
    ;0 for ax - 4 bytes
    pusha
    mov ax,val
    cmp ax,2
    je setSize
    GetStringSize current,StringSize
    mov si,StringSize
    mov bx,0
    mov cx,1 
    jmp looping

setSize:
    mov bx,0
    mov cx,1 
    mov si, 2

looping:
    mov ah,0
    mov al,current[si-1]
    sub al,30h
    cmp current[si-1],'a'
    jb rest
    sub al,27h
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
    mov al,byte ptr current
    mov ah,0
    div cl
    mov byte ptr current,ah 
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

;-------Read character-------
ReadChar MACRO
    mov ah,7
    int 21h
endm ReadChar

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


;--------Reading forbidden character from the user----------
ReadForbidden MACRO Forbidden
    LOCAL loop_number_main
    LOCAL invalidcharacter
    LOCAL forbiddencomplete 
pusha
    loop_number_main:  
    PrintMessage ForbiddenMSG     

    ReadMessage Forbidden
    UpperToLower Forbidden
    mov al, Forbidden+2

    cmp al,30h  ; check if input character is less then 0, 
    jl invalidcharacter 
    cmp al,39h  ; check if input character is great then 9
    jbe forbiddencomplete
    cmp al,'a'
    jb invalidcharacter
    cmp al,'z'
    ja invalidcharacter     
    jmp forbiddencomplete
invalidcharacter:
    mov ah,09h 
    lea dx, messageinvalidcharacter   
    int 21h     
    
    jmp loop_number_main           
        
forbiddencomplete: 
popa
ENDM ReadForbidden

;--------Reading Command and Validating It--------
ReadCommand MACRO UserCommand,UserCommandCol,UserCommandrow,Forbidden
LOCAL getting_command,checking,found_forbidden,ending_readcommand
pusha
    mov ok,0
    getting_command:
    SetCursor UserCommandCol,UserCommandrow,0
    ReadMessage UserCommand
    UpperToLower UserCommand
    mov si,offset UserCommand+2
    mov al, Forbidden
    checking:
    cmp [si],'$'
    je ending_readcommand
    cmp [si], al 
    je found_forbidden
    inc si
    jmp checking
found_forbidden:
    SetCursor UserCommandCol,UserCommandrow,0
    PrintMessage ForbiddenGameMSG
    push ax
    mov ah,0
    int 16h
    pop ax
    SetCursor UserCommandCol,UserCommandrow,0
    PrintMessage UserCommandSpaces
    EmptyTheString UserCommand+2,12
    jmp getting_command

ending_readcommand:

popa
ENDM ReadForbidden

;--------Draw pixel----------
DrawPixel Macro row,col,color

    pusha
    mov cx,col
    mov dx,row
    mov al,color
    mov ah,0ch
    int 10h 
    popa

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
;--------Draw rectangle----------
DrawRectangle Macro x1,y1,x2,y2,color

    DrawLineGraphics y1,y2,x1,0,color
    DrawLineGraphics y1,y2,x2,0,color
    DrawLineGraphics x1,x2,y1,1,color
    DrawLineGraphics x1,x2,y2,1,color

ENDM DrawRectangle
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

;--------Set 1 Digits----------
Set1Dig Macro IntialPoints,IntialPoints_Meg
    pusha
    mov al,IntialPoints

    add al,30h
    mov IntialPoints_Meg[0],al

    popa
ENDM Set1Dig


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


;--------Set Brush----------
SetBrush Macro realSize, Color

    mov ah,09
    mov bl, Color
    mov cx, realSize
    int 10h

endm SetBrush

;--------Clear command window----------
CLCWindow Macro
    pusha
    lea si , UserCommand1+2
    lea di , UserCommandEmpty+2
    mov cx , 12
    REP movSB
    SetCursor 0,10,0 
    PrintMessage UserCommandEmpty+2
    popa
ENDM CLCWindow

;-----------Draw Player-----------
DrawPlayer Macro
    SetCursor ssX,ssY,0
    PrintMessage spaceship
ENDM DrawPlayer
;-----------Update Player position-----------
UpdatePlayer Macro
    SetCursor ssX,ssY,0
    PrintMessage blank
ENDM UpdatePlayer
;----------Store the input of the keyboard--------
GetKeyPressed Macro
    ;which key is pressed "AL = ASCII char" 
    mov ah,0
    int 16h
ENDM GetKeyPressed
;--------Draw bullet/object--------
Drawbullet Macro col,Row,size,color
    Local bullet
    pusha
    mov cx ,col
    mov dx ,Row

    bullet:
    DrawPixel dx,cx,color
    
    inc cx
    mov ax ,cx
    sub ax ,col
    cmp ax ,size
    jng bullet
    mov cx , col
    inc dx
    mov ax ,dx
    sub ax ,Row
    cmp ax ,size
    jng bullet
    popa

ENDM Drawbullet
;------Check Collision------
Collison Macro
    Local True,checkColRange,false,Done,TaniCol
    pusha
    ;kda bn-check lw 3la nafs el row tyb lw nfs el row bs msh nafs range el coloum nsibooo!!!! akid la yb2a bos taht
    mov ax, bullet_Row
    add ax, bulletsize
    mov bx, objX
    add bx, objR+4
    cmp ax, bx
    jz checkColRange
    jmp false
    ;Range el col yalaaaaa
checkColRange:
    mov ax, bullet_col
    mov bx, objY
    add bx, objR+2
    cmp ax, bx
    jle TaniCol
    jmp false
TaniCol:
    mov ax, bullet_col
    mov bx, objY
    sub bx, objR+4
    cmp ax, bx
    jae True
jmp false
    
True:           ;mbrok ya m3alm
    mov scored ,1
    jmp Done
false:
    mov scored ,0

Done:
    popa
ENDM Collison
;------Bullet Action------
BulletAction Macro
    Local Check,Miss,MabrokKsabtPoint,End

    pusha
    mov si,bullet_Row
check:
    SystemTime
    cmp dl, Time
    je Check
    mov Time ,dl

    ;check if the bullet hit any object
    Collison
    cmp scored ,1
    jz MabrokKsabtPoint

    cmp bullet_Row,95
    jbe miss
    Drawbullet bullet_col,bullet_Row,bulletsize,black
    dec bullet_Row

    ;check if the bullet hit any object
    Collison
    cmp scored ,1
    jz MabrokKsabtPoint

    cmp bullet_Row,95
    jbe miss
    Drawbullet bullet_col,bullet_Row,bulletsize,White

    jmp check
miss:
    Drawbullet bullet_col,bullet_Row,bulletsize,black
    mov bullet_Row,si
    jmp End
     
MabrokKsabtPoint:
    Drawbullet bullet_col,bullet_Row,bulletsize,black
    mov bullet_Row,si

    inc RHit_value
    Set1Dig RHit_value,RHit
    SetCursor 20,16,0
    PrintMessage RHit

End:
    popa
ENDM BulletAction
;-------Get system Time-------
;after calling this macro the "CH = hour" , "CL = Minute" , "DH = Seconds" , "DL = 1:100 Seconds"
SystemTime Macro
    mov ah , 2ch
    int 21h
ENDM SystemTime

;------Flying Object-------
FlyingObj Macro 
    LOCAL drawing,KmanMaraa
pusha
mov di,objY

drawing:
    SystemTime
    cmp dl, Time
    je drawing
    mov Time ,dl
    cmp objY,143
    jz kmanMaraa
    Drawbullet objY,objX,objR,black
    inc objY
    cmp objY,143
    jz KmanMaraa
    Drawbullet objY,objX,objR,objColor
    jmp drawing

KmanMaraa:
    mov objY,di
    jmp drawing
popa
ENDM FlyingObj

;------Draw SpaceShip------
DrawSpaceShip Macro color
    Local T3alaTani
    mov cx ,sscol
    mov dx ,ssRow

    T3alaTani:
    DrawPixel dx,cx,color
    pusha
    inc cx
    mov ax ,cx
    sub ax ,ssCol
    cmp ax ,spaceship_width
    jng T3alaTani
    mov cx , ssCol
    inc dx
    mov ax ,dx
    sub ax ,ssRow
    cmp ax ,spaceship_height
    jng T3alaTani
    popa

    
ENDM DrawSpaceShip
;--------Ship Action---------
ShipAction Macro
    Local GameLoop,ExitGame,MoveUp,MoveDown,MoveLeft,MoveRight

    DrawSpaceShip White
GameLoop:
    GetKeyPressed
    mov move,al

    cmp move, 'x'
    je ExitGame

    cmp move, 'w'
    je MoveUp

    cmp move, 's'
    je MoveDown

    cmp move, 'a'
    je MoveLeft

    cmp move, 'd'
    je MoveRight

    cmp move ,' '
    je Hit

MoveUp:
    cmp ssRow,128           ;upper limit
    jz GameLoop
    DrawSpaceShip black
    Dec ssRow
    dec bullet_Row
    DrawSpaceShip White
    jmp GameLoop
MoveDown:
    cmp ssRow,168           ;lovwer limit
    jz GameLoop
    DrawSpaceShip black
    inc ssRow
    inc bullet_Row
    DrawSpaceShip White
    jmp GameLoop
MoveLeft:
    cmp ssCol,32            ;left limit
    jz GameLoop
    DrawSpaceShip black 
    Dec ssCol
    dec bullet_col
    DrawSpaceShip White
    jmp GameLoop
MoveRight:
    cmp ssCol,136           ;left limit
    jz GameLoop
    DrawSpaceShip black
    inc ssCol
    inc bullet_col
    DrawSpaceShip White
    jmp GameLoop
Hit:
    BulletAction
    jmp GameLoop

ExitGame:
    mov GameEnd,1

ENDM ShipAction

;--------Main menu----------
MainMenu  MACRO 
    
    changeTextmode  
    WelcomeText
    ;Get Info  of user1 
    GetUserName User1Name
    ReadNumber IntialPoints1
    ReadForbidden Forbidden2
    call GetEnter

    ;Get Info  of user2 
    GetUserName User2Name
    ReadNumber IntialPoints2
    ReadForbidden Forbidden1
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

Winner                  db 0

User1                   db 'USER1$'
User1Name               DB 12,?,12 DUP('$') , '$'
realSize1               db ?
IntialPoints1           dw ?
IP1                     db '0000$'  ;IntialPoints1 as a message

Forbidden1 LABEL byte
Forbidden1Size          db 2
Forbidden1ActualSize    db ?
Forbidden1Data          db 2 DUP('$') ,'$'
   
User2                   db 'USER2$'
User2Name               DB 12,?,12 DUP('$') , '$'
realSize2               db ?
IntialPoints2           dw ?
IP2                     db '0000$' ;IntialPoints2 as a message 
Forbidden2 LABEL byte
Forbidden2Size          db 2
Forbidden2ActualSize    db ?
Forbidden2Data          db 2 DUP('$') ,'$'

MinIP                   dw ?       ;Minimum of IntialPoints
    
EnterName               db 'Please enter your name:',10, 13, '$'
    
InitialPointsMSG        db 10,13,'Initial points:',10,13, '$'
PressEnter              db 10,13,'Press ENTER to continue$'
ForbiddenMSG            db 'Forbidden Character:',10,13, '$'  
ForbiddenGameMSG        db 'Forbid-Press Key', '$'

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

;--------Winner Screen Variables--------
WinnerScreenMSG1         db 3,14,2,' The winner is User 1 ',3,14,2,'$'
WinnerScreenMSG2         db 3,14,2,' The winner is User 2 ',3,14,2,'$'
WinnerVariable           db '105E$'

;--------Level Screen Variables---------
LevelInputMSG           db 'Enter Level',10,13, '$'
LevelVariable           db 3,?,2 DUP('$') ,'$'
LevelundefinedMsg       db 'Level should be 1 or 2 $'

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
AH_Reg_Value1           db '00', '$'
AL_Reg_Value1           db '00', '$'
BX_Reg_Value1           db '0000', '$'
BH_Reg_Value1           db '00', '$'
BL_Reg_Value1           db '00', '$'
CX_Reg_Value1           db '0000', '$'
CH_Reg_Value1           db '00', '$'
CL_Reg_Value1           db '00', '$'
DX_Reg_Value1           db '0000', '$'
DH_Reg_Value1           db '00', '$'
DL_Reg_Value1           db '00', '$'
SI_Reg_Value1           db '0000', '$'
DI_Reg_Value1           db '0000', '$'
SP_Reg_Value1           db '0000', '$'
BP_Reg_Value1           db '0000', '$'

AX_Reg_Value2           db '0000', '$'
AH_Reg_Value2           db '00', '$'
AL_Reg_Value2           db '00', '$'
BX_Reg_Value2           db '0000', '$'
BH_Reg_Value2           db '00', '$'
BL_Reg_Value2           db '00', '$'
CX_Reg_Value2           db '0000', '$'
CH_Reg_Value2           db '00', '$'
CL_Reg_Value2           db '00', '$'
DX_Reg_Value2           db '0000', '$'
DH_Reg_Value2           db '00', '$'
DL_Reg_Value2           db '00', '$'
SI_Reg_Value2           db '0000', '$'
DI_Reg_Value2           db '0000', '$'
SP_Reg_Value2           db '0000', '$'
BP_Reg_Value2           db '0000', '$'

CF1                     db 0
CF2                     db 0
CheckCarry              db 0

ClearCommandWindow      db '           ', '$' 
;----------Data Segment Variables----------
DS00                    db '0', '$'
DS01                    db '1', '$'
DS02                    db '2', '$'
DS03                    db '3', '$'
DS04                    db '4', '$'

DS00_Value1             db '00', '$'
DS01_Value1             db '00', '$'
DS02_Value1             db '00', '$'
DS03_Value1             db '00', '$'
DS04_Value1             db '00', '$'

DS00_Value2             db '00', '$'
DS01_Value2             db '00', '$'
DS02_Value2             db '00', '$'
DS03_Value2             db '00', '$'
DS04_Value2             db '00', '$'

ZerosMSG                  db '0000', '$'

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
orCommand               db 'or $'
mulCommand              db 'mul$'
divCommand              db 'div$'
pushCommand             db 'push$'

found_cmd               db 0
Op_to_Execute           db 8 dup('$')
EmptyOp                 db 5 dup('$')
OK                      db ?
OperandLength           dw ?
Operand1                db 7 dup('$')
Operand1Type            db 0, '$'
Operand1Value           dw ?, '$'
startOperand2           dw ?, '$'
Operand2                db 7 dup('$')
Operand2Type            db 0, '$'
Operand2Value           dw ?, '$'

Operand1TypeInMemory    db ?, '$'
Operand2TypeInMemory    db ?, '$'

Operand1TypeInMemoryAs  db ?, '$'

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

UserCommandEmpty        db 14,?,14 dup('$') 


UserCommand1 LABEL byte
UserCommand1Size        db 14
UserCommand1ActualSize  db ?
UserCommand1Data        db 14 dup('$') 

UserCommand2 LABEL byte
UserCommand2Size        db 14
UserCommand2ActualSize  db ?
UserCommand2Data        db 14 dup('$') 

;UserCommand2            db 14,?,14 dup('$')

EmptyString12          db 12 dup('$')
EmptyString6           db 6 dup('$')


UserCommandSpaces       db 17 dup(' '),'$'


UserCommand1Col         db 0
UserCommand1row         db 10

UserCommand2Col         db 21
UserCommand2row         db 10

CurCommand              db 14 dup('$')
actualSizeCommand       dw ? , '$'
CurrUser                db ? , '$'
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

;------Game-----
spaceship_height        dw 3
spaceship_width         dw 9
Blank                   db ' ' , '$'
ssRow                   dw 168
ssCol                   dw 80

move                    db ?
GameEnd                 db 0

bulletsize              dw 2
bullet_Row              dw 165
bullet_col              dw 83    
Time                    db 0

GHit                    db '0', '$' 
RHit                    db '0', '$'
CHIt                    db '0', '$'
YHit                    db '0', '$'
GHit_value              db 0 
RHit_value              db 0
CHIt_value              db 0
YHit_value              db 0

objR                    dw 4
objX                   dw 95
objY                   dw 35
objColor               db 0ah


scored                  db 0
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

Game Proc

GameLoop:
    SystemTime
    cmp dl, Time
    je GameLoop
    mov Time ,dl

mov di,objY

    cmp objY,143
    jz kmanMaraa
    Drawbullet objY,objX,objR,black
    inc objY
    cmp objY,143
    jz KmanMaraa
    Drawbullet objY,objX,objR,objColor
    jmp GameLoop

KmanMaraa:
    mov objY,di
    jmp GameLoop
Drawbullet objY,objX,objR,objColor

DrawSpaceShip White

    GetKeyPressed
    mov move,al

    cmp move, 'x'
    je ExitGame

    cmp move, 'w'
    je MoveUp

    cmp move, 's'
    je MoveDown

    cmp move, 'a'
    je MoveLeft

    cmp move, 'd'
    je MoveRight

    cmp move ,' '
    je Hit

MoveUp:
    cmp ssRow,128           ;upper limit
    jz GameLoop
    DrawSpaceShip black
    Dec ssRow
    dec bullet_Row
    DrawSpaceShip White
    jmp GameLoop
MoveDown:
    cmp ssRow,168           ;lovwer limit
    jz GameLoop
    DrawSpaceShip black
    inc ssRow
    inc bullet_Row
    DrawSpaceShip White
    jmp GameLoop
MoveLeft:
    cmp ssCol,32            ;left limit
    jz GameLoop
    DrawSpaceShip black 
    Dec ssCol
    dec bullet_col
    DrawSpaceShip White
    jmp GameLoop
MoveRight:
    cmp ssCol,136           ;left limit
    jz GameLoop
    DrawSpaceShip black
    inc ssCol
    inc bullet_col
    DrawSpaceShip White
    jmp GameLoop
Hit:
    BulletAction
    jmp GameLoop

ExitGame:
    ret
ENDP Game


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
        call LevelScreen
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


;-------Level Screen-------
LevelScreen proc near
    pusha
    changeTextmode
    ClearScreen WindowStart,WindowStart,WindowEndX,WindowEndY,0
starting_levelscreen:
    SetCursor 0,10,0
    PrintMessage LevelInputMSG
    ReadMessage LevelVariable
    cmp LevelVariable+2,'1'
    je ending_levelscreen
    cmp LevelVariable+2,'2'
    je ending_levelscreen
    SetCursor 0,11,0
    PrintMessage UserCommandSpaces
    SetCursor 0, 21, 0
    PrintMessage LevelundefinedMsg
    jmp starting_levelscreen
ending_levelscreen:
    call GetEnter
    popa
    RET
endp LevelScreen

;-------Winner Screen-------
WinnerScreen proc near
    pusha
    changeTextmode
    ClearScreen WindowStart,WindowStart,WindowEndX,WindowEndY,0
    cmp winner,1
    jne Winner_is_User2
    SetCursor 26,10,0
    PrintMessage WinnerScreenMSG1
    jmp ending_WinnerScreen
Winner_is_User2:
    SetCursor 26,10,0
    PrintMessage WinnerScreenMSG2

ending_WinnerScreen:
    SetCursor 0,23,0
    call GetEnter
    MainMenu
    popa
    RET
endp WinnerScreen

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
    ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
    ;SetCursor UserCommand1Col,UserCommand1row,0
    ;ReadMessage UserCommand1
    ;UpperToLower UserCommand1
    call excCommand
    ;CLCWindow
    ;check if command is valid -> change in the registers

    ;if not valid -1 in points and take the other user command
    cmp IntialPoints1,0
    je Ending_WriteCommand
    cmp IntialPoints2,0
    je Ending_WriteCommand
    
    SetCursor UserCommand1Col,UserCommand1row,0     2 commands
    PrintMessage UserCommandSpaces
    
    mov CurrUser,2
    ReadCommand UserCommand2,UserCommand2Col,UserCommand2row,Forbidden2Data
    ;SetCursor UserCommand2Col,UserCommand2row,0
    ;ReadMessage UserCommand2
    ;UpperToLower UserCommand2
    call excCommand

   ;call FlyingObj
Ending_WriteCommand:
    ret
endp WriteCommand

;-------Execute Command-------
excCommand proc
    
pusha
    ;moving UserCommand into CurCommand
    cmp CurrUser,1
    je excCommand_User1

        mov SI,offset UserCommand2+2
        mov DI,offset CurCommand
        mov cl,UserCommand2+1
        mov ch,0
        REP MOVSB
        jmp excCommand_start

    excCommand_User1:
        mov SI,offset UserCommand1Data
        mov DI,offset CurCommand
        mov cl,UserCommand1ActualSize
        mov ch,0
        REP MOVSB

    excCommand_start:
    popa

    GetStringSize CurCommand,actualSizeCommand

    call GetCommand
    cmp found_cmd,0
    je bayz

    ; jumping to found command
    CompareStrings Op_to_Execute,orCommand,4,OK
    cmp OK,1
    je or_loop

    ; if third is not space, cmd is wrong
    mov dl, 3
    cmp CurCommand+3,' '
    jne bayz

    ;Commands with no operands
    CompareStrings Op_to_Execute,clcCommand,4,OK
    cmp OK,1
    je clc_loop

    CompareStrings Op_to_Execute,nopCommand,4,OK
    cmp OK,1
    je nop_loop

    ;Validaate operand 1
    call GetOperandOne
    call ValidateOp1
    cmp OK,0
    je bayz

    SetCursor 26,15,0
    PrintMessage Operand1
    ;SetCursor 26,13,0
    ;PrintMessage EndProg
    
    ;NumbertoAscii4byte  Operand1TypeInMemory, Operand1TypeInMemoryAs
    ;single operand commands

    CompareStrings Op_to_Execute,incCommand,4,OK
    cmp OK,1
    je inc_loop

    CompareStrings Op_to_Execute,decCommand,4,OK
    cmp OK,1
    je dec_loop

    ;Validaate operand 2
    call GetOperandTwo
    call ValidateOp2
    cmp OK,0
    je bayz
    call TypeOp

    SetCursor 26,17,0
    PrintMessage Operand2
    SetCursor 26,19,0
    PrintMessage CurrUser

    call Validate2Operands
    cmp OK,0
    je bayz

  ; SetCursor 26,18,0
   ; PrintMessage Welcome

 ;SetCursor 26,14,0
 ;PrintMessage Operand2Type

    CompareStrings Op_to_Execute,mulCommand,4,OK
    cmp OK,1
    je mul_loop

    CompareStrings Op_to_Execute,divCommand,4,OK
    cmp OK,1
    je div_loop

    CompareStrings Op_to_Execute,shlCommand,4,OK
    cmp OK,1
    je shl_loop
    CompareStrings Op_to_Execute,shrCommand,4,OK
    cmp OK,1
    je shr_loop
    CompareStrings Op_to_Execute,rorCommand,4,OK
    cmp OK,1
    je ror_loop
    CompareStrings Op_to_Execute,rolCommand,4,OK
    cmp OK,1
    je rol_loop
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
    call GetOperandTwo
    isEmptyString Operand2,OK
    cmp OK,0
    je bayz
    call GetOperandValueUser2
    pusha
    mov ax,Operand1Value
    inc ax
    mov Operand1Value,ax
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

dec_loop:
    call GetOperandTwo
    isEmptyString Operand2,OK
    cmp OK,0
    je bayz
    call GetOperandValueUser2
    pusha
    mov ax,Operand1Value
    dec ax
    mov Operand1Value,ax
    popa

    call LoadOperandValueUser1

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
    call LoadOperandValueUser1
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
    call LoadOperandValueUser1
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
    call LoadOperandValueUser1
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
    call LoadOperandValueUser1
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
    call LoadOperandValueUser1
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
    rcr ax,cl ; ghalat el mafrood rcr
    mov Operand1Value,ax
    adc CheckCarry,0
    mov bl,CheckCarry
    mov CF2,bl
    mov CheckCarry,0
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

nop_loop:
    cmp Operand1Type,0
    jne bayz
    cmp Operand2Type,0
    jne bayz
    jmp msh_bayz

add_loop:
    Call GetOperandValueUser2
    ;SetCursor 26,16,0
    ;PrintMessage Operand2
    Call GetOperandValueUser1
    ;SetCursor 26,18,0
    ;PrintMessage Operand1
    pusha
    mov ax,Operand1Value
    mov bx,Operand2Value
    add ax,bx
    mov Operand1Value,ax
    call  CheckCurrentUserCarry
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

sub_loop:
    Call GetOperandValueUser2
    ;SetCursor 26,16,0
    ;PrintMessage Operand2
    Call GetOperandValueUser1
    ;SetCursor 26,18,0
    ;PrintMessage Operand1
    pusha
    mov ax,Operand1Value
    mov bx,Operand2Value
    sub ax,bx
    mov Operand1Value,ax
    call  CheckCurrentUserCarry
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

adc_loop:
    Call GetOperandValueUser2
    ;SetCursor 26,16,0
    ;PrintMessage Operand2
    Call GetOperandValueUser1
    ;SetCursor 26,18,0
    ;PrintMessage Operand1
    pusha
    call LoadCurrentUsercarry
    mov ax,Operand1Value
    mov bx,Operand2Value
    adc ax,bx
    mov Operand1Value,ax
    call  CheckCurrentUserCarry
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

sbb_loop:

     Call GetOperandValueUser2
    ;SetCursor 26,16,0
    ;PrintMessage Operand2
    Call GetOperandValueUser1
    ;SetCursor 26,18,0
    ;PrintMessage Operand1
    pusha
    call LoadCurrentUsercarry
    mov ax,Operand1Value
    mov bx,Operand2Value
    sbb ax,bx
    mov Operand1Value,ax
    call  CheckCurrentUserCarry
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

or_loop:
    ;SetCursor 26,16,0
    ;PrintMessage orCommand
    cmp CurCommand+2,' '
    jne bayz
    ;Validaate operand 1
    call GetOperandOne
    call ValidateOp1
    cmp OK,0
    je bayz
    ;Validaate operand 2
    call GetOperandTwo
    call ValidateOp2
    cmp OK,0
    je bayz
    ;SetCursor 26,15,0
    ;PrintMessage f1Pressed
    call TypeOp
    call Validate2Operands
    cmp OK,0
    je bayz

    Call GetOperandValueUser2
    ;SetCursor 26,16,0
    ;PrintMessage Operand2
    Call GetOperandValueUser1
    ;SetCursor 26,18,0
    ;PrintMessage Operand1
    pusha
    mov ax,Operand1Value
    mov bx,Operand2Value
    or ax,bx
    mov Operand1Value,ax
    call  CheckCurrentUserCarry
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

xor_loop:
    Call GetOperandValueUser2
    ;SetCursor 26,16,0
    ;PrintMessage Operand2
    Call GetOperandValueUser1
    ;SetCursor 26,18,0
    ;PrintMessage Operand1
    pusha
    mov ax,Operand1Value
    mov bx,Operand2Value
    xor ax,bx
    mov Operand1Value,ax
    call  CheckCurrentUserCarry
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

and_loop:
    Call GetOperandValueUser2
    ;SetCursor 26,16,0
    ;PrintMessage Operand2
    Call GetOperandValueUser1
    ;SetCursor 26,18,0
    ;PrintMessage Operand1
    pusha
    mov ax,Operand1Value
    mov bx,Operand2Value
    and ax,bx
    mov Operand1Value,ax
    call  CheckCurrentUserCarry
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

mov_loop:
    ;cmp Operand2Type,4
    ;Call GetOperandValueUser2
    Call GetOperandValueUser1
    pusha
    ;mov ax,Operand1Value
    mov bx,Operand2Value
    mov ax,bx
    mov Operand1Value,ax
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

mul_loop:
    pusha

    
    popa

div_loop:

bayz:  
    SetCursor 17,23,0
    PrintMessage ChatStatusMSG1

    cmp CurrUser,2
    je bayz_user2
    dec IntialPoints1
    NumbertoAscii4byte IntialPoints1,IP1
    jmp msh_bayz

bayz_user2:
    dec IntialPoints2
    NumbertoAscii4byte IntialPoints2,IP2

msh_bayz:
EmptyTheString UserCommand1Data,12
EmptyTheString UserCommand2Data,12
EmptyTheString CurCommand,14

EmptyTheString Operand1,7
EmptyTheString Operand2,7

mov Operand1Value, 0
mov Operand2Value, 0
call Refresh
;SetCursor 26,18,0
;PrintMessage AX_Reg_Value2
;SetCursor 26,20,0
;PrintMessage AH_Reg_Value2
;SetCursor 26,22,0
;PrintMessage AL_Reg_Value2

RET
ENDP excCommand


;-------Load Current user Carry-------

LoadCurrentUsercarry proc
    cmp CurrUser, 2
    je loadCarryUser2
    cmp CF2, 0
    jne setCarry
    jmp clearCarryUser2
    loadCarryUser2:
    cmp CF1, 0
    jne setCarry
    jmp clearCarryUser2

    setCarry:
    STC
    JMP endLoadCarry
    clearCarryUser2:
    CLC
    endLoadCarry:

ret
endp LoadCurrentUsercarry


;-------Check Current user Carry-------
CheckCurrentUserCarry proc
pusha
    adc CheckCarry,0
    mov bl,CheckCarry

    cmp CurrUser, 2
    je user2_carry
        MOV CF2, BL 
        JMP endSetCarry
    user2_carry:
       mov CF1, bl

    endSetCarry:
    mov CheckCarry,0
popa
ret
endp CheckCurrentUserCarry


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
      jmp compare_memory

 found_op1:    
      mov OK,1
      jmp finished_op1    

 not_found_op1:
     mov OK,0   
     
finished_op1:
    popa
    ret
endp ValidateOp1


;-------Validate Operand 2-------
ValidateOp2 proc

      pusha
      ;compare Curr_Command with command at loop_index
      mov OK,0
      mov bx,0

compare_registers2:
      lea si,AX_op[bx]
      lea di,Operand2
      mov cx,3
      REPE CMPSB
      cmp cx,0
      je found_op2
      add bx,3
      cmp bx,48
      je compare_based2
      jmp compare_registers2

compare_based2:  
      lea si,AX_op[bx]
      lea di,Operand2
      mov cx,4
      REPE CMPSB
      cmp cx,0
      je found_op2
      add bx,5
      cmp bx,63
      je compare_memory2
      jmp compare_based2

compare_memory2:
      lea si,AX_op[bx]
      lea di,Operand2
      mov cx,3
      REPE CMPSB
      cmp cx,0
      je found_op2
      add bx,4
      cmp bx,83
      je compare_immediateNumber2
      jmp compare_memory2


compare_immediateNumber2:
    CheckImmediate Operand2, ok
    cmp ok,0
    je not_found_op2


 found_op2:    
      mov OK,1
      jmp finished_op2    

 not_found_op2:
     mov OK,0   
     
finished_op2:
    popa
    ret
endp ValidateOp2


;-------Validate 2 Operands-------

Validate2Operands proc near
    mov OK, 0

    cmp Operand1Type, 0 ;nop
    je operandTypeMismatch

    cmp Operand1Type, 1
    je operandoneReg8

    cmp Operand1Type, 2
    je operandoneReg16

    cmp Operand1Type, 3
    je operandoneMemory

    cmp Operand1Type, 4
    je operandTypeMismatch


    cmp Operand1Type, 5
    je operandTypeMismatch



    operandoneReg8:
    
        cmp Operand2Type, 2
        je operandTypeMismatch
        cmp Operand2Type, 5
        je operandTypeMismatch
        mov OK,1
        jmp Finish

     operandoneReg16:
       
        cmp Operand2Type, 1
        je operandTypeMismatch
        mov OK,1
        jmp Finish

    operandoneMemory:
        cmp Operand2Type, 3
        je operandTypeMismatch
        mov OK,1
        jmp Finish

    operandTypeMismatch:
        mov OK,0
        ;SetCursor 22,14,0
        ;PrintMessage SI_op
    Finish:
ret
endp Validate2Operands


;------Get Type of Operand-------
;------0 -> false type-----------
;------1 -> register-8-----------
;------2 -> register-16----------
;------3 -> memory------------
;------4 -> imm 2- bytes---------------
;------5 -> imm 4- bytes---------------

;-----Get data segment number-----------Operand1TypeInMemory,Operand2TypeInMemory
TypeOp proc

      pusha
    ;Operand 1:
    isEmptyString Operand1,OK
    cmp OK,1
    je false_op1
    CompareStrings Operand1,AX_op,4,OK
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
    jne CompareMem1Op1
    mov Operand1TypeInMemory, 0
    jmp mem_op1

    ;comp mem1
    CompareMem1Op1:
    CompareStrings Operand1,MEM1,4,OK
    cmp OK,1
    jne CompareMem2Op1
    mov Operand1TypeInMemory, 1
    jmp mem_op1

    ;comp mem2
    CompareMem2Op1:
    CompareStrings Operand1,MEM2,4,OK
    cmp OK,1
    jne CompareMem3Op1
    mov Operand1TypeInMemory, 2
    jmp mem_op1

    ;comp mem3
    CompareMem3Op1:
    CompareStrings Operand1,MEM3,4,OK
    cmp OK,1
    jne CompareMem4Op1
    mov Operand1TypeInMemory, 3
    jmp mem_op1

    ;comp mem4
    CompareMem4Op1:
    CompareStrings Operand1,MEM4,4,OK
    cmp OK,1
    jne CheckImmediateLabel
    mov Operand1TypeInMemory, 4
    jmp mem_op1

    ;check immediate
     CheckImmediateLabel:
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
    CompareStrings Operand2,AL_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,AH_op,3,OK
    cmp OK,1
    je reg8_op2
    CompareStrings Operand2,BX_op,3,OK
    cmp OK,1
    je reg16_op2
    CompareStrings Operand2,BL_op,3,OK
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
    jne CompareMem1Op2
    mov Operand2TypeInMemory, 0
    jmp mem_op2
    
    ;cmp mem1
CompareMem1Op2:

    CompareStrings Operand2,MEM1,4,OK
    cmp OK,1
    jne CompareMem2Op2
    mov Operand2TypeInMemory, 1
    jmp mem_op2
    
    ;cmp mem2
CompareMem2Op2:

    CompareStrings Operand2,MEM2,4,OK
    cmp OK,1
    jne CompareMem3Op2
    mov Operand2TypeInMemory, 2
    jmp mem_op2
    
    ;cmp mem3
CompareMem3Op2:

    CompareStrings Operand2,MEM3,4,OK
    cmp OK,1
    jne CompareMem4Op2
    mov Operand2TypeInMemory, 3
    jmp mem_op2
    
    ;cmp mem4
CompareMem4Op2:

    CompareStrings Operand2,MEM4,4,OK
    cmp OK,1
    jne CheckImmediateLabel2
    mov Operand2TypeInMemory, 4
    jmp mem_op2
    
    ;Check immediate
CheckImmediateLabel2:
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
    cmp Operand2Type,4
    je OP2IMM
    cmp Operand2Type,5
    je OP2IMM
    cmp Operand2Type,3
    je OP2MEM


    CompareStrings Operand2,AX_op,3,OK
    cmp OK,1
    je AXisOP1
    CompareStrings Operand2,AL_op,3,OK
    cmp OK,1
    je ALisOP1
    CompareStrings Operand2,AH_op,3,OK
    cmp OK,1
    je AHisOP1
    CompareStrings Operand2,BX_op,3,OK
    cmp OK,1
    je BXisOP1
    CompareStrings Operand2,BL_op,3,OK
    cmp OK,1
    je BLisOP1
    CompareStrings Operand2,BH_op,3,OK
    cmp OK,1
    je BHisOP1
    CompareStrings Operand2,CX_op,3,OK
    cmp OK,1
    je CXisOP1
    CompareStrings Operand2,CL_op,3,OK
    cmp OK,1
    je CLisOP1
    CompareStrings Operand2,CH_op,3,OK
    cmp OK,1
    je CHisOP1
    CompareStrings Operand2,DX_op,3,OK
    cmp OK,1
    je DXisOP1
    CompareStrings Operand2,DL_op,3,OK
    cmp OK,1
    je DLisOP1
    CompareStrings Operand2,DH_op,3,OK
    cmp OK,1
    je DHisOP1
    CompareStrings Operand2,SI_op,3,OK
    cmp OK,1
    je SIisOP1
    CompareStrings Operand2,DI_op,3,OK
    cmp OK,1
    je DIisOP1
    CompareStrings Operand2,SP_op,3,OK
    cmp OK,1
    je SPisOP1
    CompareStrings Operand2,BP_op,3,OK
    cmp OK,1
    je BPisOP1
    CompareStrings Operand2,BX_op_idx,5,OK
    cmp OK,1
    je BXidxisOP1
    CompareStrings Operand2,SI_op_idx,5,OK
    cmp OK,1
    je SIidxisOP1
    CompareStrings Operand2,DI_op_idx,5,OK
    cmp OK,1
    je DIidxisOP1
 
 AXisOP1:
 cmp CurrUser,2
 je user1_ax      
       AsciiToNumber AX_Reg_Value2,0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_ax:
       AsciiToNumber AX_Reg_Value1,0,Operand2Value
       jmp finished_GetOperandValueUser1 

ALisOP1:
cmp CurrUser,2
je user1_al 
        AsciiToNumber AX_Reg_Value2[2],0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_al:
       AsciiToNumber AX_Reg_Value1[2],0,Operand2Value
       jmp finished_GetOperandValueUser1

AHisOP1:

BXisOP1:
cmp CurrUser,2
je user1_bx 
       AsciiToNumber BX_Reg_Value2,0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_bx:
       AsciiToNumber BX_Reg_Value1,0,Operand2Value
       jmp finished_GetOperandValueUser1 

BLisOP1:
cmp CurrUser,2
je user1_bl 
       AsciiToNumber BX_Reg_Value2[2],0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_bl:
       AsciiToNumber BX_Reg_Value1[2],0,Operand2Value
       jmp finished_GetOperandValueUser1

BHisOP1:

CXisOP1:
cmp CurrUser,2
je user1_cx 
       AsciiToNumber CX_Reg_Value2,0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_cx:
       AsciiToNumber CX_Reg_Value1,0,Operand2Value
       jmp finished_GetOperandValueUser1 

CLisOP1:
cmp CurrUser,2
je user1_cl 
       AsciiToNumber CX_Reg_Value2[2],0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_cl:
       AsciiToNumber CX_Reg_Value1[2],0,Operand2Value
       jmp finished_GetOperandValueUser1 

CHisOP1:

DXisOP1:
cmp CurrUser,2
je user1_dx 
       AsciiToNumber DX_Reg_Value2,0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_dx:
       AsciiToNumber DX_Reg_Value1,0,Operand2Value
       jmp finished_GetOperandValueUser1 

DLisOP1:
cmp CurrUser,2
je user1_dl
       AsciiToNumber DX_Reg_Value2[2],0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_dl:
       AsciiToNumber DX_Reg_Value1[2],0,Operand2Value
       jmp finished_GetOperandValueUser1 

DHisOP1:

SIisOP1:
cmp CurrUser,2
je user1_si
       AsciiToNumber SI_Reg_Value2,0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_si:
       AsciiToNumber SI_Reg_Value1,0,Operand2Value
       jmp finished_GetOperandValueUser1 

DIisOP1:
cmp CurrUser,2
je user1_di
       AsciiToNumber DI_Reg_Value2,0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_di:
       AsciiToNumber DI_Reg_Value1,0,Operand2Value
       jmp finished_GetOperandValueUser1 

SPisOP1:
cmp CurrUser,2
je user1_sp
       AsciiToNumber SP_Reg_Value2,0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_sp:
       AsciiToNumber SP_Reg_Value1,0,Operand2Value
       jmp finished_GetOperandValueUser1 

BPisOP1:
cmp CurrUser,2
je user1_bp
       AsciiToNumber BP_Reg_Value2,0,Operand2Value
       jmp finished_GetOperandValueUser1
user1_bp:
       AsciiToNumber BP_Reg_Value1,0,Operand2Value
       jmp finished_GetOperandValueUser1 

BXidxisOP1:
SIidxisOP1:
DIidxisOP1:

OP2Imm:
    AsciiToNumber Operand2,0,Operand2Value
    jmp finished_GetOperandValueUser1 
    
OP2MEM:
    cmp Operand2TypeInMemory, 0
    jne memo2

        cmp CurrUser,2
        je user1_DS00
            AsciiToNumber DS00_Value2,0,Operand2Value
            jmp finished_GetOperandValueUser1
        user1_DS00:
            AsciiToNumber DS00_Value1,0,Operand2Value
            jmp finished_GetOperandValueUser1 

    memo2:
    cmp Operand2TypeInMemory, 1
    jne memo3

        cmp CurrUser,2
        je user1_DS01
            AsciiToNumber DS01_Value2,0,Operand2Value
            jmp finished_GetOperandValueUser1
        user1_DS01:
            AsciiToNumber DS01_Value1,0,Operand2Value
            jmp finished_GetOperandValueUser1 

    memo3:
    cmp Operand2TypeInMemory, 2
    jne memo4

        cmp CurrUser,2
        je user1_DS02
            AsciiToNumber DS02_Value2,0,Operand2Value
            jmp finished_GetOperandValueUser1
        user1_DS02:
            AsciiToNumber DS02_Value1,0,Operand2Value
            jmp finished_GetOperandValueUser1 

    memo4:
    cmp Operand2TypeInMemory, 3
    jne memo5

        cmp CurrUser,2
        je user1_DS03
            AsciiToNumber DS03_Value2,0,Operand2Value
            jmp finished_GetOperandValueUser1
        user1_DS03:
            AsciiToNumber DS03_Value1,0,Operand2Value
            jmp finished_GetOperandValueUser1 

    memo5:
    cmp Operand2TypeInMemory, 4
    jne finished_GetOperandValueUser1

        cmp CurrUser,2
        je user1_DS04
            AsciiToNumber DS04_Value2,0,Operand2Value
            jmp finished_GetOperandValueUser1
        user1_DS04:
            AsciiToNumber DS04_Value1,0,Operand2Value
            jmp finished_GetOperandValueUser1 



    

    jmp finished_GetOperandValueUser1 


finished_GetOperandValueUser1:
    popa
    ret

endp GetOperandValueUser1


;-------Get Value from Operand1 for User2 Registers-------
GetOperandValueUser2 proc

    pusha

    cmp Operand1Type,3
    je OP1MEM

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
cmp CurrUser,2
je user2_ah 
        AsciiToNumber AX_Reg_Value2[0],2,Operand1Value
       jmp finished_GetOperandValueUser2
user2_ah:
       AsciiToNumber AX_Reg_Value1[0],2,Operand1Value
       jmp finished_GetOperandValueUser2


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
cmp CurrUser,2
je user2_bh 
        AsciiToNumber BX_Reg_Value2[0],2,Operand1Value
       jmp finished_GetOperandValueUser2
user2_bh:
       AsciiToNumber BX_Reg_Value1[0],2,Operand1Value
       jmp finished_GetOperandValueUser2

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
cmp CurrUser,2
je user2_ch 
        AsciiToNumber CX_Reg_Value2[0],2,Operand1Value
       jmp finished_GetOperandValueUser2
user2_ch:
       AsciiToNumber CX_Reg_Value1[0],2,Operand1Value
       jmp finished_GetOperandValueUser2

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
cmp CurrUser,2
je user2_dh 
        AsciiToNumber DX_Reg_Value2[0],2,Operand1Value
       jmp finished_GetOperandValueUser2
user2_dh:
       AsciiToNumber DX_Reg_Value1[0],2,Operand1Value
       jmp finished_GetOperandValueUser2

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

OP1MEM:
    cmp Operand1TypeInMemory, 0
    jne memo22

        cmp CurrUser,2
        je user2_DS00
            AsciiToNumber DS00_Value2,0,Operand1Value
            jmp finished_GetOperandValueUser2
        user2_DS00:
            AsciiToNumber DS00_Value1,0,Operand1Value
            jmp finished_GetOperandValueUser2 

    memo22:

    cmp Operand1TypeInMemory, 1
    jne memo23

        cmp CurrUser,2
        je user2_DS01
            AsciiToNumber DS01_Value2,0,Operand1Value
            jmp finished_GetOperandValueUser2
        user2_DS01:
            AsciiToNumber DS01_Value1,0,Operand1Value
            jmp finished_GetOperandValueUser2 
    memo23:
        cmp Operand1TypeInMemory, 2
        jne memo24

        cmp CurrUser,2
        je user2_DS02
            AsciiToNumber DS02_Value2,0,Operand1Value
            jmp finished_GetOperandValueUser2
        user2_DS02:
            AsciiToNumber DS02_Value1,0,Operand1Value
            jmp finished_GetOperandValueUser2 

    memo24:
        cmp Operand1TypeInMemory, 3
        jne memo25

        cmp CurrUser,2
        je user2_DS03
            AsciiToNumber DS03_Value2,0,Operand1Value
            jmp finished_GetOperandValueUser2
        user2_DS03:
            AsciiToNumber DS03_Value1,0,Operand1Value
            jmp finished_GetOperandValueUser2 

    memo25:
         cmp Operand1TypeInMemory, 4
        jne finished_GetOperandValueUser2

        cmp CurrUser,2
        je user2_DS04
            AsciiToNumber DS04_Value2,0,Operand1Value
            jmp finished_GetOperandValueUser2
        user2_DS04:
            AsciiToNumber DS04_Value1,0,Operand1Value
            jmp finished_GetOperandValueUser2 



    
finished_GetOperandValueUser2:
    popa
    ret
endp GetOperandValueUser2


;-------Load Value in Operand1 for User1 Registers-------
LoadOperandValueUser1 proc

    pusha
    cmp Operand1Type,3
    je Load_OP1MEM

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
    jmp finished_LoadOperandValueUser
 AXisLoad:
 cmp CurrUser,2 
 je axlod_2  
       NumbertoAscii4byte Operand1Value,AX_Reg_Value2
       UpdateSmallReg AX_Reg_Value2, AH_Reg_Value2, AL_Reg_Value2
       jmp finished_LoadOperandValueUser
axlod_2:
       NumbertoAscii4byte Operand1Value,AX_Reg_Value1
       UpdateSmallReg AX_Reg_Value1, AH_Reg_Value1, AL_Reg_Value1
       jmp finished_LoadOperandValueUser

 ALisLoad:
 cmp CurrUser,2 
 je allod_2  
       NumbertoAscii2byte Operand1Value,AL_Reg_Value2
       UpdateBigRegL AX_Reg_Value2, AL_Reg_Value2
       jmp finished_LoadOperandValueUser
allod_2:
       NumbertoAscii2byte Operand1Value,AL_Reg_Value1
       UpdateBigRegL AX_Reg_Value1, AL_Reg_Value1
       jmp finished_LoadOperandValueUser

 AHisLoad:
 cmp CurrUser,2 
 je ahlod_2  
       NumbertoAscii2byte Operand1Value,AH_Reg_Value2
       UpdateBigRegH AX_Reg_Value2, AH_Reg_Value2
       jmp finished_LoadOperandValueUser
ahlod_2:
       NumbertoAscii2byte Operand1Value,AH_Reg_Value1
       UpdateBigRegH AX_Reg_Value1, AH_Reg_Value1
       jmp finished_LoadOperandValueUser

 BXisLoad:
 cmp CurrUser,2 
 je bxlod_2  
       NumbertoAscii4byte Operand1Value,BX_Reg_Value2
       UpdateSmallReg BX_Reg_Value2, BH_Reg_Value2, BL_Reg_Value2
       jmp finished_LoadOperandValueUser
bxlod_2:
       NumbertoAscii4byte Operand1Value,BX_Reg_Value1
       UpdateSmallReg BX_Reg_Value1, BH_Reg_Value1, BL_Reg_Value1
       jmp finished_LoadOperandValueUser

 BLisLoad:
 cmp CurrUser,2 
je bllod_2  
       NumbertoAscii2byte Operand1Value,BL_Reg_Value2
       UpdateBigRegL BX_Reg_Value2, BL_Reg_Value2
       jmp finished_LoadOperandValueUser
bllod_2:
       NumbertoAscii2byte Operand1Value,BL_Reg_Value1
       UpdateBigRegL BX_Reg_Value1, BL_Reg_Value1
       jmp finished_LoadOperandValueUser

 BHisLoad:
 cmp CurrUser,2 
je bhlod_2  
       NumbertoAscii2byte Operand1Value,Bh_Reg_Value2
       UpdateBigRegH BX_Reg_Value2, BH_Reg_Value2
       jmp finished_LoadOperandValueUser
bhlod_2:
       NumbertoAscii2byte Operand1Value,Bh_Reg_Value1
       UpdateBigRegH BX_Reg_Value1, BH_Reg_Value1
       jmp finished_LoadOperandValueUser

 CXisLoad:
 cmp CurrUser,2 
 je cxlod_2  
       NumbertoAscii4byte Operand1Value,CX_Reg_Value2
       UpdateSmallReg CX_Reg_Value2, CH_Reg_Value2, CL_Reg_Value2
       jmp finished_LoadOperandValueUser
cxlod_2:
       NumbertoAscii4byte Operand1Value,CX_Reg_Value1
       UpdateSmallReg CX_Reg_Value1, CH_Reg_Value1, CL_Reg_Value1
       jmp finished_LoadOperandValueUser

 CLisLoad:
 cmp CurrUser,2 
 je cllod_2  
       NumbertoAscii2byte Operand1Value,CL_Reg_Value2
       UpdateBigRegL CX_Reg_Value2, CL_Reg_Value2
       jmp finished_LoadOperandValueUser
cllod_2:
       NumbertoAscii2byte Operand1Value,CL_Reg_Value1
       UpdateBigRegL CX_Reg_Value1, CL_Reg_Value1
       jmp finished_LoadOperandValueUser

 CHisLoad:
 cmp CurrUser,2 
je chlod_2  
       NumbertoAscii2byte Operand1Value,CH_Reg_Value2
       UpdateBigRegH CX_Reg_Value2, CH_Reg_Value2
       jmp finished_LoadOperandValueUser
chlod_2:
       NumbertoAscii2byte Operand1Value,CH_Reg_Value1
       UpdateBigRegH CX_Reg_Value1, CH_Reg_Value1
       jmp finished_LoadOperandValueUser

 DXisLoad:
 cmp CurrUser,2 
je dxlod_2  
       NumbertoAscii4byte Operand1Value,DX_Reg_Value2
       UpdateSmallReg DX_Reg_Value2, DH_Reg_Value2, DL_Reg_Value2
       jmp finished_LoadOperandValueUser
dxlod_2:
       NumbertoAscii4byte Operand1Value,DX_Reg_Value1
       UpdateSmallReg DX_Reg_Value1, DH_Reg_Value1, DL_Reg_Value1
       jmp finished_LoadOperandValueUser

 DLisLoad:
 cmp CurrUser,2 
je dllod_2  
       NumbertoAscii2byte Operand1Value,DL_Reg_Value2
       UpdateBigRegL DX_Reg_Value2, DL_Reg_Value2
       jmp finished_LoadOperandValueUser
dllod_2:
       NumbertoAscii2byte Operand1Value,DL_Reg_Value1
       UpdateBigRegL DX_Reg_Value1, DL_Reg_Value1
       jmp finished_LoadOperandValueUser

 DHisLoad:
 cmp CurrUser,2 
je dhlod_2  
       NumbertoAscii2byte Operand1Value,DH_Reg_Value2
       UpdateBigRegH DX_Reg_Value2, DH_Reg_Value2
       jmp finished_LoadOperandValueUser
dhlod_2:
       NumbertoAscii2byte Operand1Value,DH_Reg_Value1
       UpdateBigRegH DX_Reg_Value1, DH_Reg_Value1
       jmp finished_LoadOperandValueUser

 SIisLoad:
 cmp CurrUser,2 
je silod_2  
       NumbertoAscii4byte Operand1Value,SI_Reg_Value2
       jmp finished_LoadOperandValueUser
silod_2:
       NumbertoAscii4byte Operand1Value,SI_Reg_Value1
       jmp finished_LoadOperandValueUser
 
 DIisLoad:
 cmp CurrUser,2 
je dilod_2  
       NumbertoAscii4byte Operand1Value,DI_Reg_Value2
       jmp finished_LoadOperandValueUser
dilod_2:
       NumbertoAscii4byte Operand1Value,DI_Reg_Value1
       jmp finished_LoadOperandValueUser

 SPisLoad:
 cmp CurrUser,2 
je splod_2  
       NumbertoAscii4byte Operand1Value,SP_Reg_Value2
       jmp finished_LoadOperandValueUser
splod_2:
       NumbertoAscii4byte Operand1Value,SP_Reg_Value1
       jmp finished_LoadOperandValueUser

 BPisLoad:
 cmp CurrUser,2 
je bplod_2  
       NumbertoAscii4byte Operand1Value,BP_Reg_Value2
       jmp finished_LoadOperandValueUser
bplod_2:
       NumbertoAscii4byte Operand1Value,BP_Reg_Value1
       jmp finished_LoadOperandValueUser

 BXidxisLoad:
 SIidxisLoad:
 DIidxisLoad:

 Load_OP1MEM:
    cmp Operand1TypeInMemory, 0
    jne makanElawel
    cmp CurrUser,2 
    je Mem0LOD  
        NumbertoAscii2byte Operand1Value, DS00_Value2
       jmp finished_LoadOperandValueUser
    Mem0LOD:
       NumbertoAscii2byte Operand1Value,DS00_Value1
       jmp finished_LoadOperandValueUser
    makanElawel:
        cmp Operand1TypeInMemory, 1
        jne makanEltany
        cmp CurrUser,2 
    je Mem1LOD  
        NumbertoAscii2byte Operand1Value, DS01_Value2
       jmp finished_LoadOperandValueUser
    Mem1LOD:
       NumbertoAscii2byte Operand1Value,DS01_Value1
       jmp finished_LoadOperandValueUser

    makanEltany:
     cmp Operand1TypeInMemory, 2
        jne makanEltalt
        cmp CurrUser,2 
    je Mem2LOD  
        NumbertoAscii2byte Operand1Value, DS02_Value2
       jmp finished_LoadOperandValueUser
    Mem2LOD:
       NumbertoAscii2byte Operand1Value,DS02_Value1
       jmp finished_LoadOperandValueUser

    makanEltalt:
    cmp Operand1TypeInMemory, 3
        jne makanElrabe3
        cmp CurrUser,2 
    je Mem3LOD  
        NumbertoAscii2byte Operand1Value, DS03_Value2
       jmp finished_LoadOperandValueUser
    Mem3LOD:
       NumbertoAscii2byte Operand1Value,DS03_Value1
       jmp finished_LoadOperandValueUser
    makanElrabe3:
    cmp Operand1TypeInMemory, 4
        jne finished_LoadOperandValueUser
        cmp CurrUser,2 
    je Mem4LOD  
        NumbertoAscii2byte Operand1Value, DS04_Value2
       jmp finished_LoadOperandValueUser
    Mem4LOD:
       NumbertoAscii2byte Operand1Value,DS04_Value1
       jmp finished_LoadOperandValueUser

     
finished_LoadOperandValueUser:
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
    ;call GameScreen
    popa
    ret
endp LoadOperandValueUser2

;-------Game Screen-------
GameScreen proc

ZeroALL 0
Set4Dig IntialPoints1,IP1
Set4Dig IntialPoints2,IP2
TheLoop:
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

    SetCursor 20,13,0
    PrintMessage GHit
    SetCursor 20,16,0
    PrintMessage RHit
    SetCursor 20,18,0
    PrintMessage CHit
    SetCursor 20,21,0
    PrintMessage YHit

    SetCursor 19,0,0
    PrintMessage Levelmsg
    SetCursor 21,0,0
    PrintMessage LevelVariable+2
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
    AsciiToNumber IP1,0,IntialPoints1
    PrintMessage IP1


    SetCursor 23,0,0
    PrintMessage User2Name+2
    pusha
    mov al, [User2Name+1]
    add al,23
    SetCursor al,0,0
    PrintMessage Semicolon
    popa
    AsciiToNumber IP2,0,IntialPoints2
    PrintMessage IP2
    cmp LevelVariable+2,'2'
    je USER2_GAME_INFO
    SetCursor 17,0,0
    PrintMessage Forbidden1+2
    SetCursor 38,0,0
    PrintMessage Forbidden2+2
    ;Print the Names for the chat Mode
USER2_GAME_INFO:
    SetCursor 0,23,0
    PrintMessage User1Name+2
    SetCursor User1Name+1,23,0
    PrintMessage Semicolon
    SetCursor 0,24,0
    PrintMessage User2Name+2
    SetCursor User2Name+1,24,0
    PrintMessage Semicolon


    ;call Game


    Call WriteCommand

    cmp IntialPoints1,0
    je User2isWinner
    cmp IntialPoints2,0
    je User1isWinner
    jmp TheLoop

User1isWinner:
    mov Winner,1
    jmp ending_GameScreen

User2isWinner:
    mov Winner,2
    jmp ending_GameScreen

ending_GameScreen:
    call WinnerScreen
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


    SetCursor 0,12,0
    PrintMessage DS00_Value1
    SetCursor 0,14,0
    PrintMessage DS01_Value1
    SetCursor 0,16,0
    PrintMessage DS02_Value1
    SetCursor 0,18,0
    PrintMessage DS03_Value1
    SetCursor 0,20,0
    PrintMessage DS04_Value1


    SetCursor 38,12,0
    PrintMessage DS00_Value2
    SetCursor 38,14,0
    PrintMessage DS01_Value2
    SetCursor 38,16,0
    PrintMessage DS02_Value2
    SetCursor 38,18,0
    PrintMessage DS03_Value2
    SetCursor 38,20,0
    PrintMessage DS04_Value2
    
    ;Check for user 2 winning
    CompareStrings AX_Reg_Value1,WinnerVariable,5,OK
    cmp OK,1
    je User2isWinner
    CompareStrings BX_Reg_Value1,WinnerVariable,5,OK
    cmp OK,1
    je User2isWinner
    CompareStrings CX_Reg_Value1,WinnerVariable,5,OK
    cmp OK,1
    je User2isWinner
    CompareStrings DX_Reg_Value1,WinnerVariable,5,OK
    cmp OK,1
    je User2isWinner
    CompareStrings SI_Reg_Value1,WinnerVariable,5,OK
    cmp OK,1
    je User2isWinner
    CompareStrings DI_Reg_Value1,WinnerVariable,5,OK
    cmp OK,1
    je User2isWinner
    CompareStrings BP_Reg_Value1,WinnerVariable,5,OK
    cmp OK,1
    je User2isWinner
    CompareStrings SP_Reg_Value1,WinnerVariable,5,OK
    cmp OK,1
    je User2isWinner

    ;Check for user 1 winning
    CompareStrings AX_Reg_Value2,WinnerVariable,5,OK
    cmp OK,1
    je User1isWinner
    CompareStrings BX_Reg_Value2,WinnerVariable,5,OK
    cmp OK,1
    je User1isWinner
    CompareStrings CX_Reg_Value2,WinnerVariable,5,OK
    cmp OK,1
    je User1isWinner
    CompareStrings DX_Reg_Value2,WinnerVariable,5,OK
    cmp OK,1
    je User1isWinner
    CompareStrings SI_Reg_Value2,WinnerVariable,5,OK
    cmp OK,1
    je User1isWinner
    CompareStrings DI_Reg_Value2,WinnerVariable,5,OK
    cmp OK,1
    je User1isWinner
    CompareStrings BP_Reg_Value2,WinnerVariable,5,OK
    cmp OK,1
    je User1isWinner
    CompareStrings SP_Reg_Value2,WinnerVariable,5,OK
    cmp OK,1
    je User1isWinner

    SetCursor 0,0,0
    PrintMessage User1Name+2
    SetCursor User1Name+1,0,0
    PrintMessage Semicolon
    AsciiToNumber IP1,0,IntialPoints1
    PrintMessage IP1

    SetCursor 23,0,0
    PrintMessage User2Name+2
    pusha
    mov al, [User2Name+1]
    add al,23
    SetCursor al,0,0
    PrintMessage Semicolon
    popa
    AsciiToNumber IP2,0,IntialPoints2
    PrintMessage IP2
    jmp Refresh_ending
User1Wins:
    mov IntialPoints2,0
    jmp Refresh_ending
User2Wins:
    mov IntialPoints1,0
    jmp Refresh_ending

Refresh_ending:
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