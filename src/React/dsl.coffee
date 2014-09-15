React = require "react"
_     = require "lodash"

# A tiny DSL that exports an object which lets you do this:
#
# {div, span} = dsl
#
# div  {id: "foo"}, [childrenGoHere]
# span {id: "bar"}, ["some text or something"]
#
# ...instead of calling React.DOM.div {id: "foo"} etc.

supportedElems = ["a", "b", "i", "div", "span", "ul", "ol", "li"]
module.exports = _.object _.map supportedElems, (elem) ->
  [elem, React.DOM[elem].bind(React.DOM)]
