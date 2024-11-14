# -------------------------------------------------------
#
# @name libEnv
# @brief Functions to manipulate environment PATH-like variables
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
# string as with `ksl:contains()`. Here the string to look for
# must exactly match between the surrounding ":" markers.
#
# @arg $1 string the name of a path style variable.
# @arg $2 string the element to look for.
#
# @example
#     if ksl::envContains PATH "/usr/bin"; then
#         echo "Yes in PATH"
#     fi
#
# @exitcode 0 Success - was found
# @exitcode 1 not found, or missing args  <p><p>![](../images/pub/divider-line.png)
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
# @description Appends an element to a PATH-style variable.
#
# Appends $2, in-place, to the end of the PATH-style variable 
# named in $1, provided $2 is not already in there (options are 
# available to control this).
# 
# ksl::envAppend [options...] PATH_VARIABLE ELEMENT
#
# **Options**
#
# *   -a | --allow-dups
# *   -r | --reject-dups (default)
# *   -s | --add-as-string (default)
# *   -f | --file-must-exist
#
# **Option Descriptions**
#
# *   -a | --allow-dups: Adds to PATH_VARIABLE even if ELEMENT is already in there.
# *   -r | --reject-dups: (default) Don't add to PATH_VARIABLE if ELEMENT is already in there.
# *   -s | --add-as-string: (default) Adds ELEMENT to the
#          PATH_VARIABLE as a string - meaning do not check
#          whether ELEMENT exists as a file.
# *   -f | --file-must-exist: Adds ELEMENT, treated as a file/directory,
#          to the PATH_VARIABLE, but only if ELEMENT exists on the
#          file space.
#
# * If both -s and -f are given, last one wins.
# * If both -a and -r are given, last one wins.
#
# @arg $1 VariableName of a path style variable, such as `PATH`, with ":" separating individual elements.
# @arg $2 Element a string or directory or file name to append
#
# @example
#     # Update MANPATH only if $HOME/man is not already in there
#     ksl::envAppend MANPATH $HOME/man
#     #
#     # Update MANPATH only if $HOME/man is not in there and it exists on file space
#     ksl::envAppend -r -f MANPATH $HOME/man # MANPATH is updated if $HOME/man exists
#
# @exitcode 0 Success if element was appended
# @exitcode 1 Failed element was not appended  <p><p>![](../images/pub/divider-line.png)
#
ksl::envAppend()
{
    ksl::_envXxpend --append "$@"
}

# -----------------------------------------------------------
#
# @description Prepends $2, in-place, to the front of the PATH-style
# variable named in $1, provided $2 is not already in there (options are
# available to control this).
#
# Same args and description as [ksl::envAppend](#ksl-envappend). <p><p>![](../images/pub/divider-line.png)
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
# @description Deletes all occurrences of $2, in-place, from $1.
#
# $1 is the name of a path style variable with ":" separating 
# individual elements.
#
# @arg $1 string the name of a path style variable.
# @arg $2 string the element to delete.
#
# @example
#     ksl::envDelete MANPATH "$HOME/man"
#
# @exitcode 0 No error. Doesn't mean anything was deleted.
# @exitcode 1 Missing or empty args  <p><p>![](../images/pub/divider-line.png)
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
# @description Deletes 1st element, in-place, from $1 where $1 is the
# name of a path style variable with ":" separating individual elements.
#
# Returns 1 on an error otherwise 0.
#
# @arg $1 VariableName of a path style variable, such as `PATH`, with ":" separating individual elements.
#
# @example
#     ksl::envDeleteFirst MANPATH
#
# @exitcode 0 No error. Doesn't mean anything was deleted.
# @exitcode 1 Missing or empty args  <p><p>![](../images/pub/divider-line.png)
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
# @description Deletes last element, in-place, from $1 where $1 is the
# name of a path style variable with ":" separating individual elements.
#
# @arg $1 VariableName of a path style variable, such as `PATH`, with ":" separating individual elements.
#
# @example
#     ksl::envDeleteLast MANPATH
#
# @exitcode 0 No error. Doesn't mean anything was deleted.
# @exitcode 1 Missing or empty args  <p><p>![](../images/pub/divider-line.png)
#
ksl::envDeleteLast()
{
    [[ -z "$1" ]] && return 1      # Missing args
    local -n ref=$1
    [[ -z "$ref" ]] && return 1    # Empty environment var
    ref=${envSep}${ref}            # Add sentinel in case single frag
    
    # shellcheck disable=SC2295
    ref=${ref%${envSep}*}          # Delete last including separator
    # shellcheck disable=SC2295
    ref=${ref#${envSep}}           # Remove sentinel
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
#
# @description Use the given character as the separator
# between elements in a PATH-style variable.
#
# Initialized to ":" at startup. Stays in effect until changed.
#
# @arg $1 character the separator.
#
# @example
#     ksl::envSetSeparator ";"
#
# @exitcode 0 In all cases
#
ksl::envSetSeparator()
{
    envSep=$1
}

# -----------------------------------------------------------
