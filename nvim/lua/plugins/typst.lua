-- Typst: live preview, to give it a fair comparison against the LaTeX setup
-- in plugins/latex.lua (continuous latexmk + Skim/Zathura sync). tinymist
-- (the LSP: completion, diagnostics, hover) lives in lsp.lua alongside the
-- other language servers, since it's just another server, not a Typst-
-- specific concern.
return {
    'chomosuke/typst-preview.nvim',
    commit = '1c2e19486397be1c580b560fc50ee36abe329c46', -- v1.5.0, pinned as with the other plugins
    ft = 'typst',
    -- Downloads its own preview-server/websocket binaries on first use
    -- (into stdpath('data')/typst-preview/) -- only real dependency is curl.
    opts = {},
    -- init (not config) so this registers at startup regardless of when
    -- the plugin itself lazy-loads -- it's unrelated to typst-preview,
    -- just colocated here since this is the Typst-specific file.
    -- Neovim's built-in spellchecker, no plugin needed. English ships
    -- with Neovim; Swedish (sv.utf-8.spl/.sug) was fetched from the
    -- official Vim spell files mirror into
    -- ~/.local/share/nvim/site/spell/ since it isn't bundled. Both
    -- languages checked at once -- a word only gets flagged if it
    -- matches neither.
    init = function()
        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'typst',
            callback = function()
                vim.opt_local.spell = true
                vim.opt_local.spelllang = { 'en', 'sv' }
            end,
        })
    end,
}
