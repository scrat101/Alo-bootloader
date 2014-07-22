.code16 
.org 0 

.macro DoInterrupt, intn 
	pusha 
	int $\intn   
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
	movw $0x400, %sp # Lets do a 512 byte stack, eh? 
	call ClearScreen 
	pushw $FirstMessage
	call PrintString 
	add $2, %sp 
	# call LoadStageTwo #Load stage two 
	pushw $LoadedMessage 
	call PrintString 
	add $2, %sp #Stack cleanup..................                  
	#jmp $0x301 #Transfer control to stage two 
	pushw $0x48 
	call PrintHex 
	add $2, %sp 
	jmp .ANotEndingLoop 
	.ANotEndingLoop:           
		jmp .ANotEndingLoop 
		
LoadStageTwo: 



ClearScreen: 
	movw $0x600, %ax 
	movw $0, %cx 
	movw 0x184F, %dx 
	movb $0x07, %bh 
	DoInterrupt 0x10 
	ret   
	
PrintChar: 
	movw %sp, %bx 
	movb 2(%bx), %al  
	mov $0xE, %ah 
	DoInterrupt 0x10 
	ret 
	
PrintString: 
	movw %sp, %bp 
	xor %bx, %bx 
	movb 2(%bp), %bl 
	jmp .MainLoop 
	.MainLoop: 
		movb (%bx), %al 
		cmp $0, %al  
		je .printdone 
		pushw %bx 
		pushw %ax 
		call PrintChar 
		add  $2, %sp 
		popw %bx 
		add $1, %bx 
		jmp .MainLoop 		
	.printdone: 
		ret 
		
PrintHex: 		
	movw $HexIndexStr, %si  
	movw %sp, %bp 
	xor %bx, %bx 
	movw 2(%bp), %ax 
	movw $4, %cx 
	jmp .MainLoo 
	.MainLoo: 
		cmp $0, %cx 
		je .theen 
		rol $4, %ax 
		movb %al, %bl  
		and $0xF, %bl     
		movb (%bx, %si), %bl          
		pushw %bx 
		call PrintChar 
		dec %cx 
	.theen: 
		ret 
	
		
FirstMessage: 
	.ascii "Hello bootloader world!\r\n" 
	.ascii "Loading stage two....\r\n"  
	.byte 0 
	
LoadedMessage: 
	.ascii "Stage two loaded." 
	.byte 0 
	
HexIndexStr: 
	.ascii "0123456789ABCDEF" 
	
	
.org 510 	
	.byte 0x55 
	.byte 0xAA 


