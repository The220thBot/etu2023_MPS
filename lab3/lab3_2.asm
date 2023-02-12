$MOD52

org 0h

MAIN:
    mov A, #0h
    mov TMOD, #86h ; gate - 1
    mov TCON, #10h
    mov TH0, #0F8h
    mov TL0, #0F8h
LOOP:
    mov A, TL0
    mov P1, A
    sjmp LOOP
end