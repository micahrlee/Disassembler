*-----------------------------------------------------------
* Title      : Evan's Share
* Written by : Evan Yang
*-----------------------------------------------------------

* File -> Open data -> Load a .S68 test data into memory
* View -> Memory
* Now your data is in memory
*
* Use $1000 to $4000 for program
* Load test data into $7000
            
MinAddr     EQU     $00000000       ; Least accessible address 
MaxAddr     EQU     $00FFFFFF       ; Greatest accessible address
            *************
            ORG     $1000
            *************

*********** Beginning of program
Start       LEA     IntroMsg,A1     ; Load intro message
            MOVE.L  #14,D0          ; Load Task 14
            TRAP    #15             ; Output intro message to console

*********** Ask for lower-bound memory location
            LEA     LowInputMsg,A1  ; Load message asking for input
            MOVE.B  #14,D0          ; Load Task 14
            TRAP    #15             ; Output ask-for-input message
            MOVE.B  #4,D0           ; Load Task 4
            TRAP    #15             ; Ask for input (cursor appears)
            
*********** Store the lower-bound memory location
            MOVEA.L #0000,A1        ; Set word-size of A1 to 0s
            MOVE.B  #2,D0           ; Load Task 2
            TRAP    #15             ; Store the user-provided lower-bound address
            MOVE.L  (A1),D1         ; Store address to be converted
            MOVE.B  #4,D7           ; Initialize loop counter

*********** Ask for upper-bound memory location
            LEA     UpInputMsg,A1   ; Load message asking for input
            MOVE.B  #14,D0          ; Load Task 14
            TRAP    #15             ; Output ask-for-input message
            MOVE.B  #4,D0           ; Load Task 4
            TRAP    #15             ; Ask for input (cursor appears)

*********** Store the upper-bound memory location
            MOVEA.L #0000,A1        ; Set word-size of A1 to 0s
            MOVE.B  #2,D0           ; Load Task 2
            TRAP    #15             ; Store the user-provided lower-bound address
            MOVE.L  (A1),D1         ; 
            MOVE.B  #4,D7           ; Initialize loop counter

*********** Let user choose whether to run program again or not
            LEA     ProgRedoMsg,A1  ; Load message asking to redo program            
            MOVE.B  #14,D0          ; Load Task 14
            TRAP    #15             ; Output ask-to-redo message

            MOVE.B  #5,D0           ; Load Task 5
            TRAP    #15             ; Read single character from the keyboard into D1.B

            CMP.B   #$30,D1
            BEQ     ProgDone        

            CMP.B   #$31,D1         
            BEQ     ProgRedo

*********** User chose to redo program, so clear all registers and
*********** jump back to label "Start"
ProgRedo
            CLR     D0              ; Clear data register 0
            CLR     D1              ; Clear data register 1
            CLR     D2              ; Clear data register 2
            CLR     D3              ; Clear data register 3
            CLR     D4              ; Clear data register 4
            CLR     D5              ; Clear data register 5
            CLR     D6              ; Clear data register 6
            CLR     D7              ; Clear data register 7
            
            SUBA.L A0,A0            ; Clear address register 0
            SUBA.l A1,A1            ; Clear address register 1
            SUBA.l A2,A2            ; Clear address register 2
            SUBA.l A3,A3            ; Clear address register 3
            SUBA.l A4,A4            ; Clear address register 4
            SUBA.l A5,A5            ; Clear address register 5
            SUBA.l A6,A6            ; Clear address register 6
                  
            JMP     Start           ; Jump to Start (perform program again)

*********** Let user choose whether to run program again or not
CR          EQU     $0D             ; Carriage Return
LF          EQU     $0A             ; Line Feed
IntroMsg    DC.B    'This is a 68K disassembler by Team Blue.',CR,LF,0
LowInputMsg DC.B    'Enter the lower-bound memory location you want to access: ',0
ProgRedoMsg DC.B    'Do you want to redo this program? ',CR,LF,0
UpInputMsg  DC.B    'Enter the upper-bound memory location you want to access: ',0

            END     Start           ; Last line of source code
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
