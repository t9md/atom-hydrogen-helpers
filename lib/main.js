"use babel"

let hydrogenMain = null
let hydrogenStore = null

const { CompositeDisposable } = require("atom")

function* getIteratorForRowRange([start, end]) {
  while (start <= end) {
    yield start++
  }
}

function requireFrom(pack, path) {
  const packPath = atom.packages.resolvePackagePath(pack)
  return require(`${packPath}/lib/${path}`)
}

function removeLineCellForBufferRow(editor, row, commentStartString) {
  let cellRemoved = false
  const regex = new RegExp(`\\s*${commentStartString}\\s*%%\\s*$`)
  const scanRange = editor.bufferRangeForBufferRow(row)
  editor.scanInBufferRange(regex, scanRange, ({ range, replace }) => {
    if (!range.isEmpty()) {
      replace("")
      cellRemoved = true
    }
  })
  return cellRemoved
}

function getCommentStartStrings(editor) {
  const scope = editor.getLastCursor().getScopeDescriptor()
  return editor.getCommentStrings(scope).commentStartString
}

function hydrogenAppendCell(editor) {
  const commentStartString = getCommentStartStrings(editor)
  const rowRange = editor.getLastSelection().getBufferRowRange()

  for (let row of getIteratorForRowRange(rowRange)) {
    if (removeLineCellForBufferRow(editor, row, commentStartString)) {
      continue
    }

    const point = [row, Infinity]
    editor.setTextInBufferRange([point, point], ` ${commentStartString}%%`)
  }
}

function clearAllLineCells(editor) {
  const selection = editor.getLastSelection()
  let rowRange
  if (selection.getBufferRange().isEmpty()) {
    rowRange = [0, editor.getLastBufferRow()]
  } else {
    rowRange = selection.getBufferRowRange()
  }
  for (let row of getIteratorForRowRange(rowRange)) {
    removeLineCellForBufferRow(editor, row, getCommentStartStrings(editor))
  }
}

function hydrogenRestartKernelAndRunAll(editorElement) {
  if (hydrogenStore == null) {
    // means hydrogen is not yet activated. need activation by run-all
    // We don't need restart since this is first-run
    atom.commands.dispatch(editorElement, "hydrogen:run-all")
    return
  }

  const kernel = hydrogenStore.kernel
  if (kernel == null) return

  hydrogenMain.clearResultBubbles()
  kernel.restart(() => hydrogenMain.runAll())
}

module.exports = {
  activate() {
    this.subscriptions = new CompositeDisposable()
    const commands = {
      "hydrogen-helper:toggle-line-cells": function() {
        hydrogenAppendCell(this.getModel())
      },
      "hydrogen-helper:clear-all-line-cells": function() {
        clearAllLineCells(this.getModel())
      },
      "hydrogen-helper:restart-kernel-and-run-all": function() {
        hydrogenRestartKernelAndRunAll(this)
      }
    }
    this.subscriptions.add(
      atom.commands.add("atom-text-editor:not([mini])", commands)
    )
  },

  deactivate() {
    this.subscriptions.dispose()
  },

  consumeHydrogen(service) {
    hydrogenMain = service._hydrogen
    hydrogenStore = requireFrom("Hydrogen", "store")
  }
}
