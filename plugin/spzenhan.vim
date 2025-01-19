scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

if exists('g:spzenhan')
    finish
endif
let g:spzenhan = 1

if !exists('g:spzenhan#wsl')
    if has('unix')
        let s:uname = system('uname -a')
        if (stridx(s:uname, 'Linux') != -1) && (stridx(s:uname, 'microsoft-standard') != -1)
            let g:spzenhan#wsl = 1
        else
            let g:spzenhan#wsl = 0
        endif
    else
        let g:spzenhan#wsl = 0
    endif
endif

function! s:find_executable_file(files) abort
    for file in a:files
        if executable(file)
            return file
        endif
    endfor
    return v:null " not found
endfunction

if has('win32') || has('win32unix') || g:spzenhan#wsl == 1
    if !exists('g:spzenhan#executable')
        let g:spzenhan#executable = 'spzenhan.exe'
        let executable = s:find_executable_file([
                    \ 'spzenhan.exe',
                    \ expand('<sfile>:h:h') . '/zenhan/spzenhan.exe',
                    \ expand('<sfile>:h:h') . '/spzenhan.exe',
                    \ ])
        if executable isnot v:null
            let g:spzenhan#executable = executable
        else
            echo "spzenhan.exe is not found"
            finish
        endif
    endif

    augroup zenhan
        autocmd!
        autocmd BufEnter * call system([g:spzenhan#executable])
                \ | let b:zenhan_ime_status = exists('g:spzenhan#default_status') ? g:spzenhan#default_status : v:shell_error
        autocmd InsertEnter * if b:zenhan_ime_status == 1 | call system([g:spzenhan#executable , ' 1']) | endif
        autocmd InsertLeave * call system([g:spzenhan#executable , ' 0'])
                \ | let b:zenhan_ime_status = exists('g:spzenhan#default_status') ? g:spzenhan#default_status : v:shell_error
    augroup END
endif

let &cpo = s:save_cpo
unlet s:save_cpo
