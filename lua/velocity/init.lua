local M = {}
local api = vim.api
local buf, win

local default_options = {}
for k, v in pairs(default_options) do M[k] = v end

M.setup = function(opts) for k, v in pairs(opts) do M[k] = v end end

function create_window(opts)
end

M.open_window = function(input)
  print('We tried to open a window')
  buf = api.nvim_create_buf(false, true)
  -- TODO: we wanna probably set this in the opts
  -- TODO: nvim_create_buf makes a buffer either "listed" or "scratch",
  -- If we wanna pause the reader we should think about making it a listed buffer
  local border_buf = api.nvim_create_buf(false, true)


  -- this one is the border buffer
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  -- this one is where the fun happens
  api.nvim_buf_set_option(buf, 'filetype', 'Velocity')


  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")
  print('height', height)
  local win_height = 1
  -- math.ceil(height * 0.8 - 4)
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
  table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
  api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
  local border_win = api.nvim_open_win(border_buf, true, border_opts)
  win = api.nvim_open_win(buf, true, opts)
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

  api.nvim_win_set_option(win, 'cursorline', true) -- it highlight line with the cursor on it
  -- we can add title already here, because first line will never change
  api.nvim_buf_set_lines(buf, 0, -1, false, { input, '', '' })
  api.nvim_buf_add_highlight(buf, -1, 'WhidHeader', 0, 0, -1)
end

M.exec = function(options)
  local opts = vim.tbl_deep_extend("force", M, options)

  if type(opts.init) == 'function' then opts.init(opts) end

  curr_buffer = vim.fn.bufnr("%")

  local mode = opts.mode or vim.fn.mode()
  if mode == "v" or mode == "V" then
    start_pos = vim.fn.getpos("'<")
    end_pos = vim.fn.getpos("'>")
    end_pos[3] = vim.fn.col("'>") -- in case of `V`, it would be maxcol instead
  else
    local cursor = vim.fn.getpos(".")
    start_pos = cursor
    end_pos = start_pos
  end
end

vim.api.nvim_create_user_command("Velocity", function(arg)
  print('Yay we got args', arg)
  local mode
  if arg.range == 0 then
    mode = "n"
    print('mode: ', mode)
  else
    mode = "v"
    print('mode: ', mode)
    -- start_pos = vim.fn.getpos("'<")
    -- end_pos = vim.fn.getpos("'>")
    -- local lines =


    local vstart = vim.fn.getpos("'<")

    local vend = vim.fn.getpos("'>")

    local line_start = vstart[2]
    local line_end = vend[2]

    -- or use api.nvim_buf_get_lines
    local lines = vim.fn.getline(line_start, line_end)
    -- vim.pretty_print(lines)
    M.open_window(table.concat(lines))
    -- api.nvim_buf_set_lines(buf, 3, -1, false, result)

    -- M.exec()
  end
end, {
  range = true,
  nargs = "?",
  complete = function(ArgLead, CmdLine, CursorPos)
    print('WERE HERE', ArgLead, CmdLine, CursorPos)
    -- local promptKeys = {}
    -- for key, _ in pairs(M.prompts) do
    --     if key:lower():match("^" .. ArgLead:lower()) then
    --         table.insert(promptKeys, key)
    --     end
    -- end
    -- table.sort(promptKeys)
    -- return promptKeys
  end
})


return M
