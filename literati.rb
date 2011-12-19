#! /usr/bin/env ruby

$: << '.' unless $:.include?('.')
require 'lib/tokenizer'
require 'lib/lexer'
require 'lib/linker'

if ARGV.length < 2
  abort "Usage: literati.rb [tangle|weave] input_file"
end

mode = ARGV[0]
input_file = ARGV[1]

abort "I don't know how to '#{mode}'" unless Parser::Program.method_defined? mode

tokens = Parser::tokenize input_file
program, statements = Parser::lex tokens
statements = Parser::link statements
program.send(mode.to_sym, statements)