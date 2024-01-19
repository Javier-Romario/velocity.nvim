-- We want to loop over the selection, and then animate the text and highlight the correct letter
require('testhi.util')
local bufnr = nil

-- Window Settings
local width = vim.api.nvim_get_option("columns")
local win_height = 10
local win_width = math.ceil(width * 0.8)

local function open_popup_window(text)
  -- Step 1: Create a Popup Buffer
  bufnr = vim.api.nvim_create_buf(false, true)             -- create a new buffer
  print('text bout to go into the buf', text)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, { text }) -- set buffer lines

  -- Step 2: Open Popup Window
  local opts = {
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = 5,
    row = 10,
    style = 'minimal',
    border = 'rounded',
  }
  local _ = vim.api.nvim_open_win(bufnr, false, opts)
end

-- Step 3: Define a Highlight Group
-- vim.cmd("highlight CustomHighlight guifg=red guibg=yellow")
-- Step 4: Apply the Highlight
-- Assuming the letter to highlight is the 5th character on the line
local ns_id = vim.api.nvim_create_namespace('mynamespace')
vim.api.nvim_set_hl(0, "CustomHighlight", { fg = "red", bg = "#545454" })

local function add_highlight(start_pos, end_pos)
  start_pos = start_pos or 1
  end_pos = end_pos or 2

  if bufnr ~= nil then
    vim.highlight.range(bufnr, ns_id, "CustomHighlight", { 0, 0 }, { 1, 5 }, { inclusive = true, priority = 50 })
  end
end

local function start_timer(input)
  local text = "This is a test line"

  if input ~= nil then
    text = table.concat(input, '%s') -- since the table is just passed as a list
    print("changed text", text)
  end

  open_popup_window(text)

  local timer = vim.loop.new_timer()

  timer:start(0, 300,
    vim.schedule_wrap(function()
      local new_text = Split(text)
      table.remove(new_text, 1)

      if bufnr ~= nil then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { Join(new_text, ' ') })
        add_highlight()

        if IsArrayEmpty(new_text) then
          timer:stop()
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end
    end)
  )
end

vim.api.nvim_create_user_command("Testhi", function(arg)
  -- Do_setup()
  local mode
  if arg.range == 0 then
    mode = "n"
    start_timer()
  else
    mode = "v"
    local vstart = vim.fn.getpos("'<")
    local vend = vim.fn.getpos("'>")

    local line_start = vstart[2]
    local line_end = vend[2]

    local lines = vim.fn.getline(line_start, line_end)
    start_timer(lines)
  end
end, {
  range = true,
  nargs = "?",
})
