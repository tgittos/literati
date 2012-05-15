module Parser

  def self.link(program, statements)
    if program.has_flag?('inherit')
      path = program.flag_value('inherit')
      path = File.join(File.dirname(program.source), path)
      file = Literati.gather_paths([path]).first
      inherited_tokens = Parser::tokenize file
      inherited_program, inherited_statements = Parser::lex inherited_tokens
      statements_to_skip = inherited_statements.select{|s| s.get_code.nil?}.map{|s| s.get_title} | (inherited_statements.map{|s| s.get_title} & statements.map{|s| s.get_title})
      inherited_statements.each{|s| s.inherited = true; statements << s unless statements_to_skip.include?(s.get_title)}
    end
    code_map = {}
    statements.each do |statement|
      next if !(statement.respond_to?(:get_code) && statement.respond_to?(:get_title))
      code_map[statement.get_title] = statement
    end
    statements.each do |statement|
      next if !(statement.respond_to?(:get_code) && statement.respond_to?(:get_title)) || statement.get_code.nil?
      code = statement.get_code
      code.each_with_index do |line, i|
        if line.length > 0 && line[line.length - 1].chr == '.'
          #could be a reference
          replacement = code_map[line.gsub('.', '').strip]
          if !replacement.nil?
            indent = 0
            line.each_char{|c| if c == ' ' then indent += 1 else break end }
            code.delete_at i
            replacement.get_code.reverse.each do |replacement_line|
              code.insert(i, (" " * indent) << replacement_line)
            end
          end
        end
      end
    end
    statements
  end

end
