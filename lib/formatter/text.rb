module Formatter
  def self.format(statements)
    comment = ""
    statements.each do |statement|
      next if !(statement.respond_to?(:get_code) && statement.respond_to?(:get_title))
      next if statement.get_comments.nil? || statement.get_title.nil?
  
      comment += statement.get_title + "\n" + ("-" * statement.get_title.length) + "\n"
      comment += statement.get_comments.join("\n")
      if (statement.has_flag?('code'))
        comment += "\n\nCode:\n\n" + statement.get_code.join("\n")
        comment += "\n"
      end
      comment += "\n\n"
    end
    comment
  end
end
