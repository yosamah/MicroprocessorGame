;-----------بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ------------;

;-----------------MACROS-----------------


;-------------------Serial Port Macros-------------------

;----Initializes serial port with a certian configuration---
SerialPort MACRO
    ;Set divisor latch access bit
    MOV DX, ADDRESS+3    ;Line control register
    MOV AL, 10000000b
    OUT DX, AL

    ;Set the least significant byte of the Baud rate divisor latch register
    MOV DX, ADDRESS
    MOV AL, 0CH
    OUT DX, AL

    ;Set the most significant byte of the Baud rate divisor latch register
    MOV DX, ADDRESS+1
    MOV AL, 0
    OUT DX, AL

    ;Set serial port configurations
    MOV DX, ADDRESS+3    ;Line Control Register
    MOV AL, 00011011B
    ;0:     Access to receiver and transmitter buffers
    ;0:     Set break disabled
    ;011:   Even parity
    ;0:     One stop bit
    ;11:    8-bit word length
    OUT DX, AL
ENDM SerialPort

;-------Send character serial port-------
SendCharSerial MACRO char
LOCAL Send
    Send:
    MOV DX, ADDRESS+5    ;Line Status Register
    IN AL, DX
    AND AL, 00100000B       ;Check transmitter holding register status: 1 ready, 0 otherwise
    JZ Send                 ;Transmitter is not ready
    MOV DX, ADDRESS
    MOV AL, char
    OUT DX, AL
ENDM SendCharSerial

;------Receive a character from the serial port into AL----
ReceiveCharSerial MACRO
LOCAL ending
    MOV AL, 0
    MOV DX, ADDRESS+5    ;Line Status Register
    IN AL, DX
    AND AL, 00000001B       ;Check for data ready
    JZ ending               ;No character received
    MOV DX, ADDRESS      ;Receive data register
    IN AL, DX
    ending:
ENDM ReceiveCharSerial

;--------Print Character in Serial-------
PrintCharSerial MACRO char
    MOV AH, 02H
    MOV DL, char
    INT 21H
ENDM PrintCharSerial

;--------Empty buffer in Serial----------
EmptyBuffer MACRO
LOCAL Back, Return
    Back:
    GetKeyNoWaitSerial
    JZ Return
    GetKeyWaitSerial
    JMP Back
    Return:
ENDM EmptyBuffer

;--------Get key wait for serial---------
GetKeyWaitSerial MACRO 
    MOV AH, 00H
    INT 16H
endm GetKeyWaitSerial

;-------Get key no wait for serial-------
GetKeyNoWaitSerial MACRO 
    MOV AH, 01H
    INT 16H
endm GetKeyNoWaitSerial

;--------Flush keys pressed serial-------
FlushPressedSerial MACRO
LOCAL NoKeyPressed
    GetKeyNoWaitSerial
    jz NoKeyPressed
    GetKeyWaitSerial
    NoKeyPressed:
ENDM FlushPressedSerial

;--------Checking Input Character--------
; StartY for sending is WindowStart
; StartY for receiving is ChatHeight
CheckInputCharSerial MACRO char, x, y, StartY 
LOCAL Checking_Enter, Check_Scroll, Checking_BS, Checking_Printable, Modifying_Cursor, ending_check_char

    CMP char, ESCAsciiCode
    JNE Checking_Enter
    MOV end_chat, 1
    jmp ending_check_char
    
    Checking_Enter:
    cmp char, 0DH ;enter ascii
    jne Checking_BS
    mov x, WindowStart+4
    inc y 
    jmp Check_Scroll

    Checking_BS:
    cmp char, 8  ;backspace ascii
    jne Checking_Printable
    cmp x, WindowStart
    jbe Checking_Printable
    mov char, ' '
    dec x
    SetCursor x,y,0
    PrintCharSerial char
    jmp ReceivingChat

    Checking_Printable:  ;printing character if printable
    cmp char, ' '
    jb ReceivingChat
    cmp char, '~'
    ja ReceivingChat

    SetCursor x,y,0
    PrintCharSerial char  

    Modifying_Cursor:
    inc x
    cmp x, ChatLength - 1
    jb ending_check_char
    mov x, WindowStart
    inc y

    Check_Scroll:
    cmp y, ChatHeight+StartY-1
    jbe ending_check_char
    dec y
    Scroll WindowStart,StartY+2,WindowEndX,y,00h,1

ending_check_char:

endm CheckInputCharSerial        


;--------Checking Input for Main Screen from My Side--------
MainCheckInputSerialFromMe MACRO char
LOCAL Checking_Game_Me, start_chatting_me, Checking_Exit, start_game_me, undefined_main, ending_check_main_me
    
    ;Check if chatting
    CMP char, F1Scancode
    JNE Checking_Game_Me

    mov ChatInvitationSent,1
    cmp ChatInvitationRec,1
    je start_chatting_me
    jmp ending_check_main_me

start_chatting_me:
    call ChatWindow
    jmp ending_check_main_me
    
    ;Check if start game pressed
    Checking_Game_Me:
    cmp char, F2Scancode ;enter ascii
    jne Checking_Exit

    mov GameInvitationSent,1
    cmp GameInvitationRec,1
    je start_game_me
    jmp ending_check_main_me

start_game_me:
    mov IamSlave, 1
    changeGraphicsmode
    call GameScreen
    jmp ending_check_main_me

    Checking_Exit:
    cmp char, 1
    jnz undefined_main
    jmp ending_check_main_me
undefined_main:
    SetCursor 0, 21, 0
    PrintMessage undefinedMsg

ending_check_main_me:

endm MainCheckInputSerialFromMe  

;--------Checking Input for Main Screen from My Side--------
MainCheckInputSerialFromYou MACRO char
LOCAL Checking_Game_You, start_chatting_you, Checking_Exit_2, start_game_you, undefined_main2, ending_check_main_you, GoGame
    
    ;Check if chatting
    CMP char, F1Scancode
    JNE Checking_Game_You

    mov ChatInvitationRec,1
    cmp ChatInvitationSent,1
    je start_chatting_you
    jmp ending_check_main_you

start_chatting_you:
    call ChatWindow
    jmp ending_check_main_you
    
    ;Check if start game pressed
    Checking_Game_You:
    cmp char, F2Scancode ;enter ascii
    jne Checking_Exit_2

    mov GameInvitationRec,1
    cmp GameInvitationSent,1
    je start_game_you
    jmp ending_check_main_you

start_game_you:
    mov IamSlave, 0
    call LevelScreen
    ;cmp LevelVariable+2,'1'
    ;je GoGame
    ;call InputRegistersScreen
GoGame:
    changeGraphicsmode
    call GameScreen
    jmp ending_check_main_you

    Checking_Exit_2:
    cmp char, 1
    jnz undefined_main2
    jmp ending_check_main_you
undefined_main2:
    SetCursor 0, 21, 0
    PrintMessage undefinedMsg

ending_check_main_you:

endm MainCheckInputSerialFromYou  

;------Set Level According to Player-------
GetLevel macro
LOCAL ReceiveLevel, ending_get_level
    cmp IamSlave,0
    jne ReceiveLevel
    SendCharSerial LevelVariable+2
    jmp ending_get_level
ReceiveLevel:
    FlushPressedSerial
    ReceiveCharSerial
    JZ ReceiveLevel
    mov LevelVariable+2,AL
ending_get_level:
endm GetLevel


;-------Debug------
Debug macro charDebug
    SetCursor 10,10,0
    PrintCharGraphics charDebug, White,1
endm Debug

;-------Copy the string with unknown size-------
CopyStringDollar macro string1,string2
local myLoop, ending_compare_string
pusha
    mov si, 0
    mov di, 0
    myLoop:
        mov al, string1[si]
        cmp string1[si],'$'
        je ending_compare_string
        mov string2[di], al
        inc si
        inc di
        dec cx
        cmp cx, 0
    jnz myLoop
ending_compare_string:
popa
endm EmptyTheString

;-------Copy the string with size 4-------
CopyString macro string1,string2
local myLoop
pusha
    mov si, 2
    mov di, 0
    mov cl,4
    mov ch,0
    myLoop:
        mov al, string1[si]
        mov string2[di], al
        inc si
        inc di
        dec cx
        cmp cx, 0
    jnz myLoop
popa
endm EmptyTheString

;-------Empty the string-------
EmptyTheString macro string2,size
local myLoop
pusha
    mov si, offset string2
    mov cl,size
    mov ch,0
    myLoop:
        mov [si], '$'
        inc si
        dec cx
        cmp cx, 0
    jnz myLoop
   
popa
endm EmptyTheString

;------PUT ZERO IN ALL REGISTERS--------------
;------FOR START GAME AND POWER UP------------
;------0 for all registers and data segment---
;------1 for user 1 registers-----------------
;------2 for user 2 registers-----------------
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

;--Check Data Bus Stuck From PowerUp 4--
;---------Called each time--------------
CheckDataBus Macro CurrOperandCheckStuck
LOCAL stuck_at_zero,check_type_zero,stuck_zero_big,stuck_at_one,check_type_one,stuck_one_big,ending_checkdatabus
pusha
    cmp Power4Chosen,1
    jne ending_checkdatabus
    cmp StuckValue,'0'
    jne stuck_at_one

stuck_at_zero:
    cmp DataLineValue,8
    jae check_type_zero
    mov bx,0
    mov dx,1
    mov cl,DataLineValue
    mov ch,0
    shl dx,cl
    or  bx,dx
    not bx
    and CurrOperandCheckStuck,bx
    jmp ending_checkdatabus

check_type_zero:
    cmp Operand2Type,2
    je stuck_zero_big
    cmp Operand2Type,5
    je stuck_zero_big
    jmp ending_checkdatabus

stuck_zero_big:
    mov bx,0
    mov dx,1
    mov cl,DataLineValue
    mov ch,0
    shl dx,cl
    or bx,dx
    not bx
    and CurrOperandCheckStuck,bx
    jmp ending_checkdatabus

stuck_at_one:
    cmp DataLineValue,8
    jae check_type_one
    mov bx,0
    mov dx,1
    mov cl,DataLineValue
    mov ch,0
    shl dx,cl
    or bx,dx
    or CurrOperandCheckStuck,bx
    jmp ending_checkdatabus

check_type_one:
    cmp Operand2Type,2
    je stuck_one_big
    cmp Operand2Type,5
    je stuck_one_big
    jmp ending_checkdatabus

stuck_one_big:
    mov bx,0
    mov dx,1
    mov cl,DataLineValue
    mov ch,0
    shl dx,cl
    or bx,dx
    not bx
    or bx,cx
    or CurrOperandCheckStuck,bx
    jmp ending_checkdatabus

ending_checkdatabus:
    mov Power4Chosen,0
popa
endm CheckDataBus

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

;-------Clear Screen Graphics-------
ClearScreenGraphics MACRO x1,y1,x2,y2,Color

    mov ax,0600h
    mov bh,color
    mov cl,x1
    mov ch,y1
    mov dl,x2
    mov dh,y2
    int 10h

endm ClearScreenGraphics

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
; When a 16-bit register is updated, it updates 
; the value of its two equivalent 8-bit ones
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
; When an lower 8-bit register is updated, it updates 
; the value of its corresponding 16-bit one (Al -> AX)
UpdateBigRegL Macro  regX, regL
pusha
    mov al,  regL[0]
    mov regX[2], al
    mov al,  regL[1]
    mov regX[3], al
popa
endm UpdateBigRegL

;-------Update big registers-------
; When an upper 8-bit register is updated, it updates 
; the value of its corresponding 16-bit one (AH -> AX)
UpdateBigRegH Macro  regX, regH
pusha
    mov al,  regH[0]
    mov regX[0], al
    mov al,  regH[1]
    mov regX[1], al
popa
endm UpdateBigRegH


