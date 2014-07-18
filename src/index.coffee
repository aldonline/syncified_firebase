syncify         = require 'syncify'

###
TODO:
we are currently using an underlying syncify.cell()
we should integrate at a lower level to handle notifier cleanup, etc
###
module.exports = firebase_cell = ( firebase_ref ) ->
  ref               = firebase_ref
  syncified_cell    = syncify.cell()
  destroyed         = no
  handler           = null
  ensure_subscribed = -> handler ?= ref.on 'value', (snap) -> syncified_cell snap.val()
  cell = ->

    throw new Error 'cell was destroyed' if destroyed
    a = arguments

    # first lets catch all cases in which the first argument
    # is an error. we do nothing since
    # it makes no sense to put an error
    # on a remote firebase reference
    return undefined if a[0] instanceof Error

    switch a.length
      when 0 # cell()
        ensure_subscribed()
        syncified_cell()
      when 1 # cell( err_or_value )
        ref.set a[0]
        undefined
      when 2 # cell( err, value )
        ref.set a[1]
        undefined
      when 3 # cell( err, value, priority )
        ref.setWithPriority a[1], a[2]
        undefined

  cell.destroy = ->
    destroyed = yes
    syncified_cell.destroy()
    ref.off 'value', handler
    handler = null
  cell