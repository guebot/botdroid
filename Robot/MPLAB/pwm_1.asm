LIST		P=16F877A
__CONFIG	_CP_OFF&_WDT_OFF&_PWRTE_ON&_HS_OSC

CBLOCK		20h
			C_PERIODO_PWM		; Indica el periodo de la señal PWM
			C_ANCHO_PWM			; Indica el ancho PWM programado en alto
			C_CICLO_PWM		  ; Indica el ciclo PWM actual
ENDC

#include	<P16F877A.INC>		  
#define	  BANCO0	bcf		  STATUS, RP0
#define	  BANCO1	bsf		  STATUS, RP0


			org 00h
			call		INICIO
			nop
			
			org			04h
			btfsc		INTCON, TMR0IF
			goto		INT_TMR0			; Interrupcion de TMR0
BUS_RX		btfsc		PIR1, RCIF
			goto		INT_RX
RET_INT		return

INT_RX		movfw		RCREG
			movwf		C_ANCHO_PWM
			bsf			INTCON, GIE
			goto		RET_INT

INT_TMR0	movlw		.216
			movwf		TMR0
			bcf			INTCON, TMR0IF
			bsf			INTCON, GIE
			movf		C_CICLO_PWM,W
			xorwf		C_ANCHO_PWM,0
			btfsc		STATUS,Z
			bcf			PORTC,0				; Si el ciclo actual es igual al ancho de pulso programado limpia la salida
			movf		C_CICLO_PWM,W
			xorwf		C_PERIODO_PWM,0
			btfss		STATUS,Z
			goto		INC_PWM
			call		REIN_PWM			 ; Si el ciclo actual es igual al periodo de señal programado, reinicia el ciclo
			goto		BUS_RX

INC_PWM		incf		C_CICLO_PWM,1
			goto		BUS_RX

INICIO		call		CONF_RX
			call		CFG_TMR0
			bsf			INTCON, GIE
			call		CICLO

CFG_TMR0	BANCO0
			movlw		.216
			movwf		TMR0
			movlw		.200
			movwf		C_PERIODO_PWM
			movlw		.30
			movwf		C_ANCHO_PWM
			BANCO1
			bcf			OPTION_REG,T0CS
			bcf			TRISC,0
			BANCO0
			call		REIN_PWM
			bsf			INTCON, TMR0IE
			return

CONF_RX		BANCO1
			movlw		.25
			movwf		SPBRG
			bcf			TXSTA, SYNC			; Habilitar comunicacion asincrona
			bsf			TXSTA, BRGH			; Habilitar seleccion de alta velocidad
			BANCO0
			bsf			RCSTA, SPEN			; Habilitar puerto serial
			bcf			RCSTA, RX9			; Deshabilitar recepcion de 9 bits
			bsf			RCSTA, CREN			; Habilitar el modulo de recepcion
			bsf			INTCON, PEIE		; Habilitar la interrupcion por eventos perifericos
			BANCO1
			bsf			PIE1, RCIE			; Habilitar la interrupcion por recepcion de USAR
			BANCO0
			bcf			PIR1, RCIF			; Limpiar la bandera de interrupcion por recepcion de USAR
			return

REIN_PWM	movlw		.1
			movwf		C_CICLO_PWM
			bsf			PORTC,0
			return

CICLO		nop
			goto		CICLO

			end
