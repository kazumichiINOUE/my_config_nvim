-- 研究ノート（~/notes）でタスクの行を取ると（yy，dd など），ほかのアプリへは印を外した文だけを渡す（kaz の選択，2026-10-28）．
-- 外すのは，行頭の字下げと「- [ ] 」「- [x] 」，済みの時刻（「15:37 」「10/27 15:37 」），行末の ID（「 ^a1b2」）．
-- nvim の中で貼るときは印つきのまま（yyp でタスクを複製できる）．そのために，nvim と macOS のクリップボードの橋渡し（g:clipboard）を差し替える：
-- macOS のクリップボードがまだ自分の渡した文のままなら，覚えておいた元の行を返す．ほかのアプリでコピーしたあとは，その中身を返す．
-- タスクの行がなければ，今までの橋渡し（pbcopy，pbpaste）と同じ中身を渡す．unnamedplus はそのまま
if vim.fn.has("mac") == 0 then
  return
end

local notes_dir = vim.fn.expand("~/notes")
-- 印を外して渡したときの { sent = 渡した文, lines = 元の行, regtype = 元の形 }
local last

local function in_notes()
  local name = vim.api.nvim_buf_get_name(0)
  return vim.bo.filetype == "markdown" and name:sub(1, #notes_dir + 1) == notes_dir .. "/"
end

-- タスクの行なら印を外した文．そうでなければ nil．済みの時刻は済みの行だけで外す（未了の「9:30 打ち合わせ」は残す）
local function strip(line)
  local mark, body = line:match("^%s*[-*+]%s+%[([ xX])%]%s?(.*)$")
  if not body then
    return nil
  end
  if mark ~= " " then
    body = body:gsub("^%d%d?/%d%d? %d%d?:%d%d ", "", 1)
    body = body:gsub("^%d%d?:%d%d ", "", 1)
  end
  return (body:gsub("%s%^[%w%-]+%s*$", ""))
end

local function copy(lines, regtype)
  local out, changed = {}, false
  if in_notes() then
    for i, line in ipairs(lines) do
      local s = strip(line)
      out[i] = s or line
      changed = changed or s ~= nil
    end
  end
  -- 行として取ると，lines の最後に空の行が付いてくる（渡すと最後の改行になる）
  local text
  if changed then
    -- 最後の改行は渡さない．チャットなどに貼ったときに，余計な改行が入らないように
    if out[#out] == "" then
      out[#out] = nil
    end
    text = table.concat(out, "\n")
    last = { sent = text, lines = lines, regtype = regtype }
  else
    -- 今までの橋渡しと同じ形
    text = table.concat(lines, "\n")
    last = nil
  end
  vim.system({ "pbcopy" }, { stdin = text }):wait()
end

local function paste()
  local text = vim.system({ "pbpaste" }, { text = true }):wait().stdout or ""
  if last and text == last.sent then
    return { last.lines, last.regtype }
  end
  return vim.split(text, "\n", { plain = true })
end

vim.g.clipboard = {
  name = "notes-tasks",
  copy = { ["+"] = copy, ["*"] = copy },
  paste = { ["+"] = paste, ["*"] = paste },
  cache_enabled = 0,
}
