# hydrogen-helpers

Some hydrogen helper commands package.

**You need to install [Hydrogen](https://atom.io/packages/hydrogen), core functionalities are provided by Hydrogen**  

**This package just adds some helper commands which I think it's useful**.  

![](https://github.com/t9md/t9md/blob/8ddfc44e22a50436e52245fc3271656c29c745ea/img/hydrogen-helpers.gif?raw=true)

# commands

Currently this package provide following commands

- `hydrogen-helper:toggle-line-cells`: add or remove `cell` to end of each selected lines.
- `hydrogen-helper:clear-all-line-cells`: clear all line-cells placed on each end of lines.
- `hydrogen-helper:restart-kernel-and-run-all`

# keymap

no keymap by default, my keymap is here.

- `keymap.cson` example

```coffeescript
'atom-text-editor:not([mini])':
  'cmd-m': 'hydrogen-helper:toggle-line-cells'
  'cmd-h': 'hydrogen-helper:restart-kernel-and-run-all'
  'shift-cmd-m': 'hydrogen-helper:clear-all-line-cells'
```
