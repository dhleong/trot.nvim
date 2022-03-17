trot.nvim
=========

*A relaxed Dash plugin for Neovim*

## What?

trot.nvim is a lightweight Neovim plugin for opening the [Dash][1] macOS documentation search app.

## How?

Install with your favorite plugin manager. I like [Plug][2]:

```vim
Plug 'dhleong/trot.nvim'
```

Then, map the lua function however you prefer. For example:

```vim
nnoremap <leader>K <cmd>lua require'trot'.search()<cr>
```

By default, `search()` will search for the word under your cursor, and try to "guess" the best keywords based on your filetype. Its full API is:

```lua
---Open dash, searching with the query string (if provided) or the word under the cursor otherwise
---A list of keywords may also optionally be provided, to override the default (see `buf_keywords`)
---@param query string|nil
---@param keywords string[]|nil
function M.search(query, keywords)
```

So, you can provide a specific string to `query`, as well as your own set of `keywords` for selecting docsets to search in.

### Custom "BROWSER"

By default, trot.nvim will use the macOS `open` tool to activate the special URI that activates Dash. However, it also respects the `$BROWSER` environment variable, so if you have a special setup you can still activate Dash. For example, if you are doing remote development over SSH or something similar, you might be able to use `$BROWSER` to tunnel back to your local machine and open the URI (and Dash!) from there.

[1]: https://kapeli.com/dash
[2]: https://github.com/junegunn/vim-plug
