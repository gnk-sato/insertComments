"=============================================================================
" File: insertComments.vim
" Author: gnk_sato
" Created: 2016-02-25
"=============================================================================

echo "aaa"
scriptencoding utf-8

if exists('g:loaded_insertComments')
    finish
endif
let g:loaded_insertComments = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent><C-i> :call insertComments#Test()<CR>


let &cpo = s:save_cpo
unlet s:save_cpo