;-------Check if Operand is Immediate-------
CheckImmediate MACRO Operand,OK
     LOCAL check_all_dig,check_letter,end,cont
     pusha
     mov OK,0
     GetStringSize Operand,OperandLength
     mov si,0
     cmp OperandLength,4
     ja end ; no immediate has more than 4 bytes
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

;-------Convert from Ascii (decimal) to number-------
AsciiToNumberDecimal MACRO current,answer
LOCAL looping,rest,setSize
    
    pusha
    GetStringSize current,StringSize
    mov si,StringSize
    mov bx,0
    mov cx,1 

looping:
    mov ah,0
    mov al,current[si-1]
    sub al,30h
rest:
    mul cx
    add bx,ax
    mov dx,10
    mov ax,cx
    mul dx
    mov cx,ax
    dec si
    cmp si,0
    ja looping
    mov answer,bx

popa
endm AsciiToNumberDecimal

;-------Convert from Ascii (hexa) to number-------
; If u know the size send it in "val" 
; if not send 0 in val & it automatically calculates size 
AsciiToNumber MACRO current,val,answer
LOCAL looping,rest,setSize
    
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
    cmp current[si-1],'A'
    jb rest
    sub al,7h
    cmp current[si-1],'a'
    jb rest
    sub al,20h
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


;-------Convert from 4-byte Number to Ascii-------
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


;-------Convert from 2-byte Number to Ascii--------
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
pusha
    mov ah,0Ah
    lea dx,msg
    int 21h
popa
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
GetUser1Name MACRO UserName
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
    
    
    ;checking if the name contain only chars
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
ENDM GetUser1Name

;--------Sending Values of All Registers----------
SendAllValues MACRO
local sending_register_values
    mov bx,0
sending_register_values:
    mov cl, AX_Reg_Value2[bx]
    SendCharSerial cl
    inc bx
    cmp bx,128d
    jb sending_register_values

    EmptyBuffer
endm SendAllValues

;--------Receiving Values of All Registers----------
ReceiveAllValues MACRO
local receiving_register_values, Still_Receiving

receiving_register_values:
    
    mov bx,0
    Still_Receiving:
    ReceiveCharSerial
    JZ Still_Receiving

    mov AX_Reg_Value1[bx],al
    inc bx 
    cmp bx, 128d
    jbe Still_Receiving

    EmptyBuffer
endm ReceiveAllValues

;--------Getting the username from the user----------
ReceiveUser2Var MACRO User1,User2,Size
    LOCAL Sending_My_Var,Still_Waiting,Still_Receiving

    mov BX, 1
    Sending_My_Var:
    mov cl, User1[bx]
    SendCharSerial cl

    Still_Waiting:
    FlushPressedSerial
    cmp al, ESCAsciiCode
    jne Still_Receiving
    mov ax,4c00h ;hlt
    int 21h
    
    Still_Receiving:
    ReceiveCharSerial
    JZ Still_Waiting

    mov User2[bx],al
    inc bx 
    cmp bx, Size
    jbe Sending_My_Var

    EmptyBuffer
ENDM ReceiveUser2Name



;--------Reading initial points from the user----------
;--------Initial points are a 1 or 2 digit number------
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
    UpperToLower Forbidden ;convert all to lowercase for easier comparison
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
; Reads the whole command and checks if forbidden character is used
; If used, keeps asking to re-enter until correct
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

;--------Lower to uppercase----------
LowertoUpperSize Macro InputString,size
    Local loop1,loop2
pusha
    mov cx, size
    mov bx, 0
    loop1:
    mov al, InputString[bx]
    cmp al , 'a'
    ja  loop2
    cmp al , 'z'
    jb loop2
    sub al , 20h

    loop2: 

    mov InputString[bx] , al 
    inc bx
    loop loop1

popa
endm UpperToLower

;--------Set 4 Digits----------
; Converts ascii to decimal number
; Used for initial points 
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


;--------Get Minimum of two numbers----------
; Used for intial points
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
    add bx, objR
    cmp ax, bx
    jz checkColRange
    jmp false
    ;Range el col yalaaaaa
checkColRange: ;right col
    mov ax, bullet_col
    mov bx, objY
    add bx, objR
    cmp ax, bx
    jle TaniCol
    jmp false
TaniCol:
    mov ax, bullet_col
    mov bx, objY
    sub bx, objR
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
BulletAction Macro T
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
;after calling this macro the "CH = hour" , "CL = Minute" 
;"DH = Seconds" , "DL = 1:100 Seconds"
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
    pusha
    mov cx ,sscol
    mov dx ,ssRow

    T3alaTani:
    DrawPixel dx,cx,color

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
    Local ExitGame,MoveUp,MoveDown,MoveLeft,MoveRight,hit

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
    jmp ExitGame

MoveUp:
    cmp ssRow,128           ;upper limit
    jz ExitGame
    DrawSpaceShip black
    Dec ssRow
    dec bullet_Row
    DrawSpaceShip White
    jmp ExitGame
MoveDown:
    cmp ssRow,168           ;lovwer limit
    jz ExitGame
    DrawSpaceShip black
    inc ssRow
    inc bullet_Row
    DrawSpaceShip White
    jmp ExitGame
MoveLeft:
    cmp ssCol,32            ;left limit
    jz ExitGame
    DrawSpaceShip black 
    Dec ssCol
    dec bullet_col
    DrawSpaceShip White
    jmp ExitGame
MoveRight:
    cmp ssCol,136           ;left limit
    jz ExitGame
    DrawSpaceShip black
    inc ssCol
    inc bullet_col
    DrawSpaceShip White
    jmp ExitGame
Hit:
    ;BulletAction
    jmp ExitGame


ExitGame:
ENDM ShipAction

;--------Main menu----------
MainMenu  MACRO 
    
    SerialPort
    
    changeTextmode  
    WelcomeText

    ;Getting Info  of user1 
    GetUser1Name User1Name
    ReceiveUser2Var User1Name,User2Name,UserNameSize
    
    ReadNumber IntialPoints1
    Set4Dig IntialPoints1,IP1
    ReceiveUser2Var IP1,IP2,InitialPointsSize 
    AsciiToNumberDecimal IP2,IntialPoints2

    ReadForbidden Forbidden2
    ReceiveUser2Var Forbidden2,Forbidden1,ForbiddenSizeSerial

    call GetEnter

    ;Getting Info  of user2 
    ;GetUserName User2Name
    ;ReadNumber IntialPoints2
    ;ReadForbidden Forbidden1
    ;call GetEnter

    ;Setting minimum initial points
    GetMin IntialPoints1,IntialPoints2,MinIP
    pusha
    mov ax, MinIP
    mov IntialPoints1,ax
    mov IntialPoints2,ax
    Set4Dig IntialPoints1,IP1
    Set4Dig IntialPoints2,IP2
    popa
    
    Call MainScreen

ENDM MainMenu

;----------------------------------------
.model small
.stack 64
.386
.data 

ADDRESS EQU 3F8H
Winner                  db 0
UserNameSize            dw 12,'$'
InitialPointsSize       dw 4,'$'
ForbiddenSizeSerial     dw 4,'$'

User1                   db 'USER1$'
User1Name               DB 12,?,12 DUP('$') , '$'
realSize1               db ?
IntialPoints1           dw ?,'$'
IP1                     db '0000$'  ;IntialPoints1 as a message

ForbidTemp              LABEL byte
ForbidTempSize          db 2
ForbidTempActSize       db ?
Forbid1Data             db 2 DUP('$') ,'$'

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

GameKeyScanCode         db ?,'$'
GameKeyAscii            db ?,'$'
PowerUpChosen           db ?,'$'
PowerUpChosen2          db 3,?,2 DUP('$') ,'$'

WrongPowerUpMSG         db 'Wrong Key.$'
NoEnoughPtsMsg          db 'Wrong- press key','$'
KeyPressPower           db 'F1 or F2.$'
KeyPressChoose          db '1-2-3-4-5$'
Power4StuckMSG          db 'Stuck 0 - 1$','$'
Power4DataMSG           db 'Data 0 - F$','$'
PowerUsedMSG           db 'Used already$','$'
Power5User1             db 0
Power5User2             db 0
Power1User1LV2          db 0 
Power1User2LV2          db 0 
EnterTarget             db 'Enter target $'
ValueExists             db 'Value is in Reg$'
NewTargetValue          db 5,?,5 DUP('$') ,'$'
TargetValid             db 0

Power1Chosen            db 0
Power2Chosen            db 0
Power3Chosen            db 0
Power4Chosen            db 0
Power5Chosen            db 0

Stuck LABEL byte
StuckSize               db 2
StuckActualSize         db ?
StuckValue              db 2 DUP('$') ,'$'

DataLine LABEL byte
DataLineSize            db 2
DataLineActualSize      db ?
DataLineValue           db 2 DUP('$') ,'$'

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
ChatInvitationMessage   db 'You have a pending chat invitation. Press F1.$'
GameInvitationMessage   db 'You have a pending game invitation. Press F2.$'
char                    db '-'
IsF1pressed             db 0
IsF2pressed             db 0
IsESCpressed            db 0
startrow                db 2
startcol                db 0
endcol                  db 20
SentCharMain            db ?
ReceivedCharMain        db ?
ChatInvitationRec       db 0
ChatInvitationSent      db 0
GameInvitationRec       db 0
GameInvitationSent      db 0
IamSlave                db 0

;--------Winner Screen Variables--------
WinnerScreenMSG1         db 3,14,2,' The winner is User 1 ',2,14,3,'$'
WinnerScreenMSG2         db 3,14,2,' The winner is User 2 ',2,14,3,'$'
WinnerVariable           db '105E$'

;--------Level Screen Variables---------
LevelInputMSG           db 'Enter Level',10,13, '$'
LevelVariable           db 3,?,2 DUP('$') ,'$'
LevelundefinedMsg       db 'Level should be 1 or 2 $'
ChooseProc              db 'Choose Processor $'
Processor1or2           db '1 - 2$'
ProcessorChosen         db 3,?,2 DUP('$') ,'$'

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


InputRegisterLevel2     db 5,?, 5 dup('$'), '$'

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

ZerosMSG                db '0000', '$'
TemporaryCheckMem       dw ?,'$'
;Geting username variables 
MulNmber                db 10
messageinvalidcharacter DB 'Invalid Input',10,13, '$'


;Chat Variables
end_chat                db 0
ChatStart               equ 1
ChatHeight              equ 11
ChatLength              equ 80
ChatStatusMSG1          db 'To end chat press F3 $'
MinusPoints             db 'Point Deducted $'
User1CursorX            db ?
User1CursorY            db ?
User2CursorX            db ?
User2CursorY            db ?
ChatMessage             db 70,?,70 dup('$')
ChatMessage2            db ?,'$'
test2                   db 25,?,25 dup('$')
SentCharChat            db ?
ReceivedCharChat        db ?

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
F3AsciiCode             equ 3DH
ESCAsciiCode            equ 1BH

Semicolon               db ':$'

;-------Available Commands-------
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
pushCommand             db 'push$'
imulCommand             db 'imul$'

found_cmd               db 0
Op_to_Execute           db 8 dup('$')
EmptyOp                 db 5 dup('$')
OK                      db ?,'$'
OperandLength           dw ?
Operand1                db 7 dup('$'),'$'
Operand1Size            dw ?,'$'
Operand1Type            db 0, '$'
Operand1Value           dw ?, '$'
startOperand2           dw ?, '$'
Operand2                db 7 dup('$')
Operand2Size            dw ?,'$'
Operand2Type            db 0, '$'
Operand2Value           dw ?, '$'
CurrOperandCheckStuck   dw ?,'$'

Operand1TypeInMemory    db ?, '$'
Operand2TypeInMemory    db ?, '$'

Operand1TypeInMemoryAs  db ?, '$'

