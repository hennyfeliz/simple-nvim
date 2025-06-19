local M = {}

-- Start a visual selection inside the given delimiter and remember it
function M.start(delim)
  if not delim or #delim ~= 1 then
    vim.notify("vis_nav.start: invalid delimiter", vim.log.levels.ERROR)
    return
  end
  vim.b.vis_nav_delim = delim
  vim.cmd('normal! vi' .. delim)
end

-- Navigate to the next / previous occurrence of the stored delimiter
-- @param forward boolean : true = next, false = previous
function M.navigate(forward)
  local delim = vim.b.vis_nav_delim
  if not delim then
    vim.notify("vis_nav: no stored delimiter – start with {, }, ] etc.", vim.log.levels.WARN)
    return
  end
  -- Ensure we are in Normal mode
  vim.cmd([[normal! \\<Esc>]])

  -- Move one char outside current selection to avoid staying inside same block
  if forward then
    vim.cmd([[normal! `>l]])
  else
    vim.cmd([[normal! `<h]])
  end

  local pattern = vim.fn.escape(delim, '\\.^$*[]')
  local flags = forward and 'W' or 'bW'

  -- For forward move we need to skip until next opening delimiter (two searches: close + open)
  local search_count = forward and 2 or 1
  for _ = 1, search_count do
    local ok = vim.fn.search(pattern, flags)
    if ok == 0 then
      vim.notify('vis_nav: no further delimiter found', vim.log.levels.INFO)
      return
    end
  end

  -- Select inside the found delimiter again
  vim.cmd('normal! vi' .. delim)
end

return M 