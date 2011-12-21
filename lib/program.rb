module Parser

  class Program

    def initialize(lines)
      @refs = []
      convert_title_to_filename lines.first
      lines.shift
      @refs = lines.dup
    end

    def weave(statements, path = nil)
      require 'lib/formatter/text' # this is hard coded, but should be passed in
      filename = @filename.gsub(/\.rb/,'')
      comment = Formatter::format(statements)
      File.open("#{filename}.txt", 'w') {|f| f.write(comment) } unless comment.nil?
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
