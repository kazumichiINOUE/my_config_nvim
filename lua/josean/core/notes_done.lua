-- 研究ノート（~/notes）の Markdown で，チェック済み（- [x]）の行を薄く表示する．
-- 描画のたびにその場で色を当てる（extmark を残さない）ので，/todo や tutti で届いた変更にもそのまま効く
local notes_dir = vim.fn.expand("~/notes")
local ns = vim.api.nvim_create_namespace("notes_done")

-- 色は tokyonight の terminal_black（#414868）と comment（#565f89）の真ん中．
-- colorscheme を読み直すと消えるので，そのたびに作り直す
local function set_hl()
  vim.api.nvim_set_hl(0, "NotesDone", { fg = "#4c5478", default = true })
end
set_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("notes_done", { clear = true }),
  callback = set_hl,
})

local function in_notes(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return vim.bo[buf].filetype == "markdown" and name:sub(1, #notes_dir + 1) == notes_dir .. "/"
end

vim.api.nvim_set_decoration_provider(ns, {
  on_win = function(_, _, buf)
    return in_notes(buf)
  end,
  on_line = function(_, _, buf, row)
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
    local s = line and line:match("^%s*()[-*+]%s+%[[xX]%]")
    if s then
      vim.api.nvim_buf_set_extmark(buf, ns, row, s - 1, {
        end_col = #line,
        hl_group = "NotesDone",
        priority = vim.hl.priorities.user, -- treesitter の色（見出し，タグ，リンク）より上に
        ephemeral = true,
      })
    end
  end,
})
