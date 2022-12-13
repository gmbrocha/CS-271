TITLE Input/Output Program     (Project1.asm)

; Author: Glen Brochard
; Last Modified: 10/10/2022
; OSU email address: brocharg@oregonstate.edu
; Course number/section: CS271 Section 400 F2022
; Project Number: 1   Due Date: 10/16/2022
; Description: Project 1; Introduces program title and creator; prompts user for 3 numeric inputs in descending order; checks
;		for descending order validity; calculates addition, subtraction, and division of signed numeric data; displays results of
;		those calculations; asks for progrom restart from user and uses input conditionally; gives closing goodbye statement

INCLUDE Irvine32.inc

.data

; NEED TO UPDATE THIS COMMENT
progTitle        byte  "        --Basic I/O Arithmetic",0	      ; program title
creator          byte  "-----by Glen M Brochard--",0              ; creator name to be displayed
userInstruction  byte  "Enter three numbers in descending order; calculations will be performed on these data.",0		; user instructions
prompt1		     byte  "First number: ",0                         ; prompt for first user number
prompt2          byte  "Second number: ",0                        ; prompt for second user number
prompt3          byte  "Third number: ",0                         ; prompt for third user number
prompt4          byte  "Would you like to restart the program? Y/N: ",0								; prompt for user to restart Y/N
userRestartY_N   byte  3 DUP(0)                                   ; user string to be entered Y/N
inputY           byte  "Y",0                                      ; for comparison to restart user input
inputN           byte  "N",0                                      ; for comparison to restart user input
operatorSum      byte  " + ",0                                    ; sum operator
operatorDif      byte  " - ",0                                    ; difference operator
operatorEq       byte  " = ",0                                    ; equal operator
operatorDiv      byte  " / ",0                                    ; division operator
numA             dword ?                                          ; user defined number A
numB             dword ?                                          ; user defined number B
numC             dword ?                                          ; user defined number C
aPlusB		     dword ?                                          ; sum of A and B
aMinusB		     dword ?                                          ; difference of A and B
aPlusC           dword ?                                          ; sum of A and C
aMinusC          dword ?                                          ; difference of A and C
bPlusC           dword ?                                          ; sum of B and C
bMinusC          dword ?                                          ; difference of B and C
aPlusBplusC      dword ?                                          ; sum and A, B, and C
bMinusA          dword ?										  ; difference of B and A
cMinusA          dword ?                                          ; difference of C and A
cMinusB          dword ?										  ; difference of C and B
cMinusBminusA    dword ?                                          ; difference of C, B, and A
aDivBquotient    dword ?										  ; quotient of A by B
aDivBrem         dword ?                                          ; remainder of the division of A by B
aDivCquotient    dword ?										  ; quotient of A by C
aDivCrem         dword ?										  ; remainder of the division of A by C
bDivCquotient    dword ?										  ; quotient of B by C
bDivCrem         dword ?										  ; remainder of the division of B by C
remainder        byte  " R",0                                                                        ; hold R for display as 'remainder' in results
closing          byte  "Thank you for coming to the show, goodbye!",0                                ; closing message
extraCr1         byte  "**EC: Program repeats until the user chooses to quit.",0                     ; extra credit identification
extraCr2         byte  "**EC: Program verifies the numbers are in descending order.",0               ; extra credit identification
extraCr3         byte  "**EC: Program handles negative values and performs new calculations",0       ; extra credit identification
extraCr4         byte  "**EC: Program divides user numbers; displays quotients and remainders",0     ; extra credit identification
errorMessage     byte  "ERROR: The numbers are not in descending order!",0                           ; for error display

.code
main PROC

; ------------------------------------------------------
; Introduction which uses simple WriteString calls on null terminated 
;		byte arrays in EDX (precondition for WriteString) which displays: 
;		program title, name of creator of project, as well as identifiers 
;		of extra credit problems. 
;
; ------------------------------------------------------
  
  ; display program title and extra credit identifiers

_introduction:
  MOV  EDX, OFFSET progTitle        ; mov progTitle into EDX register
  CALL WriteString					; preconditions OFFSET in EDX, progTitle NULL terminated byte array; postcondition: displayed in console
  MOV  EDX, OFFSET creator          
  CALL WriteString                  
  CALL CrLf
  CALL CrLf
  MOV  EDX, OFFSET extraCr1         
  CALL WriteString                   
  CALL CrLf
  MOV  EDX, OFFSET extraCr2         
  CALL WriteString
  CALL CrLf
  MOV  EDX, OFFSET extraCr3         
  CALL WriteString
  CALL CrLf
  MOV  EDX, OFFSET extraCr4         
  CALL WriteString
  CALL CrLf
  CALL CrLf

  ; display user instructions

  MOV  EDX, OFFSET userInstruction  ; mov user instructions into EDX as precondition for display
  CALL WriteString                  ; write NULL terminated array containing user instruction 
  CALL CrLf
  CALL CrLf

