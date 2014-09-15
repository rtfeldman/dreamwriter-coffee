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
          docElem = document.createElement 'div'
          docElem.innerHTML = "<div id='loaded-content'>#{payload.html}</div>"

          dreamStore.newDoc DreamDoc.fromHtmlDoc(docElem.firstChild),
            DreamDoc.wrapInDocumentMarkup(docElem.firstChild.innerHTML)
        when AppAction.EDIT_CURRENT
          dreamStore.saveDocWithSnapshot payload.doc, {id: payload.doc.snapshotId, html: payload.html}
        when AppAction.OPEN_DOC
          dreamStore.openDoc payload.doc
        when AppAction.SYNC_DOC_LIST
          dreamStore.syncDocList()
        else
          throw new Error("Unknown AppAction actionType: \"#{payload.actionType}\"")

    React.renderComponent Page({dreamStore: dreamStore.readOnlyVersion}), document.body

    # Kick this off now, so it can run while we're finishing our init.
    AppAction.syncDocList()

    dreamStore.readOnlyVersion.getCurrentDoc ((currentDoc) ->
      if currentDoc?
        # We have an existing currentDoc, so open that.
        AppAction.openDoc currentDoc
      else
        # Create a new doc using the default doc HTML, and open that.
        AppAction.newDoc defaultDocHtml
    ), -> console.error "Could not access store to check initial value of currentDoc."

  connect: ->
    DreamBox.auth (error, dreamBox) ->
      console.log "Auth'd with Dropbox:", dreamBox, error
      dreamBox.writeFile "Alice.html", document.getElementById("editor").innerHTML, (error, stat) ->
        console.log "writeFile:", error, stat
