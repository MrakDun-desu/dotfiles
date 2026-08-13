 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#1e1e2e',
    base01 = '#313244',
    base02 = '#3a3b50',
    base03 = '#6c7086',
    base04 = '#a6adc8',
    base05 = '#cdd6f4',
    base06 = '#cdd6f4',
    base07 = '#cdd6f4',
    base08 = '#f38ba8',
    base09 = '#cba6f7',
    base0A = '#f5c2e7',
    base0B = '#b4befe',
    base0C = '#bb8af4',
    base0D = '#8192fd',
    base0E = '#ed91d4',
    base0F = '#c8043a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#cdd6f4',          bg = '#1e1e2e' })
  hi('TelescopeBorder',         { fg = '#6c7086',             bg = '#1e1e2e' })
  hi('TelescopePromptNormal',   { fg = '#cdd6f4',          bg = '#1e1e2e' })
  hi('TelescopePromptBorder',   { fg = '#6c7086',             bg = '#1e1e2e' })
  hi('TelescopePromptPrefix',   { fg = '#b4befe',             bg = '#1e1e2e' })
  hi('TelescopePromptCounter',  { fg = '#a6adc8',  bg = '#1e1e2e' })
  hi('TelescopePromptTitle',    { fg = '#1e1e2e',             bg = '#b4befe' })
  hi('TelescopePreviewTitle',   { fg = '#1e1e2e',             bg = '#f5c2e7' })
  hi('TelescopeResultsTitle',   { fg = '#1e1e2e',             bg = '#cba6f7' })
  hi('TelescopeSelection',      { fg = '#cdd6f4',          bg = '#3a3b50' })
  hi('TelescopeSelectionCaret', { fg = '#b4befe',             bg = '#3a3b50' })
  hi('TelescopeMatching',       { fg = '#b4befe',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