;-------Available Operands-------
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
BXRelOne                db '[bx+1]','$'
BXRelTwo                db '[bx+2]','$'
BXRelThr                db '[bx+3]','$'
BXRelFour               db '[bx+4]','$'
SIRelOne                db '[si+1]','$'
SIRelTwo                db '[si+2]','$'
SIRelThr                db '[si+3]','$'
SIRelFour               db '[si+4]','$'
DIRelOne                db '[di+1]','$'
DIRelTwo                db '[di+2]','$'
DIRelThr                db '[di+3]','$'
DIRelFour               db '[di+4]','$'
StringSize              dw ?

UserCommandEmpty        db 14,?,14 dup('$') 


UserCommand1 LABEL byte
UserCommand1Size        db 19
UserCommand1ActualSize  db ?
UserCommand1Data        db 19 dup('$') 

UserCommand2 LABEL byte
UserCommand2Size        db 19
UserCommand2ActualSize  db ?
UserCommand2Data        db 19 dup('$') 

UserComTemp LABEL byte
UserComTempSize         db 19
UserComTempActualSize   db ?
UserComTempData         db 19 dup('$') 

EmptyString12           db 12 dup('$')
EmptyString6            db 6 dup('$')


UserCommandSpaces       db 19 dup(' '),'$'


UserCommand1Col         db 0
UserCommand1row         db 10

UserCommand2Col         db 21
UserCommand2row         db 10

CurCommand              db 19 dup('$')
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
test3                   db 10
test4                   dw 30
test5                   dw 120
test6                   dw 70
;;


;------Mul Variables-------

mul_al                  dw ?
mul_dx                  dw ?

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

ssCol                   dw ?
ss1Col                  dw 80
ss2Col                  dw 240

;gun Boundry
Gunx1                   dw 128
Gunx2                   dw 168
GunY1                   dw ?
GunY2                   dw ?

Gun1y1                  dw 32
Gun1y2                  dw 136

Gun2y1                  dw 180
Gun2y2                  dw 284

move                    db ?
GameEnd                 db 0

bulletsize              dw 2
bullet_Row              dw 165

bullet_col              dw ? 
bullet_1col             dw 83 
bullet_2col             dw 243 

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
objX                    dw 100
objY                    dw ?

obj1Y                   dw 35
obj2Y                   dw 178

YBoundry                dw ?  

Y1Boundry               dw 143
Y2Boundry               dw 283

objColor                db ?


scored                  db 0
ActionFlag              db 0

Random                  db ?
curColor                db ?

;Help messages (shown at start of game)

HelpText           db 'Level 1:',10,13,'1-User 1 plays first then, user 2',10,13,10,13
db '2-After user 2 turn, the flying objects game starts, and each user',10,13, 'has ONLY one bullet',10,13,10,13
db '3-At each plyer turn, they should press F1 or F2: ',10,13
db 'F1: Directly execute a command on opponent processor',10,13
db 'F2: Choose powerup and then execute a command *Check manual for Powerups*',10,13,10,13
db '4-Whenever you enter a wrong command, 1 point is automatically deducted and you lose your turn',10,13
db '5-Each user chooses their opponents forbidden character, and using the forbidden character lets you re-write the command'
db 'until the command is correct',10,13,10,13
db '6-Points distribution in the flying objects game: ',10,13
db '-Red:    1 point',10,13
db '-Cyan:   2 points',10,13
db '-Yellow: 3 Points',10,13
db '-Green:  6 Points',10,13, '$'

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

;--------Flying Objects Game-------
Game Proc

pusha
    cmp CurrUser ,1
    jz Player1
    mov ax,obj2Y
    mov bx,Y2Boundry
    mov cx,bullet_2col
    mov dx,Gun2y1
    mov objY,ax
    mov YBoundry,bx
    mov bullet_col,cx
    mov GunY1,dx

    mov ax,Gun2y2
    mov bx,ss2Col
    mov GunY2,ax
    mov ssCol,bx
    jmp DoneInfo

    Player1:
    mov ax,obj1Y
    mov bx,Y1Boundry
    mov cx,bullet_1col
    mov dx,Gun1y1
    mov objY,ax
    mov YBoundry,bx
    mov bullet_col,cx
    mov GunY1,dx

    mov ax,Gun1y2
    mov bx,ss1Col
    mov GunY2,ax
    mov ssCol,bx

    DoneInfo:
popa

pusha
    mov di, 1
Check:

    cmp di,0
    jbe EndGame
    mov ah,2ch
    int 21h

    mov al,dl 
    mov ah,0
    mov bl,4
    div bl
    mov Random, ah

    cmp dl,Time
    je Check

    mov Time,dl

    ;movement of the obj
    call MoveObject
    ;drawing the flying obj
    
    Drawbullet objY,objX,objR,objColor

    ;Gun movement
    call MoveGun
    ;Draw the gun
    DrawSpaceShip white
    cmp ActionFlag,1
    jz MoveBullet
    ;dec di
    Jmp Check
    MoveBullet:
        pusha
    mov si,bullet_Row
    Run:
    pusha
        ;to make 0.25 second delay
        mov cx,0h
        mov dx,9000h
        mov ah,86h
        int 15h
    popa
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
    cmp ActionFlag,1
    jz Run
    ;dec di
    jmp check
miss:
    mov ActionFlag,0
    Drawbullet bullet_col,bullet_Row,bulletsize,black
    mov bullet_Row,si
    jmp khlasnaKhlas
     
MabrokKsabtPoint:

    cmp curColor,0
    jz incGreen
    cmp curColor,1
    jz inccyan
    cmp curColor,2
    jz incred
    cmp curColor,3
    jz incyellow
    jmp doneYm3alm

    incGreen:
    inc gHit_value
    Set1Dig gHit_value,gHit
    SetCursor 20,13,0
    PrintMessage gHit
    cmp CurrUser,2
    jz shofElTani1
    add IntialPoints1,6
    Set4Dig IntialPoints1,IP1
    jmp doneYm3alm
    shofElTani1:
    add IntialPoints2,6
    Set4Dig IntialPoints2,IP2
    jmp doneYm3alm

    incred:
    inc rHit_value
    Set1Dig rHit_value,rHit
    SetCursor 20,16,0
    PrintMessage rHit
    cmp CurrUser,2
    jz shofElTani2
    add IntialPoints1,1
    Set4Dig IntialPoints1,IP1
    jmp doneYm3alm
    shofElTani2:
    add IntialPoints2,1
    Set4Dig IntialPoints2,IP2
    jmp doneYm3alm

    inccyan:
    inc cHit_value
    Set1Dig cHit_value,cHit
    SetCursor 20,18,0
    PrintMessage cHit
    cmp CurrUser,2
    jz shofElTani3
    add IntialPoints1,2
    Set4Dig IntialPoints1,IP1
    jmp doneYm3alm
    shofElTani3:
    add IntialPoints2,2
    Set4Dig IntialPoints2,IP2
    jmp doneYm3alm

    incyellow:
    inc yHit_value
    Set1Dig yHit_value,yHit
    SetCursor 20,21,0
    PrintMessage yHit
    cmp CurrUser,2
    jz shofElTani4
    add IntialPoints1,3
    Set4Dig IntialPoints1,IP1
    jmp doneYm3alm
    shofElTani4:
    add IntialPoints2,3
    Set4Dig IntialPoints2,IP2

    doneYm3alm:
    call Refresh
    mov ActionFlag,0
    mov scored,0
    Drawbullet bullet_col,bullet_Row,bulletsize,black
    mov bullet_Row,si   

khlasnaKhlas:
    popa
    ;---------------

    dec di
    jmp Check

    EndGame:
    ClearScreenGraphics 4,12,17,21,black
    ClearScreenGraphics 22,12,35,21,black
popa

RET
ENDP Game

;-------Gun movement AKA 7ark el pew pew--------
MoveGun Proc
pusha
    mov ActionFlag,0
    mov ah,01h
    int 16h
    jz ExitGame

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
    jmp ExitGame

MoveUp:
    mov si,Gunx1
    cmp ssRow,si          ;upper limit
    jbe ExitGame
    DrawSpaceShip black
    Dec ssRow
    cmp ssRow,si           
    jbe ExitGame
    dec bullet_Row
    DrawSpaceShip White
    jmp ExitGame
MoveDown:
    mov si,Gunx2
    cmp ssRow,si           ;lovwer limit
    jae ExitGame
    DrawSpaceShip black
    inc ssRow
    cmp ssRow,si           
    jae ExitGame
    inc bullet_Row
    DrawSpaceShip White
    jmp ExitGame
MoveLeft:
    mov si,GunY1
    cmp ssCol,si            ;left limit
    jbe ExitGame
    DrawSpaceShip black 
    Dec ssCol
    cmp ssCol,si         
    jbe ExitGame
    dec bullet_col
    DrawSpaceShip White
    jmp ExitGame
MoveRight:
    mov si,GunY2
    cmp ssCol,si           ;left limit
    jae ExitGame
    DrawSpaceShip black
    inc ssCol
    cmp ssCol,si           
    jae ExitGame
    inc bullet_col
    DrawSpaceShip White
    jmp ExitGame
Hit:
    mov ActionFlag ,1
    ;------------
    jmp ExitGame

ExitGame:
popa
    RET 
ENDP MoveGun 

;------Move target "mal7oza ghir el pew pew"------
MoveObject Proc
pusha
    mov si,YBoundry
    cmp objY,si
    jae StartOver
    Drawbullet objY,objX,objR,black
    inc objY
    cmp objY,si
    jae StartOver
    Drawbullet objY,objX,objR,objColor
popa
    RET
    StartOver:
    ;getting color
    cmp Random ,0
    Jz LGreen
    cmp Random,1
    jz LCyan
    cmp Random ,2
    Jz LRed
    cmp Random,3
    jz CYellow
    jmp m3analon

    LGreen:
    mov objColor,LightGreen
    mov curColor,0
    jmp m3analon
    LCyan:
    mov objColor,LightCyan
    mov curColor,1
    jmp m3analon
    LRed:
    mov objColor,LightRed
    mov curColor,2
    jmp m3analon
    CYellow:
    mov objColor,Yellow
    mov curColor,3

    m3analon:
    ;Getting random positions
    mov al,Random
    mov bl,4
    mul bl
    mov ah,0
    add objX,ax 
    cmp objX ,120
    jae resetpos
    jmp buf
    resetpos:
    mov objX,100
    buf:
    Drawbullet objY,objX,objR,black
    cmp CurrUser,2
    jz set2
    mov cx, obj1Y
    mov objY,cx
    jmp tmam
    Set2:
    mov cx, obj2Y
    mov objY,cx
    tmam: ;ydonia hati kman hati
popa
    RET
ENDP MoveObject

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
    Call PrintStatusBar

    CheckSendingMain:
    FlushPressedSerial
    jz CheckReceiveMain
    mov SentCharMain, AH
    SendCharSerial SentCharMain
    MainCheckInputSerialFromMe SentCharMain


    CheckReceiveMain:
    ReceiveCharSerial
    jz myLoop
    mov ReceivedCharMain, AL
    MainCheckInputSerialFromYou ReceivedCharMain

    jmp myLoop



        ;mov ah,0
        ;int 16h
        ;cmp ah, 59
       ; jnz check2ndkey
       ; SetCursor 0, 21, 0
       ; PrintMessage f1Pressed
      ;  mov IsF1pressed, 1
      ;  Call ChatWindow
      ;  jmp finishd
      ;  check2ndkey:
      ;  cmp ah, 60
      ;  jnz check3rdkey
      ;  SetCursor 0, 21, 0
      ;  PrintMessage f2Pressed
      ;  mov IsF2pressed, 1
       ; call LevelScreen
        ;cmp LevelVariable+2,'1'
      ;  je GoGame
      ;  call InputRegistersScreen
