_            = require "lodash"
EventEmitter = require "event-emitter"
sha1         = require "sha1"

proxy = (target, methodName) ->
  -> target[methodName].apply target, Array.prototype.slice.call arguments

getRandomSha = -> sha1 "#{Math.random()}"[0..16]
newRecord = ->
  creationTimestamp = new Date()
  {id: getRandomSha(), created: creationTimestamp, lastModified: creationTimestamp}

runInParallel = (continuations = [], onSuccess = (->), onError = (-> throw new Error "Error executing #{continuations.length} in parallel.")) ->
  remaining = continuations.length

  completeWithSuccess = ->
    remaining--
    if remaining < 1
      onSuccess()

  _.each continuations, (continuation) ->
    continuation completeWithSuccess, onError

module.exports = class DreamStore
  listeners: new EventEmitter()

  @CHANGE_EVENT:        "changeEvent"
  @OPEN_EVENT:          "openEvent"
  @NEW_DOC_EVENT:       "newDocEvent"
  @SYNC_DOC_LIST_EVENT: "syncDocListEvent"

  constructor: ->
    storeNames = ['docs', 'snapshots', 'settings']

    vault = new Vault
      name: "dreamwriter"
      version: '1' # Must be an ever-increasing integer for Firefox and a string for Chrome.
      desiredStorageQuotaBytes: 1024 * 1024 * 1024 * 1024 # 1TB
      stores: storeNames
      storeDefaults: { keyName: 'id' }

    @_stores = vault.stores

    @readOnlyVersion = new ReadOnlyDreamStore this

  openDoc: (doc, onSuccess, onError) =>
    @putSetting "currentDocId", doc.id, (=>
      @listeners.emit DreamStore.OPEN_EVENT, doc
    ), onError

  putSetting: (id, value, onSuccess, onError) =>
    @_stores.settings.put {id, value}, onSuccess, onError

  saveDocWithSnapshot: (doc, snapshot) =>
    unless doc?
      throw new Error "Invalid doc: #{doc}"

    unless snapshot?
      throw new Error "Invalid snapshot: #{snapshot}"

    if snapshot.id? and (snapshot.id isnt doc.snapshotId)
      throw new Error "Cannot save doc with snapshotId #{doc.snapshotId} and snapshot with id #{snapshot.id}"

    persistDocAndSnapshot = =>
      succeed = => @listeners.emit DreamStore.CHANGE_EVENT
      fail    = -> throw new Error "Error saving doc #{doc?.id} and snapshot #{snapshot?.id}"

      doc.snapshotId ?= snapshot.id ? getRandomSha()
      snapshot.id    ?= doc.snapshotId

      currentDate = new Date()

      doc.creationTimestamp      ||= currentDate
      snapshot.creationTimestamp ||= currentDate
      doc.lastModified      = currentDate
      snapshot.lastModified = currentDate

      runInParallel [
        (onSuccess, onError) => @_stores.docs.put doc, onSuccess, onError
        (onSuccess, onError) => @_stores.snapshots.put snapshot, onSuccess, onError
      ], succeed, fail

    if doc.id?
      @readOnlyVersion.getDoc doc.id, (existingDoc) =>
        if existingDoc.lastModified.getTime() > doc.lastModified.getTime()
          # TODO handle this by re-rendering etc
          alert "Your document is out of sync! Please refresh."
        else
          persistDocAndSnapshot()
    else
      doc.id = getRandomSha()
      persistDocAndSnapshot()

  syncDocList: =>
    succeed = (docs) => @listeners.emit DreamStore.SYNC_DOC_LIST_EVENT, docs
    fail    =        -> throw new Error "Error syncing doc list"

    # TODO check for new content with Dropbox.
    @readOnlyVersion.listDocs succeed, fail

  newDoc: (doc, html) =>
    unless doc
      throw new Error "Cannot create new doc from #{doc} doc."

    unless html
      throw new Error "Cannot create new doc from #{html} HTML."

    snapshotRecord = _.defaults {html}, newRecord()
    notesRecord    = _.defaults {html: ""}, newRecord()
    docRecord      = _.defaults {snapshotId: snapshotRecord.id, notesId: notesRecord.id}, doc, newRecord()
    settingsRecord = {id: "currentDocId", value: docRecord.id}

    succeed = => @listeners.emit DreamStore.NEW_DOC_EVENT, doc
    fail    = -> throw new Error "Error saving new doc #{JSON.stringify doc}"

    runInParallel [
      (onSuccess, onError) => @_stores.docs.put      docRecord,      onSuccess, onError
      (onSuccess, onError) => @_stores.snapshots.put snapshotRecord, onSuccess, onError
      (onSuccess, onError) => @_stores.snapshots.put notesRecord,    onSuccess, onError
      (onSuccess, onError) => @_stores.settings.put  settingsRecord, onSuccess, onError
    ], succeed, fail

# TODO move this logic into vaultjs
readOnlyMethods = ["get", "count", "each", "db", "name"]

class ReadOnlyDreamStore
  constructor: (dreamStore) ->
    @_stores = _.object _.map dreamStore._stores, (store, storeName) ->
      readOnlyStore = _.object _.compact _.map store, (method, methodName) ->
        if methodName in readOnlyMethods
          [methodName, method]

      [storeName, readOnlyStore]

    @listeners = dreamStore.listeners

    @getDoc      = proxy @_stores.docs,      "get"
    @getSnapshot = proxy @_stores.snapshots, "get"

  getSetting: (key, onSuccess, onError) =>
    @_stores.settings.get key, ((result) =>
      onSuccess result?.value
    ), onError

  getCurrentDocId: (onSuccess, onError) =>
    @getSetting "currentDocId", onSuccess, onError

  getCurrentDoc: (onSuccess, onError) =>
    @getCurrentDocId ((currentDocId) =>
      if currentDocId?
        @getDoc currentDocId, onSuccess, onError
      else
        onSuccess()
    ), onError

  listDocs: (onSuccess, onError) =>
    listStoreContents @_stores.docs, onSuccess, onError

# TODO move this to vaultjs.list()
listStoreContents = (store, onSuccess = (->), onError = (->)) ->
  results = {}

  cursorIterator = (event) ->
    cursor = event.target.result

    if cursor
      results[cursor.key] = cursor.value
      cursor.continue()
    else
      onSuccess results

  store.db.openCursor store.name, cursorIterator, onError