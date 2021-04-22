call plug#begin("~/.config/nvim/plugged")
Plug 'gyim/vim-boxdraw'
Plug 'tpope/vim-fugitive'
Plug 'machakann/vim-sandwich'
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'nvim-lua/completion-nvim'
Plug 'dart-lang/dart-vim-plugin'
Plug 'morhetz/gruvbox'
Plug 'dhruvasagar/vim-table-mode'
Plug 'alvan/vim-closetag'

Plug 'neovim/nvim-lspconfig'
Plug 'RishabhRD/popfix'
Plug 'RishabhRD/nvim-lsputils'

" Snippets
Plug 'SirVer/ultisnips'

" Git (mostly for merging)
Plug 'tpope/vim-fugitive'

" LaTeX
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
call plug#end()

map <Space> <Nop>
let mapleader="\<space>"

set modeline

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

tnoremap <Esc> <C-\><C-n>

set clipboard+=unnamedplus

color gruvbox

lua << EOF
 require('lspconfig').pyls.setup{
    on_attach=require'completion'.on_attach;
 }
 require('lspconfig').hls.setup{
    on_attach=require'completion'.on_attach;
    filetypes={'haskell'};
 }
 require('lspconfig').clangd.setup{
    on_attach=require'completion'.on_attach;
 }
 require('lspconfig').rust_analyzer.setup{
    on_attach=require'completion'.on_attach;
 }
 require('lspconfig').tsserver.setup{
    on_attach=require'completion'.on_attach;
 }
 require('lspconfig').dartls.setup{
    on_attach=require'completion'.on_attach;
 }

 vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
 vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler
 vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
 vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
 vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
 vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
 vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
 vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler
EOF


augroup gdbgroup 
    autocmd Filetype c,cpp,rs packadd termdebug
augroup END

augroup complete_group
    autocmd Filetype rs,cpp,c,py,ts,hs inoremap <expr> <Tab>    pumvisible() ? "\<C-n>" : "\<Tab>"
    autocmd Filetype rs,cpp,c,py,ts.hs inoremap <expr> <S-Tab>  pumvisible() ? "\<C-p>" : "\<S-Tab>"
augroup END

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
nnoremap C    <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <F3> <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

let g:UltiSnipsSnippetDirectories=["UltiSnips"]
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>" 
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Spell checking
autocmd FileType text,md,markdown call SpellChecking()

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

" LaTeX
let g:livepreview_previewer = "zathura"
