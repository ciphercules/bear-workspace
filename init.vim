" Force cursor to be block always.
set guicursor=
autocmd OptionSet guicursor noautocmd set guicursor=

" Define conditional loading function
function! Cond(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

" Keep visual block selected when shifting.
vnoremap < <gv
vnoremap > >gv

" Show line numbers.
set number

" Initialize plugins.
call plug#begin('~/.local/share/nvim/site/plugged')
    " Shared plugins.
    Plug 'tpope/vim-sensible'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-sleuth'
    Plug 'ntpeters/vim-better-whitespace'
    " Neovim specific plugins.
    Plug 'tpope/vim-vinegar', Cond(!exists('g:vscode'))
    Plug 'tpope/vim-commentary', Cond(!exists('g:vscode'))
    Plug 'mhinz/vim-startify', Cond(!exists('g:vscode'))
    Plug 'itchyny/lightline.vim', Cond(!exists('g:vscode'))
    Plug 'sonph/onehalf', Cond(!exists('g:vscode'), { 'rtp': 'vim' })
    Plug 'neoclide/coc.nvim', Cond(!exists('g:vscode'), {'branch': 'release'})
    Plug 'kopischke/vim-fetch', Cond(!exists('g:vscode'))
    Plug 'airblade/vim-gitgutter', Cond(!exists('g:vscode'))
    Plug 'junegunn/fzf', Cond(!exists('g:vscode'), { 'do': { -> fzf#install() } })
    Plug 'junegunn/fzf.vim', Cond(!exists('g:vscode'))
    Plug 'udalov/kotlin-vim', Cond(!exists('g:vscode'))
call plug#end()

if !exists('g:vscode')
    source ~/.config/nvim/coc.vim

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

    if exists('+termguicolors')
      let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
      let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
      set termguicolors
    endif

    ""Bind the fzf :Files command to ctrl-p
    nmap <C-P> :Files<CR>
endif
