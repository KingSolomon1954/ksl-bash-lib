# -------------------------------------------------------
#
# @name libFiles
# @brief Functions to manipulate directory and file names.
#
# @description
# Functions to manipulate directory and file names.
#
# Contains the following:
#
#     * ksl::baseName()
#     * ksl::dirName()
#     * ksl::scriptName()
#     * ksl::scriptDir()
#     * ksl::suffix()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[[ -v libFilesImported ]] && [[ "$1" != "-f" ]] && return
libFilesImported=true

# -----------------------------------------------------------
#
# @description Returns the base name of the given file.
#
ksl::baseName ()
{
    local s="${1}"    
    s="${s%/}"
    echo -n "${s##*/}"
}

# -----------------------------------------------------------

ksl::dirName ()
{
    # Remove any trailing '/' that doesn't have anything following it (to
    # parallel the behavior of "dirname").
    #
    local tmp1=${1%/}

    # remove last level in path
    local tmp2=${tmp1%/*}

    # If there was nothing left after removing the last level in the path,
    # the path must be to something in the root directory, so the result
    # should just be the root directory. Otherwise, if there wasn't any last
    # level, the path must be to something in the current dir, so the result
    # should just be the current dir. Otherwise,
    #
    if [[ "${tmp2}" = "" ]]; then
        tmp2=/
    elif [[ "${tmp2}" = "${tmp1}" ]]; then
        tmp2=.
    fi

    echo -n "${tmp2}"
}

# -----------------------------------------------------------
#
# Returns the absolute path to the script itself
#
# Usage for this is primarily at script startup, for those
# occasions when a script needs to know the location
# of the script itself.
#
# Takes no args. Uses $0 from env
#
ksl::scriptDir()
{
    # Note that there is no promise that $0 will work in all cases.
    # Refer to web discussions regarding finding script location.
    echo -n "$(cd "$(ksl::dirName "$0")" && pwd)"
}

# -----------------------------------------------------------
#
# Returns the name of the script with suffix, if any.
#
# Usage for this is primarily at script startup, so that
# a script doesn't need to hard code in its name.
#
# $1 = supply $0 from outermost script context
# caller: echo $(scriptFile $0)
#
ksl::scriptName()
{
    echo -n "$(ksl::baseName "$0")"
}

# -----------------------------------------------------------
#
# Extract the file name suffix - the last '.' and following
# characters. This conforms to the Makefile $(suffix ...) command.
#
ksl::suffix()
{
    local path=${1}
    [[ $path != *\.* ]]    && echo '' && return   # no .'s anywhere
    [[ $path =~ ^\.\/+$ ]] && echo '' && return   # "./*" are not suffix
    
    local t=".${path##*.}"
    
    # After isolating the suffix, correct for bad input like
    # "/music/../beatles", which results in "./beatles" which 
    # of course is not a suffix. Easier to correct after.
    [[ $t =~ ^\.\/.*$ ]] && echo '' && return
    echo -n "$t"
}

# -----------------------------------------------------------


# fileTrimLeft 1 
# parent, ancestor, root, stem, name
# 
#  os.path.split(path)
# 
#     Split the pathname path into a pair, (head, tail) where tail is the
#     last pathname component and head is everything leading up to
#     that. The tail part will never contain a slash; if path ends in a
#     slash, tail will be empty. If there is no slash in path, head will
#     be empty. If path is empty, both head and tail are empty. Trailing
#     slashes are stripped from head unless it is the root (one or more
#     slashes only). In all cases, join(head, tail) returns a path to the
#     same location as path (but the strings may differ). Also see the
#     functions dirname() and basename().
