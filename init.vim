source ~/.config/nvim/coc.vim

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
    Plug 'sonph/onehalf', { 'rtp': 'vim' }
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'ntpeters/vim-better-whitespace'
    Plug 'kopischke/vim-fetch'
    Plug 'airblade/vim-gitgutter'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'udalov/kotlin-vim'
call plug#end()

set number
let g:lightline = {
    \'colorscheme' : 'onehalfdark',
    \}

syntax on
colorscheme onehalfdark

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

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

""Bind the fzf :Files command to ctrl-p
nmap <C-P> :Files<CR>
