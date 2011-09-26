#! /usr/bin/env ruby

$: << '.' unless $:.include?('.')
require 'lib/tokenizer'
require 'lib/lexer'
require 'lib/linker'

input_file = ARGV[0]

tokens = Parser::tokenize input_file
program, statements = Parser::lex tokens
statements = Parser::link statements
program.write(statements)