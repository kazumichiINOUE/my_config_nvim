return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>nr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown rendering" },
  },
  opts = {
    -- カーソル行も元の記法に戻さず，レンダリングしたままにする
    anti_conceal = { enabled = false },
  },
}
