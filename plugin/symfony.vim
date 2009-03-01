"{{{ for symfony 
"File:vim-symfony
"Author: soh kitahara <sugarbabe335@gmail.com>
"URL: http://github.com/soh335/vim-symfony/tree/master
"Description:
"   vim-symfony offers some convenient methods when you develp symfony project
"   in vim
"
"   :SymfonyView
"       move to template/xxxSuccess.php from action file.
"       Even if Action file name is not actions.class.php but
"       xxxAction.class.php, it can move to xxxSuccess.php.
"       In case of actions.class.php it judges from the line of the cursor
"       position, in case of xxxAction.class.php it judges from filename.
"
"   :SymfonyView error
"       If argument nameed error is passed to SymfonyView, move to
"       template/xxxError.php.
"
"   :SymfonyAction
"       move to actions/xxxAction.class.php or actions.class.php from
"       templates/xxxSuccess.php or templates/xxxError.php.
"
"   :SymfonyProject
"       set symfony project directory. it is necessary to still teach clearly.
"       like this, :SymfonyProject ../../../../
"       In the future, it it due to set up automatically.
"
"   :SymfonyModel
"       move to lib/model/xxx.php or lib/model/xxxPeer.php from anywhere.
"       Also in lib/model/---/xxx.php or xxxPeer.php, it corrensponds.
"       It judges from word under cursor.
"       It it necessary to do :SymfonyProject first.
"
"   :SymconyCC
"       execute symfony clear cache
"       It it necessary to do :SymfonyProject first.
"
"   :SymfonyInitApp
"       execute symfony init-app xxx
"       It it necessary to do :SymfonyProject first.
"
"   :SymfonyInitModule
"       execute symfony init-module xxx xxx
"       It it necessary to do :SymfonyProject first.
"
"   :SymfonyPropelInitAdmin
"       execyte symfony prople-init-admin xxx xxx xxx
"       It it necessary to do :SymfonyProject first.
"
"   :SymfonyConfig
"       It is shortcut to config/* files.
"
"   :SymfonyLib
"       It is shortcut to lib/* files.


"echo errormsg func
function! s:error(str)
    echohl ErrorMsg
    echomsg a:str
    echohl None
endfunction

" open template file function
function! s:openTemplateFile(file)
if finddir("templates","./../") != ""
    silent exec ":e ". finddir("templates", expand('%:p:h')."/../"). "/".a:file
else
    call s:error("error not find  templates directory")
endif
endfunction

"find and edit symfony view file 
"find and edit xxxError.php if argument is error
"find executeXXX or execute in line
function! s:SymfonyView(arg)
    let l:suffix = "Success.php"
    if a:arg == "error"
        let l:suffix = "Error.php"
    endif
    let l:word = matchstr(getline('.'),'execute[0-9a-zA-Z_-]*')
    if l:word == 'execute'
        "if action file is separeted
        let l:file = substitute(expand('%:t'),"Action.class.php","","").l:suffix
        call s:openTemplateFile(l:file)
        unlet l:file
        return
    elseif l:word  =~ 'execute' && strlen(l:word)>7
        let l:file = tolower(l:word[7:7]).l:word[8:].l:suffix
        call s:openTemplateFile(l:file)
        unlet l:file
        return
    endif
        call s:error("not find executeXXX in this line")
endfunction

" find and edit action class file
function! s:SymfonyAction()
    if expand('%:t') =~ 'Success.php'
        let l:view = 'Success.php'
    elseif expand('%:t') =~ 'Error.php'
        let l:view = 'Error.php'
    endif
    if finddir("actions","./../") != "" && substitute(expand('%:p:h'),'.*/','','') == "templates"
        let file = substitute(expand('%:t'),l:view,"","")."Action.class.php"
        if findfile(file,"./../actions/") != ""
            silent execute ':e ./../actions/'.file
        elseif findfile("actions.class.php", "./../actions") != ""
            silent execute ':e ./../actions/actions.class.php'
        else
            call s:error("not exist action class file")
        endif
    else
        call s:error("not exitst action dir")
    endif
