			list		p = 16F877A
			#include	<P16F877A.INC>

__CONFIG	_CP_OFF&_WDT_OFF&_PWRTE_ON&_HS_OSC

#define		BANCO0	bcf		  STATUS, RP0
#define		BANCO1	bsf		  STATUS, RP0

cblock		20h
			C_PERIODO_PWM					; Indica el periodo de la señal PWM
			C_ANCHO_PWM						; Indica el ancho PWM programado en alto
			C_CICLO_PWM						; Indica el ciclo PWM actual
			C_TMR1H							; Byte de mayor peso de TMR1
			C_TMR1L							; Byte de menor peso de TMR1
			C_CCP1H							; Byte de mayor peso de CCP1
			C_CCP1L							; Byte de menor peso de CCP1
			C_CCP2H							; Byte de mayor peso de CCP2
			C_CCP2L							; Byte de menor peso de CCP2
			RX_INICIADA						; Indica el estado de la recepcion
			RX_TEMP
			RX_COM4							; Byte de peso 4 de comando recibido
			RX_COM3							; Byte de peso 3 de comando recibido
			RX_COM2							; Byte de peso 2 de comando recibido
			RX_COM1							; Byte de peso 1 de comando recibido
			RX_COM0							; Byte de peso 0 de comando recibido
			CCP1H_MAX						; Byte de mayor peso de valor maximo de CCP1
			CCP1L_MIN						; Byte de menor peso de valor maximo de CCP1
			CCP2H_MAX						; Byte de mayor peso de valor maximo de CCP2
			CCP2L_MIN						; Byte de menor peso de valor maximo de CCP2
			DATO1_1H						; Byte de mayor peso de entrada 1 de operaciones aritmeticas
			DATO1_1L						; Byte de menor peso de entrada 1 de operaciones aritmeticas
			DATO2_1H						; Byte de mayor peso de entrada 2 de operaciones aritmeticas
			DATO2_1L						; Byte de menor peso de entrada 2 de operaciones aritmeticas
			RESP1H							; Byte de mayor peso de resultado de operaciones aritmeticas
			RESP1L							; Byte de menor peso de resultado de operaciones aritmeticas
			C_BASE_PWM_H					; Base de configuracion PWM
			C_BASE_PWM_L					; Base de configuracion PWM
			C_INI_PWM1_H					; Valor inicial de posicion de motor 1
			C_INI_PWM1_L					; Valor inicial de posicion de motor 1
			C_INI_PWM2_H					; Valor inicial de posicion de motor 2
			C_INI_PWM2_L					; Valor inicial de posicion de motor 2
			TX_INICIADA						; Indica el estado de la transmision
			TX_TEMP
			TX_COM4							; Byte de peso 4 de comando a transmitir
			TX_COM3							; Byte de peso 3 de comando a transmitir
			TX_COM2							; Byte de peso 2 de comando a transmitir
			TX_COM1							; Byte de peso 1 de comando a transmitir
			TX_COM0							; Byte de peso 0 de comando a transmitir
			C_VLRMIN_CCP1_H					; Byte de mayor peso de posicion maxima parametrizada del motor 1
			C_VLRMIN_CCP1_L					; Byte de menorpeso de posicion maxima parametrizada del motor 1
			C_VLRMIN_CCP2_H					; Byte de mayor peso de posicion maxima parametrizada del motor 2
			C_VLRMIN_CCP2_L					; Byte de menorpeso de posicion maxima parametrizada del motor 2
			C_VLRMIN_H
			C_VLRMIN_L
endc

			org 00h
			call INICIO
			nop

			org 04h
			btfsc		PIR1, TMR1IF
			call		INT_TMR1
			btfsc		PIR1, CCP1IF
			call		INT_CCP1
			btfsc		PIR2, CCP2IF
			call		INT_CCP2
			btfsc		PIR1, TXIF
			call		INT_TX
			btfsc		PIR1, RCIF
			call		INT_RX
RET_INT		retfie

