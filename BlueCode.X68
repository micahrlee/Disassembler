*-----------------------------------------------------------
* Title      : BLUE GROUP Code
* Written by : Shane Barker, Micah Lee, Evan Yang
* Date       : 30 MAY 2014
* Description: 68K DISASSEMBLER
*-----------------------------------------------------------

********  ADDRESS AND REGISTER DESIGNATIONS  ***************

* D0 holds the bits we are immediately concerned with
* D1 holds the shift amount
* D2 holds the entire instruction we are currently decoding
* D3 holds the size of the OPCODE instruction (Byte, Word, Long)
* D4 HOLDS BAD BUFFER INDICATOR

* A0 holds the JMP_TABLE starting address
* A1 holds the GOOD_BUFFER starting address
* A2 holds the BAD_BUFFER starting address

************************************************************

STACK       EQU     $A000
GOOD_BUFFER EQU     $0000E000           	; Store valid instruction
BAD_BUFFER  EQU     $0000F000           	; Store invalid or non-required opcodes
NOP_BITS    EQU     %0100111001110001

*****    SYMBOLS AND SPECIAL FUNCTIONS/CHARACTERS     ******

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
PERIOD      EQU     $2E ; .
        
START       ORG     $1000               	; first instruction of program
            LEA     STACK,SP            	; Load stack pointer
            LEA     JMP_TABLE,A0        	; Load jump table address to A0
            LEA     GOOD_BUFFER,A1        	; Load good buffer address to A1
            LEA     BAD_BUFFER,A2     	; Load bad buffer address to A2
            BRA     GET_OPCODE		; Branch to GET_OPCODE
            
GET_OPCODE           
						; CHECK FOR LINE OF INPUT (IF ANY)
            CLR.L   D0                  	; Clear D0
            MOVE.W  #NOP_BITS,D2		; ??? CHANGE NOP BITS
            MOVE.W  D2,D0               	; To save instruction, also move D2 into D0
            MOVE.B  #12,D1              	; Load 12 into D1     
            LSR.W   D1,D0               	; Shifts D0 right by 12 bits
            
    * At this point, D0 has 4 MSBs
            MULU    #6,D0               	; Form offset
            JSR     0(A0,D0)            	; Jump indirect with index
            
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


*********************************************************************
*         0000       Bit manipulation/MOVEP/Immediate/ORI/BCLR/CMPI *
*********************************************************************
CHOOSE0000
	* If bits 8/9/10/11 are 1100, it’s CMPI
***********************************************************
*         0001       Move Byte       00 01 (BYTE SIZE)    *
***********************************************************
CHOOSE0001 * MOVE BYTE

     CLR.L     (A1)            	; Clear data that A1 points to
            MOVE.B  #'M',(A1)+		; PRINTS MOVE.B TO BUFFER
            MOVE.B  #'O',(A1)+
            MOVE.B  #'V',(A1)+
            MOVE.B  #'E',(A1)+
            MOVE.B  #'.',(A1)+
            MOVE.B  #'B',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+

    JSR		MOVE_SRC_MODE		; JUMP TO SUBROUTINE
    MOVE.B  #',',(A1)+ 		; COMMA IN BETWEEN SOURCE AND DESTINATION
    JSR 	MOVE_DEST_MODE		; BRANCH TO MOVES DESTINATION

    JSR 	PRINT_GOOD_BUFFER	; PRINTS THE GOOD BUFFER
    BRA		GET_OPCODE		; RETURNS FOR ANOTHER LINE
* END MOVE BYTE ----------------------------------------------------------

***********************************************************
*         0010       Move Long       00 10 (LONG SIZE)    *
***********************************************************
CHOOSE0010
     CLR.L   (A1)            		; Clear data that A1 points to
            MOVE.B  #'M',(A1)+		; PRINTS MOVE.L OR MOVEA.L TO BUFFER
            MOVE.B  #'O',(A1)+
            MOVE.B  #'V',(A1)+
            MOVE.B  #'E',(A1)+

	    JSR	     GET678			; GETS BITS AT 6,7, AND 8 INTO D0
	    CMP.B   #%001,D0			; COMPARES 001 TO D0
	    BEQ     TOMOVEALONG		; IF EQUAL TO 001 ADDS 'A' TO MOVEA BUFFER
	    BRA	    TOMOVELONG			; ELSE MOVES TO 

