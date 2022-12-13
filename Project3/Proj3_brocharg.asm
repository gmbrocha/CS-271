TITLE Count_and_Accumulate (Proj3_brocharg.asm)

; Author: Glen Brochard
; Last Modified: 10/21/2022
; OSU email address: brocharg@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number: 3      Due Date: 10/30/2022
; Description: Program that displays title and programmer name; prompts user for his/her name; provides
; instructions for input (valid ranges) and instructions to terminate input and display stats on valid
; entries; loops user input prompt until user enters a non-negative number; validates input as negative
; and within bounds of ranges (as constants lower_one, upper_one, lower_two, upper_two); calculates count,
; sum, minimum, maximum, rounded average (>.51 gets rounded 'up', <= .50 gets rounded 'down'), as well
; as the actual decimal average (to one-hundreth place) without utilizing the FPU; displays all of the 
; these stats; displays special message if no valid numbers were entered, then displays a closing message 
; to the user including his/her name

INCLUDE Irvine32.inc

LOWER_ONE = -200
UPPER_ONE = -100
LOWER_TWO = -50
UPPER_TWO = -1

.data

programTitle       BYTE  "**********Counting, Accumulating, and Stats! by",0                        ; program title for display
programmerName     BYTE  " Glen M. Brochard (nezcoupe)**********",0
userName           BYTE  33 DUP(0)                           ; storage for user name input
userNamePrompt     BYTE  "Please give me your handle: ",0    ; get userName
userGreet          BYTE  "It's a pleasure, ",0
instructions       BYTE  "Please enter any numbers between[-200, -100] or [-50, -1].",0
instructions2      BYTE  "To finish the program and see input stats, please enter",0
instructions3      BYTE  "a non-negative number.",0          ; separated this from instructions2 just for aesthetic
fullstop           BYTE  ".",0
exclaim            BYTE  "!",0
userNumPrompt      BYTE  ". Enter a number: ",0
userNum            DWORD ?          ; for storing user input
minValid           DWORD ?          ; will hold minimum (farthest from zero)
maxValid           DWORD LOWER_ONE  ; set for initial comparisons, without the program will set maxValid to 0 upon termination
countValid         DWORD ?          ; count of valid entries
sumValid		   DWORD ?          ; sum of valid entries
averageQuotient    DWORD ?          ; sumValid/countValid quotient
averageRemain      DWORD ?          ; sumValid/countValid remainder
averageQuotDec     DWORD ?          ; for decremented average, so that averageQuotient will not be changed (for display in extra credit)
remMULhund         DWORD ?          ; holds (remainder of (sumValid/countValid) * 100)
remHundDIVcount    DWORD ?          ; remMULhund / countValid; is the decimal portion of the average for EC 2
remHundDIVcountRem DWORD ?          ; will hold the remainder for the decimal portion above to check for .01 rounding for EC 2
decimalRemTen      DWORD ?          ; holds remHundDIVcountRem * 10 for EC 2
decimalRemTenDIV   DWORD ?          ; holds decimalRemTen / countValid to check for rounding rule for EC 2
invalidMessage     BYTE  "This number is not within the ranges specified.",0           ; error message for invalid entries
noValidMessage     BYTE  "No valid numbers were entered.",0                            ; display special message for no valid entries
countMessage       BYTE  "The count of valid numbers entered is: ",0
sumMessage         BYTE  "The sum of valid numbers entered is: ",0
maxMessage         BYTE  "The maximum valid number entered is: ",0
minMessage         BYTE  "The minimum valid number entered is: ",0
averageMessage     BYTE  "The average valid number entered is: ",0
decAverageMessage  BYTE  "The decimal average to the nearest hundreth is: ",0          ; display message for extra credit 2
goodbye            BYTE  "So long, and thanks for all the fish, ",0
lineCount          DWORD 0          ; will hold extra credit 1 line count
extraCredit1       BYTE  "**EC1: Numbers the lines during user input, increments line number only for valid entries.",0
extraCredit2       BYTE  "**EC2: Calculates and displays average as decimal point number rounded to nearest .01",0

.code
main PROC

