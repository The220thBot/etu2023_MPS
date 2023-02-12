$mod52

ORG 0h ; Начальный адрес программы (если нет прерываний)
    JMP INIT

ORG	0003h ; Обработка INT0
	JMP INT0_HANDLE

ORG	000Bh ; Обработка переполнения счетчика по TF0
	JMP TF0_HANDLE

INIT:
    MOV P1, #0
    MOV IE, #10000011b; T/C0 по TF0 (переполнение) + INT0
    MOV TL0, #0h            ; обнуляем счетчик
	MOV TH0, #0FFh          ; то, что будет загружаться в TL0 при перезаполнении
    MOV TMOD, #00000001b
	MOV TCON, #00010001b    ; работа таймера + по срезу смотрим INT0
                            ; если 00010000b? то когда INT0 = 0, обрабатываем прерывание пока это так

    mov IP, #00000001b	; приоритет INT0 > TF0
	;mov IP, #00000000b	; приоритет INT0 = TF0
	;mov IP, #00000010b	; приоритет INT0 < TF0

LOOP:
    JMP LOOP

INT0_HANDLE:
    MOV P1, #055h
    RETI

TF0_HANDLE:
    CLR TR0                 ; остановка таймера
    MOV P1, #011h

TF_LOOP:
    JMP TF_LOOP
    RETI

END