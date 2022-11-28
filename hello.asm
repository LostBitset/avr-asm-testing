;;; hello.asm: Turns on a pin 13

;;; Includes
.nolist
.include "./m328Pdef.inc" ; Include def file for ATMEGA328P
.list

;;; Declarations
.def counter = r17
.def tmp_io_b = r16

;;; Handlers
.org 0x0 ; Reset handler
rjmp Init

.org 0x20 ; Timer0 Overflow ISR
rjmp Isr_Timer0_OF

;;; Entry Point
	rjmp Init

;;; Code
Init:
	rcall SetupTimer0
	ldi r16, 0x20
	out DDRB, r16 ; Make only 13 an output pin
	clr tmp_io_b ; Start with everything off
	rjmp MainLoop
MainLoop:
	rcall Main
	rjmp MainLoop
Main:
	ldi r18, 0x20
	eor tmp_io_b, r18 ; Toggle whether pin 13 should be HIGH or LOW
	rcall delay
	out PORTB, tmp_io_b ; Write to the memory-mapped IO (for pin 13)
	ret

;;; Functions (don't forget ret!)
SetupTimer0:
	ldi r18, 0x5
	out TCCR0B, r18 ; Set the clock selector bits CS{0..2}, so it ticks at f/1024
	ldi r18, 0x1
	sts TIMSK0, r18 ; Set TOIE0 (timer overflow interrupt enable) bit of mask
	sei ; Enable interrupts
	clr r18
	out TCNT0, r18 ; Initialize the TCNT0 to zero
	ret
Delay:
	clr counter ; Clear the counter
	_DelayLoop:
	cpi counter, 30
	brne _DelayLoop ; Jump back to loop if not equal
	ret

;; ISRs (don't forget iret!)
Isr_Timer0_OF:
	inc counter
	cpi counter, 61
	brne PC+2 ; Skip next line if not equal
	clr counter ; Clear the counter
	reti

