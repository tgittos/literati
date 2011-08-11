#! /usr/bin/env ruby

input_file = ARGV[0]
lines = []
File.readlines(input_file).each { |line|
  lines << line
}

section_list = []
in_section = false

lines.each_with_index do |line, i|
  # find blocks of docs + code
  if line =~ /^==\s([^=]*)\s?==$/
    if !in_section
      # start of header
      section_list << { :start => i }
      in_section = true
    else
      # start of next header/end of section
      section_list.last[:end] = i - 1
      in_section = false
    end
  end
end

# parse sections, splitting docs from code
# and marking any API comments (api)
# and any code that needs printing (pc)
section_list.each do |section|
  in_comment = false
  in_code = false
  section[:end] = lines.length - 1 if section[:end].nil?
  (section[:start]..section[:end]).each do |index|
    line = lines[index]
    if in_code
      section[:code] = "" if section[:code].nil?
      section[:code] << line
    else
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
      if line =~ /^==\s([^=]*)\s?==$/
        section[:identifier] = lines[index].gsub /\n/, ''
        in_comment = true
      end
    end
  end
end

section_list.each do |section|
  puts section.inspect
end