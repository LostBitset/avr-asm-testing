#!/bin/bash

avra "$1.asm"

avrdude -p m328p -c stk500v1 -b 115200 -P /dev/ttyACM0 -U "flash:w:$1.hex" -F

