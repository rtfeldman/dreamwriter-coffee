# Handles enqueuing (or immediately running) actions.
module.exports = class AppActionDispatcher
  constructor: (stores) ->
    queue = []

    @runImmediately = (action, callback) =>
      action.resolve stores, callback

    @enqueue = (action) =>
      queue.push action

      if queue.length == 1
        dispatch()

    dispatch = ->
      if queue.length > 0
        queue[0].resolve stores, ->
          queue.shift()
          dispatch()

