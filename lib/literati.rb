require 'find'
require 'literati/tokenizer'
require 'literati/lexer'
require 'literati/linker'

class Literati

  def self.process(command, files)

    # sanity check on inputs
    if command.nil?
      puts "Usage: literati.rb [tangle|weave] [input_file]"
      return
    end

    # sanity check on command
    unless Parser::Program.method_defined? command
      puts "I don't know how to '#{command}'"
      return
    end

    input = gather_paths(files)
    # sanity check files
    if input.empty?
      puts "Couldn't find path/s '#{input.join(', ')}'. Are you sure it's correct?"
      return
    end

    puts "#{command.chop}ing:\n#{input.join("\n")}"

    input.each do |file|
      tokens = Parser::tokenize file
      program, statements = Parser::lex tokens
      statements = Parser::link statements
      program.send(command.to_sym, statements)
    end

  end

  private

  def self.gather_paths(files)
    input_files = []
    files << './' if files.empty?
    files.each do |arg|
      next if not File.exists?(arg)
      if !File.directory?(arg)
        input_files << arg if File.basename(arg) =~ /\.lit$/i
      else
        Find.find(arg) do |path|
          next if File.directory? path
          input_files << path if File.basename(path) =~ /\.lit$/i
        end
      end
    end
    input_files
  end

end