INT_TX		BANCO1
			movf		PIE1, W
			BANCO0
			movwf		TX_TEMP
			btfss		TX_TEMP, 4			; La interrupcion por transmision serial esta habilitada?
			goto		RET_PROC_TX			; No, retornar
			movlw		06h					; Si, continuar
			xorwf		TX_INICIADA, W
			btfsc		STATUS, Z			; La transmision ya fué terminada previamente?
			goto		DES_TX				; Si, evaluar si el buffer de TX esta vacio
			incf		TX_INICIADA, F
			movlw		06h
			xorwf		TX_INICIADA, W
			btfsc		STATUS, Z
			goto		DES_TX				; Rutina de deshabilitacion de transmision
			call		REG_TX
RET_PROC_TX	return

DES_TX		BANCO1
			movf		TXSTA, W
			BANCO0
			movwf		TX_TEMP
			btfsc		TX_TEMP, 1			; La transmision actual ya se terminó?
			goto		RET_PROC_TX			; No, retornar
			BANCO1
			bcf			TXSTA, TXEN
			BANCO0
			goto		RET_PROC_TX

INT_RX		movfw		RCREG
			movwf		RX_TEMP
			call		PROC_RX
			return

PROC_RX		movf		RX_INICIADA, F
			btfsc		STATUS, Z
			goto		NUEVA_RX
			goto		CONT_RX
RET_PROC_RX	return

NUEVA_RX	movlw		55h
			xorwf		RX_TEMP, W
			btfss		STATUS, Z
			goto		RESP_ERR_RX			; Respuesta erronea por transmision
CONT_RX		movlw		2Bh
			addwf		RX_INICIADA, W
			movwf		FSR
			movf		RX_TEMP, W
			movwf		INDF
			incf		RX_INICIADA, F
			movf		RX_INICIADA, W
			xorlw		05h
			btfsc		STATUS, Z			; Trama completa?
			goto		EJEC_RX				; Si
			goto		RET_PROC_RX			; No

RESP_ERR_RX	movlw		55h
			movwf		TX_COM4
			movlw		02h
			movwf		TX_COM3
			clrf		TX_COM2
			clrf		TX_COM1
			clrf		TX_COM0
			call		CONF_TX
			goto		RET_PROC_RX

CONF_TX		movlw		00h
			movwf		TX_INICIADA
			call		REG_TX				; Mover primer registro a transmitir
			BANCO1
			bsf			TXSTA, TXEN
			bsf			PIE1, TXIE
			BANCO0
			return

REG_TX		movlw		42h					; Transfiere el registro de envio para su transmision serial
			addwf		TX_INICIADA, W
			movwf		FSR
			movf		INDF, W
			movwf		TXREG
			return

EJEC_RX		clrf		RX_INICIADA			; Reiniciar variable
			bcf			PCLATH, 4
			bcf			PCLATH, 3
			decf		RX_COM3, W
			addwf		PCL, F				; Menu de comandos recibidos
			goto		CMDO_1				; Comando 1, cambiar valor de CCP1
			goto		CMDO_2				; Comando 2, solicitud de posicion de motor
			goto		CMDO_3				; Comando 3, solicitud de reinicio
			goto		CMDO_4				; Comando 4, calibracion de posicion de motor

CMDO_4		decf		RX_COM2, W
			addwf		PCL, F
			goto		LIM_MOTOR1			; Calibracion de motor 1
			goto		LIM_MOTOR2			; Calibracion de motor 2

LIM_MOTOR1	movf		RX_COM1, W
			movwf		C_VLRMIN_CCP1_H
			movf		RX_COM0, W
			movwf		C_VLRMIN_CCP1_L
			call		VLR_INI_CCP1
			call		SET_CCP1
			call		VLR_INI_CCP2
			call		SET_CCP2
			movlw		55h
			movwf		TX_COM4
			movlw		01h
			movwf		TX_COM3
			movf		RX_COM2, W
			movwf		TX_COM2
			clrf		TX_COM1
			clrf		TX_COM0
			call		CONF_TX
			goto		RET_PROC_RX

