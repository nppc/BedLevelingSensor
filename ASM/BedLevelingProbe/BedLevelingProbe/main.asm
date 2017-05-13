; we assume that PWM signal means: 1000us - 0 deg, 2000us - 180 deg
; 10 deg  = 1055us or 131 ticks  (Push-pin down)
; 90 deg  = 1500us or 187 ticks  (Push-pin up)
; 120 deg = 1667us or 208 ticks  (Manual self-test)
; 160 deg = 1889us or 235 ticks  (alarm releae)

.EQU	PWM_PIN		= PB0	; PWM (servo) input 
.EQU	LED_PIN		= PB1	; LED pin 
.EQU	SENSE_PIN	= PB2	; Contacts 
.EQU	COILB_PIN	= PB3	; 
.EQU	COILA_PIN	= PB4	; 

.undef ZL
.undef ZH
.def	z0			= r0	; zero reg
.def	z1			= r1	; one reg
.def	pwm_err_cnt	= r2	; counter for overflows of timer1 for detecting failed signal
.def	sreg_tmp	= r3	; preserve SREG in interrupts
.def	lastPinState= r4	; Probe pin (0 - up, 1 - down)
.def	tmp			= r16 	; general temp register
.def	tmp1		= r17 	; general temp register
.def	tmp2		= r18 	; general temp register
.def	itmp		= r19 	; general interrupts temp register
.def	itmp1		= r20 	; general interrupts temp register
.def	PWMval		= r30	; value ofm PWM input in timer ticks (0 - no valid signal)
.def	PWMdeg		= r31	; value ofm PWM input in deg (0 - no valid signal)

;.def	z0			= r31	; zero reg

;.DSEG
;.ORG RAMEND-127	; start of SRAM data memory
;RST_OPTION: 	.BYTE 1	; store here count of reset presses after power-on to determine special modes of operation

	
 .MACRO COIL_OFF
		cbi PORTB, COILA_PIN
		cbi PORTB, COILB_PIN
 .ENDMACRO

 .MACRO PROBE_UP
		cbi PORTB, COILB_PIN
		sbi PORTB, COILA_PIN
		clr lastPinState
 .ENDMACRO

  .MACRO PROBE_DOWN
		cbi PORTB, COILA_PIN
		sbi PORTB, COILB_PIN
		mov lastPinState, z1
 .ENDMACRO

 .MACRO LED_ON
		cbi PORTB, LED_PIN
 .ENDMACRO

 .MACRO LED_OFF
		sbi PORTB, LED_PIN
 .ENDMACRO

.cseg
.org 0x0000 ;Set address of next statement
rjmp RESET ; Address 0x0000
rjmp INT0_ISR ; Address 0x0001
rjmp PCINT0_ISR ; Address 0x0002
reti	;rjmp TIM1_COMPA_ISR ; Address 0x0003
rjmp TIM1_OVF_ISR ; Address 0x0004
reti	;rjmp TIM0_OVF_ISR ; Address 0x0005
reti	;rjmp EE_RDY_ISR ; Address 0x0006
reti	;rjmp ANA_COMP_ISR ; Address 0x0007
reti	;rjmp ADC_ISR ; Address 0x0008
reti	;rjmp TIM1_COMPB_ISR ; Address 0x0009
reti	;rjmp TIM0_COMPA_ISR ; Address 0x000A
reti	;rjmp TIM0_COMPB_ISR ; Address 0x000B
reti	;rjmp WDT_ISR ; Address 0x000C
reti	;rjmp USI_START_ISR ; Address 0x000D
reti	;rjmp USI_OVF_ISR ; Address 0x000E