; ----------------------------------------------------------------
; display title and programmer name; prompt user to enter userName
; and then display a greeting with the user's name.
;
; ----------------------------------------------------------------
  
  ; mov programTitle and Name offsets into EDX and display them with WriteSting
  MOV  EDX, OFFSET programTitle
  CALL WriteString
  MOV  EDX, OFFSET programmerName
  CALL WriteString
  CALL CrLf
  CALL CrLf
  MOV  EDX, OFFSET extraCredit1
  CALL WriteString
  CALL CrLf
  MOV  EDX, OFFSET extraCredit2
  CALL WriteString
  CALL CrLf
  CALL CrLf

  ; ask user name via prompt, get input and store
  MOV  EDX, OFFSET userNamePrompt
  CALL WriteString
  MOV  EDX, OFFSET userName
  MOV  ECX, 32
  CALL ReadString	
  CALL CrLf
                             
  ; greet the user including userName
  MOV  EDX, OFFSET userGreet
  CALL WriteString
  MOV  EDX, OFFSET userName
  CALL WriteString
  MOV  EDX, OFFSET fullstop
  CALL WriteString
  CALL CrLf
  CALL CrLf

; ---------------------------------------------------------------
; display instructions for program use; tell user what range of 
; input values will be considered valid and how to terminate the
; entry of more values and see the calculations that the program
; provides
;
; Section could possibly be rolled into the logical section above
;
; ---------------------------------------------------------------

  ; mov instruction offsets in EDX and display them with WriteString
  MOV  EDX, OFFSET instructions
  CALL WriteString
  CALL CrLf
  MOV  EDX, OFFSET instructions2
  CALL WriteString
  CALL CrLf
  MOV  EDX, OFFSET instructions3
  CALL WriteString
  CALL CrLf
  CALL CrLf

; -------------------------------------------------------------------
; Main user entry loop to get input and validate.
; 
; 1) prompt user to enter number; repeat until user enters non-negative 
; number with first validation 2) then again validate in this order: 
; is input non-negative?, is input in lower set of OR condition 
; {-200,...,-100}?, is input in upper set of OR condition {-50,...,-1}? 
; 3) Displays invalid input message and restarts loops
; 4) counts the validated inputs 5) increments sum of validated inputs
; 6) finds min and max of valid inputs and sets values of minValid and 
; maxValid accordingly
;
; The min and max value variable setting, as well as sum increment,
; could be placed in logical section below this one (for calculations)
; - however it works well organized like this, in code and in my head
; 
; -------------------------------------------------------------------

  ; begin loop with prompt "Enter a number: " and continue loop until user terminates
_topOfLoop:
  MOV  EAX, lineCount
  CALL WriteDec
  MOV  EDX, OFFSET userNumPrompt
  CALL WriteString
  CALL ReadInt
  MOV  userNum, EAX

  ; check for non-negative input and terminate loop (skip to proper _displayCalcs) if so
_validateNonNegative:
  MOV  EAX, userNum
  CMP  EAX, 0					     ; if userNum is negative, SF will set to 1
  JNS  _displayCalcs			     ; if SF = 0, jump to _displayCalcs code label
  
  ; if input validated as negative, validate for range [-200, -100]
_validateOne:                
  MOV  EAX, userNum
  CMP  EAX, LOWER_ONE			     ; compare userNum in EAX to constant -200
  JL   _invalidate				     ; if userNum is less than -200, jmp to invalidate code label
  CMP  EAX, UPPER_ONE			     ; compare userNum in EAX to constant -100
  JG   _validateTwo				     ; if userNum is greater than -100, jmp to the second validation - if this fails then the input is valid - jmp to countValid label
  JMP  _countValid

  ; if input is not within first range, validate for [-50, -1]
_validateTwo:
  CMP  EAX, LOWER_TWO			     ; compare userNum in EAX to constant -50
  JL   _invalidate				     ; if userNum is less than, invalidate
  CMP  EAX, UPPER_TWO			     ; compare userNum in EAX to constant -1
  JG   _invalidate				     ; if userNum is greater than, invalidate
  JMP  _countValid				     ; validateOne or validateTwo have been passed, jmp to countValid

  ; count, accumulate, and set min/max values for the valid numbers
