# -----------------------------------------------------------
#
# @name libError
# @brief Functions to support error passing
#
# @description
# Error passing is a technique where lower layer functions
# set values in an error passing structure, and higher layer
# functions up along the call tree add more context and detail
# to form strong diagnostics.
#
# `epSet()` is meant to be called at the lowest level of a call tree.
# Generally the leaf most function does the `epSet()`. Each parent
# function up along the call chain tests for a returned fail condition,
# testing either the child function return code or checking the **error
# passing structure (EPS)** itself using `epHasError()`. The parent then
# contributes to the error passing structure by appending, prepending,
# and setting additional fields to provide improved context and
# diagnostics to its caller. At the level in the program where the error
# can be analyzed for severity, corrective action is taken and the EPS is
# usually printed or logged.
#
# See [Error Passing Example](../shdoc/example-error-pass.bash) which is
# runnable. Output from a run:
#
# ![](../images/pub/errpass-example-output.png)
#
# Contains the following:
#
# **Lifecycle**
#
#     * epSet()
#
# **Modifiers**
#
#     * epPrepend()
#     * epAppend()
#     * epSetErrorName()
#     * epSetErrorType()
#     * epSetDescription()
#     * epSetSeverity()
#     * epSetProbableCause()
#     * epSetProposedRepair()
#     * epSetFileName()
#     * epSetFuncName()
#     * epSetLineNum()
#     * epSetCodeNum()
#
# **Observers**
#
#     * epErrorName()
#     * epErrorType()
#     * epSeverity()
#     * epFileName()
#     * epFuncName()
#     * epLineNum()
#     * epCodeNum()
#     * epFullDesc()
#     * epDescription()
#     * epProbableCause()
#     * epProposedRepair()
#     * epTimestamp()
#     * epHasError()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[[ -v libErrorImported ]] && [[ "$1" != "-f" ]] && return
libErrorImported=true

source "${KSL_BASH_LIB}"/libArrays.bash
source "${KSL_BASH_LIB}"/libColors.bash

# -------------------------------------------------------
#
# @description Initialize and set values in an error passing structure.
#
# epSet [eps] [options...]
#
# **Options**
#
# *   -ca, --cause \<string\>
# *   -cn, --codeNum \<number\>
# *    -d, --description \<string\>
# *   -en, --errorName \<string\>
# *   -et, --errorType \<string\>
# *   -fi, --fileName \<string\>
# *   -fu, --funcName \<string\>
# *   -li, --lineNum \<number\>
# *   -rp, --repair \<string\>
# *   -sv, --severity \<string\>
#
# With no args, epSet works on the default `ep1` **error passing structure
# (EPS)**. You can pass in `ep1` explicitly or create your own EPS. If the
# given EPS does not already exist, then it is created.
#
# These two are equivalent: `epSet` and `epSet ep1`.
# Or supply your own: `epSet myEp`.
#
# Each call to `epSet()` initalizes all fields to empty values
# with the timestamp set to current time, followed by setting any
# supplied options. Most options are strings so they will need to be
# in double quotes if they have embedded spaces.
#
# @example
#     echo ksl::epSet                # ep1 is initalized
#     echo ksl::epSet ep2            # ep2 is initalized
#     echo ksl::epSet --fi /home/abc # ep1 is initalized and file name is set
#
# @arg $1 array is the EPS. If not specified then EPS is `ep1`  <p><p>![](../images/pub/divider-line.png)
#
ksl::epSet()
{
    local eps
    local cause=""
    local codeNum=""
    local description=""
    local errorName=""
    local errorType=""
    local fileName=""
    local funcName=""
    local lineNum=""
    local repair=""
    local severity=""

    while [[ $# -gt 0 ]]; do
        case $1 in
        -d|--description)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            description="$2"
            shift;;
        -fi|--fileName)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            fileName="$2"
            shift;;
        -fu|--funcName)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            funcName="$2"
            shift;;
        -li|--lineNum)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            lineNum="$2"
            shift;;
        -sv|--severity)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            severity="$2"
            shift;;
        -en|--errorName)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            errorName="$2"
            shift;;
        -et|--errorType)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            errorType="$2"
            shift;;
        -cn|--codeNum)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            codeNum="$2"
            shift;;
        -ca|--cause)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            cause="$2"
            shift;;
        -rp|--repair)
            if [[ $# -lt 2 ]]; then
                echo "epSet(): No argument specified along with \"$1\" option." >&2
                return 1
            fi
            repair="$2"
            shift;;
        -*)
            echo "epSet(): Invalid option \"$1\"". >&2
            return 1;;
        "") ;;  # Ignore empty arg
        *) eps="$1" ;;
        esac
        shift
    done

    declare -A -g "${eps:=ep1}"

    ksl::arraySetValue "$eps" CAUSE     "$cause"
    ksl::arraySetValue "$eps" CODENUM   "$codeNum"
    ksl::arraySetValue "$eps" DESC      "$description"
    ksl::arraySetValue "$eps" ERRNAME   "$errorName"
    ksl::arraySetValue "$eps" ERRTYPE   "$errorType"
    ksl::arraySetValue "$eps" FILE      "$fileName"
    ksl::arraySetValue "$eps" FUNC      "$funcName"
    ksl::arraySetValue "$eps" LINENUM   "$lineNum"
    ksl::arraySetValue "$eps" REPAIR    "$repair"
    ksl::arraySetValue "$eps" SEVERITY  "$severity"
    ksl::arraySetValue "$eps" TIMESTAMP "$(date --rfc-3339=ns)"
}

