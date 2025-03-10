# Silly Car Game

FPGA Car Game written in verilog

## Arch

Controlled by a 8-bit single-cycle CPU with 2 regs (a,b)

![system arch block diagram](figs/system.png)

## Assembler Usage

Run with asm file path as input arg:

```sh
python assembley.py [source]
```

outputs written to ram.mem and rom.mem in the root project folder


## ISA Summary

### Math 

| Opp  | Rd  |     | Description       |
|------|-----|-----|-------------------|
| add  | reg |     | reg = a + b       |
| sub  | reg |     | reg = a - b       |
| mul  | reg |     | reg = a * b       |
| sll  | reg |     | reg = a << b      |
| srl  | reg |     | reg = a >> b      |
| inca | reg |     | reg = a + 1       |
| incb | reg |     | reg = b + 1       |
| deca | reg |     | reg = a - 1       |
| decb | reg |     | reg = b - 1       |
| eq   | reg |     | reg = a == b      |
| gt   | reg |     | reg = a > b       |
| lt   | reg |     | reg = a < b       |
| not  | reg |     | reg = ~a          |
| and  | reg |     | reg = a & b       |
| or   | reg |     | reg = a | b       |
| xor  | reg |     | reg = a ^ b       |


### Math Immediate

| Opp  | Rd  | IMM |     | Description       |
|------|-----|-----|-----|-------------------|
| add  | reg | imm |     | reg = reg + imm   |
| sub  | reg | imm |     | reg = reg - imm   |
| mul  | reg | imm |     | reg = reg * imm   |
| sll  | reg | imm |     | reg = reg << imm  |
| srl  | reg | imm |     | reg = reg >> imm  |
| eq   | reg | imm |     | reg = reg == imm  |
| gt   | reg | imm |     | reg = reg > imm   |
| lt   | reg | imm |     | reg = reg < imm   |
| and  | reg | imm |     | reg = reg & imm   |
| or   | reg | imm |     | reg = reg | imm   |
| xor  | reg | imm |     | reg = reg ^ imm   |

### Memory 

| Opp  | Rd  | MEM  |     | Description       |
|------|-----|------|-----|-------------------|
| ldb  | reg | ADDR |     | reg = [ADDR]      |
| stb  | reg | ADDR |     | [ADDR] = reg      |
| dref | reg |      |     | reg = [reg]       |

### Branch 

| Opp  | MEM  |     | Description                  |
|------|------|-----|------------------------------|
| beq  | ADDR |     | branch if a == b             |
| bgt  | ADDR |     | branch if a > b              |
| blt  | ADDR |     | branch if a < b              |
| goto | ADDR |     | unconditional branch         |
| idle |      |     | unconditional branch to idle |
| call | ADDR |     | call subroutine              |
| ret  |      |     | return from subroutine       |