LIM_MOTOR2	movf		RX_COM1, W
			movwf		C_VLRMIN_CCP2_H
			movf		RX_COM0, W
			movwf		C_VLRMIN_CCP2_L
			call		VLR_INI_CCP1
			call		SET_CCP1
			call		VLR_INI_CCP2
			call		SET_CCP2
			movlw		55h
			movwf		TX_COM4
			movlw		01h
			movwf		TX_COM3
			movf		RX_COM2, W
			movwf		TX_COM2
			clrf		TX_COM1
			clrf		TX_COM0
			call		CONF_TX
			goto		RET_PROC_RX
			
CMDO_3		call		VLR_INI_CCP1
			call		SET_CCP1
			call		VLR_INI_CCP2
			call		SET_CCP2
			movlw		55h
			movf		TX_COM4
			movlw		01h
			movwf		TX_COM3
			clrf		TX_COM2
			clrf		TX_COM1
			clrf		TX_COM0
			call		CONF_TX
			goto		RET_PROC_RX

CMDO_2		decf		RX_COM2, W
			addwf		PCL, F				; Menu de seleccion de motor
			goto		POS_MOTOR1			; Motor 1
			goto		POS_MOTOR2			; Motor 2

POS_MOTOR1	movf		C_CCP1H, W			; Calcular el valor del ancho de pulso en relacion con la cifra base parametrizada
			movwf		DATO1_1H
			movf		C_CCP1L, W
			movwf		DATO1_1L
			movf		C_BASE_PWM_H, W
			movwf		DATO2_1H
			movf		C_BASE_PWM_L, W
			movwf		DATO2_1L
			call		RESTA16				; Restar la cifra base de control PWM del valor parametrizado para el ancho de pulso
			call		RESP_POS			; Enviar respuesta de posicion
			goto		RET_PROC_RX

RESP_POS	movlw		55h
			movwf		TX_COM4
			movlw		01h
			movwf		TX_COM3
			movf		RX_COM2, W
			movwf		TX_COM2
			movf		RESP1H, W
			movwf		TX_COM1
			movf		RESP1L, W
			movwf		TX_COM0
			call		CONF_TX
			return

POS_MOTOR2	movf		C_CCP2H, W			; Calcular el valor del ancho de pulso en relacion con la cifra base parametrizada
			movwf		DATO1_1H
			movf		C_CCP2L, W
			movwf		DATO1_1L
			movf		C_BASE_PWM_H, W
			movwf		DATO2_1H
			movf		C_BASE_PWM_L, W
			movwf		DATO2_1L
			call		RESTA16				; Restar la cifra base de control PWM del valor parametrizado para el ancho de pulso
			call		RESP_POS			; Enviar respuesta de posicion
			goto		RET_PROC_RX

CMDO_1		decf		RX_COM2, W
			addwf		PCL, F				; Menu de seleccion de motor
			goto		CMB_CCP1			; Motor 1, cambiar ancho de pulso
			goto		CMB_CCP2			; Motor 2, cambiar ancho de pulso

CMB_CCP1	movf		C_VLRMIN_CCP1_H, W
			movwf		C_VLRMIN_H
			movf		C_VLRMIN_CCP1_L, W
			movwf		C_VLRMIN_L
			call		VER_LIM
			xorlw		00h					; Valor invalido de posicion?
			btfsc		STATUS, Z
			goto		RES_ERR_POS
			movf		C_BASE_PWM_H, W
			movwf		DATO1_1H
			movf		C_BASE_PWM_L, W
			movwf		DATO1_1L
			movf		RX_COM1, W
			movwf		DATO2_1H
			movf		RX_COM0, W
			movwf		DATO2_1L
			call		SUMA16				; Sumar la cifra base de control PWM al valor recibido por el comando
			movf		RESP1H, W
			movwf		C_CCP1H
			movf		RESP1L, W
			movwf		C_CCP1L
			call		SET_CCP1
			call		ACK_CMD1
			goto		RET_PROC_RX