endfunction

"find model class
"word under cursor is required
function! s:SymfonyModel(word)
    if findfile(a:word.".php", g:sf_root_dir."lib/model") != ""
        silent execute ':e '.g:sf_root_dir."lib/model/".a:word.".php"
    else
        if findfile(a:word.".php", g:sf_root_dir."lib/model/*") != ""
            silent execute ':e '. findfile(a:word.".php", g:sf_root_dir."lib/model/*")
        else
            call s:error("not find ".a:word.".php")
        endif
    endif
endfunction

"set symfony home project directory
function! s:SymfonyProject(word)
    if finddir('apps', a:word) != "" && finddir('web' , a:word) != "" && finddir('lib', a:word) != ""
        let g:sf_root_dir = finddir('apps',a:word)[:-5]
        echo "set symfony home"
    else
        call s:error("nof find apps, web, lib dir")
    endif
endfunction

"execute symfony clear cache
function! s:SymconyCC()
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony cc"
        echo "cache clear"
    else
        call s:error("not set symfony root dir")
    endif
endfunction

"execute symfony init-app 
function! s:SymfonyInitApp(app)
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony init-app ".a:app
        echo "init app ".a:app
    else
        call s:error("not set symfony root dir")
    endif
endfunction

"execute symfony init-module
function! s:SymfonyInitModule(app, module)
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony init-module ".a:app." ".a:module
        echo "init module ".a:app." ".a:module
    else
        call s:error("not set symfony root dir")
    endif
endfunction

"execute symfony propel-init-admin    
function! s:SymfonyPropelInitAdmin(app, module, model)
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony propel-init-admin ".a:app." ".a:module." ".model
        echo "propel-init-admin ".a:app." ".a:module." ".a:model
    else
        call s:error("not set symfony root dir")
    endif
endfunction

"open symfonyProject/config/* file
function! s:GetSymfonyConfigList(A,L,P)
    if exists("g:sf_root_dir")
        return split(substitute(glob(g:sf_root_dir."config/".a:A."*"),g:sf_root_dir."config/","","g"), "\n")
    else
        call s:error("not set symfony root dir")
    endif
endfunction

function! s:SymfonyOpenConfigFile(word)
    silent execute ':e '.g:sf_root_dir."config/".a:word
endfunction

"open symfonyProject/lib* file
function! s:GetSymfonyLibList(A,L,P)
    if exists("g:sf_root_dir")
        return split(substitute(glob(g:sf_root_dir."lib/".a:A."*"),g:sf_root_dir."lib/","","g"), "\n")
    else
        call s:error("not set symfony root dir")
    endif
endfunction

function! s:SymfonyOpenLibFile(word)
    silent execute ':e '.g:sf_root_dir."lib/".a:word
endfunction
"}}}


"{{{ map
command! -nargs=? SymfonyView :call s:SymfonyView(<q-args>)
command! -nargs=0 SymfonyAction :call s:SymfonyAction()
command! -nargs=0 SymfonyModel :call s:SymfonyModel(expand('<cword>'))
command! -complete=file -nargs=1 SymfonyProject :call s:SymfonyProject(<f-args>)
command! -nargs=0 Symfonycc :call s:SymconyCC()
command! -nargs=1 SymfonyInitApp :call s:SymfonyInitApp(<f-args>)
command! -nargs=+ SymfonyInitModule :call s:SymfonyInitModule(<f-args>)
command! -nargs=+ SymfonyPropelInitAdmin :call s:SymfonyPropelInitAdmin(<f-args>)
command! -nargs=? -complete=customlist,s:GetSymfonyConfigList SymfonyConfig :call s:SymfonyOpenConfigFile(<f-args>)
command! -nargs=? -complete=customlist,s:GetSymfonyLibList SymfonyLib :call s:SymfonyOpenLibFile(<f-args>)
"}}}
