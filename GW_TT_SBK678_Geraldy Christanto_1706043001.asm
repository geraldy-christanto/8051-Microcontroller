; Geraldy Christanto
; 1706043001
; 8A - Praktikum Sistem Berbasis Komputer


;LED 		> P2

ORG 0H			;Program dimulai dari alamat memori 0H
	PWMOUTPUT	EQU P0.0
 	PWM_FLAG 	EQU 0

MAIN:
	MOV TMOD,#00H 		; Timer0 dan Timer1 diset menjadi Mode 0
	SETB EA 		; Enable Interrupts
        SETB ET0 		; Enable Timer 0 Interrupt
        SETB ET1 		; Enable Timer 1 Interrupt
	ACALL ON		;Memanggil subrutin ON
	ACALL OFF		;Memanggil subrutin OFF
	JMP MAIN		;Looping main program

ON:    			;Subrutin ON untuk menyalakan LED dari tengah terlebih dahulu kemudian merambat ke pin sebelahnya
			;hingga semua pin menyala
	MOV P2, #0FFH	;Mengisi P2 dengan nilai FFH
	ACALL DELAY	;Memanggil sub-rutin delay untuk waktu menyalakan LED selama satu detik
	CLR P2.4	;Menyalakan P2.4 dan P2.3 (tengah) selama satu detik
	CLR P2.3
	ACALL PWM1
	ACALL DELAY
	CLR P2.2	;Menyalakan P2.5 dan P2.2 selama satu detik dengan LED tengah tetap menyala
	CLR P2.5
	ACALL PWM2
	ACALL DELAY
	CLR P2.1	;Menyalakan P2.6 dan P2.1 selama satu detik dengan LED sebelumnya tetap menyala
	CLR P2.6
	ACALL PWM3
	ACALL DELAY
	CLR P2.0	;Menyalakan P2.7 dan P2.0 selama satu detik dengan LED sebelumnya tetap menyala
	CLR P2.7
	ACALL PWM4
	ACALL DELAY	;Semua LED Menyala
	RET		;Kembali ke main program

OFF:    		;Subrutin OFF untuk mematikan LED dari pinggir ke tengah secara bergantian hingga seluruh LED mati setiap satu detik
	ACALL DELAY
	SETB P2.0	;Mematikan LED pada P2.0 dan P2.7
	SETB P2.7
	ACALL PWM4
	ACALL DELAY	;Delay satu detik untuk lanjut ke line berikutnya
	SETB P2.1	;Mematikan LED pada P2.1 dan P2.6
	SETB P2.6
	ACALL PWM3
	ACALL DELAY
	SETB P2.2	;Mematikan LED pada P2.2 dan P2.5
	SETB P2.5
	ACALL PWM2
	ACALL DELAY
	SETB P2.3	;Mematikan LED pada P2.3 dan P2.4
	SETB P2.4
	ACALL PWM1
	ACALL DELAY
	RET		;Kembali ke main program

DELAY:			;Fungsi delay selama satu detik menggunakan inner loop
	MOV R2, #7
TUNGGU:	MOV R1, #255
TUNGGU1:MOV R0, #255
TUNGGU2:DJNZ R0, TUNGGU2
	DJNZ R1, TUNGGU1
	DJNZ R2, TUNGGU
	RET

;PWM untuk mengatur intensitas cahaya
PWM1:			;PWM untuk LED P2.3 dan P2.4 (Paling redup)
	MOV A, #254
	MOV R3, A
	SETB TR0
	RET
PWM2:			;PWM untuk LED P2.2 dan P2.5
	MOV A, #150
	MOV R4, A
	SETB TR1
	RET

PWM3:	MOV A, #60	;PWM untuk LED P2.1 dan P2.6
	MOV R5, A
	SETB TR0
	RET

PWM4:	MOV A, #0	;PWM untuk LED P2.0 dan P2.7 (Paling terang)
	MOV R6, A
	SETB TR1
	RET

; TIMER 0 ROUTINE
T0INTERRUPT:
	JB PWM_FLAG, HIGH_DONE		; Jika PWM_FLAG0 diset jump ke high_done

LOW_DONE:
	SETB PWM_FLAG		; Set PWM_FLAG=1 memulai bagian high
        CLR PWMOUTPUT		; Membuat PWM output bernilai High
        MOV TH0, R7		; Load high byte dari timer dengan R7 (mengatur nilai pulse width)
        CLR TF0			; Clear Timer 0 interrupt flag
RETI				; kembali ke fungsi interrupt

HIGH_DONE:
        CLR PWM_FLAG		; Clear PWM_FLAG=0 memulai bagian low
        SETB PWMOUTPUT		; Membuat PWM output bernilai low
        MOV A, #0FFH		; Mengisi A menjadi FFh atau 255
        CLR C			; Clear C (carry bit) agar tidak mempengaruhi nilai c
        SUBB A, R7		; A = 255 - R7.
        MOV TH0, A		; Nilai TH0 + R7 = 255
        CLR TF0			; Clear Timer 0 interrupt flag
RETI				; kembali ke fungsi interrupt

PWM_STOP0:
        CLR TR0			; Menghentikan timer untuk menghentikan PWM
RET
END