RES_ERR_POS	movlw		55h
			movwf		TX_COM4
			movlw		02h
			movwf		TX_COM3
			movf		RX_COM2, W
			movwf		TX_COM2
			clrf		TX_COM1
			clrf		TX_COM0
			call		CONF_TX
			goto		RET_PROC_RX

VER_LIM		movf		C_VLRMIN_H, W
			movwf		DATO1_1H
			movf		C_VLRMIN_L, W
			movwf		DATO1_1L
			movf		RX_COM1, W
			movwf		DATO2_1H
			movf		RX_COM0, W
			movwf		DATO2_1L
			call		RESTA16
			btfsc		STATUS, C			; Resultado negativo?
			retlw		01h					; No, indicar
			retlw		00h					; Si, indicar

ACK_CMD1	movlw		55h					; Armar la respuesta afirmativa
			movwf		TX_COM4
			movlw		01h
			movwf		TX_COM3
			movf		RX_COM2, W
			movwf		TX_COM2
			movf		RX_COM1, W
			movwf		TX_COM1
			movf		RX_COM0, W
			movwf		TX_COM0
			call		CONF_TX				; Configurar el envio de la respuesta
			return

CMB_CCP2	movf		C_VLRMIN_CCP2_H, W
			movwf		C_VLRMIN_H
			movf		C_VLRMIN_CCP2_L, W
			movwf		C_VLRMIN_L
			call		VER_LIM
			xorlw		00h					; Valor invalido de posicion?
			btfsc		STATUS, Z
			goto		RES_ERR_POS
			movf		C_BASE_PWM_H, W
			movwf		DATO1_1H
			movf		C_BASE_PWM_L, W
			movwf		DATO1_1L
			movf		RX_COM1, W
			movwf		DATO2_1H
			movf		RX_COM0, W
			movwf		DATO2_1L
			call		SUMA16				; Sumar la cifra base de control PWM al valor recibido por el comando
			movf		RESP1H, W
			movwf		C_CCP2H
			movf		RESP1L, W
			movwf		C_CCP2L
			call		SET_CCP2
			call		ACK_CMD1
			goto		RET_PROC_RX

INT_CCP2	bcf			PORTB, 1
			bcf			PIR2, CCP2IF
			return

INT_CCP1	bcf			PORTB, 0
			bcf			PIR1, CCP1IF
			return

INT_TMR1	call		SET_TMR1
			bcf			PIR1, TMR1IF
			movlw		b'00000011'
			movwf		PORTB
			return

INICIO		call		CONF_CONST
			call		CONF_RX
			call		CFG_CCP
			call		CFG_TMR1
			bsf			INTCON, GIE			; Habilitar las interrupciones
			call		CICLO

CONF_CONST	movlw		0DCh				; Configuracion inicial de constantes - 0DCh
			movwf		C_BASE_PWM_H
			movlw		0D5h				; 0D5h
			movwf		C_BASE_PWM_L
			movlw		000h
			movwf		C_INI_PWM1_H
			movlw		000h
			movwf		C_INI_PWM1_L
			movlw		000h
			movwf		C_INI_PWM2_H
			movlw		000h
			movwf		C_INI_PWM2_L
			movlw		03h
			movwf		C_VLRMIN_CCP1_H
			movlw		0E8h
			movwf		C_VLRMIN_CCP1_L
			movlw		03h
			movwf		C_VLRMIN_CCP2_H
			movlw		0E8h
			movwf		C_VLRMIN_CCP2_L
			return

CONF_RX		clrf		RX_INICIADA			; Iniciar variable
			BANCO1
			movlw		.25					; Comunicacion a 9600bps
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

