module Parser

  class Program

    def initialize(lines)
      @refs = []
      convert_title_to_filename lines.first
      lines.shift
      @refs = lines.dup
    end

    def weave(statements, path = nil)
      filename = @filename.gsub(/\.rb/,'')
      File.open("#{filename}.txt", 'w') do |file|
        statements.each do |statement|
          next if !(statement.respond_to?(:get_code) && statement.respond_to?(:get_title))
          next if statement.get_comments.nil? || statement.get_title.nil?

          comment = statement.get_title + "\n" + ("-" * statement.get_title.length) + "\n\n"
          comment += statement.get_comments.join("\n")
          file.write "#{comment}\n\n" unless comment.nil?
        end
      end
    end

    def tangle(statements, path = nil)
      # at the moment, lets just hardcode writing a code file
      buffer = []
      map = build_code_map(statements)
      @refs.each do |ref|
        buffer.concat map[ref.gsub('.', '').strip].get_code
      end
      File.open(@filename, 'w') do |file|
        buffer.each { |line| file.write("#{line}\n") }
      end
    end

    private

    def convert_title_to_filename(title)
      @filename = title.gsub(/[=|\s|@]/, '')
    end
    def build_code_map(statements)
      code_map = {}
      statements.each do |statement|
        next if !(statement.respond_to?(:get_code) && statement.respond_to?(:get_title))
        code_map[statement.get_title] = statement
      end
      code_map
    end
    
  end

end
