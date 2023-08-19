" ~/.vim/syntax/cal.vim
"Ajout a .vimrc:
"au BufRead,BufNewFile *.cal set filetype=cal
"syntax enable

if exists("b:current_syntax")
  finish
endif

"syn keyword calKeywords de avec
syn match calIdentifiant '[a-zA-Z_][a-zA-Z0-9_']*'
syn match calKeywords '\`[a-z]\+:'
syn match calString '"[^"]*"'
syn match calComment "^\s*#.*$"
syn match calNumber '\d\+\%(\.\d\+\)\?'
syn match calOperator '[%!.&?@+*/|-]\|\s:'
syn match calSpecialOperator '\\[a-zA-Z%&|&?@+*/=-]\|\'[%&|?@+*/-]'

" Fonctions définies avec la syntaxe `nom_fonction(argument) = quelque chose`
syn match calFunction '\w\+\s*([^)]*)\s*='

hi def link calKeywords Keyword
hi def link calString String
hi def link calComment Comment
hi def link calNumber Number
hi def link calOperator Operator
hi def link calSpecialOperator Special
hi def link calFunction Function
hi def link calIdentifiant Type