TOMOVEALONG     
    MOVE.B  #'A',(A1)+			; ADDS 'A' TO MOVEA, THEN MOVES TO NEXT LINE

TOMOVELONG      
            MOVE.B  #'.',(A1)+
            MOVE.B  #'L',(A1)+
    MOVE.B  #' ',(A1)+

    JSR		MOVE_SRC_MODE		; JUMP TO SOURCE SUBROUTINE 
    MOVE.B  #', ',(A1)+
    JSR 	MOVE_DEST_MODE		; JUMP TO DESTINATION SUBROUTINE

    JSR 	PRINT_GOOD_BUFFER	; PRINTS THE GOOD BUFFER
    BRA		GET_OPCODE		; RETURNS FOR ANOTHER LINE

* END MOVE LONG ---------------------------------------------------------

***********************************************************
*         0011       Move Word       00 1 (WORD SIZE)    *
***********************************************************
CHOOSE0011
    CLR.L     (A1)            	; Clear data that A1 points to
            MOVE.B  #'M',(A1)+		; PRINTS MOVE.W OR MOVEA.W TO BUFFER
            MOVE.B  #'O',(A1)+
            MOVE.B  #'V',(A1)+
            MOVE.B  #'E',(A1)+

	    JSR	     GET678			; GETS BITS AT 6,7, AND 8 INTO D0
	    CMP.B   #%001,D0			; COMPARES 001 TO D0
	    BEQ     TOMOVEAWORD		; IF EQUAL TO 001 ADDS 'A' TO MOVEA BUFFER
	    BRA	    TOMOVEWORD

TOMOVEAWORD     
    MOVE.B  #'A',(A1)+			; ADDS 'A' TO MOVEA, THEN MOVES TO NEXT LINE

TOMOVEWORD      
            MOVE.B  #'.',(A1)+
            MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+

    JSR		MOVE_SRC_MODE		; JUMP TO SOURCE SUBROUTINE
    MOVE.B  #', ',(A1)+ 
    JSR 	MOVE_DEST_MODE		; JUMP TO DESTINATION SUBROUTINE

    JSR 	PRINT_GOOD_BUFFER	; PRINTS THE GOOD BUFFER
    BRA		GET_OPCODE		; RETURNS FOR ANOTHER LINE

* END MOVE WORD---------------------------------------------------------

***********************************************************
*         0100       JSR/LEA/MOVEM/NEG/RTS                *
***********************************************************

CHOOSE0100
* DETERMINATIONS
	    JSR	    GET6TO11			; Get bits 6 through 11 at D0

* JSR SECTION
            CMP.B   #%111010,D0    		; If bits equal 111010, branch to JSR
            BEQ     GOTO_JSR   		; Branch to JSR opcode

* MOVEM SECTION
            CMP.B   #%100010,D0		; If bits equal 100010, branch TO GOTO_MOVEM
            BEQ     GOTO_MOVEM		; BRANCH TO GOTO_MOVEM (REG TO MEM)
            CMP.B   #%110010,D0		; If bits equal 110010, branch TO GOTO_MOVEM
            BEQ     GOTO_MOVEM		; BRANCH TO GOTO_MOVEM (MEM TO REG)
            CMP.B   #%100011,D0		; If bits equal 100011, branch TO GOTO_MOVEM
            BEQ     GOTO_MOVEM		; BRANCH TO GOTO_MOVEM (REG TO MEM)
            CMP.B   #%110011,D0		; If bits equal 110011, branch TO GOTO_MOVEM
            BEQ     GOTO_MOVEM		; BRANCH TO GOTO_MOVEM (MEM TO REG)

