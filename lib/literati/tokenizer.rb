module Parser

  def self.tokenize input_file
    tokens = []
    # tokens are lines in literati
    File.readlines(input_file).each do |line|
      tokens << line.gsub("\n", '')
    end
    tokens
  end

end