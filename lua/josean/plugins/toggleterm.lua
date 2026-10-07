-- vim global is provided by Neovim
---@diagnostic disable: undefined-global

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      direction = 'float',
      size = 20, -- 水平・垂直分割時のサイズ（行数・列数）
      shade_terminals = false, -- 背景を暗くする
      shading_factor = 0.8, -- 暗くする度合い（0-1、小さいほど暗い）
      float_opts = {
        border = 'curved',
        width = 100, -- フローティング時の幅（文字数）
        height = 60, -- フローティング時の高さ（行数）
        winblend = 10, -- 背景の透明度（0-100、大きいほど透明）
      },
    })
    
    -- 衝突しないキーマップ
    vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", { desc = "Float Terminal" })
    vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Horizontal Terminal" })
    vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Vertical Terminal" })
    
    -- ターミナルモードでのキーマップ
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
    vim.keymap.set("t", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })
    
  end,
}
