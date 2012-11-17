# Ruby BBCode Parser

* Work in progress
* Live demo: [http://bbcode.herokuapp.com][demo]
* PEG Parser built with [Parslet](http://kschiess.github.com/parslet/)
* Intended to reasonably emulate vBulletin's BBCode

[demo]: http://bbcode.herokuapp.com/


## Supported BBCode (so far)

**For an intuitive inventory, view the cheatsheet on the [live demo][demo].**

* [b]bold[/b]
* [i]italicize[/i]
* [u]underline[/u]
* [s]strikethrough[/s]
* [quote]text[/quote]
* [quote=Barack Obama]text with username reference[/quote]
* [quote=Barack Obama;2342]text with username and post ID reference[/quote]
* [left]left-align[/left]
* [right]right-align[/right]
* [center]center-align[/center]
* [color=blue]colored text[/color]
* [url]http://google.com[/url]
* [url=http://google.com]Click Me![/url]
* [img]http://website.com/image.jpg[/img]

## How it works

1. The parser (lib/parser.rb), where the grammar rules are defined, reads a string of user text and outputs a syntax tree.

       [b]hello[/b]goodbye
       
   …becomes:
   
       body:
         open: "b"
         inner: [
           text: "hello"
         ]
         close: "b"
         text: "goodbye"
         
* The transformer (lib/transformer.rb) applies transformation rules to the tree by starting at the tree's leaves/subtrees and collapsing them into strings/html.

    For example, if this is the tree sent to the transformer:
    
        body:
          open: "b"
          inner: [
            text: "hello"
          ]  
          cose: "b"
          
    …first, `inner: { text: "hello" }` is collapsed into `inner: ["hello"]` because of the rule that collapses text nodes into strings:
    
        body:
          open: "b"
          inner: ["hello"]
          close: "b"
          
    …which now matches another transformation rule pattern: `open:string, inner:sequence, close:string`.
    
* Whenever the transformer finds an open/inner/close subtree, it instantiates it into a Tag (lib/tag.rb) object that contains the actual BBCode to HTML transformation.

        open: "b"
        inner: ["hello"]
        close: "b"
        
    …instantiates a Tag like this:
    
        Tag.new("b").wrap(inner.join)
        
    …which outputs 
    
        <strong>hello</strong>
        
* It keeps collapsing all the nodes into strings until it has one final string to return.

## TODO/Caveats/Stuff I can't figure out yet

* Sanitize user input. Make sure they can't do weird stuff.
* Limit nesting so users can't go too crazy.
* Handle mismatched or overlapped tags. For instance, 

        [b]abc [i]def[/b] ghi[/i]
        
    Should become:
    
        <strong>abc <em>def</strong> ghi</em>
        
    But at the moment the parser produces a tree like:
    
        open: "b"
        inner:
          text: "abc"
          open: "i"
            inner:
              text: "def"
          text: "ghi"
          close: "b"
        close: "i"

* Parser is just too simplistic and nonrobust.

    This works:
    
        [b]no close tag
        
    …becomes a 'text' node since text only fails if lookahead finds a [/closing tag].
    
    Which means that this fails:
    
        [/b]no open tag
        
    Instead, orphan tags that don't form blocks should just be output as text.
* Write tests. :'(
