     .MODEL SMALL                                                                               
.STACK 32



.Data

;///INPUT
PLAYERNAME db 10,?,dup('0')

;///DISPLAYS
DISP1 db 'PLAYER 1 ENTER YOUR NAME  : ','$'   
DISP12 db 'PLAYER 2 ENTER YOUR NAME  : ','$'   
DISP2 db 'PRESS ENTER KEY TO CONTINUE ...','$' 
DISP3 db 10,13,'  -> TO START CHATTING PRESS C ','$'
DISP4 db 10,13,'  -> TO START GAMING PRESS G ',10,13,'$'  
LL DB 10,13,'$'
DISP5 db '  -> TO END PROGRAM PRESS ESC ','$'
DISP6 DB ' SCORE : ','$'          
DISPCON DB 'WAITING FOR SECOND PLAYER !!!' ,10,13 ,'                    PRESS ESC TO RETURN TO MENU...','$' 
DISPCON2 DB 'YOU RECIEVED A GAME INVITATION!!!',10,13,'                    PRESS G TO ACCEPT ...' ,10,13 ,'                             PRESS ESC TO RETURN TO MENU...','$' 
DISPCON3 DB 'YOU RECIEVED A CHAT INVITATION!!!',10,13,'                    PRESS C TO ACCEPT ...' ,10,13 ,'                             PRESS ESC TO RETURN TO MENU...','$' 

DISP7 DB 'PLAER 1 CONTROLS : ',10,13,'A   D',10,13,'SPACE',10,13,10,13,'PLAER 2 CONTROLS : ',10,13,'J   L',10,13,'ENTER','$'
DISP8 DB ' * * * G A M E  O V E R * * * ','$'   
DISP88 DB '   * * * L E V E L  2 * * * ','$'   
DISP9 DB 'GOOOAAALLLLLL','$'
DISP0 DB 'HARD LUCK','$'  
DISPX DB '**PLAYER 1 TURN**','$'
DISPXX DB '**PLAYER 2 TURN**','$'     
DISPXXX DB 'YOU ARE PLAYER 1','$'
DISPXXXX DB 'YOU ARE PLAYER 2','$'
  
LVL2 DB 0
OUTDATA db 0  
INDATA db 0 
readcurx db 0
readcury db 14
writecurx db 0
writecury db 1
HOST db 0
REQ db 0  
press DB 0
readcurxIN db 10
readcuryIN db 15H
writecurxIN db 10
writecuryIN db 13H
                   
                   
PLAYER1 DB 2,?,DUP(30H)    
PLAYER2 DB 2,?,DUP(30H) 
;////DRAW               
PLAYERNAME2 DB 10,?,DUP('0')



.CODE
Main proc Far
    MOV AX, DATA
    MOV DS,AX       
             
  
             
             
CALL CLEAR_SCREEN    
CALL GET_PLAYER_NAME           ;get player 1 name 

CALL CONFIGURATION          ;to set serial communication configuration
OPTIONS:      
MOV HOST,0             ;decides if you are the host or client
MOV REQ,0              ;if you recieved a request or not

CALL CLEAR_SCREEN   

LEA SI,PLAYER1[2]  

LEA DI,PLAYER2[2]
  
MOV [SI],30H         ;initialize score of player1  with 0
MOV [DI],30H         ;initialize score of player2  with 0


CALL DISP_OPTIONS    ;display main menu

CALL GET_OPTION  ; ORDER IS IN AL: 1B FOR EXIT, 43 FOR CHAT,47 TO START  GAME


CMP AL,1BH             ;if esc is pressed end the proc
JZ END_PROC



INGAME1:           ;to call ingame chat
PUSHA
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,1300H
INT 10H
CALL INGAMECHAT
POPA    
CMP LVL2,1
JE INPUT1LVL2    ;if we are in level2 the return label is different
JMP INPUT1





GAME_MODE: 
CALL CLEAR_SCREEN              
       
CALL SETGAME               ;calls proc that draws the starting game interface
 MOV LVL2,0     
 
 ; CMP HOST,1 
 ; JNE DABB
 ;    PUSHA
 ;MOV  BX,0
;MOV AH,2       ;SET CURSOR
;MOV  DX ,1000H
;INT 10H
      
;MOV AH,9
;MOV DX,OFFSET DISPXXX
;INT 21H   
;     POPA    
     
;   DABB:
;       PUSHA
; MOV  BX,0
;MOV AH,2       ;SET CURSOR
;MOV  DX ,1000H
;INT 10H
;      
;MOV AH,9
;MOV DX,OFFSET DISPXXXX
;INT 21H   
;     POPA
     

TURN_01:

    PUSHA         
 MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,1038H
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISPX ;display player1 turn
INT 21H   
     POPA

MOV BX,0828H ; P1 CONTROLS BX  
MOV DX,0426H ; P2 CONTROLS DX  

PUSH BX
PUSH DX
XCHG BX,DX     ; draw cursor needs ball destination to be in dx
                ;so we need to exchange it
CALL DRAW_CURSOR   ;proc that draws the cursor that declares dest of ball
POP DX
POP BX 

MOV CX,5    
INPUT1: 
           
PUSH CX
PUSH DX
PUSH BX           
CALL GETKEY      ;get the key press either from player1 or player2
POP BX
POP DX
POP CX        

CMP AL,43H          ;if C pressed jump to in game chat
JE INGAME1

CMP AL,1BH           ;if esc pressed we end game
JNE H
MOV REQ,0
MOV HOST,0
JMP END_PROG

H:
CMP CX,0
JZ NO  


CMP AL,20H  ;if space is pressed the goal is shot otherwise the loop continues
JZ SHOT_DECLARED



NO:  



PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CURSOR       ; with each step we need to delete old cursor
                            ; to draw it in new pos
POP DX
POP BX  

PUSH DX
CALL INPUTKEY            ;here we update bx and dx according to what was pressed by players

  
MOV AX,DX              ;to save new dx
POP DX                  ;to restore old dx
PUSH AX                 ;push new dx to stack
CALL DELETE_GOAL        ;delete goal at old pos 
POP DX  
PUSH DX
CALL DRAW_GOAL        ;draw goal once again
 
 
 

PUSH BX
PUSH DX
XCHG BX,DX              ;draw cursor needs ball pos in dx
CALL DRAW_CURSOR      ;draw cursor in new position
POP DX
POP BX     
 
 
 
DEC CX
JMP INPUT1


;///BX HOLD FINAL BALL POSITION 
;///DX HOLD UPPER LEFT CORNER OF GOAL
SHOT_DECLARED:
              
;//DRAW SIMULATION              
CALL MOVE_KICKER     ; proc to move player to shoot the ball



PUSH BX
PUSH DX
CALL MOVE_BALL       ; proc to draw ball at new pos and delete old pos
PUSH BX
PUSH DX
XCHG BX,DX            ;check goal needs ball pos to be in dx
CALL CHECK_GOAL       ;proc that checks if the ball was a goal and updates score
POP DX
POP BX  


PUSH BX
PUSH DX
XCHG BX,DX             
CALL DELETE_CHECK      ;we delete the text goal or hard luck from screenn
POP DX
POP BX  



PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CURSOR       ;delete cursor at old pos
POP DX
POP BX  
   

;///////////////////////////
;/EXCHANGE PLAYERS
POP DX        ; we need the last ball pos and goal corner to update interface
POP BX        ;  before the second player starts to shoot  

CALL CHECK_GAME2    ;it checks if player 1 has 5 goals or not 
                    ;and whether player 2 has 4 goals or nor to end the game        
            
CALL SETGAME2       ;update interface for 2nd player turn
    PUSHA
 MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,1038H
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISPXX
INT 21H   
     POPA

MOV BX,0828H ; P1 CONTROLS BX  
MOV DX,0426H ; P2 CONTROLS DX 
PUSH BX
PUSH DX
XCHG BX,DX
CALL DRAW_CURSOR     ;that desides ball destination
POP DX
POP BX 

MOV CX,5
INPUT2: 

PUSH CX
PUSH DX
PUSH BX           
CALL GETKEY2       ;get input key from either players
POP BX
POP DX
POP CX      

CMP AL,1BH
JZ END_PROG

CMP CX,0
JZ NO2    

;CMP HOST,0
;JNE NO2
CMP AL,20H  ;if space is pressed the goal is shot otherwise the loop continues
JZ SHOT_DECLARED2



NO2:  



PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CURSOR   ;delete cursor at old pos
POP DX
POP BX  

PUSH DX
CALL INPUTKEY2       ;sets new destination according to sent or recieved press

  
MOV AX,DX
POP DX
PUSH AX
CALL DELETE_GOAL       ;delete goal at old pos
POP DX  
PUSH DX
CALL DRAW_GOAL      ;draw goal at new pos
 
 
 

