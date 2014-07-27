DreamBox    = require "./DreamBox.coffee"
DreamEditor = require "../DreamEditor/DreamEditor.coffee"

module.exports.DreamApp = DreamApp =
  init: ->
    console.log "Initializing Dreamwriter..."

  connect: ->
    DreamBox.auth (error, dreamBox) ->
      console.log "Auth'd with Dropbox:", dreamBox, error
      dreamBox.writeFile "Alice.html", document.getElementById("editor").innerHTML, (error, stat) ->
        console.log "writeFile:", error, stat
