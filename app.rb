require "lib/parser"
require "lib/transformer"
require "lib/tag"
require "sinatra"
require "parslet"
require "sass"

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  def parse(bbcode)
    transformer = BBCodeTransformer.new
    transformer.apply(BBCode.parse(bbcode))
  end
end

get("/stylesheet.css") { scss :stylesheet }
get("/bbcode.css")     { scss :bbcode }
get "/" do
  @bbcode = params[:bbcode]
  @html = parse(params[:bbcode]) if @bbcode
  scss :stylesheet, :style => :expanded
  erb :index
end

__END__

@@ index
<form action="/" method="get">
  <textarea rows=10 name="bbcode" placeholder="Insert BBCode"><%= @bbcode %></textarea>
  <input type="submit" value="Convert to HTML" />
</form>
<hr />

<h2>HTML</h2>
<pre class="output html">
  <%=h @html %>
</pre>

<h2>Rendered</h2>
<div class="output rendered">
<%= @html %>
</div>

@@ layout
<link rel="stylesheet" type="text/css" href="stylesheet.css" />
<link rel="stylesheet" type="text/css" href="bbcode.css" />
<h1>BBCode → HTML</h1>
<%= yield %>

@@ stylesheet
textarea      { width: 50%; display: block; }
.output       { padding: 10px; }
.html         { background: #ccc; }
.rendered     { border: 1px solid black; }

@@ bbcode
.underline { 
  text-decoration: underline; 
}
.quote {
  border: 1px solid black;
  margin: 10px;
  .quote-original-poster { 
    padding: 5px;
    border-bottom: 1px solid black; 
  }
  .quote-text {
    padding: 5px;
  }
}