;GoGame:
 ;       changeGraphicsmode
  ;      call GameScreen
   ;     jmp finishd
 ;       check3rdkey:
 ;       cmp ah, 1
 ;       jnz undefined
 ;       SetCursor 0,21,0
  ;      PrintMessage escPressed
  ;      mov IsESCpressed, 1
  ;      jmp finishd
  ;      undefined:
  ;      SetCursor 0, 21, 0
  ;      PrintMessage undefinedMsg
   ;     mainscreen_loop:
   ; jmp myLoop 
        finishd:

    RET
endp MainScreen

;--------Help Screen-------
HelpScreen proc
    pusha
    changeTextmode
    ClearScreen WindowStart,WindowStart,WindowEndX,WindowEndY,0

    SetCursor 0,1,0
    PrintMessage HelpText
    call GetEnter
    popa
ret
ENDP HelpScreen

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


;-------Input Registers Screen LV2-------
; Screen that shows up in Level 2 for 
; initializing the registers for both users
InputRegistersScreen proc near
    pusha
    changeTextmode
    ClearScreen WindowStart,WindowStart,WindowEndX,WindowEndY,0
starting_user1:
    SetCursor 15,0,0
    PrintMessage User1

    SetCursor 0,2,0
    PrintMessage AX_Reg
    SetCursor 5,2,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,AX_Reg_Value1
    UpdateSmallReg AX_Reg_Value1,AH_Reg_Value1,AL_Reg_Value1


    SetCursor 0,4,0
    PrintMessage BX_Reg
    SetCursor 5,4,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,BX_Reg_Value1
    UpdateSmallReg BX_Reg_Value1,BH_Reg_Value1,BL_Reg_Value1

    SetCursor 0,6,0
    PrintMessage CX_Reg
    SetCursor 5,6,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,CX_Reg_Value1
    UpdateSmallReg CX_Reg_Value1,CH_Reg_Value1,CL_Reg_Value1

    SetCursor 0,8,0
    PrintMessage DX_Reg
    SetCursor 5,8,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,DX_Reg_Value1
    UpdateSmallReg DX_Reg_Value1,DH_Reg_Value1,DL_Reg_Value1

    SetCursor 0,10,0
    PrintMessage SI_Reg
    SetCursor 5,10,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,SI_Reg_Value1

    SetCursor 0,12,0
    PrintMessage DI_Reg
    SetCursor 5,12,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,DI_Reg_Value1

    SetCursor 0,14,0
    PrintMessage BP_Reg
    SetCursor 5,14,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,BP_Reg_Value1
    
    SetCursor 0,16,0
    PrintMessage SP_Reg
    SetCursor 5,16,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,SP_Reg_Value1
    
    SetCursor 0,18,0
    call GetEnter

    changeTextmode
    ClearScreen WindowStart,WindowStart,WindowEndX,WindowEndY,0
starting_user2:
    SetCursor 15,0,0
    PrintMessage User2
    
    SetCursor 0,2,0
    PrintMessage AX_Reg
    SetCursor 5,2,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,AX_Reg_Value2
    UpdateSmallReg AX_Reg_Value2,AH_Reg_Value2,AL_Reg_Value2

    SetCursor 0,4,0
    PrintMessage BX_Reg
    SetCursor 5,4,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,BX_Reg_Value2
    UpdateSmallReg BX_Reg_Value2,BH_Reg_Value2,BL_Reg_Value2

    SetCursor 0,6,0
    PrintMessage CX_Reg
    SetCursor 5,6,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,CX_Reg_Value2
    UpdateSmallReg CX_Reg_Value2,CH_Reg_Value2,CL_Reg_Value2

    SetCursor 0,8,0
    PrintMessage DX_Reg
    SetCursor 5,8,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,DX_Reg_Value2
    UpdateSmallReg DX_Reg_Value2,DH_Reg_Value2,DL_Reg_Value2

    SetCursor 0,10,0
    PrintMessage SI_Reg
    SetCursor 5,10,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,SI_Reg_Value2

    SetCursor 0,12,0
    PrintMessage DI_Reg
    SetCursor 5,12,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,DI_Reg_Value2

    SetCursor 0,14,0
    PrintMessage BP_Reg
    SetCursor 5,14,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,BP_Reg_Value2

    SetCursor 0,16,0
    PrintMessage SP_Reg
    SetCursor 5,16,0
    ReadMessage InputRegisterLevel2
    CopyString InputRegisterLevel2,SP_Reg_Value2
    
    SetCursor 0,18,0
    call GetEnter
    popa
    RET
endp InputRegistersScreen


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

    ;Drawing Chat Screen
    mov ChatInvitationSent,0
    mov ChatInvitationRec,0
    mov end_chat, 0
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
    
    SendingChat:
    FlushPressedSerial
    JZ ReceivingChat
    mov SentCharChat, AL
    SendCharSerial SentCharChat
    CheckInputCharSerial SentCharChat, User1CursorX, User1CursorY, WindowStart

    cmp end_chat, 1
    je Khalas

    ReceivingChat:
    ReceiveCharSerial
    jz CursorLoop
    mov ReceivedCharChat, AL
    CheckInputCharSerial ReceivedCharChat, User2CursorX, User2CursorY, ChatHeight

    cmp end_chat, 1
    jne CursorLoop

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

    cmp IamSlave,0
    je call_command1
    ReceiveAllValues 
    call Refresh
    call WriteCommand1
    SendAllValues
    jmp ending_write 
call_command1:
    call WriteCommand1
        SendAllValues
    ReceiveAllValues 
    call Refresh 
ending_write:
ret  
endp WriteCommand 
;;-------Writing commands-------
; WriteCommand proc

; start1:
;     mov CurrUser,1

;     ;Get Key for F1 or F2
;     ;F1 for command F2 for power-up
    
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage KeyPressPower
;     GetKeyWait GameKeyScanCode,GameKeyAscii

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

;     ; Check if PowerUp
;     ; If F1: jump to CallExecute i.e: directly execute command
;     ; If F2: jump to start1 i.e: choose power-up first
;     cmp GameKeyScanCode,F1Scancode
;     je CallExecute
;     cmp GameKeyScanCode,F2Scancode
;     jne start1

;     ;Choose which power-up
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage KeyPressChoose

;     GetKeyWait PowerUpChosen,GameKeyAscii
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces


;     cmp PowerUpChosen,2 ;2 is scan-code for 1 on keyboard
;     je FirstPowerUp
;     cmp PowerUpChosen,3 ;3 is scan-code for 2 on keyboard
;     je SecondPowerUp
;     cmp PowerUpChosen,4 ;4 is scan-code for 3 on keyboard
;     je ThirdPowerUp
;     cmp PowerUpChosen,5 ;5 is scan-code for 4 on keyboard
;     je FourthPowerUp
;     cmp PowerUpChosen,6 ;6 is scan-code for 5 on keyboard
;     je FifthPowerUp
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage WrongPowerUpMSG

;     ;Wait any key press to proceed to execute 
;     push ax
;     mov ah,0
;     int 16h
;     pop ax

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute

; ;Command on your own processor (Level 1)
; ;Changing target value (Level 2)
; FirstPowerUp:

;     cmp LevelVariable+2,'1' 
;     je FirstPowerUpLevel1 
;     cmp Power1User1LV2,1 ; Check if first power up in level 2 is already used
;     jne FirstPowerUpLevel2 ; if used, proceed to execute command & skip power up

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage PowerUsedMSG

;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute

; FirstPowerUpLevel2:
;     cmp IntialPoints1,30 ;check if there's enough points

;     jbe WrongPowerUp
;     mov Power1User1LV2,1
;     Set4Dig IntialPoints1,IP1

;     ; Reading new target value
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage EnterTarget
;     ReadMessage NewTargetValue

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

;     ; Validating input target value
;     call ValidateTarget
;     cmp TargetValid,1
;     je change_target

;     ; Notifying user new target value is invalid
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage ValueExists
;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute

; change_target:
;     sub IntialPoints1,30
;     LowertoUpperSize NewTargetValue,4
;     CopyString NewTargetValue,WinnerVariable ;copying value to actual WinnerVariable
;     jmp CallExecute

; FirstPowerUpLevel1:
;     cmp IntialPoints1,5
;     jbe WrongPowerUp
;     sub IntialPoints1,5
;     Set4Dig IntialPoints1,IP1

; ChooseProcessorLevel2User1:  ;label to execute command on own processor level 2 without points deduction
;     mov Power1Chosen,1
;     mov CurrUser,2
;     ReadCommand UserCommand2,UserCommand1Col,UserCommand1row,Forbidden1Data
;     call excCommand

; jmp Resetting1


; ;Command on your processor and your opponent processor 
; SecondPowerUp:

;     cmp IntialPoints1,3 ;check enough points
;     jbe WrongPowerUp
;     sub IntialPoints1,3
;     Set4Dig IntialPoints1,IP1
;     mov Power2Chosen,0
;     ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
;     CopyStringDollar UserCommand1,UserComTemp
;     mov Power2Chosen,1
;     call excCommand
;     CopyStringDollar UserComTemp,UserCommand2
;     mov CurrUser,2
;     call excCommand

; jmp Resetting1


; ;Changing the forbidden character
; ThirdPowerUp:

;     mov Power3Chosen, 1
;     cmp IntialPoints1,8 ;check enough points
;     jbe WrongPowerUp
;     sub IntialPoints1,8
;     Set4Dig IntialPoints1,IP1

;     ;Reading new forbidden
;     CopyStringDollar Forbidden1,ForbidTemp
;     SetCursor UserCommand1Col,UserCommand1row,0
;     ReadMessage Forbidden1
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data

;     call excCommand
;     CopyStringDollar ForbidTemp,Forbidden1

; jmp Resetting1


; ;Data lines stuck
; ;Stuck value has 0 or 1
; ;DataLine value has 0-16 (which bit to stick)
; FourthPowerUp:

;     cmp IntialPoints1,2 ;check enough points
;     jbe WrongPowerUp
;     sub IntialPoints1,2
;     Set4Dig IntialPoints1,IP1
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage Power4StuckMSG
;     ReadMessage Stuck

;     ;validating stuck value is 0 or 1
;     cmp StuckValue,'0'
;     je check_dataline
;     cmp StuckValue,'1'
;     je check_dataline
;     jmp WrongPowerUp

; check_dataline: ;check if dataline chosen is 0 - 9 and sub 30h to convert to number
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage Power4DataMSG
;     ReadMessage DataLine
;     cmp DataLineValue,'0'
;     jb WrongPowerUp
;     cmp DataLineValue,'9'
;     ja check_letter
;     sub DataLineValue,30h
;     jmp start_execute_power4

; check_letter: ;check if dataline chosen is A - F and sub 37h to convert to number
;     cmp DataLineValue,'A'
;     jb WrongPowerUp
;     cmp DataLineValue,'F'
;     ja WrongPowerUp
;     sub DataLineValue, 37h

; start_execute_power4:
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
;     call excCommand
;     mov Power4Chosen, 1
 
; jmp Resetting1


; ;Clearing all registers
; ;Just calls Zero All
; FifthPowerUp:
;     cmp Power5User1,1
;     jne start_power5

;     ;Check if power up is already used before
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage PowerUsedMSG
;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute
; start_power5:
;     mov Power5Chosen, 1
;     cmp IntialPoints1,30
;     jbe WrongPowerUp
;     sub IntialPoints1,30
;     mov Power5User1,1
;     ZeroALL 1
;     call Refresh
; jmp Resetting1

; ;Message to when you don't have enough points
; WrongPowerUp:
    
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage NoEnoughPtsMsg
    
;     push ax
;     mov ah,0
;     int 16h
;     pop ax

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

; CallExecute:
;     call Refresh ;update register values
;     cmp LevelVariable+2,'2'
;     jne start_execute

;     ;Choose which processor (for level 2)
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage ChooseProc

;     ReadMessage ProcessorChosen

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

