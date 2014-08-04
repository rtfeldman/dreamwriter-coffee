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

    for storeName in storeNames
      @[storeName] = vault.stores[storeName]
