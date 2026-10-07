vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- 折り返し行での視覚的な移動を有効化
keymap.set('n', 'j', 'gj', { noremap = true, silent = true })
keymap.set('n', 'k', 'gk', { noremap = true, silent = true })
keymap.set('v', 'j', 'gj', { noremap = true, silent = true })
keymap.set('v', 'k', 'gk', { noremap = true, silent = true })

--keymap.set("i", "<C-b>", "<BS>", { desc = "Delete charactor in Japanese input mode"})
vim.api.nvim_set_keymap("i", "<C-b>", "<BS>", { noremap = true, silent = true, desc = "Delete character in Japanese input mode" })

-- Swap ; and :
keymap.set("n", ";", ":", { desc = "Use ; as :" })
keymap.set("n", ":", ";", { desc = "Use : as ;" })

-- Insert current datetime in ISO format
keymap.set('i', '<C-d>', function()
  return os.date('%Y-%m-%dT%H:%M')
end, { expr = true, desc = "Insert current datetime" })

-- Literate Programming mode toggle
-- local literate_mode = false
-- 
-- local function toggle_literate_mode()
--   if literate_mode then
--     -- カーソル位置とスクロール位置を保存
--     local cursor_pos = vim.fn.getcurpos()
--     local view = vim.fn.winsaveview()
--     -- 通常モード：元のカラースキームに戻す  
--     vim.cmd("TSEnable highlight")
--     vim.cmd([[
--       syntax reset
--       syntax on
--       highlight clear
--       colorscheme tokyonight
--     ]])
--     literate_mode = false
--     vim.cmd("edit")
--     -- カーソル位置とスクロール位置を復元
--     vim.fn.setpos('.', cursor_pos)
--     vim.fn.winrestview(view)
--     print("Code Mode")
--   else
--     -- カーソル位置とスクロール位置を保存
--     local cursor_pos = vim.fn.getcurpos()
--     local view = vim.fn.winsaveview()
--     -- Literateモード：ステータスバーを保持してからリセット
--     local statusline_bg = vim.fn.synIDattr(vim.fn.hlID("StatusLine"), "bg")
--     local statusline_fg = vim.fn.synIDattr(vim.fn.hlID("StatusLine"), "fg")
--     
--     -- Tree-sitterを一時無効化
--     vim.cmd("TSDisable highlight")
--     
--     vim.cmd([[
--       syntax reset
--       syntax on
--       set syntax=rust
--       highlight clear
--       highlight Normal guifg=#44475a guibg=#011628
--       highlight Comment guifg=#CBE0F0 guibg=#011628 gui=bold
--       
--       " コメント内Markdown要素の定義（階層別見出し）
--       syntax match CommentHeader1 /^\s*\(\*\s*\)\?#[^#].*$/ contained
--       syntax match CommentHeader2 /^\s*\(\*\s*\)\?##[^#].*$/ contained
--       syntax match CommentHeader3 /^\s*\(\*\s*\)\?###[^#].*$/ contained
--       syntax match CommentHeader4 /^\s*\(\*\s*\)\?####.*$/ contained
--       syntax match CommentBold /\*\*[^*]\+\*\*/ contained  
--       syntax match CommentItalic /\*[^*\s][^*]*\*/ contained
--       syntax match CommentList /^\s*\(\*\s*\)\?[-*+]\s\+.*$/ contained
--       
--       " Markdownコードブロック（Rust専用シンタックス）
--       syntax match CommentCodeInline /`[^`]\+`/ contained
--       syntax region CommentCodeBlock start=/```/ end=/```/ contained
--       
--       " Rustコードブロック専用（手動定義）
--       syntax region CommentCodeRust start=/```rust/ end=/```/ contained contains=RustCodeKeyword,RustCodeFunction,RustCodeType,RustCodeString
--       syntax match RustCodeKeyword /\(fn\|let\|mut\|Result\|Ok\|Err\|Box\|dyn\)/ contained
--       syntax match RustCodeFunction /\w\+\ze(/ contained
--       syntax match RustCodeType /\<\u\w*/ contained
--       syntax region RustCodeString start=/"/ end=/"/ contained
--       
--       " Algorithmブロック専用（疑似コード）
--       syntax region CommentCodeAlgorithm start=/```algorithm/ end=/```/ contained contains=AlgoKeyword,AlgoNumber,AlgoProcedure,AlgoOperator
--       syntax match AlgoKeyword /\(procedure\|while\|do\|case\|of\|end\|Algorithm\|Input\|Output\)/ contained
--       syntax match AlgoNumber /^\s*\d\+:/ contained
--       syntax match AlgoProcedure /\<\u\w*\>/ contained
--       syntax match AlgoOperator /\(<-\|!=\|≠\|←\)/ contained
--       
--       " コメント領域を再定義（ブロックコメントのみLiterate対応）
--       syntax region rustComment start="/\*lt" end="\*/" contains=CommentHeader1,CommentHeader2,CommentHeader3,CommentHeader4,CommentBold,CommentItalic,CommentCodeInline,CommentCodeRust,CommentCodeAlgorithm,CommentCodeBlock,CommentList,CommentListWithCode
--       " 通常のブロックコメントは普通のコード扱い
--       syntax region rustNormalComment start="/\*\(\(lt\)\@!\)" end="\*/"
--       " 行コメントは通常のコード扱い（Literateハイライト除外）
--       syntax match rustLineComment "//.*$"
--       
--       " 箇条書き行の再定義（インラインコード対応）
--       syntax match CommentListWithCode /^\s*\(\*\s*\)\?[-*+]\s\+.*`[^`]\+`.*$/ contained contains=CommentCodeInline
-- 
--       " コメント区切り文字の定義
--       syntax match CommentDelimiter "/\*lt" contained
--       syntax match CommentDelimiter "\*/" contained
--       
--       " 基本のコメントハイライトを設定
--       highlight! link rustComment Comment
--       " 通常のブロックコメントは普通のコード色（グレー）
--       highlight rustNormalComment guifg=#44475a gui=italic
--       " 行コメントは通常のコード色（グレー）
--       highlight rustLineComment guifg=#44475a gui=italic
--       " コメント区切り文字をグレーに
--       highlight! CommentDelimiter guifg=#44475a gui=italic
--       
--       " Markdown要素の色設定（階層別見出し）
--       highlight CommentHeader1 guifg=#ff79c6 guibg=#011628 gui=bold
--       highlight CommentHeader2 guifg=#f7768e guibg=#011628 gui=bold
--       highlight CommentHeader3 guifg=#e0af68 guibg=#011628 gui=bold
--       highlight CommentHeader4 guifg=#9ece6a guibg=#011628
--       highlight CommentBold guifg=#f8f8f2 guibg=#011628 gui=bold
--       highlight CommentItalic guifg=#f8f8f2 guibg=#011628 gui=italic
--       " インラインコードとコードブロックの色設定
--       highlight CommentCodeInline guifg=#50fa7b guibg=#44475a gui=bold
--       highlight CommentCodeBlock guifg=#50fa7b guibg=#2d3748 gui=bold
--       highlight CommentCodeRust guifg=#c0caf5 guibg=#1a1b26
--       
--       " Rustコードブロック内のシンタックス色（Tokyo Night準拠）
--       highlight RustCodeKeyword guifg=#bb9af7 gui=bold
--       highlight RustCodeFunction guifg=#7aa2f7 gui=bold  
--       highlight RustCodeType guifg=#e0af68 gui=bold
--       highlight RustCodeString guifg=#9ece6a
--       highlight RustCodeComment guifg=#565f89
--       
--       " Algorithmブロック内のシンタックス色
--       highlight CommentCodeAlgorithm guifg=#c0caf5 guibg=#1a1b26
--       highlight AlgoKeyword guifg=#f7768e gui=bold
--       highlight AlgoNumber guifg=#ff9e64 gui=bold
--       highlight AlgoProcedure guifg=#7aa2f7 gui=bold
--       highlight AlgoOperator guifg=#bb9af7 gui=bold
--       highlight CommentList guifg=#8be9fd guibg=#011628
--       highlight! link CommentListWithCode CommentList
--       
--       highlight! link Identifier Normal
--       highlight! link Statement Normal
--       highlight! link Type Normal
--       highlight! link Special Normal
--       highlight! link PreProc Normal
--       highlight! link Constant Normal
--       highlight! link Function Normal
--       highlight! link Keyword Normal
--       highlight! link String Normal
--       highlight! link Number Normal
--       highlight! link Boolean Normal
--       highlight! link Operator Normal
--       highlight! link Delimiter Normal
--       highlight! link Variable Normal
--       highlight! link @variable Normal
--       highlight! link @variable.builtin Normal
--       highlight! link @parameter Normal
--       highlight! link @field Normal
--       highlight! link @property Normal
--     ]])
--     
--     -- 保存した色でステータスラインを復元
--     vim.cmd(string.format("highlight StatusLine guifg=%s guibg=%s", statusline_fg, statusline_bg))
--     -- カーソル位置とスクロール位置を復元
--     vim.fn.setpos('.', cursor_pos)
--     vim.fn.winrestview(view)
--     print("Literate Mode")
--     literate_mode = true
--   end
-- end
-- 
-- keymap.set("n", "<leader>lt", toggle_literate_mode, { desc = "Toggle Literate Programming mode" })
-- 
-- -- ファイル再読み込み時のLiterate mode復元
-- vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
--   pattern = "*.rs",
--   callback = function()
--     if literate_mode then
--       toggle_literate_mode()
--       toggle_literate_mode()
--     end
--   end
-- })
