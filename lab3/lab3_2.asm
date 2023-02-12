$MOD52

ORG 0h

MAIN:
    MOV A, #0h
    MOV TMOD, #06h
    MOV TCON, #10h
    MOV TH0, #0F8h
    MOV TL0, #0F8h

LOOP:
    MOV A, TL0
    MOV P1, A
    SJMP LOOP

END