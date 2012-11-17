require 'parslet'

class BBCode < Parslet::Parser
  rule(:space) { str(' ').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:newline) { (str("\r\n") | str("\n")) >> space? }
  #rule(:newline) { (str("\r\n") | str("\n")) }
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
  rule(:text){ (match['a-zA-Z\.\:\,'] | space).repeat(1).as(:text) | (((str("\r\n") | str("\n")).as(:break) >> space?).repeat(1,2).as(:breaks) >> whitespace.maybe)  }

  #rule(:close) { str('[/') >> tag_name.as(:close) >> str(']') }

  rule(:b) { str("b") }
  rule(:i) { str("i") }
  rule(:u) { str("u") }
  rule(:quote) { str("quote") }
  rule(:inline_tag) { b | i | u }
  rule(:block_tag) { quote }
  rule(:tag) { inline_tag | block_tag }
  rule(:inline_close) { str('[/') >> inline_tag.as(:close) >> str(']') }
  # We distinguish between inline [b][/b] tags and block [quote][/quote] tags so
  # that block tags eat a few newlines.
    #rule(:block_close){ str('[/') >> block_tag.as(:close) >> str(']') >> whitespace.maybe }
  # Just consume up to two newlines to still let user add more spacing. 
  rule(:block_close){ str('[/') >> block_tag.as(:close) >> str(']') >> (space | newline.repeat(1)).maybe }
  rule(:open) { str('[') >> tag.as(:open) >> options?.as(:options) >> str(']') >> (space | newline.repeat(1)).maybe }
  rule(:close) { block_close | inline_close }
    

  rule(:block) { (open >> (block | text >> (space | newline.repeat(1)).maybe).repeat.as(:inner) >> whitespace.maybe >> close) }
  rule(:body) { (block | text).repeat.as(:body) }
  root(:body)

  def self.parse(str)
    new.parse(str)
  rescue Parslet::ParseFailed => failure
    puts failure.cause.ascii_tree
  end
end