CFG_CCP		call		VLR_INI_CCP1
			call		SET_CCP1			; Configurar valor de control de CCP1
			call		VLR_INI_CCP2
			call		SET_CCP2			; Configurar valor de control de CCP2
			BANCO1
			bsf			PIE1, CCP1IE		; Habilitar interrupcion por CCP1 - PIR1<CCP1IF>
			bsf			PIE2, CCP2IE		; Habilitar interrupcion por CCP2 - PIR2<CCP2IF>
			BANCO0
			movlw		b'00001010'			; Configuracion CCP1
			movwf		CCP1CON
			movlw		b'00001010'			; Configuracion CCP2
			movwf		CCP2CON
			bsf			INTCON, PEIE
			return

VLR_INI_CCP1 movf		C_BASE_PWM_H, W
			movwf		DATO1_1H
			movf		C_BASE_PWM_L, W
			movwf		DATO1_1L
			movf		C_INI_PWM1_H, W
			movwf		DATO2_1H
			movf		C_INI_PWM1_L, W
			movwf		DATO2_1L
			call		SUMA16				; Sumar la cifra base de control PWM al valor inicial de ancho de pulso 1 programado
			movf		RESP1H, W
			movwf		C_CCP1H
			movf		RESP1L, W
			movwf		C_CCP1L
			return

VLR_INI_CCP2 movf		C_BASE_PWM_H, W
			movwf		DATO1_1H
			movf		C_BASE_PWM_L, W
			movwf		DATO1_1L
			movf		C_INI_PWM2_H, W
			movwf		DATO2_1H
			movf		C_INI_PWM2_L, W
			movwf		DATO2_1L
			call		SUMA16				; Sumar la cifra base de control PWM al valor inicial de ancho de pulso 2 programado
			movf		RESP1H, W
			movwf		C_CCP2H
			movf		RESP1L, W
			movwf		C_CCP2L
			return

SET_CCP1 	movf		C_CCP1L, W
			movwf		CCPR1L
			movf		C_CCP1H, W
			movwf		CCPR1H
			return

SET_CCP2	movf		C_CCP2L, W
			movwf		CCPR2L
			movf		C_CCP2H, W
			movwf		CCPR2H
			return

CFG_TMR1  	movlw		0D8h
			movwf		C_TMR1H
			movlw		0F0h
			movwf		C_TMR1L
			call		SET_TMR1
			bcf			T1CON, T1CKPS1		; Preescala de 1
			bcf			T1CON, T1CKPS0		; Preescala de 1
			bcf			T1CON, TMR1CS		; Fuente de reloj interna
			BANCO1
			bsf			PIE1, TMR1IE		; Habilitar interrupcion por TMR1 - TMR1IF
			bcf			TRISB, 0			; Pin RB0 en modo salida
			bcf			TRISB, 1			; Pin RB1 en modo salida
			BANCO0
			bsf			INTCON, PEIE		; Habilitar interrupcion por perifericos
			movlw		b'00000011'
			movwf		PORTB
			bsf			T1CON,TMR1ON		; Habilitar TMR1
			return

SET_TMR1 	movf		C_TMR1L, W
			movwf		TMR1L
			movf		C_TMR1H, W
			movwf		TMR1H
			return

CICLO		nop
		  	goto		CICLO

; ******************************************************
;					FUNCIONES DE APOYO
; ******************************************************

;******************************
; 	SUMA EN 16 BITS
;******************************
SUMA16		movf		DATO1_1L, W
			addwf		DATO2_1L, W
			movwf		RESP1L
			btfsc		STATUS, C
			goto		ETI1
			movf		DATO1_1H, W
ETI2		addwf		DATO2_1H, W
			movwf		RESP1H
			return

ETI1		incf		DATO1_1H,W
			goto		ETI2

;******************************
; 	RESTA EN 16 BITS
;******************************
RESTA16		movf		DATO2_1L, W
			subwf		DATO1_1L, W
			movwf		RESP1L
			btfss		STATUS, C
			goto		ETI9
			movf		DATO2_1H, W
ETI10		subwf		DATO1_1H, W
			movwf		RESP1H
			return

ETI9		incf		DATO2_1H, W
			goto		ETI10

			end
