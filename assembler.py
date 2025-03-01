# TODO implement labels, can't think of anything else 

import sys
import re

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

def write_comment(file_p, com, label=''): # write the instruction as a comment
  file_p.write(f"  // {label} {' '.join(com)}")

def write_byte(file_p,num): # write instruction to machine code file
  if num > 255: # panic if you get something bigger than a byte
    raise Exception(f"ERROR: Instruction longer than 8 bits")

  hex_token = hex(num)[2:] # don't need "0x" prefix
  if len(hex_token) == 1: # display 1 digit as 2 digit 
    file_p.write(f"0")
  file_p.write(f"{hex_token}")
  global address_counter # too lazy to think of a nice way
  address_counter += 1
  print(f"wrote this {hex_token}")

def check_dest_reg(rd): # check that rd is either a or b
  if "a" not in rd and "b" not in rd:
    raise Exception(f"ERROR: {line[1]} does not contain a valid destination register")

def check_token_num(line,num): # error handling for number of tokens
  if (len(line) != num):
    raise Exception(f"ERROR: \ninstruction: {' '.join(line)}should only contain {num} tokens")

def is_int(s): # check if a string is an int
  try:
    if re.match('^[0-9]*$', s):
      return True
    int(s,0)
    return True
  except ValueError:
    return False

def write_math_instr(file_p,line,label=''): # handle math type
  check_dest_reg(line[1])
  check_token_num(line,2)
  instr = math_lut[line[0]]

  if "b" in line[1]:
    instr += 1

  write_byte(file_p,instr)
  write_comment(file_p,line,label)
  file_p.write("\n")

def write_mem_instr(file_p,line,label=''): # handle mem access type
  check_dest_reg(line[1])
  instr = mem_lut[line[0]]
  if "b" in line[1]:
    instr += 1

  write_byte(file_p,instr)
  write_comment(file_p,line,label)
  file_p.write("\n")

  if "dref" in line[0]: # dref doesn't take an immediate address so return early
    check_token_num(line,2)
    return

  check_token_num(line,3)
  write_byte(file_p,int(line[2],0))
  file_p.write("\n")

def write_branch_instr(file_p,line,label=''): # handle branch type
  instr = branch_lut[line[0]]
  write_byte(file_p,instr)
  write_comment(file_p,line,label)
  file_p.write("\n")

  if "ret" in line[0] or "idle" in line[0]: # ret & idle don't need an address
    check_token_num(line,1)
    return

  check_token_num(line,2)
  if is_int(line[1]):
    write_byte(file_p,int(line[1],0))
  else:
    try: # try to write the label address
      write_byte(file_p,label_lut[line[1]])
    except KeyError:
      file_p.write(line[1]) # if label doesn't exist write the label name, we will go back and replace it after the first pass
      global address_counter
      address_counter += 1
  file_p.write("\n")

n = len(sys.argv) # get input args
assert n == 2, "Requires 1 input arg"
rom_fp = "rom.mem"
ram_fp = "ram.mem"
rom_f = open(rom_fp,"w")
ram_f = open(ram_fp,"w")
asm_f = open(sys.argv[1],"r")
asm = asm_f.readlines()

label_lut = {} # label lookup table

for line in asm:
  line = line.replace('\n','') 
  line = line.strip() # mainly for trailing whitespace
  if not line:
    continue
  line = line.split(" ")
  code = line[0]

  label = ''

  # Match labels
  if re.match(r'[A-Z]*:', line[0]):
    label = line[0]
    # If a label matches an instruction store the address counter of the label
    if line[1] in math_lut or line[1] in mem_lut or line[1] in branch_lut:
      code = line[1]
      label_lut[label.replace(':', '')] = address_counter # why +1?
      line = line[1:]
    else:
      raise Exception(f"Label {label} does not match any instruction")

  if code in math_lut:
    write_math_instr(rom_f,line,label)
  elif code in mem_lut:
    write_mem_instr(rom_f,line,label)
  elif code in branch_lut:
    write_branch_instr(rom_f,line,label)
  elif code == "":
    continue
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

rom_f.close()
ram_f.close()
asm_f.close()

# Second pass to replace labels with addresses
with open(rom_fp, "r") as rom_f:
  lines = rom_f.readlines()  
  modified_lines = []
  for line in lines:
    parts = line.strip().split(" ")  # Strip and split the line

    if not is_int(parts[0]):
      try:
          label_hex = hex(label_lut[parts[0]])[2:]
          if len(label_hex) == 1: # display 1 digit as 2 digit 
            parts[0] = f"0{label_hex}"
          else:
            parts[0] = hex(label_lut[parts[0]])[2:]  # Replace first part
      except KeyError:
          raise Exception(f"Label {parts[0]} not found")

    modified_lines.append(" ".join(parts))  # Rejoin and store the modified line

with open(rom_fp, "w") as rom_f:
  rom_f.write("\n".join(modified_lines) + "\n")