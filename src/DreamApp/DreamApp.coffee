DreamBox    = require "./DreamBox.coffee"
DreamEditor = require "../DreamEditor/DreamEditor.coffee"
DreamDoc    = require "../DreamDoc/DreamDoc.coffee"
Page        = require "./components/Page.coffee"
React       = require "react"
Dispatcher  = require "./AppActionDispatcher.coffee"
DreamStore  = require "./DreamStore.coffee"
AppAction   = require "./AppAction.coffee"

defaultDocHtml = require "./defaultDoc.coffee"

module.exports.DreamApp = DreamApp =
  init: ->
    dreamStore = new DreamStore()

    Dispatcher.register (payload) ->
      switch payload.actionType
        when AppAction.SAVE_DOC
          dreamStore.saveDoc payload.doc
        when AppAction.SAVE_SNAPSHOT
          dreamStore.saveSnapshot payload.snapshot
        when AppAction.NEW_DOC
          dreamStore.newDoc payload.doc, payload.html
        when AppAction.EDIT_CURRENT
          dreamStore.saveDocWithSnapshot payload.doc, {id: payload.doc.snapshotId, html: payload.html}
        else
          throw new Error("Unknown AppAction actionType: \"#{payload.actionType}\"")

    React.renderComponent Page({dreamStore: dreamStore.readOnlyVersion}), document.body

    dreamStore.readOnlyVersion.getCurrentDoc ((currentDoc) ->
      if currentDoc? and false
        console.log "Got a current doc! Emitting open..."
        # Have it broadcast that it's opening its current doc.
        dreamStore.listeners.emit DreamStore.OPEN_EVENT
      else
        # Load up the default doc, and open that.
        defaultElem = document.createElement 'div'
        defaultElem.innerHTML = defaultDocHtml

        initialDoc = DreamDoc.fromHtmlDoc defaultElem.firstChild

        AppAction.newDoc initialDoc, defaultElem.firstChild.innerHTML
    ), -> console.error "Could not access store to check initial value of currentDoc."

  connect: ->
    DreamBox.auth (error, dreamBox) ->
      console.log "Auth'd with Dropbox:", dreamBox, error
      dreamBox.writeFile "Alice.html", document.getElementById("editor").innerHTML, (error, stat) ->
        console.log "writeFile:", error, stat
