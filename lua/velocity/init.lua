local M = {}
local api = vim.api
local buf, win

local default_options = {}
for k, v in pairs(default_options) do M[k] = v end

-- vim.cmd [[
--   hi def link VelocityControlChar @constructor
-- ]]

-- TODO: would be good to link the below to a known group in order to respect user set theme
vim.cmd('highlight VelocityChar guifg=red')
vim.cmd('syntax clear VelocityChar')

M.setup = function(opts) for k, v in pairs(opts) do M[k] = v end end

M.open_window = function(input)
  buf = api.nvim_create_buf(false, true)
  -- TODO: we wanna probably set this in the opts
  -- TODO: nvim_create_buf makes a buffer either "listed" or "scratch",
  -- If we wanna pause the reader we should think about making it a listed buffer
  local border_buf = api.nvim_create_buf(false, true)

  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'filetype', 'Velocity')

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")
  local win_height = 1
  local win_width = math.ceil(width * 0.8)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local border_opts = {
    style = "minimal",
    relative = "editor",
    width = win_width + 2,
    height = win_height + 2,
    row = row - 1,
    col = col - 1
  }

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }

  local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
  local middle_line = '║' .. string.rep(' ', win_width) .. '║'

  for i = 1, win_height do
    table.insert(border_lines, middle_line)
  end

  -- TODO: Could make top and bottom border lines point at the focus char
  table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
  api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
  local border_win = api.nvim_open_win(border_buf, true, border_opts)
  win = api.nvim_open_win(buf, true, opts)
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

  api.nvim_win_set_option(win, 'cursorline', true)
  api.nvim_buf_set_lines(buf, 0, -1, false, input)
end

local function center(str, balance)
  local width = api.nvim_win_get_width(win)
  local shift = math.floor(width / 2) - math.floor(string.len(balance) / 2)
  -- - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
end

local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

M.start_reading = function(buffer)
  -- We want to loop over the selection, and then animate the text and highlight the correct letter
  --
  -- then then then then
  local current_state = {
    time = 0,
    words = split(buffer, '%s')
  }

  local timer = vim.loop.new_timer()
  local stop = false

  timer:start(0, 500,
    vim.schedule_wrap(function()
      current_state.time = current_state.time + 1
      local removed = table.remove(current_state.words, 1)
      local new_string = split(table.concat(current_state.words, ' '), '%s')
      local centered_text = center(table.concat(new_string, ' '), removed)

      local control_char_highlight = math.ceil(string.len(new_string[1]) / 2)
      local loop_pairs = { [new_string[1]] = { control_char_highlight } }
      for word, v in pairs(loop_pairs) do
        for _, position_of_letter in ipairs(v) do
          vim.cmd('syntax match VelocityChar "' ..
            word .. '"lc=' .. (position_of_letter - 1) .. ',me=s+' .. position_of_letter)
        end
      end

      api.nvim_buf_set_lines(buf, 0, -1, false, { centered_text })

      if current_state.words[2] == nil or current_state.time == 100 then
        timer:stop()
      end
    end))
end

vim.api.nvim_create_user_command("Velocity", function(arg)
  local mode
  if arg.range == 0 then
    mode = "n"
    print('mode: ', mode)
  else
    mode = "v"
    local vstart = vim.fn.getpos("'<")
    local vend = vim.fn.getpos("'>")

    local line_start = vstart[2]
    local line_end = vend[2]

    local lines = vim.fn.getline(line_start, line_end)
    M.open_window(lines)
    -- TODO: Need to set keymaps and events for: start_reading, pause_reading, end_reading
    M.start_reading(table.concat(lines))
  end
end, {
  range = true,
  nargs = "?",
})

return M
