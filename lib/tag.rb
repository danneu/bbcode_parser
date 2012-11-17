class Tag
  attr_accessor :name, :options

  def initialize(name, options = nil)
    @name = name.downcase
    @options = options if options
  end

  def wrap(text)
    case @name
    when "img"    then %{"<img src="#{text}" />}
    when "i"      then %{<em>#{text}</em>}
    when "b"      then %{<strong>#{text}</strong>}
    when "u"      then %{<span class="underline">#{text}</span>}
    when "center" then %{<center>#{text}</center>}
    when "size"   then %{<span class="size-#{options.first}">#{text}</span>}
    when "quote" 
      if options.count == 0
        %{
<div class="quote">
  <div class="quote-original-poster">
    Quote:
  </div>
  <div class="quote-text">
    #{text}
  </div>
</div>
        }
      elsif options.count == 1
        %{
<div class="quote">
  <div class="quote-original-poster">
    Originally posted by <a href="#">#{options.first}</a>
  </div>
  <div class="quote-text">
    #{text}
  </div>
</div>
        }
        #}.split("\n").map(&:strip).join
      elsif options.count == 2
        %{
<div class="quote">
  <div class="quote-original-poster">
    Originally posted by <a href="#">#{options.first}</a> (<a href="posts/#{options.last}">Go to post</a>)
  </div>
  <div class="quote-text">
    #{text}
  </div>
</div>
        }
        #}.each_line.map { |l| l[8..-1] }.join
        #}.split("\n").map(&:strip).join
      end
    end # /case
  end # /def

end
