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

function! GetAuthor()
    let authorName = substitute(system("whoami"), "\n", "", "g")
    return 'Author: ' . authorName
endfunction

function! GetCreatedAt()
    let now = localtime()
    return "CreatedAt: " . strftime("%Y/%m/%d", now)
endfunction

function! GetArgs(sentence)
    let mysentence = substitute(a:sentence, ' ', '', 'g')
    let start   = stridx(mysentence, "(")
    let stop    = stridx(mysentence, ")")
    let argsStr = mysentence[start+1 : stop-1]
    return split(argsStr, ',')
endfunction

function! IsJavascript(filename)
    let array = split(a:filename, '\.')
    return len(array) > 1 && (array[-1] == 'js' || array[-1] == 'jsx')
endfunction

function! IsES6Class(sentence)
    return stridx(a:sentence, " class ") != -1
endfunction

function! IsComment(sentence)
    let mysentence = substitute(a:sentence, ' ', '', 'g')
    let target     = mysentence[0 : 1]
    return target == "//"  || target == "/*"
endfunction

function! IsConstructor(sentence)
    return stridx(a:sentence, " constructor(") != -1
endfunction

function! ExtractClassName(sentence)
    let mysentence = substitute(a:sentence, '\( \)\+', ' ', 'g')
    let terms = split(mysentence, ' ')
    let index = index(terms, 'class')
    return terms[index+1]
endfunction

function! Indent(sentences)
    return map(a:sentences, "'  ' . v:val")
endfunction

function! AppendJSComments()
    let comments = []
    call add(comments, GetAuthor())
    call add(comments, GetCreatedAt())
    call add(comments, "")

    let classInfo   = []
    let hasES6Class = 0

    try
        for line in readfile(expand("%"))
            if !IsComment(line)
                if IsES6Class(line)
                    let obj  = {'name': ExtractClassName(line)}
                    call add(classInfo, obj)

                    let hasES6Class = 1
                endif

                if hasES6Class
                    if(IsConstructor(line))
                        let constructorArgs = GetArgs(line)
                        if len(constructorArgs)
                            let classInfo[-1].constructor = constructorArgs
                        endif

                        let hasES6Class = 0
                    endif
                endif
            endif
        endfor
    catch
        echo "Failed to read. Please do it after saving!"
    endtry

    for aClassInfo in classInfo

        let commentsAboutClass = []
        let className   = "ClassName: " . aClassInfo.name
        call add(commentsAboutClass, className)
        call add(commentsAboutClass, "Summary: ")

        if has_key(aClassInfo, 'constructor')
            call add(commentsAboutClass, "Constructor: ")
            
            for constructorArg in aClassInfo.constructor
                call add(commentsAboutClass, "  " . constructorArg . ":")
            endfor
        endif
        
        call add(commentsAboutClass, "")
        for comment in Indent(commentsAboutClass)
            call add(comments, comment)
        endfor 
    endfor

    let indentedComments = Indent(comments)

    call insert(indentedComments, '/**', 0)
    call add(indentedComments, '*/')
    call add(indentedComments, "")
    
    return indentedComments
endfunction

function! insertComments#InsertComments()
    let filename = expand("%")
    if IsJavascript(filename)
        call append(0, AppendJSComments())
    endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo


