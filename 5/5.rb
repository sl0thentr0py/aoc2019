require 'pry'

class Computer

  attr_accessor :pc, :tape, :instruction

  STEPS = { halt: 1, arithmetic: 4, io: 2 }

  def initialize(input)
    @tape = input.dup
    @pc = 0
    @instruction = nil
  end

  def execute
    return unless read_instruction
    return unless execute_instruction
    @pc += steps
    execute
  end

  private

  def steps
    STEPS[opcode_type]
  end

  def opcode
    @tape[@pc]
  end

  def opcode_s
    opcode.to_s
  end

  def opcode_last
    opcode_s.chars.last.to_i
  end

  def opcode_type
    return :halt if opcode == 99

    case opcode_last
    when 1, 2
      :arithmetic
    when 3, 4
      :io
    else
      :unknown
    end
  end


  def operand1_type
    return :immediate if opcode_s.length == 3 && opcode_s[0] == '1'
    return :immediate if opcode_s.length == 4 && opcode_s[1] == '1'
    :position
  end

  def operand2_type
    return :immediate if opcode_s.length == 4 && opcode_s[0] == '1'
    :position
  end

  def operand1
    case operand1_type
    when :position
      @tape[@instruction[1]]
    when :immediate
      @instruction[1]
    end
  end

  def operand2
    case operand2_type
    when :position
      @tape[@instruction[2]]
    when :immediate
      @instruction[2]
    end
  end

  def execute_arithmetic
    result = opcode_last == 1 ? operand1 + operand2 : operand1 * operand2
    @tape[@instruction[3]] = result
  end

  def execute_io
    case opcode_last
    when 3
      puts 'Input..'
      @tape[@instruction[1]] = gets.strip.to_i
      puts '------'
    when 4
      puts "Output: #{operand1}"
    end
  end

  def read_instruction
    @instruction = @tape.slice(@pc...@pc + steps)
  end

  def execute_instruction
    case opcode_type
    when :halt
      false
    when :arithmetic
      execute_arithmetic
      true
    when :io
      execute_io
      true
    else
      raise 'Unknwown instruction'
    end
  end

end


input = File::read('input').strip.split(',').map(&:to_i)
c = Computer.new(input)
c.execute
