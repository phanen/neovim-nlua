local n = require('nvim')()
local ctlseqs = require('ctlseqs')
local uv = vim.uv

n.clear()
-- vim.print(n.api.nvim_get_api_info())
-- local s = n.get_session()
-- vim.print(s:request('nvim_get_api_info'))
-- vim.print(n.api.nvim_get_color_map())

local Screen = require('screen')

local stdin = assert(uv.new_tty(0, false))
local screen = Screen.new(stdin:get_winsize())
vim.print(n.api.nvim_list_uis())
vim.print(n.api.nvim__redraw({ win = 0, flush = true }))
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

function screen:_row_expr_no_attr(gridnr, rownr, cursor)
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
      if not self._busy and cursor and self._cursor.col == i then
        table.insert(rv, '^')
      end
      table.insert(rv, row[i].text)
      i = i + 1
    end
  end
  -- trailing whitespace
  return table.concat(rv, '') --:gsub('%s+$', '')
end

function screen:_render_no_attr()
  local rv = {}
  for igrid, grid in pairs(self._grids) do
    local height = grid.height
    if igrid == self.msg_grid then
      height = self._grids[1].height - self.msg_grid_pos
    end
    for i = 1, height do
      -- local cursor = self._cursor.grid == igrid and self._cursor.row == i
      local cursor = false
      table.insert(rv, self:_row_expr_no_attr(igrid, i, cursor) .. '|')
    end
  end
  print(table.concat(rv, '\n'))
end

function screen:_handle_grid_clear(grid)
  Screen._handle_grid_clear(self, grid)
  grid_clear()
end
function screen:_handle_flush()
  io.write(ctlseqs.sgr_reset)
  io.write(ctlseqs.cup:format(self._cursor.row + 1, self._cursor.col + 1))
end
function screen:_handle_grid_line(grid, row, col, items, wrap)
  Screen._handle_grid_line(self, grid, row, col, items, wrap)
  self:_render_no_attr()
end
function screen:_handle_grid_scroll(grid, row, col, items, wrap)
  Screen._handle_grid_scroll(self, grid, row, col, items, wrap)
end

uv.tty_set_mode(stdin, uv.constants.TTY_MODE_RAW)
stdin:read_start(function(err, data)
  assert(not err, err)
  if not data then
    return
  end
  if n.get_session().closed then
    vim.cmd.qall()
  end
  -- print('KEY:', data)
  -- n.api.nvim_input(data)
  -- io.write(ctlseqs.cup:format(10, 10))
  if redraw_debug then
    grid_clear()
  end
  if not n.get_session()._is_running then
    n.feed(data)
    if redraw_debug then
      screen:redraw_debug()
    end
    -- screen:sleep(0)
  end
  -- n.api.nvim__redraw({ win = 0, flush = true })
  -- screen:sleep(10)
  -- screen:print_snapshot()
  -- vim.print(n.api.nvim_buf_get_lines(0, 0, -1, true))
end)

assert(uv.new_timer()):start(100, 10, function()
  if not n.get_session()._is_running then
    -- screen:redraw_debug()
    -- screen:_redraw()
    screen:sleep(0)
  end
end)

while true do
  -- print()
  vim.wait(0)
end
