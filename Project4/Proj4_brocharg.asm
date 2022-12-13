TITLE Give Me N Primes!   (Proj4_brocharg.asm)

; Author: Glen M. Brochard
; Last Modified: 11/13/2022
; OSU email address: brocharg@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 4        Due Date: 11/13/2022
; Description: This program utilizes 5 procedures (two of which contain subprocedures) that perform task in this order: introduction
; procedure displays the program name and programmer; displayInstructions displays an acceptable range of inputs for the user; getUserData
; prompts the user for input, validates with a subprocedure that sets a boolean value that will dictate whether or not the data will
; be accepted, otherwise displays and invalid input error message and prompts user again; showPrimes accepts the validated input and uses 
; a loop from userNum down to 1 and checks each of these n values for being prime via isPrime subprocedure, showPrimes will utilize a second
; subprocedure which will dictate display of primes found and to print x number of primes per line, as well as x number of lines before 
; pausing and waiting for any user keystroke to continue execution; final procedure farewell simply displays a farewell message to the user

INCLUDE Irvine32.inc

UPPER = 4000                        ; sets up range for valid user input
LOWER = 1                           ; sets lower range for valid user input

.data

programTitle       BYTE  "**********Give Me N Primes! by ",0                        ; program title for display
programmerName     BYTE  "Glen M. Brochard (nezcoupe)**********",0
instructions       BYTE  "Please enter any integer between [1, 4000]",0
instructions2      BYTE  "This program will display all primes up to ",0
instructions3      BYTE   "and including the integer that you enter.",0
userNumPrompt      BYTE  "Enter an arabic numeral: ",0
userNum            DWORD ?          ; for storing user input
condBool           BYTE  ?          ; boolean identifier for conditinals
incrementNth       DWORD 2          ; used by showPrimes loop to iterate up to user imput
colIndex           DWORD 0          ; used by checkPosition proc for printing newline
rowIndex           DWORD 0          ; used by checkPosition proc for wait message
invalidMessage     BYTE  "Not within specified range. Try again - this time, use the Force, Harry.",0      ; error message for invalid entries
goodbye            BYTE  "Y'all come back now, ya hear?",0
extraCreditMsg1    BYTE  "**EC1: Output of this program is left aligned into columns.",0
extraCreditMsg2    BYTE  "**EC2: Increased display of primes up to 4000, with wait messages ",0
extraCreditMsg3    BYTE  "       appearing every 20 rows.",0                        ; this third message is just for aesthetic

.code

; -------------------------------------------
; main procedure that will do all the callin'
;
; -------------------------------------------

main PROC

  CALL introduction  
  CALL displayInstructions
  CALL getUserData
  CALL showPrimes
  CALL farewell

  Invoke ExitProcess,0	        ; exit to operating system

main ENDP

; -----------------------------------------
; display programmer name and program title
; and extra credit identification
;
; -----------------------------------------

introduction PROC

  PUSH EDX
  MOV  EDX, OFFSET programTitle
  CALL WriteString
  MOV  EDX, OFFSET programmerName
  CALL WriteString
  CALL CrLf
  CALL CrLf
  MOV  EDX, OFFSET extraCreditMsg1
  CALL WriteString
  CALL CrLf
  MOV  EDX, OFFSET extraCreditMsg2
  CALL WriteString
  CALL CrLf
  MOV  EDX, OFFSET extraCreditMsg3
  CALL WriteString
  CALL CrLf
  CALL CrLf
  POP  EDX
  RET

introduction ENDP

; --------------------------------------------------------------
; display instructions for program use; prompt user for a number
; and tell user what range of input values are accepted valid
;
; --------------------------------------------------------------

displayInstructions PROC

  PUSH EDX
  MOV  EDX, OFFSET instructions
  CALL WriteString
  CALL CrLf
  CALL CrLf
  MOV  EDX, OFFSET instructions2
  CALL WriteString
  CALL CrLf
  MOV  EDX, OFFSET instructions3
  CALL WriteString
  CALL CrLf
  CALL CrLf
  POP  EDX
  RET

displayInstructions ENDP

; -------------------------------------------------------------
; obtain user input and validate inputs; any invalid input will
; result in a re-prompt until entry is in the specified range
;
; -------------------------------------------------------------

; get the data and call validate

getUserData PROC

  PUSH EDX
  MOV  EDX, OFFSET userNumPrompt
  CALL WriteString
  CALL ReadInt
  MOV  userNum, EAX
  CALL CrLf
  CALL validateData
  POP  EDX
  RET

getUserData ENDP

; validate user data, if user input is out of range, display error message and restart input loop

validateData PROC

  PUSH EAX
  PUSH EDX
  MOV  EAX, userNum
  CMP  EAX, LOWER
  JL   _setFalse					; if less than LOWER jump to setFalse
  CMP  EAX, UPPER
  JG   _setFalse					; if greater than UPPER jump to setFalse
  MOV  condBool, 1
  JMP  _compareBool

