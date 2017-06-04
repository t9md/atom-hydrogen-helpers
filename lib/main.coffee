{CompositeDisposable} = require 'atom'

hydrogenMain = null
hydrogenStore = null

requireFrom = (pack, path) ->
  packPath = atom.packages.resolvePackagePath(pack)
  require "#{packPath}/lib/#{path}"

removeLineCellForBufferRow = (editor, row, commentStartString) ->
  cellRemoved = false
  regex = ///\s*#{commentStartString}\s*%%\s*$///
  scanRange = editor.bufferRangeForBufferRow(row)
  editor.scanInBufferRange regex, scanRange, ({range, replace}) ->
    unless range.isEmpty()
      replace('')
      cellRemoved = true

  return cellRemoved

getCommentStartStrings = (editor) ->
  scope = editor.getLastCursor().getScopeDescriptor()
  editor.getCommentStrings(scope).commentStartString

hydrogenAppendCell = (editor) ->
  commentStartString = getCommentStartStrings(editor)

  [startRow, endRow] = editor.getLastSelection().getBufferRowRange()
  for row in [startRow..endRow]
    if removeLineCellForBufferRow(editor, row, commentStartString)
      continue

    point = [row, Infinity]
    editor.setTextInBufferRange([point, point], " #{commentStartString}%%")

clearAllLineCells = (editor) ->
  selection = editor.getLastSelection()
  if selection.getBufferRange().isEmpty()
    rowRange = [0, editor.getLastBufferRow()]
  else
    rowRange = selection.getBufferRowRange()

  [startRow, endRow] = rowRange
  for row in [startRow..endRow]
    removeLineCellForBufferRow(editor, row, getCommentStartStrings(editor))

hydrogenRestartKernelAndRunAll = (editorElement) ->
  unless hydrogenStore?
    # means hydrogen is not yet activated. need activation by run-all
    # We don't need restart since this is first-run
    atom.commands.dispatch(editorElement, 'hydrogen:run-all')
    return

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
      "hydrogen-helper:clear-all-line-cells": ->
        clearAllLineCells(@getModel())
      "hydrogen-helper:restart-kernel-and-run-all": ->
        hydrogenRestartKernelAndRunAll(this)

  deactivate: ->
    @subscriptions.dispose()

  consumeHydrogen: (service) ->
    hydrogenMain = service._hydrogen
    hydrogenStore = requireFrom('Hydrogen', 'store')
