module Parser
  class Program
  
    attr_accessor :source
  
    def initialize(lines, metadata = [])
      @flags = metadata
      @refs = []
      convert_title_to_filename lines.first
      lines.shift
      @refs = lines.dup
      @base_output_dir = File.join(Dir.pwd, 'output')
      @base_tangle_dir = File.join(@base_output_dir, 'src')
      @base_weave_dir = File.join(@base_output_dir, 'doc')
    end
  
    def weave(statements, path = nil)
      require 'formatter/text' # this is hard coded, but should be passed in
      output_path = @base_weave_dir
      output_path = File.join(Dir.pwd, path) unless path.nil?
      Dir.mkdir(@base_output_dir) if !File.exists?(@base_output_dir) && path.nil?
      Dir.mkdir(output_path) if !File.exists?(output_path)
      build_dir_structure(@filename, output_path)
      filename = File.join(output_path, @filename.gsub(/\.rb/,''))
      comment = Formatter::format(statements)
      File.open("#{filename}.txt", 'w') {|f| f.write(comment) } unless comment.nil?
    end
  
    def tangle(statements, path = nil)
      output_path = @base_tangle_dir
      output_path = File.join(Dir.pwd, path) unless path.nil?
      Dir.mkdir(@base_output_dir) if !File.exists?(@base_output_dir) && path.nil?
      Dir.mkdir(output_path) if !File.exists?(output_path)
      build_dir_structure(@filename, output_path)
      filename = File.join(output_path, @filename)
      buffer = []
      map = build_code_map(statements)
      @refs.each do |ref|
        section = map[ref.gsub('.', '').strip]
        raise "Cannot find reference #{ref} in #{source}" if section.nil?
        buffer.concat section.get_code
      end
      if not_changed? source, filename
        puts "#{source} unchanged, skipping"
        return
      end
      File.open(filename, 'w') do |file|
        buffer.each { |line| file.write("#{line}\n") }
      end
    end
  
    def all(statements, path = nil)
      weave(statements, path)
      tangle(statements, path)
    end
  
    def has_flag?(flag)
      return false if @flags.nil?
      return @flags.select{|f| f =~ /^#{flag}/}.length == 1
    end
  
    def flag_value(flag)
      @flags.each do |f|
        return f.split(' ').last.strip if f =~ /^#{flag}/
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
  
    def not_changed?(input, output)
      File.mtime(output) > File.mtime(input) if File.exists? output
    end
  
  end
end
