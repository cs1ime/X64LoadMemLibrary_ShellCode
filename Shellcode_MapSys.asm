	.code

_text SEGMENT

LoadMemSys PROC
	;int 3
	;lea rcx,[g_SysData]
	;mov rdx,1000000000h
	;mov r8,1000000000h
	;call LoadMemSys_Proc
	;ret
;LoadMemSys_Proc:
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push rbp
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	pushfq

	mov rbp,rsp
	sub rsp,70h
	
	;rcx = DllData
	;rdx = DriverObject
	;r8 = reg_path
	mov [rbp-58h],rdx
	mov [rbp-60h],r8

	xor rax,rax
	mov eax,dword ptr[rcx+3Ch]
	add rax,rcx

	mov [rbp-8],rcx
	mov [rbp-10h],rax
	mov rcx,rax
	call FirstSection
	mov [rbp-18h],rax

	sub rsp,30h
	mov dword ptr[rsp],'lAxE'
	mov dword ptr[rsp+4],'acol'
	mov dword ptr[rsp+8],'oPet'
	mov dword ptr[rsp+12],'iWlo'
	mov dword ptr[rsp+16],'aTht'
	mov dword ptr[rsp+20],'g'

	mov rcx,rsp
	call GetNtoskrnlExport
	add rsp,30h

	xor rcx,rcx
	xor rdx,rdx
	xor r8,r8
	mov rsi,[rbp-10h]
	mov edx,dword ptr[rsi+50h]
	mov r8d,'enoN'
	call WinAPI_EnterStack
	call rax
	call WinAPI_ExitStack
	mov [rbp-20h],rax

	;[rbp-8]=SysData   [rbp-10h]=inh   [rbp-18h]=ish   [rbp-20h]=Sys
	
	;Map All Section


	xor rcx,rcx
	mov rax,[rbp-10h]
	mov ecx,dword ptr[rax+54h]
	mov rsi,[rbp-8]
	mov rdi,[rbp-20h]
	rep movsb

	xor rcx,rcx
	mov cx,word ptr[rax+6]
	mov r8,[rbp-18h]
	mov r10,[rbp-8]
	mov r11,[rbp-20h]
	;r8=Current ish r9=cnt

	LoadMemSys_loop_map_section:
		push rcx

		xor rcx,rcx
		mov ecx,[r8+10h]
		xor rsi,rsi
		mov esi,[r8+14h]
		add rsi,r10
		xor rdi,rdi
		mov edi,[r8+0Ch]
		add rdi,r11
		rep movsb

		add r8,28h

		pop rcx
		loop LoadMemSys_loop_map_section

	xor r8,r8
	xor r9,r9
	mov rax,[rbp-10h]
	mov r8d,[rax+90h]
	cmp r8d,0
	je LoadMemSys_FixIAT_end
	add r8,[rbp-20h]
	mov r9d,[rax+94h]
	add r9,r8
	;r8=iid r9=iidMaxPtr

	LoadMemSys_loop_FixIAT:
		xor r10,r10
		xor r11,r11
		mov r10d,[r8+0Ch]
		cmp r10d,0
		;end of iid
		je LoadMemSys_loop_FixIAT_contine
		mov r11d,[r8+10h]
		cmp r11,0
		je LoadMemSys_loop_FixIAT_contine
		mov rax,[rbp-20h]
		add r10,rax
		add r11,rax
		mov rcx,r10
		push r8
		push r9
		push r10
		push r11
		push r12
		call IsVaildImportModule
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		cmp al,0
		je LoadMemSys_loop_FixIAT_contine
		mov r12,rdx
		;r10=DllName r11=FirstThunk r12=ntos or hal
		LoadMemSys_loop_FixIAT_FillThunk:
			mov rax,qword ptr[r11]
			cmp rax,0
			je LoadMemSys_loop_FixIAT_contine
			mov rbx,rax
			mov rsi,8000000000000000h
			and rbx,rsi
			cmp rbx,0
			jne LoadMemSys_loop_FixIAT_FillThunk_contine
			add rax,qword ptr[rbp-20h]
			add rax,2
			mov rcx,rax
			mov rdx,r12

			push r8
			push r9
			push r10
			push r11
			push r12
			call GetRoutineAddress
			pop r12
			pop r11
			pop r10
			pop r9
			pop r8

			mov qword ptr[r11],rax
			LoadMemSys_loop_FixIAT_FillThunk_contine:
				add r11,8
			jmp LoadMemSys_loop_FixIAT_FillThunk


	LoadMemSys_loop_FixIAT_contine:
		add r8,20
		cmp r8,r9
		jb LoadMemSys_loop_FixIAT


	LoadMemSys_FixIAT_end:
	;Fix Reloc

	mov r8,[rbp-10h]
	mov r9,[rbp-20h]
	xor r10,r10
	mov r10d,[r8+0B0h]
	cmp r10d,0
	je LoadMemSys_FixReloc_end
	add r10,r9
	xor r11,r11
	mov r11d,[r8+0B4h]
	add r11,r10
	;r8=inh r9=Dll r10=ibr r11=ibrMaxPtr
	
	LoadMemSys_FixReloc_loop:
		xor r12,r12
		xor r13,r13
		mov r12d,[r10]
		cmp r12d,0
		je LoadMemSys_FixReloc_end
		mov r13d,[r10+4]
		cmp r13d,8
		jb LoadMemSys_FixReloc_end
		lea r14,[r13+r10]
		lea r15,[r10+8]
		;r12=ibr->VirtualAddress r13=ibr->SizeOfBlock r14=NextIbrPtr r15=pRelocValues
		LoadMemSys_FixReloc_loop_loop:
			xor rax,rax
			mov ax,[r15]
			mov bx,ax
			and bx,0F000h
			cmp bx,0A000h
			jne LoadMemSys_FixReloc_loop_loop_contine
			and ax,0FFFh
			add rax,r9
			add rax,r12
			mov rbx,[rax]
			sub rbx,qword ptr[r8+30h]
			add rbx,r9
			mov [rax],rbx

			LoadMemSys_FixReloc_loop_loop_contine:
			add r15,2
			cmp r15,r14
			jb LoadMemSys_FixReloc_loop_loop

		LoadMemSys_FixReloc_loop_contine:
		add r10,r13
		cmp r10,r11
		jb LoadMemSys_FixReloc_loop
	LoadMemSys_FixReloc_end:

	xor rax,rax
	mov eax,[r8+28h]
	add rax,r9

	mov rcx,[rbp-58h]
	mov rdx,[rbp-60h]
	;int 3
	call WinAPI_EnterStack
	call rax
	call WinAPI_ExitStack

	mov rax,[rbp-20h]

	add rsp,70h

	popfq
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rbp
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx

	ret

