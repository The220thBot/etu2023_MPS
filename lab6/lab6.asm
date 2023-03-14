; среднее в примере - 63h
; работаем с младшими 2 байтами в записи ADCDATA 0011, где 11 - то, с чем работаем :)

; Если x_cp >= Q_max,        то P1:11b
; Если Q_min < x_cp < Q_max, то P1:10b
; Если x_cp <= Q_min,        то P1:00b

$MOD812

ORG	0h
	JMP		MAIN

ORG	0033h	; прерывание по концу работы АЦП
	JMP 	ADCINT

MAIN:
	MOV		ADCCON1, #62h	; 01100010b == нормальный, от таймера 2
	MOV		ADCCON2, #00h	; 00000000b == 0 канал (последние 3 бита)
	MOV		RCAP2L, #0A4h   ; В регистры RCAP2H и
                            ; RCAP2L записываются данные для загрузки в регистры счетчика TH2 и TL2
	MOV		RCAP2H, #0FFh
	MOV		TL2, #0A4h		; обнуляем счетчик 2
	MOV		TH2, #0FFh		; то, что будет загружаться в TL2 при перезаполнении
	MOV		10h, #10h		; кол-во чисел (+1, т.к. DJNZ "упустит" последнее число)
	MOV		IE, #0C0h		; 11000000b == вкл + от АЦП вкл
	SETB	TR2				; старт для таймера 2
	MOV		DPH, #0h
	MOV		DPL, #0h
	MOV		P1, #10010000b

	; ниже просто записываем Q_min и Q_max в External Memory. Или это тоже надо как-то через АЦП вход?
	MOV		DPL, #70h
	MOV		A, #50h		; q_min tyt
	MOVX	@DPTR, A
	MOV		DPL, #71h
	MOV		A, #70h		; q_max tyt
	MOVX	@DPTR, A
	CLR		A

LOOP:
	JMP		LOOP

ADCINT:
	DJNZ	10h, NEXT	; считываем все 15 чисел по одному на прерывание, записываем в External Memory
	CLR		TR2			; стопаем таймер
	JMP	LAB1_4			; выполняем алгоритм из лаб1_4

NEXT:
	PUSH	ACC
	PUSH	DPH
	PUSH	DPL			; сохраняем текущий DPTR
	MOV		DPH, #0h
	MOV		DPL, #0h	; в нулевой ячейке держим кол-во чисел в памяти
	MOVX	A, @DPTR	; берем из нулевой ячейки значение
	INC		A
	MOVX	@DPTR,A		; +1 записываем обратно
	MOV		DPL, A		; дальше записываем число в "массив"
	MOV		A, #0h
	MOVX	@DPTR,A
	MOV		A, ADCDATAL
	MOVX	@DPTR,A
	POP		DPL
	POP		DPH
	POP		ACC
	RETI

LAB1_4:
	; сохраняем состояния регистров до работы
	PUSH	0
	PUSH	1
	PUSH	2
	PUSH	3
	PUSH	4
	PUSH	5
	PUSH	6
	PUSH	ACC
	PUSH	PSW
	PUSH	DPH
	PUSH	DPL

	MOV		DPH, #0h
	MOV		DPL, #0h

	; ниже работа 1 пункт 4, добавлено только получение кол-ва чисел, диапазон из External Memory
	MOVX A, @DPTR
	MOV R0, A
	INC	DPTR
    MOV R2, #0h
    MOV R3, #0h

	MAIN_LOOP:
        MOVX A, @DPTR
        INC DPTR

        MOV R4, A

        LCALL F_ADDER
        MOV A, R5
        MOV R2, A
        MOV A, R6
        MOV R3, A

        DJNZ R0, MAIN_LOOP

	MOV	DPH, #0h
	MOV	DPL, #0h	; в нулевой ячейке держим кол-во чисел в памяти
	MOVX A, @DPTR
    MOV R4, A ; кол-во чисел
    LCALL F_DEVIDER ; В R5 среднее значение, в R6 есть ли остаток

	MOV DPL, #70h
    MOVX A, @DPTR; Q_MIN
    MOV R0, A
    INC DPTR
    MOVX A, @DPTR; Q_MAX
    MOV R1, A

    MOV  A, R5
    SUBB A, R1
    JNC MAIN_P11 ; R5 >= R1    <->    x_ср >= Q_max

    CLR PSW.7 ; C - carry flag
    MOV  A, R0
    SUBB A, R5
    JC MAIN_P10  ; R0 < R5     <->    Q_min < x_ср

    ; То что ниже, это для   x_ср <= Q_min
    ;   mod   Q_min==x_cp   P
    ;    0         0       00
    ;    0         1       00
    ;    1         0       00
    ;    1         1       10
    CLR PSW.7 ; C - carry flag
    MOV A, R0
    SUBB A, R5
    JNZ MAIN_P00 ; R0 != R5 <-> Q_min != x_cp

    MOV A, R6
    JZ  MAIN_P00  ; mod == 0
    JNZ MAIN_P10 ; mod != 0


    MAIN_P11:
    MOV P1, #3h
    JMP KEKE

    MAIN_P10:
    MOV P1, #2h
    JMP KEKE

    MAIN_P00:
    MOV P1, #0h
    JMP KEKE

    KEKE:
	POP	DPL
	POP	DPH
	POP	PSW
	POP	ACC
	POP	6
	POP	5
	POP	4
	POP	3
	POP	2
	POP	1
	POP	0
    RETI

; https://what-when-how.com/8051-microcontroller/8051-call-instructions/
F_ADDER:
    ; Складывает R2R3 и R4 в R5R6
    ; R3 и R6 - это младшие разряды
    ; R5, R6 и A меняются после вызова процедуры

    CLR PSW.7 ; C - carry flag

    MOV A, R4
    ADD A, R3
    MOV R6, A

    MOV A, R2
    ADDC A, #0h
    MOV R5, A

    RET

; HE nPOWE 6blJlO YMHO)l(uTb Q_min u Q_max HA 10?!?!
F_DEVIDER:
    ; Целочисленное деление R2R3 на R4 в R5
    ;             Если остаток от деления равен 0, то R6=0
    ; R3 - это младший разряд
    ; R5, R6 и A меняются после вызова процедуры
    PUSH 0 ; R0
    PUSH 1 ; R1

    MOV R0, #0h
    MOV R1, #0h
    MOV R5, #0h
    MOV R6, #0h

    CLR PSW.7 ; C - carry flag
    DEVIDER_LOOP:
        INC R5

        ; плюсуем к R1R0 R4
        MOV A, R0
        ADD A, R4
        MOV R0, A
        MOV A, R1
        ADDC A, #0h
        MOV R1, A

        ; Сравниваем R2R3 и R1R0
        MOV A, R2
        SUBB A, R1

        JC DEVIDER_END
        JNZ DEVIDER_LOOP

        MOV A, R3
        SUBB A, R0

        JC DEVIDER_END
        JNZ DEVIDER_LOOP
        ; JZ DEVIDER_END
        INC R5
        DEC R6

        DEVIDER_END:
        DEC R5
        INC R6

    POP 1 ; R1
    POP 0 ; R0
    RET

END
