-- LSP + completion, Python-focused (LaTeX added alongside: see texlab below
-- and plugins/latex.lua for vimtex + LaTeX-specific snippets; Typst's tinymist
-- is here too, with typst-preview.nvim in plugins/typst.lua).
--
-- LSP itself needs NO plugin: `vim.lsp.config` / `vim.lsp.enable` are built into
-- Neovim 0.11+. The plugins below are only for the completion menu, which is why
-- the spec is anchored on nvim-cmp.
--
-- Servers used -- installed via brew on macOS, pacman/pipx on Arch (this
-- config is shared across both machines):
--   basedpyright -- types, completion, go-to-definition (pipx install basedpyright;
--                   not in Arch's official repos)
--   ruff         -- linting + formatting (fast; complements the type checker)
--   texlab       -- LaTeX LSP (diagnostics/completion/hover only -- see below)
--   lua_ls       -- this config's own language
--   tinymist     -- Typst LSP
return {
    'hrsh7th/nvim-cmp',
    commit = '2ffe79f1f021def8dd1fcd81deb16f1bb0d989f3', -- pinned, as with the other plugins
    lazy = false, -- LSP must be configured at startup so it attaches to the first buffer
    dependencies = {
	-- feeds LSP results into the completion menu
	{ 'hrsh7th/cmp-nvim-lsp', commit = 'cbc7b02bb99fae35cb42f514762b89b5126651ef' },
	-- words from open buffers
	{ 'hrsh7th/cmp-buffer',   commit = 'b74fab3656eea9de20a9b8116afa3cfc4ec09657' },
	-- filesystem paths
	{ 'hrsh7th/cmp-path',     commit = 'c642487086dbd9a93160e1679a1327be111cbc25' },
	-- Snippet ENGINE, used globally now (not just LaTeX) -- vim.snippet is
	-- fine for LSP-server-provided snippets, but LuaSnip is what the LaTeX
	-- snippet library in plugins/latex.lua is written against.
	-- install_jsregexp: LaTeX snippets commonly use regex-triggered
	-- expansion (e.g. Gilles Castel-style math snippets); without the
	-- compiled jsregexp lib those triggers silently don't fire.
	{ 'L3MON4D3/LuaSnip', commit = '0abc8f390b278c3b4aabc4c004ac8a088b65cf24',
	  build = 'make install_jsregexp' },
	{ 'saadparwaiz1/cmp_luasnip', commit = '98d9cb5c2c38532bd9bdb481067b20fea8f32e90' },
    },
    config = function()
	---------------------------------------------------------------------
	-- completion
	---------------------------------------------------------------------
	local cmp = require('cmp')
	local luasnip = require('luasnip')

	cmp.setup({
	    snippet = {
		expand = function(args) luasnip.lsp_expand(args.body) end,
	    },
	    window = {
		completion    = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	    },
	    mapping = cmp.mapping.preset.insert({
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>']     = cmp.mapping.abort(),
		['<C-b>']     = cmp.mapping.scroll_docs(-4),
		['<C-f>']     = cmp.mapping.scroll_docs(4),
		-- select = false: <CR> only confirms an explicitly chosen item,
		-- so pressing Enter never silently accepts a suggestion.
		['<CR>']      = cmp.mapping.confirm({ select = false }),
		-- Tab/S-Tab: jump between snippet placeholders when inside an
		-- expanded snippet (e.g. the {} in \frac{}{} after expanding
		-- "frac"). Falls through to a literal Tab otherwise -- this does
		-- NOT accept completions, so it doesn't relitigate the <CR>
		-- select=false decision above.
		['<Tab>'] = cmp.mapping(function(fallback)
		    if luasnip.expand_or_jumpable() then
			luasnip.expand_or_jump()
		    else
			fallback()
		    end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
		    if luasnip.jumpable(-1) then
			luasnip.jump(-1)
		    else
			fallback()
		    end
		end, { 'i', 's' }),
	    }),
	    sources = cmp.config.sources(
		{ { name = 'nvim_lsp' }, { name = 'luasnip' }, { name = 'path' } },
		{ { name = 'buffer' } } -- fallback group: only if the first yields nothing
	    ),
	})

	---------------------------------------------------------------------
	-- diagnostics
	---------------------------------------------------------------------
	vim.diagnostic.config({
	    virtual_text  = true,
	    severity_sort = true,
	    float         = { border = 'rounded', source = 'if_many' },
	    signs         = {
		text = {
		    [vim.diagnostic.severity.ERROR] = '✘',
		    [vim.diagnostic.severity.WARN]  = '▲',
		    [vim.diagnostic.severity.HINT]  = '⚑',
		    [vim.diagnostic.severity.INFO]  = '»',
		},
	    },
	})

	---------------------------------------------------------------------
	-- servers
	---------------------------------------------------------------------
	local caps = require('cmp_nvim_lsp').default_capabilities()

	vim.lsp.config('*', { capabilities = caps, root_markers = { '.git' } })

	-- Find the interpreter for a project. Without this basedpyright uses the
	-- system Python and reports every third-party import as unresolved, since
	-- each project keeps its deps in a local .venv.
	--
	-- Searches UPWARD from the file rather than trusting root_dir: some
	-- projects here have no .git/pyproject.toml at all, so root_dir is nil.
	local function venv_python(start)
	    -- an already-active shell venv wins; it's the explicit choice
	    local active = vim.env.VIRTUAL_ENV
	    if active and vim.uv.fs_stat(active .. '/bin/python') then
		return active .. '/bin/python'
	    end
	    local hit = vim.fs.find(
		function(name) return name == '.venv' or name == 'venv' or name == '.env' end,
		{ path = start, upward = true, type = 'directory', limit = 1 }
	    )[1]
	    if hit and vim.uv.fs_stat(hit .. '/bin/python') then
		return hit .. '/bin/python'
	    end
	    return nil
	end

	vim.lsp.config['basedpyright'] = {
	    cmd = { 'basedpyright-langserver', '--stdio' },
	    filetypes = { 'python' },
	    -- .venv listed as a marker: several projects have no other root file
	    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.venv', '.git' },
	    before_init = function(params, config)
		-- Careful: with no project root, rootUri is vim.NIL -- userdata,
		-- which is truthy in Lua -- so type-check rather than `and`.
		local root = config.root_dir
		if type(root) ~= 'string' or root == '' then
		    root = type(params.rootUri) == 'string'
			and vim.uri_to_fname(params.rootUri)
			or nil
		end
		local py = venv_python(root or vim.fn.expand('%:p:h'))
		if py then
		    config.settings = vim.tbl_deep_extend('force', config.settings or {},
			{ python = { pythonPath = py } })
		end
	    end,
	    settings = {
		basedpyright = {
		    analysis = {
			typeCheckingMode = 'standard', -- 'strict' is very noisy on untyped code
			diagnosticMode   = 'openFilesOnly',
			autoSearchPaths  = true,
			useLibraryCodeForTypes = true,
			-- ruff already reports these; without this you get every
			-- unused import/variable flagged twice.
			diagnosticSeverityOverrides = {
			    reportUnusedImport     = 'none',
			    reportUnusedVariable   = 'none',
			    reportUnusedExpression = 'none',
			},
		    },
		},
	    },
	}

	vim.lsp.config['ruff'] = {
	    cmd = { 'ruff', 'server' },
	    filetypes = { 'python' },
	    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
	}

	-- MATLAB. MathWorks' official server, built from source into
	-- ~/.local/share/matlab-language-server (there is no real npm package --
	-- `matlab-language-server` on npm is a 0.0.1 security placeholder).
	-- Rebuild after `git pull` there with: npm install && npm run package
	local matlab_ls = vim.fn.expand('~/.local/share/matlab-language-server/out/index.js')
	local matlab_app = '/Applications/MATLAB_R2025b.app'
	if vim.uv.fs_stat(matlab_ls) and vim.uv.fs_stat(matlab_app) then
	    vim.lsp.config['matlab_ls'] = {
		cmd = {
		    'node', matlab_ls, '--stdio',
		    '--matlabInstallPath=' .. matlab_app,
		    -- Must be onStart. Completion and MATLAB's code analysis need
		    -- a live MATLAB session; with onDemand it never connects and
		    -- you silently get zero completions (tested). The cost is that
		    -- opening any .m file launches MATLAB in the background and
		    -- takes a licence seat -- completions are empty for the first
		    -- ~60s while it starts, then work.
		    '--matlabConnectionTiming=onStart',
		    '--indexWorkspace=true',
		    -- -nodisplay disables MATLAB's Crash Reporter (MathWorks:
		    -- "The Crash Reporter is unavailable if you start MATLAB with
		    -- the -nodisplay option"), which otherwise pops a dialog every
		    -- time nvim exits and the session is torn down. This session
		    -- only does code analysis -- it never draws figures -- so
		    -- losing the display costs nothing here.
		    '--matlabLaunchCommandArgs=-nodisplay -nosplash',
		},
		filetypes = { 'matlab' },
		root_markers = { '.git', '*.prj' },
	    }
	    vim.lsp.enable('matlab_ls')

	    -- NOTE: quitting nvim with a .m file open pops MATLAB's crash
	    -- reporter. This is upstream behaviour, not fixable here: the
	    -- language server's shutdown() ends the session with
	    -- matlabProcess.kill('SIGTERM') and never sends MATLAB a clean exit,
	    -- so MATLAB records an abnormal termination. Tried and ruled out:
	    -- stopping the client early on VimLeavePre (server still SIGTERMs),
	    -- launching with -nodisplay, and MATLAB settings (no crashhandling
	    -- group exists). Click "Don't Send"; nothing is written.
	    -- Setting matlabConnectionTiming=never avoids it entirely, at the
	    -- cost of completions -- linting and highlighting still work.
	end

	-- LaTeX. texlab handles LSP duties only (completion, diagnostics, hover,
	-- references) -- build.onSave is deliberately off because vimtex (see
	-- plugins/latex.lua) owns compilation via continuous latexmk and does
	-- forward/inverse search with Skim itself. Running both would mean two
	-- separate systems compiling the same document.
	vim.lsp.config['texlab'] = {
	    cmd = { 'texlab' },
	    filetypes = { 'tex', 'plaintex', 'bib' },
	    root_markers = { '.latexmkrc', '.git' },
	    settings = {
		texlab = {
		    build = { onSave = false },
		    chktex = { onOpenAndSave = true, onEdit = false },
		},
	    },
	}

	-- Lua. This config's own language -- workspace.library points it at
	-- Neovim's own runtime (vim.*, the stdlib) so it doesn't flag every
	-- `vim.xyz` call as undefined.
	vim.lsp.config['lua_ls'] = {
	    cmd = { 'lua-language-server' },
	    filetypes = { 'lua' },
	    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
	    settings = {
		Lua = {
		    runtime = { version = 'LuaJIT' }, -- Neovim embeds LuaJIT, not stock Lua
		    diagnostics = { globals = { 'vim' } },
		    workspace = {
			library = vim.api.nvim_get_runtime_file('', true),
			checkThirdParty = false,
		    },
		    telemetry = { enable = false },
		},
	    },
	}

	-- Typst. tinymist is zero-config-friendly by design; live preview
	-- (typst-preview.nvim) lives in plugins/typst.lua rather than here,
	-- since it's not itself an LSP concern.
	vim.lsp.config['tinymist'] = {
	    cmd = { 'tinymist' },
	    filetypes = { 'typst' },
	    root_markers = { '.git' },
	}

	vim.lsp.enable({ 'basedpyright', 'ruff', 'texlab', 'lua_ls', 'tinymist' })

	---------------------------------------------------------------------
	-- per-buffer keymaps
	---------------------------------------------------------------------
	vim.api.nvim_create_autocmd('LspAttach', {
	    group = vim.api.nvim_create_augroup('my.lsp', {}),
	    callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local buf = args.buf

		-- Both servers attach to python. Let basedpyright own hover so
		-- K doesn't return ruff's (empty) response instead.
		if client and client.name == 'ruff' then
		    client.server_capabilities.hoverProvider = false
		end

		local map = function(lhs, rhs, desc)
		    vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
		end

		-- Neovim 0.11 already maps K, grn, gra, grr, gri by default;
		-- these fill the gaps.
		map('gd', vim.lsp.buf.definition, 'LSP goto definition')
		map('gD', vim.lsp.buf.declaration, 'LSP goto declaration')
		map('go', vim.lsp.buf.type_definition, 'LSP type definition')
		map('gl', vim.diagnostic.open_float, 'Show diagnostic')
		map('<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'LSP format')
	    end,
	})
    end
}
