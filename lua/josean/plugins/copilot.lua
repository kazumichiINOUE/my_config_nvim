return {
  "github/copilot.vim",
  lazy = false, -- プラグインを常にロード
  config = function()
    -- TAB キーを無効化（デフォルトの補完を防ぐ）
    vim.g.copilot_no_tab_map = true
    -- Copilot の提案トリガーをカスタマイズ（無効化）
    vim.g.copilot_enabled = false

    -- 手動トリガーの設定
    vim.api.nvim_set_keymap(
      "i",                          -- 挿入モード
      "<C-E>",                      -- 手動トリガーのキー（Ctrl+E）
      'copilot#Accept("<CR>")',     -- Copilot の提案を受け入れる
      { silent = true, expr = true }
    )

    -- 必要に応じて他のキー設定を追加
    vim.cmd([[
      imap <silent><script><expr> <C-J> copilot#Accept("")
      let g:copilot_assume_mapped = v:true
    ]])
  end,
}

