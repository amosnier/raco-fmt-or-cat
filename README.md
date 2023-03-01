# raco-fmt-or-cat
Workaround for `raco fmt` not outputting input on error.

See comments in .sh file.

See
[.vimrc](https://github.com/amosnier/vim-config/blob/master/.vimrc#L207)
for examples of use.

Example on the command line:

    $ raco-fmt-or-cat.sh < test.rkt 2>/dev/null