; -------------------------------------------------------
; Get the data; display prompt for user to enter three signed or unsigned 
;		numbers, move those imputs to proper identifiers for calculations
;       later. Next, verify the inputs are in descending order by using the
;       CMP call and looking at the sign flags; display errorMessage if they
;       are not in descending order - repeat prompts after errorMessage is 
;       displayed.
;
; -------------------------------------------------------

  ; prompt for three unsigned numbers, mov to respective identifiers

_getData:  
  MOV  EDX, OFFSET prompt1          ; mov prompt1 to EDX as precondition for WriteString
  CALL WriteString                  ; display prompt1
  CALL ReadInt                      ; call ReadInt; no preconditions; postcondition: value stored in EAX
  MOV  numA, EAX                    ; mov user input from EAX into numA; repeat this for the rest of segment (until input verification)
  MOV  EDX, OFFSET prompt2         
  CALL WriteString                 
  CALL ReadInt                     
  MOV  numB, EAX                   
  MOV  EDX, OFFSET prompt3         
  CALL WriteString                 
  CALL ReadInt                     
  MOV  numC, EAX                   
  CALL CrLf                         

  ; verify inputs are in descending order

  MOV  EAX, numA                    
  MOV  EBX, numB                    
  CMP  EAX, EBX                     ; perform compare on EAX-EBX values to check SF
  JS   _isNegative                  ; if sign flag is 1 jump to _isNegative code label
  MOV  ECX, numC                    
  CMP  EBX, ECX                     ; perform compare on EBX-ECX values to check SF
  JS   _isNegative                  ; if sign flag is 1 jump to _isNegative code label
_notNegative:						; if sign flag is 0 perform this code block to continue to calculations
  JMP  _continue                    ; jump to continue code label after verified
_isNegative:                        ; if JS (SF = 1) perform this code block to display error to user and retry
  MOV  EDX, OFFSET errorMessage     
  CALL WriteString                  
  CALL CrLf
  CALL CrLf
  JMP  _getData                     ; jump back to _getData code label after displaying errorMessage

; ----------------------------------------------------------
; Calculates the required values for the project. Each step will move the proper 
;		identifier (A,B, or C) from the user inputs into registers for calculation, 
;		so that the identifier memory itself won't be altered. Sums, differences,
;		and quotients with remainders will be calculated, each time placing the
;		result into a unique identifer for results display later.
;
; ----------------------------------------------------------

  ; mov user entered numbers, perform addition, mov to sum identifiers for display

_continue:
  MOV  EAX, numA					; mov numA into EAX so that addition by numB won't change value in numA
  ADD  EAX, numB                    ; add numB to numA's value in EAX, store in EAX
  MOV  aPlusB, EAX                  ; mov result into proper identifier; this repeats throughout this block with numbers numA, numB, and numC
  MOV  EAX, numA                  
  ADD  EAX, numC                  
  MOV  aPlusC, EAX                
  MOV  EAX, numB                  
  ADD  EAX, numC                  
  MOV  bPlusC, EAX            
  MOV  EAX, bPlusC               
  ADD  EAX, numA              
  MOV  aPlusBplusC, EAX         

  ; mov user entered numbers, perform subtraction, mov to difference identifiers for display

  MOV  EAX, numA                    ; mov numA into EAX so that subtraction by numB won't change value of numA
  SUB  EAX, numB                    ; subtract numB from numA's value in EAX, store in EAX
  MOV  aMinusB, EAX                 ; mov result into proper identifier; this repeats throughout this block with numbers numA, numB, and numC
  MOV  EAX, numA                  
  SUB  EAX, numC					
  MOV  aMinusC, EAX             
  MOV  EAX, numB                 
  SUB  EAX, numC               
  MOV  bMinusC, EAX              
  MOV  EAX, numB                   
  SUB  EAX, numA
  MOV  bMinusA, EAX
  MOV  EAX, numC
  SUB  EAX, numA
  MOV  cMinusA, EAX
  MOV  EAX, numC
  SUB  EAX, numB
  MOV  cMinusB, EAX
  MOV  EAX, cMinusB
  SUB  EAX, numA
  MOV  cMinusBminusA, EAX

  ; mov user entered numbers, perform idiv, mov to data identifiers for display later

  MOV  EAX, numA                   ; mov num_a's value to EAX:EDX for instruction
  CDQ                              ; convert 32 bit value into 64 bit
  IDIV numB                        ; idiv (by signed integer) value in EAX by numB; store quotient in EAX; store remainder in EDX
  MOV  aDivBquotient, EAX          ; mov quotient in EAX into proper identifer
  MOV  aDivBrem, EDX               ; mov remaineder in EDX into proper identifier; repeat the process 168-172 two more times for remainder of block
  MOV  EAX, numA
  CDQ  
  IDIV numC
  MOV  aDivCquotient, EAX
  MOV  aDivCrem, EDX
  MOV  EAX, numB
  CDQ
  IDIV numC
  MOV  bDivCquotient, EAX
  MOV  bDivCrem, EDX

