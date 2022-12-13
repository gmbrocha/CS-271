TITLE Project_6  (Proj6_brocharg.asm)

; Author: 
; Last Modified:
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section: CS 271  CS271 Section 400
; Project Number: 6      Due Date: 12/3/22
; Description: Program utilizes 2 macros and 4 procedures (1 of which is main PROC and will call the other 3 as well as the macros) to 
;              1st) Display title and creator name, 2nd) Get as input (readVal; utilizing mGetString) a string of digits representing 
;              a signed integer from the user, validate those digits against the valid array (0-9, +, -), and converts the input string 
;              to a 32 bit signed integer in hexidecimal format; for the program assignment the user will be prompted 10 times (excluding 
;              error prompts) and the resultin inputs will be stored in a 10 element string, 3rd) The string of 32-bit signed integers 
;              will be converted back to strings of ASCII digits and displayed to the user (writeVal; utilizing mDisplayString), as well 
;              as their sum and truncated average. 4th) Displays a farewell message to the user.

INCLUDE Irvine32.inc

; --------------------------------------------------------------
; mGetString utilized by procedure getVal to acquire a string
; as input from the user. Preconditions: prompt is input OFF
; SET, inputTo is input/output parameter of a BYTE array OFFSET,
; byteCount is an input/output OFFSET of a WORD type variable
; Postconditions: prompt displayed in console, input string
; from user stored at inputTo, bytes read stored at byteCount
;
; --------------------------------------------------------------

mGetString MACRO prompt, inputTo, byteCount

  PUSHAD
  MOV    ESI, prompt
  MOV    ECX, 30

_disInputMsg:  
  LODSB 
  CALL   WriteChar
  LOOP   _disInputMsg
  MOV    EDX, inputTo
  MOV    ECX, 29
  CALL   ReadString
  MOV    byteCount, EAX
  POPAD

ENDM

; --------------------------------------------------------------
; mDisplayString utilized by writeVal procedure to display chars
; of strings to the console. Preconditions: displayStr is input
; OFFSET of string, length is input int for counter for LODSB. 
; Postconditions: string displayed to console.
;
; --------------------------------------------------------------

mDisplayString MACRO displayStr, length

  PUSHAD
  MOV    ECX, length
  MOV    ESI, displayStr
  LODSB  
  CMP    AL, 0FFh
  JNE    _skipNeg
  MOV    AL, 2Dh
  CALL   WriteChar

_skipNeg:
  LODSB
  CALL   WriteChar
  LOOP   _skipNeg
  POPAD

ENDM

.data

progHead   BYTE   "      Assignment 6: Implementing Primitive I/O Procedures",0Ah,
                  "                 Created by: Glen M. Brochard",0Ah,0Ah,0
userPrompt BYTE   "Please provide 10 signed decimal integers.",0Ah,
                  "Each number needs to be small enough to fit inside a 32 bit register.",0Ah,
                  "After you have finished inputing numbers I will display all your inputs,",0Ah,
                  "their sum, and their truncated average value.",0Ah,0Ah,0
inputMsg   BYTE   "Please enter a signed number: ",0
inputStr   BYTE   30 DUP(0)                                                          ; will hold user input string
errorMsg   BYTE   "ERROR: not signed or the input is too large to fit in a 32-bit register.",0Ah,0
numBytes   DWORD  ?                                                                  ; will hold bytes read value from readString
numeric    DWORD  ?                                                                  ; will hold 32-bit signed integer; used by readVal
numericArr BYTE   111 DUP(0)                                                         ; will hold 10 numeric^ values (when converted) to be displayed by writeVal
validArray BYTE   2bh, 2dh, 30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h,0       ; all valid digits for input to be tested against
enteredMsg BYTE   0Ah,"You entered the following numbers: ",0Ah,0
sumMsg     BYTE   0Ah,"The sum of these numbers is: ",0
sum        BYTE   11 DUP(0)
avgMsg     BYTE   0Ah,"The truncated average of these numbers is: ",0
avg        BYTE   11 DUP(0)
farewell   BYTE   0Ah,"So long and thanks for all the fish!",0Ah,0

.code

; --------------------------------------------------------------------
; main procedure that will call relevant sub procedures introDisplay
; for title and creator display; will loop procedure readVal ten times
; to get 10 validated strings of numbers, and will provide those valid
; strings (in array numericArr - array of 32 bit signed hex values) to
; procedure writeVal to display them as ASCII digits as output
;
; --------------------------------------------------------------------

