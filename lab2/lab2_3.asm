$mod52

ORG 0h

MAIN:
    MOV C,P0.0
    ANL C,/P0.1
    
    MOV 0E0H, C
    
    MOV C,P0.3
    ANL C,/P0.2

    ORL C, 0E0H

    JC RESULT1
    JMP RESULT0

RESULT1:
    MOV P1, #0FFh
    JMP FINAL

RESULT0:
    MOV P1, #0h

FINAL:
    JMP MAIN

END