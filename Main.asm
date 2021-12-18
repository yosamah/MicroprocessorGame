;Besm alah

.model small
.stack 64
.data 

User1 db 'USER1$'
User1Name DB 15,?,15 DUP('$') , '$'
IntialPoints1 dw ?

User2 db 'USER2$'
User2Name DB 15,?,15 DUP('$') , '$'
IntialPoints2 dw ?     

MulNmber db 10
messageinvalidcharacter DB 'Invalid Input',10,13, '$'

EnterName db 'Please enter your name:',10, 13, '$'

InitialPointsMSG db 10,13,'Initial points:',10,13, '$'
PressEnter db 10,13,'Press ENTER to continue$'

StartChat db 'To start chatting press F1$'
StartGame db 'To start game press F2$'
EndProg db 'To end the program press ESC$'



PrintMessage MACRO MyMessage ;print a message on the screen
    mov AH,9h
    lea DX,MyMessage
    int 21h
ENDM PrintMessage
;----------------------------------------
ReadString MACRO MyStr  ;read a string
    mov AH, 0ah
    lea DX, MyStr
    int 21H
ENDM ReadString
;----------------------------------------
;Set cursor
SetCursor MACRO x,y,PageNO

    mov ah,2
    mov dl,x
    mov dh,y
    mov bh,PageNO
    int 10h

endm SetCursor

;Clear Screen
ClearScreen MACRO x1,y1,x2,y2,Color

    mov ax,0600h
    mov bh,Color
    mov cl,x1
    mov ch,y1
    mov dl,x2
    mov dh,y2
    int 10h

endm ClearScreen 

;changing to  text mode
changeTextmode Macro
    mov ah,0
    mov al,3
    int 10h
endm changeTextmode
;----------------------------
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
    
    ReadString UserName ;get the string from the user and save it in username
    
    
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
;---------------------------------
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
;-----------------------------------------
.code
main proc far
    mov ax,@DATA
    mov ds,ax

    changeTextmode  
    ;Get Info  of user1 
    GetUserName User1Name
    ReadNumber IntialPoints1
    call GetEnter
    ;Get Info  of user2 
    GetUserName User2Name
    ReadNumber IntialPoints2
    call GetEnter

    mov ah,04ch
    int 21h
    
main endp
;-----------------------------------------  

GetEnter Proc
    
    return: 
    
    PrintMessage PressEnter
    mov ah,0h
    int 16h    
    cmp ah,28
    jnz return

    ClearScreen 0,0,80,25,0Fh
    RET
GetEnter ENDP

end main
