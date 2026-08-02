require("core.ui.auto_cmds")
require("core.ui.tabline").setup()
require("core.ui.statusline").setup()
require("core.ui.winbar").setup()
require("core.ui.dialogs.toggle").setup()
require("core.ui.base64").setup()

vim.ui.input = require("core.ui.dialogs.input").input
vim.ui.select = require("core.ui.dialogs.select").select
