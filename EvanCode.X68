*-----------------------------------------------------------
* Title      : Evan's Code
* Written by : Evan Yang
* Date       :
* Description:
*-----------------------------------------------------------
* D0 holds the bits we are immediately concerned with
* D1 holds the shift amount
* D2 holds the entire instruction we are currently decoding
* A0 holds the JMP_TABLE starting address
* A1 holds the GOOD_BUFFER starting address
* A2 holds the BAD_BUFFER starting address 

STACK       EQU     $A000
GOOD_BUFFER EQU     $0000E000           ; Store valid instruction
BAD_BUFFER  EQU     $0000F000           ; Store invalid or non-required opcodes
NOP_BITS    EQU     %0100111001110001
        
START       ORG     $1000               ; first instruction of program
            LEA     STACK,SP            ; Load stack pointer
            LEA     JMP_TABLE,A0        ; Load A0
            LEA     GOOD_BUFFER,A1         
            LEA     BAD_BUFFER,A2      
            BRA     GET_OPCODE
            
GET_OPCODE            
            CLR.L   D0                  ; Clear D0
            MOVE.W  #NOP_BITS,D0
            MOVE.W  D0,D2               ; To save instruction, also move D0 into D2
            MOVE.B  #12,D1              ; Load 12 into D1      
            LSR.W   D1,D0               ; Shifts D0 right by 12 bits
            * At this point, D0 has 4 MSBs
            MULU    #6,D0               ; Form offset
            JSR     0(A0,D0)            ; Jump indirect with index
            
***********************************************************
* Credit: Professor Kim's "Project Description - Addendum"*
* This table covers all 16 possible combinations for the  *
* 4 MSBs.                                                 *
***********************************************************
JMP_TABLE   JMP     CODE0000
            JMP     CODE0001
            JMP     CODE0010
            JMP     CODE0011
            JMP     CODE0100
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
            
***********************************************************
* Credit: Professor Kim's "Project Description - Addendum"*
* This section is where the JMP_TABLE jumps to, based on  *
* the jump destination.                                   *
*********************************************************** 
CODE0000    BRA     CHOOSE0000
CODE0001    BRA     CHOOSE0001
CODE0010    BRA     CHOOSE0010
CODE0011    BRA     CHOOSE0011
CODE0100    BRA     CHOOSE0100
CODE0101    BRA     CHOOSE0101
CODE0110    BRA     CHOOSE0110
CODE0111    BRA     CHOOSE0111
CODE1000    BRA     CHOOSE1000
CODE1001    BRA     CHOOSE1001
CODE1010    BRA     CHOOSE1010
CODE1011    BRA     CHOOSE1011
CODE1100    BRA     CHOOSE1100
CODE1101    BRA     CHOOSE1101
CODE1110    BRA     CHOOSE1110
CODE1111    BRA     CHOOSE1111

CHOOSE0000
CHOOSE0001
CHOOSE0010
CHOOSE0011
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
            
            CMP.B   #%001,D0    ; If bytes are equal to the specific op code
            BEQ     WRITE_NOP   ;   branch to it
            CMP.B   #%010,D0
            BEQ     WRITE_JSR             
            CMP.B   #%111,D0
            BEQ     WRITE_LEA

*001    
WRITE_NOP   
            CLR.L     (A1)            ; Clear data that A1 points to
            MOVE.B  #'N',(A1)+
            MOVE.B  #'O',(A1)+
            MOVE.B  #'P',(A1)+
            MOVE.B  #'X',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
                        MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            JSR    PRINT_GOOD_BUFFER

*010
WRITE_JSR
            CLR.L   (A1)            ; Clear data that A1 points to
            MOVE.B  #'J',(A1)+
            MOVE.B  #'S',(A1)+
            MOVE.B  #'R',(A1)+
            JSR    PRINT_GOOD_BUFFER    

*111
WRITE_LEA
            CLR.L   (A1)            ; Clear data that A1 points to
            MOVE.B  #'L',(A1)+
            MOVE.B  #'E',(A1)+
            MOVE.B  #'A',(A1)+
            JSR    PRINT_GOOD_BUFFER

CHOOSE0101
CHOOSE0110
CHOOSE0111
CHOOSE1000
CHOOSE1001
CHOOSE1010
CHOOSE1011
CHOOSE1100
CHOOSE1101
CHOOSE1110
CHOOSE1111

PRINT_GOOD_BUFFER
            LEA     GOOD_BUFFER,A1  ; Move A1's pointer back so it can
                                    ;   print entire op-code word
            MOVE.B  #1,D0           ; Load code #1
            TRAP    #15             ; Call Trap #1

* Put variables and constants here

CR          EQU     $0D ; Carriage return
LF          EQU     $0A ; Line feed
TAB         EQU     $09 ; '   '
COMMA       EQU     $2C ; ,
NULL        EQU     $00 ; 
O_PAREN     EQU     $28 ; (
C_PAREN     EQU     $29 ; )
PLUS        EQU     $2B ; +
MINUS       EQU     $2D ; -
HASH        EQU     $23 ; #
MONEY	    EQU	    $24 ; $
****************** Do not write past here *****************            
            
            END    START                ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
