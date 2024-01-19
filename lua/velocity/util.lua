function Split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function Join(t, sep)
  return table.concat(t, sep)
end

function IsArrayEmpty(t)
  return #t == 0
end

-- TODO: Set this up later when you know what the potential options are
function Do_setup(M)
  local default_options = {
    reading_speed = 500, -- milliseconds
    highlight_color = "orange",
  }
  for k, v in pairs(default_options) do M[k] = v end

  M.setup = function(opts) for k, v in pairs(opts) do M[k] = v end end
end

function Exact_Center(win)
  local width = vim.api.nvim_win_get_width(win)
  local shift = math.floor(width / 2)
  return shift
end
