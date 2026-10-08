return {
  "stevearc/dressing.nvim",
  -- VS Codeの中では読まない．入力欄が見えない浮き窓になり，VS Codeの入力欄を上書きしてしまうため
  cond = not vim.g.vscode,
  event = "VeryLazy",
}
