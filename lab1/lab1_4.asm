
; DSEG - резидентная память данных
; Пересылка DPH, DPL, TH0, TL0, TH1, TL1 в DSEG (банк 3) по адресам 18h-1Dh (18, 19, 1A, 1B, 1C, 1D)

; PSW.3 (RS0)   PSW.4 (RS1)    Банк
;    0               0          0   00H-07H
;    1               0          1   08H-0FH
;    0               1          2   10H-17H
;    1               1          3   18H-1FH

$mod52

    ORG 0h ; Начальный адрес программы (если нет прерываний)
START:

    CLR PSW.3
    CLR PSW.4 ; Банк 0

    MOV R2, #037h
    MOV R3, #053h
    MOV R4, #0F4h
    LCALL DEVIDER ; expected 3Ah

    KEKE:
    JMP KEKE

; https://what-when-how.com/8051-microcontroller/8051-call-instructions/
ADDER:
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

DEVIDER:
    ; Целочисленное деление R2R3 на R4 в R5
    ; R3 - это младший разряд
    ; R5 и A меняются после вызова процедуры
    PUSH 0 ; R0
    PUSH 1 ; R1

    MOV R0, #0h
    MOV R1, #0h
    MOV R5, #0h

    CLR PSW.7 ; C - carry flag
    DEVIDER_LOOP:
        INC R5

        MOV A, R0     ; плюсуем к R1R0 R4
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
        JZ DEVIDER_END

        DEVIDER_END:
        DEC R5

    POP 1 ; R1
    POP 0 ; R0
    RET

DEVIDER2:
    ; Целочисленное деление R2R3 на R4 в R5
    ; R3 - это младший разряд
    ; R5 и A меняются после вызова процедуры
    PUSH 0 ; R0
    PUSH 1 ; R1

    MOV A, R3
    MOV R0, A
    MOV A, R2
    MOV R1, A
    MOV R5, #0h

    CLR PSW.7 ; C - carry flag
    DEVIDER_LOOP1:
        INC R5

        MOV A, R0
        SUBB A, R4
        MOV R0, A

        JNC DEVIDER_LOOP1

        MOV A, R1
        JZ DEVIDER_END
        SUBB A, #0h
        MOV R1, A

        JNZ DEVIDER_LOOP1

        DEVIDER_END1:
        DEC R5
        DEC R5

    POP 1 ; R1
    POP 0 ; R0
    RET
END













