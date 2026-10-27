-- ノーマルモードのあいだは，かなのままでも vim のキーを半角で受けるための知らせ．
-- フォーカスのある nvim がノーマルモード（ビジュアル，オペレータ待ちを含む）なら，Karabiner の変数 nvim_normal を 1 にする．
-- Karabiner（~/.config/karabiner/karabiner.json）は，WezTerm が前面で nvim_normal が 1 で入力が日本語のとき，キーの前に英数を送る
local cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
if vim.fn.has("mac") == 0 or vim.fn.executable(cli) == 0 then
  return
end

-- 立ち上げたままの karabiner_cli に1行ずつ渡す．毎回立ち上げると，知らせが届く順番が入れ替わりうる
local proc
local last
local focused = true

local function send(value)
  if not proc or proc:is_closing() then
    proc = vim.system({ cli, "--set-variables-from-stdin", "--silent" }, { stdin = true })
  end
  proc:write(vim.json.encode({ nvim_normal = value }) .. "\n")
  last = value
end

-- force：ほかの nvim が書き換えたかもしれないとき（フォーカスの出入り）は，同じ値でも送り直す
local function update(force)
  local value = 0
  if focused and vim.api.nvim_get_mode().mode:find("^[nvV\22]") then
    value = 1
  end
  if force or value ~= last then
    send(value)
  end
end

local function attach()
  -- headless（試験や Kai の道具）では知らせない
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  local group = vim.api.nvim_create_augroup("karabiner_mode", { clear = true })
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = function()
      update(false)
    end,
  })
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
    group = group,
    callback = function()
      focused = true
      update(true)
    end,
  })
  vim.api.nvim_create_autocmd({ "FocusLost", "VimSuspend" }, {
    group = group,
    callback = function()
      focused = false
      update(true)
    end,
  })
  -- 終わるときは 0 を届けてから閉じる．SIGHUP（タブを閉じたとき）と SIGTERM でもここを通る
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      focused = false
      update(true)
      proc:write(nil)
      proc:wait(500)
    end,
  })
  update(true)
end

if vim.v.vim_did_enter == 1 then
  attach()
else
  vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = attach })
end
