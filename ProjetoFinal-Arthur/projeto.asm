//------------------------------------------------------------------------------------- //
//		       Projeto Final - Display de 7 segmentos				//	
//------------------------------------------------------------------------------------- //
//=====================================================================================	//
//	
//	(OK) Fazer uma contagem de 0x0 a 0xF no display, incrementando a cada 1s aproximadamente.
//    
//	(X - Bug) Ao pressionar o botão, o display deve desligar, mas não zerar a contagem.
//      (Em vez de desligar o display, ele pausa a contagem quando desliga temporariamente)
//    
//  Requisitos:
//	(OK) O loop principal deve fazer a contagem e chamar a decodificação/escrita no display.
//	(OK) O atendimento do botão deve ser implementado utilizando interrupção.
//	(OK) Utilizar sub-rotina de delay programável apresentada na aula.
//	(OK) Utilizar a sub-rotina de decodificação.
//	
//  OBS:
//  No caso de meu Arduino estar com problemas nas Pinos PB0 a PB2 da PORTAB, o pino usado na Decodificação,
//     por isso foi usado o PB3 para pino G do Display em vez de PB1 como estava orgininalmente.
//
//  Por falta de tempo hábil, e problemas com Arduino a funcionalidade a interrupção na prática não funcionou corretamente. 
//  Contudo, usando a depuracao da simulacao, a interrupcao na simulacao ocorreu com sucesso.
//====================================================================================	//
.INCLUDE <m328Pdef.inc>
   
 ;DEFINIÇÕES   
.equ BOTAO    = PD2		//BOTAO é o substituto de PD2 na programação
.equ CHAVE    = PB5             //OBS: Professor para facilitar, colocar seu o pino correto
.equ G        = PB3             //OBS: Professor para facilitar, colocar seu o pino correto
.equ DISPLAY  = PORTC		//PORTC é onde está conectado o Display (seg a = LSB)
.def AUX      = R16;		//R16 tem agora o nome de AUX

.ORG 0x0000		; Reset vector
    RJMP Setup

.ORG 0x0002		; Vetor (endereço na Flash) da INT0
    RJMP isr_int0
    
.ORG 0x0034		; primeira end. livre depois dos vetores				

Setup:
    LDI AUX,0b11111011 //carrega AUX com o valor (1 saída, 0 entrada)
    OUT DDRD,AUX 
    LDI  AUX,0b11111111	   
    OUT DDRC,AUX 
    OUT PORTC,AUX 
    OUT PORTD,AUX 
    
    LDI  AUX,0b11111111
    OUT DDRB,AUX
    OUT PORTB,AUX
    
    ;Configuracao para INT0
    LDI AUX, 0x01 ;Borda de decida em INT0 - Como visto nos slides de aula
    STS EICRA, AUX ; config. INT0 sensivel a borda
    SBI EIMSK, INT0 ; habilita a INT0
    SEI ; habilita a interrupcao global ...
	; ... (bit I do SREG)
    
    LDI AUX, 0x0F;Carrega 0xF para iniciar a contagem no display a partir de 0, como mostrado no fluxograma proposto.


//------------------------------------------------------------------------------------
main:    
	CPI  AUX,0x0F   	//compara se valor é máximo
	BRNE Incr       	//se não for igual, incrementa; senão, zera valor
	LDI  AUX,0x00
	RJMP Decodi

Incr:	
	INC  AUX

Decodi:	
	RCALL Decodifica	//Sub-rotina de decodificação
	ldi r19, 80		//R19 estara carregado com o valor de 1s
	RCALL delay      	//Sub-rotina de Atraso
	RJMP  main      	//volta ao main
	
;----------------------------------------------------------------------------------------
;SUB-ROTINA DE ATRASO Programável - Depende do valor de R19 carregado antes da chamada.
; Exemplos:
;- R19 = 16 --> 200ms
;- R19 = 80 --> 1s
;----------------------------------------------------------------------------------------
delay:
    push R17	    ; Salva os valores de r17,
    push R18	    ; ... r18,
    in R17,SREG	    ; ...
    push R17	    ; ... e SREG na pilha. | Executa sub-rotina :
    clr R17
    clr R18
loop:
    dec R17	    ;decrementa R17, começa com 0x00
    brne loop	    ;enquanto R17 > 0 fica decrementando R17
    dec R18	    ;decrementa R18, começa com 0x00
    brne loop	    ;enquanto R18 > 0 volta decrementar R18
    dec R19	    ;decrementa R19
    brne loop	    ;enquanto R19 > 0 vai para volta
    
    pop R17
    out SREG,R17    ; Restaura os valores de SREG,
    pop R18	    ; ... r18
    pop R17	    ; ... r17 da pilha
    
    RET

;-------------------------------------------------
; Rotina de Interrupção (ISR) da INT0 (Exemplo usado na aula Interrupção, com o desliga modificado)
;-------------------------------------------------
isr_int0:
    push R16		; Salva o contexto (SREG)
    in R16, SREG
    push R16
    sbis PIND,BOTAO	; botao press. salta a próxima inst.
    rjmp desliga
    cbi PORTB,CHAVE
    rjmp fim
    
desliga:
    sbi PORTB,CHAVE
 
fim:
    pop R16	    ; Restaura o contexto (SREG)
    in R16, SREG
    pop R16
    reti	    ; retorna da interrupcao
;---------------------------------------------------------------------------
; SUB-ROTINA: Decodifica um valor de 0 a 15 passado como parâmetro no R16 e 
;             escreve em um display anodo comum com a seguinte ligação:
; Seguimento:  G   F  ...  A
; Pino:       PB3 PC5 ... PC0
;
; obs: PB3 usado no lugar de PB1.    
;---------------------------------------------------------------------------
Decodifica:
    push ZH            ; Guarda contexto
    push ZL        
    push r0        
    in r0,SREG   
    push r0      

    ldi  ZH,HIGH(Tabela<<1)	;carrega o endereço da tabela no registrador Z, de 16 bits (trabalha como um ponteiro)
    ldi  ZL,LOW(Tabela<<1)	;deslocando a esquerda todos os bits, pois o bit 0 é para a seleção do byte alto ou baixo no end. de memória    
    add  ZL,R16			;soma posição de memória correspondente ao nr. a apresentar na parte baixa do endereço
    brcc le_tab			;se houve Carry, 
    inc  ZH			;incrementa parte alta do endereço, senão lê diretamente a memória

le_tab:     
    lpm  R0,Z			;Lê tabela de decoficação do valor em R0

    sbi PORTB, G		; Escreve G - PB1 Trocado por PB3, pelo motivo do PB1 de meu Arduino estar com problema
    sbrs R0, 6
    cbi PORTB, G

    out  PORTC,R0		;Escreve A .. F      

    pop r0			;Recupera contexto
    out SREG, r0
    pop r0
    pop ZL
    pop ZH    

    ret

;---------------------------------------------------------------------------
;   Tabela p/ decodificar o display: como cada endereço da memória flash é 
; de 16 bits, acessa-se a parte baixa e alta na decodificação
;---------------------------------------------------------------------------
Tabela: .dw 0x7940, 0x3024, 0x1219, 0x7802, 0x1800, 0x0308, 0x2146, 0x0E06
;             1 0     3 2     5 4     7 6     9 8     B A     D C     F E  
;===========================================================================