PUSH BX
PUSH DX
XCHG BX,DX
CALL DRAW_CURSOR    ;draw cursor at new pos
POP DX
POP BX     
 
 
 
DEC CX
JMP INPUT2     


;///BX HOLD FINAL BALL POSITION 
;///DX HOLD UPPER LEFT CORNER OF GOAL
SHOT_DECLARED2:
              
;//DRAW SIMULATION              
CALL MOVE_KICKER


;POP DX  
PUSH BX
PUSH DX
CALL MOVE_BALL   ;move ball simulation

PUSH BX
PUSH DX
XCHG BX,DX
CALL CHECK_GOAL2  ;check if ball between boundries  and declare hardluck or goaal
POP DX
POP BX  


PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CHECK    ;delete goal or hardluck
POP DX
POP BX  



PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CURSOR   ;delete cursor at old pos
POP DX
POP BX  

;////////////
CALL CHECK_GAME       ;check if game level1 ended


POP DX
POP BX            
            


CALL SETGAME2   ;redraws and updates interface

JMP TURN_01     ;return to turn 1



CHATT:         ;chat mode
CALL CHAT           
JMP OPTIONS 



LVLVL:         ;level2

CALL CLEAR_SCREEN
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0A1BH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISP88 ;display level 2  screen
INT 21H   

CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY 



CALL CLEAR_SCREEN 
             
LEA SI,PLAYER1[2]  

LEA DI,PLAYER2[2]
  
MOV [SI],30H         ;initialize score of player1  with 0
MOV [DI],30H         ;initialize score of player2  with 0

 MOV LVL2,1      
CALL SETGAME               ;calls proc that draws the starting game interface
 
TURN_01LVL2:
     PUSHA
 MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,1038H
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISPX
INT 21H   
     POPA
MOV BX,0828H ; P1 CONTROLS BX  
MOV DX,0426H ; P2 CONTROLS DX  

PUSH BX
PUSH DX
XCHG BX,DX     ; draw cursor needs ball destination to be in dx
                ;so we need to exchange it
CALL DRAW_CURSOR   ;proc that draws the cursor that declares dest of ball
POP DX
POP BX 

MOV CX,5    
INPUT1LVL2: 
           
PUSH CX
PUSH DX
PUSH BX           
CALL GETKEY
POP BX
POP DX
POP CX        

CMP AL,43H
JE INGAME1

CMP AL,1BH           ;if esc pressed we end game
JNE HLVL2
MOV REQ,0
MOV HOST,0
JMP END_PROG

HLVL2:
  


CMP AL,20H  ;if space is pressed the goal is shot otherwise the loop continues
JZ SHOT_DECLAREDLVL2



NOLVL2:  



PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CURSOR       ; with each step we need to delete old cursor
                            ; to draw it in new pos
POP DX
POP BX  

PUSH DX
CALL INPUTKEYLVL2            ;here we update bx and dx according to what was pressed by players

  
MOV AX,DX              ;to save new dx
POP DX                  ;to restore old dx
PUSH AX                 ;push new dx to stack
CALL DELETE_GOAL        ;delete goal at old pos 
POP DX  
PUSH DX
CALL DRAW_GOAL        ;draw goal once again
 
 
 

PUSH BX
PUSH DX
XCHG BX,DX              ;draw cursor needs ball pos in dx
CALL DRAW_CURSOR      ;draw cursor in new position
POP DX
POP BX     
 
 
 
DEC CX
JMP INPUT1LVL2


;///BX HOLD FINAL BALL POSITION 
;///DX HOLD UPPER LEFT CORNER OF GOAL
SHOT_DECLAREDLVL2:
              
;//DRAW SIMULATION              
CALL MOVE_KICKER     ; proc to move player to shoot the ball



PUSH BX
PUSH DX
CALL MOVE_BALL       ; proc to draw ball at new pos and delete old pos
PUSH BX
PUSH DX
XCHG BX,DX            ;check goal needs ball pos to be in dx
CALL CHECK_GOAL       ;proc that checks if the ball was a goal and updates score
POP DX
POP BX  


PUSH BX
PUSH DX
XCHG BX,DX             
CALL DELETE_CHECK      ;we delete the text goal or hard luck from screenn
POP DX
POP BX  



PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CURSOR       ;delete cursor at old pos
POP DX
POP BX  
   

;///////////////////////////
;/EXCHANGE PLAYERS
POP DX        ; we need the last ball pos and goal corner to update interface
POP BX        ;  before the second player starts to shoot  

CALL CHECK_GAME2LVL2    ;it checks if player 1 has 5 goals or not 
                    ;and whether player 2 has 4 goals or nor to end the game        
            
CALL SETGAME2       ;update interface for 2nd player turn
     PUSHA
 MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,1038H
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISPXX
INT 21H   
     POPA

MOV BX,0828H ; P1 CONTROLS BX  
MOV DX,0426H ; P2 CONTROLS DX 
PUSH BX
PUSH DX
XCHG BX,DX
CALL DRAW_CURSOR
POP DX
POP BX 

MOV CX,5
INPUT2LVL2: 

PUSH CX
PUSH DX
PUSH BX           
CALL GETKEY2
POP BX
POP DX
POP CX      

CMP AL,1BH
JZ END_PROG

CMP CX,0
JZ NO2LVL2    

;CMP HOST,0
;JNE NO2
CMP AL,20H  ;if space is pressed the goal is shot otherwise the loop continues
JZ SHOT_DECLARED2LVL2



NO2LVL2:  



PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CURSOR
POP DX
POP BX  

PUSH DX
CALL INPUTKEY2LVL2 

  
MOV AX,DX
POP DX
PUSH AX
CALL DELETE_GOAL
POP DX  
PUSH DX
CALL DRAW_GOAL
 
 
 

PUSH BX
PUSH DX
XCHG BX,DX
CALL DRAW_CURSOR
POP DX
POP BX     
 
 
 
DEC CX
JMP INPUT2LVL2


;///BX HOLD FINAL BALL POSITION 
;///DX HOLD UPPER LEFT CORNER OF GOAL
SHOT_DECLARED2LVL2:
              
;//DRAW SIMULATION              
CALL MOVE_KICKER


;POP DX  
PUSH BX
PUSH DX
CALL MOVE_BALL

PUSH BX
PUSH DX
XCHG BX,DX
CALL CHECK_GOAL2
POP DX
POP BX  


PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CHECK
POP DX
POP BX  



PUSH BX
PUSH DX
XCHG BX,DX
CALL DELETE_CURSOR
POP DX
POP BX  

;////////////
CALL CHECK_GAMELVL2


POP DX
POP BX            
            


CALL SETGAME2

JMP TURN_01LVL2    






           
END_PROG:        ;here we end game and display game over
            
CALL CLEAR_SCREEN
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0A1BH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISP8
INT 21H   

CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY
CALL DELAY

JMP OPTIONS ; we return again to the main menu

END_PROC:       
MOV AH,4CH   ; end program
INT 21H
Main ENDP      
;/////////////////////////////////////////////


Proc Delay  ; proc that causes delay to open in dosbox
PUSHA

MOV DI,10000
LOOP1:

DEC DI
CMP DI,0
JNZ LOOP1

MOV DI,10000
LOOP2:

DEC DI
CMP DI,0
JNZ LOOP2
MOV DI,10000
LOOP3:

DEC DI
CMP DI,0
JNZ LOOP3

MOV DI,10000
LOOP4:

DEC DI
CMP DI,0
JNZ LOOP4

POPA
ret
endp DELAY


;/////////////////////////////////////////
PROC SET_GOAL       ;proc that assigns goal for player (1) and display it
PUSHA    
 
  
 
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,1112H
INT 10H


LEA SI,PLAYER1[2]    ; load the previous score

;MOV AH,2
MOV DL,[SI]  
INC DL         ; add a goal
MOV [SI],DL
;INT 21H



PUSHA 
MOV AH,9         ;display
MOV BH,0
MOV AL,DL
MOV CX,1 
MOV BL,03h
INT 10H
POPA



POPA        

RET
ENDP SET_GOAL
;/////////////////////////////////////////
PROC SET_GOAL2      ;proc that assigns goal for player (2) and display it
PUSHA    
 
    
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,1140H
INT 10H
  ; sam as the previous proc

LEA SI,PLAYER2[2]  

;MOV AH,2
MOV DL,[SI]  
INC DL     
MOV [SI],DL
;INT 21H

PUSHA 
MOV AH,9
MOV BH,0
MOV AL,DL
MOV CX,1 
MOV BL,03h
INT 10H
POPA

POPA        

