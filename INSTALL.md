# Installation Help

This is just a living document as I make updates to remind myself how to do things.

## Order of Opperations

1. Lazy is your package manager. Add any new plugins to `lua/lazy-plugins.lua`. Likely there will be install instructions for lazy on the plugins github page.

2. Create a new config for the plugin in the `lua` folder. For example I just added nvim-tree so I added `lua/nvim-tree-setup.lua`.

3. Add config infor into the new file. likely will be something like `require("new-plugin").setup()` and you can add options. Each setup will be unique to the plugin so reference the documents for that specific plugin.

4. Add `require("new-plugin-setup")` to your `init.lua`.

5. Next time you open neovim lazy should automatically install the package.
