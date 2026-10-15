-- 研究ノート（~/notes）の #タグ を補完の候補に出す nvim-cmp のソース．
-- 候補は ~/notes の .md 全体から集め，最近使った順に並べる．「最近」は，デイリーならファイル名の日付，
-- ほかのノートなら最後に書き換えた時刻．効くのは ~/notes の Markdown だけ
local notes_dir = vim.fn.expand("~/notes")

-- 行頭か空白のあとの # で始まる語をタグとみなす．URL の # や [[note#見出し]] は拾わない
local rg_pattern = [[(^|\s)#[\p{L}\p{N}_][\p{L}\p{N}_-]*]]
local max_age = 30 -- 秒．これより古ければ，候補を出すときに裏で集め直す

local tags = {} -- 並べた候補（{ label, time, count }）
local collected_at, collecting = 0, false

local function file_time(path)
  local date = path:match("/daily/(%d%d%d%d%-%d%d%-%d%d)%.md$")
  if date then
    local y, m, d = date:match("^(%d+)-(%d+)-(%d+)$")
    return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
  end
  local stat = vim.uv.fs_stat(path)
  return stat and stat.mtime.sec or 0
end

-- rg の出力（「パス\0一致した文字」が1行ずつ）から，タグごとの最後に使った時刻と回数を数える
local function parse(out)
  local by_tag, times = {}, {}
  for line in out:gmatch("[^\n]+") do
    local path, hit = line:match("^(.-)%z(.*)$")
    local tag = hit and hit:match("(#.+)$")
    if tag then
      times[path] = times[path] or file_time(path)
      local t = by_tag[tag] or { label = tag, time = 0, count = 0 }
      t.time, t.count = math.max(t.time, times[path]), t.count + 1
      by_tag[tag] = t
    end
  end
  local list = vim.tbl_values(by_tag)
  table.sort(list, function(a, b)
    if a.time ~= b.time then
      return a.time > b.time
    end
    return a.count > b.count
  end)
  return list
end

local function collect(done)
  if collecting then
    return done()
  end
  collecting = true
  vim.system(
    { "rg", "-o", "--null", "--no-heading", "-N", "-g", "*.md", rg_pattern, notes_dir },
    { text = true },
    vim.schedule_wrap(function(res)
      collecting = false
      -- rg は一致がないと 1 で終わる．2 以上はエラーなので，前の候補を残す
      if res.code <= 1 then
        tags, collected_at = parse(res.stdout or ""), os.time()
      end
      done()
    end)
  )
end

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_debug_name()
  return "notes_tags"
end

function source:is_available()
  local name = vim.api.nvim_buf_get_name(0)
  return vim.bo.filetype == "markdown" and name:sub(1, #notes_dir + 1) == notes_dir .. "/"
end

-- # のあとに1文字打つと候補を出す（登録するときに keyword_length = 2）．"# 見出し" は # のすぐあとが空白なので出ない．
-- # だけでも当てはまるようにしておくのは，/tag から # だけの状態で一覧を開くため
function source:get_keyword_pattern()
  return [[#[^[:space:]#]*]]
end

function source:complete(params, callback)
  local before = params.context.cursor_before_line
  local s = before:match("()#[^%s#]*$")
  -- # の前は行頭か空白（全角の空白も）だけ．「テキスト#tag」は候補を出さない
  local prev = s and before:sub(1, s - 1)
  if not s or (prev ~= "" and not prev:match("%s$") and not prev:match("　$")) then
    return callback({ items = {}, isIncomplete = false })
  end
  local function respond()
    local items = {}
    for i, t in ipairs(tags) do
      items[i] = {
        label = t.label,
        sortText = string.format("%05d", i),
        labelDetails = { description = os.date("%m/%d", t.time) .. "・" .. t.count .. "回" },
      }
    end
    callback({ items = items, isIncomplete = false })
  end
  if os.time() - collected_at >= max_age then
    collect(respond)
  else
    respond()
  end
end

return source
