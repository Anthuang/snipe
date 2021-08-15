fun! Snipe()
  lua require("snipe").snipe()
endfunction

fun! SnipeToggle()
  lua require("snipe").toggle()
endfunction

fun! SnipeClose()
  lua require("snipe").close()
endfunction

augroup Snipe
  autocmd!
  autocmd WinScrolled * call Snipe()
  autocmd BufLeave,BufWinLeave * call SnipeClose()
augroup END