RET
ENDP SET_GOAL2
;////////////////////////////////////////// 
PROC CHECK_GAME   ;checks wether game should be ended if player 1 has 5 goals 
                    ;or player 2 or they have a draw
PUSHA         
LEA SI,PLAYER1[2]      ;load player1 score

LEA DI,PLAYER2[2]      ;load player 2 score
  
MOV AL,[SI]
MOV AH,[DI]


CMP AH,35H           ;see if player 2 has   5 goals
JB XXX
CMP AH,AL           ;see if there is a draw
JZ  XX   
JMP LVLVL

XXX:
CMP AL,35H        ;see if player 1 has 5 goals
JB  XX
CMP AH,AL         ;see if there is  a draw
JZ  XX 

JMP LVLVL         ; end game if any one wins


XX:
POPA

RET
ENDP CHECK_GAME
;///////////////////////////////////
 PROC CHECK_GAME2
PUSHA         
LEA SI,PLAYER1[2]        ; load the scores

LEA DI,PLAYER2[2]
  
MOV AL,[SI]
MOV AH,[DI]


CMP Al,35H         ;check if playyer 1 has 5 goals
JB SSS    

SUB AL,AH          ;checks that player 2 is less than 4 goals
CMP AL,2

  
JNB LVLVL

SSS:
POPA

RET
ENDP CHECK_GAME2
;/////////////////////////////////////
PROC CHECK_GOAL     ; for player 1
PUSHA


CMP DL,BL         ; checks if the ball is below the uppper boundary
JNA NOG
ADD BL,9
CMP DL,BL         ; checks if the ball is above the lower boundary
JNB NOG

CMP DH,BH            ; checks if the ball is to right of left boundary
JNA NOG
  
ADD BH,4
CMP DH,BH            ; checks if the ball is to lrft of right boundary
JNB NOG


JMP EE
NOG:    ; not goal

MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,111FH
INT 10H
      
MOV AH,9                ; display hard luck
MOV DX,OFFSET DISP0
INT 21H     

JMP NZZ
EE:

MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,111FH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISP9      ; disp goal
INT 21H     
CALL SET_GOAL             ; update score
NZZ:


POPA
RET    
ENDP CHECK_GOAL    
;/////////////////////////////////////////
;//////////////////////////////////////////
PROC CHECK_GOAL2     ; for player 2
PUSHA

CMP DL,BL
JNA NOG2
ADD BL,9
CMP DL,BL
JNB NOG2

CMP DH,BH
JNA NOG
  
ADD BH,4
CMP DH,BH
JNB NOG


JMP EE2
NOG2:

MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,111FH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISP0
INT 21H     

JMP NZZ2
EE2:

MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,111FH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISP9
INT 21H     
CALL SET_GOAL2
NZZ2:


POPA
RET    
ENDP CHECK_GOAL2    
;//////////////////////////////////////////  
PROC DELETE_CHECK     ; delete goal or hardluck
PUSHA

MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,111FH
INT 10H
      
MOV CX,13
  
EX:  
MOV AH,2
MOV DL,' '
INT 21H   

CALL DELAY
CALL DELAY
CALL DELAY
DEC CX
CMP CX,0
JNZ EX

POPA      
RET
ENDP DELETE_CHECK
;////////////////////////////////////////  
PROC DRAW_CURSOR     ;draw the cursor that decides the ball dest
PUSHA

MOV BX,0

MOV AH,2       ;SET CURSOR
MOV DH,0CH    ;we must draw it below goal
INT 10H


  
MOV AH,9
MOV BH,0
MOV AL,'^'
MOV CX,1 
MOV BL,08H
INT 10H

POPA
RET
ENDP DRAW_CURSOR
;//////////////////////////////////////////
PROC DELETE_CURSOR      ; deletes cursor
PUSHA

MOV BX,0

MOV AH,2       ;SET CURSOR
MOV DH,0CH
INT 10H

  
MOV AH,2
MOV DL,' '      ;print space
INT 21H


POPA
RET
ENDP DELETE_CURSOR
;//////////////////////////////////////////
  
;//////////////////////////////////////////////////////
PROC MOVE_KICKER
PUSH DX
PUSH BX 
;first delete old body pos
MOV BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0E2AH
INT 10H
mov ah, 02h         ; DOS Display character call 
mov dl, 20h         ; A space to clear old character 
int 21h             ; Display it 

MOV BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0F2AH
INT 10H
mov ah, 02h         ; DOS Display character call 
mov dl, 20h         ; A space to clear old character 
int 21h             ; Display it 


MOV AH,2       ;SET CURSOR
MOV  DX ,102AH
INT 10H
mov ah, 02h         ; DOS Display character call 
mov dl, 20h         ; A space to clear old character 
int 21h             ; Display it 

MOV AH,2       ;SET CURSOR
MOV  DX ,0D29H    ;new head pos
INT 10H

  
;MOV AH,2
;MOV DL,'Q'
;INT 21H


PUSHA             ;draw head
MOV AH,9
MOV BH,0
MOV AL,'Q'
MOV CX,1 
MOV BL,4
INT 10H
POPA


MOV AH,2       ;SET CURSOR
MOV  DX ,0E29H  ;new arms pos
INT 10H

  
;MOV AH,2
;MOV DL,'^'
;INT 21H

              ;draw new arms
PUSHA 
MOV AH,9
MOV BH,0
MOV AL,'^'
MOV CX,1 
MOV BL,4
INT 10H
POPA


MOV AH,2       ;SET CURSOR
MOV  DX ,0F29H
INT 10H


PUSHA 
MOV AH,9      ;draw legs
MOV BH,0
MOV AL,'^'
MOV CX,1 
MOV BL,4
INT 10H
POPA  
;MOV AH,2
;MOV DL,'^'
;INT 21H
CALL DELAY
CALL DELAY
CALL DELAY
MOV AH,2       ;SET CURSOR
MOV  DX ,0F29H
INT 10H
mov ah, 02h         ; DOS Display character call 
mov dl, 20h         ; A space to clear old character 
int 21h             ; Display it 
           
MOV AH,2       ;SET CURSOR
MOV  DX ,0F28H
INT 10H


PUSHA            ;move the legs to ball to shoot
MOV AH,9
MOV BH,0
MOV AL,'^'
MOV CX,1 
MOV BL,4
INT 10H
POPA  
;MOV AH,2
;MOV DL,'^'
;INT 21H
CALL DELAY
CALL DELAY
CALL DELAY
POP BX
POP DX
RET
ENDP MOVE_KICKER
;/////////////////////////////////////////////////////
PROC GET_PLAYER_NAME    ;player1        
MOV AH,9
MOV DX,OFFSET DISP1
INT 21H

MOV AH,2       ;SET CURSOR
MOV  DX ,0300H
INT 10H

MOV AH,9
MOV DX,OFFSET DISP2
INT 21H

MOV AH,2     ;SET CURSOR
MOV  DX ,0200H
INT 10H

MOV AH,0AH
MOV DX,OFFSET PLAYERNAME
INT 21H

 RET 
 ENDP GET_PLAYER_NAME  

;//////////////////////////////////////////////////
;/////////////////////////////////////////////////////
PROC GET_PLAYER_NAME2       ;player2     
MOV AH,9
MOV DX,OFFSET DISP12
INT 21H

MOV AH,2       ;SET CURSOR
MOV  DX ,0300H
INT 10H

MOV AH,9
MOV DX,OFFSET DISP2
INT 21H

MOV AH,2     ;SET CURSOR
MOV  DX ,0200H
INT 10H

MOV AH,0AH
MOV DX,OFFSET PLAYERNAME2
INT 21H

 RET 
 ENDP GET_PLAYER_NAME2  
     
;///////////////////////////////////////////////
PROC  CLEAR_SCREEN        ;clear screen proc
mov ax,02
mov bx,03
int 10h

RET
ENDP CLEAR_SCREEN

;////////////////////////////////////////////////////
PROC DISP_OPTIONS          ;proc to displaye main menu of the prog
MOV AH,2       ;SET CURSOR
MOV  DX ,0000H
INT 10H

    
MOV AH,9
MOV DX,OFFSET DISP3       ;game
INT 21H

MOV AH,9
MOV DX,OFFSET DISP4       ;chat
INT 21H

MOV AH,9
MOV DX,OFFSET DISP5       ;escape
INT 21H
RET
ENDP DISP_OPTIONS

;///////////////////////////////////////////
PROC DRAW_GOAL        ; INITIAL LEFT CORNER MUST BE PUT IN DX   --> 0426H
PUSH BX
MOV BX,0
MOV CX,9
PUSH DX
MOV AH,2       ;SET CURSOR
INT 10H

UPPER:           ;draw upper bar
MOV AH,2
MOV DL,'-'
INT 21H
DEC CX
JNZ UPPER

MOV CX,5

