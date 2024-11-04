# -----------------------------------------------------------
#
# Functions to support error passing
#
# Contains the following:
#
# Lifecycle
#      epCreate done
#      epDestroy done
#
# Modifiers
#     epSet done
#     epClear done
#     epPrepend done
#     epAppend done
#     epSetErrorName done
#     epSetErrorType done
#     epSetDescription done
#     epSetSeverity done
#     epSetProbableCause
#     epSetProposedRepair
#     epSetFileName
#     epSetFuncName done
#     epSetLineNum
#     epSetCodeNum
#     epSetTimestamp
#
# Observers
#     epExists done
#     epErrorName done
#     epErrorType done
#     epSeverity done
#     epFileName
#     epFuncName done
#     epLineNum
#     epCodeNum
#     epFullDesc
#     epDescription done
#     epProbableCause
#     epProposedRepair
#     epTimestamp
#     epHasError
#
# ERRNAME choices
#     UnsetErrorName
#     CaughtException
#     ConfigurationError
#     DataFormatError
#     ExistsError
#     IllegalStateError
#     InputOutputError
#     InvalidAccessError
#     InvalidArgumentError
#     LengthError
#     LogicError
#     NetworkError
#     NoPermissionError
#     NotFoundError
#     NotImplementedError
#     NullPointerError
#     NullValueError
#     OperationNotPossibleError
#     OverflowError
#     RangeError
#     SignalError
#     SystemCallError
#     TimeoutError
#     UnderflowError
#
# ERRTYPE choices
#     ErrorTypeNotSpecified
#     CommunicationsError
#     ConfigurationError
#     EnvironmentalError
#     EquipmentError
#     ProcessingError
#     QualityOfServiceError
#
# SEVERITY choices
#     UnsetSeverity
#     Indeterminate
#     Critical
#     Major
#     Minor
#     Warning
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[ -v libErrorImported ] && [ "$1" != "-f" ] && return
libErrorImported=true

# -------------------------------------------------------
#
# Output text to standard out.
#
# epCreate errPass
ksl::epCreate()
{
    [ -z "$1" ] && return 1
    ksl::epExists "$1" && return 1
    local -A -g "$1"
    local -n name="$1"
    name[DESC]=
    name[FUNC]=
    name[FILE]=
    name[LINENUM]=
    name[SEVERITY]=
    name[ERRNAME]=
    name[ERRTYPE]=
    name[CODENUM]=
    name[TIMESTAMP]=
    name[CAUSE]=
    name[REPAIR]=
}

# -------------------------------------------------------

