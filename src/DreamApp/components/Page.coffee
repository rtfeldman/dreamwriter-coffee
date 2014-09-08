LeftSidebar  = require "./LeftSidebar.coffee"
Editor       = require "./Editor.coffee"
RightSidebar = require "./RightSidebar.coffee"
React        = require "react"
DreamDoc     = require "../../DreamDoc/DreamDoc.coffee"
Dispatcher   = require "../AppActionDispatcher.coffee"
AppAction    = require "../AppAction.coffee"
DreamStore   = require "../DreamStore.coffee"

{div} = require "../../React/dsl.coffee"

module.exports = Page = React.createClass
  getInitialState: -> {currentDoc: undefined, currentSnapshot: undefined, currentNotes: undefined}

  componentDidMount: ->
    @props.dreamStore.listeners.on DreamStore.CHANGE_EVENT, @handleStoreChange

  componentWillUnmount: ->
    @props.dreamStore.off DreamStore.CHANGE_EVENT @handleStoreChange

  componentShouldUpdate: (nextProps, nextState) ->
    (@state.currentSnapshot.lastModified isnt nextState.currentSnapshot.lastModified) or
    (@state.currentDoc.lastModified      isnt nextState.currentDoc.lastModified)

  render: ->
    renderPage @state.currentDoc, @state.currentSnapshot, @state.currentNotes

  handleStoreChange: ->
    {dreamStore} = @props

    # TODO add granularity to store event listeners. We want to do different things
    # depending on whether current doc changes, other docs change, etc.

    # Refresh doc and snapshot
    # TODO parallelize this
    dreamStore.getCurrentDoc (doc) =>
      if doc
        dreamStore.getSnapshot doc.snapshotId, (snapshot) =>
          dreamStore.getSnapshot doc.notesId, (notes) =>
            @setState {currentDoc: doc, currentSnapshot: snapshot, currentNotes: notes}
      else
        @setState {currentDoc: undefined, currentSnapshot: undefined}

  handleStoreOpen: ->
    {dreamStore} = @props

    # TODO can we just pass the new doc through the Open event?
    dreamStore.getCurrentDoc (doc) =>
      if doc
        dreamStore.getSnapshot doc.snapshotId, (snapshot) =>
          @setState {currentDoc: doc, currentSnapshot: snapshot}
      else
        @setState {currentDoc: undefined, currentSnapshot: undefined}

renderPage = (doc, snapshot, notes) ->
  editor = Editor
    snapshot: snapshot

  div {id: "page"}, [
    renderBackdrop()

    (LeftSidebar.render doc)
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
