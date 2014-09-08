{div, span} = require "../../React/dsl.coffee"
React       = require "react"
DreamDoc    = require "../../DreamDoc/DreamDoc.coffee"
AppAction   = require "../../DreamApp/AppAction.coffee"

module.exports = Editor = React.createClass
  render: ->
    # Even if we have nothing to show, we need to render the iframe so we
    # can set it up on our first mount. Render it with display:none if need be.
    style = if @props.snapshot then null else {display: "none"}

    div {id: "editor-container", style},
      React.DOM.iframe {id: "editor-frame", spellCheck: true, key: "editor-frame", ref: "iframe"}

  handleMutation: (mutations) ->
    # We only care about mutations if we have a snapshot to work with
    if @props.snapshot
      contentDocument = @getContentDocument()
      AppAction.editCurrent DreamDoc.fromHtmlDoc(contentDocument), contentDocument.documentElement.innerHTML

  getContentDocument: ->
    iframeNode = @refs.iframe.getDOMNode()
    iframeNode.contentDocument ? iframeNode.contentWindow.document

  componentDidMount: ->
    # Enable design mode on the iframe and register a mutation observer
    contentDocument = @getContentDocument()
    contentDocument.designMode = "on"

    # Record the observer so we can disconnect it on unmount.
    @mutationObserver = new MutationObserver @handleMutation

    @enableMutationObserver contentDocument

  componentDidUpdate: (prevProps, prevState) ->
    # If our snapshot changed, write the new one to the iframe.
    if prevProps.snapshot?.id isnt @props.snapshot?.id
      # Mutation observers are expensive and unhelpful for this (massive) write
      @withoutMutationObserver =>
        html = @props.snapshot.html ? ""
        writeToIframeDocument @getContentDocument(), html

  withoutMutationObserver: (runLogic) ->
    @disableMutationObserver()

    try
      runLogic()
    finally
      @enableMutationObserver @getContentDocument()

  enableMutationObserver: (contentDocument) ->
    unless @mutationObserver
      throw new Error "Tried to enable #{@mutationObserver} mutationObserver"

    @mutationObserver.observe contentDocument, {
      childList: true
      attributes: true
      characterData: true
      subtree: true
    }

  disableMutationObserver: ->
    unless @mutationObserver
      throw new Error "Tried to disable #{@mutationObserver} mutationObserver"

    @mutationObserver.disconnect()

  componentWillUnmount: ->
    if @mutationObserver
      @disableMutationObserver()
      @mutationObserver.takeRecords()

initMutationObserver = (target, options, handler) ->

  observer.observe target, options
  observer

# Writes the given html to the given iframe document, and fires a callback once the write is complete.
writeToIframeDocument = (iframeDocument, html, onSuccess = (->), onError = (->)) ->
  switch iframeDocument.readyState
    # "complete" in Chrome/Safari, "uninitialized" in Firefox
    when "complete", "uninitialized"
      try
        iframeDocument.open()
        iframeDocument.write html
        iframeDocument.close()

        onSuccess()
      catch error
        onError error
    else
      setTimeout (-> writeToIframeDocument iframeDocument, html, onSuccess, onError), 0
