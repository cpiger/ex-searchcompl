" ======================================================================================
" File         : searchcompl.vim
" Author       : Wu Jie 
" Last Change  : 03/16/2014 | 23:05:15 PM | Sunday,March
" Description  : This script catches the <Tab> character when using the '/' search 
"                command.  Pressing Tab will expand the current partial word to the 
"                next matching word starting with the partial word.
"                If you want to match a tab, use the '\t' pattern.
" ======================================================================================

" disable the searchcompl in xterm in linux/unix.
" because of the <ESC> mapping problem in xterm
if !has("gui_running") && has("unix")
  let g:loaded_searchcompl = 1
endif

" check if plugin loaded
if exists('g:loaded_searchcompl') || &cp
  finish
endif
let g:loaded_searchcompl = 1

" variables
let s:usr_input = ''
let s:init_search_input = 1

" ------------------------------------------------------------------ 
" Desc: Set mappings for search complete
" ------------------------------------------------------------------ 

function s:search_compl_start()
  let s:init_search_input = 1
  cnoremap <Tab> <C-R>=<SID>search_compl()<CR>
  cnoremap <silent> <CR> <CR>:call <SID>search_compl_stop()<CR>
  cnoremap <silent> <Esc> <C-C>:call <SID>search_compl_stop()<CR>
endfunction

" ------------------------------------------------------------------ 
" Desc: Tab completion in / search
" ------------------------------------------------------------------ 

function s:search_compl()
  let jump_to_next = 1
  if s:init_search_input == 1 
    let s:usr_input = getcmdline()
    let s:init_search_input = 0
    let jump_to_next = 0
  endif

  let cur_cmdline = getcmdline()
  let match_result = s:get_next_match_result(jump_to_next) 
  let cmdline = substitute(cur_cmdline, ".", "\<c-h>", "g") . match_result 
  return cmdline
endfunction

" ------------------------------------------------------------------ 
" Desc: 
" ------------------------------------------------------------------ 

function s:get_next_match_result( jump_to_next )
  let input_strlen = strlen(s:usr_input) 

  " first time search needn't jump
  if a:jump_to_next 
    silent call search ( s:usr_input, 'cwe' )
    let search_end_col = col( "." )
    let search_start_col = search_end_col - input_strlen + 1
    " KEEPME { 
    " silent call search ( s:usr_input, 'w' )
    " let search_start_col = col( "." )
    " let search_end_col = search_start_col + input_strlen
    " } KEEPME end 
  else " first time search
    let search_end_col = col( "." )
    let search_start_col = search_end_col - input_strlen
  endif

  silent exec "normal b"
  let cur_word = expand('<cword>')
  let word_start_col = col( "." )

  if a:jump_to_next " cause the / search mechanism don't allow cursor jump (though it jumped.), so for next search result, it will get the whole word 
    return '\<'.cur_word.'\>'
  endif

  " for first time search result, you can get partial word.
  let result_word = strpart( cur_word, search_start_col-word_start_col )
  return result_word 
endfunction


" ------------------------------------------------------------------ 
" Desc: Remove search complete mappings
" ------------------------------------------------------------------ 

function s:search_compl_stop()
  cunmap <Tab>
  cunmap <CR>
  cunmap <Esc>
  let s:init_search_input = 0
endfunction

"/////////////////////////////////////////////////////////////////////////////
" Key mappings
"/////////////////////////////////////////////////////////////////////////////

noremap <silent> <Plug>StartSearch :call <SID>search_compl_start()<CR>/
nmap / <Plug>StartSearch

" vim:ts=2:sw=2:sts=2
