vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

def comment#half#setup(dir: string): string #{{{1
    half_to_comment = dir
    &opfunc = 'comment#half#do'
    return 'g@l'
enddef

var half_to_comment: string
#}}}1
def comment#half#do(_a: any) #{{{1
    var half: string = half_to_comment
    var first_lnum: number = line("'{") + 1
    var last_lnum: number = line("'}") - 1
    if line("'{") == 1 && getline(1) =~ '\S'
        first_lnum = 1
    endif
    if line("'}") == line('$') && getline('$') =~ '\S'
        last_lnum = line('$')
    endif
    var diff: number = last_lnum - first_lnum + 1
    var lnum1: number
    var lnum2: number
    if half == 'top'
        [lnum1, lnum2] = [
            first_lnum,
            first_lnum + diff / 2 - (diff % 2 == 0 ? 1 : 0)
            ]
    else
        [lnum1, lnum2] = [last_lnum - diff / 2 + 1, last_lnum]
    endif
    exe ':' .. lnum1 .. ',' .. lnum2 .. 'CommentToggle'
    # position cursor on first/last line of the remaining uncommented block of lines
    cursor(half == 'top' ? lnum2 : lnum1, 1)
enddef

