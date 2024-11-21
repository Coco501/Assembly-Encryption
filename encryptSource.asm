;Joe Vogel

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

ReadInput PROTO
WriteOutput PROTO

CreateFileA PROTO, lpFilename:PTR BYTE, dwDesiredAccess:DWORD, dwShareMode:DWORD, lpSecurityAttributes:DWORD, dwCreationDisposition:DWORD, dwFlagsAndAttributes:DWORD, hTemplateFile:DWORD
WriteFile PROTO, hFile:DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToWrite:DWORD, lpNumberOfBytesWritten:PTR DWORD, lpOverlapped:PTR DWORD
CloseHandle PROTO, hObject:DWORD

.data
GENERIC_WRITE EQU <40000000h>
CREATE_ALWAYS EQU <2>
NORMAL_FLAGS EQU <128>

filename BYTE "Encrypted_Message.txt"
filehandle DWORD ?

inputbuffer BYTE 300 DUP(?)
bytesWritten DWORD ?

promptUser BYTE "Please enter any message to be encrypted, or type q to quit.	", 0

moduloNumber BYTE ?
inputLength BYTE ?

.code
	main PROC

	;Creating file
	INVOKE CreateFileA, addr filename, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, NORMAL_FLAGS, 0
	mov filehandle, eax

askForInput:
	;Ask for input in console
	push lengthof promptUser
	push offset promptUser
	INVOKE WriteOutput

	;Calling ReadInput function for user input
	push lengthof inputbuffer
	push offset inputbuffer
	INVOKE ReadInput
	mov bytesWritten, eax
	mov inputLength, al

	;Checking for input of just 'q', to quit
	cmp bytesWritten, 3			
	je potentialq						;if only one letter was typed, we jump to check if it was q
	


continueAsNormal:
	push dword ptr lengthof inputbuffer
	push offset inputbuffer
	call findE						;sets ebx to number of 'e's (only lowercase) in input

	mov eax, ebx						;prepare to divide number of 'e's by 8
	mov ebx, 8
	mov edx, 0
	div ebx							;quotient goes to EAX, remainder to EDX

	mov moduloNumber, dl
	cmp edx, 0
	jne nonZeroRemainder
	

ZeroRemainder:
	;if it is 0, we are here now, and need to flip all bits by XORing with 1111 1111
	mov ecx, bytesWritten
	mov eax, offset inputbuffer
flipBits:
	XOR [eax], byte ptr 11111111
	inc eax							;increment eax for next loop
	loop flipBits
	jmp writeIntoFile


nonZeroRemainder:
	;need to roll bits left by remainder times using ROL (rotate left)
	mov ecx, bytesWritten
	mov eax, offset inputbuffer
rotateBits:
	push ecx
	mov cl, dl
	ROL byte ptr [eax], cl	
	pop ecx
	inc eax
	loop rotateBits
	jmp writeIntoFile


writeIntoFile:
	INVOKE WriteFile, filehandle, addr inputLength, 1, addr bytesWritten, 0 
	INVOKE WriteFile, filehandle, addr moduloNumber, 1, addr bytesWritten, 0
	INVOKE WriteFile, filehandle, addr inputbuffer, inputLength, addr bytesWritten, 0
	jmp EndingProgram

potentialq:
	mov esi, offset inputbuffer	;esi set to the start of the input array's address
	cmp [esi], byte ptr 'q'		;check if input was letter q
	jne continueAsNormal		;if the letter is not q, jump back to program and continue as normal


EndingProgram:
	INVOKE CloseHandle, filehandle
	INVOKE ExitProcess, 0

main ENDP



; findE Procedure
; Determines how many 'e' are present in a string
; Receives: two parameteres, pointer to string and length of the string
; Returns: total number of 'e's stored in EBX.

findE PROC
    push ebp                    ; save ebp so we can create the stack frame
    mov ebp, esp                ; set ebp to esp, now ebp is our frame pointer
    sub esp, 4                  ; make space for one local variable
    push ecx                    ; preserve ecx and edx
    push edx

    mov eax, 0                  ; set eax, ebx, and the local variable to 0
    mov ebx, 0
    mov [ebp - 4], dword ptr 0
    mov ecx, [ebp + 12]         ; set ecx to the length of the string parameter
    mov esi, [ebp + 8]          ; set esi to the string address parameter
loopstart:
    mov dl, [esi]               ; grab a character from the string
    cmp dl, 'e'                 ; compare the character to e
    jne nextcharacter           ; if our character isn't an e, jump ahead
    
    ; only move to the next line if the character was an e
    inc ebx                     ; count up 1 more e found
    jmp nextcharacter           

nextcharacter:                  ; both jumps lead here
    inc esi                     ; move to the next character in the string
    loop loopstart

    pop edx                     ; restore ecx and edx
    pop ecx
    mov esp, ebp                ; remove the local variable from the stack
    pop ebp                     ; restore ebp
    ret 8                       ; remove our 2 parameters from the stack and return

findE ENDP

END main