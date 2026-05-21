# PIC16F84A Guessing Game

A reaction/guessing game written in PIC16F84A assembly language.

## Overview

Four LEDs cycle through states one at a time. The player must press the button corresponding to the currently lit LED before the state advances. A correct press lights a green OK indicator; a wrong press lights a red error indicator. The game then resets to state 1.

## Hardware

| Component | Pin | Direction |
|---|---|---|
| Button 1 | RA0 | Input |
| Button 2 | RA1 | Input |
| Button 3 | RA2 | Input |
| Button 4 | RA3 | Input |
| LED 1 | RB0 | Output |
| LED 2 | RB1 | Output |
| LED 3 | RB2 | Output |
| LED 4 | RB3 | Output |
| Error LED | RB4 | Output |
| OK LED | RB5 | Output |

- **MCU:** PIC16F84A
- **Clock:** 25kHz RC oscillator
- **Toolchain:** MPLAB / MPASM

## How It Works

- PORTA (RA0–RA3) configured as inputs; PORTB as outputs
- State machine cycles through 4 states, each activating one LED via bitmask on PORTB
- `CHECK_INPUT` reads PORTA, masks to lower 4 bits, and XORs against the active PORTB value
  - Zero result → correct button → `SOK_STATE` (RB5 on)
  - Non-zero result → wrong button → `SERR_STATE` (RB4 on)
- `DELAY_1S` implements a calibrated 1-second delay using nested countdown loops at 25kHz
- After any button result, game waits for button release then resets to state 1

## Building

Assemble with MPASM or any compatible PIC assembler targeting the PIC16F84A:

```
mpasmwin /p16F84A guessing_game.asm
```
