
; CSEG - внешняя память программы
; DSEG - резидентная память данных
; Пересылка DPH, DPL, TH0, TL0, TH1, TL1 в DSEG (банк 3) по адресам 18h-1Dh (18, 19, 1A, 1B, 1C, 1D)

; PSW.3 (RS0)   PSW.4 (RS1)    Банк
;    0               0          0   00H-07H
;    1               0          1   08H-0FH
;    0               1          2   10H-17H
;    1               1          3   18H-1FH

$mod52

    ORG 0h ; Начальный адрес программы (если нет прерываний)

OUT_REGS:
    PUSH 0
    SETB PSW.3
    CLR PSW.4
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
    RETI