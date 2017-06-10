let SessionLoad = 1
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/PWR/PW2017/adaLang/zad3
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +0 core_manager.adb
badd +0 fault_coordinator.adb
badd +0 main.adb
badd +0 path_finder.adb
badd +0 repair_manager.adb
badd +0 repair_train.adb
badd +0 steering.adb
badd +0 test_suite.adb
badd +0 track.adb
badd +0 train.adb
badd +0 constants_and_types.ads
badd +0 core_manager.ads
badd +0 fault_coordinator.ads
badd +0 path_finder.ads
badd +0 repair_manager.ads
badd +0 repair_train.ads
badd +0 steering.ads
badd +0 track.ads
badd +0 train.ads
argglobal
silent! argdel *
argadd core_manager.adb
argadd fault_coordinator.adb
argadd main.adb
argadd path_finder.adb
argadd repair_manager.adb
argadd repair_train.adb
argadd steering.adb
argadd test_suite.adb
argadd track.adb
argadd train.adb
argadd constants_and_types.ads
argadd core_manager.ads
argadd fault_coordinator.ads
argadd path_finder.ads
argadd repair_manager.ads
argadd repair_train.ads
argadd steering.ads
argadd track.ads
argadd train.ads
edit core_manager.adb
set splitbelow splitright
wincmd t
set winminheight=1 winminwidth=1 winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
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
