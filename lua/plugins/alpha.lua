return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
	config = function()
		local require_safe = require("utils.require_safe")

		local alpha = require_safe("alpha")
		local dashboard = require_safe("alpha.themes.dashboard")
		local signs = require_safe("config.signs")

		if not (alpha and signs and dashboard) then
			return
		end

		local header = {
			type = "text",
			opts = {
				position = "center",
				hl = "Type",
			},
			val = {
				" ⣴⣾⣧     ⢸⣿⣶                                  ⢠⣿⣷⡀                ",
				" ⣿⣿⣿⣧    ⢸⣿⣿                                  ⠘⣿⡿⠁                ",
				" ⣿⣿⣿⣿⣧   ⢸⣿⣿     ⣀⣤⣤⣀⡀     ⢀⣠⣤⣤⣀⡀   ⣀⣤⡀    ⢠⣀  ⣄⣀  ⢠⣤⣤⡀⣀⣤⣤⡀⡀⢀⣤⣤⣀⡀ ",
				" ⣿⣿⡇⢿⣿⣧  ⢸⣿⣿   ⣴⣿⣿⠛⠛⢿⣿⣆  ⢀⣾⣿⠟⠛⠛⣿⣿⣦⡀ ⣿⣿⣷    ⣿⣿  ⣿⣿   ⣿⣿⣿⠿⢿⣿⣿⣾⡿⠿⣿⣿⣷ ",
				" ⢿⣿⡇ ⢻⣿⣧ ⢸⣿⡟  ⣸⣿⣿    ⣿⣿⡀ ⣿⣿⠇    ⣿⣿⣇ ⠈⣿⣿⡄  ⣼⣿⠃  ⣿⣿   ⣿⣿⠁  ⣿⣿⣿  ⠸⣿⣿ ",
				" ⢸⣿⡇  ⠻⣿⣧⢸⣿⡇  ⣿⣿⡇⣿⣿⣿⣿⣿⣿⡇ ⣿⣿⡀    ⢸⣿⣿  ⠹⣿⣿⡀⢠⣿⡟   ⣿⣿   ⣿⣿   ⣿⣿⡇   ⣿⣿ ",
				" ⢸⣿⡇   ⠹⣿⣿⣿⡇  ⢻⣿⣷        ⣿⣿⣇    ⣼⣿⡿   ⢿⣿⡆⣿⣿    ⣿⣿   ⣿⣿   ⣿⣿⡇   ⣿⣿ ",
				" ⢸⣿⡇    ⠙⣿⣿⡇   ⢿⣿⣷⣄⣀⣀⣴⣿⡀ ⠘⣿⣿⣦⣀⣀⣴⣿⡿     ⣿⣿⣿⠇    ⣿⣿   ⣿⣿   ⣿⣿⡇   ⣿⣿ ",
				" ⠘⠛⠃     ⠘⠛⠃    ⠉⠛⠿⠿⠿⠛     ⠙⠻⠿⠿⠛⠉      ⠘⠛⠛     ⠿⠟   ⠿⠟   ⠿⠿⠃   ⠿⠛ ",
			},
		}

		local function set_button_color(button)
			button.opts.hl = "Type"
			button.opts.hl_shortcut = "DiagnosticHint"
			return button
		end

		local function generate_dashboard_button(str, shortcut_prefix, icon, cmd)
			local parts = {}
			local length = 0
			local name = ""
			for part in string.gmatch(str, "([^/]+)") do
				table.insert(parts, part)
				length = length + 1
			end
			if length > 1 then
				name = parts[length - 1] .. "/" .. parts[length]
			else
				name = parts[1]
			end
			local button = dashboard.button(shortcut_prefix, icon .. " " .. name, cmd)
			return set_button_color(button)
		end

		local last_projects = {
			type = "group",
			val = function()
				local projects = require("telescope._extensions.project.utils").get_projects("recent")
				local val = {
					{
						type = "text",
						val = "Last Projects",
						opts = {
							position = "center",
							hl = "Type",
						},
					},
					{
						type = "padding",
						value = 1,
					},
				}
				for i, project in ipairs(projects) do
					if i > 5 then
						break
					end
					local cmd = "<CMD>lua require('telescope._extensions.project.utils').change_project_dir('"
						.. project.path
						.. "')<CR><CMD>Telescope file_browser<CR>"
					table.insert(
						val,
						generate_dashboard_button(
							project.path,
							"<leader>p" .. tostring(i),
							signs.system.directory.project,
							cmd
						)
					)
				end
				return val
			end,
		}
		local last_files = {
			type = "group",
			val = function()
				local val = {
					{
						type = "text",
						val = "Last Files",
						opts = {
							position = "center",
							hl = "Type",
						},
					},
					{
						type = "padding",
						value = 1,
					},
				}
				local current_file = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
				local old_files = {}
				for _, file in ipairs(vim.v.oldfiles) do
					if old_files[file] == nil and file ~= current_file and vim.loop.fs_stat(file) then
						table.insert(old_files, file)
					end
				end
				local i = 1
				for _, file in ipairs(old_files) do
					if i > 5 then
						break
					end
					if
						not string.find(file, "nvim/runtime/doc/")
						and not (
							string.find(file, "/share/nvim/site/pack/packer/")
							and string.find(file, "/doc/")
							and string.find(file, ".txt")
						)
					then
						table.insert(
							val,
							generate_dashboard_button(
								file,
								"<leader>n" .. tostring(i),
								signs.system.file.default,
								"<CMD>e " .. file .. "<CR>"
							)
						)
						i = i + 1
					end
				end
				return val
			end,
		}

		local buttons = {
			type = "group",
			val = {
				{
					type = "text",
					val = "Actions",
					opts = {
						position = "center",
						hl = "Type",
					},
					{
						type = "padding",
						value = 1,
					},
				},
				set_button_color(
					dashboard.button(
						"1",
						signs.system.directory.config .. " Open Neovim config direction",
						"<CMD>Telescope file_browser path=$NVIM_CONFIG select_buffer=true<CR>"
					)
				),
				set_button_color(
					dashboard.button(
						"2",
						signs.system.utils.shell .. " Open ZSH config direction",
						"<CMD>Telescope file_browser path=$ZSH_CONFIG select_buffer=true<CR>"
					)
				),
				set_button_color(
					dashboard.button("3", signs.system.file.new .. " New File", "<CMD>enew | startinsert<CR>")
				),
				set_button_color(
					dashboard.button(
						"4",
						signs.system.directory.browse .. " Browse Projects",
						"<CMD>Telescope project<CR>"
					)
				),
				set_button_color(
					dashboard.button(
						"5",
						signs.system.directory.browse .. " Browse Files",
						"<CMD>Telescope file_browser<CR>"
					)
				),
				set_button_color(
					dashboard.button(
						"6",
						signs.system.directory.search .. " Find File",
						"<CMD>Telescope find_files<CR>"
					)
				),
				set_button_color(
					dashboard.button(
						"7",
						signs.system.file.search .. " Live Grep (Find Text)",
						"<CMD>Telescope live_grep<CR>"
					)
				),
				set_button_color(dashboard.button("q", signs.quit.icon .. " Quit", "<CMD>qa<CR>")),
			},
		}

		alpha.setup({
			layout = {
				{ type = "padding", val = 3 },
				header,
				{ type = "padding", val = 2 },
				last_projects,
				{ type = "padding", val = 2 },
				last_files,
				{ type = "padding", val = 2 },
				buttons,
			},
		})
	end,
}
