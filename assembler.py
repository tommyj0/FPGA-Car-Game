# TODO implement labels, can't think of anything else 

import sys

# LUTs for each "type" of instruction

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
  "dref"  : 0xB,
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

address_counter = 0x0 # check where we are in machine code
# n.b. because of var length instructions: instruction count != byte count

def write_comment(file_p, com): # write the instruction as a comment
  file_p.write(f"  // {' '.join(com)}")

def write_byte(file_p,num): # write instruction to machine code file
  if num > 255: # panic if you get something bigger than a byte
    raise Exception(f"ERROR: Instruction longer than 8 bits")

  hex_token = hex(num)[2:] # don't need "0x" prefix
  if len(hex_token) == 1: # display 1 digit as 2 digit 
    file_p.write(f"0")
  file_p.write(f"{hex_token}")
  global address_counter # too lazy to think of a nice way
  address_counter += 1

def check_dest_reg(rd): # check that rd is either a or b
  if "a" not in rd and "b" not in rd:
    raise Exception(f"ERROR: {line[1]} does not contain a valid destination register")

def check_token_num(line,num): # error handling for number of tokens
  if (len(line) != num):
    raise Exception(f"ERROR: \ninstruction: {' '.join(line)}should only contain {num} tokens")

def write_math_instr(file_p,line): # handle math type
  check_dest_reg(line[1])
  check_token_num(line,2)
  instr = math_lut[line[0]]

  if "b" in line[1]:
    instr += 1

  write_byte(file_p,instr)
  write_comment(file_p,line)
  file_p.write("\n")

def write_mem_instr(file_p,line): # handle mem access type
  check_dest_reg(line[1])
  instr = mem_lut[line[0]]
  if "b" in line[1]:
    instr += 1

  write_byte(file_p,instr)
  write_comment(file_p,line)
  file_p.write("\n")

  if "dref" in line[0]: # dref doesn't take an immediate address so return early
    check_token_num(line,2)
    return

  check_token_num(line,3)
  write_byte(file_p,int(line[2],0))
  file_p.write("\n")

def write_branch_instr(file_p,line): # handle branch type
  instr = branch_lut[line[0]]
  write_byte(file_p,instr)
  write_comment(file_p,line)
  file_p.write("\n")

  if "ret" in line[0] or "idle" in line[0]: # ret & idle don't need an address
    check_token_num(line,1)
    return

  check_token_num(line,2)
  write_byte(file_p,int(line[1],0))
  file_p.write("\n")

n = len(sys.argv) # get input args
assert n == 2, "Requires 1 input arg"
rom_fp = "rom.mem"
ram_fp = "ram.mem"
rom_f = open(rom_fp,"w")
ram_f = open(ram_fp,"w")
asm_f = open(sys.argv[1],"r")
asm = asm_f.readlines()

for line in asm:
  line = line.replace('\n','') 
  line = line.strip() # mainly for trailing whitespace
  if not line:
    continue
  line = line.split(" ")
  code = line[0]

  if code in math_lut:
    write_math_instr(rom_f,line)
  elif code in mem_lut:
    write_mem_instr(rom_f,line)
  elif code in branch_lut:
    write_branch_instr(rom_f,line)
  else:
    raise Exception(f"code {code} is not a part of the ISA")

# cleanup
if address_counter > 255:
  raise Exception(f"code must be 255B or shorter, current length is {address_counter}")
else:
  print(f"{address_counter}B have been written to {rom_fp}")

for i in range(256 - address_counter): # fill rest of rom init with nops (idle)
  rom_f.write("08\n")

for i in range(128): # TODO: add constants, for now fill ram with 0s
  ram_f.write("00\n")