; ------------------------------------------------------------
; Display the results; output the results from the calculations section to the console.
;		Code will move both numbers A, B, and C (Into EAX) as well as operators +,-,/,=
;		(Into EDX) as preconditions for WriteInt and WriteString respectively. The output
;		will show the expressions that were calculated in section above.
;
; ------------------------------------------------------------

  ; mov results and operators into proper registers for display

  MOV  EAX, numA                   ; mov numA into EAX as precondition for WriteDec; postcondition: displayed in console
  CALL WriteInt                    ; write signed value from EAX
  MOV  EDX, OFFSET operatorSum     ; mov operator into EDX as precondition for WriteString; postcondition: displayed in console
  CALL WriteString				   ; Write null terminated array from EDX; this repeats for operators and values throughout this block
  MOV  EAX, numB                   
  CALL WriteInt                    
  MOV  EDX, OFFSET operatorEq      
  CALL WriteString					
  MOV  EAX, aPlusB                
  CALL WriteInt                    
  CALL CrLf
  MOV  EAX, numA                   
  CALL WriteInt                     
  MOV  EDX, OFFSET operatorDif      
  CALL WriteString					
  MOV  EAX, numB                    
  CALL WriteInt                     
  MOV  EDX, OFFSET operatorEq       
  CALL WriteString					
  MOV  EAX, aMinusB                 
  CALL WriteInt                     
  CALL CrLf 
  MOV  EAX, numA                    
  CALL WriteInt                     
  MOV  EDX, OFFSET operatorSum      
  CALL WriteString					
  MOV  EAX, numC                   
  CALL WriteInt                     
  MOV  EDX, OFFSET operatorEq       
  CALL WriteString					
  MOV  EAX, aPlusC                  
  CALL WriteInt                     
  CALL CrLf
  MOV  EAX, numA                    
  CALL WriteInt                     
  MOV  EDX, OFFSET operatorDif      
  CALL WriteString					
  MOV  EAX, numC                    
  CALL WriteInt                     
  MOV  EDX, OFFSET operatorEq       
  CALL WriteString					
  MOV  EAX, aMinusC                 
  CALL WriteInt                     
  CALL CrLf
  MOV  EAX, numB                   
  CALL WriteInt                     
  MOV  EDX, OFFSET operatorSum      
  CALL WriteString					
  MOV  EAX, numC                  
  CALL WriteInt                     
  MOV  EDX, OFFSET operatorEq       
  CALL WriteString					
  MOV  EAX, bPlusC                
  CALL WriteInt						
  CALL CrLf
  MOV  EAX, numB                   
  CALL WriteInt						
  MOV  EDX, OFFSET operatorDif      
  CALL WriteString					
  MOV  EAX, numC		            
  CALL WriteInt						
  MOV  EDX, OFFSET operatorEq       
  CALL WriteString					
  MOV  EAX, bMinusC               
  CALL WriteInt						
  CALL CrLf
  MOV  EAX, numA                   
  CALL WriteInt						
  MOV  EDX, OFFSET operatorSum      
  CALL WriteString					
  MOV  EAX, numB                   
  CALL WriteInt						
  MOV  EDX, OFFSET operatorSum      
  CALL WriteString					
  MOV  EAX, numC                   
  CALL WriteInt						
  MOV  EDX, OFFSET operatorEq       
  CALL WriteString					
  MOV  EAX, aPlusBplusC         
  CALL WriteInt						
  CALL CrLf
  MOV  EAX, numB                   
  CALL WriteInt
  MOV  EDX, OFFSET operatorDif
  CALL WriteString
  MOV  EAX, numA
  CALL WriteInt
  MOV  EDX, OFFSET operatorEq
  CALL WriteString
  MOV  EAX, bMinusA
  CALL WriteInt
  CALL CrLf
  MOV  EAX, numC
  CALL WriteInt
  MOV  EDX, OFFSET operatorDif
  CALL WriteString
  MOV  EAX, numA
  CALL WriteInt
  MOV  EDX, OFFSET operatorEq
  CALL WriteString
  MOV  EAX, cMinusA
  CALL WriteInt
  CALL CrLf
  MOV  EAX, numC
  CALL WriteInt
  MOV  EDX, OFFSET operatorDif
  CALL WriteString
  MOV  EAX, numB
  CALL WriteInt
  MOV  EDX, OFFSET operatorEq
  CALL WriteString
  MOV  EAX, cMinusB
  CALL WriteInt
  CALL CrLF
  MOV  EAX, numC
  CALL WriteInt
  MOV  EDX, OFFSET operatorSum
  CALL WriteString
  MOV  EAX, numB
  CALL WriteInt
  MOV  EDX, OFFSET operatorDif
  CALL WriteString 
  MOV  EAX, numA
  CALL WriteInt
  MOV  EDX, OFFSET operatorEq
  CALL WriteString
  MOV  EAX, cMinusBminusA
  CALL WriteInt
  CALL CrLf
  MOV  EAX, numA
  CALL WriteInt
  MOV  EDX, OFFSET operatorDiv
  CALL WriteString
  MOV  EAX, numB
  CALL WriteInt
  MOV  EDX, OFFSET operatorEq
  CALL WriteString
  MOV  EAX, aDivBquotient
  CALL WriteInt
  MOV  EDX, OFFSET remainder
  CALL WriteString
  MOV  EAX, aDivBrem
  CALL WriteInt
  CALL CrLf
  MOV  EAX, numA
  CALL WriteInt
  MOV  EDX, OFFSET operatorDiv
  CALL WriteString
  MOV  EAX, numC
  CALL WriteInt
  MOV  EDX, OFFSET operatorEq
  CALL WriteString
  MOV  EAX, aDivCquotient
  CALL WriteInt
  MOV  EDX, OFFSET remainder
  CALL WriteString
  MOV  EAX, aDivCrem
  CALL WriteInt
  CALL CrLf
  MOV  EAX, numB
  CALL WriteInt
  MOV  EDX, OFFSET operatorDiv
  CALL WriteString
  MOV  EAX, numC
  CALL WriteInt
  MOV  EDX, OFFSET operatorEq
  CALL WriteString
  MOV  EAX, bDivCquotient
  CALL WriteInt
  MOV  EDX, OFFSET remainder
  CALL WriteString
  MOV  EAX, bDivCrem
  CALL WriteInt
  CALL CrLf
  CALL CrLf

