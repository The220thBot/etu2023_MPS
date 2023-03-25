$MOD812

; Пункт 1, реализуем функцию x_1 & !x_2 | !x_3 & x_4
SENSOR_X1 EQU P0.0
SENSOR_X2 EQU P0.1
SENSOR_X3 EQU P0.2
SENSOR_X4 EQU P0.3

SENSOR_OUT EQU P0.4

; Пункт 2
LAMPOCHKA_OUT EQU P1
CURRENT_LAMPOCHKA EQU 31h

; Пункт 5
Q_MIN EQU 50h
Q_MIN_ADDR EQU 70h
Q_MAX EQU 70h
Q_MAX_ADDR EQU 71h
HEAT EQU 00h
COOL EQU 3h
NOTHING_TO_DO EQU 2h

; СТОП/РЕСЕТ
STOP_BIT EQU P0.5
RESET_BIT EQU P0.4

ORG	0h
    JMP INIT

ORG	0003h   ; INT0 for LAMPOCHKA_OUT
	JMP INT0_HANDLE_LAB4

ORG	000Bh   ; Timer 0 for LAMPOCHKA_OUT
	JMP TF0_HANDLE_LAB4

ORG 0023h
    JMP INTERRUPT_LAB5

ORG	0033h	; прерывание по концу работы АЦП, пункт 5
	JMP ADCINT

INIT:
    INIT_LAB5:
        ; установка таймера 1 в режим 2 (8b с перезагрузкой)
        MOV TMOD, #00100001b 

        ; точно НЕ запускаем таймер 1
        CLR TR1 
        CLR TF1

        ; установка timer1 на скорость 2400 бод
        MOV TL1, #0E8h
        MOV TH1, #0E8h

        ; скорость 2400 бод
        MOV PCON, #10000000b

        ; настройка serial порта (ri и ti очищены)
        MOV SCON, #01010000b

        MOV DPTR, #0h
        CLR A

        ; запускаем таймер 1
        SETB TR1
        
        ; устанавливаем возможность прерывания в целом и прерывания serial port TI или RI
        ; T/C0 по TF0 (переполнение) + INT0 (последние 2 бита)
        MOV IE, #11010011b

    INIT_LAB4:
        ; Пункт 2
        MOV TL0, #0h            ; обнуляем счетчик
        MOV TH0, #0FFh          ; то, что будет загружаться в TL0 при перезаполнении
        MOV TCON, #01010001b    ; работа таймера + по срезу смотрим INT0
                                ; если 00010000b? то когда INT0 = 0, обрабатываем прерывание пока это так

        MOV LAMPOCHKA_OUT, #80h
        MOV CURRENT_LAMPOCHKA, #80h

    INIT_LAB6:
        MOV		ADCCON1, #62h	; 01100010b == нормальный, от таймера 2
        MOV		ADCCON2, #00h	; 00000000b == 0 канал (последние 3 бита)
        MOV		RCAP2L, #0A4h   ; В регистры RCAP2H и
                                ; RCAP2L записываются данные для загрузки в регистры счетчика TH2 и TL2
        MOV		RCAP2H, #0FFh
        MOV		TL2, #0A4h		; обнуляем счетчик 2
        MOV		TH2, #0FFh		; то, что будет загружаться в TL2 при перезаполнении
        MOV		10h, #10h		; кол-во чисел (+1, т.к. DJNZ "упустит" последнее число)
        SETB	TR2				; старт для таймера 2
        MOV		DPH, #0h
        MOV		DPL, #0h

        ; ниже просто записываем Q_min и Q_max в External Memory. Или это тоже надо как-то через АЦП вход?
        MOV		DPL, #Q_MIN_ADDR
        MOV		A, #Q_MIN		; q_min tyt
        MOVX	@DPTR, A
        MOV		DPL, #Q_MAX_ADDR
        MOV		A, #Q_MAX		; q_max tyt
        MOVX	@DPTR, A
	    CLR		A

MAIN:
    SENSOR_PROCESS_OPTION1:
        LCALL OUT_REGS_LAB1
        MOV C, SENSOR_X1 ; пересылка бита в перенос
        ANL C, /SENSOR_X2 ; логическое И инверсии бита и переноса
        
        MOV 0E0H, C ; пересылка переноса в бит аккумулятора
        
        MOV C,SENSOR_X4 ; пересылка бита в перенос
        ANL C,/SENSOR_X3 ; логическое И инверсии бита и переноса

        ORL C, 0E0H ; логическое ИЛИ бита и переноса

        JC SENSORS_RESULT1    ; переход, если перенос равен единице. 
                                ; Если там 0, то и сбрасывать не надо, верно?)
        JMP SENSORS_RESULT0

SENSORS_RESULT0:
    CLR SENSOR_OUT
    JMP MAIN

SENSORS_RESULT1:
    SETB SENSOR_OUT
    JMP MAIN

ORG 00B9h

OUT_REGS_LAB1:
    PUSH 0

    MOV R0, #18h   ; Банк 0

    MOV @R0, DPH
    INC R0
    MOV @R0, DPL
    INC R0
    MOV @R0, TH0
    INC R0
    MOV @R0, TL0
    INC R0
    MOV @R0, TH1
    INC R0
    MOV @R0, TL1
    INC R0

    POP 0
    RET

INT0_HANDLE_LAB4:
    MOV LAMPOCHKA_OUT, #055h
    RETI

TF0_HANDLE_LAB4:
    PUSH ACC                ; сохраняем значение аккумулятора
    CLR TR0                 ; остановка таймера
    
    ; сдвиг вправо
    MOV A, CURRENT_LAMPOCHKA
    RR A 
    MOV CURRENT_LAMPOCHKA, A 
    MOV LAMPOCHKA_OUT, A

    mov TL0, #0h            ; обнуляем счетчик
    mov TH0, #0FFh          ; то, что будет загружаться в TL0 при перезаполнении
    SETB TR0                ; восстанавливаем работу таймера
    POP ACC                 ; восстанавливаем значение аккумулятора до обработки прерывания
    RETI

ORG 0170h

; прерывания serial port
INTERRUPT_LAB5:
    ; сохраняем контекст и флаги
    PUSH PSW

    ; проверяем готовность устройств
    JNB P3.4, DONE
    JNB P3.5, DONE

    ; если триггернулись не по RI проверяем TI
    JNB RI, OUTPUT

INPUT:
    ; пересылаем данные в память
    MOVX A, @DPTR
    INC A
    MOVX @DPTR, A
    MOV DPL, A
    MOV A, SBUF
    ;MOV SBUF, A
    MOVX @DPTR, A
    MOV DPL, #0h
    CLR A
    
    ; очищаем флаг прерывания RI
    CLR RI

OUTPUT:
    ; если нет TI выходим
    JNB TI, DONE

    MOVX A, @DPTR
    MOV R0, A
    MOV DPTR, #1h

; цикл для вывода данных
OUTPUT_ROUTINE:
    MOV A, #0
    MOVX A, @DPTR
	MOV SBUF, A
	INC DPTR
	DJNZ R0, OUTPUT_ROUTINE


    MOV R0, 0
    CLR A
    MOV DPTR, #0000H

    ; очищаем флаг прерывания RI
    CLR TI
    
DONE:
    ; восстанавливаем флаги и возврат
    POP PSW
    RETI

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

ORG 0205h

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
    MOV P2, #COOL
    JMP KEKE

    MAIN_P10:
    MOV P2, #NOTHING_TO_DO
    JMP KEKE

    MAIN_P00:
    MOV P2, #HEAT
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

    SETB TR2
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

END_STOP:
    END