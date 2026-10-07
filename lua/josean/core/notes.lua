-- 研究ノート（~/notes）用の設定
local notes_dir = vim.fn.expand("~/notes")
local keymap = vim.keymap

-- 今日のデイリーノートを開く（なければ見出し付きで作る）
local function open_daily()
  local date = os.date("%Y-%m-%d")
  local path = notes_dir .. "/daily/" .. date .. ".md"
  vim.fn.mkdir(notes_dir .. "/daily", "p")
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({ "# " .. date, "" }, path)
  end
  vim.cmd.edit(vim.fn.fnameescape(path))
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
  local path = name and resolve_link(name)
  if not path then
    -- リンク上でなければ通常の <CR> として動かす
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
    return
  end
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.cmd.edit(vim.fn.fnameescape(path))
end

keymap.set("n", "<leader>nd", open_daily, { desc = "Open today's daily note" })
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
