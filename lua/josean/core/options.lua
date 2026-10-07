vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- 折り返し表示の設定
opt.linebreak = true   -- 単語の境界で折り返し
opt.breakindent = true -- 折り返し時のインデントを維持
opt.wrap = true

-- search settings
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

-- undoファイルの保存先ディレクトリを設定
opt.undodir = {vim.fn.stdpath("cache") .. "/undo"}

-- ディレクトリがなければ作成
vim.fn.mkdir(vim.opt.undodir:get()[1], "p")

-- 永続的なundoを有効化
opt.undofile = true

opt.mouse = 'a'

-- Rust推奨100文字ラインマーク
opt.colorcolumn = "100"

-- セッション復元時のfiletypeとhighlighting保持
opt.sessionoptions:append("localoptions")


