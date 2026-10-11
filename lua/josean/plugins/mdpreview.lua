return {
  -- ~/src/mdpreview：WezTerm のウィンドウに重ねて出すプレビュー（試作中）
  dir = "~/src/mdpreview",
  name = "mdpreview",
  -- ~/src/mdpreview がない Mac では読まない
  cond = vim.fn.isdirectory(vim.fn.expand("~/src/mdpreview")) == 1,
  keys = {
    -- Cmd+e：WezTerm が CSI u の Super+e として送ってくる
    {
      "<D-e>",
      function()
        require("mdpreview").show()
      end,
      mode = { "n", "i" },
      desc = "Show markdown preview (mdpreview)",
    },
  },
}
