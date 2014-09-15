Dispatcher = require "./AppActionDispatcher.coffee"

module.exports = AppAction =
  SAVE_SNAPSHOT: "SAVE_SNAPSHOT"
  saveSnapshot: (snapshot) ->
    Dispatcher.dispatch {actionType: AppAction.SAVE_SNAPSHOT, snapshot}

  SAVE_DOC: "SAVE_DOC"
  saveDoc: (doc) ->
    Dispatcher.dispatch {actionType: AppAction.SAVE_DOC, doc}

  NEW_DOC: "NEW_DOC"
  newDoc: (html) ->
    Dispatcher.dispatch {actionType: AppAction.NEW_DOC, html}

  OPEN_DOC: "OPEN_DOC"
  openDoc: (doc) ->
    Dispatcher.dispatch {actionType: AppAction.OPEN_DOC, doc}

  EDIT_CURRENT: "EDIT_CURRENT"
  editCurrent: (doc, html) ->
    Dispatcher.dispatch {actionType: AppAction.EDIT_CURRENT, doc, html}

  SYNC_DOC_LIST: "SYNC_DOC_LIST"
  syncDocList: ->
    Dispatcher.dispatch {actionType: AppAction.SYNC_DOC_LIST}