;     cmp ProcessorChosen+2,'1'
;     je ChooseProcessorLevel2User1 ;Jumps to power up 1 in Level 1 (same functionality)

; start_execute:   
;     ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
;     call excCommand
; Resetting1:
    
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

;     ;Resetting power-up variables
;     mov Power1Chosen,0
;     mov Power2Chosen,0
;     mov Power3Chosen,0
;     mov Power5Chosen,0

;     ;Check if there's a winner
;     cmp IntialPoints1,0
;     je Ending_WriteCommand
;     cmp IntialPoints2,0
;     je Ending_WriteCommand

;     SetCursor UserCommand1Col,UserCommand1row,0     
;     PrintMessage UserCommandSpaces

;     call Refresh
; ;Same as upwards but for user 2
; start2:  
;     SetCursor UserCommand1Col,UserCommand1row,0     
;     PrintMessage UserCommandSpaces

;     call Refresh



;     mov CurrUser,2

;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage KeyPressPower
;     GetKeyWait GameKeyScanCode,GameKeyAscii

;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces

;     ;Check if PowerUp
;     cmp GameKeyScanCode,F1Scancode
;     je CallExecute2
;     cmp GameKeyScanCode,F2Scancode
;     jne start2

;     ;Choose which power-up
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage KeyPressChoose
;     GetKeyWait PowerUpChosen,GameKeyAscii
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces

;     cmp PowerUpChosen,2
;     je FirstPowerUp2
;     cmp PowerUpChosen,3
;     je SecondPowerUp2
;     cmp PowerUpChosen,4    
;     je ThirdPowerUp2
;     cmp PowerUpChosen,5
;     je FourthPowerUp2
;     cmp PowerUpChosen,6
;     je FifthPowerUp2

;     SetCursor UserCommand1Col,UserCommand1row,0 ;LSA m8yrynyhaa merge mul

;     PrintMessage WrongPowerUpMSG
;     push ax
;     mov ah,0
;     int 16h
;     pop ax
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute2

; ;Command on your own processor (Level 1)
; ;Target value update (Level 2)
; FirstPowerUp2:
;     cmp LevelVariable+2,'1'
;     je FirstPowerUpLevel1_2
;     cmp Power1User2LV2,1
;     jne FirstPowerUpLevel2_2

;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage PowerUsedMSG

;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute2

; FirstPowerUpLevel2_2:
;     cmp IntialPoints2,30
;     jbe WrongPowerUp2
;     mov Power1User2LV2,1
;     Set4Dig IntialPoints2,IP2

;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage EnterTarget
;     ReadMessage NewTargetValue

;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces

;     call ValidateTarget
;     cmp TargetValid,1
;     je change_target2
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage ValueExists
;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute2
; change_target2:
;     sub IntialPoints2,30
;     CopyString NewTargetValue+2,WinnerVariable
;     GetKeyWait ScanCode,ScanCode
;     jmp CallExecute2

; FirstPowerUpLevel1_2:
;     cmp IntialPoints2,5
;     jbe WrongPowerUp2
;     sub IntialPoints2,5
;     Set4Dig IntialPoints2,IP2

; ChooseProcessorLevel2User2:
;     mov Power1Chosen,1
;     mov CurrUser,1
;     ReadCommand UserCommand1,UserCommand2Col,UserCommand2row,Forbidden2Data
;     call excCommand

; jmp WriteCommandNow2

; ;Command on your processor and your opponent processor 
; SecondPowerUp2:

;     cmp IntialPoints2,3
;     jbe WrongPowerUp
;     sub IntialPoints2,3
;     Set4Dig IntialPoints2,IP2
;     mov Power2Chosen,0
;     ReadCommand UserCommand2,UserCommand2Col,UserCommand2row,Forbidden2Data
;     CopyStringDollar UserCommand2,UserComTemp
;     mov Power2Chosen,1
;     call excCommand
;     CopyStringDollar UserComTemp,UserCommand1
;     mov CurrUser,1
;     call excCommand
; jmp WriteCommandNow2


; ;Changing the forbidden character
; ThirdPowerUp2:

;     mov Power3Chosen, 1
;     cmp IntialPoints2,8
;     jbe WrongPowerUp2
;     sub IntialPoints2,8
;     CopyStringDollar Forbidden2,ForbidTemp
;     SetCursor UserCommand2Col,UserCommand2row,0
;     ReadMessage Forbidden2

;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces

;     ReadCommand UserCommand2,UserCommand2Col,UserCommand2row,Forbidden2Data
;     call excCommand

;     CopyStringDollar ForbidTemp,Forbidden2

; jmp WriteCommandNow2

; ;Data lines stuck
; FourthPowerUp2:

;     cmp IntialPoints2,2
;     jbe WrongPowerUp2
;     sub IntialPoints2,2
;     Set4Dig IntialPoints2,IP2
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage Power4StuckMSG
;     ReadMessage Stuck

;     cmp StuckValue,'0'
;     je check_dataline_2
;     cmp StuckValue,'1'
;     je check_dataline_2
;     jmp WrongPowerUp2

; check_dataline_2:
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage Power4DataMSG
;     ReadMessage DataLine
;     cmp DataLineValue,'0'
;     jb WrongPowerUp2
;     cmp DataLineValue,'9'
;     ja check_letter_2
;     sub DataLineValue,30h
;     jmp start_execute_power4_2

; check_letter_2:
;     cmp DataLineValue,'A'
;     jb WrongPowerUp2
;     cmp DataLineValue,'F'
;     ja WrongPowerUp2
;     sub DataLineValue, 37h

; start_execute_power4_2:
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     ReadCommand UserCommand2,UserCommand2Col,UserCommand2row,Forbidden2Data
;     call excCommand
;     mov Power4Chosen, 1

; jmp WriteCommandNow2

; ;Clearing all registers
; FifthPowerUp2:

;     cmp Power5User2,1
;     jne start_power5_2
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage PowerUsedMSG
;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces

;     jmp CallExecute2
; start_power5_2:
;     mov Power5Chosen, 1
;     cmp IntialPoints2,30
;     jbe WrongPowerUp
;     sub IntialPoints2,30
;     mov Power5User2,1
;     ZeroALL 2
;     call Refresh
; jmp WriteCommandNow2

; WrongPowerUp2:
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage NoEnoughPtsMsg
;     push ax
;     mov ah,0
;     int 16h
;     pop ax
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces

; CallExecute2:
;     call Refresh
;     cmp LevelVariable+2,'2'
;     jne start_execute2
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage ChooseProc
;     ReadMessage ProcessorChosen
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     cmp ProcessorChosen+2,'2'
;     je ChooseProcessorLevel2User2
; start_execute2:
;     ReadCommand UserCommand2,UserCommand2Col,UserCommand2row,Forbidden2Data
;     call excCommand

; WriteCommandNow2:
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces

; Resetting2:
;     mov Power1Chosen,0
;     mov Power2Chosen,0
;     mov Power3Chosen,0
;     mov Power5Chosen,0

; Ending_WriteCommand:
;     mov CurrUser,1
;     call Refresh 
; ret  
; endp WriteCommand 

;-------Execute Command-------
excCommand proc
    
pusha
    
    cmp CurrUser,1
    je excCommand_User1
 ; Copying usercommand1 or 2 to CurrCommand (for general usage)
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

    GetStringSize CurCommand,actualSizeCommand ;Calculating command size

    call GetCommand
    cmp found_cmd,0
    je bayz

    ; jumping to found command
    CompareStrings Op_to_Execute,orCommand,4,OK
    cmp OK,1
    je or_loop

    ;Commands with no operands
    CompareStrings Op_to_Execute,clcCommand,4,OK
    cmp OK,1
    je clc_loop

    CompareStrings Op_to_Execute,nopCommand,4,OK
    cmp OK,1
    je nop_loop
     

    ;Specifying & validating operand 1
    call GetOperandOne
    
    CompareStrings Op_to_Execute,pushCommand,5,OK
    cmp OK,1
    je push_loop

    
    CompareStrings Op_to_Execute,imulCommand,5,OK
    cmp OK,1
    je imul_loop


    ; if third is not space, cmd is wrong
    mov dl, 3
    cmp CurCommand+3,' '
    jne bayz
    
    call ValidateOp1
    
    cmp OK,0
    je bayz

    ;single operand commands

    CompareStrings Op_to_Execute,incCommand,4,OK
    cmp OK,1
    je inc_loop

    CompareStrings Op_to_Execute,decCommand,4,OK
    cmp OK,1
    je dec_loop
  
    CompareStrings Op_to_Execute,mulCommand,4,OK
    cmp OK,1
    je mul_loop

    ;Specifying & validating operand 2
    call GetOperandTwo
    call ValidateOp2
    cmp OK,0
    je bayz
    call TypeOp

    call Validate2Operands
    cmp OK,0
    je bayz

    ;Specifying rest of commands
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
    call TypeOp
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
    SetCursor 10,10,0
    PrintMessage Operand1Value
    call LoadOperandValueUser1
    jmp msh_bayz

dec_loop:
    call TypeOp
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
    AsciiToNumber Operand2,0,Operand2Value
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
    AsciiToNumber Operand2,0,Operand2Value
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
    call TypeOp
    cmp Operand1Type,0
    jne bayz
    cmp Operand2Type,0
    jne bayz
    cmp CurrUser,1
    jne user_two_clc
    mov CF1,0
    jmp msh_bayz
user_two_clc:  
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
    AsciiToNumber Operand2,0,Operand2Value
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
    AsciiToNumber Operand2,0,Operand2Value
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
    AsciiToNumber Operand2,0,Operand2Value
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
    AsciiToNumber Operand2,0,Operand2Value
    mov cx,Operand2Value
    mov ch,0
    rcr ax,cl 
    mov Operand1Value,ax
    adc CheckCarry,0
    mov bl,CheckCarry
    mov CF2,bl
    mov CheckCarry,0
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

nop_loop:
    call TypeOp
    cmp Operand1Type,0
    jne bayz
    cmp Operand2Type,0
    jne bayz
    jmp msh_bayz

add_loop:
    Call GetOperandValueUser2
    Call GetOperandValueUser1
    pusha
    mov ax,Operand1Value
    mov bx,Operand2Value
    mov CurrOperandCheckStuck,bx
    CheckDataBus  CurrOperandCheckStuck
    mov bx, CurrOperandCheckStuck
    add ax,bx
    mov Operand1Value,ax
    call  CheckCurrentUserCarry
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

sub_loop:
    Call GetOperandValueUser2
    Call GetOperandValueUser1
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
    Call GetOperandValueUser1
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
    Call GetOperandValueUser1
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
    cmp CurCommand+2,' '
    jne bayz
    ;Validate operand 1
    call GetOperandOne
    call ValidateOp1
    cmp OK,0
    je bayz
    ;Validate operand 2
    call GetOperandTwo
    call ValidateOp2
    cmp OK,0
    je bayz
    call TypeOp
    call Validate2Operands
    cmp OK,0
    je bayz

    Call GetOperandValueUser2
    Call GetOperandValueUser1

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
    Call GetOperandValueUser1

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
    Call GetOperandValueUser1

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

    Call GetOperandValueUser1
    pusha
    mov bx,Operand2Value
    mov ax,bx
    mov Operand1Value,ax
    popa
    call LoadOperandValueUser1
    jmp msh_bayz

mul_loop:
    call TypeOp
    call GetOperandTwo
    isEmptyString Operand2,OK
    cmp OK,0
    je bayz
    call GetOperandValueUser2
    cmp Operand1Type, 1
    je mul_smallReg

    cmp Operand1Type, 3
    je mul_smallReg

    cmp Operand1Type, 4
    je mul_smallReg

    cmp Operand1Type, 2
    je mul_BigReg

    cmp Operand1Type, 5
    je mul_BigReg

