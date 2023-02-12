$mod52

ORG 0h

MAIN:

    MOV C,P0.1
    CPL C
    ANL C,P0.0
    
    MOV A.0,C
    
    MOV C,P0.2
    CPL C
    ANL C,P0.3

    ORL C,A.0

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