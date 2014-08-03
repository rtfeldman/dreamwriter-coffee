LeftSidebar  = require "./LeftSidebar.coffee"
Editor       = require "./Editor.coffee"
RightSidebar = require "./RightSidebar.coffee"
React        = require "react"
DreamDoc     = require "../../DreamDoc/DreamDoc.coffee"

{div} = require "../../React/dsl.coffee"

module.exports = Page = React.createClass
  getInitialState: -> {currentDoc: @props.initialDoc}
  render: ->
    onMutate = (mutations, contentDocument) =>
      @setState {currentDoc: DreamDoc.fromHtmlDoc contentDocument}

    renderPage @state.currentDoc, @props.notes, onMutate

renderPage = (currentDoc, notes, onMutate) ->
  editor = Editor
    doc: currentDoc
    mutationObserverOptions: {childList: true, attributes: true, characterData: true, subtree: true}
    onLoad: (error) ->
      if error
        console.error "Attempted to load HTML document into editor but got error:", error

    onMutate: onMutate

  div {id: "page"}, [
    renderBackdrop()

    (LeftSidebar.render currentDoc)
    editor
    (RightSidebar.render notes)
  ]

renderBackdrop = ->
  (div {className: "backdrop", key: "backdrop"}, [
    (div {key: "backdrop-tl", className: "backdrop-quadrant backdrop-top backdrop-left"})
    (div {key: "backdrop-bl", className: "backdrop-quadrant backdrop-bottom backdrop-left"})
    (div {key: "backdrop-tr", className: "backdrop-quadrant backdrop-top backdrop-right"})
    (div {key: "backdrop-br", className: "backdrop-quadrant backdrop-bottom backdrop-right"})
  ])
