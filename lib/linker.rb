module Parser

  def self.link(statements)
    code_map = {}
    statements.each do |statement|
      next if !(statement.respond_to?(:get_code) && statement.respond_to?(:get_title))
      code_map[statement.get_title] = statement
    end
    statements.each do |statement|
      next if !(statement.respond_to?(:get_code) && statement.respond_to?(:get_title)) || statement.get_code.nil?
      code = statement.get_code
      code.each_with_index do |line, i|
        if line[line.length - 1] == '.'
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