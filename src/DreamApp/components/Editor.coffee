{div} = require "../../React/dsl.coffee"
React = require "react"

module.exports = Editor = React.createClass
  render: (state) ->
    React.DOM.iframe {id: "editor-container", key: "editor-container"}

  componentDidMount: ->
    initIframe @getDOMNode(), @props.html, (error) ->
      console.debug "Loaded HTML document with error:", error

initIframe = (iframeNode, html, callback) ->
  contentDocument = iframeNode.contentDocument ? iframeNode.contentWindow.document

  contentDocument.designMode = "on"

  iframeNode.setAttribute "spellcheck", true

  writeToIframeDocument contentDocument, html, callback

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
