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
      nested_result = get_code_for section_list, section[:code]
      return nested_result unless nested_result.nil?
      return section[:code]
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
    code_string = ""
    section[:code].each_with_index do |line, i|
      code_for = get_code_for section_list, line.strip
      code_string << code_for unless code_for.nil?
      code_string << line if code_for.nil?
    end
    section[:code] = code_string
  end
end

if program[:identifiers].nil?
  return
end

code = ""
program[:identifiers].each do |identifier|
  code += get_code_for section_list, identifier
end

File.open(program[:filename], 'w') { |f| f.write(code) }