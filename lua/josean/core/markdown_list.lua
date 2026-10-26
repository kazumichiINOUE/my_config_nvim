-- Markdown の箇条書き（- ）とタスク（- [ ] ）で，insert mode の Enter が次の行にも同じ印を付ける．
-- 印だけで中身のない行で Enter を押すと，印を消して行頭へ戻る．ほかの行では今までどおりの Enter（autopairs）．
-- 補完の候補を選んでいるときの Enter は cmp が受け取り，選んでいなければこの割り当てに回ってくる

-- 行頭の印を調べる．返すのは，字下げ，次の行に付ける印，印の終わり（0 始まりのバイト），印のあとの中身
local function parse(line)
  local indent, mark, body = line:match("^(%s*)(%- %[[ xX]%]%s*)(.*)$")
  local next_mark = "- [ ] "
  if not indent or (body ~= "" and not mark:match("%s$")) then
    indent, mark, body = line:match("^(%s*)(%-%s+)(.*)$")
    next_mark = "- "
  end
  if not indent then
    return nil
  end
  return indent, next_mark, #indent + #mark, body
end

local function enter()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local indent, next_mark, mark_end, body = parse(line)

  -- 印のない行と，カーソルが印より前にあるときは，今までどおりの Enter
  if not indent or col < mark_end then
    local ok, autopairs = pcall(require, "nvim-autopairs")
    local keys = ok and autopairs.completion_confirm() or vim.keycode("<CR>")
    vim.api.nvim_feedkeys(keys, "ni", false)
    return
  end

  -- 中身がなければ，印を消して行頭へ
  if vim.trim(body) == "" then
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, #line, { "" })
    vim.api.nvim_win_set_cursor(0, { row, 0 })
    return
  end

  -- カーソルの位置で行を分け，次の行に同じ字下げで印を付ける（チェック済みの行からは - [ ] を続ける）
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "", indent .. next_mark })
  vim.api.nvim_win_set_cursor(0, { row + 1, #indent + #next_mark })
end

-- normal mode の o も，印のある行なら次の行に同じ印を付けて書き始める．
-- . や 3o で繰り返せるよう，キーで返す．字下げは autoindent に任せる
local function open_below()
  local indent, next_mark = parse(vim.api.nvim_get_current_line())
  return indent and "o" .. next_mark or "o"
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_list", { clear = true }),
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("i", "<CR>", enter, { buffer = args.buf, desc = "Continue Markdown list" })
    vim.keymap.set("n", "o", open_below, { buffer = args.buf, expr = true, desc = "Open Markdown list item below" })
  end,
})
