set guicursor=
autocmd OptionSet guicursor noautocmd set guicursor=

call plug#begin('~/.local/share/nvim/site/plugged')
    Plug 'tpope/vim-sensible'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-vinegar'
    Plug 'tpope/vim-sleuth'
    Plug 'mhinz/vim-startify'
    Plug 'itchyny/lightline.vim'
    Plug 'joshdick/onedark.vim'
    Plug 'ntpeters/vim-better-whitespace'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'kopischke/vim-fetch'
    Plug 'airblade/vim-gitgutter'
call plug#end()

set number
let g:lightline = {
    \'colorscheme' : 'onedark',
    \}

syntax on
colorscheme onedark

set splitbelow
set splitright

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

autocmd BufWritePre * :StripWhitespace
autocmd BufWritePost * :GitGutter

vnoremap < <gv
vnoremap > >gv
