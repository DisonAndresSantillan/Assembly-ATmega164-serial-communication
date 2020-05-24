;
; 2_ASSEMBLER_SERIAL_COMUNICACTION_ATmega164p.asm
;
; Created: 23/05/2020 14:41:29
; Author : disoandres
;

.def tempo=r16
.def adc_h=r17
.def adc_l=r18
.def aux=r19
.dseg
.org 0x100//SRAM
convertion: .BYTE 1
value_out: .BYTE 1
.cseg
.org 0x00
rjmp init
.org 0x28
rjmp receiving_data

init:
//port A
ldi tempo,0x00
out ddra,tempo
com tempo
out porta,tempo
//port B
ldi tempo,0xff
out ddrb,tempo
com tempo
out portb,tempo
//port C
ldi tempo,0b00000011
out ddrc,tempo
com tempo
out portc,tempo
//port D
ldi tempo,0b00000010
out ddrd,tempo
com tempo
out portd,tempo

//PUD=0
in tempo,mcucr
andi tempo,0b11101111
out mcucr,tempo
//stack pointer
ldi  tempo,high(ramend)
out sph,tempo
ldi tempo,low(ramend)
out spl,tempo
//config adc circuit 
ldi tempo,0b01100000//justification left 
sts admux,tempo
ldi tempo,0b00000001
sts didr0,tempo

//Config Communication
// UBRRn=(fosc/16*BAUDS)-1 , page 227,Atmel Datasheet 
//U2X=0
ldi tempo,high(51)//UBRRn=51, 9600baus,focs=8Mz
sts ubrr0h,tempo
ldi tempo,low(51)
sts ubrr0l,tempo

ldi tempo,0b00000000// here U2X=0
sts ucsr0a,tempo
ldi tempo,0b10011000
sts ucsr0b,tempo
ldi tempo,0b00000110//Asynchronous UsartT, 1 Stop bit, 8Bits 
sts ucsr0c,tempo
sei

//////////////////////////////////
program:
//first, I need to initialize the ADC
ldi tempo,0b11000011//MANUAL,DIV8
sts adcsra,tempo
wait:
lds tempo,adcsra
sbrc tempo,6
rjmp wait

lds tempo,adch
sts convertion,tempo

//prescaling 100%
ldi aux,230
lds tempo,convertion
mul tempo,aux
clc
ror r1
ror r0
clc
ror r1
ror r0
clc
ror r1
ror r0
clc
ror r1
ror r0
clc
ror r1
ror r0
clc
ror r1
ror r0
clc
ror r1
ror r0
clc
ror r1
ror r0
sts value_out,r0
wait1:
lds tempo,ucsr0a
sbrs tempo,5
rjmp wait1

lds aux,value_out
sts udr0,aux
rjmp program

//labview to atmega 
receiving_data: 
push tempo
in tempo,sreg
push tempo

lds tempo,udr0
out portb,tempo

pop tempo
out sreg,tempo
pop tempo
reti
