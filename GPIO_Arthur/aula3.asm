.INCLUDE <m328pdef.inc>

;DEFINIÇOES
.equ LED0   = PD0        ;LED  PD0
.equ LED1   = PD1        ;LED  PD1
.equ LED2   = PD2        ;LED  PD2
.equ LED3   = PD3        ;LED  PD3
.equ LED4   = PD4        ;LED  PD4
.equ LED5   = PD5        ;LED  PD5
.equ LED6   = PD6        ;LED  PD6
.equ LED7   = PD7        ;LED  PD7 

.equ BOTAO = PB3        ;BOTAO PB11
.equ BOTAO1 = PB4        ;BOTAO PB12

.def AUX   = R16        ;Auxiliar do Setup

setup:
    LDI  AUX,0b11111111   ;carrega AUX com o Valor
    OUT  DDRD,AUX         ;configura os pinos da PORTD
    OUT PORTD, AUX
    
    LDI  AUX,0b00000000   ;carrega AUX com o Valor
    OUT  DDRB,AUX         ;configura os pinos da PORTB
    LDI  AUX,0b11111111   ;habilita o pull-up para os botões
    OUT  PORTB,AUX


naoPress:              
    sbi  PORTD,LED0
    sbi  PORTD,LED1
    sbi  PORTD,LED2
    sbi  PORTD,LED3
    sbi  PORTD,LED4
    sbi  PORTD,LED5
    sbi  PORTD,LED6
    sbi  PORTD,LED7

    sbic PINB,BOTAO
    rjmp naoPress 
   
press:                  
    cbi  PORTD,LED0
    cbi  PORTD,LED1
    cbi  PORTD,LED2
    cbi  PORTD,LED3
    cbi  PORTD,LED4
    cbi  PORTD,LED5
    cbi  PORTD,LED6
    cbi  PORTD,LED7
    
    sbic PINB,BOTAO1      ;verifica se o botao1 foi solto, se sim
    rjmp naoPress         ;volta estado de nao pressionado, caso contrario salta
    
    sbic PINB,BOTAO       ;idem ao Botao1
    rjmp naoPress         
    rjmp press       