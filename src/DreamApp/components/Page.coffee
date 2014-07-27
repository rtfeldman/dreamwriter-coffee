LeftSidebar  = require "./LeftSidebar.coffee"
Editor       = require "./Editor.coffee"
RightSidebar = require "./RightSidebar.coffee"

{div} = require "../../Mercury/dsl.coffee"

module.exports = Page =
  render: (state) ->
    div {id: "page"}, [
      renderBackdrop()

      (LeftSidebar.render state.currentDoc)
      (Editor.render state)
      (RightSidebar.render state)
    ]

renderBackdrop = ->
  (div {className: "backdrop"}, [
    (div {className: "backdrop-quadrant backdrop-top backdrop-left"})
    (div {className: "backdrop-quadrant backdrop-bottom backdrop-left"})
    (div {className: "backdrop-quadrant backdrop-top backdrop-right"})
    (div {className: "backdrop-quadrant backdrop-bottom backdrop-right"})
  ])