RESET: ; Main program start
// config part
		cli
		ldi tmp, low (RAMEND) ; to top of RAM
		out SPL,tmp
		clr Z0
		clr z1
		inc z1

		clr pwm_err_cnt
		clr PWMdeg		; PWM signal is undefined
		clr PWMval		; PWM signal is undefined

		rcall MAIN_CLOCK_8MHZ
		COIL_OFF
		cbi DDRB, SENSE_PIN
		cbi DDRB, PWM_PIN
		sbi PORTB, SENSE_PIN ; PULLUP
		sbi PORTB, PWM_PIN ; PULLUP
		sbi DDRB, LED_PIN
		sbi DDRB, COILA_PIN
		sbi DDRB, COILB_PIN
		LED_OFF
		; pin change interrupt for PB0 and PB2 (PWM input and sense contacts)
		ldi tmp, (1<<PCIE) | (1<<INT0)
		out GIMSK, tmp
		ldi tmp, 1<<PCINT0
		out PCMSK, tmp
		; INT0 interrupt for sense pin
		ldi tmp, (1<<ISC00) | (0<<ISC01)
		out MCUCR, tmp

		; Timer1 fro PWM capture
		ldi tmp, 1<<CS10 | 1<<CS11 | 1<<CS12 | 0<<CS13 ;/64 (about 2048us)
		out TCCR1, tmp
		ldi tmp, 1<<TOIE1
		out TIMSK, tmp

		rcall WAIT1MS ; in case if coil is charged
		PROBE_UP
		sei

// main loop
L1:
		; check PWM signal
		rcall getPWMdeg ; updates PWMdeg variable
		; do something
		cpi PWMdeg, 90	; pin Up
		brne pwm_not_90
		cp lastPinState, z0
		breq pwm_deg_end	; already up
		PROBE_UP
		rjmp pwm_deg_end
pwm_not_90:
		cpi PWMdeg, 10	; pin Up
		brne pwm_not_10
		cp lastPinState, z1
		breq pwm_deg_end	; already up
		PROBE_DOWN
		rjmp pwm_deg_end
pwm_not_10:

		
pwm_deg_end:

		rjmp L1

// read PWM signal and convert it to degrees (update PWMdeg variable)
getPWMdeg:
		mov tmp, PWMval ; store it because intrrupt can change it anytime.
		cpi tmp, 129
		brlo PWM_end
		cpi tmp, 134
		brsh not10deg
		ldi PWMdeg, 10
		rjmp PWM_end
not10deg:
		cpi tmp, 185
		brlo PWM_end
		cpi tmp, 189
		brsh not90deg
		ldi PWMdeg, 90
		rjmp PWM_end
not90deg:
		cpi tmp, 206
		brlo PWM_end
		cpi tmp, 210
		brsh not120deg
		ldi PWMdeg, 120
		rjmp PWM_end
not120deg:
		cpi tmp, 233
		brlo PWM_end
		cpi tmp, 237
		brsh PWM_end
		ldi PWMdeg, 120
PWM_end: ; do nothing
		ret		

WAIT100MS:  ; routine that creates delay 100ms at 8MHZ
		ldi  tmp, 5
		ldi  tmp1, 15
		ldi  tmp2, 242
wL1:	dec  tmp2
		brne wL1
		dec  tmp1
		brne wL1
		dec  tmp
		brne wL1
		ret

WAIT1MS:  ; routine that creates delay 1ms at 8MHZ
		ldi  tmp, 11
		ldi  tmp1, 99
wL2:	dec  tmp1
		brne wL2
		dec  tmp
		brne wL2
		ret

MAIN_CLOCK_8MHZ:
		; 8Mhz (Leave 8 mhz osc with prescaler 1)
		; Write signature for change enable of protected I/O register
		ldi tmp, 1<<CLKPCE
		out CLKPR, tmp
		ldi tmp, (0 << CLKPS3) | (0 << CLKPS2) | (0 << CLKPS1) | (0 << CLKPS0) ;  prescaler is 2 (4mhz)
		out  CLKPR, tmp
		ret

INT0_ISR:
		in sreg_tmp, SREG
		in itmp, TCNT1	; preserve timer counter value
		out TCNT1, z0	; reset timer for next pulse
		;if pwm_err_cnt is not 0 then this is pause between PWM pulses. Do not update PWMval register
		cp pwm_err_cnt, z0
		brne int0_ext
		; get ticks
		mov PWMval, itmp
int0_ext:
		clr pwm_err_cnt	; some PWM change is detected, so reset overflow counter
		out SREG, sreg_tmp
		reti

PCINT0_ISR:
		in sreg_tmp, SREG
		out SREG, sreg_tmp
		reti

TIM1_OVF_ISR:
		in sreg_tmp, SREG
		; no valid signal or pause between pulses are came
		inc pwm_err_cnt
		brne tmovr_ext ; if we have 255 then preserve it.
		dec pwm_err_cnt	
tmovr_ext:
		out SREG, sreg_tmp
		reti

init_self_test:
; three times up/down
ret