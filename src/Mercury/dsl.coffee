mercury = require "mercury"
_       = require "lodash"

# A tiny DSL that exports an object which lets you do this:
#
# {div, span} = dsl
#
# div  {id: "foo"}, [childrenGoHere]
# span {id: "bar"}, ["some text or something"]
#
# ...instead of calling mercury.h "div", {id: "foo"} etc.

supportedElems = ["div", "span", "ul", "ol", "li"]

module.exports = _.object _.map supportedElems, (elem) ->
  [elem, mercury.h.bind mercury, elem]
