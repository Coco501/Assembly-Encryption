;Joe Vogel

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

WriteOutput PROTO

CreateFileA PROTO, lpFilename:PTR BYTE, dwDesiredAccess:DWORD, dwShareMode:DWORD, lpSecurityAttributes:DWORD, dwCreationDisposition:DWORD, dwFlagsAndAttributes:DWORD, hTemplateFile:DWORD
ReadFile PROTO, hFile:DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToRead:DWORD, lpNumberOfBytesRead:PTR DWORD, lpOverlapped:PTR DWORD
CloseHandle PROTO, hObject:DWORD
GetLastError PROTO

.data

filename BYTE "Encrypted_Message.txt"
filehandle DWORD ?
readbuffer BYTE 300 DUP(?)
bytesRead DWORD ?
inputLength BYTE ?
moduloNumber BYTE ?


GENERIC_READ EQU <80000000h>
OPEN_EXISTING EQU <3> 
NORMAL_FLAGS EQU <128>

errorMessage BYTE "ERROR: the file was not found.", 0
messageDecrypted BYTE "The decrypted message is: ", 0

.code
	main PROC

	INVOKE CreateFileA, addr filename, GENERIC_READ, 0, 0, OPEN_EXISTING, NORMAL_FLAGS, 0
	mov filehandle, eax

	INVOKE GetLastError
	cmp eax, 2
	je filenotfound

readFromFile:
	INVOKE ReadFile, filehandle, addr readbuffer, 1, addr bytesRead, 0
	cmp bytesRead, 0
	je endProgram
	mov al, [readbuffer]
	mov inputLength, al
	INVOKE ReadFile, filehandle, addr readbuffer, 1, addr bytesRead, 0
	mov al, [readbuffer]
	mov moduloNumber, al
	INVOKE ReadFile, filehandle, addr readbuffer, inputLength, addr bytesRead, 0

	mov ecx, 0
	mov cl, inputLength
	cmp moduloNumber, 0
	mov eax, offset readbuffer
	jne ModuloWasNot0

ModuloWas0:
	;decrypt by flipping all bits using XOR
	mov eax, offset readbuffer
	XOR [eax], byte ptr 11111111
	inc eax
	loop ModuloWas0

ModuloWasNot0:
	;decrypt by rotating right by modulo value
	push ecx
	mov cl, moduloNumber
	ROR byte ptr [eax], cl
	pop ecx
	inc eax
	loop ModuloWasNot0


WriteToConsole:
	push lengthof messageDecrypted
	push offset messageDecrypted
	INVOKE WriteOutput

	push bytesRead
	push offset readbuffer
	INVOKE WriteOutput 
	jmp readFromFile


filenotfound:
	push lengthof errorMessage
	push offset errorMessage
	INVOKE WriteOutput


endProgram:
	INVOKE CloseHandle, filehandle
	INVOKE ExitProcess, 0
main ENDP
END main