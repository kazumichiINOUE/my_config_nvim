-- 研究ノート（~/notes）で，タスクの行を書いて insert mode を抜けたら，行末に短い ID（「 ^a3f9」）を付ける．
-- 同じ ID の行どうしは，tutti の中継が済み／未了を揃える（tutti の docs/twins.md）．あとでプロジェクトのノートへ写すとき，ID ごと写せば結ばれる．
-- 付けるのは，insert mode で書き換えた未了のタスク（- [ ]）で，文があり，まだ ID のない行だけ（kaz の決め，2026-10-27）．
-- ID のうしろに書き足して ID が行末から外れた行は，新しく付けずに ID を行末へ戻す（結びを切らないため）
local notes_dir = vim.fn.expand("~/notes")
local CHARS = "0123456789abcdefghijklmnopqrstuvwxyz"

local function in_notes(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return vim.bo[buf].filetype == "markdown" and name:sub(1, #notes_dir + 1) == notes_dir .. "/"
end

-- ~/notes のどのノートでも使っていない4文字の ID．taken は，この回にもう付けた ID
local function new_id(taken)
  for _ = 1, 50 do
    local bytes = vim.uv.random(4)
    local id = bytes:gsub(".", function(c)
      local k = c:byte() % #CHARS + 1
      return CHARS:sub(k, k)
    end)
    if not taken[id] then
      vim.fn.system({ "grep", "-rqE", "--include=*.md", "\\^" .. id .. "([^0-9A-Za-z-]|$)", notes_dir })
      if vim.v.shell_error ~= 0 then
        return id
      end
    end
  end
end

local entered -- insert mode に入ったときの変更の回数（changedtick）と行番号

local function add_ids()
  local e = entered
  entered = nil
  if not e or vim.b.changedtick == e.tick or not in_notes(0) then
    return
  end
  -- 書き換えた範囲：入った行，最後に書いた範囲（'[ と ']），カーソルの行
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local first, last = math.min(e.lnum, cur), math.max(e.lnum, cur)
  local s, f = vim.api.nvim_buf_get_mark(0, "[")[1], vim.api.nvim_buf_get_mark(0, "]")[1]
  if s > 0 and f > 0 then
    first, last = math.min(first, s), math.max(last, f)
  end
  local count = vim.api.nvim_buf_line_count(0)
  last = math.min(last, count, first + 200)
  local taken = {}
  for lnum = first, last do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    local function append(id)
      -- insert mode で書いた分と一緒に，1回の u で戻るようにする
      pcall(vim.cmd.undojoin)
      vim.api.nvim_buf_set_text(0, lnum - 1, #line, lnum - 1, #line, { (line:match("%s$") and "" or " ") .. "^" .. id })
    end
    if line:match("^%s*%- %[[ xX]%]") and not line:match("%s%^[%w%-]+%s*$") then
      -- ID のうしろに書き足した行（A で書くとそうなる）は，ID を行末へ戻す．先に行末へ足してから途中を消す（位置がずれないように）
      local s, e, id = line:find("%s%^([%w%-][%w%-][%w%-]+)%s")
      if s then
        append(id)
        pcall(vim.cmd.undojoin)
        vim.api.nvim_buf_set_text(0, lnum - 1, s - 1, lnum - 1, e - 1, { "" })
      elseif line:match("^%s*%- %[ %]%s*%S") then
        local new = new_id(taken)
        if not new then
          return
        end
        taken[new] = true
        append(new)
      end
    end
  end
end

local group = vim.api.nvim_create_augroup("notes_taskid", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  pattern = "*.md",
  callback = function()
    entered = { tick = vim.b.changedtick, lnum = vim.api.nvim_win_get_cursor(0)[1] }
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = group,
  pattern = "*.md",
  callback = add_ids,
})
