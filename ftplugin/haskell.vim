" vim: sts=2 sw=2
"
" Haskell customizations.

" Indentation.
setlocal shiftwidth=2
setlocal softtabstop=2

" Run ghc as the syntax checker
set makeprg=stack\ exec\ --\ ghc\ -fno-code\ %\ -i%:h\ -Wall
set efm=%E%f:%l:%c:\ error:
set efm+=%W%f:%l:%c:\ warning:\ %m
set efm+=%C%m
set efm+=%-G\\s%#
set efm+=%-G%.%#\ Compiling\ %.%#

" Format code with brittany.
set formatprg=stack\ exec\ brittany
