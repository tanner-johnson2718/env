set ts=4 sw=4
colorscheme slate
set nu rnu
set autoindent
set smartindent
set hlsearch
set incsearch
set hidden
hi myFuncGroup ctermfg=192
hi Include ctermfg=170
hi PreProc ctermfg=170
hi String ctermfg=179
hi Type ctermfg=68
hi Statement ctermfg=170
hi myMacroGroup ctermfg=68
hi Constant ctermfg=46
hi Comment ctermfg=113
hi Pmenu ctermbg=241 ctermfg=251

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
nmap <C-Right> e
map <C-Up> {
map <C-Down> }
map <C-e> $
map <C-b> 0

" Quick Buffer Switches and Closing
nmap <C-PageDown> :bprev<CR>
nmap <C-PageUp> :bnext<CR>
nmap <C-x> :bd<CR>

" In normal mode make enter go into insert mode
nmap <CR> i<right>

" Copy to system clipboard w/ enter
vmap c "+y
vmap x "+d

" Clear Search Highlighting
nmap <C-c> :noh<CR>

" Copy and Paste doesnt create a bunch of random indents
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
	set pastetoggle=<Esc>[201~
	set paste
	return ""
endfunction


" YCM Plug in
packadd YouCompleteMe
nmap <C-l> :YcmCompleter GoToDeclaration<CR>
nmap <C-f> <S-*>
