call plug#begin("~/.config/nvim/plugged")
Plug 'gyim/vim-boxdraw'
Plug 'tpope/vim-fugitive'
Plug 'machakann/vim-sandwich'
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'neovim/nvim-lsp'
Plug 'nvim-lua/completion-nvim'

" Snippets
Plug 'SirVer/ultisnips'

" Git (mostly for merging)
Plug 'tpope/vim-fugitive'

call plug#end()

map <Space> <Nop>
let mapleader="\<space>"

set number relativenumber
set virtualedit=all

set ignorecase
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
omap ¤ $
nmap å <CMD>q<CR>

nnoremap ( <CMD>noh<CR>

nnoremap % %zz
vnoremap % %zz
nnoremap j gjzz
nnoremap k gkzz
vnoremap j gjzz
vnoremap k gkzz
nnoremap gg ggzz
nnoremap G Gzz
vnoremap gg ggzz
vnoremap G Gzz
nnoremap n nzz
nnoremap N Nzz
vnoremap n nzz
vnoremap N Nzz
nnoremap { {zz
nnoremap } }zz
vnoremap { {zz
vnoremap } }zz

noremap C-j j
noremap C-k k

inoremap <c-s> <ESC>:w<CR>i
noremap <c-s> :w<CR>

set clipboard+=unnamedplus

color delek


lua << EOF
local genericCapabilities = vim.lsp.protocol.make_client_capabilities()
genericCapabilities.textDocument.codeAction = {
    dynamicRegistration = false;
    codeActionLiteralSupport = {
        codeActionKind = {
            valueSet = {
                "",
                "quickfix",
                "refactor",
                "refactor.extract",
                "refactor.inline",
                "refactor.rewrite",
                "source"
            };
        };
    };
}
require('nvim_lsp').pyls.setup{
    on_attach=require'completion'.on_attach;
    capabilities = genericCapabilities;
}
require('nvim_lsp').clangd.setup{
    on_attach=require'completion'.on_attach;
    capabilities = genericCapabilities;
}
require('nvim_lsp').rust_analyzer.setup{
    on_attach=require'completion'.on_attach;
    capabilities = genericCapabilities;
}
require('nvim_lsp').tsserver.setup{
    on_attach=require'completion'.on_attach;
    capabilities = genericCapabilities;
}
EOF

augroup lspgroup
    autocmd Filetype c,cpp nnoremap <TAB> <C-x><C-o>
    autocmd Filetype c,cpp inoremap <TAB> <C-x><C-o>
augroup END

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

let g:completion_enable_snippet = 'UltiSnips'
" Set completeopt to have a better completion experience (citation needed)
set completeopt=menuone,noinsert

" Avoid showing message extra message when using completion
set shortmess+=c

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

let g:UltiSnipsSnippetDirectories=["UltiSnips"]

" Spell checking
autocmd FileType text call SpellChecking()

function SpellChecking()
    if expand('%:t') != 'settings.txt'
        setlocal spell

        " Fixes last spelling mistake
        inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
    endif
endfunction

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
