$mod52

; В этой лабораторной реализовано быстрое деление (через DIV AB)

ORG 0h

	ARR EQU 10h
	MAX EQU 20h
	MIN EQU 30h
START:
	MOV R0, #0  ; //
	MOV R1, #0  ; %
	MOV R2, #10 ; Счётчик
	MOV DPTR, #ARR

	CLR C
	
LOOP:
	MOVX A, @DPTR

	MOV B, #0Ah

	DIV AB

	; Сумма усредненных значений
	ADD A, R0
	MOV R0, A
	MOV A, B
	ADD A, R1
	MOV R1, A
	
	INC DPTR
	DJNZ R2, LOOP

	MOV A, R1
	MOV B, #0Ah

	DIV AB ; Для остатка
	
	ADD A, R0
	MOV R0, A
	MOV R1, B

	; Если целая часть >= MAX, то больше
	MOV DPTR, #MAX
	MOVX A, @DPTR
	MOV R2, A
	MOV A, R0
	CLR C
	SUBB A, R2
	JNC GREATER

	; Если целая часть меньше или равна+ненулевой остаток, то меньше
	MOV DPTR, #MIN
	MOVX A, @DPTR
	CLR C
	SUBB A, R0
	JNZ TESTNE

	MOV A, R1
	JZ LOWER

	JMP NORM

	

TESTNE:
	MOV DPTR, #MIN
	MOVx A, @DPTR
	CLR C
	SUBB A, R0
	JNC LOWER
	JMP NORM

LOWER:
	MOV R2,#00h
	JMP RES
GREATER:
	MOV R2,#11h
	JMP RES
NORM:
	MOV R2,#10h
	JMP RES
RES:
	MOV P1, R2
	JMP START

END
