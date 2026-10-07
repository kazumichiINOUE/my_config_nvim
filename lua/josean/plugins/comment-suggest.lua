-- 設定オプション
local config = {
  auto_hiragana = true  -- 検索開始時に自動でひらがな入力に切り替える
}

local function comment_suggest(opts)
  opts = opts or {}

  -- 現在のバッファがcomment.mdかチェック
  local current_file = vim.fn.expand("%:t")
  if current_file ~= "comment.md" then
    vim.notify("この機能はcomment.mdでのみ利用できます", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- comment.mdの全行を取得
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- 空行，ヘッダーを除外し，出現回数をカウント
  local text_counts = {}
  local first_occurrence = {}
  for i, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed ~= "" and
       not trimmed:match("^##") and
       not trimmed:match("^%-%-") then
      if text_counts[trimmed] then
        text_counts[trimmed] = text_counts[trimmed] + 1
      else
        text_counts[trimmed] = 1
        first_occurrence[trimmed] = i
      end
    end
  end

  -- 出現回数順でソートして候補を作成
  local suggestions = {}
  for text, count in pairs(text_counts) do
    table.insert(suggestions, {
      text = text,
      line_number = first_occurrence[text],
      count = count
    })
  end
  
  -- 出現回数の昇順でソート（使用頻度の高いものを下部に表示）
  table.sort(suggestions, function(a, b)
    if a.count == b.count then
      return a.line_number > b.line_number
    end
    return a.count < b.count
  end)

  local picker = pickers.new(opts, {
    prompt_title = "Comment Suggestions",
    finder = finders.new_table({
      results = suggestions,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("(%dx) [%d] %s", entry.count, entry.line_number, entry.text),
          ordinal = entry.text,
        }
      end,
    }),
    sorter = require("telescope.config").values.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, {selection.value.text})
          vim.api.nvim_win_set_cursor(0, {row, col + #selection.value.text})
          
          -- コマンドモードに移行し，英数入力に切り替え
          vim.defer_fn(function()
            vim.cmd("stopinsert")  -- インサートモードを終了
            vim.cmd("call system('osascript -e \"tell application \\\"System Events\\\" to key code 102\"')")  -- 英数キー
          end, 10)
        end
      end)
      
      -- Escapeキーでも英数入力に切り替え
      map("i", "<Esc>", function()
        actions.close(prompt_bufnr)
        vim.cmd("call system('osascript -e \"tell application \\\"System Events\\\" to key code 102\"')")
      end)
      
      return true
    end,
  })
  
  -- 検索開始時にひらがな入力に切り替え（オプション）
  if config.auto_hiragana then
    vim.defer_fn(function()
      vim.cmd("call system('osascript -e \"tell application \\\"System Events\\\" to key code 104\"')")  -- かなキー
    end, 50)
  end
  
  picker:find()
end

-- コマンドとキーマップを設定
vim.api.nvim_create_user_command("CommentSuggest", comment_suggest, {})
vim.keymap.set("n", "<leader>cs", comment_suggest, { desc = "Comment suggestions from current file" })
vim.keymap.set("i", "<C-g>", comment_suggest, { desc = "Comment suggestions from current file" })

return {}
