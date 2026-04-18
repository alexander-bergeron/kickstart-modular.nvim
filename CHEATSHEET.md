# Neovim Cheat Sheet

A comprehensive reference guide for common use cases migrated from VS Code to Neovim with this custom configuration.

---

## Table of Contents

1. [Search & Find](#search--find)
2. [Find & Replace](#find--replace)
3. [Tab & Buffer Management](#tab--buffer-management)
4. [Multi-line Editing](#multi-line-editing)
5. [Split & Pane Management](#split--pane-management)
6. [Code Navigation (LSP)](#code-navigation-lsp)
7. [Git Operations](#git-operations)
8. [Debugging](#debugging)
9. [File Management](#file-management)
10. [Miscellaneous Tips](#miscellaneous-tips)
11. [Remote SSH Editing](#remote-ssh-editing)

---

## Search & Find

### Basic Search (Builtin)

| Action | Keybind | Notes |
|--------|---------|-------|
| **Find in current file** | `/` | Type search term, press Enter to go to first match |
| **Find next match** | `n` | Jump to next occurrence |
| **Find previous match** | `N` | Jump to previous occurrence |
| **Clear search highlights** | `<Esc>` | Removes highlighting from search results |
| **Find word under cursor** | `*` | Search for word at cursor position |
| **Find word (case-insensitive)** | `g*` | Like `*` but matches substrings |

### Advanced Find (Telescope)

Telescope provides a modern fuzzy-finding interface with live preview.

| Action | Keybind | Description |
|--------|---------|-------------|
| **Search files** | `<leader>sf` | Find any file in project |
| **Search word in project** | `<leader>sw` | Search all files for word under cursor |
| **Live grep (search content)** | `<leader>sg` | Search file contents with live grep |
| **Search open buffers** | `<leader>sb` | Switch between open files |
| **Search in current file** | `<leader>/` | Fuzzy search current buffer |
| **Search help documentation** | `<leader>sh` | Find help topics |
| **Search keybinds** | `<leader>sk` | Discover available keybindings |
| **Resume last search** | `<leader>sr` | Re-open last Telescope search |
| **Recent files** | `<leader>.` | Browse recently opened files |

### Find & Walk Through Results (Pattern)

**Scenario**: Find a string, see all matches, walk through them one by one.

1. **Open grep search**: `<leader>sg`
2. **Type your search term** (e.g., `function_name`)
3. **Results appear in split** showing file:line:match
4. **Navigate results**:
   - `<C-j>` / `<C-k>` - Next/Previous result in list
   - `<Enter>` - Jump to selected result
   - `<C-x>` - Open in horizontal split
   - `<C-v>` - Open in vertical split
5. **Walk through matches**: Once in a file, use `n` / `N` to jump between matches

**Alternative (Builtin)**: Use `:grep "search_term"` then `:copen` to open quickfix list.

### Case Sensitivity & Smart Case

| Feature | Setting | How to Use |
|---------|---------|-----------|
| **Case-insensitive search** | Default | `/pattern` matches "Pattern", "PATTERN", etc. |
| **Force case-sensitive** | `\C` prefix | `/\Cpattern` (uppercase P won't match) |
| **Smart case** | Enabled by default | If search has capital letter, becomes case-sensitive |
| **Example** | `/function` | Finds "function", "Function", "FUNCTION" |
| **Example** | `/Function` | Finds only "Function" (capital triggered smart case) |

### Regex Search

| Pattern | Meaning | Example |
|---------|---------|---------|
| `.` | Any character | `/h.llo` matches "hello", "hallo" |
| `*` | Zero or more of previous | `/lo*` matches "l", "lo", "loo" |
| `+` | One or more of previous | `/lo+` matches "lo", "loo" (not "l") |
| `^` | Start of line | `/^function` matches "function" at line start |
| `$` | End of line | `/return;$` matches "return;" at line end |
| `\(pattern\)` | Capture group | `/\(foo\)bar` captures "foo" |
| `\|` | OR operator | `/cat\|dog` matches "cat" or "dog" |
| `[abc]` | Character class | `/[aeiou]` matches any vowel |
| `[^abc]` | Negated class | `/[^0-9]` matches non-digits |

**Example**: Search for all function definitions in Python:
```
<leader>sg
^def\s+
```

---

## Find & Replace

### Basic Find & Replace (Single File)

**Scenario**: Replace all occurrences of a word in current file.

```vim
:%s/old_text/new_text/g
```

| Part | Meaning |
|------|---------|
| `%` | Entire file (use `:10,20s` for lines 10-20) |
| `s` | Substitute command |
| `old_text` | Pattern to find |
| `new_text` | Replacement text |
| `g` | Global (all occurrences per line) |

**Examples**:
```vim
:%s/foo/bar/g              " Replace all 'foo' with 'bar' in entire file
:10,20s/foo/bar/g         " Replace in lines 10-20 only
:%s/foo/bar/gc            " Replace with confirmation prompt for each match
:%s/\<foo\>/bar/g         " Replace whole word 'foo' only (not 'foobar')
```

### Replace with Confirmation

```vim
:%s/old_text/new_text/gc
```

The `c` flag adds a prompt for each replacement:
- `y` - Replace this match
- `n` - Skip this match
- `a` - Replace all remaining matches
- `q` - Quit replace mode
- `l` - Replace this match and quit
- `<C-e>` - Show context around match

### Replace Using Regex

| Pattern | Purpose |
|---------|---------|
| `\(pattern\)` | Capture group |
| `\1, \2, etc` | Reference captured group in replacement |

**Example**: Swap first and last name
```vim
:%s/\([A-Za-z]*\) \([A-Za-z]*\)/\2 \1/g
```
Changes "John Doe" → "Doe John"

**Example**: Add quotes around words
```vim
:%s/\([a-z]*\)/"&"/g
```
Changes "hello world" → `"hello" "world"` (& means matched text)

### Find & Replace Across Multiple Files

**Method 1: Using Telescope grep + Manual Edit** (Tedious)
1. `<leader>sg` - Search all files
2. Select results, manually edit each file
3. `:w` to save

**Method 2: Using Quickfix List** (Better)
1. `:grep "pattern" **/*.py` - Search all Python files
2. `:cfdo %s/old/new/g | update` - Replace in all matched files
3. `:cclose` - Close quickfix list

**Recommended**: Install `grug-far.nvim` for VS Code-like batch find/replace UI.

### Case-Insensitive Replace

```vim
:%s/old_text/new_text/gi
```

The `i` flag makes pattern matching case-insensitive:
- `/OLD_TEXT/new/gi` will match "old_text", "Old_Text", "OLD_TEXT"

---

## Tab & Buffer Management

### Understanding Tabs vs Buffers

Neovim uses **buffers** (like VS Code tabs) more than traditional Vim tabs. You're mostly working with buffers.

| Concept | Neovim | VS Code |
|---------|--------|--------|
| **Open files** | Buffers | Tabs |
| **Named windows** | Tabs | Panes |
| **Multiple editors** | Splits | Split editors |

### Buffer Management (Like VS Code Tabs)

| Action | Keybind | Notes |
|--------|---------|-------|
| **Show all buffers** | `<leader><leader>` | Opens Telescope buffer picker |
| **Next buffer** | `:bn` | Go to next open buffer |
| **Previous buffer** | `:bp` | Go to previous open buffer |
| **Close buffer** | `:bd` | Close current buffer (without closing split) |
| **Close buffer (force)** | `:bd!` | Force close unsaved buffer |
| **List buffers** | `:ls` | Show all open buffers in command line |
| **Jump to buffer N** | `:b3` | Jump to buffer number 3 |

### Faster Buffer Navigation

Using Telescope is faster than `:bn`:
```
<leader><leader>  " Opens buffer picker
Type first few chars of filename
<Enter>           " Jump to that buffer
```

### Create New File / Buffer

| Action | Command | Result |
|--------|---------|--------|
| **New file in new split** | `:new` | Horizontal split with empty buffer |
| **New file in vertical split** | `:vnew` | Vertical split with empty buffer |
| **New file (same window)** | `:edit filename.txt` | Open file in current window |

### Vim Tabs (If You Need Multiple Workspaces)

Traditional Vim tabs are different from buffers. Use them for project organization:

| Action | Keybind | Command |
|--------|---------|---------|
| **Create new tab** | | `:tabnew` |
| **Close tab** | | `:tabclose` |
| **Next tab** | | `gt` |
| **Previous tab** | | `gT` |
| **Go to tab N** | | `3gt` (go to tab 3) |
| **List tabs** | | `:tabs` |

**Tip**: Use buffers for daily work (like VS Code tabs) and tabs only if you need multiple "workspaces".

---

## Multi-line Editing

### Visual Block Selection (Column Selection)

**Scenario**: Edit multiple lines in the same column position.

1. **Enter visual block mode**: `<C-v>`
2. **Select region**: Use arrow keys or hjkl to select columns and rows
3. **Edit**:
   - `I` - Insert before selection (then edit, press `<Esc>`)
   - `A` - Append after selection (then edit, press `<Esc>`)
   - `d` - Delete selection
   - `c` - Change (delete and insert)

**Example**: Add `//` comment to multiple lines

```python
# Before
function test() {
  let x = 1;
  let y = 2;
}

# Steps
1. <C-v>           " Enter block mode
2. j j             " Select 3 lines down
3. I               " Insert at start
4. // <Esc>        " Type comment, exit

# After
// function test() {
//   let x = 1;
//   let y = 2;
// }
```

### Vertical Line Selection with Replacement

**Scenario**: Replace a pattern across multiple lines in a column.

1. **Find & replace with regex**:
```vim
:%s/\([a-z]*\) = \([0-9]*\)/\1 = '\2'/g
```

2. **Or use visual block + substitute**:
   - `<C-v>` - Select block
   - `:s/old/new/g` - Substitute in selection

**Example**: Add quotes around numbers
```python
# Before
x = 123
y = 456

# Command: :%s/= \([0-9]*\)/= '\1'/g
# After
x = '123'
y = '456'
```

### Multi-cursor-like Editing

Neovim doesn't have true multi-cursor (VS Code style). Workarounds:

**Method 1: Visual block + command**
```vim
<C-v>      " Visual block
j j        " Select lines
:normal @a " Execute macro 'a' on all lines
```

**Method 2: Global command**
```vim
:g/pattern/s/old/new/g
```
Runs `:s/old/new/g` on all lines matching "pattern"

**Method 3: Range command**
```vim
:10,20s/foo/bar/g
```
Replace on lines 10-20 only

**Recommendation**: Install `vim-visual-multi` for true multi-cursor if you heavily use this feature.

---

## Split & Pane Management

### Creating Splits

| Action | Command | Keybind |
|--------|---------|---------|
| **Horizontal split** | `:split` | (or `:sp`) |
| **Vertical split** | `:vsplit` | (or `:vs`) |
| **New horizontal split** | `:new` | (empty buffer) |
| **New vertical split** | `:vnew` | (empty buffer) |

### Navigate Between Splits

| Direction | Keybind | Alternative |
|-----------|---------|-------------|
| **Left window** | `<C-h>` | `<C-w>h` |
| **Right window** | `<C-l>` | `<C-w>l` |
| **Up window** | `<C-k>` | `<C-w>k` |
| **Down window** | `<C-j>` | `<C-w>j` |
| **Cycle windows** | `<C-w>w` | Cycle through all splits |
| **Last window** | `<C-w>p` | Jump to previously focused split |

### Resize Splits

| Action | Keybind |
|--------|---------|
| **Increase width** | `<C-w>>` (repeat for more) |
| **Decrease width** | `<C-w><` |
| **Increase height** | `<C-w>+` |
| **Decrease height** | `<C-w>-` |
| **Equalize sizes** | `<C-w>=` |
| **Max height** | `<C-w>_` |
| **Max width** | `<C-w>\|` |

### Close Splits

| Action | Keybind | Command |
|--------|---------|---------|
| **Close current split** | `<C-w>c` | `:close` or `:q` |
| **Close other splits** | `<C-w>o` | (keep only current) |
| **Close all but one split** | | `:only` |

### Move Splits

| Action | Keybind | Description |
|--------|---------|-------------|
| **Move to new tab** | `<C-w>T` | Convert split to tab |
| **Rotate splits** | `<C-w>r` | Rotate clockwise |
| **Swap with next** | `<C-w>x` | Swap current with next split |

---

## Code Navigation (LSP)

### Go to Definition / Implementation / References

| Action | Keybind | Description |
|--------|---------|-------------|
| **Go to definition** | `gd` | Jump to where symbol is defined |
| **Find references** | `gr` | Show all places symbol is used |
| **Go to implementation** | `gI` | Jump to implementation (for interfaces) |
| **Go to declaration** | `gD` | Jump to declaration (header in C) |
| **Go to type definition** | `<leader>D` | Jump to type definition |
| **Go back** | `<C-t>` | Jump back to previous location |

### Symbol Search & Navigation

| Action | Keybind | Description |
|--------|---------|-------------|
| **Document symbols** | `<leader>ds` | Outline/symbols in current file |
| **Workspace symbols** | `<leader>ws` | All symbols in project |

**Example**: Jump to all instances of a function
```
1. gd or gr               " Jump to definition or references
2. Use telescope to see all matches
3. <Enter> to jump to each one
```

### Code Actions & Quick Fixes

| Action | Keybind | Notes |
|--------|---------|-------|
| **Code actions** | `<leader>ca` | Fixes, refactors, format suggestions |
| **Rename symbol** | `<leader>rn` | Rename variable/function workspace-wide |
| **Format buffer** | `<leader>f` | Format entire file or selection |
| **Toggle inlay hints** | `<leader>th` | Show type hints and parameter names |

### Hover Information

```vim
" Hover info is available but not auto-shown
K          " Show hover information for symbol under cursor
```

**Note**: If you want auto-hover on hover, this would require additional setup.

---

## Git Operations

All git operations use the `gitsigns` plugin integrated with Telescope.

### View Changes & Diffs

| Action | Keybind | Description |
|--------|---------|-------------|
| **Next change** | `]c` | Jump to next git hunk |
| **Previous change** | `[c` | Jump to previous git hunk |
| **Preview hunk** | `<leader>hp` | Show diff of current hunk |
| **Diff against index** | `<leader>hd` | Show file diff (staged vs working) |
| **Diff last commit** | `<leader>hD` | Show diff since last commit |

### Stage & Reset Changes

| Action | Keybind | Description |
|--------|---------|-------------|
| **Stage hunk** | `<leader>hs` | Stage current hunk |
| **Unstage hunk** | `<leader>hu` | Undo staged hunk |
| **Reset hunk** | `<leader>hr` | Discard hunk changes |
| **Stage buffer** | `<leader>hS` | Stage entire buffer |
| **Reset buffer** | `<leader>hR` | Discard all changes in buffer |

### Blame & History

| Action | Keybind | Description |
|--------|---------|-------------|
| **Blame current line** | `<leader>hb` | Show who wrote this line |
| **Toggle blame** | `<leader>tb` | Show/hide blame gutter |
| **Toggle deleted** | `<leader>tD` | Show/hide deleted lines |

### Full Git Workflow Example

```
1. <leader>sg          " Search for your bug
2. gd                  " Go to definition
3. ]c                  " Jump to git changes
4. <leader>hd          " Preview the diff
5. <leader>hs          " Stage the hunk
6. :!git commit -m "fix: description"   " Commit from CLI
```

---

## Debugging

Debugging is configured for Go using DAP (Debug Adapter Protocol).

### Go Debugging

| Action | Keybind | Description |
|--------|---------|-------------|
| **Continue / Start** | `<F5>` | Start debugging or continue from breakpoint |
| **Step into** | `<F1>` | Step into function call |
| **Step over** | `<F2>` | Step to next line (skip function) |
| **Step out** | `<F3>` | Step out of current function |
| **Toggle debug UI** | `<F7>` | Show/hide debug panels |
| **Toggle breakpoint** | `<leader>b` | Set/remove breakpoint on current line |
| **Set conditional breakpoint** | `<leader>B` | Breakpoint with condition (when expression is true) |

### Start a Debug Session

1. **Place breakpoint**: `<leader>b` on line you want to debug
2. **Start debugger**: `<F5>`
3. **Step through**: Use `<F1>`, `<F2>`, `<F3>` to navigate
4. **Inspect variables**: Hover over variables in debug panel or right-click
5. **Stop**: `<F5>` when in debugger

**Note**: Python and Node.js debugging would require additional setup. See `lua/kickstart/plugins/debug.lua` to add language-specific DAP configurations.

---

## File Management

### File Explorer

| Action | Keybind | Description |
|--------|---------|-------------|
| **Toggle neo-tree** | `<leader>\` | Open/close file explorer sidebar |

### In Neo-tree

| Action | Keybind | Description |
|--------|---------|-------------|
| **Toggle directory** | `<Enter>` | Open/close folder |
| **Open file** | `<Enter>` | Open file in current split |
| **Open file (new split)** | `s` | Open in horizontal split |
| **Open file (vertical)** | `v` | Open in vertical split |
| **Create file** | `a` | Add new file |
| **Create directory** | `A` | Add new directory |
| **Rename** | `r` | Rename file/folder |
| **Delete** | `d` | Delete file/folder |
| **Copy** | `c` | Copy file/folder |
| **Move** | `m` | Move file/folder |
| **Refresh** | `R` | Refresh file tree |

### Quick File Opening

Instead of neo-tree, you can use Telescope:
```
<leader>sf        " Fuzzy search files
Type filename
<Enter>           " Open file
```

---

## Miscellaneous Tips

### Show Available Keybinds

```
<space>           " Opens which-key menu showing all keybinds
<leader>sk        " Search keybinds by description
```

### Comment Toggle

| Action | Keybind | Description |
|--------|---------|-------------|
| **Toggle comment** | `gc` | Comment/uncomment line or selection |

**Examples**:
```vim
gc in normal mode          " Toggle comment on current line
gcj                        " Toggle comment on current + next line
gc (visual selection)      " Comment all selected lines
```

### Auto-completion

| Action | Keybind | Description |
|--------|---------|-------------|
| **Trigger completion** | `<C-Space>` | Open completion menu |
| **Next suggestion** | `<C-n>` | Next completion option |
| **Previous suggestion** | `<C-p>` | Previous completion option |
| **Accept suggestion** | `<C-y>` or `<Enter>` | Confirm completion |
| **Dismiss menu** | `<C-e>` | Close completion menu |

### Snippets

Auto-completion includes snippet suggestions. Installed snippets cover:
- 1000+ pre-made snippets (friendly-snippets)
- Language-specific templates
- Custom snippet support

**Using snippets**:
```
<C-Space>          " Trigger completion to see snippets
Type snippet name (autocomplete shows descriptions)
<Enter>            " Insert snippet
<C-l>/<C-h>        " Jump to next/prev snippet placeholder
```

### Line Numbering

| Setting | Command | Effect |
|---------|---------|--------|
| **Absolute line numbers** | `:set number` | Shows line numbers 1, 2, 3... |
| **Relative line numbers** | `:set relativenumber` | Shows distance from current line |
| **Hybrid mode** | Both enabled | Current line absolute, others relative |
| **Toggle** | `:set nonumber` | Turn off line numbers |

### Word Wrap

| Action | Command | Effect |
|--------|---------|--------|
| **Enable wrap** | `:set wrap` | Long lines break visually |
| **Disable wrap** | `:set nowrap` | Long lines scroll horizontally |
| **Toggle** | `:set wrap!` | Toggle word wrap on/off |

### Indentation

| Action | Keybind | Effect |
|--------|---------|--------|
| **Increase indent** | `>>` (normal) or `>` (visual) | Add indentation |
| **Decrease indent** | `<<` (normal) or `<` (visual) | Remove indentation |
| **Auto-indent** | `==` (normal) or `=` (visual) | Auto-indent based on context |

### Undo & Redo

| Action | Keybind | Notes |
|--------|---------|-------|
| **Undo** | `u` | Undo last change |
| **Redo** | `<C-r>` | Redo last undone change |
| **Undo all** | `:1,$d \| :e` | Revert to last saved (dangerous!) |

---

## Remote SSH Editing

### Using Netrw (Built-in)

Neovim includes `netrw` for remote file access over SSH.

**Open remote file**:
```bash
nvim scp://user@hostname/path/to/file.txt
nvim sftp://user@hostname/path/to/file.txt
```

**Browse remote directory**:
```bash
nvim scp://user@hostname/remote/path/
```

**Edit and save**: Normal Neovim editing, then `:w` saves to remote.

**Limitations**:
- Slower than local editing
- No interactive authentication (use SSH keys)
- Limited directory browsing

### Using netman.nvim (Modern Alternative)

A modern Lua-based network resource manager plugin that improves on netrw.

**Installation**: Add to `lua/custom/plugins/netman.lua`:
```lua
return {
  'miversen33/netman.nvim',
  config = function()
    require('netman').setup()
  end,
}
```

**Usage**:
```bash
# Edit remote file
nvim sftp://user@hostname:port/path/file.txt

# Edit file from SSH config host
nvim sftp://myhost/path/file.txt    " Uses ~/.ssh/config

# Browse remote directory
nvim sftp://user@hostname/dir/

# Edit file in Docker container
nvim docker://container_name/path/file.txt
```

**Advantages over netrw**:
- Better performance
- Supports SSH config aliases
- Docker container support
- Integrates with neo-tree for browsing
- Cleaner UI

**Requirements**:
- SSH keys configured (no password auth yet)
- `ssh` and `sftp` binaries available
- Remote machine needs: `ssh`, `sftp`, `find`, `rm`

### SSH Setup for Remote Editing

**Prerequisites**:
1. **SSH key pair** (if not exists):
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. **Copy public key to remote**:
   ```bash
   ssh-copy-id -i ~/.ssh/id_ed25519.pub user@remote_host
   ```

3. **Add to SSH config** (~/.ssh/config):
   ```
   Host myserver
       HostName example.com
       User myusername
       IdentityFile ~/.ssh/id_ed25519
   ```

**Then use**:
```bash
nvim sftp://myserver/path/to/file.txt
```

### Workflow: Edit Remote Files

**Local setup** (one time):
```bash
# Generate SSH key
ssh-keygen -t ed25519

# Copy to remote
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@remote_host

# (Optional) Create ~/.ssh/config entry
```

**Daily workflow**:
```bash
# Open remote file
nvim sftp://user@hostname/app/main.go

# Edit normally in Neovim
# Make changes, save with :w

# Changes are automatically synced to remote
```

### Comparison: Netrw vs netman vs VS Code Remote SSH

| Feature | Netrw | netman | VS Code Remote SSH |
|---------|-------|--------|-------------------|
| **SSH support** | ✅ | ✅ | ✅ |
| **SFTP support** | ✅ | ✅ | ❌ |
| **Performance** | Slow | Fast | Fast |
| **Docker support** | ❌ | ✅ | ✅ (ext) |
| **Directory browsing** | Limited | Good | Good |
| **Setup complexity** | Simple | Simple | Complex |
| **Remote server needed** | No | No | Yes (VSCode Server) |

**Recommendation**: Use `netman.nvim` for a better experience than netrw, or stick with netrw if you prefer minimal setup.

---

## Quick Reference Card

### Essential Keybinds to Know

```
General
  <space>              Show keybind menu (which-key)
  <Esc>                Clear search highlights

Search & Navigation
  /pattern             Find in file
  *                    Find word under cursor
  <leader>sf           Search files
  <leader>sg           Grep search project
  <leader>sb           Switch buffers

Code Navigation
  gd                   Go to definition
  gr                   Find references
  <leader>rn           Rename symbol
  <leader>ca           Code actions

Editing
  <C-v>                Visual block mode
  >>                   Indent line
  <<                   Dedent line
  gc                   Toggle comment
  <leader>f            Format file

Git
  ]c / [c              Jump to git change
  <leader>hs           Stage hunk
  <leader>hd           Diff
  <leader>hb           Blame

Splits
  <C-h/j/k/l>          Move between splits
  :vsplit              Vertical split
  :split               Horizontal split
  <C-w>c               Close split

Debugging
  <F5>                 Start/continue debug
  <leader>b            Toggle breakpoint

Files
  <leader>\            Toggle file explorer
  <leader>.            Recent files
```

---

## Common Patterns

### Pattern: Search → Edit → Save

```
1. <leader>sg          " Open grep
2. Type "bug_pattern"
3. <Enter>             " Jump to first match
4. n                   " Find next with /
5. i                   " Insert mode, make edits
6. <Esc>               " Back to normal
7. :w                  " Save
```

### Pattern: Find and Replace Multiple Files

```
1. <leader>sg          " Grep search
2. :cfdo %s/old/new/g | update   " Replace in all matches
3. :cclose             " Close quickfix
```

### Pattern: Rename Variable Workspace-wide

```
1. <C-h/j/k/l>         " Navigate to file with variable
2. gd or :FzfLua blines " Find variable definition
3. <leader>rn          " Rename all occurrences
4. Type new name
5. <Enter>             " Confirm
```

### Pattern: Multi-line Edit

```
1. <C-v>               " Visual block mode
2. Select lines/columns
3. I or A              " Insert or append
4. Edit text
5. <Esc>               " Apply to all selected
```

---

## Troubleshooting

### "Command not found" or Feature Not Working

1. **Check if LSP is running**:
   ```vim
   :LspInfo
   ```
   Should show attached language servers.

2. **Mason tool not installed**:
   ```vim
   :Mason
   ```
   Shows all available tools and their status. Install missing ones.

3. **Plugin not loading**:
   ```vim
   :Lazy
   ```
   Check plugin status. If red, there's an error.

### Performance Issues

1. **Disable spell check** (can be slow):
   ```vim
   :set nospell
   ```

2. **Reduce LSP overhead** (in init.lua):
   ```lua
   -- Disable inlay hints for speed
   vim.lsp.inlay_hint.enable(false)
   ```

3. **Check for slow plugins**:
   ```vim
   :Lazy profile
   ```

### Search Not Working

- **Ensure ignorecase/smartcase are set** (they are by default in options.lua)
- **Escape special regex characters**: `/\.` for literal dot
- **Use `\C` to force case-sensitive**: `/\Cpattern`

---

## Additional Resources

- **Neovim Help**: `:help` - Comprehensive built-in documentation
- **Search Help**: `<leader>sh` - Fuzzy search help topics
- **LSP Configuration**: Check `lua/kickstart/plugins/lspconfig.lua`
- **Plugin Docs**: `:help <plugin-name>` for installed plugin docs
- **Key Mappings**: `:map` or `<space>` to see all bindings

---

## Tips for VS Code Refugees

| VS Code Habit | Neovim Equivalent | Difference |
|---------------|-------------------|-----------|
| Cmd+F | `/` or `<leader>sg` | More powerful, modal |
| Cmd+H | `:%s/old/new/g` | Requires regex syntax |
| Cmd+D (multi-select) | `<C-v>` visual block | Different paradigm |
| Cmd+P (file search) | `<leader>sf` | Very similar |
| Cmd+Shift+P (command palette) | `<space>` (which-key) | Visual keybind menu |
| Ctrl+G (go to line) | `:10` or `10G` | Simpler in Neovim |
| F12 (go to definition) | `gd` | Identical functionality |
| Shift+F12 (find refs) | `gr` | Identical functionality |
| Ctrl+` (terminal) | `:terminal` | Built-in terminal |
| Ctrl+B (toggle sidebar) | `<leader>\` | File explorer toggle |

---

**Last Updated**: 2026-03-15
**Config Version**: Kickstart-modular with custom enhancements

