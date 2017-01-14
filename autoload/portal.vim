" Make portals.
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

" Points for portals
let s:points = {}

let s:jump_tagets = {
\   'blue': 'orange',
\   'orange': 'blue',
\ }
let s:jump_colors = {
\   'blue': {
\     'guibg': 'Blue',
\     'guifg': 'Blue',
\     'ctermbg': 'Blue',
\     'ctermfg': 'Blue',
\   },
\   'orange': {
\     'guibg': 'Orange',
\     'guifg': 'Orange',
\     'ctermbg': 'Red',
\     'ctermfg': 'Red',
\   },
\ }

function! portal#shoot(color)
  let s:points[a:color] = s:getpos()
  call portal#show_all()
endfunction

function! portal#random_shoot()
  for color in keys(s:jump_colors)
    let line = s:rand(line('$')) + 1
    let col = s:rand(col([line, '$'])) + 1
    let s:points[color] = [bufnr('%'), line, col, 0]
  endfor
  call portal#show_all()
endfunction

function! portal#reset()
  let s:points = {}
  call portal#show_all()
endfunction

function! portal#_complete(lead, line, pos)
  return filter(keys(s:jump_tagets), 'v:val =~# "^" . a:lead')
endfunction

function! portal#jump()
  let cur_pos = s:getpos()
  for [color, pos] in items(s:points)
    if cur_pos == pos
      let target = get(s:jump_tagets, color, '')
      if has_key(s:points, target)
        let target_pos = get(s:points, target)
        if cur_pos[0] != target_pos[0]
          execute target_pos[0] 'buffer'
        endif
        call cursor(target_pos[1 :])
      endif
      break
    end
  endfor
endfunction

function! portal#show_all()
  let winnr = winnr()
  noautocmd keepjumps windo call portal#show()
  noautocmd keepjumps execute winnr 'wincmd w'
endfunction

function! portal#show()
  for m in filter(getmatches(), 'v:val.group =~# "^portal_"')
    silent! call matchdelete(m.id)
  endfor

  let buf = bufnr('%')
  for [color, pos] in items(s:points)
    if pos[0] == buf
      let pat = printf('\%%%dl\%%%dc', pos[1], pos[2])
      let id = matchadd('portal_' . color, pat)
    endif
  endfor
endfunction

function! portal#highlight()
  for [name, colors] in items(s:jump_colors)
    let args = join(map(items(colors), 'v:val[0] . "=" . v:val[1]'), ' ')
    execute printf('highlight portal_%s %s', name, args)
  endfor
endfunction

function! s:rand(n)
  let l:match_end = matchend(reltimestr(reltime()), '\d\+\.') + 1
  return reltimestr(reltime())[l:match_end : ] % (a:n + 1)
endfunction

function! s:getpos()
  let pos = getpos('.')
  let pos[0] = bufnr('%')
  return pos
endfunction

call portal#highlight()

let &cpo = s:save_cpo
unlet s:save_cpo