main PROC

  PUSH OFFSET progHead
  PUSH OFFSET userPrompt
  CALL introDisplay

  MOV  ECX, 10
  XOR  EDX, EDX                                  ; will be a running sum
  MOV  EDI, OFFSET numericArr                    ; will hold 32-bit signed integers 
  MOV  ESI, OFFSET numeric                       ; reference to each 32-bit value placed in ESI to be added to running sum

_topGetNumbers:
  PUSH OFFSET errorMsg     
  PUSH OFFSET validArray                         
  PUSH OFFSET numeric
  PUSH OFFSET inputMsg
  PUSH OFFSET inputStr
  PUSH OFFSET numBytes
  CALL readVal
  MOV  EBX, [ESI]                                ; move value
  CMP  EBX, 0                                    ; check sign flag, if flag is set continue to negate value in EBX
  JNS  _addPos
  NEG  EBX
  SUB  EDX, EBX                                  ; subtract positive value from EDX for new running sum
  NEG  EBX                                       ; restore EBX negative value
  JMP  _continue

_addPos:
  ADD  EDX, EBX                                  ; increment sum

_continue:
  MOV   [EDI], EBX                               ; store EBX into numericArr
  ADD   EDI, 11                                  ; increment destination
  LOOP  _topGetNumbers

  MOV   ESI, OFFSET enteredMsg                   ; place OFFSET of writeVals into ESI for use in string primitive below
  MOV   ECX, 37                                  ; counter for writeVals message

_printValsMsg:
  LODSB
  CALL  writeChar
  LOOP  _printValsMsg

  MOV   ECX, 10                                   ; counter for display of strings
  MOV   EAX, OFFSET numericArr                    ; place in EAX as push to procedure writeVal below for easy increment during loop
_topDisplayLoop:
  PUSH  EAX                                       ; push OFFSET for numericArr in EAX to stack as pass to writeVal
  CALL  writeVal                                   
  CMP   ECX, 1                                    ; if ECX = 1, skip comma display below
  JE    _displaySum
  ADD   EAX, 11
  PUSH  EAX
  MOV   AL, 2Ch
  CALL  WriteChar                                 ; comma display
  POP   EAX
  LOOP  _topDisplayLoop
  CALL  CrLf
  CALL  CrLf

_displaySum:
  CALL  CrLf
  MOV   ECX, LENGTHOF sumMsg
  MOV   ESI, OFFSET sumMsg

_sumLoop:
  LODSB
  CALL  WriteChar
  LOOP  _sumLoop
  MOV   DWORD PTR [sum], EDX                      ; **this is done as an array because the converted ASCII digits could be up to 11 length,
                                                  ; needed extra memory allocated past a DWORD to handle those
  PUSH  OFFSET sum
  CALL  writeVal
  CALL  CrLf

_displayAvg:
  MOV   ECX, LENGTHOF avgMsg
  MOV   ESI, OFFSET avgMsg

_avgLoop:
  LODSB
  CALL  WriteChar
  LOOP  _avgLoop

  MOV   EAX, EDX
  CDQ
  MOV   EBX, 10                                   ; divide sum in EAX (formerly EDX) by 10 to find average, only move value in EAX to truncate
  DIV   EBX
  MOV   DWORD PTR [avg], EAX                      
  PUSH  OFFSET avg
  CALL  writeVal
  CALL  CrLf

  PUSH  OFFSET farewell
  CALL  goodbyeDisplay
                                                  
  Invoke ExitProcess,0	 ; exit to operating system

main ENDP

; ------------------------------------------------------------
; Simple display procedure to write introductions strings to 
; output. Preconditions: string OFFSET of title passedas first 
; parameter on stack, string OFFSET of instructions passed as 
; second parameter on stack. Postconditions: Title string and 
; instructions string displayed in output.
;
; ------------------------------------------------------------

introDisplay PROC

  ; call WriteString on passed strings to display to output
  PUSH  EBP
  MOV   EBP, ESP
  PUSH  EDX
  MOV   EDX, [EBP + 12]                          ; OFFSET of string at location in stack frame placed into EDX for writing
  CALL  WriteString
  MOV   EDX, [EBP + 8]
  CALL  WriteString
  POP   EDX
  POP   EBP
  RET   8

introDisplay ENDP

