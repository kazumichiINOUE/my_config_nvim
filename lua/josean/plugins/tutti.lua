return {
  -- ~/src/tutti：~/notes の .md を，ほかの nvim や Claude Code と同時に編集する（試作中）
  -- tuttid が動いていなければ立ち上げる．保存は tuttid がするので :w は要らない
  dir = "~/src/tutti/nvim",
  name = "tutti",
  -- ~/src/tutti がない Mac では読まない
  cond = vim.fn.isdirectory(vim.fn.expand("~/src/tutti")) == 1,
  lazy = false,
  config = function()
    require("tutti").setup({
      root = "~/notes",
      -- cd ~/src/tutti/daemon && cargo build --release で作る
      daemon = "~/src/tutti/daemon/target/release/tuttid",
    })
  end,
}
