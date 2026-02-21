local require_safe = require("utils.require_safe")

local colors = require_safe("core.colors")

if not colors then
	return
end

colors.logger = {
	debug = "#FFFFFF",
	info = "#00C3FF",
	pass = "#C0FF00",
	warn = "#FF8314",
	error = "#F62430",
}

return colors