_countValid:
  INC  countValid                    ; increment the valid count by 1
  INC  lineCount
  MOV  EAX, sumValid
  ADD  EAX, userNum                  ; add the current valid userNum to the current sumValid value in EAX
  MOV  sumValid, EAX                 ; mov new sum into indentifier
  MOV  EAX, userNum
  CMP  EAX, minValid                 ; compare userNum to the current minimum
  JG   _checkMax                     ; if userNum >= minValid skip over minValid setting to _checkMax
  MOV  minValid, EAX                 ; if userNum < minValid, userNum becomes new minValid and continue to _checkMax

  ; check in userNum is new maximum
_checkMax:
  CMP  EAX, maxValid                 ; compare userNum to the current maximum
  JNG  _topOfLoop                    ; if userNum <= maxValid, skip to _topOfLoop
  MOV  maxValid, EAX                 ; if userNum > maxValid, set maxValid and then jmp to _topOfLoop
  JMP  _topOfLoop
                                   
  ; notify user for negative numbers not in range; restart entry loop
_invalidate:
  MOV  EDX, OFFSET invalidMessage
  CALL WriteString
  CALL CrLf
  JMP  _topOfLoop                    ; restart loop after invalid input message


; ------------------------------------------------------------------
; 1) display count, sum, minimum and maximum of valid inputs 2) includes 
; calculations to get the average of the valid inputs as well as the 
; instructions to correctly round that average up if remainder >.5 
; and do-nothing if remainder <=.5 3) displays the correct integer 
; average 3) calculates the correct decimal average 
; by using the quotient of 
; (averageRem*100)/countValid as a way to find the value of the decimal to
; hundreths place 4) round this to nearest .01 by comparing the remainder*10
; /countValid of that process (which would yield the thousandths value) to 
; 5 (if greater or equal, increment hundreths place) 4) display the correct 
; rounded or non-rounded decimal by writing the non-rounded averageQuotient, 
; a "." stop, and the 2 digit 'decimal' portion of the overall value
;
; ------------------------------------------------------------------

_displayCalcs:
  ; count of validated numbers (if no valid entered skip to parting message)
  MOV  EAX, countValid
  CMP  EAX, 0
  JE   _partingZero                  ; if countValid = 0 then jump to special case parting message
  CALL CrLf
  MOV  EDX, OFFSET countMessage 
  CALL WriteString                   ; display valid count message and unsigned integer value (dec chosen because count will only be positive, looks cleaner)
  CALL WriteDec
  CALL CrLf
              
  ; sum of valid numbers
  MOV  EDX, OFFSET sumMessage
  CALL WriteString                   
  MOV  EAX, sumValid
  CALL WriteInt                      ; display signed integer sum to handle negative inputs
  CALL CrLf
								   
  ; minimum (farthest from 0) valid entered
  MOV  EDX, OFFSET minMessage
  CALL WriteString                   
  MOV  EAX, minValid
  CALL WriteInt                      ; display signed integer minimum valid entry
  CALL CrLf

  ; maximum (closet to 0) valid user value entered
  MOV  EDX, OFFSET maxMessage
  CALL WriteString                  
  MOV  EAX, maxValid
  CALL WriteInt                      ; display signed integer maximum valid entry
  CALL CrLf

  ; average (sumValid/countValid); quotient and remainder will be used in roundAverage as well as decimalAverage
  MOV  EAX, sumValid                
  CDQ                                ; sign extend value in EAX to EDX:EAX
  IDIV countValid                    
  MOV  averageQuotient, EAX          ; mov quotient from EAX into quotient identifier
  MOV  averageRemain, EDX            ; mov remainder from EDX into remainder identifer
							
  ; 20.01 to 20.5 rounds down, 20.51-20.99 rounds up; i.e. > .5 decimal remainder gets rounded up, <= .5 round down
