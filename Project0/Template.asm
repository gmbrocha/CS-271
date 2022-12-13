TITLE Program Template     (template.asm)

; Author: 
; Last Modified:
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section ???
; Project Number:                 Due Date:
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

.data
yes     BYTE    "Yes",0
no      BYTE    "No",0

.code
main PROC

  MOV   EAX, 5
  CMP   EAX, 5
  JG    _printYes
  MOV   EDX, OFFSET no
  JMP   _finished
_printYes:
  MOV   EDX, OFFSET yes
_finished:
  CALL  WriteString

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