* NEG SECTION
            CMP.B   #%010000,D0		; If bits equal 010000, branch TO NEGBYTE
            BEQ     NEGBYTE			; BRANCH TO NEGBYTE
            CMP.B   #%010001,D0		; If bits equal 010001, branch TO NEGWORD
            BEQ     NEGWORD		; BRANCH TO NEGWORD
            CMP.B   #%010010,D0		; If bits equal 010010, branch TO NEGLONG
            BEQ     NEGLONG		; BRANCH TO NEGLONG 

*RTS SECTION
            CMP.B   #%111001,D0		; If bits equal 111001, branch TO GOTO_RTS
            BEQ     GOTO_RTS		; BRANCH TO GOTO_RTS

* SWITCH TO CHECK BITS 6 THROUGH 8
	    JSR     GET678		* At this point, we have isolated bits 6/7/8 to D0
 
*LEA SECTION DETERMINE
            CMP.B   #%111,D0		; If bits equal to 111, branch TO LEA
            BEQ     GOTO_LEA   	; Branch to GOTO_LEA

*NOP SECTION DETERMINE
            CMP.B   #%001,D0    	; If bits equal 001, branch TO NOP
            BEQ     GOTO_NOP    	; Branch to GOTO_NOP

	    BRA     WRITE_INVALID 	; NOTHING ELSE CAN EXIST, PRINT OUT BAD BUFFER

************************** ALL WRITE OUTS FOR OPCODE 0100 *****************************

GOTO_JSR 
            CLR.L   (A1)            ; Clear data that A1 points to
            MOVE.B  #'J',(A1)+
            MOVE.B  #'S',(A1)+
            MOVE.B  #'R',(A1)+
	    MOVE.B  #' ',(A1)+
    JSR	    JSR_MODE	     ; Jump to JSR_MODE
    JSR     PRINT_GOOD_BUFFER ; Print the whole JSR instruction
    BRA		GET_OPCODE		; RETURNS FOR ANOTHER LINE


GOTO_MOVEM
    CLR.L     (A1)            	; Clear data that A1 points to
            MOVE.B  #'M',(A1)+		; PRINTS MOVEM.W OR MOVEM.L TO BUFFER
            MOVE.B  #'O',(A1)+
            MOVE.B  #'V',(A1)+
            MOVE.B  #'E',(A1)+
            MOVE.B  #'M',(A1)+
            MOVE.B  #'.',(A1)+

    CMP.B   #%100010,D0		; If bits equal 100010, branch TO MOVEM_w
    BEQ		MOVEM_w
    CMP.B   #%110010,D0		; If bits equal 100010, branch TO MOVEM_w
    BEQ		MOVEM_w
    CMP.B   #%100010,D0		; If bits equal 100010, branch TO MOVEM_L
    BEQ		MOVEM_L
    CMP.B   #%110010,D0		; If bits equal 100010, branch TO MOVEM_L
    BEQ		MOVEM_L
MOVEM_W
	    MOVE.B  #'W',(A1)+		; ADDS W IF WORD
	    MOVE.B  #' ',(A1)+
	    BRA MOVEM_CONT

MOVEM_L
	    MOVE.B  #'L',(A1)+		; ADDS L IF LONG WORD
	    MOVE.B  #' ',(A1)+
	    BRA MOVEM_CONT

MOVEM_CONT
	    JSR		MOVEM_SRC_MODE	; JUMP TO SOURCE SUBROUTINE
    MOVE.B  #', ',(A1)+		; PRINTS COMMA
	    JSR		MOVEM_DEST_MODE	; JUMP TO DESTINATION SUBROUTINE

NEGBYTE

NEGWORD

NEGLONG

GOTO_RTS 
            CLR.L   (A1)            ; Clear data that A1 points to
            MOVE.B  #'R',(A1)+
            MOVE.B  #'T',(A1)+
            MOVE.B  #'S',(A1)+
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

    JSR     PRINT_GOOD_BUFFER ; Print the whole JSR instruction
    BRA	    GET_OPCODE		; RETURNS FOR ANOTHER LINE


