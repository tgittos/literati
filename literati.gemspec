Gem::Specification.new do |s|
  s.name        = 'literati'
  s.version     = '0.0.1'
  s.date        = '2012-05-02'
  s.summary     = "Literati is a language agnostic literate programming tool written in Ruby"
  s.description = "More to come later"
  s.authors     = ["Tim Gittos"]
  s.email       = 'gems@timgittos.com'
  s.files       = [ "lib/literati.rb",
                    "lib/literati/block.rb",
                    "lib/literati/lexer.rb",
                    "lib/literati/linker.rb",
                    "lib/literati/program.rb",
                    "lib/literati/tokenizer.rb",
                    "lib/formatter/text.rb"
                  ]
  s.executables << 'literati'
  s.homepage    =
    'http://www.timgittos.com/projects/literati'
end