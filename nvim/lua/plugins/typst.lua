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
    --
    -- spellfile is set explicitly because with two languages and an
    -- unset spellfile, zg always writes to the FIRST one -- so every
    -- Swedish word ended up in en.utf-8.add. With both listed, zg adds
    -- to English and 2zg adds to Swedish. Editing either .add by hand
    -- is fine; nvim recompiles the .add.spl next to it when it changes.
    --
    -- ORDER MATTERS, and getting it wrong is silent and destructive:
    -- spelllang must be set BEFORE spellfile. If spellfile is already
    -- set when spelllang is evaluated, Vim sees sv.utf-8.add listed,
    -- loads sv.utf-8.add.spl, counts 'sv' as satisfied and never
    -- searches runtimepath for the real sv.utf-8.spl -- so the whole
    -- Swedish dictionary is replaced by the handful of added words and
    -- every ordinary Swedish word reads as misspelled. Keep this
    -- buffer-local and in this order; :spellinfo lists what actually
    -- loaded if it ever looks wrong again.
    init = function()
        local spell_dir = vim.fn.stdpath('data') .. '/site/spell/'
        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'typst',
            callback = function()
                vim.opt_local.spell = true
                vim.opt_local.spelllang = { 'en', 'sv' }
                vim.opt_local.spellfile = {
                    spell_dir .. 'en.utf-8.add',
                    spell_dir .. 'sv.utf-8.add',
                }
            end,
        })
    end,
}
