DreamBox    = require "./DreamBox.coffee"
DreamEditor = require "../DreamEditor/DreamEditor.coffee"
DreamDoc    = require "../DreamDoc/DreamDoc.coffee"
Page        = require "./components/Page.coffee"
mercury     = require "mercury"
defaultDocHtml = require "./defaultDoc.coffee"

module.exports.DreamApp = DreamApp =
  init: ->
    console.debug "Initializing Dreamwriter..."

    # Load up the default doc
    defaultElem = document.createElement 'div'
    defaultElem.innerHTML = defaultDocHtml
    defaultDoc = defaultElem.firstChild

    currentDoc = DreamDoc.fromHtmlDoc defaultDoc

    state = mercury.struct {currentDoc}
    mercury.app(document.body, state, Page.render)

  connect: ->
    DreamBox.auth (error, dreamBox) ->
      console.log "Auth'd with Dropbox:", dreamBox, error
      dreamBox.writeFile "Alice.html", document.getElementById("editor").innerHTML, (error, stat) ->
        console.log "writeFile:", error, stat
