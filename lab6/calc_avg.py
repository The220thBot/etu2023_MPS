# -*- coding: utf-8 -*-

def f(a):
    return int(a, 16)

if __name__ == "__main__":
    with open("ADCDATA.ADC", 'r', encoding="utf-8") as temp:
            S = temp.read()
    a = list(map(f, S.split()))
    S = sum(a)
    print(f"sum (hex): {hex(S)}")
    print(f"sum      : {S}")
    print(f"avg (hex): {hex(S//len(a))}")
    print(f"avg      : {round(S/len(a), 2)}")
