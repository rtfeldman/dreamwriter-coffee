# Takes a function which accepts a map of stores and a continuation function
# as its arguments, and runs the continuation function exactly once when it's done.
# e.g. new AppAction(function(stores, done) { doStuffWithStores(); done(); });
#
# Invoke the original function later with action.resolve(stores, callback)
# Alternatively, call .chain(nextAction) on the action to construct a new action with a resolve method that
# first resolves the original action, then the nextAction passed to chain.
module.exports = class AppAction
  constructor: (resolve) ->
    unless typeof resolve == "function"
      console.error "The AppAction constructor takes a function, not", resolve
      throw new Error "A AppAction constructor was passedan argument that was not a function"

    # Run the given function passing `stores` and `done`.
    # If the `done` continuation is called more than once,
    # throw an error.
    @resolve = (stores, done) ->
      resolve.call null, stores, ->
        originalDone = done
        done = throwMultipleContinuationAttempts
        originalDone()

    @chain = (nextAction) ->
      new AppAction (stores, done) ->
        resolve.call null, stores, ->
          nextAction.resolve stores, done

throwMultipleContinuationAttempts = -> throw new Error "A Continuable tried to invoke its continuation function more than once."

