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
#     * ksl::notSuffix()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[[ -v libFilesImported ]] && [[ "$1" != "-f" ]] && return
libFilesImported=true

# -----------------------------------------------------------
#
# @description Strip leading directory components from filename.
#
# Does not touch any suffixes.
#
# @arg $1 string the filename
#
# @example
#     ksl::baseName /music/beatles/yellow-submarine.flak
#     Output: yellow-submarine.flak
#
# @exitcode 1 error, missing args
# @exitcode 0 in all other cases
#
# @stdout the basename
# @stderr "baseName(): missing operand" <p><p>![](../images/pub/divider-line.png)
#
ksl::baseName ()
{
    [[ $# -eq 0 ]] && echo "baseName(): missing operand" 1>&2 && return 1

    # Cleanup all multiple slashes if any "//"
    local tmp1=$1
    doubles="//"
    while [[ "$tmp1" == *$doubles* ]]; do
        tmp1=${tmp1/\/\//\/}
    done
    
    # Remove any trailing '/' that doesn't have anything following it.
    tmp1=${tmp1%/}
    
    local s="$tmp1"    
    s="${s%/}"
    echo -n "${s##*/}"
}

# -----------------------------------------------------------
#
# @description Strip last component from filename.
#
# @arg $1 string the filename
#
# @example
#     ksl::dirName /music/beatles/yellow-submarine.flak
#     Output: /music/beatles
#
# @exitcode 1 error, missing args
# @exitcode 0 in all other cases
#
# @stdout the dirname
# @stderr "dirName(): missing operand" <p><p>![](../images/pub/divider-line.png)
#
ksl::dirName ()
{
    [[ $# -eq 0 ]] && echo "dirName(): missing operand" 1>&2 && return 1

    # Cleanup all multiple slashes if any "//"
    local tmp1=$1
    doubles="//"
    while [[ "$tmp1" == *$doubles* ]]; do
        tmp1=${tmp1/\/\//\/}
    done

    # Single slash special case
    [[ $tmp1 == '/' ]] && echo -n '/' && return 0
    
    # Remove any trailing '/' that doesn't have anything following it.
    tmp1=${tmp1%/}
    
    # if there are no slashes then current dir
    [[ ! $tmp1 =~ / ]] && echo -n '.' && return 0

    # OK now to remove last level in path
    local tmp2=${tmp1%/*}

    # If empty, we matched a leading / thus we must be root
    [[ $tmp2 == '' ]] && echo -n '/' && return 0

    # If nothing was removed then no slashes so must be current dir
    if [[ "${tmp2}" = "${tmp1}" ]]; then
        tmp2=.
    # else
        # what remains is the parent dir
    fi

    echo -n "${tmp2}"
}

# -----------------------------------------------------------
#
# @description Returns the absolute path to the script itself.
#
# Usage for this is primarily at script startup, for those
# occasions when a script needs to know the location
# of the script itself. This is just the dirname of $0.
#
# Takes no args. Uses $0 from env.
#
# @example
#     echo $(ksl::scriptDir)
#
# @stdout the path <p><p>![](../images/pub/divider-line.png)
#
ksl::scriptDir()
{
    # Note that there is no promise that $0 will work in all cases.
    # Refer to web discussions regarding finding script location.
    echo -n "$(cd "$(ksl::dirName "$0")" && pwd)"
}

# -----------------------------------------------------------
#
# @description Returns the name of the script with suffix.
#
# Usage for this is primarily at script startup, so that
# a script doesn't need to hard code in its name.
# This is just the basename of $0.
#
# Takes no args. Uses $0 from env.
#
# @example
#     echo $(ksl::scriptName)
#
# @stdout the script name <p><p>![](../images/pub/divider-line.png)
#
ksl::scriptName()
{
    echo -n "$(ksl::baseName "$0")"
}

# -----------------------------------------------------------
#
# @description Returns the file name suffix - the last '.' and
#              following characters.
#
# This conforms to the Makefile $(suffix ...) command.
#
# @arg $1 string the filename
#
# @example
#     ksl::suffix /home/elvis/bin/power.bash
#     Output: .bash
#
# @stdout the suffix <p><p>![](../images/pub/divider-line.png)
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
#
# @description Returns the file name wiithout any suffix.
#
# @arg $1 string the filename
#
# @example
#     ksl::suffix /home/elvis/bin/power.bash
#     Output: power
#
# @stdout the filename <p><p>![](../images/pub/divider-line.png)
#
ksl::notSuffix()
{
    local path=${1}
    path=$(ksl::baseName "${path}")
    echo -n "${path%.*}"
}

# -----------------------------------------------------------
