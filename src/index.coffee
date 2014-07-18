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
    if arguments.length > 0 # setting a value
      [new_value, priority] = arguments
      # you can pass a second argument. will be used as priority
      if priority?
        ref.setWithPriority new_value, priority
      else
        ref.set new_value
      # return undefined to conform to the cell spec
      # https://github.com/aldonline/reactivity/wiki/Cell
      undefined 
    else # getting a value
      ensure_subscribed()
      syncified_cell()
  cell.destroy = ->
    destroyed = yes
    syncified_cell.destroy()
    ref.off 'value', handler
    handler = null
  cell