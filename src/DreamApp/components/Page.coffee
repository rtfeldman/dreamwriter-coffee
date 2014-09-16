LeftSidebar  = require "./LeftSidebar.coffee"
Editor       = require "./Editor.coffee"
RightSidebar = require "./RightSidebar.coffee"
React        = require "react"
DreamDoc     = require "../../DreamDoc/DreamDoc.coffee"
Dispatcher   = require "../AppActionDispatcher.coffee"
AppAction    = require "../AppAction.coffee"
DreamStore   = require "../DreamStore.coffee"
_            = require "lodash"

{div} = require "../../React/dsl.coffee"

module.exports = Page = React.createClass
  getInitialState: -> {currentDoc: undefined, currentSnapshot: undefined, currentNotes: undefined}

  componentDidMount: ->
    @props.dreamStore.listeners.on DreamStore.CHANGE_EVENT,        @handleStoreChange
    @props.dreamStore.listeners.on DreamStore.OPEN_EVENT,          @handleStoreOpen
    @props.dreamStore.listeners.on DreamStore.NEW_DOC_EVENT,       @handleNewDocEvent
    @props.dreamStore.listeners.on DreamStore.SYNC_DOC_LIST_EVENT, @handleDocListChange

  componentWillUnmount: ->
    @props.dreamStore.off DreamStore.CHANGE_EVENT        @handleStoreChange
    @props.dreamStore.off DreamStore.OPEN_EVENT          @handleStoreOpen
    @props.dreamStore.off DreamStore.NEW_DOC_EVENT       @handleNewDocEvent
    @props.dreamStore.off DreamStore.SYNC_DOC_LIST_EVENT @handleDocListChange

  shouldComponentUpdate: (nextProps, nextState) ->
    # TODO fix this!
    return true

    currentDocs = @state.docs    ? {}
    nextDocs    = nextState.docs ? {}

    (@state.currentSnapshot.lastModified isnt nextState.currentSnapshot.lastModified) or
    (@state.currentDoc.lastModified      isnt nextState.currentDoc.lastModified) or
    (_.keys(currentDocs) isnt _.keys(nextDocs)) or
    (_.any currentDocs, (doc) -> doc.lastModified isnt nextDocs[doc.id]?.lastModified)

  render: ->
    div {id: "page"}, [
      (div {className: "backdrop", key: "backdrop"}, [
        (div {key: "backdrop-tl", className: "backdrop-quadrant backdrop-top backdrop-left"})
        (div {key: "backdrop-bl", className: "backdrop-quadrant backdrop-bottom backdrop-left"})
        (div {key: "backdrop-tr", className: "backdrop-quadrant backdrop-top backdrop-right"})
        (div {key: "backdrop-br", className: "backdrop-quadrant backdrop-bottom backdrop-right"})
      ])

      (LeftSidebar {currentDoc: @state.currentDoc, currentSnapshot: @state.currentSnapshot, docs: @state.docs})
      (Editor {doc: @state.currentDoc, snapshot: @state.currentSnapshot})
      (RightSidebar.render @state.currentNotes)
    ]

  handleStoreChange: ->
    {dreamStore} = @props

    # Refresh doc and snapshot
    # TODO parallelize this
    dreamStore.getCurrentDoc (doc) =>
      if doc
        dreamStore.getSnapshot doc.snapshotId, (snapshot) =>
          dreamStore.getSnapshot doc.notesId, (notes) =>
            @setState {currentDoc: doc, currentSnapshot: snapshot, currentNotes: notes}
      else
        @setState {currentDoc: undefined, currentSnapshot: undefined}

  handleStoreOpen: (doc) ->
    {dreamStore} = @props

    if doc
      # TODO parallelize this
      dreamStore.getSnapshot doc.snapshotId, (snapshot) =>
        dreamStore.getSnapshot doc.notesId, (notes) =>
          @setState {currentDoc: doc, currentSnapshot: snapshot, currentNotes: notes}
    else
      @setState {currentDoc: undefined, currentSnapshot: undefined}

  handleNewDocEvent: (doc) ->
    AppAction.syncDocList()

    # TODO just have the store emit something more specific like "current doc changed"
    @handleStoreChange()

  handleDocListChange: (docs) -> @setState {docs}