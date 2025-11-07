local n = require('nvim')()
local ctlseqs = require('ctlseqs')
local uv = vim.uv

local args = vim.deepcopy(_G.arg)
table.insert(args, 1, '--embed')
n.clear({
  args = args,
  merge = false,
})

local Screen = require('screen')

local l = io.open('/tmp/nvim-log.txt', 'a')
local log = function(...)
  -- io.write(ctlseqs.cup:format(24 + 5, 1))
  -- io.write(vim.inspect({ ... }) .. '\n')
  l:write(vim.inspect({ ... }) .. '\n')
  l:flush()
end

local stdin = assert(uv.new_tty(0, false))
local screen = Screen.new(stdin:get_winsize())
-- local screen = Screen.new(80, 24)
-- vim.print(n.api.nvim_list_uis())
-- vim.print(n.api.nvim__redraw({ win = 0, flush = true }))
-- screen:print_snapshot()
-- vim.print(s:next_message())
-- require('nvim').api
--
-- vim.fn.stdioopen({
--   on_stdin = function(data)
--     vim.print('got data', data)
--   end,
-- })

local redraw_debug = false
local grid_clear = function()
  io.write(ctlseqs.home)
  io.write(ctlseqs.erase_below_cursor)
  io.write(ctlseqs.sgr_reset)
end

function screen:_row_repr2(gridnr, rownr)
  local rv = {}
  local i = 1
  local has_windows = self._options.ext_multigrid and gridnr == 1
  local row = self._grids[gridnr].rows[rownr]
  if has_windows and self.msg_grid and self.msg_grid_pos < rownr then
    return '[' .. self.msg_grid .. ':' .. string.rep('-', #row) .. ']'
  end
  while i <= #row do
    local did_window = false
    if has_windows then
      for id, pos in pairs(self.win_position) do
        if
          i - 1 == pos.startcol
          and pos.startrow <= rownr - 1
          and rownr - 1 < pos.startrow + pos.height
        then
          table.insert(rv, '[' .. id .. ':' .. string.rep('-', pos.width) .. ']')
          i = i + pos.width
          did_window = true
        end
      end
    end

    if not did_window then
      table.insert(rv, (self._attr_table[row[i].hl_id] or {})[3] or '')
      table.insert(rv, row[i].text)
      table.insert(rv, ctlseqs.sgr_reset)
      i = i + 1
    end
  end
  -- trailing whitespace
  return table.concat(rv, '') --:gsub('%s+$', '')
end

function screen:_render()
  local rv = {}
  for igrid, grid in pairs(self._grids) do
    local height = grid.height
    if igrid == self.msg_grid then
      height = self._grids[1].height - self.msg_grid_pos
    end
    for i = 1, height do
      table.insert(rv, self:_row_repr2(igrid, i))
    end
  end
  io.write(table.concat(rv, '\n'))
end

function screen:_handle_grid_clear(grid)
  Screen._handle_grid_clear(self, grid)
  grid_clear()
end
function screen:_handle_flush()
  io.write(ctlseqs.sgr_reset)
  io.write(ctlseqs.cup:format(self._cursor.row, self._cursor.col))
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

local cursor_shape = function(name)
  local shapes = { block = 1, underline = 3, bar = 5 }
  io.write(ctlseqs.cursor_shape:format(shapes[name] or 5))
end
function screen:_handle_mode_change(mode, idx)
  assert(mode == self._mode_info[idx + 1].name)
  self.mode = mode
  cursor_shape(self._mode_info[idx + 1].cursor_shape)
end
function screen:_print_snapshot()
  -- return Screen._print_snapshot(self)
  grid_clear()
  self:_render()
  -- io.write(ctlseqs.cup:format(self._cursor.row , self._cursor.col ))
  io.flush()
end

function screen:_handle_grid_line(grid, row, col, items, wrap)
  Screen._handle_grid_line(self, grid, row, col, items, wrap)
  io.write(ctlseqs.cup:format(self._cursor.row, self._cursor.col))
  grid_clear()
  self:_render()
end

function screen:_handle_grid_scroll(g, top, bot, left, right, rows, cols)
  Screen._handle_grid_scroll(self, g, top, bot, left, right, rows, cols)
end

uv.tty_set_mode(stdin, uv.constants.TTY_MODE_RAW)
stdin:read_start(vim.schedule_wrap(function(err, data)
  assert(not err, err)
  if not data then
    return
  end
  if n.get_session().closed or n.get_session().eof_err then
    vim.cmd.qall()
  end
  if data == '\127' then
    data = vim.keycode('<c-h>')
  end
  log('KEY:', data)
  if not n.get_session()._is_running then
    n.feed(data)
    if redraw_debug then
      grid_clear()
      screen:redraw_debug()
    end
  end
end))

assert(uv.new_timer()):start(100, 10, function()
  if n.get_session().closed or n.get_session().eof_err then
    vim.schedule_wrap(vim.cmd.qall)()
  end
  if not n.get_session()._is_running then
    screen:sleep(0)
  end
end)

while true do
  vim.wait(0)
end
