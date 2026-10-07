require("josean.core.options")
require("josean.core.keymaps")
require("josean.core.notes")

-- ファイルを開いたときに前回の編集位置に移動する
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line = mark[1]
        local col = mark[2]
        -- 前回の位置が有効ならそこに移動する
        if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, {line, col})
        end
    end,
})

vim.opt.rtp:append("/opt/homebrew/opt/fzf")

vim.keymap.set('n', 'gx', function()
  local file = vim.fn.expand('<cfile>')
  vim.cmd('edit ' .. file)
end, { noremap = true, silent = true })

vim.api.nvim_create_user_command('Ev', function()
 require('nvim-tree.api').tree.close()
 require('nvim-tree.api').tree.change_root('/Users/kaz/.config/nvim')
 require('nvim-tree.api').tree.open()
end, {})

return {
  "github/copilot.vim",
  lazy=false,
}

