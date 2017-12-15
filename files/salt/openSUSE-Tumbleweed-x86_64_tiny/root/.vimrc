set nocompatible              " be iMproved, required
se nu

set history=500
filetype plugin on
filetype indent on

" CTRLP 
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

autocmd FileType sh setlocal shiftwidth=4 tabstop=4
autocmd FileType perl setlocal shiftwidth=4 tabstop=4
autocmd FileType c setlocal shiftwidth=4 tabstop=4
autocmd FileType yacc setlocal shiftwidth=4 tabstop=4
autocmd FileType go setlocal noexpandtab shiftwidth=4 tabstop=4
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType cpp setlocal shiftwidth=4 tabstop=4
autocmd FileType php setlocal noexpandtab shiftwidth=4 tabstop=4
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2


" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file


function! InsertStatuslineColor(mode)
  if a:mode == 'i'
    hi statusline guibg=Cyan ctermfg=6 guifg=Black ctermbg=0
  elseif a:mode == 'r'
    hi statusline guibg=Purple ctermfg=5 guifg=Black ctermbg=0
  else
    hi statusline guibg=DarkRed ctermfg=1 guifg=Black ctermbg=0
  endif
endfunction

au InsertEnter * call InsertStatuslineColor(v:insertmode)
au InsertLeave * hi statusline guibg=DarkGrey ctermfg=8 guifg=White ctermbg=15

" default the statusline to green when entering Vim
hi statusline guibg=Green ctermfg=8 guifg=White ctermbg=15

" Formats the statusline
set statusline=%f                           " file name
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%y      "filetype
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag

set statusline+=%#warningmsg#
set statusline+=%*

set statusline+=\ %=                        " align left
set statusline+=Line:%l/%L[%p%%]            " line X of Y [percent of file]
set statusline+=\ Col:%c                    " current column
set statusline+=\ Buf:%n                    " Buffer number
set statusline+=\ [%b][0x%B]\               " ASCII and byte code under cursor

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 6 lines to the cursor - when moving vertically using j/k
set so=6

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
"
set term=xterm-256color
let g:solarized_termcolors=256
syntax on 
set relativenumber

" Bindings
"
" CTRL-Right is next tab
noremap <C-RIGHT> :<C-U>tabnext<CR>
inoremap <C-RIGHT> <C-\><C-N>:tabnext<CR>
cnoremap <C-RIGHT> <C-C>:tabnext<CR>
" CTRL-left is previous tab
noremap <C-LEFT> :<C-U>tabprevious<CR>
inoremap <C-LEFT> <C-\><C-N>:tabprevious<CR>
cnoremap <C-LEFT> <C-C>:tabprevious<CR>

" CTRL-N is new tab
noremap <C-N> :<C-U>tabnew<CR>
inoremap <C-N> <C-\><C-N>:tabnew<CR>
cnoremap <C-N> <C-C>:tabnew<CR>
" CTRL-W is tab close
" map <C-W> <C-C>:tabclose<CR>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <C-O> :buffers<CR>:buffer<Space>
nnoremap <C-I> :ls<CR>

" Nerdtree " 
"
" Search
" bind CTRL-F to grep word under cursor
nnoremap <C-F> :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <C-]> :sp <CR>:exec("tag ".expand("<cword>"))<CR>

set tabstop=8
set expandtab
set shiftwidth=4
set softtabstop=4
" laststatus - setting for statusbar.default is 1 - only show statusbar when
" there at least 2 windows.. change this behavior with setting it to 1 -
" always show the status bar
set laststatus=2
colo desert
set background=dark
