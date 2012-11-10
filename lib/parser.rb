require 'parslet'

class BBCode < Parslet::Parser
  rule(:space) { str(' ').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:newline) { (str("\r\n") | str("\n")) >> space? }
  rule(:whitespace) { (space | newline).repeat(1) }

  # === BBCODE OPTIONS ===
  # [bbcode=a;b;c] => options: [option, option, option]
  # [bbcode]       => options: [] 
  rule(:option) { match['a-zA-Z0-9 '].repeat(1) }
  rule(:option_delimiter) { str('=') | str(';') }
  rule(:options) { (option_delimiter >> option.as(:option)).repeat(1) }
  rule(:options?) { options.repeat(0, 1) }

  # === STRINGS - ALLOWED CHARACTERS ===
  rule(:tag_options) { match['a-zA-Z0-9 '].repeat(1) }
  rule(:tag_name)    { match['a-zA-Z'].repeat(1) }
  rule(:text){ (match['a-zA-Z\.\:\,'] | space).repeat(1).as(:text) | newline.as(:break).repeat(1).as(:breaks) }

  rule(:open) { str('[') >> tag_name.as(:open) >> options?.as(:options) >> str(']') }
  rule(:close) { str('[/') >> tag_name.as(:close) >> str(']') }

  rule(:block) { (open >> (text | block).repeat.as(:inner) >> close) }
  rule(:body) { (block | text).repeat.as(:body) }
  root(:body)

  def self.parse(str)
    new.parse(str)
  rescue Parslet::ParseFailed => failure
    puts failure.cause.ascii_tree
  end
end
