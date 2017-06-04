# hydrogen-helpers

Some hydrogen helper commands package.

# commands

- `hydrogen-helper:toggle-line-cells`: add or remove `cell` to end of each selected lines.
- `hydrogen-helper:restart-kernel-and-run-all`

# keymap

no keymap by default

- `keymap.cson` example

```coffeescript
'atom-text-editor:not([mini])':
  'cmd-m': 'hydrogen-helper:toggle-line-cells'
  'cmd-h': 'hydrogen-helper:restart-kernel-and-run-all'
```