GOTO_LEA
            CLR.L   (A1)            ; Clear data that A1 points to
            MOVE.B  #'L',(A1)+
            MOVE.B  #'E',(A1)+
            MOVE.B  #'A',(A1)+
            JSR    PRINT_GOOD_BUFFER
    	    BRA		GET_OPCODE		; RETURNS FOR ANOTHER LINE

GOTO_NOP  
            CLR.L     (A1)            ; Clear data that A1 points to
            MOVE.B  #'N',(A1)+
            MOVE.B  #'O',(A1)+
            MOVE.B  #'P',(A1)+
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
            JSR     	PRINT_GOOD_BUFFER
    	    BRA		GET_OPCODE		; RETURNS FOR ANOTHER LINE

***********************************************************
*         0101       SUBQ/Scc/DBcc                        *
***********************************************************

CHOOSE0101

***********************************************************
*         0110       BSR,BRA,Bcc    BCS BGE BLT BVC       *
***********************************************************

CHOOSE0110
	* If bits 8/9/10/11 are 0000, it’s BRA
	* If bits 8/9/10/11 are 0001, it’s BSR

***********************************************************
*         0111       MOVEQ                                *
***********************************************************

CHOOSE0111

***********************************************************
*         1000       OR/DIVS.W                               *
***********************************************************

CHOOSE1000
	* If bits 6/7/8 are 111, it’s DIVS.W
***********************************************************
*         1001       SUB                                  *
***********************************************************

CHOOSE1001

***********************************************************
*         1010       Unassigned  LEA? NEG? BCLR? JSR? RTS?*
***********************************************************

CHOOSE1010

***********************************************************
*         1011       CMP/EOR                              *
***********************************************************

CHOOSE1011

***********************************************************
*         1100       AND/MUL                              *
***********************************************************

CHOOSE1100

***********************************************************
*         1101       ADD/ADDA/ADDX                        *
***********************************************************

CHOOSE1101

***********************************************************
*         1110       Shift/Rotate  LSL LSR ASL ASR ROL ROR*
***********************************************************

CHOOSE1110

***********************************************************
*         1111       Special/Reserved                     *
***********************************************************

CHOOSE1111

***********************************************************
*         END of 4 MSB Section                            *
***********************************************************

PRINT_GOOD_BUFFER
            LEA     GOOD_BUFFER,A1  ; Move A1's pointer back so it can
                                    ; print entire op-code word
            MOVE.B  #1,D0           ; Load code #1
            TRAP    #15             ; Call Trap #1
            
PRINT_BAD_BUFFER
            LEA     BAD_BUFFER,A1   ; Move A1's pointer back so it can
                                    ; print entire op-code word
            MOVE.B  #1,D0           ; Load code #1
            TRAP    #15             ; Call Trap #1

*********************
* Effective Address *
*********************
MOVE_SRC_MODE
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE

MOVE_DEST_MODE 
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #23,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_DEST  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_DEST 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_DEST 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_DEST 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_DEST_ADDRESS

MOVEA_SRC_MODE
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE
        
MOVEA_DEST_MODE
        ;BRA     WRITE_AN 

MOVEM_SRC_MODE
MOVEM_DEST_MODE

ADD_SRC_MODE_V1         ;THIS IS IF SOURCE IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE
        
ADD_SRC_MODE_V2             ;THIS IS IF DN IS SOURCE
        ;BRA     WRITE_DN_DEST 

        
ADD_DEST_MODE_V1                ;THIS IS IF DESTINATION IS DN
        ;BRA     WRITE_DN_DEST  

    
ADD_DEST_MODE_V2            ;THIS IS IF DESTINATION IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

ADDB_SRC_MODE_V1         ;THIS IS IF SOURCE IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE
        
ADDB_SRC_MODE_V2             ;THIS IS IF DN IS SOURCE
        ;BRA     WRITE_DN_DEST  
        
ADDB_DEST_MODE_V1                ;THIS IS IF DESTINATION IS DN
        ;BRA     WRITE_DN_DEST  
         
ADDB_DEST_MODE_V2            ;THIS IS IF DESTINATION IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

