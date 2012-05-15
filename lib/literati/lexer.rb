require 'literati/block'
require 'literati/program'
module Parser
  def self.state
    @@state
  end
  
  def self.state=(state)
    @@state = state
  end
  
  def self.lex tokens
    statements = []
    current_statement = nil
    program = nil
    self.state = nil
    tokens.each_with_index do |token, i|
      token.rstrip!
      if line_is_program_definition?(token)
        tokens = tokens.slice(i, tokens.count - i).reject{|t| t.strip.length == 0}
        metadata = tokens.select{|t| t =~ /^@/}.map{|t| t.gsub(/@/, '')}
        tokens.reject!{|t| t=~ /^@/}
        program = Program.new tokens, metadata
        break
      end
      if line_is_title? token
        if self.state == :has_title
          # block is comment only block
          statements << current_statement
          current_statement = nil
          self.state = nil
        end
        self.state = :has_title
        current_statement = Block.new token
      end
      if line_is_comment? token
        current_statement.add_comment token
      end
      if line_is_metadata? token
        current_statement.parse_metadata token
      end
      if line_ends_code? token
        statements << current_statement
        current_statement = nil
        self.state = nil
      end
      if line_starts_code? token
        self.state = :code_started
      end
      if line_is_code?(token) || line_is_whitespace?(token)
        current_statement.add_code token
      end
    end
    [program, statements]
  end
  
  private
  
  def self.line_is_program_definition?(line)
    return false if line.length < 1
    line_is_title?(line) && line.gsub(/\s/, '')[2].chr == "@"
  end
  
  def self.line_is_title?(line)
    c = line.length
    return false if c < 4
    line[0].chr == '=' && line[1].chr == '=' && line[2].chr != '=' &&
    line[c - 1].chr == '=' && line[c - 2].chr == '=' && line[c - 3].chr != '='
  end
  
  def self.line_is_comment?(line)
    self.state == :has_title && !line_is_title?(line) && !line_is_metadata?(line) && !line_starts_code?(line) && !line_is_code?(line) && !line_ends_code?(line)
  end
  
  def self.line_is_metadata?(line)
    return false if line.length < 2
    self.state == :has_title && line[0].chr == '@'
  end
  
  def self.line_starts_code?(line)
    return false if line.length < 1
    self.state == :has_title && line[0].chr == '-' && line.length == 1
  end
  
  def self.line_is_code?(line)
    return false if line.length < 1
    self.state == :code_started && !line_ends_code?(line)
  end
  
  def self.line_is_whitespace?(line)
    return self.state == :code_started && line.strip.length == 0
  end
  
  def self.line_ends_code?(line)
    return false if line.length < 1
    self.state == :code_started && line[0].chr == '-' && line.length == 1
  end
end
