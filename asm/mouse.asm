// set Mouse Read addresses
MOUSE_STATUS: 0xA0
MOUSE_X: 0xA1
MOUSE_Y: 0xA2
// set LEDS Write addresses
LEDS_LO: 0xC0
LEDS_HI: 0xC1
// set SEG7 Write addresses
SEG_LO: 0xD0
SEG_HI: 0xD1

VGA_INT: 0x0 // set VGA interrupt to 0 (not needed)

// Start Code and set Mouse Interrupt address
MOUSE_INT: ldb a MOUSE_X // load mousex
ldb b MOUSE_Y // load mousey
stb a SEG_LO // store mousex in seg7
stb b SEG_HI // store mousey in seg7

ldb a MOUSE_STATUS // load mouse
stb a LEDS_LO // store state in the bottom leds

END: idle // wait for interrupt