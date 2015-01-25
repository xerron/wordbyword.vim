" wordbyword.vim - word by word interface call funcion
" Version: 0.1
" Maintainer: E. Manuel Cerrón Angeles <xerron.angels@gmail.com>
" Date: 2015-01-18
" Licence: MIT

if exists("g:loaded_wordbyword")
  finish
endif

let g:loaded_wordbyword=1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? wordbyword call wordbyword#open(<q-args>)

command! -nargs=? WBWOpen call wordbyword#open(<q-args>)
command! -nargs=? WBWClose call wordbyword#close()
command! -nargs=? WBWToggle call wordbyword#toggle()

let &cpo = s:save_cpo
