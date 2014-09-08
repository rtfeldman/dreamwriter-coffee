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

  @CHANGE_EVENT: "changeEvent"
  @OPEN_EVENT:   "openEvent"

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
    @_stores.settings.put "currentDocId", doc.id, (=>
      @listeners.emit DreamStore.OPEN_EVENT
    ), onError

  saveSnapshot: (snapshot) =>
    console.debug "Saving snapshot:", snapshot.length, "to:", @_stores.snapshots
    return
    @_stores.snapshots.put snapshot, => @listeners.emit DreamStore.CHANGE_EVENT

  saveDocWithSnapshot: (doc, snapshot) =>
    unless doc?
      throw new Error "Invalid doc: #{doc}"

    unless snapshot?
      throw new Error "Invalid snapshot: #{snapshot}"

    doc.id      ||= getRandomSha()
    snapshot.id ||= getRandomSha()

    currentDate = new Date()
    
    doc.creationTimestamp      ||= currentDate
    snapshot.creationTimestamp ||= currentDate
    doc.lastModified             = currentDate
    snapshot.lastModified        = currentDate

    succeed = => @listeners.emit DreamStore.CHANGE_EVENT
    fail    = -> throw new Error "Error saving doc #{doc?.id} and snapshot #{snapshot?.id}"

    runInParallel [
      (onSuccess, onError) => @_stores.docs.put      doc,      onSuccess, onError
      (onSuccess, onError) => @_stores.snapshots.put snapshot, onSuccess, onError
    ], succeed, fail

  saveDoc: (doc) =>
    console.debug "Saving doc:", doc, "to:", @_stores.docs
    return
    @_stores.docs.put doc, => @listeners.emit DreamStore.CHANGE_EVENT

  newDoc: (doc, html) =>
    unless doc
      throw new Error "Cannot create new doc from #{doc} doc."

    unless html
      throw new Error "Cannot create new doc from #{html} HTML."

    snapshotRecord = _.defaults {html}, newRecord()
    notesRecord    = _.defaults {html: ""}, newRecord()
    docRecord      = _.defaults {snapshotId: snapshotRecord.id, notesId: notesRecord.id}, doc, newRecord()
    settingsRecord = {id: "currentDocId", value: docRecord.id}

    succeed = => @listeners.emit DreamStore.CHANGE_EVENT
    fail    = -> throw new Error "Error saving new doc #{doc}"

    runInParallel [
      (onSuccess, onError) => @_stores.docs.put      docRecord,      onSuccess, onError
      (onSuccess, onError) => @_stores.snapshots.put snapshotRecord, onSuccess, onError
      (onSuccess, onError) => @_stores.snapshots.put notesRecord,    onSuccess, onError
      (onSuccess, onError) => @_stores.settings.put  settingsRecord, onSuccess, onError
    ], succeed, fail

# TODO move this logic into vaultjs
readOnlyMethods = ["get", "count", "each"]

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