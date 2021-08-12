fun! Snipe()
  lua require('snipe').snipe()
endfunction

fun! SnipeClose()
  lua require('snipe').close()
endfunction

augroup Snipe
  autocmd!
  autocmd CursorMoved * call Snipe()
  autocmd BufLeave,BufWinLeave * call SnipeClose()
augroup END