_checkRoundAverage:
  MOV  EAX, averageRemain            ; MUL remainder by 100
  MOV  EBX, 100
  IMUL EBX							
  MOV  remMULhund, EAX
  NEG  remMULhund                    ; change negative value to positive value because we want to be able to call WriteDec on line 286 to avoid the sign and
                                     ; the 2's complement of unsigned and signed positive values is the same - so we need this for execution
  MOV  EAX, remMULhund               
  CDQ                                ; sign extend to EDX
  MOV  EBX, countValid               ; move countValid to EBX as divisor
  IDIV EBX                           ; divide remMULhund, which is (averageRemainder * 100), by valid count
  MOV  remHundDIVcount, EAX          ; store EAX into identifier which will be the post-'decimal' display for the decimal average
  MOV  remHundDIVcountRem, EDX       ; store EDX into identifier which will be used in the rounding rule for the decimal portion of the decimal average
  MOV  EAX, remHundDIVcount          
  CMP  EAX, 50                     
  JLE  _displayNonRoundedAverage     ; if the (remainder * 100) / countValid is less or equal to 50, skip to display non rounded average                                
  MOV  EAX, averageQuotient          ; if > 50, continue execution here to decrement the quotient 'up'
  DEC  EAX                           
  MOV  averageQuotDec, EAX           ; store decremented quotient into separate identifier so that _displayDecimalAverage can still utilize averageQuotient as-is
                                     
  ; display rounded average
  MOV  EDX, OFFSET averageMessage
  CALL WriteString
  MOV  EAX, averageQuotDec           ; displays proper (rounded) integer average
  CALL WriteInt
  CALL CrLf
  JMP  _checkDecimalAverageRound

  ; display the non-decremented quotient for jcond skip above
_displayNonRoundedAverage:
  MOV  EDX, OFFSET averageMessage
  CALL WriteString
  MOV  EAX, averageQuotient          ; displays proper (non-rounded) integer average
  CALL WriteInt
  CALL CrLf
  CALL CrLf          
  
  ; check remainder of the decimal portion found above for rounding to nearest .01; 
_checkDecimalAverageRound:
  MOV  EAX, remHundDIVcountRem
  MOV  EBX, 10     
  MUL  EBX                           ; mul remainder by 10
  MOV  decimalRemTen, EAX    
  MOV  EAX, decimalRemTen
  CDQ
  MOV  EBX, countValid
  DIV  EBX                           ; div by 3 again for find what is the thousandth's place for the original average
  MOV  decimalRemTenDIV, EAX
  MOV  EAX, decimalRemTenDIV
  CMP  EAX, 5                        ; check if decimalRemTenDIV is less than 5; if so jcond jmp to display non-rounded version of decimal
  JL   _displayNonRoundedDecimal

  ; display extra credit rounded decimal average
_displayRoundedDecimal:
  INC  remHundDIVcount               ; if jcond fails, continue here to increment the decimal up one-hundreth
  MOV  EDX, OFFSET decAverageMessage ; mov decimal-average message offset into EDX
  CALL WriteString                   
  MOV  EAX, averageQuotient          ; display non-rounded quotient
  CALL WriteInt
  MOV  EDX, OFFSET fullstop          ; display 'decimal'
  CALL WriteString
  MOV  EAX, remHundDIVcount          ; display rounded decimal (to hundreths)
  CALL WriteDec                      ; write dec here to avoid sign, why NEG was used above to make the signed look same as unsigned
  CALL CrLf
  CALL CrLf
  CALL CrLf
  JMP _partingMessage

  ; display extra credit non-rounded decimal average
_displayNonRoundedDecimal:
  MOV  EDX, OFFSET decAverageMessage ; mov decimal-average message offset into EDX
  CALL WriteString                   
  MOV  EAX, averageQuotient          ; display non-rounded quotient
  CALL WriteInt
  MOV  EDX, OFFSET fullstop          ; display 'decimal'
  CALL WriteString
  MOV  EAX, remHundDIVcount          
  CALL WriteDec                      ; write dec here to avoid sign, why NEG was used above to make the signed look same as unsigned
  CALL CrLf
  CALL CrLf
  CALL CrLf
  JMP  _partingMessage               ; skip _partingZero (which is the special case) straight to _partingMessage
       
       
; -----------------------------------------------------------
; parting message with user's name; includes code for special 
; message display if no valid numbers were entered (countValid
; = 0)
;
; -----------------------------------------------------------

  ; special message for no valid entries
_partingZero:
  CALL CrLf
  MOV  EDX, OFFSET noValidMessage
  CALL WriteString
  CALL CrLf
  CALL CrLf

  ; parting message with userName
_partingMessage:
  MOV  EDX, OFFSET goodbye
  CALL WriteString
  MOV  EDX, OFFSET userName
  CALL WriteString
  MOV  EDX, OFFSET exclaim
  CALL WriteString
  CALL CrLf
                                    
	Invoke ExitProcess,0	        ; exit to operating system
main ENDP

END main