mul_smallReg:
pusha
    cmp CurrUser, 2
    je user2_mul
    AsciiToNumber AL_Reg_Value2,0,mul_al 
    jmp kaml
    user2_mul:
    AsciiToNumber AL_Reg_Value1,0,mul_al 
kaml:

    mov ax, mul_al
    mov bx, Operand1Value
    mul bl 
    mov Operand1Value, ax
    cmp CurrUser, 2
    
    je user2_mulAx
    NumbertoAscii4byte Operand1Value,AX_Reg_Value2
    UpdateSmallReg AX_Reg_Value2, AH_Reg_Value2, AL_Reg_Value2
    popa
    jmp msh_bayz
    user2_mulAx:
    NumbertoAscii4byte Operand1Value,AX_Reg_Value1
    UpdateSmallReg AX_Reg_Value1, AH_Reg_Value1, AL_Reg_Value1
    popa
    jmp msh_bayz
mul_BigReg:
pusha
 cmp CurrUser, 2
    je user2_mul2
    AsciiToNumber AX_Reg_Value2,0,mul_al 
    jmp kaml2
    user2_mul2:
    AsciiToNumber AX_Reg_Value1,0,mul_al 
kaml2:
    mov ax, mul_al
    mov bx, Operand1Value
    mul bx
    mov Operand1Value, ax
    mov mul_dx, dx
    cmp CurrUser, 2
    
    je user2_mulAxDX
    NumbertoAscii4byte Operand1Value,AX_Reg_Value2
    UpdateSmallReg AX_Reg_Value2, AH_Reg_Value2, AL_Reg_Value2

    NumbertoAscii4byte mul_dx,DX_Reg_Value2
    UpdateSmallReg DX_Reg_Value2, DH_Reg_Value2, DL_Reg_Value2
 
    popa
    jmp msh_bayz
    user2_mulAxDX:
    NumbertoAscii4byte Operand1Value,AX_Reg_Value1
    UpdateSmallReg AX_Reg_Value1, AH_Reg_Value1, AL_Reg_Value1

    NumbertoAscii4byte mul_dx,DX_Reg_Value1
    UpdateSmallReg DX_Reg_Value1, DH_Reg_Value1, DL_Reg_Value1
 
    popa
    jmp msh_bayz
push_loop:
    call ValidateOp1
    cmp OK,0
    je bayz
    call TypeOp
    cmp Operand1Type, 1
    je bayz
   
    jmp msh_bayz

imul_loop:

    call ValidateOp1
    cmp OK,0
    je bayz
    call TypeOp
    call GetOperandTwo
    isEmptyString Operand2,OK
    cmp OK,0
    je bayz
    call GetOperandValueUser2
    cmp Operand1Type, 1
    je imul_smallReg

    cmp Operand1Type, 3
    je imul_smallReg

    cmp Operand1Type, 4
    je imul_smallReg

    cmp Operand1Type, 2
    je imul_BigReg

    cmp Operand1Type, 5
    je imul_BigReg

imul_smallReg:
pusha
    cmp CurrUser, 2
    je user2_imul
    AsciiToNumber AL_Reg_Value2,0,mul_al 
    jmp ikaml
    user2_imul:
    AsciiToNumber AL_Reg_Value1,0,mul_al 
ikaml:

    mov ax, mul_al
    mov bx, Operand1Value
    imul bl 
    mov Operand1Value, ax
    cmp CurrUser, 2
    
    je user2_imulAx
    NumbertoAscii4byte Operand1Value,AX_Reg_Value2
    UpdateSmallReg AX_Reg_Value2, AH_Reg_Value2, AL_Reg_Value2
    popa
    jmp msh_bayz
    user2_imulAx:
    NumbertoAscii4byte Operand1Value,AX_Reg_Value1
    UpdateSmallReg AX_Reg_Value1, AH_Reg_Value1, AL_Reg_Value1
    popa
    jmp msh_bayz
imul_BigReg:
pusha
 cmp CurrUser, 2
    je user2_imul2
    AsciiToNumber AX_Reg_Value2,0,mul_al 
    jmp ikaml2
    user2_imul2:
    AsciiToNumber AX_Reg_Value1,0,mul_al 
ikaml2:
    mov ax, mul_al
    mov bx, Operand1Value
    imul bx
    mov Operand1Value, ax
    mov mul_dx, dx
    cmp CurrUser, 2
    
    je user2_imulAxDX
    NumbertoAscii4byte Operand1Value,AX_Reg_Value2
    UpdateSmallReg AX_Reg_Value2, AH_Reg_Value2, AL_Reg_Value2

     NumbertoAscii4byte mul_dx,DX_Reg_Value2
    UpdateSmallReg DX_Reg_Value2, DH_Reg_Value2, DL_Reg_Value2
 
    popa
    jmp msh_bayz
    user2_imulAxDX:
    NumbertoAscii4byte Operand1Value,AX_Reg_Value1
    UpdateSmallReg AX_Reg_Value1, AH_Reg_Value1, AL_Reg_Value1

    NumbertoAscii4byte mul_dx,DX_Reg_Value1
    UpdateSmallReg DX_Reg_Value1, DH_Reg_Value1, DL_Reg_Value1
 
    popa

jmp msh_bayz
bayz:  
    cmp CurrUser,2
    je bayz_user2
    cmp Power1Chosen,1
    jne User1true
    dec IntialPoints2
    Set4Dig IntialPoints2,IP2
    jmp msh_bayz
User1true:
    dec IntialPoints1
    Set4Dig IntialPoints1,IP1
    jmp msh_bayz

bayz_user2:
    cmp Power2Chosen, 1
    je msh_bayz
    cmp Power1Chosen, 1
    jne User2true
    dec IntialPoints1
    Set4Dig IntialPoints1,IP1
    jmp msh_bayz
User2true:
    dec IntialPoints2
    Set4Dig IntialPoints2,IP2

  

msh_bayz:
EmptyTheString UserCommand1Data,12
EmptyTheString UserCommand2Data,12
EmptyTheString CurCommand,14

EmptyTheString Operand1,7
EmptyTheString Operand2,7

mov Operand1Value, 0
mov Operand2Value, 0
call Refresh

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
    CompareStrings Op_to_Execute,pushCommand,5,OK
    cmp OK,1
    je setSi3
    CompareStrings Op_to_Execute,imulCommand,5,OK
    cmp OK,1
    je setSi3
    mov si,2
    mov OK,0
    jmp findLetter
    setSi3:
    mov OK,0
    mov si,3
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
      cmp bx,76
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
    lea si,pushCommand
    lea di,CurCommand
    mov cx,5
    REPE CMPSB
    cmp cx,0
je foundPush
    lea si,imulCommand
    lea di,CurCommand
    mov cx,5
    REPE CMPSB
    cmp cx,0
je foundImul
jmp Notfound_push
     
 foundPush:   
    lea si,pushCommand
    lea di,Op_to_Execute 
    mov cx,5
    rep MOVSB 
    mov found_cmd,1
    jmp finished  

foundImul:
    
    lea si,imulCommand
    lea di,Op_to_Execute 
    mov cx,5
    rep MOVSB 
    mov found_cmd,1
    jmp finished  


Notfound_push:
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
      GetStringSize Operand1,Operand1Size


compare_registers:
      ;cmp Operand1Size,2
      ;jne compare_based
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
      ;cmp Operand1Size,4
      ;jne compare_memory
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
      ;cmp Operand1Size,3
      ;jne not_found_op1
      lea si,AX_op[bx]
      lea di,Operand1
      mov cx,3
      REPE CMPSB
      cmp cx,0
      je found_op1
      add bx,4
      cmp bx,83
      je compare_relative
      jmp compare_memory

compare_relative:
      lea si,AX_op[bx]
      lea di,Operand1
      mov cx,6
      REPE CMPSB
      cmp cx,0
      je found_op1
      add bx,7
      cmp bx,167
      je not_found_op1
      jmp compare_relative

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
      je compare_relative2
      jmp compare_memory2

compare_relative2:
      lea si,AX_op[bx]
      lea di,Operand2
      mov cx,6
      REPE CMPSB
      cmp cx,0
      je found_op2
      add bx,7
      cmp bx,167
      je compare_immediateNumber2
      jmp compare_relative2

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
    CompareStrings Operand1,BXRelOne,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,BXRelTwo,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,BXRelThr,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,BXRelFour,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,SIRelOne,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,SIRelTwo,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,SIRelThr,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,SIRelFour,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,DIRelOne,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,DIRelTwo,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,DIRelThr,7,OK
    cmp OK,1
    je mem_op1
    CompareStrings Operand1,DIRelFour,7,OK
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
    CompareStrings Operand2,BXRelOne,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,BXRelTwo,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,BXRelThr,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,BXRelFour,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,SIRelOne,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,SIRelTwo,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,SIRelThr,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,SIRelFour,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,DIRelOne,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,DIRelTwo,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,DIRelThr,7,OK
    cmp OK,1
    je mem_op2
    CompareStrings Operand2,DIRelFour,7,OK
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


;-------Get Value from Operand2--------
GetOperandValueUser1 proc

pusha
    ;checking on based relative
    CompareStrings Operand2,BXRelOne,6,OK
    cmp OK,1
    je BXRelOneisOP1
    CompareStrings Operand2,BXRelTwo,6,OK
    cmp OK,1
    je BXRelTwoisOP1
    CompareStrings Operand2,BXRelThr,6,OK
    cmp OK,1
    je BXRelThrisOP1
    CompareStrings Operand2,BXRelFour,6,OK
    cmp OK,1
    je BXRelFourisOP1

    CompareStrings Operand2,SIRelOne,6,OK
    cmp OK,1
    je SIRelOneisOP1
    CompareStrings Operand2,SIRelTwo,6,OK
    cmp OK,1
    je SIRelTwoisOP1
    CompareStrings Operand2,SIRelThr,6,OK
    cmp OK,1
    je SIRelThrisOP1
    CompareStrings Operand2,SIRelFour,6,OK
    cmp OK,1
    je SIRelFourisOP1

    CompareStrings Operand2,DIRelOne,6,OK
    cmp OK,1
    je DIRelOneisOP1
    CompareStrings Operand2,DIRelTwo,6,OK
    cmp OK,1
    je DIRelTwoisOP1
    CompareStrings Operand2,DIRelThr,6,OK
    cmp OK,1
    je DIRelThrisOP1
    CompareStrings Operand2,DIRelFour,6,OK
    cmp OK,1
    je DIRelFourisOP1
    
    CompareStrings Operand2,BX_op_idx,5,OK
    cmp OK,1
    je BXidxisOP1
    CompareStrings Operand2,SI_op_idx,5,OK
    cmp OK,1
    je SIidxisOP1
    CompareStrings Operand2,DI_op_idx,5,OK
    cmp OK,1
    je DIidxisOP1
    

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
    cmp CurrUser,2
       je user2_bxidx2
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser1
user2_bxidx2:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser1

SIidxisOP1:
 cmp CurrUser,2
       je user2_siidx2
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser1
user2_siidx2:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser1

DIidxisOP1:
cmp CurrUser,2
       je user2_diidx2
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser1
user2_diidx2:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser1

BXRelOneisOP1:
       cmp CurrUser,2
       je user2_bxrelone2
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxrelone2:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

BXRelTwoisOP1:
       cmp CurrUser,2
       je user2_bxreltwo2
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxreltwo2:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

BXRelThrisOP1:
       cmp CurrUser,2
       je user2_bxrelthr2
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxrelthr2:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

