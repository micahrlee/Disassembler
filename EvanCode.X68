*-----------------------------------------------------------
* Title      : Evan's Test
* Written by : Evan Yang
* Date       :
* Description:
*-----------------------------------------------------------
* D0 holds the bits we are immediately concerned with
* D1 holds the shift amount
* D2 holds the entire instruction we are currently decoding

STACK       EQU     $A000
NOP_BITS    EQU     %0100111001110001
        
START       ORG     $1000               ; first instruction of program
            LEA     STACK,SP            ; Load stack pointer
            LEA     JMP_TABLE,A0        ; Load A0
            CLR.L   D0                  ; Clear D0
            MOVE.W  #NOP_BITS,D0        ; Move entire instruction to D0
            MOVE.W  D0,D2               ; To save instruction, also move D0 into D2
            MOVE.B  #12,D1              ; Load 12 into D1      
            LSR.W   D1,D0               ; Shifts D0 right by 12 bits
            * At this point, D0 = 0000000000000100 
            MULU    #6,D0               ; Form offset
            JSR     0(A0,D0)            ; Jump indirect with index
*****************************************
* Credit: Professor Kim's "Project Description - Addendum"
* This table covers all 16 possible combinations for the
* 4 MSBs.
*****************************************           
JMP_TABLE   JMP     CODE0000
            JMP     CODE0001
            JMP     CODE0010
            JMP     CODE0011
            JMP     CODE0100 * for NOP
            JMP     CODE0101
            JMP     CODE0110
            JMP     CODE0111
            JMP     CODE1000
            JMP     CODE1001
            JMP     CODE1010
            JMP     CODE1011
            JMP     CODE1100
            JMP     CODE1101
            JMP     CODE1110
            JMP     CODE1111
            
*****************************************
* Credit: Professor Kim's "Project Description - Addendum"
* This section is where the JMP_TABLE jumps to, based on 
* the jump destination.
***************************************** 
CODE0000    STOP    #$2700
CODE0001    STOP    #$2700
CODE0010    STOP    #$2700
CODE0011    STOP    #$2700
CODE0100    BRA     CHOOSE0100
CODE0101    STOP    #$2700
CODE0110    STOP    #$2700
CODE0111    STOP    #$2700
CODE1000    STOP    #$2700
CODE1001    STOP    #$2700
CODE1010    STOP    #$2700
CODE1011    STOP    #$2700
CODE1100    STOP    #$2700
CODE1101    STOP    #$2700
CODE1110    STOP    #$2700
CODE1111    STOP    #$2700

******
*0100*
******
CHOOSE0100
            MOVE.W  D2,D0       ; Entire instruction is saved in D2,
                                ;   so move that into D0
            MOVE.B  #23,D1      ; Load 23 into D1 for shifting
            LSL.L   D1,D0       ; Shift D0 left by 23 bits
            MOVE.B  #29,D1      ; Load 29 into D1 for shifting
            LSR.L   D1,D0       ; Shift D0 right by 29 bits
            * At this point, we have isolated bits 6/7/8 to D0
            CMP.B   #%001,D0    ;If bytes are equal to the specific op code
            BEQ     WRITE_NOP   ;branch to it
            CMP.B   #%111
            BEQ     WRITE_LEA
            CMP.B   #%010
            BEQ     WRITE_JSR 
    
WRITE_NOP   
            ;ADD TAB            

            END    START                ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
