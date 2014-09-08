# Handles dispatching actions
class AppActionDispatcher
  handlers: []
  isDispatching: false
  pendingPayload: null

  register: (callback) ->
    @handlers.push
      isPending: false
      isHandled: false
      callback: callback

  dispatch: (payload) ->
    if @isDispatching
      throw new Error "Cannot dispatch in the middle of a dispatch!"

    # Initialize states to begin the dispatch
    @handlers.forEach (handler) ->
      handler.isPending = false
      handler.isHandled = false

    @pendingPayload = payload
    @isDispatching  = true

    try
      # Invoke handler callbacks
      @handlers.forEach (handler) ->
        unless handler.isPending
          handler.isPending = true
          handler.callback payload
          handler.isHandled = true
    finally
      # Clean up after the dispatch
      @pendingPayload = null
      @isDispatching  = false

module.exports = new AppActionDispatcher()