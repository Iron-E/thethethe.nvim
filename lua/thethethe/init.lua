local M = {}

-- load abbreviations.dict
local function load_abbreviations()
  -- load our dictionary string
  local dict = require("thethethe.dictionary")

  local opts = {}

  local timer, err, err_name = vim.uv.new_timer()
  if err ~= nil or err_name ~= nil then
    error(string.format("While loading abbreviations: %s [%s]", err, err_name))
  end

  --- @cast timer -nil

  local previous_key = nil
  timer:start(0, 1, function()
    for _ = 1, 20 do
      local key, value = next(dict, previous_key)
      if key == nil or value == nil then
        timer:stop()
        return
      end

      vim.schedule(function()
        vim.api.nvim_set_keymap("ia", key, value, opts)
      end)

      previous_key = key
    end
  end)
end

-- create our exported setup() function
function M.setup(opts)
  -- load our default configuration
  local config = require("thethethe.config")

  -- check for default overrides passed in
  if opts then
    config.delay_ms = opts.delay_ms or config.delay_ms
  end

  -- execute the function after config.delay_ms
  vim.defer_fn(load_abbreviations, config.delay_ms)
end

return M
