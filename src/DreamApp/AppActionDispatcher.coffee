# Handles enqueuing (or immediately running) actions.
module.exports = class AppActionDispatcher
  constructor: (stores) ->
    queue = []

    @runImmediately = (action) =>
      action.resolve stores

    @enqueue = (action) =>
      queue.push action

      if queue.length == 1
        dispatch()

    dispatch = ->
      if queue.length > 0
        result = queue[0].resolve stores
        Promise.resolve(result).then advanceQueue, handleError

    advanceQueue = ->
      queue.shift()
      dispatch()

    handleError = (msg) ->
      console.error "Error dispatching action", msg
