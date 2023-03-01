#!/usr/bin/bash

# This script is a workaround to compensate for `raco fmt`'s absence of standard output when it finds an error in the
# program it tries to format, which otherwise makes it difficult to use it as a standard filter program in editors or
# for pipeline composition. It works by simply outputting its input to standard out if `raco fmt` returns an error
# code. That is achieved by first redirecting standard input to a temporary file, which is then passed to `raco fmt`,
# and then, if the latter returned an error code, simply to `cat`.

# This script's command line arguments are passed to `raco fmt` without any control. It should be noted that using an
# explicit file as a command line argument does not really make sense in this case, since this script really is meant to
# pass the standard input to `raco fmt`. If a file is explicitly passed as a command line argument, the standard input
# will still be fetched, but it will then not be used. On the other hand, using e.g. `< filename.rkt` will work as
# expected, since that will be interpreted as standard input by the script.

# In order to avoid being more invasive than necessary, this script does not touch the standard error output. In
# particular, when `raco fmt` finds an error in the script it tries to format, it will as usual send its error message
# to standard error. If that is disturbing (this typically will if this script is used as an `equalprg` in Vim, for
# instance), simply use the `2>/dev/null` technique.

# The temporary file plumbing, minimizing the probability of not removing the file in case of signals: the idea is to
# create file descriptors that keep the file alive as long as it is used even after removal. Because we might read the
# file twice (once by `raco fmt`, one by `cat`, we create two read file descriptors).
tmpfile=$(mktemp)
exec {FD_W}>"$tmpfile"
exec {FD_R1}<"$tmpfile"
exec {FD_R2}<"$tmpfile"
rm "$tmpfile"

# Write standard input to the temporary file
cat >&$FD_W
# Send either `raco fmt` output, or, if unsuccessful, `cat` output, to standard out.
raco fmt $@ <&$FD_R1 || cat <&$FD_R2
