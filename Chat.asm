;Author:Quantum Team
;Date:08-12-2016
;Chat module
;----------------------------------------------

;
;Macros
;
;Draws chat area
DrawChatArea MACRO Y, Username
    ;Draw separator line
    DrawLine 0, Y, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
    
    ;Print user name
    SetCursorPos ChatMargin, Y+1, CurrentPage
    PrintString Username
    
    ;Draw line under username
    DrawLine 0, Y+2, 1, MaxUserNameSize+1, ChatLineChar, ChatLineColor, CurrentPage
ENDM DrawChatArea
;===============================================================

;Draw the chatting information bar
DrawInfoBar MACRO Y
    ;Draw begin separator
    DrawLine 0, Y, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
    ;Print info message
    SetCursorPos ChatMargin, Y+1, CurrentPage
    PrintString EndChatMsg
    ;Draw end separator
    DrawLine 0, Y+2, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
ENDM DrawInfoBar
;===============================================================

;Process a given user input. Called from within a procedure
ProcessInput MACRO Char, X, Y, OffsetY
    LOCAL CheckEscape, CheckEnter, CheckBackspace, CheckPrintable, AdjustCursorPos, Scroll, Return
    
    ;Check if ESC is pressed
    CheckEscape:
    CMP Char, ESC_AsciiCode
    JNE CheckEnter
    MOV IsChatEnded, 1
    RET
    ;==================================
    
    ;Check if Enter is pressed
    CheckEnter:
    CMP Char, Enter_AsciiCode
    JNE CheckBackspace
    MOV X, ChatMargin
    INC Y
    JMP Scroll
    ;==================================
    
    ;Check if Backspace is pressed
    CheckBackspace:
    CMP Char, Back_AsciiCode
    JNE CheckPrintable
    CMP X, ChatMargin
    JBE CheckPrintable
    MOV Char, ' '
    DEC X
    SetCursorPos X, Y, CurrentPage
    PrintChar Char
    RET
    ;==================================
    
    ;Check if printable character is pressed
    CheckPrintable:
    CMP Char, ' '   ;Compare with lowest printable ascii value
    JB Return
    CMP Char, '~'   ;Compare with highest printable ascii value
    JA Return
    
    ;Print char
    SetCursorPos X, Y, CurrentPage
    PrintChar Char
    ;==================================
    
    ;Adjust new cursor position after printing the character
    AdjustCursorPos:
    INC X
    CMP X, ChatAreaWidth-ChatMargin
    JL Return
    MOV X, ChatMargin
    INC Y
    ;==================================
    
    ;Scroll chat area one step up if chat area is full
    Scroll:
    CMP Y, ChatAreaHeight+OffsetY-1
    JBE Return
    DEC Y
    ScrollUp ChatMargin, OffsetY+3, ChatAreaWidth-ChatMargin, ChatAreaHeight+OffsetY-1, 1
    ;==================================
    
    Return:
ENDM ProcessInput
;===============================================================


;added macros // Farah

;; ********************************************** Consts ******************************************

;Main constants
WindowWidth                 EQU     80
WindowHeight                EQU     25
CurrentPage                 EQU     0
MaxUserNameSize             EQU     16

;Keys codes
ESC_ScanCode                EQU     01H
ESC_AsciiCode               EQU     1BH
Enter_ScanCode              EQU     1CH
Enter_AsciiCode             EQU     0DH
Back_ScanCode               EQU     0EH
Back_AsciiCode              EQU     08H
F1_ScanCode                 EQU     3BH
F2_ScanCode                 EQU     3CH
F3_ScanCode                 EQU     3DH
F4_ScanCode                 EQU     3EH
UP_ScanCode                 EQU     48H
UP_AsciiCode                EQU     2H      ;Application defined
DOWN_ScanCode               EQU     50H
DOWN_AsciiCode              EQU     1H      ;Application defined
W_ScanCode                  EQU     11H
S_ScanCode                  EQU     1FH

;Application key codes
KeyGameLevel                EQU     10000000B
KeyScore1                   EQU     10010000B
KeyScore2                   EQU     10100000B
KeyPaddleY1                 EQU     10110000B
KeyPaddleY2                 EQU     11000000B
KeyBallPosY                 EQU     11010000B
KeyBallPosLestX             EQU     11100000B
KeyBallPosMostX             EQU     11110000B


;; ********************************************** Graphics ******************************************
;Change video mode: 
;03H for 80x25 text mode (16 colors, 8 pages)
;04H for 320x200 graphics mode (4 colors)
;06H for 640x200 graphics mode (2 colors)
;13H for 320x200 graphics mode (256 colors)
SetVideoMode MACRO Mode
    MOV AH, 00H
    MOV AL, Mode
    INT 10H
ENDM SetVideoMode

;Set cursor position to (X, Y) in PageNum
SetCursorPos MACRO X, Y, PageNum
    MOV AH, 02H
    MOV BH, PageNum
    MOV DL, X
    MOV DH, Y
    INT 10H
