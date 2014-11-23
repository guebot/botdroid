LIST		P=16F877A
__CONFIG	_CP_OFF&_WDT_OFF&_PWRTE_ON&_XT_OSC

CBLOCK		20h
			C_PR2, C_T2CON, C_CCPR1L, C_CCP1CON
ENDC
		
#include	<P16F877A.INC>
#define		BANCO0	bcf	STATUS,RP0
#define		BANCO1	bsf	STATUS,RP0

			ORG		00h
			goto	INICIO
			nop
			nop
			nop
			nop

CONF_PWM	BANCO1
			movlw	b'11111111'
			movwf	PR2
			BANCO0
			movlw	b'11000000'
			movwf	CCPR1L
			movlw	b'00001100'		; 00111100
			movwf	CCP1CON
			BANCO1
			bcf		TRISC,2
			BANCO0
			movlw	b'00000100'
			movwf	T2CON
			return

CONF_TMR0	
		
INICIO		call	CONF_PWM
			call	CICLO

CICLO		nop
			goto	CICLO

			end