ADDA_SRC_MODE         ;THIS IS IF SOURCE IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE

ADDA_DEST_MODE
      	;WRITE_AN_DEST 

SUB_SRC_MODE_V2         ;THIS IS IF SOURCE IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE
        
SUB_SRC_MODE_V1             ;THIS IS IF DN IS SOURCE
        ;BRA    WRITE_DN_DEST
        
SUB_DEST_MODE_V2                ;THIS IS IF DESTINATION IS DN
        ;BRA    WRITE_DN_DEST          
SUB_DEST_MODE_V1            ;THIS IS IF DESTINATION IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

SUBQ_SRC_MODE             ;IMMEDIATE DATA ONLY
        ;BRA    WRITE_IMMEDIATE_DEST
       
SUBQ_DEST_MODE            ;DESTINATION
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

JSR_MODE    
    * Get EA’s mode
    CLR.L   D0		  		; Clear D0
    MOVE.W  D2,D0       		; Entire instruction is saved in D2,
                                		;   so move that into D0
            MOVE.B  #26,D1      		; Load 26 into D1 for shifting
            LSL.L   D1,D0       		; Shift D0 left by 26 bits
            MOVE.B  #29,D1      		; Load 29 into D1 for shifting
            LSR.L   D1,D0       		; Shift D0 right by 20 bits
            * At this point, we have isolated bits 3/4/5 to D0
            CMP.B   #%000,D0
            ;BEQ     WRITE_DN
            CMP.B   #%001,D0
            ;BEQ     WRITE_AN
            CMP.B   #%010,D0
            ;BEQ     WRITE_AN_IND
            CMP.B   #%011,D0
            ;BEQ     WRITE_AN_INCR 
            CMP.B   #%100,D0
            ;BEQ     WRITE_AN_DEC 
            CMP.B   #%101,D0
            ;BEQ     WRITE_INVALID 
            CMP.B   #%110,D0
            ;BEQ     WRITE_INVALID 
            CMP.B   #%111,D0
            ;BEQ     CHOOSE_EA111_(SRC/DEST)_(ADDRESS/IMMEDIATE)

MULSW_SRC_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
	CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE

MULSW_DEST_MODE
	;BRA	WRITE_IMMEDIATE_DEST

MULSL_SRC_MODE 		;???
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
	CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE

MULSL_DEST_MODE		;???

LEA_SRC_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
	CMP.B   #%000,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%100,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

LEA_DEST_MODE
	;BRA	WRITE_AN_DEST

OR_SRC_MODE_V1         ;THIS IS IF SOURCE IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE
        
OR_SRC_MODE_V2             ;THIS IS IF DN IS SOURCE
        ;BRA    WRITE_DN_DEST
        
OR_DEST_MODE_V1                ;THIS IS IF DESTINATION IS DN
        ;BRA    WRITE_DN_DEST          

OR_DEST_MODE_V2            ;THIS IS IF DESTINATION IS EA
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_INVALID  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC 
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

ORI_SRC_MODE	;???

ORI_DEST_MODE	;???
	
NEG_SRC_MODE
        CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS
        
EOR_SRC_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

EOR_DEST_MODE
	;BRA	WRITE_DN_DEST

LSL_SRC_MODE		;???
LSL_DEST_MODE		;???
LSR_SRC_MODE		;???
LSR_DEST_MODE		;???

ASL_SRC_MODE		;???
ASL_DEST_MODE		;???
ASR_SRC_MODE		;???
ASR_DEST_MODE		;???

ROL_SRC_MODE		;???
ROL_DEST_MODE		;???
ROR_SRC_MODE		;???
ROR_DEST_MODE		;???

BCLRDYNL_SRC_MODE
	;BRA	WRITE_DN_DEST

BCLRDYNL_DEST_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC  
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%011,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%100,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     WRITE_INVALID

BCLRDYNB_SRC_MODE
	;BRA	WRITE_DN_DEST

BCLRDYNB_DEST_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

BCLRIMMB_SRC_MODE
	;SOMEHOW GET IMMEDIATE DATA