; -------------------------------------------------------------------------------------
; readVal procedure initially utilizes mGetString macro to acquire an input string from 
; the user; this input is validated against an array (validArray) in attempt to non-set 
; inputs; once validated, the string is converted to a signed 32-bit integer; finally 
; the string is converted to 2's complement hex value if the input string contained an 
; initial negative value. Preconditions: First parameter OFFSET of string (error msg),
; 'valid array' OFFSET of accepted chars passed as second parameter, SDWORD OFFSET to 
; hold 32-bit signed integer as third parameter, string OFFSET (input msg) as fourth
; parameter, user input string OFFSET as fifth parameter, DWORD OFFSET to hold bytes 
; read; Postconditions: 3rd parameter memory at SDWORD OFFSET contains a 32 bit signed
; -integer representation of user input string; last parameter WORD contains an integer
; representing number of bytes read by the macro mGetString.
;
; **Have not figured out the condition for leading zeroes, IF the trailing digits are
; valid and less than the max for 32-bit signed int - for now error message if greater
; than 11 bytes read and checks min/max 32-bit sigint values at bottom of conversion
; section - i THINK leading zero handling is the last case**

; -------------------------------------------------------------------------------------

readVal PROC
 
  PUSH  EBP
  MOV   EBP, ESP
  PUSHAD

_topGetString:
  mGetString [EBP + 16], [EBP + 12], [EBP + 8]   ; inputMsg, inputStr, numBytes OFFSETs 

; begin data validation here

  ; if str empty - error; if str length is 1, con only be digits 0 - 9
  MOV   ESI, [EBP + 12]                          ; mov inputStr into ESI
  MOV   EDI, [EBP + 24]                          ; mov valid array into EDI
  MOV   ECX, [EBP + 8]                           ; mov numBytes read value into ECX
  CMP   ECX, 11
  JG    _errorFirst                              ; if more than 11 bytes read jump to error
  MOV   EBX, EDI                                 ; backup EDI for use later
  CMP   ECX, 0
  JE    _errorFirst                              ; if zero bytes read, display error
  CMP   ECX, 1                                   ; if ECX = 1, the first element cannot contain the entire valid array
  JNE   _checkFirstIndex                           
  ADD   EDI, 02h                                 ; point to 0 in valid array, past the + and - signs
  LODSB                                          ; load ESI beginning into AL
  MOV   ECX, 11
  REPNZ SCASB
  CMP   ECX, 0          
  JE    _errorFirst                              ; if AL not found in EDI, display error
  JMP   _validated                               

  ; if str length is >= 2, first digit can be (+,-,0-9) for 1st elment and 0-9 for > 2nd element
_checkFirstIndex:
  LODSB                                          ; load first element in inputStr (ESI) into AL
  MOV   ECX, 12                                  ; can be any of the valid array elements             
  REPNZ SCASB
  CMP   ECX, 0                  
  JE    _errorFirst
  MOV   EDI, EBX                                 ; reset valid array for EDI to point to first element
  ADD   EDI, 02h                                 ; point EDI to 0 in valid array past + and - signs
  MOV   EBX, EDI                                 ; store incremented EDI in EBX
  MOV   ECX, [EBP + 8]                           ; mov bytes read value into ECX; if 2, if len is 2 - validated
  DEC   ECX                                      ; decrement ECX so loop counter is correct for loop below
  
  ; iterate input string and compare against valid array beginning at the 3rd element
_topLoopValid:
  MOV   EDI, EBX                                 ; reset EDI to point to 3rd element of possible valid elements array
  XOR   EAX, EAX
  LODSB                                          
  PUSH  ECX                                      ; store ECX on the stack
  MOV   ECX, 11                                  ; move 10 to ECX counter (12 elements minus the first 2 sign elements)

_topInnerValid:
  REPNZ SCASB
  CMP   ECX, 0
  JE    _errorFromLoop                           ; if AL not found in numbers 0-9 display error

_exitInner:
  POP   ECX                                      ; restore ECX to check LOOP condition
  LOOP  _topLoopValid
  JMP   _validated                               ; unconditionally jump if loop completes without finding error

_errorFromLoop:                                  ; this error has an additional pop to re-align after loop above exits
  POP   ECX
  MOV   EDX, [EBP + 28]
  CALL  WriteString
  JMP   _topGetString

_errorFirst:                                     ; error without pop to maintain alignment if error from first 2 validations
  MOV   EDX, [EBP + 28]
  CALL  WriteString
  JMP   _topGetString

  ; data is now VALIDATED

