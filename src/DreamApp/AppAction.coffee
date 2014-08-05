# Takes a function which accepts a map of stores and
# optionally returns a Promise.
#
# e.g. new AppAction(function(stores) { doStuffWithStores(); return Promise(args); });
#
# A dispatcher will invoke the original function later with action.resolve(stores)
module.exports = class AppAction
  constructor: (resolve) ->
    unless typeof resolve == "function"
      console.error "The AppAction constructor takes a function, not", resolve
      throw new Error "An AppAction constructor was passed an argument that was not a function"

    # Invoke our `resolve` function passing `stores`.
    @resolve = (stores) -> resolve.call null, stores
