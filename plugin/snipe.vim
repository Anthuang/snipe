augroup Snipe
  autocmd!
  autocmd WinScrolled * lua require'snipe'.snipe()
  autocmd CursorMoved * lua require'snipe'.maybe_close()
  autocmd BufLeave,BufWinLeave * lua require'snipe'.close()
augroup END

command! Snipe lua require'snipe'.snipe()
command! SnipeToggle lua require'snipe'.toggle()
command! SnipeClose lua require'snipe'.close()