ksl::epDestroy()
{
    [ $# -eq 0 ] && return 1
    ! ksl::epExists "$1" && return 1
    unset "$1"
}

# -------------------------------------------------------

ksl::epExists()
{
    [ $# -eq 0 ] && return 1
    local -n name="$1"
    [[ ${#name[@]} -gt 0 ]]
}

# -------------------------------------------------------
#
# Re-initializes an existing EPS to empty, so it can be
# reused again. The timestamp is also set to null. It is
# expected that the user will issue an epSet() for the
# next usage.
#
# This is not necessary 
#
ksl::epClear()
{
    local eps=${1-"ep1"}
    ! ksl::epExists "${eps}" && return 1
    local -n name="${eps}"

    name[CAUSE]=
    name[CODENUM]=
    name[DESC]=
    name[ERRNAME]=
    name[ERRTYPE]=
    name[FILE]=
    name[FUNC]=
    name[LINENUM]=
    name[REPAIR]=
    name[SEVERITY]=
    name[TIMESTAMP]=
}

# -------------------------------------------------------

ksl::_isValidKey()
{
    return 0
}

# -------------------------------------------------------

ksl::_epSetField()
{
    local eps=$1
    local key=$2
    local str=$3

    [ $# -ne 3 ]                && echo "epSetField() missing args"       && return 1
    ! ksl::epExists "${eps}"    && echo "epSetField() no such EPS:${eps}" && return 1
    ! ksl::_isValidKey "${key}" && echo "epSetField() no such Key:${key}" && return 1

    eval ${eps}[${key}]=\""\${str}"\"
}

# -------------------------------------------------------

ksl::_epGetField()
{
    local eps=$1
    local key=$2

    [ $# -ne 2 ]                && echo "epGetField() missing args"       && return 1
    ! ksl::epExists "${eps}"    && echo "epGetField() no such EPS:${eps}" && return 1
    ! ksl::_isValidKey "${key}" && echo "epGetField() no such Key:${key}" && return 1

    eval echo "\${${eps}[${key}]}"
}

# -------------------------------------------------------
#
# Sets the description in the given EPS.
#
# Overwrites any previous description. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the description.
# If 1 arg is given, then $1 is the description and the default 
# EPS of "ep1" is used. If 0 args, then no action is taken and
# not an error.
#
# Examples:
#     epSetDescription "Broken channel"        # ep1 is used
#     epSetDescription ep2 "Broken channel"
#     epSetDescription ""                      # sets ep1 it to empty
#     epSetDescription                         # no action
#
ksl::epSetDescription()
{
    local eps
    local description

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && description="$1"
    [ $# -eq 2 ] && eps="$1" && description="$2"
    ksl::_epSetField ${eps:-ep1} DESC "${description}"
}

# -------------------------------------------------------
#
# Returns the description in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epDescription()
{
    ksl::_epGetField ${1:-ep1} DESC
}

# -------------------------------------------------------
#
# Appends given string to the description in the given EPS.
#
# EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the string
#  to append. If 1 arg is given, then $1 is the string to 
# append and the default EPS of "ep1" is used. If 0 args, then
# no action is taken and not an error.
#
# Examples:
#     epAppend "Broken channel"        # ep1 is used
#     epAppend ep2 "Broken channel"
#     epAppend ""                      # append empty string ep1
#     epAppend                         # no action
#
ksl::epAppend()
{
    local eps
    local str

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && str="$1";
    [ $# -eq 2 ] && eps="$1" && str="$2"
    ! ksl::epExists ${eps:=ep1} && return 1
    eval ${eps}[DESC]=\${${eps}[DESC]}"\${str}"
}

# -------------------------------------------------------
#
# Prepends given string to the description in the given EPS.
#
# EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the string to
# prepend. If 1 arg is given, then $1 is the string to prepend 
# and the default EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epPrepend "Broken channel"        # ep1 is used
#     epPrepend ep2 "Broken channel"
#     epPrepend ""                      # prepends empty string ep1
#     epPrepend                         # no action
#
ksl::epPrepend()
{
    local eps
    local str

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && str="$1";
    [ $# -eq 2 ] && eps="$1" && str="$2"
    ! ksl::epExists ${eps:=ep1} && return 1
    eval ${eps}[DESC]="\${str}"\${${eps}[DESC]}
}

# -------------------------------------------------------
#
# Sets the error name in the given EPS.
#
# Overwrites any previous error name. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the error name.
# If 1 arg is given, then $1 is the error name and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetErrorName "OverflowError"        # ep1 is used
#     epSetErrorName ep2 "OverflowError"
#     epSetErrorName  ""                    # sets ep1 error name to empty
#     epSetErrorName                        # no action
#
ksl::epSetErrorName()
{
    local eps
    local errName

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && errName="$1"
    [ $# -eq 2 ] && eps="$1" && errName="$2"
    ksl::_epSetField ${eps:-ep1} ERRNAME "${errName}"
}

# -------------------------------------------------------
#
# Returns the error name in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epErrorName()
{
    ksl::_epGetField ${1:-ep1} ERRNAME
}

# -------------------------------------------------------
#
# Sets the error type in the given EPS.
#
# Overwrites any previous error name. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the error type.
# If 1 arg is given, then $1 is the error type and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetErrorType "ProcessingError"       # ep1 is used
#     epSetErrorType ep2 "ProcessingError"
#     epSetErrorType  ""                    # sets ep1 error type to empty
#     epSetErrorType                        # no action
#
ksl::epSetErrorType()
{
    local eps
    local errType

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && errType="$1"
    [ $# -eq 2 ] && eps="$1" && errType="$2"
    ksl::_epSetField ${eps:-ep1} ERRTYPE "${errType}"
}

# -------------------------------------------------------
#
# Returns the error type in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epErrorType()
{
    ksl::_epGetField ${1:-ep1} ERRTYPE
}

# -------------------------------------------------------
#
# Sets the error severity in the given EPS.
#
# Overwrites any previous severity. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the severity.
# If 1 arg is given, then $1 is the severity and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetSeverity "Critical"        # ep1 is used
#     epSetSeverity ep2 "Critical"
#     epSetSeverity  ""               # sets ep1 severity to empty
#     epSetSeverity                   # no action
#
ksl::epSetSeverity()
{
    local eps
    local severity

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && severity="$1"
    [ $# -eq 2 ] && eps="$1" && severity="$2"
    ksl::_epSetField ${eps:-ep1} SEVERITY "${severity}"
}

# -------------------------------------------------------
#
# Returns the severity in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epSeverity()
{
    ksl::_epGetField ${1:-ep1} SEVERITY
}

# -------------------------------------------------------
#
# Sets the function name in the given EPS.
#
# Overwrites any previous function name. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the function name.
# If 1 arg is given, then $1 is the function name and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetFuncName "sort()"        # ep1 is used
#     epSetFuncName ep2 "sort()"
#     epSetFuncName  ""             # sets ep1 function name to empty
#     epSetFuncName                 # no action
#
ksl::epSetFuncName()
{
    local eps
    local funcName

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && funcName="$1"
    [ $# -eq 2 ] && eps="$1" && funcName="$2"
    ksl::_epSetField ${eps:-ep1} FUNC "${funcName}"
}

# -------------------------------------------------------
#
# Returns the funcition name in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epFuncName()
{
    ksl::_epGetField ${1:-ep1} FUNC
}

# -------------------------------------------------------
#
# Sets the file name in the given EPS.
#
# Overwrites any previous file name. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the file name.
# If 1 arg is given, then $1 is the file name and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetFileName "sort()"        # ep1 is used
#     epSetFileName ep2 "sort()"
#     epSetFileName  ""             # sets ep1 file name to empty
#     epSetFileName                 # no action
#
ksl::epSetFileName()
{
    local eps
    local fileName

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && fileName="$1"
    [ $# -eq 2 ] && eps="$1" && fileName="$2"
    ksl::_epSetField ${eps:-ep1} FILE "${fileName}"
}

# -------------------------------------------------------
#
# Returns the file name in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epFileName()
{
    ksl::_epGetField ${1:-ep1} FILE
}

# -------------------------------------------------------
#
# Sets the line number in the given EPS.
#
# Overwrites any previous line number. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the line number.
# If 1 arg is given, then $1 is the line number and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetLineNum "sort()"        # ep1 is used
#     epSetLineNum ep2 "sort()"
#     epSetLineNum  ""             # sets ep1 line number to empty
#     epSetLineNum                 # no action
#
ksl::epSetLineNum()
{
    local eps
    local lineNum

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && lineNum="$1"
    [ $# -eq 2 ] && eps="$1" && lineNum="$2"
    ksl::_epSetField ${eps:-ep1} LINENUM "${lineNum}"
}

# -------------------------------------------------------
#
# Returns the line number in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epLineNum()
{
    ksl::_epGetField ${1:-ep1} LINENUM
}

# -------------------------------------------------------
#
# Sets a code number in the given EPS.
#
# Overwrites any previous code number. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the code number.
# If 1 arg is given, then $1 is the code number and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetCodeNum "sort()"        # ep1 is used
#     epSetCodeNum ep2 "sort()"
#     epSetCodeNum  ""             # sets ep1 code number to empty
#     epSetCodeNum                 # no action
#
ksl::epSetCodeNum()
{
    local eps
    local codeNum

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && codeNum="$1"
    [ $# -eq 2 ] && eps="$1" && codeNum="$2"
    ksl::_epSetField ${eps:-ep1} CODENUM "${codeNum}"
}

# -------------------------------------------------------
#
# Returns the code number in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epCodeNum()
{
    ksl::_epGetField ${1:-ep1} CODENUM
}

# -------------------------------------------------------
#
# Sets a probably cause string in the given EPS.
#
# Overwrites any previous cause. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the cause.
# If 1 arg is given, then $1 is the cause and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetCause "sort()"        # ep1 is used
#     epSetCause ep2 "sort()"
#     epSetCause  ""             # sets ep1 cause to empty
#     epSetCause                 # no action
#
ksl::epSetCause()
{
    local eps
    local cause

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && cause="$1"
    [ $# -eq 2 ] && eps="$1" && cause="$2"
    ksl::_epSetField ${eps:-ep1} CAUSE "${cause}"
}

# -------------------------------------------------------
#
# Returns the probable cause in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epCause()
{
    ksl::_epGetField ${1:-ep1} CAUSE
}

# -------------------------------------------------------
#
# Sets a probable repair string in the given EPS.
#
# Overwrites any previous repair. EPS must already exist.
#
# If 2 args are given, then $1 is EPS and $2 is the repair.
# If 1 arg is given, then $1 is the repair and the default 
# EPS of "ep1" is used. If 0 args, then no action
# is taken and not an error.
#
# Examples:
#     epSetRepair "sort()"        # ep1 is used
#     epSetRepair ep2 "sort()"
#     epSetRepair  ""             # sets ep1 repair to empty
#     epSetRepair                 # no action
#
ksl::epSetRepair()
{
    local eps
    local repair

    [ $# -eq 0 ] && return 0
    [ $# -eq 1 ] && repair="$1"
    [ $# -eq 2 ] && eps="$1" && repair="$2"
    ksl::_epSetField ${eps:-ep1} REPAIR "${repair}"
}

# -------------------------------------------------------
#
# Returns the probable repair in the given EPS.
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epRepair()
{
    ksl::_epGetField ${1:-ep1} REPAIR
}

# -------------------------------------------------------
#
# Returns the timestamp in the given EPS. The value for
# timestamp was established on the most recent call to epSet().
#
# $1 is the EPS and optional. If not supplied the default EPS
# of "ep1" is used.
#
ksl::epTimestamp()
{
    ksl::_epGetField ${1:-ep1} TIMESTAMP
}

# -------------------------------------------------------
#
# Set values in an error passing structure.
#
# epSet [options...] <error passing structure: default = ep1>
#
# With no args, epSet works on the default "ep1" error passing structure
# (EPS). You can pass in ep1 explicitly or supply your own EPS. If the
# given EPS does not already exist in the environment, then it is
# created.
#
# These two are equivalent: "epSet;" and "epSet ep1;"
# Or supply your own: "epSet myEp;"
#
# Each call to epSet() initalizes all fields to empty/default values
# with the timestamp set to current time, followed by setting any
# supplied options.
#
# If there are no options given, then epSet() is effectively equivalent
# to invoking epClear() except a current timestamp is set.
#
# epSet() is meant to be called at the lowest level of call tree.
# Generally the leaf most function does the epSet. Each parent up along
# the call chain tests for a fail condition and then supplements the EPS
# by appending, prepending, and setting additional fields to provide
# improved context and diagnostics.
#
ksl::epSet()
{
    local eps
    local cause
    local codeNum
    local description
    local errorName
    local errorType
    local fileName
    local funcName
    local lineNum
    local repair
    local severity
    
    while [ $# -gt 0 ]; do
        case $1 in
        -p|--pretty-print)
            # Example of handling an option which doesn't require an argument
            prettyPrint=true;;
        -d|--description)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            description="$2"
            shift;;
        -fi|--fileName)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            fileName="$2"
            shift;;
        -fu|--funcName)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            funcName="$2"
            shift;;
        -li|--lineNum)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            lineNum="$2"
            shift;;
        -sv|--severity)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            severity="$2"
            shift;;
        -en|--errorName)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            errorName="$2"
            shift;;
        -et|--errorType)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            errorType="$2"
            shift;;
        -cn|--codeNum)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            codeNum="$2"
            shift;;
        -ca|--cause)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            cause="$2"
            shift;;
        -rp|--repair)
            if [ $# -lt 2 ]; then
                echo "epSet(): No argument specified along with \"$1\" option."
                return 1
            fi
            repair="$2"
            shift;;
        -*)
            echo "epSet(): Invalid option \"$1\"".
            return 1;;
        "") ;;  # Ignore empty arg
        *) eps="$1" ;;
        esac
        shift
    done

    # may need to +set noerrexit ??
    ksl::epCreate ${eps:=ep1}     # harmless if already exists
    ksl::epClear ${eps}           # always clear it 
    
    [ -n "${cause}"       ] && ksl::epSetCause       ${eps} "${cause}"
    [ -n "${codeNum}"     ] && ksl::epSetCodeNum     ${eps} "${codeNum}"
    [ -n "${description}" ] && ksl::epSetDescription ${eps} "${description}"
    [ -n "${errorName}"   ] && ksl::epSetErrorName   ${eps} "${errorName}"
    [ -n "${errorType}"   ] && ksl::epSetErrorType   ${eps} "${errorType}"
    [ -n "${fileName}"    ] && ksl::epSetFileName    ${eps} "${fileName}"
    [ -n "${funcName}"    ] && ksl::epSetFuncName    ${eps} "${funcName}"
    [ -n "${lineNum}"     ] && ksl::epSetLineNum     ${eps} "${lineNum}"
    [ -n "${repair}"      ] && ksl::epSetRepair      ${eps} "${repair}"
    [ -n "${severity}"    ] && ksl::epSetSeverity    ${eps} "${severity}"
    
    eval ${eps}[TIMESTAMP]="\$(date)"
}

# -------------------------------------------------------