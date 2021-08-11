fun! Snipe()
  " lua for k in pairs(package.loaded) do if k:match("^snipe") then package.loaded[k] = nil end end
  lua << EOF
  local snipe = require('snipe')

  snipe.snipe()
  snipe.snipe()
EOF
endfun

augroup Snipe
  autocmd!
  autocmd CursorHold * lua require('snipe').snipe()
  autocmd CursorHoldI * lua require('snipe').snipe()
  " autocmd CursorMoved * lua require('snipe').snipe()
  " autocmd CursorMovedI * lua require('snipe').snipe()
augroup END

