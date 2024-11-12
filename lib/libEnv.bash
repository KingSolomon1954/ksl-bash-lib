# -------------------------------------------------------
#
# @name libEnv
# @brief Functions to manipulate environment PATH like variables
#
# @description
#
# Functions to manipulate shell environment PATH like variables with
# entries normally separated by ":" such as `MANPATH` and `PATH` itself.
#
# Often these variables contain directory paths but they don't have to,
# for example `HISTCONTROL`. Between each path element is a separator
# character, normally a colon ":" but this can be changed by setting
# `evpSep`.
#
# Contains the following:
#
#     * ksl::envContains()
#     * ksl::envAppend()
#     * ksl::envPrepend()
#     * ksl::envDelete()
#     * ksl::envDeleteFirst()
#     * ksl::envDeleteLast()
#     * ksl::envSetSeparator()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source ksl::libStdOut -f"
#
[[ -v libEnvImported ]] && [[ "$1" != "-f" ]] && return
libEnvImported=true

envSep=":"

# -----------------------------------------------------------
#
# @description True if path style variable $1 contains the string in $2.
#
# This is slightly different than just looking for a contained
# string as with ksl:contains(). Here the string to look for
# must exactly match between the surrounding ":" markers.
#
# Returns 0 (success) if found otherwise 1 (not found).
# $1 is the name of a path style variable and passed by value.
# $2 is the element to look for.
#
# Example:
#     if ksl::envContains PATH "/usr/bin"; then
#         echo "Yes in PATH"
#     fi
#
ksl::envContains()
{
    [[ $# -lt 2 ]] && return 1      # Need two args

    [[ -z "$1" ]] && return 1       # Empty arg
    [[ "$1" =~ "\W" ]] && return 1  # Name of env var must be a word
    
    local -rn ref="$1"
    [[ -z "$ref" ]] && return 1     # Empty env var

    [[ -z "$2" ]] && return 1       # Empty element arg
    element=${2//:}                 # Remove any colons
    
    local pat="^${element}${envSep}"         # Front
    [[ ${ref} =~ ${pat} ]] && return 0       # Found it

    pat="${envSep}${element}${envSep}"       # Middle
    [[ ${ref} =~ ${pat} ]] && return 0       # Found it

    pat="${envSep}${element}$"               # End
    [[ ${ref} =~ ${pat} ]] && return 0       # Found it

    local pat="^${element}$"                 # Only entry
    [[ ${ref} =~ ${pat} ]] && return 0       # Found it
}

# -----------------------------------------------------------
#
# Add $2 <element>, in-place, to the end of $1 <path variable>, 
# provided <element> is not already in the <path variable>. 
# The <path variable> is the name of a path style variable, 
# such as PATH, with ":" separating individual elements.
#
#     Example: ksl::envAppend MANPATH $HOME/man
#     Example: ksl::envAppend -r -f MANPATH $HOME/man
#
# SYNOPSIS
#     ksl::envAppend [options] PATH_VARIABLE ELEMENT
#
# OPTIONS
#     -a|-allow-dups
#     -r|-reject-dups (default)
#     -s|-add-as-string (default)
#     -f|-file-must-exist
#
# OPTIONS DESCRIPTION
#    -a | -allow-dups: Add to PATH_VARIABLE even if
#        ELEMENT is already in there. 
#    -r | -reject-dups: (default) Don't add to
#        PATH_VARIABLE if ELEMENT is already in there.
#    -s | -add-as-string: (default) Add ELEMENT to the
#        PATH_VARIABLE as a string, subject to duplicates setting.
#    -f | -file-must-exist: Add ELEMENT, treated as a file/directory,
#        to the PATH_VARIABLE, but only if ELEMENT already exists
#        on the file space, subject to the duplicates setting.
#
#       If both -s and -f are given, last one wins.
#       If both -a and -r are given, last one wins.
#
# Returns true if element was appended, otherwise false.
#
# -----------------------------------------------------------

ksl::envAppend()
{
    ksl::_envXxpend --append "$@"
}

# -----------------------------------------------------------
#
# Add $2 <element>, in-place, to the front of $1 <path variable>, 
# provided <element> is not already in the <path variable>. 
# The <path variable> is the name of a path style variable, 
# such as PATH, with ":" separating individual elements.
#
# Takes exact same args and description as envAppend above.
#
ksl::envPrepend()
{
    ksl::_envXxpend --prepend "$@"
}

# -----------------------------------------------------------
#
# Shared function between envAppend and envPrepend to extract function
# arguments and perform the processing.  There is only one line
# difference between appending and prepending.
#
ksl::_envXxpend()
{
    local allowDups=false
    local mustExist=false
    local append=true
    local args=
    local -i argCount=0
    while [[ $# -ne 0 ]]; do
        case $1 in
            -a|--allow-dups)      allowDups=true;;
            -r|--reject-dups)     allowDups=false;;
            -s|--add-as-string)   mustExist=false;;
            -f|--file-must-exist) mustExist=true;;
            --append)             append=true;;
            --prepend)            append=false;;
            '') ;;
            -*) echo "Invalid option \"$1\" for envAppend() or envPrepend()" 1>&2
                return 1;;
            *) local val=${1//${envSep}/}  # strip any leading/trailing ":"
                if [[ -n "${args}" ]]; then
                   args="${args}${envSep}${val}"; (( argCount++ ))
               else
                   args="${val}"; (( argCount++ ))
               fi ;;
        esac
        shift
    done

    # Must have the two required args (PATH_VARIABLE and ELEMENT)
    if [[ ${argCount} -lt 2 ]]; then
        echo -n "ksl::envXxpend(): requires two arguments, " 1>&2
        echo    "got only ${argCount}: \"${args}\"" 1>&2
        return 1
    fi
    
    local varName=${args%%:*}
    local element=${args##*:}
    
    # echo "allowDups: ${allowDups}"
    # echo "mustExist: ${mustExist}"
    # echo "     args: ${args}"
    # echo "  varName: ${varName}"
    # echo "  element: ${element}"
    
    [[ -z "${varName}" ]] || [[ -z "${element}" ]] && return 1 # missing args

    if ! ${allowDups}; then
        if ksl::envContains "${varName}" "${element}"; then
            return 1;
        fi
    fi

    if ${mustExist}; then
        [[ ! -f "${element}" ]] && [[ ! -d "${element}" ]] && return 1
    fi

    local -n ref="${varName}"
    if ${append}; then
        ref="${ref}${envSep}${element}"
    else
        ref="${element}${envSep}${ref}"
    fi
    ksl::_envColonTrimPath "${varName}"
    return 0
}

# -----------------------------------------------------------
#
# Delete all occurrence of $1, in-place, from $2. $2 is the name of a
# path style variable with ":" separating individual elements.
#
# Example: ksl::envDelete MANPATH "$HOME/man"
#
ksl::envDelete()
{
    [[ -z "$1" ]] || [[ -z "$2" ]] && return 1 # no args, nothing appended
    local -n ref=$1

    local match="$2"            # If $2 has colons, it screws up the sub
    match=${match#"${envSep}"}  # Clean up leading colon if there
    match=${match%"${envSep}"}  # Clean up trailing colon if there

    ref="${ref//${match}/}"     # Sub it out
    ksl::_envColonTrimPath "$1"
}

# -----------------------------------------------------------
#
# Delete 1st element, in-place, from $1 where $1 is the name of
# a path style variable with ":" separating individual elements.
# Returns 1 on an error otherwise 0.
#
# Example: ksl::envDeleteFirst MANPATH
#
ksl::envDeleteFirst()
{
    [[ -z "$1" ]] && return 1    # Missing args
    local -n ref="$1"
    [[ -z "$ref" ]] && return 1  # Empty environment var

    ref=${ref}${envSep}          # Add sentinel in case single frag

    # shellcheck disable=SC2295
    ref=${ref#*${envSep}}        # Delete first including separator
    # shellcheck disable=SC2295
    ref=${ref%${envSep}}         # Remove sentinel
    return 0
}

# -----------------------------------------------------------
#
# Delete last element, in-place, from $1, where $1 is the name of 
# a path style variable with ":" separating individual elements.
# Returns 1 on an error otherwise 0.
#
# Example: ksl::envDeleteLast MANPATH
#
ksl::envDeleteLast()
{
    [[ -z "$1" ]] && return 1      # Missing args
    local -n ref=$1
    [[ -z "$ref" ]] && return 1    # Empty environment var
    ref=${envSep}${ref}          # Add sentinel in case single frag
    
    # shellcheck disable=SC2295
    ref=${ref%${envSep}*}        # Delete last including separator
    # shellcheck disable=SC2295
    ref=${ref#${envSep}}         # Remove sentinel
    return 0
}

# -----------------------------------------------------------

ksl::_envColonTrimPath ()
{
    local -n ref=${1}
    ref=${ref//${envSep}${envSep}/${envSep}}  # Clean up double colons
    # shellcheck disable=SC2295
    ref=${ref#${envSep}}                      # Clean up first colon
    # shellcheck disable=SC2295
    ref=${ref%${envSep}}                      # Clean up trailing colon
}

# -----------------------------------------------------------

ksl::envSetSeparator()
{
    envSep=$1
}

# -----------------------------------------------------------
