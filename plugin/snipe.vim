fun! Snipe()
  lua require('snipe').snipe()
endfun

augroup Snipe
  autocmd!
  autocmd CursorMoved * lua require('snipe').snipe()
  autocmd CursorMovedI * lua require('snipe').snipe()
  autocmd BufLeave,BufWinLeave * lua require('snipe').close()
augroup END

