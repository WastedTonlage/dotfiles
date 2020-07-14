call plug#begin("~/.config/nvim/plugged")
Plug 'gyim/vim-boxdraw'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'neovim/nvim-lsp'
Plug 'ajh17/vimcompletesme'

" Snippets
Plug 'SirVer/ultisnips'

" Git (mostly for merging)
Plug 'tpope/vim-fugitive'

call plug#end()

map <Space> <Nop>
let mapleader="\<space>"

set number relativenumber
set virtualedit=all

set smartcase

set expandtab
set smartindent
set autoindent
set shiftwidth=4
set tabstop=4

set hidden

" go to conf
command! Configure edit ~/.config/nvim/init.vim
cnoreabbrev conf Configure 
"
" Danish keyboard 
nmap ¤ $
nmap å <CMD>q<CR>

nnoremap ( <CMD>noh<CR>

nnoremap j gjzz
nnoremap k gkzz
vnoremap j gjzz
vnoremap k gkzz
nnoremap gg ggzz
nnoremap G Gzz
vnoremap gg ggzz
vnoremap G Gzz
nnoremap { {zz
nnoremap } }zz
vnoremap { {zz
vnoremap } }zz

noremap C-j j
noremap C-k k

inoremap <c-s> <ESC>:w<CR>i
noremap <c-s> :w<CR>

color delek

lua << EOF
require('nvim_lsp').pyls.setup{}
require('nvim_lsp').clangd.setup{}
EOF

augroup lspgroup
    autocmd Filetype c,cpp setlocal omnifunc=v:lua.vim.lsp.omnifunc
    autocmd Filetype c,cpp nnoremap <TAB> <C-x><C-o>
    autocmd Filetype c,cpp inoremap <TAB> <C-x><C-o>
augroup END

" Make F4 switch between .h and .cpp like QT Creator
function Goto_header() 
    let cppfile = bufname("%")
    let headerfile = system("find_header " . cppfile)
    if v:shell_error == 0
        execute("e " . headerfile)
        let b:cppfile = cppfile
    else 
        echoerr "header file not found"
    endif
endfunction

function Goto_cppfile() 
    if exists("b:cppfile")
        execute("e " . b:cppfile)
    else
        echoerr "no return cpp file defined"
    endif
endfunction

function Toggle_header() 
    let ext = expand("%:e")
    if ext == "cpp"
        call Goto_header()
    elseif ext == "h"
        call Goto_cppfile()
    endif
endfunction

nnoremap <F2> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap r    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <F4> <cmd>call Toggle_header()<CR>

let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetDirectories=["UltiSnips"]

" Spell checking
autocmd FileType text call SpellChecking()

function SpellChecking()
	setlocal spell

	" Fixes last spelling mistake
	inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
endfunction
