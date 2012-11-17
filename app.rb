require "lib/parser"
require "lib/transformer"
require "lib/tag"
require "sinatra"
require "parslet"
require "sass"
require "pp"
require "awesome_print"

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  def parse(bbcode)
    transformer = BBCodeTransformer.new
    transformer.apply(BBCode.parse(bbcode))
  end
  def tree(bbcode)
    BBCode.parse(bbcode)
  end
end

get("/stylesheet.css") { scss :stylesheet }
get("/bbcode.css")     { scss :bbcode }
get("/syntax.css")     { scss :syntax }
get "/" do
  if @bbcode = params[:bbcode]
    @tree = tree(@bbcode) 
    @html = parse(@bbcode) 
  end
  scss :stylesheet, :style => :expanded
  erb :index
end
