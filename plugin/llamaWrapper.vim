" Llama Vim Plugin
"
" Ensure Python3 is available
if !has('python3')
  echo "Python 3 support is required for Llama plugin"
  finish
endif

" Add Llama dependencies
python3 << EOF
import sys
import vim
import os
def safe_vim_eval(expression):
    try:
        return vim.eval(expression)
    except vim.error:
        return None

EOF
" Function to show Llama responses in a new buffer
function! DisplayResponse(response, finish_reason, session_id)
  call cursor('$', 1)

  let response = a:response
  let finish_reason = a:finish_reason

  let session_id = a:session_id

  if !bufexists(session_id)
    silent execute 'new '. session_id
    call setbufvar(session_id, '&buftype', 'nofile')
    call setbufvar(session_id, '&bufhidden', 'hide')
    call setbufvar(session_id, '&swapfile', 0)
    setlocal modifiable
    setlocal wrap
    call setbufvar(session_id, '&ft', 'markdown')
    call setbufvar(session_id, '&syntax', 'markdown')
  endif

  if bufwinnr(session_id) == -1
    execute 'split ' . session_id
  endif

  let last_lines = getbufline(session_id, '$')
  let last_line = empty(last_lines) ? '' : last_lines[-1]

  let new_lines = substitute(last_line . response, '\n', '\r\n\r', 'g')
  let lines = split(new_lines, '\n')

  let clean_lines = []
  for line in lines
    call add(clean_lines, substitute(line, '\r', '', 'g'))
  endfor

  call setbufline(session_id, '$', clean_lines)
  call cursor('$', 1)

  if finish_reason != ''
    wincmd p
  endif
endfunction

" Function to interact with Llama
function! Llama(prompt) abort
	let command = "bash run.sh " . a:prompt
	let output = system(command)
	echomsg output
	return output
endfunction

" Function to send highlighted code to Llama
function! SendHighlightedCodeToLlama(ask, context)
  " Save the current yank register
  let save_reg = @@
  let save_regtype = getregtype('@')

  let [line_start, col_start] = getpos("'<")[1:2]
  let [line_end, col_end] = getpos("'>")[1:2]

  " Yank the visually selected text into the unnamed register
  execute 'normal! ' . line_start . 'G' . col_start . '|v' . line_end . 'G' . col_end . '|y'

  " Send the yanked text to Llama
  let yanked_text = ''

  if (col_end - col_start > 0) || (line_end - line_start > 0)
    let yanked_text = '```' . "\n" . @@ . "\n" . '```'
  endif

  let prompt = a:context . ' ' . "\n" . yanked_text

  if a:ask == 'rewrite'
    let prompt = 'I have the following code snippet, can you rewrite it more idiomatically?' . "\n" . yanked_text . "\n"
    if len(a:context) > 0
      let prompt = 'I have the following code snippet, can you rewrite to' . a:context . '?' . "\n" . yanked_text . "\n"
    endif
  elseif a:ask == 'review'
    let prompt = 'I have the following code snippet, can you provide a code review for?' . "\n" . yanked_text . "\n"
  elseif a:ask == 'explain'
    let prompt = 'I have the following code snippet, can you explain it?' . "\n" . yanked_text
    if len(a:context) > 0
      let prompt = 'I have the following code snippet, can you explain, ' . a:context . '?' . "\n" . yanked_text
    endif
  elseif a:ask == 'test'
    let prompt = 'I have the following code snippet, can you write a test for it?' . "\n" . yanked_text
    if len(a:context) > 0
      let prompt = 'I have the following code snippet, can you write a test for it, ' . a:context . '?' . "\n" . yanked_text
    endif
  elseif a:ask == 'fix'
    let prompt = 'I have the following code snippet, it has an error I need you to fix:' . "\n" . yanked_text . "\n"
    if len(a:context) > 0
      let prompt = 'I have the following code snippet I would want you to fix, ' . a:context . ':' . "\n" . yanked_text . "\n"
    endif
  endif

  call Llama(prompt)

  " Restore the original yank register
  let @@ = save_reg
  call setreg('@', save_reg, save_regtype)
  let curpos = getcurpos()
  call setpos("'<", curpos)
  call setpos("'>", curpos)

endfunction
"
" Function to generate a commit message
function! GenerateCommitMessage()
  " Save the current position and yank register
  let save_cursor = getcurpos()
  let save_reg = @@
  let save_regtype = getregtype('@')

  " Yank the entire buffer into the unnamed register
  normal! ggVGy

  " Send the yanked text to Llama
  let yanked_text = @@
  let prompt = 'I have the following code changes, can you write a helpful commit message, including a short title?' . "\n" .  yanked_text

  call Llama(prompt)
endfunction

" Menu for Llama
function! s:LlamaMenuSink(id, choice)
  call popup_hide(a:id)
  let choices = {1:'Ask', 2:'rewrite', 3:'explain', 4:'test', 5:'review'}
  if a:choice > 0 && a:choice < 6
    call SendHighlightedCodeToLlama(choices[a:choice], input('Prompt > '))
  endif
endfunction

function! s:LlamaMenuFilter(id, key)
  if a:key == '1' || a:key == '2' || a:key == '3' || a:key == '4' || a:key == '5'
    call s:LlamaMenuSink(a:id, a:key)
  else " No shortcut, pass to generic filter
    return popup_filter_menu(a:id, a:key)
  endif
endfunction

function! LlamaMenu() range
  echo a:firstline. a:lastline
  call popup_menu([ '1. Ask', '2. Rewrite', '3. Explain', '4. Test', '5. Review', ], #{
        \ pos: 'topleft',
        \ line: 'cursor',
        \ col: 'cursor+2',
        \ title: ' Chat GPT ',
        \ highlight: 'question',
        \ borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ callback: function('s:LlamaMenuSink'),
        \ border: [],
        \ cursorline: 1,
        \ padding: [0,1,0,1],
        \ filter: function('s:LlamaMenuFilter'),
        \ mapping: 0,
        \ })
endfunction

" Expose mappings
vnoremap <silent> <Plug>(chatgpt-menu) :call LlamaMenu()<CR>

" Commands to interact with Llama
command! -range -nargs=? Ask call SendHighlightedCodeToLlama('Ask',<q-args>)
command! -range -nargs=? Explain call SendHighlightedCodeToLlama('explain', <q-args>)
command! -range Review call SendHighlightedCodeToLlama('review', '')
command! -range -nargs=? Rewrite call SendHighlightedCodeToLlama('rewrite', <q-args>)
command! -range -nargs=? Test call SendHighlightedCodeToLlama('test',<q-args>)
command! -range -nargs=? Fix call SendHighlightedCodeToLlama('fix', <q-args>)

command! GenerateCommit call GenerateCommitMessage()

