-- LaTeX: compilation, PDF viewing/sync, and heavy snippet use.
--
-- Split from lsp.lua deliberately: texlab (the LSP) lives there alongside
-- basedpyright/ruff, since it's just another language server. Everything
-- LaTeX-specific that ISN'T "talk LSP" lives here.
--
-- Division of labour, so vimtex and texlab don't fight over the same job:
--   vimtex -- compiles (continuous latexmk), opens/syncs Skim, folding
--   texlab -- diagnostics, completion, hover (texlab's own build/search
--             are turned off in lsp.lua for exactly this reason)
return {
    {
	'lervag/vimtex',
	commit = '2f279775e5b73743973bf2b013791f8f1673d5ac', -- pinned, as with the rest
	lazy = false, -- vimtex explicitly does not support lazy-loading
	init = function()
	    -- Skim, installed via `brew install --cask skim`. displayline (from
	    -- the same cask) is what drives forward search: cursor position in
	    -- nvim -> jump to the matching spot in the rendered PDF.
	    vim.g.vimtex_view_method = 'skim'

	    -- latexmk in continuous mode: saving the .tex file recompiles
	    -- automatically, no manual `\ll` needed after the first run.
	    vim.g.vimtex_compiler_method = 'latexmk'
	    vim.g.vimtex_compiler_latexmk = {
		continuous = 1,
		options = {
		    '-pdf', '-interaction=nonstopmode', '-synctex=1',
		},
	    }

	    -- Don't let a warning steal focus into the quickfix window mid-typing;
	    -- still opens automatically on an actual compile error.
	    vim.g.vimtex_quickfix_open_on_warning = 0

	    -- texlab already highlights syntax errors as you type; vimtex's own
	    -- indentation logic frequently disagrees with treesitter's on tex
	    -- files, so leave indenting to treesitter (configured in
	    -- treesitter.lua) rather than have the two argue.
	    vim.g.vimtex_indent_enabled = 0

	    -- Off by default in vimtex. One fold per section/environment,
	    -- toggled with za (standard vim fold keys, unmapped by this config).
	    vim.g.vimtex_fold_enabled = 1
	end,
    },
    {
	-- Gilles Castel's widely-used math-snippet collection, ported to
	-- LuaSnip. LuaSnip itself lives in lsp.lua's nvim-cmp dependencies,
	-- since it's now the snippet engine for every filetype, not just tex.
	'iurimateus/luasnip-latex-snippets.nvim',
	commit = 'a14821dd680dfdd2006b135425cc2a8ab297ebc6', -- pinned, as with the rest
	ft = { 'tex', 'plaintex', 'markdown' },
	dependencies = { 'L3MON4D3/LuaSnip' },
	config = function()
	    -- use_treesitter: math-mode detection (are we inside $...$ or not,
	    -- which most of these snippets key off) via the tex treesitter
	    -- parser already set up in treesitter.lua, rather than vimtex's
	    -- regex-based detection.
	    require('luasnip-latex-snippets').setup({ use_treesitter = true })

	    -- Required by this snippet pack: most of its math snippets are
	    -- autosnippets -- they expand the instant the trigger text is
	    -- typed in math mode (e.g. "mk" -> "$$" with cursor centred),
	    -- with no Tab/Enter needed. Without this line those triggers are
	    -- silently inert.
	    require('luasnip').config.setup({ enable_autosnippets = true })
	end,
    },
}
