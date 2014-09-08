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
  getInitialState: -> {currentDoc: undefined, currentSnapshot: undefined}

  componentDidMount: ->
    {dreamStore} = @props
    @dreamStoreListener = =>
      console.debug "Page received notification that dreamStore changed state"

      # TODO add granularity to store event listeners. We want to do different things
      # depending on whether current doc changes, other docs change, etc.

      # Refresh doc and snapshot
      # TODO parallelize this
      dreamStore.getCurrentDoc (doc) =>
        if doc
          dreamStore.getSnapshot doc.snapshotId, (snapshot) =>
            @setState {currentDoc: doc, currentSnapshot: snapshot}
        else
          @setState {currentDoc: undefined, currentSnapshot: undefined}

    dreamStore.listeners.on DreamStore.CHANGE_EVENT, @dreamStoreListener

  componentWillUnmount: ->
    @props.dreamStore.off DreamStore.CHANGE_EVENT @dreamStoreListener

  componentShouldUpdate: (nextProps, nextState) ->
    (@state.currentSnapshot.lastModified isnt nextState.currentSnapshot.lastModified) or
    (@state.currentDoc.lastModified      isnt nextState.currentDoc.lastModified)

  render: ->
    onMutate = (mutations, contentDocument) =>
      currentDoc = DreamDoc.fromHtmlDoc contentDocument
      console.log "dispatching SAVE_DOC", currentDoc
      AppAction.saveDoc(currentDoc)
      console.log "dispatching SAVE_SNAPSHOT"
      AppAction.saveSnapshot({id: 1, html: contentDocument.documentElement.innerHTML})
      @setState {currentDoc}

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