MOV AH,2       ;SET CURSOR    
POP DX
PUSH DX
INT 10H

LEFT:
PUSH DX        
MOV AH,2
MOV DL,'|'
INT 21H
POP DX
INC DH 
MOV AH,2       ;SET CURSOR
INT 10H 

DEC CX
JNZ LEFT


POP DX
PUSH DX
ADD DL,09H
MOV CX,5
MOV AH,2       ;SET CURSOR
INT 10H


RIGHT:
PUSH DX        
MOV AH,2
MOV DL,'|'
INT 21H
POP DX
INC DH 
MOV AH,2       ;SET CURSOR
INT 10H 

DEC CX
JNZ RIGHT  

POP DX
PUSH DX
ADD DH,04H  
INC DL
MOV CX,8
MOV AH,2       ;SET CURSOR
INT 10H

DOWN:
MOV AH,2
MOV DL,'-'
INT 21H
DEC CX
JNZ DOWN 

POP DX
POP BX

RET
ENDP DRAW_GOAL     
;/////////////////////////////////////////
PROC DELETE_GOAL

PUSH BX
MOV BX,0
MOV CX,9
PUSH DX
MOV AH,2       ;SET CURSOR
INT 10H

UPPER2:   
MOV AH,2
MOV DL,' '
INT 21H
DEC CX
JNZ UPPER2
         
MOV CX,5

MOV AH,2       ;SET CURSOR    
POP DX
PUSH DX
INT 10H

LEFT2:
PUSH DX        
MOV AH,2
MOV DL,' '
INT 21H
POP DX
INC DH 
MOV AH,2       ;SET CURSOR
INT 10H 

DEC CX
JNZ LEFT2


POP DX
PUSH DX
ADD DL,09H
MOV CX,5
MOV AH,2       ;SET CURSOR
INT 10H


RIGHT2:
PUSH DX        
MOV AH,2
MOV DL,' '
INT 21H
POP DX
INC DH 
MOV AH,2       ;SET CURSOR
INT 10H 

DEC CX
JNZ RIGHT2  

POP DX
PUSH DX
ADD DH,04H  
INC DL
MOV CX,8
MOV AH,2       ;SET CURSOR
INT 10H

DOWN2:
MOV AH,2
MOV DL,' '
INT 21H
DEC CX
JNZ DOWN2 

POP DX
POP BX


    
RET 
ENDP DELETE_GOAL
;////////////////////////////////////////
PROC DRAW_BP12 ;DRAW BALL AND PLAYER

;///////DRAW BALL
MOV AH,2       ;SET CURSOR
MOV  DX ,0F28H
INT 10H


PUSHA 
MOV AH,9
MOV BH,0
MOV AL,'O'
MOV CX,1 
MOV BL,0FH
INT 10H
POPA

;MOV AH,2
;MOV DL,'O'
;INT 21H

;///DRAW KICKER

MOV AH,2       ;SET CURSOR
MOV  DX ,0E2AH
INT 10H


PUSHA 
MOV AH,9
MOV BH,0
MOV AL,'Q'
MOV CX,1 
MOV BL,4
INT 10H
POPA

;MOV AH,2
;MOV DL,'Q'
;INT 21H

MOV AH,2       ;SET CURSOR
MOV  DX ,0F2AH
INT 10H


PUSHA       ;draw arms
MOV AH,9
MOV BH,0
MOV AL,'^'
MOV CX,1 
MOV BL,4
INT 10H
POPA  
;MOV AH,2
;MOV DL,'^'
;INT 21H

MOV AH,2       ;SET CURSOR
MOV  DX ,102AH
INT 10H

PUSHA           ;draw legs
MOV AH,9
MOV BH,0
MOV AL,'^'
MOV CX,1 
MOV BL,4
INT 10H
POPA
  
;MOV AH,2
;MOV DL,'^'
;INT 21H
RET 
ENDP DRAW_BP12
;////////////////////////////////////////

PROC DRAW_LINE       ;a proc to draw a line
MOV CX,50H
DLINE:  
MOV AH,2
MOV DL,04h
INT 21H
DEC CX
JNZ DLINE

RET
ENDP DRAW_LINE     
;//////////////////////////////////////
PROC CLEAR_LINE    
    MOV CX,40H
DLINE22:  
MOV AH,2
MOV DL,20H
INT 21H
DEC CX
JNZ DLINE22

RET
ENDP CLEAR_LINE     
;/////////////////////////////////////
PROC INITIAL_SCORE   
     

CALL GETPLAYER2NAME    
mov ch,host
cmp ch,0
JE NOTHOST 
   
MOV AH,2       ;SET CURSOR
MOV  DX ,1100H
INT 10H
LEA SI,PLAYERNAME[2]     ;LOAD player1 name

TYPE:     ;TYPE  letter by letter
MOV AH,2
MOV DL,[SI]
INT 21H

