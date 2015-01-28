" wordbyword.vim - word by word interface call funcion
" Version: 0.1
" Maintainer: E. Manuel Cerrón Angeles <xerron.angels@gmail.com>
" Date: 2015-01-18
" Licence: MIT

" Posición del split
" '', 'rightbelow', 'vertical', 'vertical rightbelow'
if !exists("g:wbw_window_position")
	let g:wbw_window_position='rightbelow'
endif

" Tamaño del split cuando es horizontal
if !exists("g:wbw_window_height")
	let g:wbw_window_height=10
endif

if !exists("g:CODDisableCursorMoveUpdate")
	let g:CODDisableCursorMoveUpdate=0
endif

" Borrar el evento del cursor
function! s:delete_augroup()
	augroup WBWCursorEvent
		autocmd!
	augroup END
endfunction

" Actualiza la palabra bajo el cursor
function! s:UpdateWord()
  " deshabilitar en visual mode
	if mode() =~# "[vV\<C-v>]"
		return
	endif

  " Si no encuentra la ventana no actualiza la palabra 
	let [orgnr, outputnr] = [winnr(), s:get_output_winnr('wordbyword')]
	if outputnr == -1
		return
	endif

  " No actualiza si es el mismo buffer
	if outputnr == orgnr
		return
	endif

  " Traer la palabra actual
	let cursor_word = expand("<cword>")
	if len(cursor_word) == 0
		return
	endif

	" Ultima palabra comprobación 
	execute outputnr 'wincmd w'
	let last_word = ''
	if exists("b:last_word")
		let last_word = b:last_word
	endif
	execute orgnr 'wincmd w'
	if last_word ==# cursor_word
		return
	endif

  " pegar el contenido de sdcv en el buffer
  let l:dict_path=''
  let l:bookname=''
  " verifico si esta definido un path
  if exists("g:wbw_stardict_dictionary_path")
    let l:dict_path='--data-dir=' . g:wbw_stardict_dictionary_path . ' '
  endif
  " poner el bookname
  if exists("g:wbw_stardict_bookname")
    let l:bookname='--use-dict=' . get(g:wbw_stardict_booknames, g:wbw_stardict_bookname - 1) . ' '
  endif
  " Ejecutar sdcv
  let expl=system('sdcv -n ' . l:dict_path . l:bookname . cursor_word)

	execute outputnr 'wincmd w'

  " si no devuelve nada volver a la actual ventana
	if len(expl) == 0
		execute orgnr 'wincmd w'
		return
	endif

	setlocal modifiable

  " Colorear el buffer wordbyword
	" silent! syntax clear codSearchWord
  " if len(expl) > 0
	" 	execute 'syntax match codSearchWord /\c'.escape(a:word, ' /').'/'r
	" endif

  " let l:word = substitute(a:word,"\n\\|\t",'','g')
  normal! ggdG
  put =expl

	setlocal nomodifiable

	execute orgnr 'wincmd w'

endfunction

" Muestra el resultado de la busqueda
function! wordbyword#open()
	let bname = 'wordbyword' 
	let cur_winnr = winnr()

	if !bufexists(bname)
    " Si no existe la ventana se debe de crear
    let height = g:wbw_window_height
		if height == 0
			let height = ''
		endif
		silent execute g:wbw_window_position height 'new'
		setlocal bufhidden=unload
		setlocal nobuflisted
		setlocal buftype=nofile
		setlocal nomodifiable
		setlocal noswapfile
		setlocal nonumber
		setlocal foldmethod=marker
		setfiletype wordbyword
		silent file `=bname`
    " Keymaps para el filetype wordbyword
		noremap <buffer><silent> q :bwipeout<cr>
		noremap <buffer><silent> K :if expand("<cword>") != ''\|call wordbyword#search_keyword_ex(expand("<cword>"))\|endif<CR>
		vnoremap <buffer><silent> K :call wordbyword#selected_ex()<cr>
	else
    " si ya existe la ventana se reusa
		let bufnr = bufnr('^'.bname.'$')
		let winnr = bufwinnr(bufnr)
		if winnr != -1
			return
		endif
		execute g:wbw_window_position g:wbw_window_height 'split'
		silent execute bufnr 'buffer'
	endif

	augroup WBWCursorEvent
		autocmd!
		autocmd CursorMoved * call <SID>UpdateWord()
		execute "autocmd BufWipeout" bname "call s:delete_augroup()"
	augroup END

  " Volver a la ventana actual
  execute cur_winnr 'wincmd w'

  " Actualizar palabra
  call s:UpdateWord()
endfunction

" Cierra el resultado de busqueda
function! wordbyword#close()
	let bname = '^wordbyword$'
	silent! execute 'bwipeout!' bufnr(bname)
endfunction

" Toggle el ventana
function! wordbyword#toggle()
	let win_nr = winnr('$')
	call cursoroverdictionary#open()
	if win_nr == winnr('$')
		call cursoroverdictionary#close()
	endif
endfunction

" Busca la palabra y la muestra en la buffer wbw
function! wordbyword#selected_ex()
  " TODO
endfunction

" Busca la palabra selecciona en visual mode y la muesta en el buffer
function! wordbyword#search_keyword_ex(word)
  " TODO
endfunction

" Busca la ventana de salida
function! s:get_output_winnr(bname)
	if bufexists(a:bname) == 0
		return -1
	endif
	return bufwinnr(bufnr('^'. a:bname .'$'))
endfunction

" Contenido del balloon
function! wordbyword#balloon()
  let l:dict_path=''
  let l:bookname=''
  " verifico si esta definido un path
  if exists("g:wbw_stardict_dictionary_path")
    let l:dict_path='--data-dir=' . g:wbw_stardict_dictionary_path . ' '
  endif
  " poner el bookname
  if exists("g:wbw_stardict_bookname")
    let l:bookname='--use-dict=' . get(g:wbw_stardict_booknames, g:wbw_stardict_bookname - 1) . ' '
  endif
  " Ejecutar sdcv
  let s:expl=system('sdcv -n ' . l:dict_path . l:bookname . 
          \ v:beval_text .
          \ '|fmt -cstw 40')
  return s:expl
endfunction