; get numeric value from inputStr

_validated:
  MOV   ESI, [EBP + 12]                          ; reset ESI - move input array into ESI
  MOV   EDX, [EBP + 20]                          ; move numeric variable OFFSET into EDX
  XOR   EAX, EAX
  LODSB
  MOV   EBX, [EBP + 8]                           ; check if string is only 1 number
  CMP   EBX, 1
  JNE   _checkPosNeg                             ; if not 1 length, jump to check for pos or neg
  MOV   [EBP - BYTE PTR 1], 0
  SUB   EAX, 30h
  MOV   [EDX], EAX                               ; move converted single number into value at EDX
  JMP   _endConvert

_checkPosNeg:
  CMP   EAX, 2dh                                 ; compare value in AL to -
  JE    _multiplierLoopSetupNeg
  CMP   EAX, 2bh                                 ; compare value in AL to +
  JE    _multiplierLoopSetupPos                     

; if not single number string, and not first element - or +, begin conversion setup here

_multiplierLoopSetup:
  MOV   [EBP - BYTE PTR 1], 0
  MOV   ESI, [EBP + 12]                          ; reset ESI
  DEC   EBX                                      ; dec multiplier by 1 for initial value
  MOV   ECX, EBX                                 ; move counter into ECX
  MOV   EDI, ECX                                 ; backup ECX into EDI (OUT OF REGISTERS)
  MOV   EAX, 1                                   ; begin multiplier value in EAX at 1
  JMP   _multiplierLoop

; if not single number string, and first element is -, begin conversion here

_multiplierLoopSetupNeg:
  MOV   [EBP - BYTE PTR 1], 1                    ; setup boolean local variable for use later (1 = negative)
  MOV   ESI, [EBP + 12]                          ; reset ESI
  INC   ESI                                      ; refer to 2nd element
  SUB   EBX, 2                                   ; decrement by 2 to see if only 1 number besides the sign
  CMP   EBX, 0
  JNE   _continueSetup
  XOR   EAX, EAX                                 ; if bytes read was 2, this block until JMP _endConvert converts AL to numeric and stores
  LODSB
  SUB   EAX, 30h
  MOV   [EDX], EAX
  JMP   _endConvert

_multiplierLoopSetupPos:
  MOV   [EBP - BYTE PTR 1], 0                    ; same as LoopSetupNeg except for this line which sets the local variable to 0, will combine both later
  MOV   ESI, [EBP + 12]                          
  INC   ESI                                      
  SUB   EBX, 2
  CMP   EBX, 0
  JNE   _continueSetup
  XOR   EAX, EAX
  LODSB
  SUB   EAX, 30h
  MOV   [EDX], EAX
  JMP   _endConvert

_continueSetup:
  MOV   ECX, EBX                                 ; mov bytes read into ECX as counter
  MOV   EDI, ECX
  MOV   EAX, 1  

_multiplierLoop:
  MOV   EBX, 10                                  ; mul by EAX by 10 ECX (EBX - 1 ABOVE) times
  MUL   EBX
  LOOP  _multiplierLoop
  MOV   EBX, EAX                                 ; move initial multiplier into EBX
  MOV   ECX, EDI                                 ; decremented value of EBX in EDI set back to ECX counter
  INC   ECX
  XOR   EAX, EAX                                 ; zero EAX for 32 bit ZERO to move into [EDX] (reset)
  MOV   EDX, [EBP + 20]                          ; mov numeric variable OFFSET to EDX
  MOV   [EDX], EAX                               ; mov zero into [EDX]

_topOfConvert:
  XOR   EAX, EAX                                 ; zero EAX
  LODSB
  SUB   AL, 30h                                  ; AL holds numeric representation of ASCII hex
  MUL   EBX                                      ; multiply AL by EBX multiplier
  MOV   EDX, [EBP + 20]                          ; set EDX to numeric variable
  PUSH  EDX
  ADD   [EDX], EAX                               ; add value to value pointed to by [EDX]
  MOV   EAX, EBX                                 ; temp move multiplier to EAX, divide by 10 to get next multiplier
  CDQ
  MOV   EBX, 10 
  DIV   EBX
  POP   EDX
  MOV   EBX, EAX                                 ; move new multiplier into EBX
  LOOP  _topOfConvert

_endConvert:
  CMP   [EBP - BYTE PTR 1], 1                    ; if local variable is set to 1, fall through Jcond to convert to 2's comp
  JNE   _exitCheckMax

  ; code here to get signed 2s-complement
  MOV   ECX, 4                                   ; max bytes for 32-bit signed int
  MOV   EDI, EDX                                 ; mov signed int into both EDI and ESI for usage with LODSB and STOSB
  MOV   ESI, EDX

_top2sComp:
  XOR   EAX, EAX                                 ; clear EAX and EBX in case
  XOR   EBX, EBX
  LODSB
  MOV   EBX, 0FFh                                ; will subtract the hex values at each byte from this
  SUB   BL, AL
  MOV   AL, BL
  STOSB
  LOOP  _top2sComp
  MOV   EAX, [EDX]
  INC   EAX                                      ; inc to get final 2's comp value
  MOV   [EDX], EAX
  MOV   EAX, 80000000h                           ; check sign flag for min 32-bit sigint comp with [EDX]
  JNS   _errorFirst  
  JMP   _exit

  ; check is OF flag set for cmp max 32-bit sigint, [edx] FINAL VALIDATION - would've liked this closer to regular validation, but only makes sense here
_exitCheckMax:
  MOV   EAX, 7FFFFFFFh
  CMP   EAX, [EDX]
  JO    _errorFirst

  ; exit either regular positive signed int or 2s comp signed neg int
_exit:
  POPAD
  POP   EBP
  RET   24

readVal ENDP

; -------------------------------------------------------------------------------------
; writeVal procedure accepts as only parameter (and precondition) the OFFSET of a str 
; or string array of a 32-bit signed integer. The string will then be converted from 
; signed-int hex into ASCII digits 'in place' (postcondition) and displayed to output 
; as a single str.
;
; -------------------------------------------------------------------------------------

writeVal PROC

  PUSH  EBP
  MOV   EBP, ESP
  PUSHAD
  MOV   EDI, [EBP + 8]                           ; place OFFSET of array into EDI

; manually convert signed integer 32-bit hex to ascii chars, store in inputStr
  MOV   EAX, [EDI]                               ; place 32 bit hex in EAX
  MOV   EBX, 10                                  ; will be divisor in conversion loop
  MOV   [EBP - WORD PTR 1], 31h                  ; initialize local variable with positive value
  MOV   ECX, 0                                   ; initialize the counter at zero
  CMP   EAX, 0                                   ; sub 0, check sign flag for negative
  JNS   _remainderLoop                           ; if SF not set, skip neg sign storage
  MOV   [EBP - WORD PTR 1], 0FFh                 ; store negative in local variable

  ; continually divide 32-bit integer by 10, pushing remainders to stack, until the division results in zero
_remainderLoop:
  CDQ                                            ; sign extend EAX
  IDIV  EBX                                      ; divide by 10
  CMP   EDX, 0
  JGE   _contPos
  NEG   EDX
_contPos:
  PUSH  EDX                                      ; push remainder to stack
  INC   ECX
  CMP   EAX, 0
  JNE   _remainderLoop                           ; after final execution of this loop remainders will be 
                                                 ; stored on stack in reverse order
  MOV   AX, [EBP - WORD PTR 1]                   ; place sign at element one in string
  MOV   EBX, ECX                                 ; secondary counter to be incremented and passed to MACRO below
  STOSB                                          ; store AL into whatever is pointed to by EDI

  ; pop all the remainders back and convert to ASCII hex values
_popStackLoop:
  POP   EAX
  ADD   AL, 30h                                  ; pop remainder from stack and add 30h to it to find ASCII digit
  STOSB
  LOOP  _popStackLoop

  mDisplayString [EBP + 8], EBX

  POPAD
  ROL   EAX, 16
  MOV   AX, 0040h                                ; fix return value of EAX, please don't ask, if I have time I'll fix this
  ROL   EAX, 16
  POP   EBP
  RET   4
  
writeVal ENDP

; --------------------------------------------------
; Simple display procedure to display a farewell
; to the user at the end of main procedure execution
;
; --------------------------------------------------

goodbyeDisplay PROC

  PUSH  EBP
  MOV   EBP, ESP
  PUSH  EDX
  MOV   EDX, [EBP + 8]
  CALL  WriteString
  CALL  CrLf
  POP   EDX
  POP   EBP
  RET   4

goodbyeDisplay ENDP

END MAIN
