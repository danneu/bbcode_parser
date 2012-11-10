require 'parslet'

class BBCodeTransformer < Parslet::Transform
  rule(option: simple(:str)) { String(str) }
  rule(open: simple(:tr)) { String(tr) }
  rule(text: simple(:text)) { String(text) }
  rule(break: simple(:br)) { "<br />" }
  rule(breaks: sequence(:brs)) { brs.join }
  rule(
    open: simple(:name),
    options: sequence(:options),
    inner: sequence(:inner),
    close: simple(:close)
  ) { Tag.new(name.to_s, options).wrap(inner.join) }
  rule(body: sequence(:strings)) { strings.join }
end
