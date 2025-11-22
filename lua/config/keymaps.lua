local opts = { noremap = true, silent = true }
local keymap = vim.keymap

-- Navigaton
-- Window navigation
opts.desc = "Move cursor to right buffer"
keymap.set("n", "<C-h>", "<C-w>h", opts) -- move left
opts.desc = "Move cursor to lower buffer"
keymap.set("n", "<C-j>", "<C-w>j", opts) -- move below
opts.desc = "Move cursor to upper buffer"
keymap.set("n", "<C-k>", "<C-w>k", opts) -- move top
opts.desc = "Move cursor to left buffer"
keymap.set("n", "<C-l>", "<C-w>l", opts) -- move right

-- Tab navigation
opts.desc = "Load next tab in buffer"
keymap.set("n", "<A-l>", ":tabnext<CR>", opts) -- next buffer
opts.desc = "Load previous tab in buffer"
keymap.set("n", "<A-h>", ":tabprevious<CR>", opts) -- next buffer

-- Move text up and down
opts.desc = "Move selection one line up"
keymap.set("v", "<C-k>", ":m .-2<CR>==", opts)
opts.desc = "Move selection one line down"
keymap.set("v", "<C-j>", ":m .+1<CR>==", opts)
opts.desc = "Replace selection with copied lines"
keymap.set("v", "p", '"_dP', opts)

-- Resize with arrows
opts.desc = "Move buffer size to the top"
keymap.set("n", "<C-Up>", ":resize +2<CR>", opts)
opts.desc = "Move buffer size to the bottom"
keymap.set("n", "<C-Down>", ":resize -2<CR>", opts)
opts.desc = "Move buffer size to the left"
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
opts.desc = "Move buffer size to the right"
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Move text up and down
keymap.set("x", "<C-j>", ":move '>+1<CR>gv-gv", opts)
keymap.set("x", "<C-k>", ":move '<-2<CR>gv-gv", opts)