BXRelFourisOP1:
       cmp CurrUser,2
       je user2_bxrelfour2
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxrelfour2:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIRelOneisOP1:
       cmp CurrUser,2
       je user2_sirelone2
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_sirelone2:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIRelTwoisOP1:
       cmp CurrUser,2
       je user2_sireltwo2
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_sireltwo2:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIRelThrisOP1:
       cmp CurrUser,2
       je user2_sirelthr2
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_sirelthr2:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIRelFourisOP1:
       cmp CurrUser,2
       je user2_sirelfour2
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_sirelfour2:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIRelOneisOP1:
       cmp CurrUser,2
       je user2_direlone2
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_direlone2:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIRelTwoisOP1:
       cmp CurrUser,2
       je user2_direltwo2
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_direltwo2:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIRelThrisOP1:
       cmp CurrUser,2
       je user2_direlthr2
       SetCursor 22,14,0
       PrintMessage pushCommand
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_direlthr2:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIRelFourisOP1:
       cmp CurrUser,2
       je user2_direlfour2
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_direlfour2:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type2
       cmp TemporaryCheckMem,1
       je Set_Mem_Type2
       cmp TemporaryCheckMem,2
       je Set_Mem_Type2
       cmp TemporaryCheckMem,3
       je Set_Mem_Type2
       cmp TemporaryCheckMem,4
       je Set_Mem_Type2
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2


OP2Imm:
    AsciiToNumber Operand2,0,Operand2Value
    jmp finished_GetOperandValueUser1 

Set_Mem_Type2:
    pusha
    mov ax,TemporaryCheckMem
    mov Operand2TypeInMemory,al
    popa

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

    ;checking on based relative
    CompareStrings Operand1,BXRelOne,6,OK
    cmp OK,1
    je BXRelOneisOP2
    CompareStrings Operand1,BXRelTwo,6,OK
    cmp OK,1
    je BXRelTwoisOP2
    CompareStrings Operand1,BXRelThr,6,OK
    cmp OK,1
    je BXRelThrisOP2
    CompareStrings Operand1,BXRelFour,6,OK
    cmp OK,1
    je BXRelFourisOP2

    CompareStrings Operand1,SIRelOne,6,OK
    cmp OK,1
    je SIRelOneisOP2
    CompareStrings Operand1,SIRelTwo,6,OK
    cmp OK,1
    je SIRelTwoisOP2
    CompareStrings Operand1,SIRelThr,6,OK
    cmp OK,1
    je SIRelThrisOP2
    CompareStrings Operand1,SIRelFour,6,OK
    cmp OK,1
    je SIRelFourisOP2

    CompareStrings Operand1,DIRelOne,6,OK
    cmp OK,1
    je DIRelOneisOP2
    CompareStrings Operand1,DIRelTwo,6,OK
    cmp OK,1
    je DIRelTwoisOP2
    CompareStrings Operand1,DIRelThr,6,OK
    cmp OK,1
    je DIRelThrisOP2
    CompareStrings Operand1,DIRelFour,6,OK
    cmp OK,1
    je DIRelFourisOP2

    ;checking on indirect
    CompareStrings Operand1,BX_op_idx,4,OK
    cmp OK,1
    je BXidxisOP2
    CompareStrings Operand1,SI_op_idx,4,OK
    cmp OK,1
    je SIidxisOP2
    CompareStrings Operand1,DI_op_idx,4,OK
    cmp OK,1
    je DIidxisOP2


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
       cmp CurrUser,2
       je user2_bxidx
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxidx:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIidxisOP2:
cmp CurrUser,2
       je user2_siidx
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_siidx:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIidxisOP2:
cmp CurrUser,2
       je user2_diidx
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_diidx:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

BXRelOneisOP2:
       cmp CurrUser,2
       je user2_bxrelone
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxrelone:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

BXRelTwoisOP2:
       cmp CurrUser,2
       je user2_bxreltwo
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxreltwo:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

BXRelThrisOP2:
       cmp CurrUser,2
       je user2_bxrelthr
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxrelthr:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

BXRelFourisOP2:
       cmp CurrUser,2
       je user2_bxrelfour
       AsciiToNumber BX_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_bxrelfour:
       AsciiToNumber BX_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIRelOneisOP2:
       cmp CurrUser,2
       je user2_sirelone
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_sirelone:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIRelTwoisOP2:
       cmp CurrUser,2
       je user2_sireltwo
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_sireltwo:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIRelThrisOP2:
       cmp CurrUser,2
       je user2_sirelthr
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_sirelthr:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

SIRelFourisOP2:
       cmp CurrUser,2
       je user2_sirelfour
       AsciiToNumber SI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_sirelfour:
       AsciiToNumber SI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIRelOneisOP2:
       cmp CurrUser,2
       je user2_direlone
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_direlone:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,1
       PrintMessage TemporaryCheckMem
       SetCursor 22,14,0
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIRelTwoisOP2:
       cmp CurrUser,2
       je user2_direltwo
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_direltwo:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,2
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIRelThrisOP2:
       cmp CurrUser,2
       je user2_direlthr
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_direlthr:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,3
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

DIRelFourisOP2:
       cmp CurrUser,2
       je user2_direlfour
       AsciiToNumber DI_Reg_Value2,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
       mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2
user2_direlfour:
       AsciiToNumber DI_Reg_Value1,0,TemporaryCheckMem
       add TemporaryCheckMem,4
       cmp TemporaryCheckMem,0
       je Set_Mem_Type
       cmp TemporaryCheckMem,1
       je Set_Mem_Type
       cmp TemporaryCheckMem,2
       je Set_Mem_Type
       cmp TemporaryCheckMem,3
       je Set_Mem_Type
       cmp TemporaryCheckMem,4
       je Set_Mem_Type
        mov TemporaryCheckMem,7
       jmp finished_GetOperandValueUser2

Set_Mem_Type:
    pusha
    mov ax,TemporaryCheckMem
    mov Operand1TypeInMemory,al
    popa
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
    CompareStrings Operand1,BXRelOne,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,BXRelTwo,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,BXRelThr,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,BXRelFour,6,OK
    cmp OK,1
    je BXidxisLoad

    CompareStrings Operand1,SIRelOne,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,SIRelTwo,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,SIRelThr,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,SIRelFour,6,OK
    cmp OK,1
    je BXidxisLoad

    CompareStrings Operand1,DIRelOne,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,DIRelTwo,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,DIRelThr,6,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,DIRelFour,6,OK
    cmp OK,1
    je BXidxisLoad
    
    CompareStrings Operand1,BX_op_idx,4,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,SI_op_idx,4,OK
    cmp OK,1
    je BXidxisLoad
    CompareStrings Operand1,DI_op_idx,4,OK
    cmp OK,1
    je BXidxisLoad


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
    cmp TemporaryCheckMem,4
    ja finished_LoadOperandValueUser
    jmp Load_OP1MEM
 ;SIidxisLoad:
  ;  cmp TemporaryCheckMem,4
   ; ja finished_LoadOperandValueUser
   ; jmp Load_OP1MEM
 ;DIidxisLoad:
  ;  cmp TemporaryCheckMem,4
  ;  ja finished_LoadOperandValueUser
  ;  jmp Load_OP1MEM
;BXRelOneisLoad:


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

;-------Game Screen-------
;Key pressed if F1 -> write command directly
;Key pressed if F2 -> choose power-up first
GameScreen proc

call HelpScreen
changeGraphicsmode
mov GameInvitationRec,0
mov GameInvitationSent,0
ZeroALL 0
set_start:
Set4Dig IntialPoints1,IP1
Set4Dig IntialPoints2,IP2
GetLevel 
cmp LevelVariable+2,'2'
je set_start
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
    ;AsciiToNumber IP2,0,IntialPoints2
    Set4Dig IntialPoints2,IP2
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


    Call WriteCommand
    call Game
    mov CurrUser,2
    call Game
    mov CurrUser,1
 
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
        ret
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

ValidateTarget proc
pusha
    mov TargetValid,0
    CompareStrings AX_Reg_Value1,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings BX_Reg_Value1,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings CX_Reg_Value1,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings DX_Reg_Value1,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings SI_Reg_Value1,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings DI_Reg_Value1,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings BP_Reg_Value1,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings SP_Reg_Value1,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings AX_Reg_Value2,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings BX_Reg_Value2,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings CX_Reg_Value2,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings DX_Reg_Value2,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings SI_Reg_Value2,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings DI_Reg_Value2,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings BP_Reg_Value2,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    CompareStrings SP_Reg_Value2,NewTargetValue+2,5,OK
    cmp OK,1
    je invalid
    mov TargetValid,1
invalid:
popa
ret
endp ValidateTarget 

PrintStatusBar proc 
pusha
    cmp ChatInvitationRec,1
    jne check_game_invitation
    SetCursor 0, 21, 0
    PrintMessage ChatInvitationMessage
    jmp end_status
check_game_invitation:
    cmp GameInvitationRec,1
    jne end_status
    SetCursor 0, 21, 0
    PrintMessage GameInvitationRec
end_status:
popa
ret
endp PrintStatusBar

WriteCommand1 proc
start1:

    ;Get Key for F1 or F2
    ;F1 for command F2 for power-up
    
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage KeyPressPower
    GetKeyWait GameKeyScanCode,GameKeyAscii

    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces

    ; Check if PowerUp
    ; If F1: jump to CallExecute i.e: directly execute command
    ; If F2: jump to start1 i.e: choose power-up first
    cmp GameKeyScanCode,F1Scancode
    je CallExecute
    cmp GameKeyScanCode,F2Scancode
    jne start1

    ;Choose which power-up
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage KeyPressChoose

    GetKeyWait PowerUpChosen,GameKeyAscii
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces


    cmp PowerUpChosen,2 ;2 is scan-code for 1 on keyboard
    je FirstPowerUp
    cmp PowerUpChosen,3 ;3 is scan-code for 2 on keyboard
    je SecondPowerUp
    cmp PowerUpChosen,4 ;4 is scan-code for 3 on keyboard
    je ThirdPowerUp
    cmp PowerUpChosen,5 ;5 is scan-code for 4 on keyboard
    je FourthPowerUp
    cmp PowerUpChosen,6 ;6 is scan-code for 5 on keyboard
    je FifthPowerUp
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage WrongPowerUpMSG

    ;Wait any key press to proceed to execute 
    push ax
    mov ah,0
    int 16h
    pop ax

    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces
    jmp CallExecute

;Command on your own processor (Level 1)
;Changing target value (Level 2)
FirstPowerUp:

    cmp LevelVariable+2,'1' 
    je FirstPowerUpLevel1 
    cmp Power1User1LV2,1 ; Check if first power up in level 2 is already used
    jne FirstPowerUpLevel2 ; if used, proceed to execute command & skip power up

    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage PowerUsedMSG

    GetKeyWait ScanCode,ScanCode
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces
    jmp CallExecute

FirstPowerUpLevel2:
    cmp IntialPoints1,30 ;check if there's enough points

    jbe WrongPowerUp
    mov Power1User1LV2,1
    Set4Dig IntialPoints1,IP1

    ; Reading new target value
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage EnterTarget
    ReadMessage NewTargetValue

    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces

    ; Validating input target value
    call ValidateTarget
    cmp TargetValid,1
    je change_target

    ; Notifying user new target value is invalid
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage ValueExists
    GetKeyWait ScanCode,ScanCode
    SetCursor UserCommand2Col,UserCommand2row,0
    PrintMessage UserCommandSpaces
    jmp CallExecute

change_target:
    sub IntialPoints1,30
    LowertoUpperSize NewTargetValue,4
    CopyString NewTargetValue,WinnerVariable ;copying value to actual WinnerVariable
    jmp CallExecute

FirstPowerUpLevel1:
    cmp IntialPoints1,5
    jbe WrongPowerUp
    sub IntialPoints1,5
    Set4Dig IntialPoints1,IP1

ChooseProcessorLevel2User1:  ;label to execute command on own processor level 2 without points deduction
    mov Power1Chosen,1
    mov CurrUser,2
    ReadCommand UserCommand2,UserCommand1Col,UserCommand1row,Forbidden1Data
    call excCommand

