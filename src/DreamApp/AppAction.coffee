Dispatcher = require "./AppActionDispatcher.coffee"

module.exports = AppAction =
  SAVE_SNAPSHOT: "SAVE_SNAPSHOT"
  saveSnapshot: (snapshot) ->
    Dispatcher.dispatch {actionType: AppAction.SAVE_SNAPSHOT, snapshot}

  SAVE_DOC: "SAVE_DOC"
  saveDoc: (doc) ->
    Dispatcher.dispatch {actionType: AppAction.SAVE_DOC, doc}

  NEW_DOC: "NEW_DOC"
  newDoc: (doc, html) ->
    Dispatcher.dispatch {actionType: AppAction.NEW_DOC, doc, html}

  EDIT_CURRENT: "EDIT_CURRENT"
  editCurrent: (doc, html) ->
    Dispatcher.dispatch {actionType: AppAction.EDIT_CURRENT, doc, html}
