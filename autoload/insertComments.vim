"=============================================================================
" File: insertComments.vim
" Author: gnk_sato
" Created: 2016-02-25
"=============================================================================

scriptencoding utf-8

if !exists('g:loaded_insertComments')
    finish
endif
let g:loaded_insertComments = 1

let s:save_cpo = &cpo
set cpo&vim

function! insertComments#Test()
    call append(0, "isTest")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