_setFalse:
  MOV  condBool, 0 

_compareBool:
  CMP  condBool, 1 
  JE   _return						; if validatedBool is 1, skip invalid display and exit validation
  MOV  EDX, OFFSET invalidMessage
  CALL WriteString
  CALL CrLf
  CALL CrLf
  CALL getUserData					; if validatedBool is 0, Jcond above will fail and execution will fall through to re-call

_return:
  POP  EDX
  POP  EAX
  RET

validateData ENDP

; ---------------------------------------------------------------
; calculate all of the primes up to and including the n-th (user 
; input) integer; display these 10 (*6 after extra credit) primes
; per line, left aligned by utilizing a TAB character; procedure 
; will pause at 20 lines of output and wait for user keystroke and
; then continue
;
; ---------------------------------------------------------------

; showPrime procedure will utilize 2 subprocedures to check for prime (for display) and check position of display to format output

showPrimes PROC
  
  PUSHAD
  MOV  ECX, userNum                 ; initialize ECX counter to userNum

_topShowPrimeLoop:                  ; code label for head of loop with ECX = userNum     
  CALL isPrime                      ; this call will set bool value for print condition
  CMP  condBool, 1
  JNE  _continue
  CALL checkPosition

_continue:
  INC  incrementNth                 ; increment Nth, decrement ECX with LOOP and jump back to topOfLoop if ECX != 0
  LOOP _topShowPrimeLoop
  POPAD
  RET

showPrimes ENDP

; isPrime - subprocedure of showPrimes to check whether an Nth integer from the main loop is prime or not; returns boolean 1 or 0

isPrime PROC
							   
  PUSHAD
  MOV  EAX, incrementNth            ; move current nth value produced by showPrimes loop into eax for evaluation
  CDQ
  MOV  EBX, 2
  DIV  EBX                          ; div nth/2 to produce loop range value   
  MOV  ECX, EAX                     ; set counter for loop to start at Nth/2
							        ; and the conditional will also serve to avoid the last unnecessary iteration
_topIsPrimeLoop:
  CMP  ECX, 1                       ; will terminate at ECX = 1, will cover integers 2 and 3 which we know to be prime (3/2 and 2/2 = 1)
  JE   _isPrime                     ; if ECX = 1, we have have not found any values where the remainder is zero in the iteration and the Nth is prime
  MOV  EAX, incrementNth
  CDQ
  MOV  EBX, ECX                     ; move current loop counter into ebx and divide the current Nth value by it
  DIV  EBX
  CMP  EDX, 0
  JE   _notPrime                    ; if any remainder from Nth/2 to 1 is R = 0, we know this Nth value has at least an extra divisor and is not prime
  LOOP _topIsPrimeLoop
  							   
_isPrime:                           ; is prime, set boolean to 1, pop registers and return to calling proc
  MOV  condBool, 1
  POPAD
  RET
							   
_notPrime:                          ; not prime, set boolean to 0, pop registers and return to calling proc
  MOV  condBool, 0
  POPAD
  RET

isPrime ENDP

; subprocedure of isPrime for checking columns and rows for proper display, not necessarily needed but, included because 
; the main LOOP in showPrimes could not execute to due a byte range issue. Maybe a nice subprocedure to have anyway? 

checkPosition PROC

  PUSHAD
  CMP  colIndex, 0             ; check colIndex to see if 0 
  JE   _noTab               ; if zero, skep printing TAB character
  MOV  AL, 09h
  CALL WriteChar               ; print tab character for alignment

_noTab:
  INC  colIndex                ; increment column number
  MOV  EAX, incrementNth       ; if condBool = 1 (Nth is prime) display the prime
  CALL WriteDec
  CMP  colIndex, 6             ; originally 10, set to 6 for aesthetic; this value will set the number items per row to display
  JNE  _return
  CALL CrLf                    ; if colIndex = 6, execution from Jcond fails and falls through to this newline, then reset colIndex
  MOV  colIndex, 0
  INC  rowIndex                ; at newline, we need to increment our row index
  CMP  rowIndex, 20            ; compare rowIndex to 20, at row 20, fall through the Jcond to...
  JNE  _return
  MOV  rowIndex, 0             ; reset rowIndex to 0
  CALL WaitMsg                 ; pause and wait for any user keystroke (thanks Irvine, this is handy, I almost tried to do this manually)
  CALL CrLf                    ; after keystroke, newline and continue
 
_return:
  POPAD
  RET

checkposition ENDP

; --------------------------------------
; display a farewell message to the user
;
; --------------------------------------

farewell PROC

  PUSH EDX
  CALL CrLf
  MOV  EDX, OFFSET goodbye
  CALL WriteString
  CALL CrLf
  POP  EDX
  RET

farewell ENDP

END main