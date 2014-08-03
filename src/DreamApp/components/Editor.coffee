{div} = require "../../React/dsl.coffee"
React = require "react"

module.exports = Editor = React.createClass
  render: (state) ->
    React.DOM.iframe {id: "editor-container", key: "editor-container"}

  componentDidMount: ->
    contentDocument = initIframe @getDOMNode(), @props.doc.html, @props.onLoad

    # Record the observer so we can disconnect it on unmount.
    @mutationObserver = initMutationObserver contentDocument, @props.mutationObserverOptions, @props.onMutate

  componentWillUnmount: ->
    @mutationObserver.disconnect()
    @mutationObserver.takeRecords()

initMutationObserver = (target, options, handler) ->
  observer = new MutationObserver (mutationRecords) ->
    handler.apply null, [mutationRecords, target]

  observer.observe target, options
  observer

# Initializes an iframe and returns its content document.
initIframe = (iframeNode, html, callback) ->
  contentDocument = iframeNode.contentDocument ? iframeNode.contentWindow.document

  contentDocument.designMode = "on"

  iframeNode.setAttribute "spellcheck", true

  writeToIframeDocument contentDocument, html, callback

  contentDocument

# Writes the given html to the given iframe document, and fires a callback once the write is complete.
writeToIframeDocument = (doc, html, callback = ->) ->
  switch doc.readyState
    # "complete" in Chrome/Safari, "uninitialized" in Firefox
    when "complete", "uninitialized"
      try
        doc.open()
        doc.write html
        doc.close()

        callback null
      catch error
        callback error
    else
      setTimeout (-> writeToIframeDocument doc, html, callback), 0
