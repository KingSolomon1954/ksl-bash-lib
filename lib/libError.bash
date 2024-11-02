# -----------------------------------------------------------
#
# Functions to support error passing
#
# Contains the following:
#
# epCreate
# epDestroy
# epExists
# epSet(-a -p -se -st -sev -des)
# epClear
# epPrepend
# epAppend
# epSetErrorName
# epSetErrorType
# epSetDescription
# epSetSeverity
# epSetProbableCause
# epSetProposedRepair
# epSetFileName
# epSetFuncName
# epSetLineNum
# epSetCodeNum
# epSetTimestamp
# epErrorName
# epErrorType
# epSeverity
# epFileName
# epFuncName
# epLineNum
# epCodeNum
# epFullDesc
# epDescription
# epProbableCause
# epProposedRepair
# epTimestamp
# epHasError
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

ksl::epClear()
{
# echo "Howie called: args $#"
local eps=${1-"ep1"}
# echo "Howie eps: ${eps}"

    ! ksl::epExists "${eps}" && return 1
# echo "Howie before name"
    local -n name="${eps}"

# echo "Howie clearing"
    name[DESC]=""
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
#
# Sets the description in the given EPS.
#
# Overwrites any previous description. EPS must already exist.
# If 2 args are given, then $1 is EPS and $2 is the description.
# If 1 arg is given, then $1 is the description and ep1 is the EPS.
# Examples:
#     epSetDescription "Broken channel"        # ep1 is assumed
#     epSetDescription ep2 "Broken channel"
#
ksl::epSetDescription()
{
    local eps
    local description

    [ $# -eq 0 ] && return
    [ $# -eq 1 ] && description="$1";
    [ $# -eq 2 ] && eps="$1" && description="$2"
    ! ksl::epExists ${eps:=ep1} && return 1
    eval ${eps}[DESC]="\${description}"
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
# to invoking epClear().
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
    local description
    local fileName
    local funcName
    local lineNum
    local severity
    local errorName
    local errorType
    local codeNum
    local cause
    local repair
    
    while [ $# -gt 0 ]; do        # parse arguments
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
        -li|--linenum)
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
    
    [ -n "${description}" ] && eval ${eps}[DESC]="\${description}"
    [ -n "${fileName}" ]    && eval ${eps}[FILE]="\${fileName}"
    [ -n "${funcName}" ]    && eval ${eps}[FUNC]="\${funcName}"
    [ -n "${lineNum}" ]     && eval ${eps}[LINENUM]="\${lineNum}"
    [ -n "${severity}" ]    && eval ${eps}[SEVERITY]="\${severity}"
    [ -n "${errorName}" ]   && eval ${eps}[ERRNAME]="\${errorName}"
    [ -n "${errorType}" ]   && eval ${eps}[ERRTYPE]="\${errorType}"
    [ -n "${codeNum}" ]     && eval ${eps}[CODENUM]="\${codeNum}"
    [ -n "${cause}" ]       && eval ${eps}[CAUSE]="\${cause}"
    [ -n "${repair}" ]      && eval ${eps}[REPAIR]="\${repair}"

    eval ${eps}[TIMESTAMP]="\$(date)"
}

# -------------------------------------------------------
