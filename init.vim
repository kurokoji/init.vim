" dein.vim {{{
if &compatible
  set nocompatible
endif

set runtimepath+=~/.config/nvim/dein/repos/github.com/Shougo/dein.vim

call dein#begin(expand('~/.config/nvim/dein'))

call dein#add('Shougo/dein.vim')
call dein#add('Shougo/vimproc.vim', {'build': 'make'})
call dein#add('Shougo/deoplete.nvim')
call dein#add('Shougo/neoinclude.vim')
call dein#add('zchee/deoplete-clang')
call dein#add('thinca/vim-quickrun')
call dein#add('kana/vim-smartinput')
call dein#add('itchyny/lightline.vim')
call dein#add('Shougo/unite.vim')
call dein#add('Shougo/neosnippet')
call dein#add('Shougo/neosnippet-snippets')
call dein#add('Yggdroot/indentLine')
call dein#add('airblade/vim-gitgutter')
call dein#add('thinca/vim-template')

" colorscheme
call dein#add('vim-scripts/Wombat')
call dein#add('itchyny/landscape.vim')

" }}}

" thinca/vim-quickrun {{{
let g:quickrun_config = {'*': {'hook/time/enable': '1'},}
let g:quickrun_config.cpp = {
  \   'command': 'g++',
  \   'cmdopt': '-std=c++11'
  \ }

"}}}
" Shougo/deoplete.nvim {{{
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_at_smart_case = 1

inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

"augroup cpp-path
"  autocmd!
"  autocmd FileType cpp setlocal path=.,/usr/include/c++/4.8/,/usr/include/x86_64-linux-gnu/c++/4.8,/usr/include/c++/4.8/backward,/usr/lib/gcc/x86_64-linux-gnu/4.8/include,/usr/local/include/,/usr/lib/gcc/x86_64-linux-gnu/4.8/include-fixed,/usr/include/x86_64-linux-gnu,/usr/include
"augroup END

" }}}
" zchee/deoplete-clang {{{
let g:syntastic_cpp_compiler_options = ' -std=c++1y'
let g:deoplete#sources#clang#libclang_path = '/usr/lib/llvm-3.4/lib/libclang.so.1'
let g:deoplete#sources#clang#clang_header = '/usr/include/clang'

"}}}
" itchyny/lightline {{{
let g:lightline = {
  \ 'colorscheme': 'landscape',
  \ 'mode_map': {'c': 'NORMAL'},
  \ 'active': {
  \   'left': [
  \     ['mode', 'paste'],
  \     ['fugitive', 'gitgutter', 'filename'],
  \   ],
  \   'right': [
  \     ['lineinfo', 'syntastic'],
  \     ['percent'],
  \     ['charcode', 'fileformat', 'fileencoding', 'filetype'],
  \   ]
  \ },
  \ 'component_function': {
  \   'modified': 'MyModified',
  \   'readonly': 'MyReadonly',
  \   'fugitive': 'MyFugitive',
  \   'filename': 'MyFilename',
  \   'fileformat': 'MyFileformat',
  \   'filetype': 'MyFiletype',
  \   'fileencoding': 'MyFileencoding',
  \   'mode': 'MyMode',
  \   'syntastic': 'SyntasticStatuslineFlag',
  \   'charcode': 'MyCharCode',
  \   'gitgutter': 'MyGitGutter',
  \ },
  \ 'separator': {'left': '⮀', 'right': '⮂'},
  \ 'subseparator': {'left': '⮁', 'right': '⮃'}
  \ }

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &ro ? '⭤' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? substitute(b:vimshell.current_dir,expand('~'),'~','') :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
      let _ = fugitive#head()
      return strlen(_) ? '⭠ '._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth('.') > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth('.') > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth('.') > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  return winwidth('.') > 60 ? lightline#mode() : ''
endfunction

function! MyGitGutter()
  if ! exists('*GitGutterGetHunkSummary')
        \ || ! get(g:, 'gitgutter_enabled', 0)
        \ || winwidth('.') <= 90
    return ''
  endif
  let symbols = [
        \ g:gitgutter_sign_added . ' ',
        \ g:gitgutter_sign_modified . ' ',
        \ g:gitgutter_sign_removed . ' '
        \ ]
  let hunks = GitGutterGetHunkSummary()
  let ret = []
  for i in [0, 1, 2]
    if hunks[i] > 0
      call add(ret, symbols[i] . hunks[i])
    endif
  endfor
  return join(ret, ' ')
endfunction

" https://github.com/Lokaltog/vim-powerline/blob/develop/autoload/Powerline/Functions.vim
function! MyCharCode()
  if winwidth('.') <= 70
    return ''
  endif

  " Get the output of :ascii
  redir => ascii
  silent! ascii
  redir END

  if match(ascii, 'NUL') != -1
    return 'NUL'
  endif

  " Zero pad hex values
  let nrformat = '0x%02x'

  let encoding = (&fenc == '' ? &enc : &fenc)

  if encoding == 'utf-8'
    " Zero pad with 4 zeroes in unicode files
    let nrformat = '0x%04x'
  endif

  " Get the character and the numeric value from the return value of :ascii
  " This matches the two first pieces of the return value, e.g.
  " "<F>  70" => char: 'F', nr: '70'
  let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

  " Format the numeric value
  let nr = printf(nrformat, nr)

  return "'". char ."' ". nr
endfunction

" }}}
" Shougo/neosnippet {{{ 
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)
 
" SuperTab like snippets behavior.
"imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"\ "\<Plug>(neosnippet_expand_or_jump)"
"\: pumvisible() ? "\<C-n>" : "\<TAB>"
"smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"\ "\<Plug>(neosnippet_expand_or_jump)"
"\: "\<TAB>"
 
" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

let g:neosnippet#snippets_directory='~/.config/nvim/dein/repos/github.com/Shougo/neosnippet-snippets/snippets/'

"}}}
" Yggdroot/indentLine {{{
let g:indentLine_color_term = 239
let g:indentLine_char = '|'

" }}}
" thinca/vim-template {{{
  	autocmd User plugin-template-loaded
	\    if search('<+CURSOR+>')
	\  |   execute 'normal! "_da>'
	\  | endif
" }}}

syntax enable
set title
set number
set foldmethod=marker
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,cp932,sjis,euc-jp
set fencs=utf-8,iso-2022-jp,enc-jp,cp932
set list
set matchpairs& matchpairs+=<:>
set listchars=tab:»-,eol:¬,extends:»,precedes:«,nbsp:%
set infercase
set autoread
set nowrap
set t_Co=256

set tabstop=2
set shiftwidth=2
set expandtab
set cindent
language en_US.UTF-8

inoremap <C-j> <Esc>

colorscheme landscape
set background=dark
