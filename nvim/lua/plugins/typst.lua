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
}
