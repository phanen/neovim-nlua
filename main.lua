---@diagnostic disable: need-check-nil, param-type-mismatch, duplicate-set-field, unused
local n = require('nvim')()
local ctlseqs = require('ctlseqs')
local uv = vim.uv

local dbg = false

local args = vim.deepcopy(_G.arg)
table.insert(args, 1, '--embed')
n.clear({
  args = args,
  merge = false,
})
local s = n.get_session()

local render = {
  hl_id = nil,
  clear = function()
    io.write(ctlseqs.home)
    io.write(ctlseqs.sgr_reset)
    io.write(ctlseqs.erase_below_cursor)
  end,
  cup = function(row, col)
    io.write(ctlseqs.cup:format(row, col))
  end,
  cursor_shape = function(name)
    local shapes = { block = 1, underline = 3, bar = 5 }
    io.write(ctlseqs.cursor_shape:format(shapes[name] or 5))
  end,
}

local Screen = require('screen')

local log = function(...)
  if not dbg then
    return
  end
  io.stderr:write(vim.inspect({ ... }) .. '\n')
end

local stdin = assert(uv.new_tty(0, false))
local screen = Screen.new(stdin:get_winsize())

function screen:_row_repr2(gridnr, rownr)
  local rv = {}
  local i = 1
  local row = self._grids[gridnr].rows[rownr]
  while i <= #row do
    local cell = row[i]
    table.insert(rv, self._attr_table[cell.hl_id][3] or ctlseqs.sgr_reset)
    table.insert(rv, cell.text)
    i = i + 1
  end
  table.insert(rv, ctlseqs.sgr_reset)
  return table.concat(rv, '')
end

function screen:_render(w)
  local rv = {}
  for igrid, grid in pairs(self._grids) do
    local height = grid.height
    for i = 1, height do
      table.insert(rv, self:_row_repr2(igrid, i))
    end
  end
  (w or io.write)(table.concat(rv, '\n'))
end

function screen:_handle_grid_clear(grid)
  Screen._handle_grid_clear(self, grid)
  render.clear()
end

function screen:_handle_flush()
  io.write(ctlseqs.sgr_reset)
  render.cup(self._cursor.row, self._cursor.col)
end
function screen:_handle_hl_attr_define(id, rgb_attrs, cterm_attrs, info)
  Screen._handle_hl_attr_define(self, id, rgb_attrs, cterm_attrs, info)
  -- vim.print(id, rgb_attrs, cterm_attrs, info)
  local d = {}
  d[#d + 1] = '\x1b[0m'
  local function parse_rgb(rgb)
    return math.floor(rgb / 65536) % 256, math.floor(rgb / 256) % 256, rgb % 256
  end
  if rgb_attrs.foreground then
    local r, g, b = parse_rgb(rgb_attrs.foreground)
    d[#d + 1] = ctlseqs.sgr_fg_rgb:format(r, g, b)
  end
  if rgb_attrs.background then
    local r, g, b = parse_rgb(rgb_attrs.background)
    d[#d + 1] = ctlseqs.sgr_bg_rgb:format(r, g, b)
  end
  if rgb_attrs.bold then
    d[#d + 1] = ctlseqs.bold_set
  end
  self._attr_table[id][3] = table.concat(d, '')
  -- vim.print(self._attr_table)
  -- vim.print(self._hl_info)
end

function screen:_handle_mode_change(mode, idx)
  assert(mode == self._mode_info[idx + 1].name)
  self.mode = mode
  render.cursor_shape(self._mode_info[idx + 1].cursor_shape)
end

function screen:print_snapshot()
  -- return Screen.print_snapshot(self)
  -- render.clear()
  -- self:_render()
  -- io.flush()
end

function screen:_handle_grid_clear(grid)
  Screen._handle_grid_clear(self, grid)
  render.clear()
end

function screen:_handle_grid_line(grid, row, col, items, wrap)
  Screen._handle_grid_line(self, grid, row, col, items, wrap)
  render.cup(row + 1, 0)
  io.write(self:_row_repr2(grid, row + 1))
  -- self:_render()
end

function screen:_handle_grid_scroll(g, top, bot, left, right, rows, cols)
  Screen._handle_grid_scroll(self, g, top, bot, left, right, rows, cols)
end

uv.tty_set_mode(stdin, uv.constants.TTY_MODE_RAW)
io.write(ctlseqs.smcup)
stdin:read_start(vim.schedule_wrap(function(err, data)
  assert(not err, err)
  if not data then
    return
  end
  if s.closed or s.eof_err then
    vim.cmd.qall()
  end
  if data == '\127' then
    data = vim.keycode('<c-h>')
  elseif data == '\027;' then
    data = '<a-;>'
  end
  log('KEY:', data)
  if not s._is_running then
    n.feed(data)
    if dbg then
      render.clear()
      screen:redraw_debug(nil, log)
    end
  end
end))

assert(uv.new_timer()):start(100, 10, function()
  if s.closed or s.eof_err then
    vim.schedule_wrap(vim.cmd.qall)()
    io.write(ctlseqs.rmcup)
  end
  if not s._is_running then
    screen:sleep(0)
  end
end)

while true do
  vim.wait(0)
end
