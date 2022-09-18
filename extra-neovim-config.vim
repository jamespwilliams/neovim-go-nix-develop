" Insert your own config here...

filetype indent plugin on
syntax enable

packloadall

" Fix syntax highlighting in tmux:
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set t_Co=256

set termguicolors

set background=dark
colorscheme bat
