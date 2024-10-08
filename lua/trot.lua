local default_open_command = "open -g"

local M = {}

---Low level utility to open Dash, passing various URI parameters
---@param params { keys:string|string[], query:string, prevent_activation:boolean }
function M.open_dash(params)
  local fragment_parts = {}
  for key, value in pairs(params) do
    local string_value = value
    if type(value) == "table" then
      string_value = table.concat(value, ",")
    end
    table.insert(fragment_parts, key .. "=" .. string_value)
  end

  local uri_fragment = table.concat(fragment_parts, "&")
  local uri = "dash-plugin://" .. uri_fragment

  local open_command = vim.env.BROWSER or default_open_command
  vim.fn.system(open_command .. " " .. vim.fn.shellescape(uri))
end

function M.open_sprint(params)
  local width = vim.fn.float2nr(vim.o.columns * 0.5)
  local height = vim.fn.float2nr(vim.o.lines * 0.8)
  local y = 1
  local x = vim.o.columns - width - 1

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    width = width,
    height = height,
    row = y,
    col = x,
  })

  local query = params.query
  if params.keywords then
    query = table.concat(params.keywords, ",") .. ": " .. query
  end

  vim.fn.termopen({
    vim.env.HOME .. "/git/sprint/target/debug/sprint",
    "--query",
    query,
  }, {
    on_exit = function()
      vim.api.nvim_win_close(win, true)
    end,
  })

  vim.cmd.startinsert()
end

---Load the preferred "keywords" for the current buffer
function M.buf_keywords()
  -- Let users overwrite on a per-buffer basis
  local buffer_local = vim.b.dash_keywords
  if buffer_local then
    return buffer_local
  end

  -- Let users overwrite with a global map
  local ft = vim.bo.filetype
  local from_global = (vim.g.dash_keywords or {})[ft]
  if from_global then
    return from_global
  end

  -- Fallback to our defaults
  local defaults = require("trot.default_keywords")[ft]
  if defaults then
    return defaults
  end

  -- No defaults? Just use the filetype
  return { ft }
end

---Open dash, searching with the query string (if provided) or the word under the cursor otherwise
---A list of keywords may also optionally be provided, to override the default (see `buf_keywords`)
---@param query string|nil
---@param keywords string[]|nil
function M.search(query, keywords)
  M.open_dash({
    query = query or vim.fn.expand("<cword>"),
    keys = keywords or M.buf_keywords(),
  })
end

---Open a tool, searching with the query string (if provided) or the word under the cursor otherwise
---A list of keywords may also optionally be provided, to override the default (see `buf_keywords`)
---@param opts {query: string|nil, keywords: string[]|nil, tool: 'dash'|'sprint'|nil}
function M.open_search(opts)
  local tool = opts.tool or "dash"
  local params = {
    query = opts.query or vim.fn.expand("<cword>"),
    keys = opts.keywords or M.buf_keywords(),
  }

  if tool == "dash" then
    M.open_dash(params)
  elseif tool == "sprint" then
    M.open_sprint(params)
  end
end

return M
