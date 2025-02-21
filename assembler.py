'''
#############################
######## ISA Summary ########
#############################

### Formats ###

## Math ##

add reg       reg = a + b 
sub reg       reg = a - b
mul reg       reg = a * b

sll reg       reg = a << b           
srl reg       reg = a >> b           
inca reg      reg = a + 1
incb reg      reg = b + 1
deca reg      reg = a - 1
decb reg      reg = b - 1
eq reg        reg = a == b
gt reg        reg = a > b
lt reg        reg = a < b

## Memory ##

ldb reg ADDR  reg = [ADDR] 
stb reg ADDR  [ADDR] = reg
dref reg      reg = [reg]

## Branch ##

beq ADDR      branch if a == b
bgt ADDR      branch if a > b
blt ADDR      branch if a < b
goto ADDR     unconditional branch
idle          unconditional branch to idle 
call ADDR     call subroutine
ret           return from subroutine
'''

# TODO implement labels, can't think of anything else that we need
math_lut = {
  "add"   : 0x04,
  "sub"   : 0x14,
  "mul"   : 0x24,
  "sll"   : 0x34,
  "srl"   : 0x44,
  "inca"  : 0x54,
  "incb"  : 0x64,
  "deca"  : 0x74,
  "decb"  : 0x84,
  "eq"    : 0x94,
  "gt"    : 0xA4,
  "lt"    : 0xB4,
}

mem_lut = {
  "ldb"   : 0x0, 
  "stb"   : 0x2,
  "dref"  : 0xD,
}

branch_lut = {
  "beq"   : 0x96,
  "bgt"   : 0xA6,
  "blt"   : 0xB6,
  "goto"  : 0x07,
  "idle"  : 0x08,
  "call"  : 0x09,
  "ret"   : 0x0A,
}

def write_comment(file_p, com):
  file_p.write(f"\t; {' '.join(com)}")

def write_hex(file_p,num): # write instruction to machine code file
  if num > 255:
    raise Exception(f"ERROR: Instruction longer than 8 bits")
  hex_token = hex(num)[2:]
  if len(hex_token) == 1:
    file_p.write(f"0")
  file_p.write(f"{hex_token}")

def check_dest_reg(rd): # check that rd is either a or b
  if "a" not in rd and "b" not in rd:
    raise Exception(f"ERROR: {line[1]} does not contain a valid destination register")

def check_token_num(line,num):
  if (len(line) != num):
    raise Exception(f"ERROR: \ninstruction: {' '.join(line)}should only contain {2} tokens")

def write_math_instr(file_p,line):
  check_dest_reg(line[1])
  check_token_num(line,2)
  instr = math_lut[line[0]]
  if "b" in line[1]:
    instr += 1
  write_hex(file_p,instr)
  write_comment(file_p,line)
  file_p.write("\n")

def write_mem_instr(file_p,line):
  check_dest_reg(line[1])
  instr = mem_lut[line[0]]
  if "b" in line[1]:
    instr += 1
  write_hex(file_p,instr)
  write_comment(file_p,line)
  file_p.write("\n")

  if "dref" in line[0]:
    check_token_num(line,2)
    return
  check_token_num(line,3)
  write_hex(file_p,int(line[2],0))
  file_p.write("\n")

def write_branch_instr(file_p,line):
  instr = branch_lut[line[0]]
  write_hex(file_p,instr)
  write_comment(file_p,line)
  file_p.write("\n")
  if "ret" in line[0] or "idle" in line[0]:
    check_token_num(line,1)
    return
  check_token_num(line,2)
  write_hex(file_p,int(line[1],0))
  file_p.write("\n")

mac_f = open("mem.txt","w")
asm_f = open("main.asm","r")
asm = asm_f.readlines()

for line in asm:
  line = line.replace('\n','')
  line = line.split(" ")
  code = line[0]

  if code in math_lut:
    write_math_instr(mac_f,line)
  elif code in mem_lut:
    write_mem_instr(mac_f,line)
  elif code in branch_lut:
    write_branch_instr(mac_f,line)
  else:
    raise Exception(f"code {code} is not a part of the ISA")