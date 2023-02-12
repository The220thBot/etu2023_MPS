
; CSEG - внешняя память программы
; DSEG - резидентная память данных
; Пересылка массива констант (8 чисел) из CSEG в DSEG по адресам 20h-27h


; https://de.ifmo.ru/bk_netra/page.php?index=51&layer=1&tutindex=25
; MOV  - в DSEG
; MOVC - в CSEG
$mod52

	ORG 0h ; Начальный адрес программы (если нет прерываний)
START:
    MOV 	DPTR, #init ; #init == 20h
	MOV 	R0, #8
	MOV 	R1, #20h
LOOP:
	MOV 	A, #0
	MOVC 	A, @A+DPTR
	MOV 	@R1, A
	INC 	DPTR
	INC 	R1
	DJNZ 	R0,LOOP
	JMP 	START

	ORG 20h ; Начальный адрес объектного кода (в данном случае данные)
init:
	DB 31h,22h,0FEh,40h,0A5h,40h,71h,38h
	END
