#! /usr/bin/env ruby

$: << '.' unless $:.include?('.')
require 'find'
require 'lib/tokenizer'
require 'lib/lexer'
require 'lib/linker'

if ARGV.length < 1
  abort "Usage: literati.rb [tangle|weave] [input_file]"
end

# sanity check on mode
mode = ARGV.shift
abort "I don't know how to '#{mode}'" unless Parser::Program.method_defined? mode

# gather paths
input_files = []
ARGV << './' if ARGV.empty?
ARGV.each do |arg|
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

abort "Couldn't find path '#{input}'. Are you sure it's correct?" if input_files.empty?

puts "#{mode.chop}ing:\n#{input_files.join("\n")}"

input_files.each do |file|
  tokens = Parser::tokenize file
  program, statements = Parser::lex tokens
  statements = Parser::link statements
  program.send(mode.to_sym, statements)
end
