-- 研究ノート（~/notes）の / コマンドを出す nvim-cmp のソース．
-- 行頭か空白のあとで / を打つと一覧が出る．日付の 10/15 やパスの ~/notes のように，/ の前が文字なら出ない．
-- 効くのは ~/notes の Markdown だけ
local notes_dir = vim.fn.expand("~/notes")

local commands = {
  { label = "/tag", desc = "タグを入れる", cmd = "tag" },
  { label = "/H1", desc = "見出し1にする", cmd = "heading", level = 1 },
  { label = "/H2", desc = "見出し2にする", cmd = "heading", level = 2 },
  { label = "/H3", desc = "見出し3にする", cmd = "heading", level = 3 },
}

-- 行の見出しの印（# の並び）を level にそろえる．cursor は / コマンドを消したあとの位置（0始まりのバイト）．
-- 新しい行と，そこでのカーソルの位置を返す
local function to_heading(line, cursor, level, at_end)
  local old = line:match("^#*%s*")
  local body = line:sub(#old + 1)
  if at_end then
    body = body:gsub("%s+$", "") -- 行末で打ったなら，コマンドの前の空白は残さない
  end
  local mark = string.rep("#", level) .. " "
  local new = mark .. body
  local col = at_end and #new or #mark + math.max(cursor - #old, 0)
  return new, col
end

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_debug_name()
  return "notes_slash"
end

function source:is_available()
  local name = vim.api.nvim_buf_get_name(0)
  return vim.bo.filetype == "markdown" and name:sub(1, #notes_dir + 1) == notes_dir .. "/"
end

function source:get_trigger_characters()
  return { "/" }
end

function source:get_keyword_pattern()
  return "/[[:alnum:]]*"
end

function source:complete(params, callback)
  local before = params.context.cursor_before_line
  local s = before:match("()/%w*$")
  local prev = s and before:sub(1, s - 1)
  if not s or (prev ~= "" and not prev:match("%s$") and not prev:match("　$")) then
    return callback({ items = {}, isIncomplete = false })
  end
  local items = {}
  for i, c in ipairs(commands) do
    items[i] = {
      label = c.label,
      sortText = string.format("%02d", i),
      labelDetails = { description = c.desc },
      data = { cmd = c.cmd, level = c.level },
    }
  end
  callback({ items = items, isIncomplete = false })
end

-- 選んだあとに呼ばれる．入ったコマンドの文字（/tag など）を，その動きに置き換える
function source:execute(item, callback)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local s = col - #item.label
  if s < 0 or line:sub(s + 1, col) ~= item.label then
    return callback()
  end
  if item.data.cmd == "tag" then
    -- # に置き換えて，タグの一覧（notes_tags）を開く
    vim.api.nvim_buf_set_text(0, row - 1, s, row - 1, col, { "#" })
    vim.api.nvim_win_set_cursor(0, { row, s + 1 })
    callback()
    vim.schedule(function()
      require("cmp").complete({ config = { sources = { { name = "notes_tags" } } } })
    end)
    return
  end
  local rest = line:sub(1, s) .. line:sub(col + 1)
  local new, newcol = to_heading(rest, s, item.data.level, col == #line)
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new })
  vim.api.nvim_win_set_cursor(0, { row, newcol })
  callback()
end

source._to_heading = to_heading -- 試験のため

return source
