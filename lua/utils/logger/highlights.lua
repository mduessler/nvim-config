local colors = require("utils.logger.colors")

local set = vim.api.nvim_set_hl

set(0, "LoggerDEBUG", { fg = colors.logger.debug })
set(0, "LoggerINFO", { fg = colors.logger.info })
set(0, "LoggerPASS", { fg = colors.logger.pass })
set(0, "LoggerWARN", { fg = colors.logger.warn })
set(0, "LoggerERROR", { fg = colors.logger.error })
set(0, "LoggerTime", { fg = colors.logger.time })
set(0, "LoggerLine", { fg = colors.logger.line })
set(0, "LoggerMsg", { fg = colors.logger.msg })