ENDM SetCursorPos

;Get cursor position in PageNum: DL=X, DH=Y
GetCursorPos MACRO PageNum
    MOV AH, 03H
    MOV BH, PageNum
    INT 10H
ENDM GetCursorPos

;Scroll up or clear screen from (x1, y1) to (x2, y2)
ScrollUp MACRO X1, Y1, X2, Y2, LinesCount
    MOV AH, 06H
    MOV AL, LinesCount
    MOV BH, 07H
    MOV CL, X1
    MOV CH, Y1
    MOV DL, X2
    MOV DH, Y2
    INT 10H
ENDM ScrollUp

;Clear portion of screen from (x1, y1) to (x2, y2)
ClearScreen MACRO X1, Y1, X2, Y2
    MOV AX, 0600H
    MOV BH, 07H
    MOV CL, X1
    MOV CH, Y1
    MOV DL, X2
    MOV DH, Y2
    INT 10H
ENDM ClearScreen

;Display a character number of times with a certain color
PrintColoredChar MACRO Char, Color, Cnt, PageNum
    MOV AH, 09H         ;Display
    MOV BH, PageNum     ;Page 0
    MOV AL, Char        ;Character to display
    MOV BL, Color       ;Color(back:fore)
    MOV CX, Cnt         ;Number of times
    INT 10H
ENDM PrintColoredChar

;Draw pixel in (X, Y) position with certain color
DrawPixel MACRO X, Y, Color
    MOV AH, 0CH
    MOV AL, Color
    MOV CX, X
    MOV DX, Y
    INT 10H
ENDM DrawPixel

;Draw a vertical line starting from (X, Y) with a certain length and width
DrawLine MACRO StartX, StartY, VerticalLength, HorizontalWidth, Char, Color, PageNum
    LOCAL Back
    
    MOV SI, 0
    
    Back:
        MOV CX, SI
        ADD CL, StartY
        SetCursorPos StartX, CL, PageNum
        PrintColoredChar Char, Color, HorizontalWidth, PageNum
        
        INC SI
        CMP SI, VerticalLength
        JB Back
ENDM DrawHorizontalLine


;; ********************************************** Keyboard ******************************************
;Wait key press: AH=scan_code, AL=ASCII_code
WaitKeyPress MACRO
    MOV AH, 00H
    INT 16H
ENDM WaitKeyPress

;Get key press: AH=scan_code, AL=ASCII_code
GetKeyPress MACRO
    MOV AH, 01H
    INT 16H
ENDM GetKeyPress

;Get key press and flush it: AH=scan_code, AL=ASCII_code
GetKeyPressAndFlush MACRO
    LOCAL KeyNotPressed
    GetKeyPress
    JZ KeyNotPressed
    WaitKeyPress
    KeyNotPressed:
ENDM GetKeyPressAndFlush

;Empty the key queue
EmptyKeyQueue MACRO
    LOCAL Back, Return
    Back:
    GetKeyPress
    JZ Return
    WaitKeyPress
    JMP Back
    Return:
ENDM EmptyKeyQueue

;Display one character
PrintChar MACRO MyChar
    MOV AH, 02H
    MOV DL, MyChar
    INT 21H
ENDM PrintChar

;Read one character without echo in AL
ReadChar MACRO MyChar
    MOV AH, 07H
    INT 21H
    MOV MyChar, AL
ENDM ReadChar

;Display string untill '$' character
PrintString MACRO MyStr
    MOV AH, 09H
    MOV DX, OFFSET MyStr
    INT 21H
ENDM PrintString

;Read string from keyboard
ReadString MACRO MyStr
    MOV AH, 0AH
    MOV DX, OFFSET MyStr
    INT 21H
ENDM ReadString

;; ********************************************** Port ******************************************
;Author:Omar Bazaraa
;Date:21-11-2016
;Macros for chat module
;----------------------------------------------

;Serial Port address location
COMAddress EQU 3F8H

;Initializes serial port with a certian configuration
InitSerialPort MACRO
    ;Set divisor latch access bit
    MOV DX, COMAddress+3    ;Line control register
    MOV AL, 10000000b
    OUT DX, AL

    ;Set the least significant byte of the Baud rate divisor latch register
    MOV DX, COMAddress
    MOV AL, 0CH
    OUT DX, AL

    ;Set the most significant byte of the Baud rate divisor latch register
    MOV DX, COMAddress+1
    MOV AL, 0
    OUT DX, AL

    ;Set serial port configurations
    MOV DX, COMAddress+3    ;Line Control Register
    MOV AL, 00011011B
    ;0:     Access to receiver and transmitter buffers
    ;0:     Set break disabled
    ;011:   Even parity
    ;0:     One stop bit
    ;11:    8-bit word length
    OUT DX, AL
