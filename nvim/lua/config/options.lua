vim.opt.number = true
vim.opt.cursorline = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4

-- Reclaim the line nvim reserves under lualine for the command line. With
-- zellij's bar directly below, that blank line read as a gap between two
-- bars. The cmdline reappears on demand the moment you press : or /.
vim.opt.cmdheight = 0
-- lualine already shows the mode, so nvim's own "-- INSERT --" was duplicate
-- info -- and with cmdheight=0 it has nowhere to render anyway.
vim.opt.showmode = false

-- No plugin here needs a language provider (all are pure Lua), so switch them
-- off: skips the interpreter probing Neovim does at startup and keeps
-- :checkhealth quiet. Re-enable python3 if a python remote plugin is ever added.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0






