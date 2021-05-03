.INCLUDE <m328pdef.inc>

.def AUX   = R16        ;R16 = AUX
.equ BOTAO1 = PB3        ;BOTAO1
.equ BOTAO2 = PB4        ;BOTAO2

setup:
    LDI  AUX,0b11111111 ;habilita os LEDs
    OUT  DDRD,AUX
    LDI  AUX,0b11111111
    OUT  PORTD,AUX
    LDI  AUX,0b00000000
    OUT  DDRB,AUX
    LDI  AUX,0b11111111   ;habilita o pull-up para os botoes
    OUT  PORTB,AUX
    LDI AUX, 0b11111111
    LDI AUX, 0b11111111
    OUT PORTD, AUX
naoPress:               ;loop botao nao pressionado (pull-up)

    sbis PINB,BOTAO2
    rcall main2
    sbis PINB,BOTAO1
    rcall main1
    rjmp naoPress        ;volta e fica preso no laço naoPress

main1:        ;rotacao para direita
    ror AUX
    OUT PORTD, AUX
    ldi r19, 80     ;delay 1s (usando minha sub-rotina)
    rcall delay
    ret

main2:        ;rotacao para direita
    rol AUX
    OUT PORTD, AUX
    ldi r19, 16     ;delay 1s (usando minha sub-rotina)
    rcall delay
    ret

;-----------------------------------------------------------
;SUB-ROTINA DE ATRASO Programável (Exemplo de aula)
; Depende do valor de R19 carregado antes da chamada.
; Exemplos: 
;    - R19 = 16 --> 200ms 
;    - R19 = 80 --> 1s 
;-----------------------------------------------------------
delay:
  push r17         ; Salva os valores de r17,
  push r18         ; ... r18,
  in r17,SREG    ; ...
  push r17       ; ... e SREG na pilha.
  ; Executa sub-rotina :
  clr r17
  clr r18
loop:
  dec  R17       ;decrementa R17, começa com 0x00
  brne loop      ;enquanto R17 > 0 fica decrementando R17
  dec  R18       ;decrementa R18, começa com 0x00
  brne loop      ;enquanto R18 > 0 volta decrementar R18
  dec  R19       ;decrementa R19
  brne loop      ;enquanto R19 > 0 vai para volta
  pop r17
  out SREG, r17  ; Restaura os valores de SREG,
  pop r18        ; ... r18
  pop r17        ; ... r17 da pilha
  ret