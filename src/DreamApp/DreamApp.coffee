DreamBox    = require "./DreamBox.coffee"
DreamEditor = require "../DreamEditor/DreamEditor.coffee"
Page        = require "./components/Page.coffee"
mercury     = require "mercury"

module.exports.DreamApp = DreamApp =
  init: ->
    console.debug "Initializing Dreamwriter..."

    DocumentOutline =
      title: "Alice's Adventures in Wonderland"
      words: 12345
      chapters: [
        {heading: "1. Down the Rabbit-Hole", words: 1234}
        {heading: "2. The Pool of Tears",    words: 2345}
      ]

    state = mercury.struct {some: "stuff!"}
    mercury.app(document.body, state, Page.render)

  connect: ->
    DreamBox.auth (error, dreamBox) ->
      console.log "Auth'd with Dropbox:", dreamBox, error
      dreamBox.writeFile "Alice.html", document.getElementById("editor").innerHTML, (error, stat) ->
        console.log "writeFile:", error, stat
