AppAction = require "../AppAction.coffee"

module.exports = class OpenDreamDocAction extends AppAction
  constructor: (dreamDoc) ->
    super (stores, done) ->
      stores.currentDoc.set dreamDoc, done
