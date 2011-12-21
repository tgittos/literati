module Parser
  class Block
    def initialize(title)
      @title = title.gsub(/\=/, '').strip
    end
    def get_title
      @title
    end
    def get_comments
      @comments
    end
    def add_comment(comment)
      @comments = [] if @comments.nil?
      @comments << comment
    end
    def get_code
      @code
    end
    def add_code(code)
      @code = [] if @code.nil?
      @code << code
    end
    def has_flag?(flag)
      return false if @flags.nil?
      @flags.include?(flag)
    end
    def is_comment_only?
      !@comments.nil? && @code.nil?
    end
    def parse_metadata(data)
      data.gsub!(/@/, '')
      @flags = data.split(',')
      @flags.each do |flag|
        flag.strip!
      end
    end
  end
end
