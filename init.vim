call plug#begin("~/.config/nvim/plugged")

Plug 'gyim/vim-boxdraw'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'neovim/nvim-lsp'

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

command! Conf :e ~/.config/nvim/init.vim

color delek

lua << EOF
require('nvim_lsp').pyls.setup{}
require('nvim_lsp').clangd.setup{}
EOF

autocmd Filetype c,cpp setlocal omnifunc=v:lua.vim.lsp.omnifunc

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

function Build()
    let current_dir = getcwd()
    let builddir = system("/home/mad/work/scripts/find_builddir " . bufname("%"))
    if v:shell_error != 0 
        return
    endif
    exec 'cd' builddir
    ! make
    exec 'cd' current_dir
endfunction

function Run_Cmake()
    let current_dir = getcwd()
    let builddir = system("/home/mad/work/scripts/find_builddir " . bufname("%"))
    if v:shell_error != 0 
        return
    endif
    exec 'cd' builddir
    ! cmake ..
    exec 'cd' current_dir
endfunction
