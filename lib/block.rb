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

    def get_code
      @code
    end

    def add_comment(comment)
      @comments = [] if @comments.nil?
      @comments << comment
    end

    def add_code(code)
      @code = [] if @code.nil?
      @code << code
    end

    def is_comment_only?
      !@comments.nil? && @code.nil?
    end

    def parse_metadata(data)
      # decide what to do here later
      data.gsub!(/@/, '')
      flags = data.split(',')
      flags.each do |flag|
        flag.strip!
        # handle flag
      end
    end

  end

end