return {
  'https://github.com/rcarriga/nvim-notify',
  config = function()
    vim.notify = require("notify")
  end
}