BCLRIMMB_DEST_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC 
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

BCLRIMML_SRC_MODE
	;SOMEHOW GET IMMEDIATE DATA

BCLRIMML_DEST_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%011,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     WRITE_INVALID

CMPB_SRC_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE

CMPB_DEST_MODE
	;BRA	WRITE_DN_DEST

CMP_SRC_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC
        CMP.B   #%001,D0
        ;BEQ     WRITE_AN_SRC
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_IMMEDIATE

CMP_DEST_MODE
	;BRA	WRITE_DN_DEST

CMPI_SRC_MODE
	;BRA	WRITE_IMMEDIATE

CMPI_DEST_MODE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #26,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
        CMP.B   #%000,D0
        ;BEQ     WRITE_DN_SRC
        CMP.B   #%001,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%010,D0
        ;BEQ     WRITE_AN_IND_SRC
        CMP.B   #%011,D0
        ;BEQ     WRITE_AN_INCR_SRC
        CMP.B   #%100,D0
        ;BEQ     WRITE_AN_DEC_SRC
        CMP.B   #%101,D0
        ;BEQ     WRITE_INVALID
        CMP.B   #%110,D0
        ;BEQ     WRITE_INVALID 
        CMP.B   #%111,D0
        ;BEQ     CHOOSE_EA111_SRC_ADDRESS

BRA		;???

CHOOSE_EA111_DEST_ADDRESS
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #20,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
	CMP.B	#%000
	;BEQ	WRITE_WORD
	CMP.B	#%001
	;BEQ	WRITE_LONG
	;BRA	WRITE_INVALID

CHOOSE_EA111_SRC_ADDRESS
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #29,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
	CMP.B	#%000
	;BEQ	WRITE_WORD
	CMP.B	#%001
	;BEQ	WRITE_LONG
	;BRA	WRITE_INVALID

CHOOSE_EA111_SRC_IMMEDIATE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #29,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
	CMP.B	#%000
	;BEQ	WRITE_WORD
	CMP.B	#%001
	;BEQ	WRITE_LONG
	CMP.B	#100
	;BEQ	WRITE_IMMEDIATE_SRC
	;BRA	WRITE_INVALID
	
CHOOSE_EA111_DEST_IMMEDIATE
	CLR.L   D0
        MOVE.W  D2,D0
        MOVE.B  #20,D1
        LSL.L   D1,D0
        MOVE.B  #29,D1
        LSR.L   D1,D0
	CMP.B	#%000
	;BEQ	WRITE_WORD
	CMP.B	#%001
	;BEQ	WRITE_LONG
	CMP.B	#%100
	;BEQ	WRITE_IMMEDIATE_DEST
	;BRA	WRITE_INVALID	
	
**********************
* COMMON SUBROUTINES *
**********************

******************* GET678 GETS THE BITS LOCATED AT POSITION 6, 7, AND 8 ****************
GET678
    MOVE.W  D2,D0       ; Entire instruction is saved in D2, so move that into D0
            MOVE.B  #23,D1      ; Load 23 into D1 for shifting
            LSL.L   D1,D0       ; Shift D0 left by 23 bits
            MOVE.B  #29,D1      ; Load 29 into D1 for shifting
            LSR.L   D1,D0       ; Shift D0 right by 29 bits, we have isolated bits 6/7/8 to D0
            RTS

******************* GET6TO11 GETS THE BITS LOCATED AT POSITION 6 THROUGH 11 ****************
GET6TO11
    MOVE.W  D2,D0       ; Entire instruction is saved in D2, so move that into D0
            MOVE.B  #20,D1      ; Load 20 into D1 for shifting
            LSL.L   D1,D0       ; Shift D0 left by 20 bits
            MOVE.B  #26,D1      ; Load 26 into D1 for shifting
            LSR.L   D1,D0       ; Shift D0 right by 29 bits, we have isolated bits 6 THROUGH 11 to D0
            RTS
*****************************************************************************************



****************** Do not write past here *****************           
            
            END    START                ; last line of source



*STOP        #$2700
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
