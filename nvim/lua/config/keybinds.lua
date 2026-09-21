vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- Half-page scroll (Ctrl-d/Ctrl-u) recentres the cursor line afterward,
-- so the scroll never leaves you staring at the top/bottom edge of the
-- window. Normal and visual mode -- scrolling mid-selection should
-- behave the same way.
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Half-page down, centered" })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { desc = "Half-page up, centered" })

-- Code is edited here and run in a separate Ghostty window (another AeroSpace
-- workspace), so there is deliberately no in-editor runner and no splits.
