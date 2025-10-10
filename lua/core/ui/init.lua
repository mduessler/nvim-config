require("core.ui.auto_cmds")
require("core.ui.tabline").setup()
require("core.ui.statusline").setup()
require("core.ui.winbar").setup()

vim.ui.input = require("core.ui.input").input
vim.ui.select = require("core.ui.select").select