# -------------------------------------------------------
#
# @description Sets the description field in the given EPS.
#
# Overwrites any previous description. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the description.
# If one arg is given, then $1 is the description and EPS `ep1` is used.
#
# @arg $1 array is either the EPS or the description depending on number of args as described above.
# @arg $2 string is the description if two args are given.
#
# @exitcode 0 Success - description was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetDescription "Broken channel"      # ep1 is used
#     ksl::epSetDescription ep2 "Broken channel"  # ep2 is used
#     ksl::epSetDescription ""                    # sets ep1 description to empty
#     ksl::epSetDescription                       # error
#
# @stderr epSetDescription() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetDescription()
{
    local eps
    local description

    [[ $# -eq 0 ]] && echo "epSetDescription() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && description="$1"
    [[ $# -eq 2 ]] && eps="$1" && description="$2"
    ksl::arraySetValue "${eps:-ep1}" DESC "${description}"
}

# -------------------------------------------------------
#
# @description Retrieve the description.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epDescription               # ep1 is used
#     echo $(ksl::epDescription ep2)   # ep2 is used
#     str=$(ksl::epDescription ep2)    # ep2 is used
#
# @stdout the description
# @stderr arrayGetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epDescription()
{
    ksl::arrayGetValue "${1:-ep1}" DESC
}

# -------------------------------------------------------
#
# @description Appends given string to the description in the given EPS.
#
# EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the string to
# append. If one arg is given, then $1 is the string to append and EPS
# `ep1` is used.
#
# @arg $1 array is either the EPS or the string to append depending on number of args as described above.
# @arg $2 string is the string to append if two args are given.
#
# @exitcode 0 Success - string was appended.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epAppend "Broken channel"        # ep1 is used
#     ksl::epAppend ep2 "Broken channel"    # ep2 is used
#     ksl::epAppend ""                      # append empty string to ep1
#     ksl::epAppend                         # error
#
# @stderr epAppend() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epAppend()
{
    local eps
    local str

    [[ $# -eq 0 ]] && echo "epAppend() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && str="$1";
    [[ $# -eq 2 ]] && eps="$1" && str="$2"
    ! ksl::arrayExists "${eps:=ep1}" && return 1
    eval "${eps}[DESC]+=\$str"
}

# -------------------------------------------------------
#
# @description Prepends given string to the description in the given EPS.
#
# EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the string to
# prepend. If one arg is given, then $1 is the string to prepend
# and EPS `ep1` is used.
#
# @arg $1 array is either the EPS or the string to prepend depending on number of args as described above.
# @arg $2 string is the string to prepend if two args are given.
#
# @exitcode 0 Success - string was prepended.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epPrepend "Broken channel"        # ep1 is used
#     ksl::epPrepend ep2 "Broken channel"    # ep2 is used
#     ksl::epPrepend ""                      # prepend empty string to ep1
#     ksl::epPrepend                         # error
#
# @stderr epPrepend() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epPrepend()
{
    local eps
    local str

    [[ $# -eq 0 ]] && echo "epPrepend() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && str="$1";
    # shellcheck disable=SC2034
    [[ $# -eq 2 ]] && eps="$1" && str="$2"
    ! ksl::arrayExists "${eps:=ep1}" && return 1

    eval "${eps}[DESC]=\$str\${${eps}[DESC]}"
}

# -------------------------------------------------------
#
# @description Sets the error name in the given EPS.
#
# Overwrites any previous error name. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the error name.
# If one arg is given, then $1 is the error name and EPS `ep1` is used.
#
# **Choices for ErrorName**
#
#     * CaughtException
#     * ConfigurationError
#     * DataFormatError
#     * AlreadyExistsError
#     * IllegalStateError
#     * InputOutputError
#     * InvalidAccessError
#     * InvalidArgumentError
#     * LengthError
#     * LogicError
#     * NetworkError
#     * NoPermissionError
#     * NotFoundError
#     * NotImplementedError
#     * NullPointerError
#     * NullValueError
#     * OperationNotPossibleError
#     * OverflowError
#     * RangeError
#     * SignalError
#     * SystemCallError
#     * TimeoutError
#     * UnderflowError
#
# @arg $1 array is either the EPS or the error name depending on number of args as described above.
# @arg $2 string is the error name if two args are given.
#
# @exitcode 0 Success - error name was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# Examples:
#     ksl::epSetErrorName "OverflowError"      # ep1 is used
#     ksl::epSetErrorName ep2 "OverflowError"  # ep2 is used
#     ksl::epSetErrorName  ""                  # sets ep1 error name to empty
#     ksl::epSetErrorName                      # no error
#
# @stderr epSetErrorName() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetErrorName()
{
    local eps
    local errName

    [[ $# -eq 0 ]] && echo "epSetErrorName() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && errName="$1"
    [[ $# -eq 2 ]] && eps="$1" && errName="$2"
    ksl::arraySetValue "${eps:-ep1}" ERRNAME "${errName}"
}

# -------------------------------------------------------
#
# @description Returns the error name in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epErrorName               # ep1 is used
#     echo $(ksl::epErrorName ep2)   # ep2 is used
#     str=$(ksl::epErrorName ep2)    # ep2 is used
#
# @stdout the error name
# @stderr arrayGetValue() no such array
# @see [Choices for ErrorName](#ksl-epseterrorname)  <p><p>![](../images/pub/divider-line.png)
#
ksl::epErrorName()
{
    ksl::arrayGetValue "${1:-ep1}" ERRNAME
}

# -------------------------------------------------------
#
# @description Sets the error type in the given EPS.
#
# Overwrites any previous error type. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the error type.
# If one arg is given, then $1 is the error type and EPS `ep1` is used.
#
# **Choices for ErrorType**
#
#     * CommunicationsError
#     * ConfigurationError
#     * EnvironmentalError
#     * EquipmentError
#     * ProcessingError
#     * QualityOfServiceError
#
# @arg $1 array is either the EPS or the error type depending on number of args as described above.
# @arg $2 string is the error type if two args are given.
#
# @exitcode 0 Success - description was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetErrorType "ProcessingError"      # ep1 is used
#     ksl::epSetErrorType ep2 "ProcessingError"  # ep2 is used
#     ksl::epSetErrorType  ""                    # sets ep1 error type to empty
#     ksl::epSetErrorType                        # error
#
# @stderr epSetErrorType() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetErrorType()
{
    local eps
    local errType

    [[ $# -eq 0 ]] && echo "epSetErrorType() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && errType="$1"
    [[ $# -eq 2 ]] && eps="$1" && errType="$2"
    ksl::arraySetValue "${eps:-ep1}" ERRTYPE "${errType}"
}

# -------------------------------------------------------
#
# @description Returns the error type in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epErrorType               # ep1 is used
#     echo $(ksl::epErrorType ep2)   # ep2 is used
#     str=$(ksl::epErrorType ep2)    # ep2 is used
#
# @stdout the error type
# @stderr arrayGetValue() no such array
# @see [Choices for ErrorType](#ksl-epseterrortype)  <p><p>![](../images/pub/divider-line.png)
#
ksl::epErrorType()
{
    ksl::arrayGetValue "${1:-ep1}" ERRTYPE
}

# -------------------------------------------------------
#
# @description Sets the error severity in the given EPS.
#
# Overwrites any previous severity. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the severity.
# If one arg is given, then $1 is the severity and EPS `ep1` is used.
#
# **Choices for Severity**
#
#     * Indeterminate
#     * Critical
#     * Major
#     * Minor
#     * Warning
#
# @arg $1 array is either the EPS or the severity depending on number of args as described above.
# @arg $2 string is the severity if two args are given.
#
# @exitcode 0 Success - severity was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetSeverity "Critical"        # ep1 is used
#     ksl::epSetSeverity ep2 "Critical"    # ep2 is used
#     ksl::epSetSeverity  ""               # sets ep1 severity to empty
#     ksl::epSetSeverity                   # error
#
# @stderr epSetSeverity() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetSeverity()
{
    local eps
    local severity

    [[ $# -eq 0 ]] && echo "epSetSeverity() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && severity="$1"
    [[ $# -eq 2 ]] && eps="$1" && severity="$2"
    ksl::arraySetValue "${eps:-ep1}" SEVERITY "${severity}"
}

# -------------------------------------------------------
#
# @description Returns the severity in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epSeverity              # ep1 is used
#     echo $(ksl::epSeverity ep2)  # ep2 is used
#     str=$(ksl::epSeverity ep2)   # ep2 is used
#
# @stdout the severity
# @stderr arrayGetValue() no such array
# @see [Choices for Severity](#ksl-epsetseverity)  <p><p>![](../images/pub/divider-line.png)
#
ksl::epSeverity()
{
    ksl::arrayGetValue "${1:-ep1}" SEVERITY
}

# -------------------------------------------------------
#
# @description Sets the function name in the given EPS.
#
# Overwrites any previous function name. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the function name.
# If one arg is given, then $1 is the function name and EPS `ep1` is used.
#
# @arg $1 array is either the EPS or the function name depending on number of args as described above.
# @arg $2 string is the function name if two args are given.
#
# @exitcode 0 Success - function name was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetFuncName "crcCheck()"      # ep1 is used
#     ksl::epSetFuncName ep2 "crcCheck()"  # ep2 is used
#     ksl::epSetFuncName  ""               # sets ep1 function name to empty
#     ksl::epSetFuncName                   # error
#
# @stderr epSetFuncName() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetFuncName()
{
    local eps
    local funcName

    [[ $# -eq 0 ]] && echo "epSetFuncName() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && funcName="$1"
    [[ $# -eq 2 ]] && eps="$1" && funcName="$2"
    ksl::arraySetValue "${eps:-ep1}" FUNC "${funcName}"
}

# -------------------------------------------------------
#
# @description Returns the function name in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epFuncName               # ep1 is used
#     echo $(ksl::epFuncName ep2)   # ep2 is used
#     str=$(ksl::epFuncName ep2)    # ep2 is used
#
# @stdout the function name
# @stderr arrayGetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epFuncName()
{
    ksl::arrayGetValue "${1:-ep1}" FUNC
}

# -------------------------------------------------------
#
# @description Sets the file name in the given EPS.
#
# Overwrites any previous file name. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the file name.
# If one arg is given, then $1 is the file name and EPS `ep1` is used.
#
# @arg $1 array is either the EPS or the file name on number of args as described above.
# @arg $2 string is the file name if two args are given.
#
# @exitcode 0 Success - file name was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetFileName "config.yml"     # ep1 is used
#     ksl::epSetFileName ep2 "config.yml" # ep2 is used
#     ksl::epSetFileName  ""              # sets ep1 file name to empty
#     ksl::epSetFileName                  # error
#
# @stderr epSetFileName() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetFileName()
{
    local eps
    local fileName

    [[ $# -eq 0 ]] && echo "epSetFileName() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && fileName="$1"
    [[ $# -eq 2 ]] && eps="$1" && fileName="$2"
    ksl::arraySetValue "${eps:-ep1}" FILE "${fileName}"
}

# -------------------------------------------------------
#
# @description Returns the file name in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epFileName               # ep1 is used
#     echo $(ksl::epFileName ep2)   # ep2 is used
#     str=$(ksl::epFileName ep2)    # ep2 is used
#
# @stdout the file name
# @stderr arrayGetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epFileName()
{
    ksl::arrayGetValue "${1:-ep1}" FILE
}

# -------------------------------------------------------
#
# @description Sets the line number in the given EPS.
#
# Overwrites any previous line number. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the line number.
# If one arg is given, then $1 is the line number and EPS `ep1` is used.
#
# @arg $1 array is either the EPS or the line number depending on number of args as described above.
# @arg $2 string is the line number if two args are given.
#
# @exitcode 0 Success - line number was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetLineNum "55"        # ep1 is used
#     ksl::epSetLineNum ep2 "55"    # ep2 is used
#     ksl::epSetLineNum  ""         # sets ep1 line number to empty
#     ksl::epSetLineNum             # error
#
# @stderr epSetLineNum() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetLineNum()
{
    local eps
    local lineNum

    [[ $# -eq 0 ]] && echo "epSetLineNum() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && lineNum="$1"
    [[ $# -eq 2 ]] && eps="$1" && lineNum="$2"
    ksl::arraySetValue "${eps:-ep1}" LINENUM "${lineNum}"
}

# -------------------------------------------------------
#
# @description Returns the line number in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epLineNum               # ep1 is used
#     echo $(ksl::epLineNum ep2)   # ep2 is used
#     str=$(ksl::epLineNum ep2)    # ep2 is used
#
# @stdout the line number
# @stderr arrayGetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epLineNum()
{
    ksl::arrayGetValue "${1:-ep1}" LINENUM
}

# -------------------------------------------------------
#
# @description Sets a code number in the given EPS.
#
# Overwrites any previous code number. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the code number.
# If one arg is given, then $1 is the code number and EPS `ep1` is used.
#
# @arg $1 array is either the EPS or the code number depending on number of args as described above.
# @arg $2 string is the code number if two args are given.
#
# @exitcode 0 Success - code number was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetCodeNum "999"        # ep1 is used
#     ksl::epSetCodeNum ep2 "999"    # ep2 is used
#     ksl::epSetCodeNum  ""          # sets ep1 code number to empty
#     ksl::epSetCodeNum              # error
#
# @stderr epSetCodeNum() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetCodeNum()
{
    local eps
    local codeNum

    [[ $# -eq 0 ]] && echo "epSetCodeNum() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && codeNum="$1"
    [[ $# -eq 2 ]] && eps="$1" && codeNum="$2"
    ksl::arraySetValue "${eps:-ep1}" CODENUM "${codeNum}"
}

# -------------------------------------------------------
#
# @description Returns the code number in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epCodeNum               # ep1 is used
#     echo $(ksl::epCodeNum ep2)   # ep2 is used
#     str=$(ksl::epCodeNum ep2)    # ep2 is used
#
# @stdout the code number
# @stderr arrayGetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epCodeNum()
{
    ksl::arrayGetValue "${1:-ep1}" CODENUM
}

# -------------------------------------------------------
#
# @description Sets a probable cause string in the given EPS.
#
# Overwrites any previous cause. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the cause.
# If one arg is given, then $1 is the cause and EPS `ep1` is used.
#
# @arg $1 array is either the EPS or the cause depending on number of args as described above.
# @arg $2 string is the cause if two args are given.
#
# @exitcode 0 Success - cause was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetCause "no power"      # ep1 is used
#     ksl::epSetCause ep2 "no power"  # ep2 is used
#     ksl::epSetCause  ""             # sets ep1 cause to empty
#     ksl::epSetCause                 # error
#
# @stderr epSetCause() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetCause()
{
    local eps
    local cause

    [[ $# -eq 0 ]] && echo "epSetCause() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && cause="$1"
    [[ $# -eq 2 ]] && eps="$1" && cause="$2"
    ksl::arraySetValue "${eps:-ep1}" CAUSE "${cause}"
}

# -------------------------------------------------------
#
# @description Returns the probable cause in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epCause               # ep1 is used
#     echo $(ksl::epCause ep2)   # ep2 is used
#     str=$(ksl::epCause ep2)    # ep2 is used
#
# @stdout the cause
# @stderr arrayGetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epCause()
{
    ksl::arrayGetValue "${1:-ep1}" CAUSE
}

# -------------------------------------------------------
#
# @description Sets a probable repair string in the given EPS.
#
# Overwrites any previous repair. EPS must already exist.
#
# If two args are given, then $1 is EPS and $2 is the repair.
# If one arg is given, then $1 is the repair and EPS `ep1` is used.
#
# @arg $1 array is either the EPS or the repair depending on number of args as described above.
# @arg $2 string is the repair if two args are given.
#
# @exitcode 0 Success - repair was set.
# @exitcode 1 Failed - bad EPS or missing args.
#
# @example
#     ksl::epSetRepair "plug it in"      # ep1 is used
#     ksl::epSetRepair ep2 "plug it in"  # ep2 is used
#     ksl::epSetRepair  ""               # sets ep1 repair to empty
#     ksl::epSetRepair                   # error
#
# @stderr epSetRepair() missing args
# @stderr arraySetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epSetRepair()
{
    local eps
    local repair

    [[ $# -eq 0 ]] && echo "epSetRepair() missing args" >&2 && return 1
    [[ $# -eq 1 ]] && repair="$1"
    [[ $# -eq 2 ]] && eps="$1" && repair="$2"
    ksl::arraySetValue "${eps:-ep1}" REPAIR "${repair}"
}

# -------------------------------------------------------
#
# @description Returns the probable repair in the given EPS.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epRepair                    # ep1 is used
#     echo $(ksl::epRepair ep2)        # ep2 is used
#     str=$(ksl::epRepair ep2)         # ep2 is used
#
# @stdout the repair
# @stderr arrayGetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epRepair()
{
    ksl::arrayGetValue "${1:-ep1}" REPAIR
}

# -------------------------------------------------------
#
# @description Returns the timestamp in the given EPS.
#
# The value for timestamp was established on the most recent call to
# epSet().
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epTimestamp               # ep1 is used
#     echo $(ksl::epTimestamp ep2)   # ep2 is used
#     str=$(ksl::epTimestamp ep2)    # ep2 is used
#
# @stdout the timestamp
# @stderr arrayGetValue() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epTimestamp()
{
    ksl::arrayGetValue "${1:-ep1}" TIMESTAMP
}

# -------------------------------------------------------
#
# @description Returns true if EPS is carrying an error.
#
# The EPS is considered to be carrying an error if
# either the description field or the code number
# field is non-empty.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 true - EPS is carrying an error.
# @exitcode 1 false - EPS is not carrying an error.
#
# @example
#     if ksl::epHasError; then epPrint; fi   # ep1 is used
#     [[ ksl::epHasError ep2 ]] && return 1  # ep2 is used
#
# @stderr epHasError() no such array <p><p>![](../images/pub/divider-line.png)
#
ksl::epHasError()
{
    local arg=${1:-ep1}
    local -n eps=${arg}

    ! ksl::arrayExists "$arg" &&
        echo "epHasError() no such array $1" >&2 && return 1

    [[ -z ${eps[DESC]}    ]] &&
    [[ -z ${eps[CODENUM]} ]] && return 1

    return 0
}

# -------------------------------------------------------
#
# @description Prints the given EPS in a formatted style to stdout.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
# @arg $1 array is the EPS. If no args, then EPS `ep1` is used.
#
# @exitcode 0 Success
# @exitcode 1 Failed - likely a bad EPS.
#
# @example
#     ksl::epPrint         # ep1 is used
#     ksl::epPrint ep2     # ep2 is used
#
# @stderr epPrint() no such array <p><p>![](../images/pub/divider-line.png)
# @stdout See output from example script at top of this file.
#
ksl::epPrint()
{
    local arg=${1:-ep1}
    local -n eps=${arg}
    ! ksl::arrayExists "$arg" &&
        echo "epPrint() no such array:$1" && return 1

    if ksl::useColor; then
        local fmt="${FG_RED}${BOLD}${UNDERLINE}Error${CLEAR}\n"
        for ((i=1; i<=10; i++)); do
            fmt+="${FG_GREEN}%20s: ${FG_YELLOW}%s${CLEAR}\n"
        done
    else
        local fmt="Error\n"
        for ((i=1; i<=10; i++)); do
            fmt+="%20s: %s\n"
        done
    fi

    # shellcheck disable=SC2059
    printf "$fmt" \
                   "Error" "$(ksl::epErrorName   "$eps")" \
                    "Type" "$(ksl::epErrorType   "$eps")" \
                "Severity" "$(ksl::epSeverity    "$eps")" \
             "Description" "$(ksl::epDescription "$eps")" \
               "Date/Time" "$(ksl::epTimestamp   "$eps")" \
                    "File" "$(ksl::epFileName    "$eps"):$(ksl::epLineNum "$eps")" \
                "Function" "$(ksl::epFuncName    "$eps")()" \
          "Probable Cause" "$(ksl::epCause       "$eps")" \
         "Proposed Repair" "$(ksl::epRepair      "$eps")" \
              "Error Code" "$(ksl::epCodeNum     "$eps")"
}

# -------------------------------------------------------
