# bare-metal-blink

a guessing game written in PIC16F84A assembly. no OS, no runtime, no stdlib. just registers, a clock, and whatever you can build out of branch instructions.

---

## what it is

four LEDs cycle through states one at a time. you have to press the button that matches whichever LED is currently lit — before the state advances. hit the right one and the OK light comes on. hit the wrong one and the error light does. either way the game resets and goes again.

that's it. simple idea, zero abstraction layer between the idea and the hardware.

---

## how it actually works

**setup** — on power-on, the chip switches to bank 1 to configure TRIS registers: `TRISA = 0x0F` sets RA0–RA3 as inputs (the buttons), `TRISB = 0x00` sets all of PORTB as output (the LEDs). switches back to bank 0, sets `STATE = 1`, jumps to the main loop.

**state machine** — `MAIN_LOOP` reads the `STATE` register and does a series of `SUBLW` / `BTFSC STATUS, Z` comparisons to figure out which state to jump to. it's the assembly equivalent of a switch statement — subtract a constant from W, check if the zero flag is set, branch if so.

each state (`DO_S1` through `DO_S4`) writes a bitmask to PORTB to light the correct LED:
```
state 1 → PORTB = 0x01 → RB0 on
state 2 → PORTB = 0x02 → RB1 on
state 3 → PORTB = 0x04 → RB2 on
state 4 → PORTB = 0x08 → RB3 on
```
then calls `CHECK_INPUT`.

**input check** — `CHECK_INPUT` reads PORTA, masks to `0x0F` to isolate RA0–RA3, and checks the zero flag. if no button is pressed it drops into `DELAY_1S` and returns, advancing the state. if a button is pressed it XORs the input against the current PORTB value — if the result is zero, the right button was pressed (`SOK_STATE`), otherwise it's wrong (`SERR_STATE`).

**win/loss** — `SOK_STATE` sets `PORTB = 0x20` (RB5, the OK LED). `SERR_STATE` sets `PORTB = 0x10` (RB4, the error LED). both fall through to `WAIT_RELEASE`, which loops until all buttons are released, then resets `STATE = 1` and returns.

**delay** — `DELAY_1S` is a nested countdown loop calibrated to burn ~1 second at 25kHz. outer counter starts at 100, inner at 83. each inner iteration is 3 instruction cycles. math: `100 × 83 × 3 = 24,900 cycles ≈ 1s @ 25kHz`.

---

## pin mapping

| pin | direction | function |
|---|---|---|
| RA0 | input | button 1 |
| RA1 | input | button 2 |
| RA2 | input | button 3 |
| RA3 | input | button 4 |
| RB0 | output | LED 1 — state 1 |
| RB1 | output | LED 2 — state 2 |
| RB2 | output | LED 3 — state 3 |
| RB3 | output | LED 4 — state 4 |
| RB4 | output | error LED |
| RB5 | output | OK LED |

**MCU:** PIC16F84A — **Clock:** 25kHz RC oscillator

---

## building

```bash
mpasmwin /p16F84A guessing_game.asm
```

any MPASM-compatible assembler targeting the PIC16F84A works. program the resulting `.hex` with a PICkit or compatible programmer.
