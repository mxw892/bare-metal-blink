; Guessing Game
    ; Matthew Wang
    ;
    ; Hardware: PIC16F84A @ 25kHz RC oscillator
    ;
    ; Pin mapping:
    ;   PORTA (inputs):
    ;     RA0 - Button 1
    ;     RA1 - Button 2
    ;     RA2 - Button 3
    ;     RA3 - Button 4
    ;
    ;   PORTB (outputs):
    ;     RB0 - LED 1 (State 1 indicator)
    ;     RB1 - LED 2 (State 2 indicator)
    ;     RB2 - LED 3 (State 3 indicator)
    ;     RB3 - LED 4 (State 4 indicator)
    ;     RB4 - Error LED (wrong button press)
    ;     RB5 - OK LED (correct button press)
    ;
    ; Game logic:
    ;   LEDs cycle through states 1-4. Player must press the button
    ;   matching the active LED before the state advances. Correct
    ;   press lights the OK LED; wrong press lights the Error LED.
    ;   Either way, game resets to state 1.
    
    ; Matthew Wang
    
    LIST P=16F84A
    INCLUDE <P16F84A.INC>
    ; config bits
    __CONFIG _RC_OSC & _WDT_OFF & _PWRTE_ON
    
    ; register definitions
    CBLOCK 0x0C
        COUNT1
        COUNT2
        STATE
    ENDC
 
    ORG 0x00
    
    ; set up
    GOTO START
 
    ;skip 0x04
    ORG 0x05
    
; setup the ports
START:
    ; switch to bank1
    BSF STATUS, RP0
    ;set RA0-3 as inputs
    MOVLW 0x0F
    MOVWF TRISA
    MOVLW 0x00
    ; set port b as outputs
    MOVWF TRISB
    ; switch back to bank 0
    BCF STATUS, RP0
 
    ; start at the first state
    MOVLW 0x01
    MOVWF STATE
 
; display the correct light at each state
MAIN_LOOP:
    
    MOVF STATE, W
    SUBLW d'1'
    BTFSC STATUS, Z
    GOTO DO_S1
 
    MOVF STATE, W
    SUBLW d'2'
    BTFSC STATUS, Z
    GOTO DO_S2
 
    MOVF STATE, W
    SUBLW d'3'
    BTFSC STATUS, Z
    GOTO DO_S3
 
    MOVF STATE, W
    SUBLW d'4'
    BTFSC STATUS, Z
    GOTO DO_S4
; logic for each state
DO_S1:
    
    ; l1 is on
    MOVLW 0x01
    MOVWF PORTB
    CALL CHECK_INPUT
    ; after the delay move to the second state
    MOVLW d'2'
    MOVWF STATE
    GOTO MAIN_LOOP
 
DO_S2:
    
    ; l2 on
    MOVLW 0x02
    MOVWF PORTB
    CALL CHECK_INPUT
    ; move to state 3
    MOVLW d'3'
    MOVWF STATE
    GOTO MAIN_LOOP
 
DO_S3:
    
    ;l3
    MOVLW 0x04
    MOVWF PORTB
    CALL CHECK_INPUT
    ; move to state 4
    MOVLW d'4'
    MOVWF STATE
    GOTO MAIN_LOOP
 
DO_S4:
    
    ;l4
    MOVLW 0x08
    MOVWF PORTB
    CALL CHECK_INPUT
    ; back to s1
    MOVLW d'1'
    MOVWF STATE
    GOTO MAIN_LOOP
 
; check if buttons r pressed
CHECK_INPUT:
    MOVF PORTA, W
    ; looks at just RA0-3
    ANDLW 0x0F
    BTFSC STATUS, Z
    ; no button pressed so wait
    GOTO DELAY_1S
 
    ;compare input to the currect active light
    XORWF PORTB, W
    ANDLW 0x0F
    BTFSC STATUS, Z
    ;match
    GOTO SOK_STATE
    ; not a match
    GOTO SERR_STATE
 
; win state
SOK_STATE:
    
    MOVLW 0x20
    MOVWF PORTB
    GOTO WAIT_RELEASE
    
; error state
SERR_STATE:
    
    MOVLW 0x10
    MOVWF PORTB
    GOTO WAIT_RELEASE
 
WAIT_RELEASE:
    
    MOVF PORTA, W
    ANDLW 0x0F
    ; wait till buttons r released
    BTFSS STATUS, Z
    GOTO WAIT_RELEASE
    ; reset to state 1
    MOVLW d'1'
    MOVWF STATE
    
    RETURN
 
    
;1 second delay at 25kHz
DELAY_1S:
    MOVLW d'100'
    MOVWF COUNT1
    
    
OUTER_LOOP:
    MOVLW d'83'
    MOVWF COUNT2
    
    
INNER_LOOP:
    DECFSZ COUNT2, F
    GOTO INNER_LOOP
    DECFSZ COUNT1, F
    GOTO OUTER_LOOP
    RETURN
 
    END