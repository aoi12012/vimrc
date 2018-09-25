" base setting
set nocompatible		                		" viとの互換性無効 タブ補完などが使えるようになる
syntax on			                     		" コードの色分けをON
"OSのクリップボードを使用する(vim --version | grep clipboardで+clipboardになっている場合)
set clipboard+=unnamed
set notitle				                       	" ウィンドウ:タイトルを変更しない
"set title		                			    " ウィンドウ:タイトルを設定する
set cmdheight=1                                 " ウィンドウ:コマンドラインの高さ
set laststatus=2                                " ウィンドウ:ステータスバーを表示する位置
set ruler                                       " ウィンドウ:ルーラの表示
set encoding=utf-8				                " ファイル:vimの文字コード
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8	" ファイル:ファイルの文字コード
set fileformats=unix,dos,mac		        	" ファイル:ファイルフォーマット
set nobackup				                	" ファイル:バックアップを作成しない
set noswapfile				                	" ファイル:スワップファイルを作成しない
set hlsearch				                	" サーチ:検索結果をハイライトする
set ignorecase				                	" サーチ:大文字小文字を区別しない
set smartcase				                	" サーチ:大文字で検索されたら対象を大文字限定にする
set nowrapscan				                	" サーチ:検索結果が行末まで行ったらとまる
"set wrapscan				                	" サーチ:検索結果が行末まで行ったら先頭に戻る
set showmatch				                	" カーソル:括弧にカーソルを合わせた時、対応する括弧を表示する
set matchtime=1				                	" カーソル：カーソルが飛ぶ時間を0.1秒で飛ぶようにする
set nostartofline			                	" カーソル：括弧を閉じたとき対応する括弧に一時的に移動
set backspace=start,eol,indent                  " カーソル：バックスペースで消せるようにする
set ttyfast					                    " ターミナル：ターミナル接続を高速にする
set t_Co=256				                	" ターミナル：ターミナルで256色表示を使う
set expandtab				                	" タブ:半角スペースに置き換える
set tabstop=4				                	" タブ:幅をスペース4つ分にする
set shiftwidth=4			                	" タブ:自動インデントの幅

augroup HighlightTrailingSpaces
    autocmd!
    autocmd VimEnter,WinEnter,ColorScheme * highlight TrailingSpaces term=underline guibg=Red ctermbg=Red
    autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
augroup END
"hi ZenkakuSpace cterm=underline ctermfg=lightblue ctermbg=white
"match ZenkakuSpace /　/

" ステータスバー関連
""""""""""""""""""""""""""""""""""""""""""""
" 自動文字数カウント
augroup WordCount
    autocmd!
    autocmd BufWinEnter,InsertLeave,CursorHold * call WordCount('char')
augroup END
let s:WordCountStr = ''
let s:WordCountDict = {'word': 2, 'char': 3, 'byte': 4}
function! WordCount(...)
    if a:0 == 0
        return s:WordCountStr
    endif
    let cidx = 3
    silent! let cidx = s:WordCountDict[a:1]
    let s:WordCountStr = ''
    let s:saved_status = v:statusmsg
    exec "silent normal! g\<c-g>"
    if v:statusmsg !~ '^--'
        let str = ''
        silent! let str = split(v:statusmsg, ';')[cidx]
        let cur = str2nr(matchstr(str, '\d\+'))
        let end = str2nr(matchstr(str, '\d\+\s*$'))
        if a:1 == 'char'
            " ここで(改行コード数*改行コードサイズ)を'g<C-g>'の文字数から引く
            let cr = &ff == 'dos' ? 2 : 1
            let cur -= cr * (line('.') - 1)
            let end -= cr * line('$')
        endif
        let s:WordCountStr = printf('%d/%d', cur, end)
    endif
    let v:statusmsg = s:saved_status
    return s:WordCountStr
endfunction

" 挿入モード時、ステータスラインの色を変更
let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=black ctermbg=lightred cterm=none'
if has('syntax')
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call s:StatusLine('Enter')
    autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif
let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
  endif
endfunction
function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction
if has('unix') && !has('gui_running')
  " ESC後にすぐ反映されない対策
"  inoremap <silent> <ESC> <ESC>
  " なぜか矢印キーが効かなくなるのでコメントアウト
endif

" ステータスバー設定
set statusline=%F                                                 " [ステータスバー]ファイル名表示
set statusline+=%m                                                " [ステータスバー]変更のチェック表示
set statusline+=%r                                                " [ステータスバー]読み込み専用かどうか表示
set statusline+=%h                                                " [ステータスバー]ヘルプページなら[HELP]と表示
set statusline+=%w\                                               " [ステータスバー]プレビューウインドウなら[Prevew]と表示
set statusline+=%=                                                " [ステータスバー]ここからツールバー右側
set statusline+=[FORMAT=%{&ff}]\                                  " [ステータスバー]ファイルフォーマット表示
set statusline+=[%{has('multi_byte')&&\&fileencoding!=''?&fileencoding:&encoding}] " [ステータスバー]文字コードの表示
set statusline+=[%l行,%v桁]                                       " [ステータスバー]列位置、行位置の表示
set statusline+=[%p%%]                                            " [ステータスバー]現在行が全体行の何%目か表示
set statusline+=[WC=%{exists('*WordCount')?WordCount():[]}]       " [ステータスバー]現在のファイルの文字数をカウント
""""""""""""""""""""""""""""""""""""""""""""
" ailias
inoremap <C-e> <Esc>$a
inoremap <C-a> <Esc>^a
noremap <C-e> <Esc>$a
noremap <C-a> <Esc>^a
noremap <Esc><Esc> :noh<CR>
