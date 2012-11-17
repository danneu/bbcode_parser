require 'parslet'

class BBCode < Parslet::Parser
  TAGS = %w[b i u s font quote color left right center url]
  TAGS.each do |bbcode|
    rule(bbcode.to_sym) { str(bbcode) } 
  end
  rule(:space) { str(' ').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:newline) { (str("\r\n") | str("\n")) >> space? }
  rule(:whitespace) { (space | newline).repeat(1) }
  rule(:whitespace?) { whitespace.maybe }

  # === BBCODE OPTIONS ===
  # [bbcode=a;b;c] => options: [option, option, option]
  # [bbcode]       => options: [] 
  rule(:option) { match['a-zA-Z0-9 \:\/\.'].repeat(1) }
  rule(:option_delimiter) { str('=') | str(';') }
  rule(:options) { (option_delimiter >> option.as(:option)).repeat(1) }
  rule(:options?) { options.repeat(0, 1) }

  # === STRINGS - ALLOWED CHARACTERS ===
  rule(:printable_char) { match['[:word:]'] | match['[:punct:]'] | str('^') } # [Letters, numbers, underscores] [Punctuation and symbols]
  rule(:tag_options) { match['a-zA-Z0-9 '].repeat(1) }
  rule(:tag_name)    { match['a-zA-Z'].repeat(1) }
  #rule(:text){ (match["a-zA-Z\.\:\,\"\!\'"] | space).repeat(1).as(:text) | ((newline.as(:break) >> space?).repeat(1,2).as(:breaks) >> whitespace.maybe)  }
  #rule(:text){ (printable_char | space).repeat(1).as(:text) | ((newline.as(:break) >> space?).repeat(1,2).as(:breaks) >> whitespace.maybe)  }
  rule(:text){ (close.absent? >> block.absent? >> printable_char | space).repeat(1).as(:text) | ((newline.as(:break) >> space?).repeat(1,2).as(:breaks) >> whitespace.maybe)  }

  rule(:inline_tag) { b | i | url | u | s | color | font }
  rule(:block_tag) { quote | left | right | center }
  rule(:tag) { inline_tag | block_tag }
  rule(:inline_close) { str('[/') >> inline_tag.as(:close) >> str(']') }

  # We distinguish between inline [b][/b] tags and block [quote][/quote] tags 
  # so that block tags eat newlines instead of replacing them with <br>. 
  # This is because users don't intend to add linebreaks when they're just
  # spacing out their text after a block:
  #
  # +---Example Post 1------------+ OUTPUT -->
  # | [quote=Barack Obama]        | <div class="quote">
  # |   I am the president.       |   I am the president
  # | [/quote]                    | </div> <-- User didn't intend for additional vertical spacing 
  # |                             | I agree!
  # | I agree!                    |
  # +-----------------------------+
  # +---Example Post 2------------+
  # | [b]I am the president.[/b]  | <strong>I am the president.</strong>
  # |                             | <br /><br /> <-- User intended this vertical spacing
  # | I agree!                    | I agree!
  # |                             |
  # |                             |
  # +-----------------------------+

  rule(:block_close){ str('[/') >> block_tag.as(:close) >> str(']') >> (space | newline.repeat(1)).maybe }
  rule(:open) { str('[') >> tag.as(:open) >> options?.as(:options) >> str(']') >> (space | newline.repeat(1)).maybe }
  rule(:close) { block_close | inline_close }
    

  #rule(:block) { (open >> (block | text >> (space | newline.repeat(1)).maybe).repeat.as(:inner) >> whitespace.maybe >> close) }
  rule(:block) { (open >> (block | text).repeat.as(:inner) >> whitespace? >> close) }
  rule(:body) { (block | text).repeat.as(:body) }
  root(:body)

  def self.parse(str)
    new.parse(str, reporter: Parslet::ErrorReporter::Deepest.new)
  rescue Parslet::ParseFailed => failure
    puts failure.cause.ascii_tree
    "Parse Error: " << failure.cause.ascii_tree
  end
end
