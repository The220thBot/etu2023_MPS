
; CSEG - внешняя память программы
; DSEG - резидентная память данных
; Из CSEG получить 10 чисел (их сумма может быть больше, чем 255). Найти их среднее x_ср.
; Из CSEG получить Q_min и Q_max.
; Если x_cp >= Q_max,        то P1:11b
; Если Q_min < x_cp < Q_max, то P1:10b
; Если x_cp <= Q_min,        то P1:00b

; PSW.3 (RS0)   PSW.4 (RS1)    Банк
;    0               0          0   00H-07H
;    1               0          1   08H-0FH
;    0               1          2   10H-17H
;    1               1          3   18H-1FH

$mod52

ORG 0h ; Начальный адрес программы (если нет прерываний)
MAIN:

    CLR PSW.3
    CLR PSW.4 ; Банк 0

    MOV DPTR, #DATAS
    MOV R0, #0Ah ; 10 эл. в массиве
    MOV R2, #0h
    MOV R3, #0h

    MAIN_LOOP:
        MOV A, #0h
        MOVC A, @A+DPTR
        INC DPTR

        MOV R4, A

        LCALL F_ADDER
        MOV A, R5
        MOV R2, A
        MOV A, R6
        MOV R3, A

        DJNZ R0, MAIN_LOOP

    MOV R4, #0Ah ; 10 эл. в массиве
    LCALL F_DEVIDER ; В R5 среднее значение, в R6 есть ли остаток

    MOV A, #0h
    MOVC A, @A+DPTR; Q_MIN
    MOV R0, A
    INC DPTR
    MOV A, #0h
    MOVC A, @A+DPTR; Q_MAX
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
    JMP KEKE

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

DATAS:
                  ; Массив из 10 чисел                        |        Q_min   |   Q_max
    DB 31h, 22h, 0FEh, 40h, 0A5h, 38h, 71h, 1h, 0FFh, 0h,               50h,        70h
    ; 0x31 + 0x22 + 0xFE + 0x40 + 0xA5 + 0x38 + 0x71 + 0x1 + 0xFF + 0x0

END













