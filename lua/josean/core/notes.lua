-- 研究ノート（~/notes）用の設定
local notes_dir = vim.fn.expand("~/notes")
local daily_dir = notes_dir .. "/daily"
local keymap = vim.keymap

-- デイリーノートの2行目に入れる，前後のノートへの移動リンク
local daily_nav = "[[prev|← 前のノート]] | [[next|次のノート →]]"

-- ファイルを開く．VS Code（VSCode Neovim）の中では，VS Codeのエディタで開く
local function open_file(path)
  if vim.g.vscode then
    vim.fn.VSCodeExtensionNotify("open-file", path, 0)
  else
    vim.cmd.edit(vim.fn.fnameescape(path))
  end
end

-- "YYYY-MM-DD" を days 日ずらした日付を返す
local function shift_date(date, days)
  local y, m, d = date:match("^(%d+)-(%d+)-(%d+)$")
  local t = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d) + days, hour = 12 })
  return os.date("%Y-%m-%d", t)
end

-- 指定した日（省略時は今日）のデイリーノートを開く．なければテンプレートで作る
local function open_daily(date)
  date = date or os.date("%Y-%m-%d")
  local path = daily_dir .. "/" .. date .. ".md"
  vim.fn.mkdir(daily_dir, "p")
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({ "# " .. date, daily_nav, "" }, path)
  end
  open_file(path)
end

-- 今開いているバッファがデイリーノートなら，その日付を返す
local function current_daily_date()
  local date = vim.fn.expand("%:t:r")
  if vim.fn.expand("%:p:h") == daily_dir and date:match("^%d%d%d%d%-%d%d%-%d%d$") then
    return date
  end
end

-- 入力を "YYYY-MM-DD" にする．"2026-10-10"，"10-10"（今年），"+1"/"-2"（base から）が使える
local function parse_date(input, base)
  input = vim.trim(input)
  local sign, days = input:match("^([+-])(%d+)$")
  if sign then
    return shift_date(base, (sign == "-" and -1 or 1) * tonumber(days))
  end
  local y, m, d = input:match("^(%d%d%d%d)-(%d%d?)-(%d%d?)$")
  if not y then
    y = os.date("%Y")
    m, d = input:match("^(%d%d?)[-/](%d%d?)$")
  end
  if not m then
    return nil
  end
  local date = string.format("%s-%02d-%02d", y, tonumber(m), tonumber(d))
  -- 2026-02-30 のような存在しない日付は，os.time で別の日付に化けるので弾く
  if shift_date(date, 0) ~= date then
    return nil
  end
  return date
end

-- 日付を聞いて，その日のデイリーノートを開く．+1/-1 の起点は開いているデイリーノート（なければ今日）
local function prompt_daily()
  local base = current_daily_date() or os.date("%Y-%m-%d")
  vim.ui.input({ prompt = "日付（基準 " .. base .. "）: " }, function(input)
    if not input or vim.trim(input) == "" then
      return
    end
    local date = parse_date(input, base)
    if not date then
      vim.notify("日付として読めない: " .. input, vim.log.levels.WARN)
      return
    end
    open_daily(date)
  end)
end

-- current より前（step = -1）か後（step = 1）にある，いちばん近いデイリーノートの日付を返す
local function neighbor_daily(current, step)
  local dates = {}
  for name, kind in vim.fs.dir(daily_dir) do
    local date = name:match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")
    if kind == "file" and date then
      table.insert(dates, date)
    end
  end
  table.sort(dates)
  local found
  for _, date in ipairs(dates) do
    if step < 0 and date < current then
      found = date
    elseif step > 0 and date > current then
      return date
    end
  end
  return found
end

-- [[prev]] と [[next]]：実際にある前後のデイリーノートへ移る．端なら隣の日付で作るか聞く
local function follow_daily_nav(target)
  local current = current_daily_date()
  if not current then
    vim.notify("前後移動はデイリーノートの中でだけ使える", vim.log.levels.WARN)
    return
  end
  local step = target == "prev" and -1 or 1
  local date = neighbor_daily(current, step)
  if date then
    open_file(daily_dir .. "/" .. date .. ".md")
    return
  end
  local adjacent = shift_date(current, step)
  if vim.fn.confirm(adjacent .. " のノートを作る？", "&Yes\n&No", 2) == 1 then
    open_daily(adjacent)
  end
end

-- [[ノート名]] から開くファイルのパスを決める
local function resolve_link(name)
  name = name:gsub("|.*$", ""):gsub("#.*$", "")
  name = vim.trim(name)
  if name == "" then
    return nil
  end
  -- "daily/2026-10-07" のようにパス付きなら ~/notes からの相対パスとして扱う
  if name:find("/") then
    return notes_dir .. "/" .. name .. ".md"
  end
  local found = vim.fs.find(name .. ".md", { path = notes_dir, type = "file", limit = 1 })
  return found[1] or (notes_dir .. "/" .. name .. ".md")
end

-- カーソル下の [[ノート名]] を返す（なければ nil）
local function link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local start = 1
  while true do
    local s, e, name = line:find("%[%[(.-)%]%]", start)
    if not s then
      return nil
    end
    if col >= s and col <= e then
      return name
    end
    start = e + 1
  end
end

local function follow_link()
  local name = link_under_cursor()
  local target = name and vim.trim((name:gsub("|.*$", "")))
  if target == "prev" or target == "next" then
    follow_daily_nav(target)
    return
  end
  local path = name and resolve_link(name)
  if not path then
    -- リンク上でなければ通常の <CR> として動かす
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
    return
  end
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  open_file(path)
end

keymap.set("n", "<leader>nd", function()
  open_daily()
end, { desc = "Open today's daily note" })
keymap.set("n", "<leader>nD", prompt_daily, { desc = "Open daily note for a date" })
keymap.set("n", "<leader>np", function()
  follow_daily_nav("prev")
end, { desc = "Previous daily note" })
keymap.set("n", "<leader>nn", function()
  follow_daily_nav("next")
end, { desc = "Next daily note" })
keymap.set("n", "<leader>nf", function()
  require("telescope.builtin").find_files({ cwd = notes_dir })
end, { desc = "Find files in notes" })
keymap.set("n", "<leader>ns", function()
  require("telescope.builtin").live_grep({ cwd = notes_dir })
end, { desc = "Find string in notes" })

-- ~/notes 内の Markdown でだけ <CR> をリンクジャンプにする
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = notes_dir .. "/*.md",
  callback = function(args)
    keymap.set("n", "<CR>", follow_link, { buffer = args.buf, desc = "Follow [[link]]" })
  end,
})
