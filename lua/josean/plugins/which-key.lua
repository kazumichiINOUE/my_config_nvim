return {
  -- <leader>を押したときに，keymapのヒントを表示するプラグイン
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {

  },
}