ENDM InitSerialPort

;Send character through serial port
SendChar MACRO MyChar
    LOCAL Send
    Send:
    MOV DX, COMAddress+5    ;Line Status Register
    IN AL, DX
    AND AL, 00100000B       ;Check transmitter holding register status: 1 ready, 0 otherwise
    JZ Send                 ;Transmitter is not ready
    MOV DX, COMAddress
    MOV AL, MyChar
    OUT DX, AL
ENDM SendChar

;Receive a character from the serial port into AL
ReceiveChar MACRO
    LOCAL Return
    MOV AL, 0
    MOV DX, COMAddress+5    ;Line Status Register
    IN AL, DX
    AND AL, 00000001B       ;Check for data ready
    JZ Return               ;No character received
    MOV DX, COMAddress      ;Receive data register
    IN AL, DX
    Return:
ENDM ReadPortChar

;; ********************************************** Mouse ******************************************
;Check for mouse connection: AX=mouse_status (FFFF if mouse connected)
CheckMouseConn MACRO
    MOV AX, 00H
    INT 33H
ENDM CheckMouseConn

;Show mouse cursor
ShowMouse MACRO
    MOV AX, 01H
    INT 33H
ENDM ShowMouse

;Hide mouse cursor
HideMouse MACRO
    MOV AX, 02H
    INT 33H
ENDM HideMouse

;Get mouse position: CX=row_pos, DX=col_pos, BX=button_status
GetMousePos MACRO
    MOV AX, 03H
    INT 33H
ENDM GetMousePos

;Set mouse position to (row_pos, col_pos)
SetMousePos MACRO row_pos, col_pos
    MOV AX, 04H
    MOV CX, row_pos
    MOV DX, col_pos
    INT 33H
ENDM SetMousePos

;Includes
;INCLUDE Consts.asm
;INCLUDE Graphics.asm
;INCLUDE Keyboard.asm
;INCLUDE Port.asm
;INCLUDE Mouse.asm

;Public variables and procedures
PUBLIC StartChat

;External variables and procedures
EXTRN UserName1:BYTE
EXTRN UserName2:BYTE
;===============================================================

.MODEL SMALL
.STACK 64
.DATA
;Chat variables
User1CursorX                DB      0
User1CursorY                DB      0
User2CursorX                DB      0
User2CursorY                DB      12
ChatSentChar                DB      ?
ChatReceivedChar            DB      ?
IsChatEnded                 DB      0
EndChatMsg                  DB      'Press ESC to end chatting...$'

;Screen adjust variables
ChatAreaWidth               EQU     WindowWidth
ChatAreaHeight              EQU     (WindowHeight-3)/2
ChatMargin                  EQU     1
ChatLineColor               EQU     0FH
ChatLineChar                DB      '-'
;===============================================================

.CODE
;Start chat room between the two players
StartChat PROC FAR
    CALL InitChatRoom
    
    Chat_Loop:
    
    ;Set the cursor to the primary user chat area
    SetCursorPos User1CursorX, User1CursorY, CurrentPage
    
    ;Get primary user input and send it to secondary user
    Chat_Send:
    GetKeyPressAndFlush
    JZ Chat_Receive                 ;Skip processing user input if no key is pressed
    MOV ChatSentChar, AL
    SendChar ChatSentChar
    CALL ProcessPrimaryInput
    
    ;Get secondary user input
    Chat_Receive:
    ReceiveChar
    JZ Chat_Check                   ;Skip processing user input if no key is received
    MOV ChatReceivedChar, AL
    CALL ProcessSecondaryInput
    
    ;Finally check if any user pressed ESC to quit chat room
    Chat_Check:
    CMP IsChatEnded, 0
    JZ Chat_Loop
    
    RET
StartChat ENDP
;===============================================================

;Initialize chat room
InitChatRoom PROC
    ;Clear the entire screen
    ClearScreen 0, 0, WindowWidth, WindowHeight
    
    ;Draw both users chatting area
    DrawChatArea 0, UserName1
    DrawChatArea ChatAreaHeight, UserName2
    
    ;Draw information bar
    DrawInfoBar ChatAreaHeight*2
    
    ;Set chat variables
    MOV User1CursorX, ChatMargin
    MOV User1CursorY, 3
    MOV User2CursorX, ChatMargin
    MOV User2CursorY, ChatAreaHeight+3
    MOV IsChatEnded, 0
    
    RET
InitChatRoom ENDP
;===============================================================

;Process primary user input
ProcessPrimaryInput PROC
    ProcessInput ChatSentChar, User1CursorX, User1CursorY, 0
    RET
ProcessPrimaryInput ENDP
;===============================================================

;Process secondary user input
ProcessSecondaryInput PROC
    ProcessInput ChatReceivedChar, User2CursorX, User2CursorY, ChatAreaHeight
    RET
ProcessSecondaryInput ENDP
;===============================================================

END