jmp Resetting1


;Command on your processor and your opponent processor 
SecondPowerUp:

    cmp IntialPoints1,3 ;check enough points
    jbe WrongPowerUp
    sub IntialPoints1,3
    Set4Dig IntialPoints1,IP1
    mov Power2Chosen,0
    ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
    CopyStringDollar UserCommand1,UserComTemp
    mov Power2Chosen,1
    call excCommand
    CopyStringDollar UserComTemp,UserCommand2
    mov CurrUser,2
    call excCommand

jmp Resetting1


;Changing the forbidden character
ThirdPowerUp:

    mov Power3Chosen, 1
    cmp IntialPoints1,8 ;check enough points
    jbe WrongPowerUp
    sub IntialPoints1,8
    Set4Dig IntialPoints1,IP1

    ;Reading new forbidden
    CopyStringDollar Forbidden1,ForbidTemp
    SetCursor UserCommand1Col,UserCommand1row,0
    ReadMessage Forbidden1
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces
    ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data

    call excCommand
    CopyStringDollar ForbidTemp,Forbidden1

jmp Resetting1


;Data lines stuck
;Stuck value has 0 or 1
;DataLine value has 0-16 (which bit to stick)
FourthPowerUp:

    cmp IntialPoints1,2 ;check enough points
    jbe WrongPowerUp
    sub IntialPoints1,2
    Set4Dig IntialPoints1,IP1
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage Power4StuckMSG
    ReadMessage Stuck

    ;validating stuck value is 0 or 1
    cmp StuckValue,'0'
    je check_dataline
    cmp StuckValue,'1'
    je check_dataline
    jmp WrongPowerUp

check_dataline: ;check if dataline chosen is 0 - 9 and sub 30h to convert to number
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage Power4DataMSG
    ReadMessage DataLine
    cmp DataLineValue,'0'
    jb WrongPowerUp
    cmp DataLineValue,'9'
    ja check_letter
    sub DataLineValue,30h
    jmp start_execute_power4

check_letter: ;check if dataline chosen is A - F and sub 37h to convert to number
    cmp DataLineValue,'A'
    jb WrongPowerUp
    cmp DataLineValue,'F'
    ja WrongPowerUp
    sub DataLineValue, 37h

start_execute_power4:
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces
    ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
    call excCommand
    mov Power4Chosen, 1
 
jmp Resetting1


;Clearing all registers
;Just calls Zero All
FifthPowerUp:
    cmp Power5User1,1
    jne start_power5

    ;Check if power up is already used before
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage PowerUsedMSG
    GetKeyWait ScanCode,ScanCode
    SetCursor UserCommand2Col,UserCommand2row,0
    PrintMessage UserCommandSpaces
    jmp CallExecute
start_power5:
    mov Power5Chosen, 1
    cmp IntialPoints1,30
    jbe WrongPowerUp
    sub IntialPoints1,30
    mov Power5User1,1
    ZeroALL 1
    call Refresh
jmp Resetting1

;Message to when you don't have enough points
WrongPowerUp:
    
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage NoEnoughPtsMsg
    
    push ax
    mov ah,0
    int 16h
    pop ax

    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces

CallExecute:
    call Refresh ;update register values
    cmp LevelVariable+2,'2'
    jne start_execute

    ;Choose which processor (for level 2)
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage ChooseProc

    ReadMessage ProcessorChosen

    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces

    cmp ProcessorChosen+2,'1'
    je ChooseProcessorLevel2User1 ;Jumps to power up 1 in Level 1 (same functionality)

start_execute:   
    ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
    call excCommand
Resetting1:
    
    SetCursor UserCommand1Col,UserCommand1row,0
    PrintMessage UserCommandSpaces

    ;Resetting power-up variables
    mov Power1Chosen,0
    mov Power2Chosen,0
    mov Power3Chosen,0
    mov Power5Chosen,0

    ;Check if there's a winner
    cmp IntialPoints1,0
    je Ending_WriteCommand
    cmp IntialPoints2,0
    je Ending_WriteCommand

    SetCursor UserCommand1Col,UserCommand1row,0     
    PrintMessage UserCommandSpaces

    call Refresh
Ending_WriteCommand:
ret  
endp WriteCommand1 

; WriteCommand2 proc
; start2:

;     ;Get Key for F1 or F2
;     ;F1 for command F2 for power-up
;     ReceiveAllValues 
;      call Refresh 
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage KeyPressPower
;     GetKeyWait GameKeyScanCode,GameKeyAscii

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

;     ; Check if PowerUp
;     ; If F1: jump to CallExecute i.e: directly execute command
;     ; If F2: jump to start1 i.e: choose power-up first
;     cmp GameKeyScanCode,F1Scancode
;     je CallExecute2
;     cmp GameKeyScanCode,F2Scancode
;     jne start2

;     ;Choose which power-up
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage KeyPressChoose

;     GetKeyWait PowerUpChosen,GameKeyAscii
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces


;     cmp PowerUpChosen,2 ;2 is scan-code for 1 on keyboard
;     je FirstPowerUp2
;     cmp PowerUpChosen,3 ;3 is scan-code for 2 on keyboard
;     je SecondPowerUp2
;     cmp PowerUpChosen,4 ;4 is scan-code for 3 on keyboard
;     je ThirdPowerUp2
;     cmp PowerUpChosen,5 ;5 is scan-code for 4 on keyboard
;     je FourthPowerUp2
;     cmp PowerUpChosen,6 ;6 is scan-code for 5 on keyboard
;     je FifthPowerUp2
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage WrongPowerUpMSG

;     ;Wait any key press to proceed to execute 
;     push ax
;     mov ah,0
;     int 16h
;     pop ax

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute2

; ;Command on your own processor (Level 1)
; ;Changing target value (Level 2)
; FirstPowerUp2:

;     cmp LevelVariable+2,'1' 
;     je FirstPowerUpLevel1_2
;     cmp Power1User1LV2,1 ; Check if first power up in level 2 is already used
;     jne FirstPowerUpLevel2_2 ; if used, proceed to execute command & skip power up

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage PowerUsedMSG

;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute2

; FirstPowerUpLevel2_2:
;     cmp IntialPoints1,30 ;check if there's enough points

;     jbe WrongPowerUp2
;     mov Power1User1LV2,1
;     Set4Dig IntialPoints1,IP1

;     ; Reading new target value
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage EnterTarget
;     ReadMessage NewTargetValue

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

;     ; Validating input target value
;     call ValidateTarget
;     cmp TargetValid,1
;     je change_target2

;     ; Notifying user new target value is invalid
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage ValueExists
;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute2

; change_target2:
;     sub IntialPoints1,30
;     LowertoUpperSize NewTargetValue,4
;     CopyString NewTargetValue,WinnerVariable ;copying value to actual WinnerVariable
;     jmp CallExecute2

; FirstPowerUpLevel1_2:
;     cmp IntialPoints1,5
;     jbe WrongPowerUp2
;     sub IntialPoints1,5
;     Set4Dig IntialPoints1,IP1

; ChooseProcessorLevel2User1:  ;label to execute command on own processor level 2 without points deduction
;     mov Power1Chosen,1
;     mov CurrUser,2
;     ReadCommand UserCommand2,UserCommand1Col,UserCommand1row,Forbidden1Data
;     call excCommand

; jmp Resetting2


; ;Command on your processor and your opponent processor 
; SecondPowerUp2:

;     cmp IntialPoints1,3 ;check enough points
;     jbe WrongPowerUp2
;     sub IntialPoints1,3
;     Set4Dig IntialPoints1,IP1
;     mov Power2Chosen,0
;     ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
;     CopyStringDollar UserCommand1,UserComTemp
;     mov Power2Chosen,1
;     call excCommand
;     CopyStringDollar UserComTemp,UserCommand2
;     mov CurrUser,2
;     call excCommand

; jmp Resetting2


; ;Changing the forbidden character
; ThirdPowerUp2:

;     mov Power3Chosen, 1
;     cmp IntialPoints1,8 ;check enough points
;     jbe WrongPowerUp2
;     sub IntialPoints1,8
;     Set4Dig IntialPoints1,IP1

;     ;Reading new forbidden
;     CopyStringDollar Forbidden1,ForbidTemp
;     SetCursor UserCommand1Col,UserCommand1row,0
;     ReadMessage Forbidden1
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data

;     call excCommand
;     CopyStringDollar ForbidTemp,Forbidden1

; jmp Resetting2


; ;Data lines stuck
; ;Stuck value has 0 or 1
; ;DataLine value has 0-16 (which bit to stick)
; FourthPowerUp2:

;     cmp IntialPoints1,2 ;check enough points
;     jbe WrongPowerUp2
;     sub IntialPoints1,2
;     Set4Dig IntialPoints1,IP1
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage Power4StuckMSG
;     ReadMessage Stuck

;     ;validating stuck value is 0 or 1
;     cmp StuckValue,'0'
;     je check_dataline2
;     cmp StuckValue,'1'
;     je check_dataline2
;     jmp WrongPowerUp2

; check_dataline2: ;check if dataline chosen is 0 - 9 and sub 30h to convert to number
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage Power4DataMSG
;     ReadMessage DataLine
;     cmp DataLineValue,'0'
;     jb WrongPowerUp2
;     cmp DataLineValue,'9'
;     ja check_letter2
;     sub DataLineValue,30h
;     jmp start_execute_power4_2

; check_letter2: ;check if dataline chosen is A - F and sub 37h to convert to number
;     cmp DataLineValue,'A'
;     jb WrongPowerUp
;     cmp DataLineValue,'F'
;     ja WrongPowerUp
;     sub DataLineValue, 37h

; start_execute_power4_2:
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces
;     ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
;     call excCommand
;     mov Power4Chosen, 1
 
; jmp Resetting2


; ;Clearing all registers
; ;Just calls Zero All
; FifthPowerUp2:
;     cmp Power5User1,1
;     jne start_power5_2

;     ;Check if power up is already used before
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage PowerUsedMSG
;     GetKeyWait ScanCode,ScanCode
;     SetCursor UserCommand2Col,UserCommand2row,0
;     PrintMessage UserCommandSpaces
;     jmp CallExecute
; start_power5_2:
;     mov Power5Chosen, 1
;     cmp IntialPoints1,30
;     jbe WrongPowerUp
;     sub IntialPoints1,30
;     mov Power5User1,1
;     ZeroALL 1
;     call Refresh
; jmp Resetting2

; ;Message to when you don't have enough points
; WrongPowerUp2:
    
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage NoEnoughPtsMsg
    
;     push ax
;     mov ah,0
;     int 16h
;     pop ax

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

; CallExecute2:
;     call Refresh ;update register values
;     cmp LevelVariable+2,'2'
;     jne start_execute

;     ;Choose which processor (for level 2)
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage ChooseProc

;     ReadMessage ProcessorChosen

;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

;     cmp ProcessorChosen+2,'1'
;     je ChooseProcessorLevel2User1 ;Jumps to power up 1 in Level 1 (same functionality)

; start_execute2:   
;     ReadCommand UserCommand1,UserCommand1Col,UserCommand1row,Forbidden1Data
;     call excCommand
; Resetting2:
;     SendAllValues
;     SetCursor UserCommand1Col,UserCommand1row,0
;     PrintMessage UserCommandSpaces

;     ;Resetting power-up variables
;     mov Power1Chosen,0
;     mov Power2Chosen,0
;     mov Power3Chosen,0
;     mov Power5Chosen,0

;     ;Check if there's a winner
;     cmp IntialPoints1,0
;     je Ending_WriteCommand2
;     cmp IntialPoints2,0
;     je Ending_WriteCommand2

;     SetCursor UserCommand1Col,UserCommand1row,0     
;     PrintMessage UserCommandSpaces
; Ending_WriteCommand2:
; ret  
; endp WriteCommand2

end main