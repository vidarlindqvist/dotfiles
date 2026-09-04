return {
    -- Tracks master, not tag 0.1.8: only master's previewer uses the core
    -- vim.treesitter API. 0.1.8 calls the removed nvim-treesitter.configs API
    -- and errors on every preview when treesitter is on the `main` branch.
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    commit = '427b576c16792edad01a92b89721d923c19ad60f', -- pinned: master moves, tags don't exist past 0.1.8
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
	local builtin = require('telescope.builtin')
	vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
	vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
	vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
	vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    end
}
