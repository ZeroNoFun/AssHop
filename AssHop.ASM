format PE DLL
include 'win32a.inc'
include 'macro/if.inc'
entry DllMain
 
section '.data' data readable writeable
        ;DLL
        ClientDll db 'client.dll', 0
        ClientLib dd ? ;Client address that we gonna get from GetModuleHandle
        ;-DLL
        ;Offsets
        LocalPlayerOffset dd 0xAADFFC
        ForceJump dd 0x4F215E8 ; Writing to this pointer TRUE makes player jump
        ;-Offsets
        ;Values
        LocalPlayer dd ?
        ;-Values

section '.code' code executable
proc DllMain, hInstance, fdwReason, lpvReserved
     .if [fdwReason] = DLL_PROCESS_ATTACH
         invoke createthread, NULL, NULL, thread, NULL, NULL, NULL
     .endif
     mov eax, TRUE
     ret
endp
 
proc thread
init:
        .grabmodules:
                invoke GetModuleHandle, ClientDll
                mov [ClientLib], eax
hack:
        .localplayer:
                mov eax, [ClientLib]
                add eax, [LocalPlayerOffset]
                mov eax, [eax]
                mov dword[LocalPlayer], eax
        .keyboard:
                invoke GetAsyncKeyState, VK_SPACE
                test eax, eax
                jz .keyboard
        .flags:
                mov eax, [LocalPlayer]
                add eax, 0x100
                mov eax, [eax]
                and eax, 0x1
                cmp eax, 1
                jne .keyboard
        .jump:
                mov eax, [ClientLib]
                add eax, [ForceJump]
                mov dword[eax], 6
                jmp .keyboard
        ret
endp
 
section '.idata' import data readable
library user32, 'user32.dll',\
        kernel32, 'kernel32.dll'
 
import  user32,\
        GetAsyncKeyState, 'GetAsyncKeyState'
 
import kernel32,\
       createthread, 'CreateThread',\
       GetModuleHandle, 'GetModuleHandleA'
 
section '.reloc' fixups data readable discardable