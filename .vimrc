set ts=4 sw=4
colorscheme slate
set relativenumber
set autoindent
set smartindent
set hlsearch
set incsearch
hi myFuncGroup ctermfg=192
hi Include ctermfg=170
hi PreProc ctermfg=170
hi String ctermfg=179
hi Type ctermfg=68
hi Statement ctermfg=170
hi myMacroGroup ctermfg=68
hi Constant ctermfg=46
hi Comment ctermfg=113

" Undo
nmap <c-z> <c-o>:u<CR>
 
" Save
nmap <c-s> :w<CR>

" Make sure our Control + arrows are mapped to the proper esacape sequence
map <ESC>[1;5D <C-left>
map <ESC>[1;5C <C-Right>
map <ESC>[1;5A <C-Up>
map <ESC>[1;5B <C-Down>
map <ESC>[6;5~ <C-PageDown>
map <ESC>[5;5~ <C-PageUp>

" Normal mode map word and paragraph jumps
nmap <C-Left> b
nmap <C-Right> w
map <C-Up> {
map <C-Down> }

" Quick Buffer Switches and Closing
nmap <C-PageDown> :bprev<CR>
nmap <C-PageUp> :bnext<CR>
nmap <C-x> :bd<CR>

" In normal mode make enter go into insert mode
nmap <CR> i

" Copy to system clipboard w/ enter
vmap <CR> "+y

" Clear Search Highlighting
nmap <C-c> :noh<CR>