INC SI
CMP [SI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ typez                 
JMP TYPE                 

typez:
MOV AH,9
MOV DX,OFFSET DISP6        ;disp score 
INT 21H 
MOV AH,2       ;SET CURSOR
MOV  DX ,1112H
INT 10H
;MOV AH,2
;MOV DL,'0'
;INT 21H

PUSHA         ;disp 0 intial score
MOV AH,9
MOV BH,0
MOV AL,'0'
MOV CX,1 
MOV BL,03h
INT 10H
POPA

;///////////////////////////////////////
MOV AH,2       ;SET CURSOR
MOV  DX ,1130H
INT 10H
LEA SI,PLAYERNAME2[2]   ; load player 2 name
; rest of code is as for player 1

TYPE2:
MOV AH,2
MOV DL,[SI]
INT 21H

INC SI
CMP [SI],0DH  
JZ oo
JMP TYPE2
oo:
MOV AH,9
MOV DX,OFFSET DISP6
INT 21H 
MOV AH,2       ;SET CURSOR
MOV  DX ,1140H
INT 10H
;MOV AH,2
;MOV DL,'0'
;INT 21H              

PUSHA 
MOV AH,9
MOV BH,0
MOV AL,'0'
MOV CX,1 
MOV BL,03h
INT 10H
POPA 

JMP OUTATY
NOTHOST:    
MOV AH,2       ;SET CURSOR
MOV  DX ,1100H
INT 10H

LEA SI,PLAYERNAME2[2]   ; load player 2 name
; rest of code is as for player 1

TYPE2NOT:
MOV AH,2
MOV DL,[SI]
INT 21H

INC SI
CMP [SI],0DH  
JZ ooNOT
JMP TYPE2NOT
ooNOT:
MOV AH,9
MOV DX,OFFSET DISP6
INT 21H 
MOV AH,2       ;SET CURSOR
MOV  DX ,1140H
INT 10H
;MOV AH,2
;MOV DL,'0'
;INT 21H              

PUSHA 
MOV AH,9
MOV BH,0
MOV AL,'0'
MOV CX,1 
MOV BL,03h
INT 10H
POPA

;///////////////////////////////////////
MOV AH,2       ;SET CURSOR
MOV  DX ,1130H
INT 10H


LEA SI,PLAYERNAME[2]     ;LOAD player1 name

TYPENOT:     ;TYPE  letter by letter
MOV AH,2
MOV DL,[SI]
INT 21H

INC SI
CMP [SI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ typezNOT                 
JMP TYPENOT                 

typezNOT:
MOV AH,9
MOV DX,OFFSET DISP6        ;disp score 
INT 21H 
MOV AH,2       ;SET CURSOR
MOV  DX ,1112H
INT 10H
;MOV AH,2
;MOV DL,'0'
;INT 21H

PUSHA         ;disp 0 intial score
MOV AH,9
MOV BH,0
MOV AL,'0'
MOV CX,1 
MOV BL,03h
INT 10H
POPA
          
          OUTATY:
RET
ENDP INITIAL_SCORE
;//////////////////////////////////// 
PROC SETGAME  
MOV DX , 0426H
CALL DRAW_GOAL  ;draw goal
;MOV AH,2       ;SET CURSOR
;MOV  DX ,0500H
;INT 10H
;MOV AH,9
;MOV DX,OFFSET DISP7
;INT 21H
CALL DRAW_BP12    ; draw plaer and goal   

CALL INITIAL_SCORE   ; type initial scores   

MOV BX,0
MOV AH,2       ;SET CURSOR
MOV  DX,1500H
INT 10H  

LEA SI,PLAYERNAME2[2]     ;LOAD player1 name

TYPEee34IN: ;TYPE  letter by letter
MOV AH,2
MOV DL,[SI]
INT 21H

INC SI
CMP [SI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ NA34IN                 
JMP TYPEee34IN
NA34IN:    
mov ah,2
mov dl,':'
int 21h     

MOV BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,1300H
INT 10H

LEA SI,PLAYERNAME[2]     ;LOAD player1 name

TYPEeeIN: ;TYPE  letter by letter
MOV AH,2
MOV DL,[SI]
INT 21H

INC SI
CMP [SI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ NAIN                 
JMP TYPEeeIN
NAIN:    
mov ah,2
mov dl,':'
int 21h                  

MOV AH,2       ;SET CURSOR
MOV  DX ,1200H
INT 10H
CALL DRAW_LINE
MOV AH,2       ;SET CURSOR
MOV  DX ,1600H
INT 10H          
CALL DRAW_LINE              
MOV AH,2       ;SET CURSOR
MOV  DX ,1700H
INT 10H                   
MOV AH,9
MOV DX,OFFSET DISP5
INT 21H
RET
ENDP SETGAME        
;///////////////////////////////////
PROC SETGAME2 

CALL DELETE_GOAL   ; delete goal at old pos

MOV DX,BX

MOV BX,0
MOV AH,2       ;SET CURSOR
INT 10H

PUSH DX        ; remove player at old pos
MOV AH,2
MOV DL,' '
INT 21H
POP DX
     ;////remove kicker from infront of the ball
MOV AH,2       ;SET CURSOR
MOV  DX ,0E29H
INT 10H

  
MOV AH,2
MOV DL,' '
INT 21H

MOV AH,2       ;SET CURSOR
MOV  DX ,0F29H
INT 10H

  
MOV AH,2
MOV DL,' '
INT 21H    

MOV AH,2       ;SET CURSOR
MOV  DX ,0D29H
INT 10H

  
MOV AH,2
MOV DL,' '
INT 21H




    
MOV DX , 0426H
CALL DRAW_GOAL
CALL DRAW_BP12

RET
ENDP SETGAME2

;////////////////////////////////////      


PROC MOVE_BALL

PUSH DX
PUSH BX  


MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0F28H
INT 10H      

mov ah, 02h         ; DOS Display character call 
mov dl, 20h         ; A space to clear old character 
int 21h             ; Display it 


MOV AH,2       ;SET CURSOR
MOV  DX ,0F29H
INT 10H
 ;move the player leg back after he shot the ball
PUSHA 
MOV AH,9
MOV BH,0
MOV AL,'^'
MOV CX,1 
MOV BL,4
INT 10H
POPA

;/////////////////
POP BX
PUSH BX  

MOV CX,0F28H    ;the initial ball pos
                 ; calc midpoint between initial ball pos
                ;and ball destination    
                ; to draw the ball in between
MOV AL,CL

SUB CH,BH

SUB CL,BL

CMP AL,BL
JNB STL    ;if the answer is positive we will calc in stl label
NEG CL        ; if answer is in negative get 2's comp

 ;ball dest is at right of the origin
MOV AX,0000H

MOV AL,CL
MOV DL,2
DIV DL
MOV DL,AL

MOV AH,0 
MOV AL,CH
MOV CL,2
DIV CL
MOV DH,AL 

ADD DX,0628H     ;the origin point must be added to the point we got
          ;/////now we have the mid point between the two positions
MOV BX,0  
MOV AH,2       ;SET CURSOR
INT 10H

PUSH DX  

MOV AH,2
MOV DL,'O'
INT 21H



POP DX 
JMP BM    

CALL DELAY  
CALL DELAY
CALL DELAY
;///////////////

STL:    ; ball is at left of the origin
MOV AX,0000H

MOV AL,CL
MOV DL,2
DIV DL
MOV DL,AL

MOV AH,0 
MOV AL,CH
MOV CL,2
DIV CL
MOV DH,AL
 
ADD DH,06H
ADD DL,BL        ; origin point here differs 
 
MOV BX,0 
 
MOV AH,2       ;SET CURSOR
INT 10H

PUSH DX  
MOV AH,2
MOV DL,'O'
INT 21H


POP DX    

CALL DELAY  
CALL DELAY
CALL DELAY
CALL DELAY

;////////////////

BM:        ;draw ball at destination

MOV BX,0
MOV AH,2       ;SET CURSOR
INT 10H

PUSH DX  
MOV AH,2
MOV DL,' '
INT 21H
POP DX


POP BX  

PUSH BX
MOV DX,BX

MOV BX,0
MOV AH,2       ;SET CURSOR
INT 10H

PUSH DX  




MOV AH,2
MOV DL,'O'
INT 21H
POP DX    

CALL DELAY  
CALL DELAY
CALL DELAY

POP BX
POP DX

RET
ENDP MOVE_BALL
;///////////////////////////////////////////////////////
PROC CONFIGURATION   
    ;CONFIGURATION
mov dx,3fbh  ;SET DIVISOR MODE
mov al,10000000b
out dx,al
                 ;LOWER BITS OF DIVISOR
mov dx,3f8h
mov al,0Ch
out dx,al

mov dx,3f9h       ;HIGHER BITS OF DIVISOR
mov al,00h
out dx,al

mov dx,3fbh               ; SET PARITY AND NUMBER OF BITS
mov al,00011011b
out dx,al
  RET    
  ENDP CONFIGURATION
;//////////////////////////////////////////////////////

;/////////////////////////////////////////////////////
PROC CHAT
PUSHA            

CALL GETPLAYER2NAME 
CALL CLEAR_SCREEN    
 

MOV BX,0
MOV AH,2       ;SET CURSOR
MOV  DX,0D00H
INT 10H  

LEA SI,PLAYERNAME2[2]     ;LOAD player2 name

TYPEee34: ;TYPE  letter by letter
MOV AH,2
MOV DL,[SI]
INT 21H

INC SI
CMP [SI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ NA34                 
JMP TYPEee34
NA34:    
mov ah,2
mov dl,':'
int 21h                  
                  
 MOV BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0C00H
INT 10H   
                       
CALL DRAW_LINE
 
MOV BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0000H
INT 10H

LEA SI,PLAYERNAME[2]     ;LOAD player1 name

TYPEee: ;TYPE  letter by letter
MOV AH,2
MOV DL,[SI]
INT 21H

INC SI
CMP [SI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ NA                 
JMP TYPEee
NA:    
mov ah,2
mov dl,':'
int 21h                  
                  
;GET KEYBOARD     
MOV AH,2       ;SET CURSOR
MOV  DX ,0100H
INT 10H    

iskey:   

 mov ah,1
 int 16h  
 jz NoKey3

 mov ah,0
 int 16h
 

      
;SEND    
CMP AL,0DH     ;if enter pressed print new line
Jne ESS2     
PUSH AX
MOV AH,9
MOV DX,OFFSET LL
INT 21H 
POP AX     

 JMP ssss
ESS2:
call writecurw 
CMP AL,1BH     ;if esc pressed return to menu
JE SSSS
mov outdata,al
PUSH AX
mov ah,2
mov dl,OUTDATA
int 21h 
POP AX
ssss:
MOV OUTDATA,AL
call readcurw
mov dx,3FDh
AGAIN: 
 In al,dx
And Al,00100000b
JZ AGAIN

mov dx,3F8h
mov al,OUTDATA
out dx,al 
CMP AL,1BH
JE BYEY
JMP iskey   

     
;Receiving
NoKey3: 
mov dx,3FDh               ;CHECK STATUS

chk:
in al,dx
AND al,1
JZ iskey
                           ;SOMETHING RECIEVED
mov dx,03F8h
in al,dx
mov INDATA,al   
  
CMP AL,1BH
JE BYEY

CMP AL,0DH   
Jne ESS 

PUSH AX
MOV AH,9
MOV DX,OFFSET LL
INT 21H 
POP AX 


JMP CZ

ESS:
call writecurr                            ;PRINT WHATS RECIEV
mov ah,2
mov dl,INDATA
int 21h 

CZ:
call readcurr
Jmp iskey       
 
BYEY: 
MOV REQ,0            ;
MOV HOST,0

POPA 
JMP OPTIONS    
 RET
ENDP CHAT      
;////////////////////////////////////////////////////         
 readcurr proc
    mov ah,3h
    mov bh,0h
    int 10h
    mov  readcurx,dl
    mov readcury,dh
    ret
    endp
              
   readcurw proc
    mov ah,3h
    mov bh,0h
    int 10h
    mov  writecurx,dl
    mov writecury,dh
    ret
    endp
              
      writecurr proc  ;changes cursor
    mov ah,2
    mov dl,readcurx
    mov dh,readcury
    int 10h
    
    ret
    endp

     writecurw proc   
    mov ah,2
    mov dl,writecurx
    mov dh,writecury
    int 10h
    ret
    endp
;//////////////////////////////////////////////////////




;/////////////////////////////////////////////////////
Proc GETKEY  ;get key press either from player 1 or 2  
    MOV AL,0
  AV:
      
 mov ah,1
 int 16H 
 jz NoKey00
  
 mov ah,0
 int 16h
 MOV PRESS,1      ;set press 1 if you pressed the letter
 
 
CMP HOST,0
JNE SSSSXX
CMP AL,20H      ;if the player that is not his turn press space ignore the press
JNE SSSSXX 
MOV AL,0
JMP NoKey00
  
  SSSSXX:    
;SEND  
mov outdata,al
mov dx,3FDh
AGAIN00: 
 In al,dx
And Al,00100000b
JZ AGAIN00                                


mov dx,3F8h
mov al,OUTDATA     
PUSH AX
out dx,al
POP AX
 JMP iskey00   

     
;Receiving
NoKey00: 
mov dx,3FDh               ;CHECK STATUS

chk00:
in al,dx
AND al,1
JZ iskey00 
  
MOV PRESS,0
                           ;SOMETHING RECIEVED
mov dx,03F8h
in al,dx      
PUSH AX
mov INDATA,al  
POP AX
    ISKEY00:
     CMP AL,0      ;if al contains a press pass the proc
      JE AV
        RET 
ENDP GETKEY      


;///////////////////////////////////////////////////////
 Proc GETKEY2  ;for 2nd turn  
    MOV AL,0
  AVGTK:
      
 mov ah,1
 int 16H 
 jz NoKey00GTK
  
 mov ah,0
 int 16h
 MOV PRESS,1 
 
 CMP HOST,1
JNE SSSGTK
CMP AL,20H
JNE SSSGTK 
MOV AL,0
JMP NoKey00GTK
  
  SSSGTK:  
      
;SEND  
mov outdata,al
mov dx,3FDh
AGAIN00GTK: 
 In al,dx
And Al,00100000b
JZ AGAIN00GTK                                


mov dx,3F8h
mov al,OUTDATA     
PUSH AX
out dx,al
POP AX
 JMP iskey00GTK   

     
;Receiving
NoKey00GTK: 
mov dx,3FDh               ;CHECK STATUS

chk00GTK:
in al,dx
AND al,1
JZ iskey00GTK 
  
MOV PRESS,0
                           ;SOMETHING RECIEVED
mov dx,03F8h
in al,dx      
PUSH AX
mov INDATA,al  
POP AX
    ISKEY00GTK:
     CMP AL,0
      JE AVGTK
        RET 
ENDP GETKEY2      


;////////////////////////////////////////////////////// 
;//////////////////////////////////////////////////////
PROC INGAMECHAT
PUSHA            
                  
;GET KEYBOARD     
MOV AH,2       ;SET CURSOR
MOV  DX ,130AH
INT 10H  

iskeyIN:
 mov ah,1
 
 int 16h  
 jz NoKey3IN
 mov ah,0
 int 16h
      
;SEND    
CMP AL,0DH
Jne ESS2IN 

PUSH AX
MOV AH,2       ;SET CURSOR
MOV  DX ,130AH
INT 10H

CALL CLEAR_LINE   ;clears line if enter pressed and sets cursor to start of the line
MOV AH,2       ;SET CURSOR
MOV  DX ,130AH
INT 10H
POP AX
MOV OUTDATA,AL
 JMP ssssIN
ESS2IN:
call writecurwIN
mov outdata,al

CMP AL,1BH
JE SSSSIN

mov ah,2
mov dl,OUTDATA
int 21h

ssssIN:
call readcurwIN
mov dx,3FDh

AGAININ: 
 In al,dx
And Al,00100000b
JZ AGAININ

mov dx,3F8h
mov al,OUTDATA
out dx,al
CMP AL,1BH
JE BYE 
JMP iskeyIN   

     
;Receiving
NoKey3IN: 
mov dx,3FDh               ;CHECK STATUS

chkIN:
in al,dx
AND al,1
JZ iskeyIN
                           ;SOMETHING RECIEVED
mov dx,03F8h
in al,dx
mov INDATA,al     
CMP AL,1BH
JE BYE
CMP AL,0DH
Jne ESSIN

MOV AH,2       ;SET CURSOR
MOV BX,0
MOV  DX ,150AH
INT 10H

CALL CLEAR_LINE
 MOV AH,2       ;SET CURSOR
MOV  DX ,150AH
INT 10H     
JMP CZIN
ESSIN:
call writecurrIN                            ;PRINT WHATS RECIEV
mov ah,2
mov dl,INDATA
int 21h 
CZIN:
call readcurrIN
Jmp iskeyIN 
BYE:
   POPA
 RET 
 ENDP INGAMECHAT
;////////////////////////////////////////////////// 

 readcurrIN proc
    mov ah,3h
    mov bh,0h
    int 10h
    mov  readcurxIN,dl
    mov readcuryIN,dh
    ret
    endp
              
   readcurwIN proc
    mov ah,3h
    mov bh,0h
    int 10h
    mov  writecurxIN,dl
    mov writecuryIN,dh
    ret
    endp
              
      writecurrIN proc  ;changes cursor
    mov ah,2
    mov dl,readcurxIN
    mov dh,readcuryIN
    int 10h
    
    ret
    endp

     writecurwIN proc   
    mov ah,2
    mov dl,writecurxIN
    mov dh,writecuryIN
    int 10h
    ret
    endp


;///////////////////////////////////////////////////
PROC GETPLAYER2NAME     ;exchange player 2 name
PUSHA

LEA SI,PLAYERNAME[2]     ;LOAD player1 name
LEA DI,PLAYERNAME2[2]

PLPL:
CMP HOST,1      ;sends host name first
JNE  RECNN 

MOV AL,[SI]
      
;SEND     LETTER BY LETTER
mov outdata,al
mov dx,3FDh
AGAIN000: 
 In al,dx
And Al,00100000b
JZ AGAIN000

mov dx,3F8h
mov al,OUTDATA
out dx,al

CMP [SI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ EXO  

INC SI         
JMP PLPL  

RECNN:        ;recieves host name
;Receiving
mov dx,3FDh               ;CHECK STATUS
chk000:
in al,dx
AND al,1
JZ PLPL
                           ;SOMETHING RECIEVED
mov dx,03F8h 
in al,dx     
PUSH AX
mov INDATA,al  
POP AX 
         
MOV [DI],AL

CMP [DI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ EXO  
INC DI 
               
JMP PLPL


EXO:   
LEA SI,PLAYERNAME[2]     ;LOAD player1 name
LEA DI,PLAYERNAME2[2]

PLPL22:
CMP HOST,0 
JNE  RECNN22 
                  ;sendds clent name
MOV AL,[SI]
      
;SEND     LETTER BY LETTER
mov outdata,al
mov dx,3FDh
AGAIN00022: 
 In al,dx
And Al,00100000b
JZ AGAIN00022

mov dx,3F8h
mov al,OUTDATA
out dx,al


CMP [SI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ EXO22  

INC SI         
JMP PLPL22   

RECNN22:        ;recieves client name
;Receiving
mov dx,3FDh               ;CHECK STATUS
chk00022:
in al,dx
AND al,1
JZ PLPL22
                           ;SOMETHING RECIEVED
mov dx,03F8h 
in al,dx     
PUSH AX
mov INDATA,al  
POP AX 
  
MOV [DI],AL

CMP [DI],0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ EXO22  
INC DI 
        
                
JMP PLPL22


EXO22: 
POPA
 
RET
ENDP GETPLAYER2NAME        
;/////////////////////////////////////////////////////////  
PROC RECNAME
PUSHA

LEA DI,PLAYERNAME2[2]
LOOPXx: 
;Receiving
mov dx,3FDh               ;CHECK STATUS
chk0000:
in al,dx
AND al,1
JZ LOOPXx
                           ;SOMETHING RECIEVED
mov dx,03F8h 
in al,dx     
PUSH AX
mov INDATA,al  
POP AX 
         
MOV [DI],AL
cmp al,0Dh
JZ EXO0
inc DI       
JMP LOOPXx
EXO0:   
 
POPA
 
RET
ENDP RECNAME    
;//////////////////////////////////////////////////////////
PROC SENNAME
PUSHA        

LEA SI,PLAYERNAME[2]     ;LOAD player1 name
LEA DI,PLAYERNAME2[2]
LOOPy: 


MOV AL,[SI]
      
;SEND     LETTER BY LETTER
mov outdata,al
mov dx,3FDh
AGAIN0x: 
 In al,dx
And Al,00100000b
JZ AGAIN0x

mov dx,3F8h
mov al,OUTDATA
out dx,al
     
CMP al,0DH    ;i f ascii 0Dh is met  we jmp to print the next label
JZ EXOxx
INC SI  
jmp LOOPy
EXOxx:   
 
POPA
 
RET
ENDP SENNAME
;/////////////////////////////////////////////////////////
PROC GETPLAYER2NAMEx
PUSHA

;clear divisor latch

mov dx,03FBh        ;Line Control Register
in al,dx
and al,0111_1111b   ;Set DLAB=0
out dx,al


LEA SI,PLAYERNAME[2]     ;LOAD player1 name


SendingName:        ;Sending Player Name

mov dx,03FDh        ;Line Status Register
in al,dx
test al,0010_0000b  ;Use bit 5 to see if THR is empty
jz SendingName
lodsb
mov dx,03F8h        ;Transmitter Holding Register   
out dx,al
cmp al,0dh
jne SendingName



 SendNameDone:

 lea ax,PLAYERNAME[2]

 mov dx,3f8h   
 out dx,ax


 ReceivingName:  ;Receiving PLayer Name
 
 mov dx,3fdh
 in al,dx
 test al,00000001b
 jnz ReceiveNameDone
 jmp ReceivingName   ;This will occur if nothing is received.

 ReceiveNameDone:

 mov dx,3f8h
 in ax,dx
 mov si,ax
 LEA DI,PLAYERNAME2[2]
 mov cx,15
 movsb                        
                        
 POPA
 
RET
ENDP GETPLAYER2NAMEx                       
;///////////////////////////////////////////////////
PROC SENDGAMEREQ
    
;SEND     LETTER BY LETTER
mov outdata,al
mov dx,3FDh
AGAINX: 
 In al,dx
And Al,00100000b
JZ AGAINX

mov dx,3F8h
mov al,OUTDATA
out dx,al
    
RET    
ENDP 


;////////////////////////////////////////////////
PROC RECGAMEREQ
    

;Receiving  
REC:        
MOV AH,1       ;get key pressed interrupt
INT 16H    
MOV AH,0       ;TO EMPTY BUFFER
INT 16H   
CMP AL,1BH
JE RETT

mov dx,3FDh               ;CHECK STATUS
in al,dx
AND al,1
JZ REC                                 
 ;SOMETHING RECIEVED
mov dx,03F8h 
in al,dx     
PUSH AX
mov INDATA,al  
POP AX 
CMP AL,47H
JNE REC   

;CHECK IF OTHER PLAYER PRESSED ESC
in al,dx
AND al,1
JZ ISKEYX
                           ;SOMETHING RECIEVED
mov dx,03F8h
in al,dx
mov INDATA,al    

CMP AL,1BH
JE OPTIONS
       
JMP ISKEYX

RETT:
;SEND   ESC      
MOV AL,1BH
mov outdata,al
mov dx,3FDh
AGAINXX: 
 In al,dx
And Al,00100000b
JZ AGAINXX

mov dx,3F8h
mov al,OUTDATA
out dx,al
    
JMP OPTIONS


iskeyX  : 

      
    
RET    
ENDP 
;//////////////////////////////////////////////////   



 ;////////////////////////////////////////////      
PROC GET_OPTION         ; get  input at main menu

OPTION:                
 mov ah,1
 int 16H 
 jz RECop
  
 mov ah,0
 int 16h  

    CMP AL,1BH             ;if esc is pressed end the proc
   JNE SENDOP
   CMP HOST,1     
   JE  OPTIONS        
   CMP REQ,1
   JE OPTIONS   
    JMP END_PROC

SENDOP:
mov outdata,al
mov dx,3FDh
AGAINOP: 
 In al,dx
And Al,00100000b
JZ AGAINOP

mov dx,3F8h
mov al,OUTDATA     
PUSH AX
out dx,al
POP AX
 

CMP AL,47H
JNE COP               ;if G is pressed and you have req jmp to game else seend req
MOV CL,REQ
CMP CL,1
JE GAME_MODE
               
             
MOV CL,1
MOV HOST,CL
;WAIT FOR ACCEPT 
CALL CLEAR_SCREEN
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0A0AH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISPCON
INT 21H    

            
COP:   



CMP AL,43H
JNE RECOP 
MOV CL,REQ
CMP CL,1
JE CHATT
               
             
MOV CL,1
MOV HOST,CL
;WAIT FOR ACCEPT 
CALL CLEAR_SCREEN
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0A0AH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISPCON
INT 21H   

     
     
            
;Receiving
RECOP: 
mov dx,3FDh               ;CHECK STATUS

chkOP:
in al,dx
AND al,1
JZ OPTION
                           ;SOMETHING RECIEVED
mov dx,03F8h
in al,dx      
PUSH AX
mov INDATA,al  
POP AX



CMP AL,47H
JNE ISKEYOP 

MOV CL,HOST
CMP CL,1
JE GAME_MODE

MOV CL,1
MOV REQ,CL
;ACCEPT INVITE CODE    

CALL CLEAR_SCREEN
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0A0AH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISPCON2
INT 21H         

JMP RECOP 

ISKEYOP:   
  
CMP AL,43H
Jne OPTIONS  

MOV CL,HOST
CMP CL,1
JE CHATT

MOV CL,1
MOV REQ,CL
;ACCEPT INVITE CODE    
CALL CLEAR_SCREEN  
PUSHA
MOV  BX,0
MOV AH,2       ;SET CURSOR
MOV  DX ,0A0AH
INT 10H
      
MOV AH,9
MOV DX,OFFSET DISPCON3
INT 21H    
POPA
     
JMP OPTION
    
RET
ENDP GET_OPTION
;///////////////////////////////////////
;//////////////////////////////////////
PROC INPUTKEY      ;update bx,dx for turn 1      
;/////PLAYER 1 KEYS                              

CMP HOST,1
JNE A33   
CMP PRESS,1
JNE A22
A:
CMP AL,41H  
JNZ D 
CMP BL,0
JE D   
DEC BL 
DEC BL
JMP NOKEY
D:
CMP AL,44H  
JNZ W 
CMP BL,78
JE W   
INC BL
INC BL
JMP NOKEY   
W:              ; for power of shot
CMP AL,57H
JNZ NOKEY     
cmp bh,0
JE NOKEY
DEC BH
JMP NOKEY
;////////////////
;///PLAYER 2 KEYS
A22:         
CMP AL,41H  
JNZ DDX 
CMP DL,0
JE DDX   
DEC DL 
DEC DL
JMP NOKEY
DDX:
CMP AL,44H  
JNZ NOKEY 
CMP DL,70
JE NOKEY   
INC DL
INC DL
JMP NOKEY 

 
A33:
CMP PRESS,1
JE A222

CMP AL,41H  
JNZ D222 
CMP BL,0    ;BL MKAN EL SAHM
JE D222   
DEC BL 
DEC BL
JMP NOKEY

D222:
CMP AL,44H     
JNZ W222 
CMP BL,78
JE W222   
INC BL
INC BL
JMP NOKEY   

W222:              ; for power of shot
CMP AL,57H
JNZ NOKEY     
cmp bh,0
JE NOKEY
DEC BH
JMP NOKEY

;////////////////
;///PLAYER 2 KEYS
A222:         
CMP AL,41H  
JNZ DDX22 
CMP DL,0
JE DDX22   
DEC DL 
DEC DL
JMP NOKEY
DDX22:
CMP AL,44H  
JNZ NOKEY 
CMP DL,70
JE NOKEY   
INC DL
INC DL
JMP NOKEY  



 NOKEY:  
 MOV PRESS,0
RET
ENDP INPUTKEY         
;//////////////////////////////////////////////////////   

PROC INPUTKEY2         ;update bx , dx for turn 2

;/////PLAYER 1 KEYS                              

CMP HOST,1
JNE A33X   
CMP PRESS,1
JE A22X
AXX:
CMP AL,41H  
JNZ DXX 
CMP BL,0
JE DXX   
DEC BL 
DEC BL
JMP NOKEY2
DXX:
CMP AL,44H  
JNZ WXX 
CMP BL,78
JE WXX   
INC BL
INC BL
JMP NOKEY2   
WXX:              ; for power of shot
CMP AL,57H
JNZ NOKEY2     
cmp bh,0
JE NOKEY2
DEC BH
JMP NOKEY2
;////////////////
;///PLAYER 2 KEYS
A22X:         
CMP AL,41H  
JNZ DDXX 
CMP DL,0
JE DDXX   
DEC DL 
DEC DL
JMP NOKEY2
DDXX:
CMP AL,44H  
JNZ NOKEY2 
CMP DL,70
JE NOKEY2   
INC DL
INC DL
JMP NOKEY2  



A33X:
CMP PRESS,1
JNE A222X
CMP AL,41H  
JNZ D222X 
CMP BL,0
JE D222X   
DEC BL 
DEC BL
JMP NOKEY2
D222X:
CMP AL,44H  
JNZ W222X 
CMP BL,78
JE W222X   
INC BL
INC BL
JMP NOKEY2   
W222X:              ; for power of shot
CMP AL,57H
JNZ NOKEY2     
cmp bh,0
JE NOKEY2
DEC BH
JMP NOKEY2
;////////////////
;///PLAYER 2 KEYS
A222X:         
CMP AL,41H  
JNZ DDX22X 
CMP DL,0
JE DDX22X   
DEC DL 
DEC DL
JMP NOKEY2
DDX22X:
CMP AL,44H  
JNZ NOKEY2 
CMP DL,70
JE NOKEY2   
INC DL
INC DL
JMP NOKEY2  



 NOKEY2: 
 MOV PRESS,0
 
RET
ENDP INPUTKEY2
;////////////////////////////    

;//////////////////////////////////////
PROC INPUTKEYLVL2      ;update bx,dx for turn 1      
;/////PLAYER 1 KEYS                              

CMP HOST,1
JNE A33LVL2   
CMP PRESS,1
JNE A22LVL2
ALVL2:
CMP AL,41H  
JNZ DLVL2 
CMP BL,0
JE DLVL2   
DEC BL 
DEC BL
JMP NOKEYLVL2
DLVL2:
CMP AL,44H  
JNZ WLVL2 
CMP BL,78
JE WLVL2   
INC BL
INC BL
JMP NOKEYLVL2   
WLVL2:              ; for power of shot
CMP AL,57H
JNZ NOKEYLVL2     
cmp bh,0
JE NOKEYLVL2
DEC BH
JMP NOKEYLVL2
;////////////////
;///PLAYER 2 KEYS
A22LVL2:         
CMP AL,41H  
JNZ DDXLVL2 
CMP DL,0
JE DDXLVL2   
DEC DL 
DEC DL
JMP NOKEYLVL2
DDXLVL2:
CMP AL,44H  
JNZ WADDLVL2 
CMP DL,70
JE NOKEYLVL2   
INC DL
INC DL
JMP NOKEYLVL2 


WADDLVL2:              ; for power of shot
CMP AL,57H
JNZ XADDLVL2    
cmp Dh,0
JE NOKEYLVL2
DEC DH
JMP NOKEYLVL2


XADDLVL2:              ; for power of shot
CMP AL,53H
JNZ NOKEYLVL2     
cmp Dh,06H
JE NOKEYLVL2
INC DH
JMP NOKEYLVL2





 
A33LVL2:
CMP PRESS,1
JE A222LVL2
CMP AL,41H  
JNZ D222LVL2 
CMP BL,0
JE D222LVL2   
DEC BL 
DEC BL
JMP NOKEYLVL2
D222LVL2:
CMP AL,44H  
JNZ W222LVL2 
CMP BL,78
JE W222LVL2   
INC BL
INC BL
JMP NOKEYLVL2   
W222LVL2:              ; for power of shot
CMP AL,57H
JNZ NOKEYLVL2     
cmp bh,0
JE NOKEYLVL2
DEC BH
JMP NOKEYLVL2
;////////////////
;///PLAYER 2 KEYS
A222LVL2:         
CMP AL,41H  
JNZ DDX22LVL2 
CMP DL,0
JE DDX22LVL2   
DEC DL 
DEC DL
JMP NOKEYLVL2
DDX22LVL2:
CMP AL,44H  
JNZ WWADDLVL2 
CMP DL,70
JE NOKEYLVL2   
INC DL
INC DL
JMP NOKEYLVL2     


WWADDLVL2:              ; for power of shot
CMP AL,57H
JNZ XXADDLVL2    
cmp Dh,0
JE NOKEYLVL2
DEC DH
JMP NOKEYLVL2


XXADDLVL2:              ; for power of shot
CMP AL,53H
JNZ NOKEYLVL2     
cmp Dh,06H
JE NOKEYLVL2
INC DH
JMP NOKEYLVL2


 NOKEYLVL2:  
 MOV PRESS,0
RET
ENDP INPUTKEYLVL2         
;//////////////////////////////////////////////////////   

PROC INPUTKEY2LVL2         ;update bx , dx for turn 2

;/////PLAYER 1 KEYS                              

CMP HOST,1
JNE A33XLVL2   
CMP PRESS,1
JE A22XLVL2
AXXLVL2:
CMP AL,41H  
JNZ DXXLVL2 
CMP BL,0
JE DXXLVL2   
DEC BL 
DEC BL
JMP NOKEY2LVL2
DXXLVL2:
CMP AL,44H  
JNZ WXXLVL2 
CMP BL,78
JE WXXLVL2   
INC BL
INC BL
JMP NOKEY2LVL2   
WXXLVL2:              ; for power of shot
CMP AL,57H
JNZ NOKEY2LVL2     
cmp bh,0
JE NOKEY2LVL2
DEC BH
JMP NOKEY2LVL2
;////////////////
;///PLAYER 2 KEYS
A22XLVL2:         
CMP AL,41H  
JNZ DDXXLVL2 
CMP DL,0
JE DDXXLVL2   
DEC DL 
DEC DL
JMP NOKEY2LVL2
DDXXLVL2:
CMP AL,44H  
JNZ WWWADDLVL2
CMP DL,70
JE NOKEY2LVL2   
INC DL
INC DL
JMP NOKEY2LVL2     


WWWADDLVL2:              ; for power of shot
CMP AL,57H
JNZ XXXADDLVL2    
cmp Dh,0
JE NOKEYLVL2
DEC DH
JMP NOKEYLVL2


XXXADDLVL2:              ; for power of shot
CMP AL,53H
JNZ NOKEYLVL2     
cmp Dh,06H
JE NOKEYLVL2
INC DH
JMP NOKEYLVL2

;////////////////////

A33XLVL2:
CMP PRESS,1
JNE A222XLVL2
CMP AL,41H  
JNZ D222XLVL2 
CMP BL,0
JE D222XLVL2   
DEC BL 
DEC BL
JMP NOKEY2LVL2
D222XLVL2:
CMP AL,44H  
JNZ W222XLVL2 
CMP BL,78
JE W222XLVL2   
INC BL
INC BL
JMP NOKEY2LVL2   
W222XLVL2:              ; for power of shot
CMP AL,57H
JNZ NOKEY2LVL2     
cmp bh,0
JE NOKEY2LVL2
DEC BH
JMP NOKEY2LVL2
;////////////////
;///PLAYER 2 KEYS
A222XLVL2:         
CMP AL,41H  
JNZ DDX22XLVL2 
CMP DL,0
JE DDX22XLVL2   
DEC DL 
DEC DL
JMP NOKEY2LVL2
DDX22XLVL2:
CMP AL,44H  
JNZ WWWWADDLVL2 
CMP DL,70
JE NOKEY2LVL2   
INC DL
INC DL
JMP NOKEY2LVL2  



WWWWADDLVL2:              ; for power of shot
CMP AL,57H
JNZ XXXXADDLVL2    
cmp Dh,0
JE NOKEYLVL2
DEC DH
JMP NOKEYLVL2


XXXXADDLVL2:              ; for power of shot
CMP AL,53H
JNZ NOKEYLVL2     
cmp Dh,06H
JE NOKEYLVL2
INC DH
JMP NOKEYLVL2



 NOKEY2LVL2: 
 MOV PRESS,0
 
RET
ENDP INPUTKEY2LVL2       



;//////////////////////////////////////////
;////////////////////////////////////////// 
PROC CHECK_GAMELVL2   ;checks wether game should be ended if player 1 has 5 goals 
                    ;or player 2 or they have a draw
PUSHA         
LEA SI,PLAYER1[2]      ;load player1 score

LEA DI,PLAYER2[2]      ;load player 2 score
  
MOV AL,[SI]
MOV AH,[DI]


CMP AH,35H           ;see if player 2 has   5 goals
JB XXXLVL2
CMP AH,AL           ;see if there is a draw
JZ  XXLVL2   
JMP END_PROG

XXXLVL2:
CMP AL,35H        ;see if player 1 has 5 goals
JB  XXLVL2
CMP AH,AL         ;see if there is  a draw
JZ  XXLVL2 

JMP END_PROG         ; end game if any one wins


XXLVL2:
POPA

RET
ENDP CHECK_GAMELVL2
;///////////////////////////////////
 PROC CHECK_GAME2LVL2
PUSHA         
LEA SI,PLAYER1[2]        ; load the scores

LEA DI,PLAYER2[2]
  
MOV AL,[SI]
MOV AH,[DI]


CMP Al,35H         ;check if playyer 1 has 5 goals
JB SSSLVL2    

SUB AL,AH          ;checks that player 2 is less than 4 goals
CMP AL,2

  
JNB END_PROG

SSSLVL2:
POPA

RET
ENDP CHECK_GAME2LVL2


;//////////////////////////////////////
END MAIN
 