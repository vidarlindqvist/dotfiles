-- nvim-treesitter `main` branch (the rewrite) -- NOT the old `configs.setup{}` API.
-- Highlighting/indent are no longer options here; they are Neovim features you
-- turn on per-filetype. See :h treesitter-highlight
return {
    'nvim-treesitter/nvim-treesitter',
    -- pinned: the plugin pins exact parser revisions, so plugin and compiled
    -- parsers must move together. Unpinning requires :TSUpdate in the same step.
    commit = '8b3a191c015dd66a92d51a112ed96af0aac13b63',
    lazy = false, -- the rewrite does not support lazy-loading
    build = ":TSUpdate",
    config = function()
	local ts = require('nvim-treesitter')

	ts.setup()

	
	local parsers = {
	    "lua",
	    "python",
	    "matlab",
	    "latex",  -- parser name differs from the filetype: tex -> latex
	    "bibtex", -- bib -> bibtex
	    "typst",  -- parser name matches the filetype here, no remapping needed
	    "vim",
	    "vimdoc",
	    "query",
	}

	-- No-op for parsers that are already installed. Runs async.
	ts.install(parsers)

	-- Filetypes to turn treesitter on for.
	local filetypes = { "lua", "python", "matlab", "tex", "bib", "typst", "vim", "help", "query" }

	vim.api.nvim_create_autocmd('FileType', {
	    pattern = filetypes,
	    callback = function()
		-- Guards the first launch, when a parser may still be compiling.
		if pcall(vim.treesitter.start) then
		    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	    end,
	})
    end
}
