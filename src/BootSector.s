.code16 
.org 0 

.macro DoInterrupt, intn 
	pusha 
	int $\intn   
	popa  
.endm 

.macro FunctionEntry 
	pusha 
	movw %sp, %bp 
	add $18, %bp 
.endm 

.macro FunctionExit 
	popa 
.endm 
 
movw $0x7C0, %ax 
movw %ax, %ds 
movw %ax, %es 
movw %ax, %fs 
movw %ax, %gs 
movw %ax, %ss 
jmpl $0x7C0, $thestart 

thestart: 
	movw $DriveNumber, %di   
	movb %dl, (%di) 
	movw $0x400, %sp # Lets do a 512 byte stack, eh? 
	call ClearScreen 
	pushw $FirstMessage
	call PrintString 
	add $2, %sp 
	# call LoadStageTwo #Load stage two 
	pushw $LoadedMessage 
	call PrintString 
	add $2, %sp #Stack cleanup..................        
	pushw $DriveNumberMessage 
	call PrintString 
	add $2, %sp 
	movw $DriveNumber, %bx 
	pushw (%bx) 
	call PrintHex 
	add $2, %sp 
	pushw $0x2E 
	call PrintChar  
	add $2, %sp 
	#jmp $0x401 #Transfer control to stage two 
	jmp .ANotEndingLoop 
	.ANotEndingLoop:           
		jmp .ANotEndingLoop 
		
LoadStageTwo: 
	#Empty for now. 


ClearScreen: 
	pusha 
	movb $0, %bh 
	movw $0, %dx 
	movb $0x02, %ah 
	DoInterrupt 0x10 
	movw $0, %cx 
	movw $0x0700, %ax 
	movb $0x07, %bh 
	movw $0x184F, %dx 
	DoInterrupt 0x10 
	popa 
	ret   
	
PrintChar: 
	FunctionEntry 
	movb (%bp), %al  
	mov $0xE, %ah 
	DoInterrupt 0x10 
	FunctionExit 
	ret 
	
PrintString: 
	FunctionEntry 
	movw (%bp), %bx 
	jmp .MainLoop 
	.MainLoop: 
		movb (%bx), %al 
		cmp $0, %al  
		je .printdone 
		pushw %ax 
		call PrintChar 
		add  $2, %sp 
		add $1, %bx 
		jmp .MainLoop 		
	.printdone: 
		FunctionExit 
		ret 
		

PrintHex: 
	FunctionEntry 
	pushw $PrintHexPreStr 
	call PrintString 
	add $2, %sp 
	movw (%bp), %cx 
	movw $4, %ax 
	movw $HexStr, %di 
	.TheLoopyLoop: 
		cmp $0, %ax 
		je .itisdone 
		rol $4, %cx 
		movw %cx, %bx 
		and $0x0F, %bx 
		add %di, %bx 
		movw (%bx), %bx 
		pushw %bx 
		call PrintChar 
		add $2, %sp 
		dec %ax 
		jmp .TheLoopyLoop  
	.itisdone: 
		FunctionExit 
		ret 
		
FirstMessage: 
	.ascii "Hello bootloader world!\r\n" 
	.ascii "Loading stage two....\r\n"  
	.byte 0 
	
LoadedMessage: 
	.ascii "Stage two loaded."     
	.byte 0 
	
DriveNumber: 	
	.byte 0x00 
	
HexStr: 
	.ascii "0123456789ABCDEF" 

PrintHexPreStr: 
	.ascii "0x"  
	.byte 0 
	
DriveNumberMessage: 
	.ascii "\r\nDrive number: " 
	.byte 0 

.org 510 	
	.byte 0x55 
	.byte 0xAA 