; ---------------------------------------------------
; Check if user wants to restart program. Prompt user to restart or not by inputing Y or N.
;		Precondition for ReadString: userRestartY_N OFFSET moved to EDX, max length of input
;		stored in ECX. Call ReadString and compare the user input to inputY and inputN with CMPSB; 
;		if user input is Y - jump to _restartProg (and subsequently, _introduction), and if N 
;		jump to the next section, _sayGoodbye. 
;
; ---------------------------------------------------

  ; display prompt to restart or not

  MOV  EDX, OFFSET prompt4
  CALL WriteString
  
  ; read string preconditions: (1) max length in ECX, (2) EDX holds pointer to string

  MOV  EDX, OFFSET userRestartY_N   ; pointer to identifier moved to EDX
  MOV  ECX, 2                       ; memory size in ECX, room for NULL terminator
  CALL ReadString

  ; check if input Y or N and jump to code label accordingly

  MOV  ESI, OFFSET inputY           ; precondition for CMPSB; strings to be compared pointers in ESI and EDI
  MOV  EDI, OFFSET userRestartY_N   ; other precondition; EDI will hold pointer to user input
  REPE CMPSB                        ; compare values in strings
  JCXZ _restartProg                 ; ECX=0 if all values match, jump to restart program code label
  MOV  ESI, OFFSET inputN           ; precondition for CMPSB; strings have pointers in ESI and EDI 
  REPE CMPSB                        
  CALL CrLf
  JCXZ _sayGoodbye                  ; ECX=0 if all values match, jump to say_goodbye code label
_restartProg:
  CALL CrLf
  JMP  _introduction                ; restart the code at the introduction label

; ---------------------------------------------------
; Say goodbye. Move closing OFFSET into EDX; call WriteString to 
;		tell the user goodbye. Exit to operating system.
;
; ---------------------------------------------------

_sayGoodbye:
  MOV  EDX, OFFSET closing           
  CALL WriteString                  
  CALL CrLf
 
	Invoke ExitProcess,0	        ; exit to OS
main ENDP

END main