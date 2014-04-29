# Public Domain (-) 2014 The Mu Authors.
# See the Mu UNLICENSE file for details.

defmod 'µ', (µ, root) ->

  # The bit positions specify:
  #
  #   0    whether the flow has state
  #   1    whether the flow is mutable
  #   2    whether the flow is buffered
  #   3    whether the flow is stopable

  NO_STATE = 0
  MUTABLE = 2
  IMMUTABLE = 3
  BUFFERED = 4
  STOPABLE = 8

  µ.NO_STATE = NO_STATE
  µ.MUTABLE = MUTABLE
  µ.IMMUTABLE = IMMUTABLE
  µ.BUFFERED = BUFFERED

  _ = µ._

  {console, keys, schedule, tryErr, tryFn, tryFn1} = _
  {StopFlow, now} = µ
  {clearInterval, clearTimeout, setInterval, setTimeout} = root

  nextID = 0

  Flow = ->
    f = @
    f._hasVal = false
    f._success = undefined
    f._val = undefined
    # f._subscribers = []
    # First subscriber
    f._subscribers = undefined
    f._firstUsed = false
    f._next = undefined
    f._onSucc = undefined
    f._onFail = undefined
    f._single = undefined
    # [next, onSuccess, onFailure, single] = subscriber
    return

  isFlow = (f) ->
    f instanceof Flow

  isStopable = (f) ->
    (f._b & STOPABLE) > 0

  setStopable = (f) ->
    f._b |= STOPABLE
    return

  copyFlags = (upstream, downstream) ->
    return downstream

  push = (next, data, success) ->
    # console.log "next: #{next}"
    # console.log next
    # [next, onSuccess, onFailure] = subscriber
    # console.log "boom #{data}"
    if success
      if next.handler is undefined
        schedule putValue, next.flow, data
      else
        schedule run, next, data
    else
      if next.handler is undefined
        schedule putError, next.flow, data
      else
        schedule run, next, data
    return

  putError = (f, err) ->
    # unhandled _.tickID
    return

  putValue = (f, val) ->
    # if hasValue f
    f._hasVal = true
    f._success = true
    f._val = val
    if f._firstUsed
      push f._next, val, true
    if f._subscribers isnt undefined
      for next in f._subscribers
        push next, val, true
    return

  run = (next, data) ->
    ret = tryFn1 next.handler, data
    if ret is tryErr
      console.log "err: #{ret.e}"
      putError next.flow, ret.e
    else
      putValue next.flow, ret
    return

  # runSpread = (handler, data, next) ->
  #   ret = tryApply handler, data
  #   if ret is tryErr
  #     putError next, ret.e
  #   else
  #     putValue next, ret
  #   return

  Flow:: =

    # _b: 0            # bit field
    # _h: undefined    # handler
    # _f: undefined    # flow subscriber
    # _p: undefined    # parent flow
    # _v: undefined    # value

    catch: (handler) ->
      # @_s.push
      return

    catchError: (error, handler) ->
      if not ((error:: instanceof Error) or (error is Error))
        throw new TypeError("catchError can only catch Error and its subclasses")
      return

    debounce: (wait, immediate) ->
      return

    filter: (pred) ->
      @then (value) ->
        if pred value
          return value

    finally: (handler)->
      return

    limit: (duration) ->
      buf = []
      last = 0
      f = new Flow
      @then (value) ->
        n = now()
        setTimeout ->
          f.set value
        , duration
        return
      return f

    log: ->
      @then (value) ->
        console.log value
        return value
      .catch (err) ->
        console.error err
        throw err

    onStop: (handler) ->
      f = @
      setStopable f
      f.catchError StopFlow, handler

    putError: (err) ->
      putError @, err
      return

    putValue: (val) ->
      putValue @, val
      return

    reduce: () ->
      return

    stop: ->
      f = @
      while f._a isnt undefined
        f = f._a
      f.reject(new StopFlow)
      return

    then: (handler) ->
      f = @
      downstream = new Flow
      next = {flow: downstream, handler, id: nextID++}
      # next._b = 0
      # copy flags ...
      # if isImmutable f
      #   setImmutable downstream
      # if isStopable upstream
      #   setStopable downstream
      #   downstream._p = upstream
      # subscriber = [next, handler, undefined, true]
      if f._hasVal
        push next, f._val, f._success
        # push subscriber, f._val, f._success
        # if isMutable upstream
          # me._subscribers.extend([f, handler])
      else
        # f._subscribers.push subscriber
        if not f._firstUsed
          f._next = next
          f._firstUsed = true
        else
          f._subscribers.push next
      return next

    throttle: (wait) ->
      return

    timeout: (wait) ->
      f = @
      setTimeout ->
        f.setError new µ.Timeout
        return
      , duration
      return f

    to: (other) ->
      @.then (value) ->
        other.setValue value
        return
      return other

    toString: ->
      '[object Flow]'

  newFlow = (flags) ->
    f = new Flow
    # f._b = flags|0
    return f

  # newPromise = (value) ->
  newPromise = ->
    f = new Flow
    # f._b = IMMUTABLE
    # if value isnt undefined
    #   f.setValue value
    return f

  newValue = (value) ->
    f = new Flow
    # f._b = MUTABLE
    if value isnt undefined
      f.setValue value
    return f

  newFlow._typ = Flow
  newFlow.unhandled = (flow, reason) ->
    console.error "Uncaught flow error: #{reason}"
    return

  µ.flow = newFlow
  µ.promise = newPromise
  µ.value = newValue

  µ.every = (duration) ->
    s = newFlow NO_STATE
    i = 0
    timer = setInterval ->
      s.setValue i++
      return
    , duration
    s.onClose ->
      clearInterval timer
      return

  µ.merge = (flows...) ->
    f = newFlow BUFFERED
    buffer = (value) ->
      f.setValue
      return
    for flow in flows
      if isFlow flow
        flow.then buffer
      else
        f.setValue flow
    return f

  # Returns a value-like flow.
  sync = (flows...) ->
    return flow

  # Returns a value-like flow.
  sync.object = (spec) ->
    specKeys = keys spec
    specValues = []
    l = keys.length
    `for (var i = 0; i < l; i++) {
      values[i] = obj[specKeys[i]];
    }`
    return sync(values).then ->
      obj = {}
      args = [];
      `for (var i = 0; i < l; i++) {
        obj[specKeys[i]] = arguments[i];
      }`
      return obj

  µ.sync = sync

  # Returns a promise-like flow.
  # sync.first = (flows) ->
  #   return

  return
