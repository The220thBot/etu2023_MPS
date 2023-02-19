; SERIAL I/0 WITH INTERRUPTS
; V= fг/(12*(100h-E8h)*16)=11059200/(12*16*24)=11059200/4608=2400 1/c 

$mod52

ORG 0
    JMP INIT

ORG 23h
    JMP INTERRUPT

; прерывания serial port
INTERRUPT:
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


; настройка программы
INIT:
    ; установка таймера 1 в режим 2 (8b с перезагрузкой)
    MOV TMOD, #00100000b 

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

    MOV A, #0h
    MOVX @DPTR, A
    CLR A

    ; запускаем таймер 1
    SETB TR1
    
    ; устанавливаем возможность прерывания в целом и прерывания serial port TI или RI
    MOV IE, #10010000b


; вечный цикл
LOOP:
    JMP LOOP

END
