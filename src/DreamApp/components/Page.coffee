LeftSidebar  = require "./LeftSidebar.coffee"
Editor       = require "./Editor.coffee"
RightSidebar = require "./RightSidebar.coffee"
React        = require "react"

{div} = require "../../React/dsl.coffee"

module.exports = Page = React.createClass
  render: -> renderPage @props.currentDoc, @props.notes

renderPage = (currentDoc, notes) ->
  div {id: "page"}, [
    renderBackdrop()

    (LeftSidebar.render currentDoc)
    (Editor.render currentDoc)
    (RightSidebar.render notes)
  ]

renderBackdrop = ->
  (div {className: "backdrop", key: "backdrop"}, [
    (div {key: "backdrop-tl", className: "backdrop-quadrant backdrop-top backdrop-left"})
    (div {key: "backdrop-bl", className: "backdrop-quadrant backdrop-bottom backdrop-left"})
    (div {key: "backdrop-tr", className: "backdrop-quadrant backdrop-top backdrop-right"})
    (div {key: "backdrop-br", className: "backdrop-quadrant backdrop-bottom backdrop-right"})
  ])
