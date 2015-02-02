" wordbyword.vim - word by word interface call funcion
" Version: 2.0
" Maintainer: E. Manuel Cerrón Angeles <xerron.angels@gmail.com>
" Date: 2015-01-18
" Licence: MIT

if exists("g:loaded_wordbyword")
  finish
endif

let g:loaded_wordbyword=1

let s:save_cpo = &cpo
set cpo&vim

" Devuelve la lista de booknames
function! s:BooknameList()
  if exists('g:wbw_stardict_booknames')
    return g:wbw_stardict_booknames 
  endif
  let s:result =  system('sdcv -l')
  let s:booknames = split(s:result) 
  call remove(s:booknames, 0 , 3) 
  let s:len = len(s:booknames)
  let s:count = 1
  while s:count <= s:len/2
    call remove(s:booknames, s:count) 
    let s:count += 1
  endwhile
  let g:wbw_stardict_booknames = s:booknames
  return g:wbw_stardict_booknames
endfunction

" Abrir WBW Buffer 
function! s:wordbyword(bang)
  if a:bang
    if g:wbw_stardict_bookname == 'g'
      call wordbyword#goldendict_close()
    else
      call wordbyword#close()
    endif
  else
    let s:dictionaries = s:BooknameList()
    echohl Title 
    echo 'Diccionarios disponibles:' 
    echohl None 
    let s:count=1
    for i in s:dictionaries
      echo s:count . ' - ' . i
      let s:count += 1
    endfor
    echo 'g - Goldendict popup'
    echo 'Selecciona un bookname: (escriba un numero) '
    let s:choice = nr2char(getchar())
    let g:wbw_stardict_bookname = s:choice
    if g:wbw_stardict_bookname == 'g'
      call wordbyword#goldendict_open()
    else
      call wordbyword#open()
    endif
  endif
endfunction

" Abrir WBW Balloon 
function! s:wordbywordballoon(bang)
  if a:bang
    setlocal nobeval
  else
    let s:dictionaries = s:BooknameList()
    echohl Title 
    echo 'Diccionarios disponibles:' 
    echohl None 
    let s:count=1
    for i in s:dictionaries
      echo s:count . ' - ' . i
      let s:count += 1
    endfor
    echo 'Selecciona un bookname: (escriba un numero) '
    let s:choice = nr2char(getchar())
    let g:wbw_stardict_bookname = s:choice
    " activar balloon
    setlocal bexpr=wordbyword#balloon()
    setlocal beval 
  endif
endfunction

" Balloon Toggle
function! WBWBalloonToggle()
  setlocal bexpr=wordbyword#balloon()
  setlocal beval! 
endfunction

if !exists('g:wbw_map_keys')
  let g:wbw_map_keys=1
endif

if g:wbw_map_keys
  nnoremap <unique> <LocalLeader>B :call WBWBalloonToggle()<CR>
endif

command! -bang Wordbyword call s:wordbyword('<bang>' == '!')
command! -bang WordbywordBalloon call s:wordbywordballoon('<bang>' == '!')

let &cpo = s:save_cpo