GetRoutineAddress:
	;rcx=RoutineName
	;rdx=ntos or hal
	cmp dl,0
	jne GetRoutineAddress_Hal

	call GetNtoskrnlExport
	ret
	GetRoutineAddress_Hal:
	call GetHalExport
	ret

IsVaildImportModule: 
	;rdx ret ntos or hal
	;rcx=ModuleName
	sub rsp,30h
	xor rsi,rsi

	mov dword ptr[rsp],'sotn'
	mov dword ptr[rsp+4],'lnrk'
	mov dword ptr[rsp+8],'exe.'
	mov dword ptr[rsp+12],0

	mov rdx,rsp
	push rcx
	call strcmpi
	pop rcx
	xor rdx,rdx
	cmp al,0

	jne IsVaildImportModule_ret
	mov dword ptr[rsp],'.lah'
	mov dword ptr[rsp+4],'lld'
	mov rdx,rsp
	call strcmpi
	mov rdx,1
	IsVaildImportModule_ret:
	add rsp,30h
	ret

GetHalExport:
	push rcx
	call GetHal
	jmp GetHalExport_Proc
GetNtoskrnlExport:
	push rcx
	call GetNtoskrnl
	GetHalExport_Proc:
	pop rdx
	mov rcx,rax
	call GetMemProcAddress
	ret

GetHal:
	mov rax,qword ptr[g_Hal]
	cmp rax,0
	jne GetHal_ret

	sub rsp,30h
	call GetNtoskrnl
	mov dword ptr[rsp],65476D4Dh
	mov dword ptr[rsp+04h],73795374h
	mov dword ptr[rsp+08h],526D6574h
	mov dword ptr[rsp+0Ch],6974756Fh
	mov dword ptr[rsp+10h],6441656Eh
	mov dword ptr[rsp+14h],73657264h
	mov dword ptr[rsp+18h],73h
	
	mov rcx,rax
	mov rdx,rsp
	call GetMemProcAddress
	
	mov dword ptr[rsp],00610048h
	mov dword ptr[rsp+04h],0053006Ch
	mov dword ptr[rsp+08h],00740065h
	mov dword ptr[rsp+0Ch],00750042h
	mov dword ptr[rsp+10h],00440073h
	mov dword ptr[rsp+14h],00740061h
	mov dword ptr[rsp+18h],0061h
	
	mov word ptr[rsp+20h],26
	mov word ptr[rsp+22h],28
	mov qword ptr[rsp+28h],rsp
	
	mov rcx,rsp
	add rcx,20h
	call WinAPI_EnterStack
	call rax
	call WinAPI_ExitStack
	
	and rax,0FFFFFFFFFFFFF000h
	jmp GetHal_cmp1
	GetHal_loop1:
		sub rax,1000h
	GetHal_cmp1:
		cmp word ptr[rax],'ZM'
		jne GetHal_loop1
	add rsp,30h
	mov qword ptr[g_Hal],rax
	GetHal_ret:
	ret
	
	

