{CompositeDisposable, Disposable} = require 'atom'

hydrogenMain = null
hydrogenStore = null

requireFrom = (pack, path) ->
  packPath = atom.packages.resolvePackagePath(pack)
  require "#{packPath}/lib/#{path}"

hydrogenAppendCell = (editor) ->
  scope = editor.getLastCursor().getScopeDescriptor()
  {commentStartString} = editor.getCommentStrings(scope)
  [startRow, endRow] = editor.getLastSelection().getBufferRowRange()

  pattern = ///\s*#{commentStartString}\s*%%\s*$///

  for row in [startRow..endRow]
    scanRange = editor.bufferRangeForBufferRow(row)
    replaced = false
    editor.scanInBufferRange pattern, scanRange, ({range, replace}) ->
      unless range.isEmpty()
        replace('')
        replaced = true

    unless replaced
      point = [row, Infinity]
      editor.setTextInBufferRange([point, point], " #{commentStartString}%%")

hydrogenRestartKernelAndRunAll = (editorElement) ->
  kernel = hydrogenStore.kernel
  return unless kernel?

  runAll = hydrogenMain.runAll.bind(hydrogenMain)
  hydrogenMain.clearResultBubbles()
  kernel.restart(runAll)

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add "atom-text-editor:not([mini])",
      "hydrogen-helper:toggle-line-cells": ->
        hydrogenAppendCell(@getModel())
      "hydrogen-helper:restart-kernel-and-run-all": ->
        hydrogenRestartKernelAndRunAll(this)

  deactivate: ->
    @subscriptions.dispose()

  consumeHydrogen: (service) ->
    hydrogenMain = service._hydrogen
    hydrogenStore = requireFrom('Hydrogen', 'store')
