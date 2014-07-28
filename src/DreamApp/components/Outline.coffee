React = require "react"

{div, span, ul, li} = require "../../React/dsl.coffee"

module.exports = Outline = React.createClass
  render: -> Outline.renderOutline @props.chapters

Outline.renderOutline = (chapters) ->
  (ul {id: "outline"},
    (chapters.map (chapter, index) ->
      (li {key: "chapter#{index}"}, [chapter.heading])
    ))
