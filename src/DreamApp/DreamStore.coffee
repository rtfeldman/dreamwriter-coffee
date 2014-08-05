_          = require "lodash"

# TODO move this logic into vaultjs
readOnlyMethods = ["get", "count", "each"]

module.exports = class DreamStore
  constructor: ->
    storeNames = ['docs', 'snapshots', 'settings']

    startTime = new Date().getTime()
    vault = new Vault
      name: "dreamwriter"
      version: '1' # Must be an ever-increasing integer for Firefox and a string for Chrome.
      desiredStorageQuotaBytes: 1024 * 1024 * 1024 * 1024 # 1TB
      stores: storeNames
      storeDefaults: { keyName: 'id' }


    @stores = vault.stores
    @readOnlyStores = _.object _.map @stores, (store, storeName) ->
      readOnlyStore = _.object _.compact _.map store, (method, methodName) ->
        if methodName in readOnlyMethods
          [methodName, method]

      [storeName, readOnlyStore]
