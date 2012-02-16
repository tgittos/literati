module Parser
  class Program
  
    def initialize(lines)
      @refs = []
      convert_title_to_filename lines.first
      lines.shift
      @refs = lines.dup
      @base_output_dir = File.join(Dir.pwd, 'output')
      @base_tangle_dir = File.join(@base_output_dir, 'src')
      @base_weave_dir = File.join(@base_output_dir, 'doc')
    end
  
    def weave(statements, path = nil)
      require 'lib/formatter/text' # this is hard coded, but should be passed in
      Dir.mkdir(@base_output_dir) if not File.exists?(@base_output_dir)
      Dir.mkdir(@base_weave_dir) if not File.exists?(@base_weave_dir)
      build_dir_structure(@filename, @base_weave_dir)
      filename = File.join(@base_weave_dir, @filename.gsub(/\.rb/,''))
      comment = Formatter::format(statements)
      File.open("#{filename}.txt", 'w') {|f| f.write(comment) } unless comment.nil?
    end
  
    def tangle(statements, path = nil)
      Dir.mkdir(@base_output_dir) if not File.exists?(@base_output_dir)
      Dir.mkdir(@base_tangle_dir) if not File.exists?(@base_tangle_dir)
      build_dir_structure(@filename, @base_tangle_dir)
      filename = File.join(@base_tangle_dir, @filename)
      buffer = []
      map = build_code_map(statements)
      @refs.each do |ref|
        buffer.concat map[ref.gsub('.', '').strip].get_code
      end
      File.open(filename, 'w') do |file|
        buffer.each { |line| file.write("#{line}\n") }
      end
    end
  
    def all(statements)
      weave(statements)
      tangle(statements)
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
  
    def build_dir_structure(name, base)
      # handle both Windows and *nix file structures
      dirs = name.split(/[\/\\]/)
      current_path = ""
      dirs.each_with_index do |dir, i|
        break if i == dirs.length - 1 # skip the last one as it's a filename
        path = File.join(base, current_path, dir)
        Dir.mkdir(path) unless File.exists?(path)
        current_path = File.join(current_path, dir)
      end
    end
  
  end
end
