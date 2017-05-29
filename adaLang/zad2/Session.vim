let SessionLoad = 1
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/PWR/PW2017/adaLang/zad2
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +8 fault.adb
badd +25 main.adb
badd +5 repair.adb
badd +7 steering.adb
badd +1 track.adb
badd +1 train.adb
badd +1 fault.ads
badd +7 repair.ads
badd +6 steering.ads
badd +13 track.ads
badd +1 train.ads
badd +4 repair_train.ads
badd +2 repair_train.adb
argglobal
silent! argdel *
argadd fault.adb
argadd main.adb
argadd repair.adb
argadd steering.adb
argadd track.adb
argadd train.adb
argadd fault.ads
argadd repair.ads
argadd steering.ads
argadd track.ads
argadd train.ads
edit repair_train.adb
set splitbelow splitright
wincmd t
set winminheight=1 winminwidth=1 winheight=1 winwidth=1
argglobal
edit repair_train.adb
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 11 - ((10 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
11
normal! 049|
lcd ~/PWR/PW2017/adaLang/zad2
tabnext 1
if exists('s:wipebuf') && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 winminheight=1 winminwidth=1 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
