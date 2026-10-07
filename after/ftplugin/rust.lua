-- Rust固有の設定
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

-- より良いコメント形式
vim.opt_local.commentstring = "// %s"

-- Rustファイル用のキーマッピング
vim.keymap.set('n', '<leader>cr', ':!cargo run<CR>', { buffer = true, desc = 'Cargo run' })
vim.keymap.set('n', '<leader>ct', ':!cargo test<CR>', { buffer = true, desc = 'Cargo test' })
vim.keymap.set('n', '<leader>cb', ':!cargo build<CR>', { buffer = true, desc = 'Cargo build' })
vim.keymap.set('n', '<leader>cc', ':!cargo check<CR>', { buffer = true, desc = 'Cargo check' })