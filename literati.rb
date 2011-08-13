#! /usr/bin/env ruby

section_list = []
in_section = false

input_file = ARGV[0]
lines = []
File.readlines(input_file).each { |line|
  lines << line
}

def get_code_for section_list, identifier
  identifier.chomp! '.'
  section_list.each do |section|
    if section[:identifier] == identifier
      #puts "found #{identifier}"
      # code is an array of lines
      nested_result = []
      section[:code].each do |line|
        code_for_nested = get_code_for section_list, line
        nested_result << code_for_nested unless code_for_nested.nil?
        nested_result << line if code_for_nested.nil?
      end
      return nested_result
    end
  end
  nil
end

lines.each_with_index do |line, i|
  # find blocks of docs + code
  if line =~ /^==\s([^=]*)\s?==/
      if !section_list.last.nil?
        section_list.last[:end] = i - 1
      end
      section_list << { :start => i }
  end
end

program = {}

# parse sections, splitting docs from code
# and marking any API comments (api)
# and any code that needs printing (pc)
section_list.each do |section|
  in_comment = false
  in_code = false
  in_program = false
  section[:end] = lines.length - 1 if section[:end].nil?
  (section[:start]..section[:end]).each do |index|
    line = lines[index]
    if in_code
      section[:code] = [] if section[:code].nil?
      section[:code] << line
    end
    if in_program
      program[:identifiers] = [] if program[:identifiers].nil?
      program[:identifiers] << line.gsub(/\n/, '')
    end
    if in_comment
      if line =~ /^@/
        # should tokenize this instead of string search
        section[:api] = true if line =~ /api/
        section[:pc] = true if line =~ /pc/
        in_comment = false
        in_code = true
      elsif line.strip.empty?
        in_code = true
      else
        section[:comment] = "" if section[:comment].nil?
        section[:comment] << line
      end
    else
    end
    if !in_comment && !in_code && !in_program
      if line =~ /^==\s?([^=]*)\s?==$/
        if line =~ /^==\s?@/
          section_list.delete section
          program[:filename] = line.match(/^==\s?@\s?([^=]*)\s?==/)[1].strip
          in_program = true
        else
          section[:identifier] = lines[index].gsub('=', '').gsub(/\n/, '').strip
          in_comment = true
        end
      end
    end
  end
end

# now parse through and replace lines that ref sections
section_list.each do |section|
  if !section[:code].nil?
    code_array = []
    section[:code].each_with_index do |line, i|
      #puts "getting code for #{line}"
      code_for = get_code_for section_list, line.strip
      if !code_for.nil?
        #puts "doing substitution: #{line} for #{code_for}"
        # TODO: Insert leading spaces on every line of the substituted code
        leading_spaces = 0
        line.each_char{|l| if l == ' ' then leading_spaces += 1 else break end }
        code_for.each { |line| code_array << ((" " * leading_spaces) << line) }
      else
        code_array << line
      end
    end
    section[:code] = code_array
  end
end

if program[:identifiers].nil?
  return
end

code = ""
program[:identifiers].each do |identifier|
  code += get_code_for(section_list, identifier).join('')
end

File.open(program[:filename], 'w') { |f| f.write(code) }