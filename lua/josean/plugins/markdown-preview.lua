return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  -- yarn は入れていないので npx 経由で一時的に使う
  build = "cd app && npx --yes yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    -- 辞書ごと置き換わるので，既定値も含めて全項目を書く．
    -- sync_scroll_type = "relative"：nvimの画面でカーソル行がある高さと，
    -- プレビューでその行が表示される高さを揃える（既定の "middle" は常に中央）．
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = "relative",
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {},
    }
  end,
  keys = {
    { "<leader>nv", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle markdown preview (browser)" },
  },
}
