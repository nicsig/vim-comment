vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

def comment#object#main(op_is_c = false) #{{{1
    if &l:cms == ''
        return
    endif

    var l_: string
    var r_: string
    [l_, r_] = comment#util#getCml()
    var boundaries: list<number> = [line('.') + 1, line('.') - 1]

    #       ┌ 0 or 1:  upper or lower boundary
    #       │
    for  [which, dir, limit, next_line]
    in  [[0, -1, 1, getline('.')],
    [1, 1, line('$'), getline('.')]]

        var l: string
        var r: string
        [l, r] = getline('.')->comment#util#maybeTrimCml(l_, r_)
        while comment#util#isCommented(next_line, l, r)
            # stop if the boundary has reached the beginning/end of a fold
            var fmr: string = split(&l:fmr, ',')->join('\|')
            if match(next_line, fmr) >= 0
                break
            endif

            # the test was successful so (inc|dec)rement the boundary
            boundaries[which] = boundaries[which] + dir

            # update `line`, `l`, `r` before next test
            next_line = getline(boundaries[which] + dir)
            [l, r] = comment#util#maybeTrimCml(next_line, l_, r_)
        endwhile
    endfor

    var InvalidBoundaries: func = (): bool =>
           boundaries[0] < 1
        || boundaries[1] > line('$')
        || boundaries[0] > boundaries[1]

    if InvalidBoundaries()
        return
    endif

    #  ┌ we operate on the object with `c`
    #  │          ┌ OR the object doesn't end at the very end of the buffer
    #  │          │
    if op_is_c || boundaries[1] != line('$')
        # make sure there's no empty lines at the *start* of the object
        # by incrementing the upper boundary as long as necessary
        while getline(boundaries[0]) !~ '\S'
            boundaries[0] = boundaries[0] + 1
        endwhile
    endif

    if op_is_c
        # make sure there are no empty lines at the *end* of the object
        while getline(boundaries[1]) !~ '\S'
            boundaries[1] = boundaries[1] - 1
        endwhile
    endif

    if InvalidBoundaries()
        return
    endif

    # position the cursor on the 1st line of the object
    exe 'norm! ' .. boundaries[0] .. 'G'

    # select the object
    exe 'norm! ' .. (mode() =~ "[vV\<c-v>]" ? 'o' : 'V') .. boundaries[1] .. 'G'
enddef

