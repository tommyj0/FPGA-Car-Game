#!/usr/bin/ruby

# Simulation engine for the FPGA Processor's ISA
# Used to verify the assembly code before running on the FPGA
# Helpful for debugging

require 'optparse'

$ram = Array.new()
$memory_labels = Hash.new()
$code_labels = Hash.new()

$a = 0
$b = 0

# Simulate Math Operation - set the 'a' and 'b' registers accordingly
# operation: the operation to perform
# register: the register to store the result in
# TODO: add support for immediate values
def math_ops(operation, register, immediate)
    result = 0
    
    local_b = (immediate != nil) ? immediate : $b
    local_a = ((immediate != nil) && (register == 'b')) ? $b : $a

    case(operation)
    when 'add'
        result = local_a + local_b
    when 'sub'
        result = local_a - local_b
    when 'mul'
        result = local_a * local_b
    when 'sll'
        result = local_a << local_b
    when 'srl'
        result = local_a >> local_b
    when 'inca'
        result = $a + 1
    when 'incb'
        result = $b + 1
    when 'deca'
        result = $a - 1
    when 'decb'
        result = $b - 1
    when 'eq'
        result = local_a == local_b ? 1 : 0
    when 'gt'
        result = local_a > local_b ? 1 : 0
    when 'lt'   
        result = local_a < local_b ? 1 : 0
    when 'not' # might be wrong but lazy
        result = $a ^ 0xFF
    when 'and'
        result = local_a & local_b
    when 'or'
        result = local_a | local_b
    when 'xor'
        result = local_a ^ local_b
    else # shouldn't get here
        raise "Invalid operation"
    end

    if register == 'a'
        $a = result & 0xFF
    else
        $b = result & 0xFF
    end
end

# Simulate Memory Operation - read/write to memory
# operation: the operation to perform
# register: the register to store the result in
# address: the address to read/write from - can take absolute address or label
def mem_ops(operation, register, address)
    if address.is_a? Integer
        address = address
    else
        address = $memory_labels[address]
    end

    case(operation)
    when 'ldb'
        if register == 'a'
            $a = $ram[address]
        else
            $b = $ram[address]
        end
    when 'stb'
        $ram[address] = register == 'a' ? $a : $b
    when 'dref'
        if register == 'a'
            $a = $ram[$ram[address]]
        else
            $b = $ram[$ram[address]]
        end
    else
        raise "Invalid operation"
    end
end

# Simulate Branch Operation - branch to a label or do nothing
# operation: the operation to perform
# label: the label to branch to
# ic: the current instruction counter
def branch_ops(operation, label, ic)
    raise "Don't currently support this" if label.is_a? Integer
    
    case(operation)
    when 'beq'
        if $a == $b
            ic = $code_labels[label]
        else
            ic+=1
        end
    when 'bgt'
        if $a > $b
            ic = $code_labels[label]
        else
            ic+=1
        end
    when 'blt'
        if $a < $b
            ic = $code_labels[label] if $a < $b
        else
            ic+=1
        end
    when 'goto'
        ic = $code_labels[label]
    when 'idle'
        ic+=1 # do nothing
    when 'call'
        ic+=1 # do nothing
    when 'ret'
        ic+=1 # do nothing
    end
    return ic
end

math_ops   = ['add', 'sub', 'mul',
              'sll', 'srl', 'inca',
              'incb', 'deca', 'decb', 
              'eq', 'gt', 'lt',
              'not', 'and', 'or', 'xor']

mem_ops    = ['ldb', 'stb', 'dref']

branch_ops = ['beq', 'bgt' , 'goto', 'blt',
              'idle', 'call', 'ret']

ram_file = "ram.mem"
code_file = "assembly/vga_int_handler.asm"

$simulation_steps = 250000

OptionParser.new do |opt|
    opt.on("-r", "--ram FILE", "RAM file") do |ram|
        ram_file = ram
    end
    opt.on("-c", "--code FILE", "Code file") do |code|
        code_file = code
    end
    opt.on("-v", "--verbose", "Verbose") do
        $verbose = true
    end
    opt.on("-s", "--steps STEPS", "Steps") { |steps| $simulation_steps = steps.to_i }
    opt.on("-h", "--help", "help") do
        puts opt
        exit
    end
    opt.parse!
end

File.open(ram_file, 'r') do |file|
    file.readlines.each do |line|
        data = line.split(' ')[0].to_i(16)
        $ram.append(data)
    end
end

code = Array.new()
i = 0
File.open(code_file, 'r') do |file|
    file.readlines.each do |line|
        if line.strip.empty?
            next
        elsif line[0..1] == '//'
            next
        else
            data = line.split(' ')
            if line.match(/^[A-Z_]+:\s*0x[A-Z0-9]{2}/) # if label to a memory location, store it as such
                $memory_labels.store(data[0].split(':')[0], data[1].to_i(16))
            elsif data[0].match(/^[A-Z_]+:/) # if label to a code location, store it as such
                $code_labels.store(data[0].split(':')[0], i)
                code.append(line.split('//')[0].split(':')[1].strip)
                i += 1
            else
                code.append(line.split('//')[0])
                i += 1
            end
        end
    end
end

line = code[0]
i = 0
ic = 0

print "MEMORY LABELS: "
pp $memory_labels
print "CODE LABELS: "
pp $code_labels

puts "Running #{$simulation_steps} steps of code..."

# Run the code
while(i < $simulation_steps)
    if ic >= code.length
        puts "Finished executing after #{i} steps"
        break
    end
    line = code[ic]
    puts "#{line}" if $verbose
    immediate = nil
    data = line.split(' ')
    if math_ops.include?(data[0])
        immediate = data[2].to_i(16) if data[2] && data[2].match(/[0-9A-F]{2}/)
        math_ops(data[0], data[1], immediate)
        puts "\tA: #{$a} B: #{$b}" if $verbose
        ic+=1
    elsif mem_ops.include?(data[0])
        if($memory_labels[data[2]] == nil)
            mem_ops(data[0], data[1], data[2].to_i(16))
            puts "\tMemory @ #{data[2]}: #{$ram[data[2].to_i(16)]}" if $verbose
        else
            mem_ops(data[0], data[1], data[2])
            puts "\tMemory @ #{data[2]}: #{$ram[$memory_labels[data[2]]]}" if $verbose
        end
        puts "\tA: #{$a} B: #{$b}" if $verbose
        ic+=1
    elsif branch_ops.include?(data[0])
        new_ic = branch_ops(data[0], data[1], ic)
        if new_ic != ic+1
            puts "\tjumped to #{data[1]} at #{$code_labels[data[1]]}" if $verbose
        else
            puts "\tbranch not taken" if $verbose
        end
        ic = new_ic
    else
        raise "Invalid operation" 
    end

    if data[0] == 'stb' && (data[2] == 'WRITE_Y')
        puts "Drawing X: #{$ram[$memory_labels["WRITE_X"]]} Y: #{$ram[$memory_labels["WRITE_Y"]] & 0x7F} DATA: #{($ram[$memory_labels["WRITE_Y"]] & 0x80) >> 7}"
    end
    i += 1
end

puts "End of simulation"
exit(1)