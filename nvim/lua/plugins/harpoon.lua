-- harpoon2 -- pin a handful of files and jump between them with one keystroke.
-- NOTE: leader a for pinning
-- NOTE: branch = "harpoon2". The default branch (master) is harpoon 1, which
-- has a completely different API -- `require("harpoon.mark")` vs the
-- `harpoon:list()` calls below. Tutorials predating 2023 use the old one.
return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    commit = '87b1a3506211538f460786c23f98ec63ad9af4e5', -- pinned, as with the rest
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
	local harpoon = require('harpoon')
	harpoon:setup()

	local map = function(lhs, rhs, desc)
	    vim.keymap.set('n', lhs, rhs, { desc = desc, silent = true })
	end

	map('<leader>a', function() harpoon:list():add() end, 'Harpoon: pin this file')
	map('<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
					       'Harpoon: menu')

	-- Numbered slots. <leader>1..4 rather than the upstream <C-h/t/n/s>:
	-- the number matches the position shown in the menu, so there's nothing
	-- to memorise.
	for i = 1, 4 do
	    map('<leader>' .. i, function() harpoon:list():select(i) end,
					       'Harpoon: file ' .. i)
	end

	-- cycle without opening the menu
	map('<leader>hp', function() harpoon:list():prev() end, 'Harpoon: previous')
	map('<leader>hn', function() harpoon:list():next() end, 'Harpoon: next')
    end
}