GetNtoskrnl:

	mov rax,qword ptr[g_Ntoskrnl]
	cmp rax,0
	jne GetNtoskrnl_ret
	mov rcx,0C0000082h
	call ReadMsr
	and rax,0FFFFFFFFFFFFF000h
	jmp GetNtoskrnl_cmp1
	GetNtoskrnl_loop1:
		sub rax,1000h
	GetNtoskrnl_cmp1:
		cmp word ptr[rax],'ZM'
		jne GetNtoskrnl_loop1
	mov qword ptr[g_Ntoskrnl],rax
	GetNtoskrnl_ret:
	ret
ReadMsr:
	rdmsr
	shl rdx,20h
	or rax,rdx
	ret

WinAPI_EnterStack:
	lea r11,[rsp+8]
	and rsp,0fffffffffffffff0h
	push r11
	push r11
	sub rsp,30h
	jmp qword ptr[r11-8]

WinAPI_ExitStack:
	pop r11
	add rsp,38h
	pop rsp
	jmp r11

FirstSection:
	;rcx=inh
	xor rax,rax
	mov ax,[rcx+14h]
	lea rax,[rcx+18h+rax]
	ret

GetMemProcAddress:

	push rbp
	mov rbp,rsp
	sub rsp,300h

	mov r10,rcx
	mov r11,rdx

	cmp word ptr[rcx],'ZM'
	jne GetMemProcAddress_retZero
	xor rax,rax
	mov eax,dword ptr[rcx+3Ch]
	cmp word ptr[rcx+rax],'EP'
	jne GetMemProcAddress_retZero
	lea r12,[rcx+rax]

	mov eax,[r12+88h]
	cmp eax,0
	je GetMemProcAddress_retZero
	lea r13,[r10+rax]
	
	mov eax,[r13+18h]
	inc eax
	mov [rbp-14h],eax

	xor rax,rax
	mov eax,dword ptr[r13+1Ch]
	lea r15,[rax+r10]
	mov eax,dword ptr[r13+24h]
	lea r14,[rax+r10]
	mov eax,dword ptr[r13+20h]
	lea r13,[rax+r10]

	mov eax,[r12+2Ch]
	lea rsi,[rax+r10]
	mov [rbp-8],rsi
	mov eax,[r12+1Ch]
	add rsi,rax
	mov [rbp-10h],rsi
	xor rsi,rsi
	GetMemProcAddress_loop1:
		xor rcx,rcx
		mov ecx,[r13+rsi*4]
		lea rcx,[r10+rcx]
		mov rdx,r11
		push rsi
		call strcmpi
		pop rsi
		cmp al,0
		je GetMemProcAddress_loop1_contine
		xor rax,rax
		mov ax,[r14+rsi*2]
		mov eax,[r15+rax*4]
		add rax,r10
		jmp GetMemProcAddress_ret
	GetMemProcAddress_loop1_contine:
		inc rsi
		cmp esi,[rbp-14h]
		
		jne GetMemProcAddress_loop1



	GetMemProcAddress_retZero:
	xor rax,rax
	GetMemProcAddress_ret:
	add rsp,300h
	pop rbp
	ret

tosmall:
	cmp r8b,'A'
	jb tosmall_if1
	cmp r8b,'Z'
	ja tosmall_if1
	or r8b,20h
	tosmall_if1:
	ret


strcmpi:
	push rcx
	push rdx
	call lstrlenA
	mov r8,rax
	mov rcx,rdx
	call lstrlenA
	mov r9,rax
	pop rdx
	pop rcx


	cmp r8,r9
	jne strcmpi_retZero
	mov rsi,rcx
	xor rdi,rdi
	mov rcx,r8
	strcmpi_loop1:
		mov r8b,[rsi+rdi]
		call tosmall
		mov al,r8b
		mov r8b,[rdx+rdi]
		call tosmall
		inc rdi
		mov bl,r8b
		cmp al,bl
		jne strcmpi_retZero
		loop strcmpi_loop1
	xor rax,rax
	inc al
	ret
	strcmpi_retZero:
		xor rax,rax
		ret
lstrlenA:
	mov rax,rcx
	xor rcx,rcx
	dec rcx
	lstrlenA_loop1:
		inc rcx
		cmp byte ptr[rax+rcx],0
		jne lstrlenA_loop1
	mov rax,rcx
	ret

g_Ntoskrnl: 
	dq 0
g_Hal: 
	dq 0
g_SysData:
	dq 9090909090909090h

LoadMemSys   ENDP

_text ENDS

	END