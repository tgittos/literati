require 'find'
require 'literati/tokenizer'
require 'literati/lexer'
require 'literati/linker'

class Literati

  def self.process(command, args)

    # sanity check on inputs
    if command.nil?
      puts "Usage: literati.rb [tangle|weave] [-o path/to/output] [input_file]"
      return
    end
    
    # sanity check on command
    unless Parser::Program.method_defined? command
      puts "I don't know how to '#{command}'"
      return
    end

    output_index = args.index '-o'
    if !output_index.nil?
      output_dir = args.delete_at output_index+1
      args.delete '-o'
    end
    files = args.dup

    input = gather_paths(files)

    if input.empty?
      puts "Couldn't find path/s '#{input.join(', ')}'. Are you sure it's correct?"
      return
    end

    puts "#{command.chop}ing:\n#{input.join("\n")}"

    input.each do |file|
      tokens = Parser::tokenize file
      program, statements = Parser::lex tokens
      program.source = file
      statements = Parser::link program, statements
      program.send(command.to_sym, statements, output_dir)
    end

  end

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
