require("josean.core.options")
require("josean.core.keymaps")
require("josean.core.notes")
require("josean.core.notes_done")
require("josean.core.notes_taskid")
require("josean.core.markdown_list")
require("josean.core.karabiner_mode")

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

-- insert mode を抜けたら（Esc，Ctrl+[，jk），入力を ABC（半角英数）に戻す．
-- TIS を直接呼ぶ JXA なので，アクセシビリティの許可は要らない（WezTerm のペイン移動と同じ方法）
if vim.fn.has("mac") == 1 then
  local ime_off = [[
ObjC.import("Carbon");
const filter = $.NSDictionary.dictionaryWithObjectForKey(
  "com.apple.keylayout.ABC", ObjC.castRefToObject($.kTISPropertyInputSourceID));
const list = ObjC.castRefToObject($.TISCreateInputSourceList(filter, false));
if (list.count > 0) $.TISSelectInputSource(list.objectAtIndex(0));
]]
  local function select_abc()
    vim.system({ "/usr/bin/osascript", "-l", "JavaScript", "-e", ime_off })
  end
  vim.api.nvim_create_autocmd("InsertLeave", { callback = select_abc })
  -- ほかのアプリやペインから戻ったときも ABC に戻す．入力ソースは Mac 全体で1つなので，よそで日本語にしたまま戻りうる．
  -- 日本語を打つモード（insert，replace，コマンドライン，ターミナル）のときは触らない
  vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
      if not vim.fn.mode():find("^[iRct]") then
        select_abc()
      end
    end,
  })
end

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

