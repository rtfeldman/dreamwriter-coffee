DreamBox    = require "./DreamBox.coffee"
DreamEditor = require "../DreamEditor/DreamEditor.coffee"
DreamDoc    = require "../DreamDoc/DreamDoc.coffee"
Page        = require "./components/Page.coffee"
React       = require "react"
AppActionDispatcher = require "./AppActionDispatcher.coffee"
DreamStore = require "./DreamStore.coffee"


defaultDocHtml = require "./defaultDoc.coffee"

module.exports.DreamApp = DreamApp =
  init: ->
    # Load up the default doc
    defaultElem = document.createElement 'div'
    defaultElem.innerHTML = defaultDocHtml

    initialDoc = DreamDoc.fromHtmlDoc defaultElem.firstChild

    React.renderComponent Page({initialDoc}), document.body

    dispatcher = new AppActionDispatcher(new DreamStore())

  connect: ->
    DreamBox.auth (error, dreamBox) ->
      console.log "Auth'd with Dropbox:", dreamBox, error
      dreamBox.writeFile "Alice.html", document.getElementById("editor").innerHTML, (error, stat) ->
        console.log "writeFile:", error, stat
