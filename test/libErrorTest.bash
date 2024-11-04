#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libError.bash

# -----------------------------------------------------------
#
# Note:
#
# Stay away from running commands inside bash_unit assert()'s. Got
# opposite results if same assert is run just two lines later. 
# Therefore don't do this:
# 
#     assert 'ksl::epCreate ep1"'
#
# Additionally, in the above case with epCreate, ep1 seems to be
# shadowed. Some kind of scoping thing with bash_unit. Not sure.
#
# There are two alternatives. First form uses assert in a 
# multi-conditional idiom like so:
#
#     ksl::epCreate ep1 && assert "false"   # expected negative condition
#     ! ksl::epCreate ep1 && assert "false" # expected positive condition
#
# Just be careful as the test subject must always be negated from
# the expected response. Kind of a head scratcher. Note that only
# the '&& assert "false"' form is workable, otherwise the truth
# table is not properly covered.
#
# Second alternative is more verbose but reads better and less error
# prone since the test condition is always positve. Just need to flip
# the -eq test between 0 and 1 for positive and negative conditions,
# similar to the first alternative. This also has the advantage of being
# able to test for specific return values instead of just success/fail.
#
#     local -i ret
#     ksl::epCreate ep1
#     ret=$?; assert '[[ $ret -eq 0 ]]'
#
# -----------------------------------------------------------

test_epCreate()
{
    # create

    local -i ret
    # create ep1, expect success
    ksl::epCreate ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert '[[ ${#ep1[@]} -gt 0 ]]'

    # create same again - error this time
    ksl::epCreate ep1
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create missing args
    ksl::epCreate
    ret=$?; assert '[[ $ret -eq 1 ]]'

    assert '[[ ${#ep1[@]} -eq 11 ]]'
    
    unset ep1
}

# -----------------------------------------------------------

test_epDestroy()
{
    local -i ret
    
    # destroy but missing args
    ksl::epDestroy
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # destroy but doesn't exist, error
    unset ep1
    ksl::epDestroy ep1
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # destroy, good params, expect success
    ksl::epCreate ep1
    ksl::epDestroy ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'

    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    unset ep1
}

# -----------------------------------------------------------

test_epExists()
{
    local -i ret
    
    # missing arg
    ksl::epExists
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # good args but no exist
    unset ep1
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # good args, yes exists
    ksl::epCreate ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'

    unset ep1
}

# -----------------------------------------------------------

test_epClear()
{
    local -i ret
    unset ep1

    # clear on unset EPS, will use ep1, expect fail
    ksl::epClear
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # clear on freshly created EPS, expect success
    ksl::epCreate ep1
    ksl::epClear
    ret=$?; assert '[[ $ret -eq 0 ]]'

    # set a value into description
    ksl::epSetDescription "illegal value"
    assert '[[ "${ep1[DESC]}" == "illegal value" ]]'

    # now clear, expect null description
    ksl::epClear
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert '[[ "${ep1[DESC]}" == "" ]]'

    unset ep1
}

# -----------------------------------------------------------

test_epSet()
{
    local -i ret
    
    # no args, should create ep1
    unset ep1
    ksl::epSet
    ret=$?; assert '[[ $ret -eq 0 ]]'

    # explicity specifiy ep1,
    unset ep1
    ksl::epSet ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    
    # two epSets in row
    unset ep1
    ksl::epSet ep1
    ksl::epSet ep1
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    
    # explicity specify other than ep1
    unset ep1
    ksl::epSet ep2
    ksl::epExists ep2
    ret=$?; assert '[[ $ret -eq 0 ]]'
    
    unset ep2

    # assign description
    unset ep1
    ksl::epSet -d "ETH2 network is down"
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert "[[ ${#ep1[@]} -gt 0 ]]"
    assert '[[ "${ep1[DESC]}" == "ETH2 network is down" ]]'
    
    # assign file name
    ksl::epSet -fi "libStrings.bash"
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert "[[ ${#ep1[@]} -gt 0 ]]"
    assert '[[ "${ep1[FILE]}" == "libStrings.bash" ]]'

    # assign func name
    ksl::epSet -fu "ksl::uppercase()"
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert "[[ ${#ep1[@]} -gt 0 ]]"
    assert '[[ "${ep1[FUNC]}" == "ksl::uppercase()" ]]'

    # assign three at once, clobbering old values
    ksl::epSet -d "Broken initialization" -fi "/etc/init" -fu "ksl::lowercase()"
    assert '[[ "${ep1[DESC]}" == "Broken initialization" ]]'
    assert '[[ "${ep1[FILE]}" == "/etc/init" ]]'
    assert '[[ "${ep1[FUNC]}" == "ksl::lowercase()" ]]'

    # operate on different EPS's, ensure both ep1 and ep2 are intact
    # relies on ep1 from previous
    # create a new ep2 with different values
    ksl::epSet ep2 -d "communications timeout" -fi "/usr/lib" -fu "socket()"
    assert '[[ "${ep1[DESC]}" == "Broken initialization" ]]'
    assert '[[ "${ep1[FILE]}" == "/etc/init" ]]'
    assert '[[ "${ep1[FUNC]}" == "ksl::lowercase()" ]]'
    assert '[[ "${ep2[DESC]}" == "communications timeout" ]]'
    assert '[[ "${ep2[FILE]}" == "/usr/lib" ]]'
    assert '[[ "${ep2[FUNC]}" == "socket()" ]]'

    # new EPS setting all fields
    ksl::epSet ep3 \
               -ca "power outage" \
               -cn "200" \
               -d "boo boo" \
               -en "InputOutputError" \
               -et "CommunicationsError" \
               -fi "sort.bash" \
               -fu "sort()" \
               -li "100" \
               -rp "turn power on" \
               -sv "Major"
    assert '[[ "${ep3[CAUSE]}" == "power outage" ]]'
    assert '[[ "${ep3[CODENUM]}" == "200" ]]'
    assert '[[ "${ep3[DESC]}" == "boo boo" ]]'
    assert '[[ "${ep3[ERRNAME]}" == "InputOutputError" ]]'
    assert '[[ "${ep3[ERRTYPE]}" == "CommunicationsError" ]]'
    assert '[[ "${ep3[FILE]}" == "sort.bash" ]]'
    assert '[[ "${ep3[FUNC]}" == "sort()" ]]'
    assert '[[ "${ep3[LINENUM]}" == "100" ]]'
    assert '[[ "${ep3[REPAIR]}" == "turn power on" ]]'
    assert '[[ "${ep3[SEVERITY]}" == "Major" ]]'
    assert '[[ "${ep3[TIMESTAMP]}" != "" ]]'
    
    ksl::epDestroy ep1
    ksl::epDestroy ep2
    ksl::epDestroy ep3
}

# -----------------------------------------------------------

test_epSetField()
{
    local -i ret
    local diag

    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with missing args
    diag=$(ksl::_epSetField)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::_epSetField ep1)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::_epSetField ep1 DESC)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::_epSetField ep1 DESC "my description")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::_epSetField ep7 DESC "my description")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1

    # call with good settings, if a problem occurs
    # with presumably good args then diag will display on stdout
    ksl::_epSetField ep1 DESC "my description"
    assert '[[ "${ep1[DESC]}" == "my description" ]]'
    
    unset ep1
}

# -----------------------------------------------------------

test_epGetField()
{
    local -i ret
    local val
    
    # call with missing args
    val=$(ksl::_epGetField)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    val=$(ksl::_epGetField ep1)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # call with bad EPS
    unset ep1
    val=$(ksl::_epGetField ep1 DESC)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    val=$(ksl::_epGetField ep7 DESC)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epSet ep1 -d "my description"

    # call with good settings
    val=$(ksl::_epGetField ep1 DESC)
    assert '[[ "${val}" == "my description" ]]'
    
    unset ep1
}

# -----------------------------------------------------------

test_epSetDescription()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call no args
    ksl::epSetDescription
    ret=$?; assert '[[ $ret -eq 0 ]]'
   
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetDescription "I/O error")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # call with bad EPS
    diag=$(ksl::epSetDescription ep7 "I/O error")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetDescription "I/O error"
    assert '[[ "${ep1[DESC]}" == "I/O error" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetDescription ep1 "Configuration bad value"
    assert '[[ "${ep1[DESC]}" == "Configuration bad value" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetDescription ep2 "Configuration bad value")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetDescription ep2 "missing parameter"
    assert '[[ "${ep2[DESC]}" == "missing parameter" ]]'
    assert '[[ "${ep1[DESC]}" == "Configuration bad value" ]]'
    
    ksl::epDestroy ep1
    ksl::epDestroy ep2
}

# -----------------------------------------------------------

test_epDescription()
{
    # call with non-existant EPS
    local desc
    unset ep1
    desc=$(ksl::epDescription)
    assert '[[ "${desc}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    desc=$(ksl::epDescription)
    assert '[[ "${desc}" == "" ]]'

    # put something readable in description
    ksl::epSetDescription "Input/output error"
    desc=$(ksl::epDescription)
    assert '[[ "${desc}" == "Input/output error" ]]'

    # call with different EPS
    ksl::epCreate ep2
    desc=$(ksl::epDescription ep2)
    assert '[[ "${desc}" == "" ]]'
    desc=$(ksl::epDescription ep1)
    assert '[[ "${desc}" == "Input/output error" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epAppend()
{
    local -i ret
    local desc
    
    # call no args
    ksl::epAppend
    ret=$?; assert '[[ $ret -eq 0 ]]'
   
    # call with bad EPS
    unset ep1
    ksl::epAppend "I/O error"
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    ksl::epAppend "I/O error"
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create valid ep1 with a description
    unset ep1
    ksl::epSet -d "bad CRC"

    # append to description
    ksl::epAppend ": on input channel 6."
    desc=$(ksl::epDescription)
    assert '[[ "${desc}" == "bad CRC: on input channel 6." ]]'
    
    ksl::epDestroy ep1
}

# -----------------------------------------------------------

test_epPrepend()
{
    local -i ret
    local desc
    
    # call no args
    ksl::epPrepend
    ret=$?; assert '[[ $ret -eq 0 ]]'
   
    # call with bad EPS
    unset ep1
    ksl::epPrepend "I/O error"
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    ksl::epPrepend "I/O error"
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create valid ep1 with a description
    unset ep1
    ksl::epSet -d "bad CRC"

    # append to description
    ksl::epPrepend "I/O error: "
    desc=$(ksl::epDescription)
    assert '[[ "${desc}" == "I/O error: bad CRC" ]]'
    
    ksl::epDestroy ep1
}

# -----------------------------------------------------------

test_epSetErrorName()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetErrorName "OverflowError")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetErrorName ep7 "OverflowError")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetErrorName "OverflowError"
    assert '[[ "${ep1[ERRNAME]}" == "OverflowError" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetErrorName ep1 "UnderflowError"
    assert '[[ "${ep1[ERRNAME]}" == "UnderflowError" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetErrorName ep2 "TimeoutError")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetErrorName ep2 "TimeoutError"
    assert '[[ "${ep2[ERRNAME]}" == "TimeoutError" ]]'
    assert '[[ "${ep1[ERRNAME]}" == "UnderflowError" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epErrorName()
{
    # call with non-existant EPS
    local errorName
    unset ep1
    
    errorName=$(ksl::epErrorName)
    assert '[[ "${errorName}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    errorName=$(ksl::epErrorName)
    assert '[[ "${errorName}" == "" ]]'

    # put something readable in error name
    ksl::epSetErrorName "CommunicationsError"
    errorName=$(ksl::epErrorName)
    assert '[[ "${errorName}" == "CommunicationsError" ]]'

    # call with different EPS
    ksl::epCreate ep2
    errorName=$(ksl::epErrorName ep2)
    assert '[[ "${errorName}" == "" ]]'
    errorName=$(ksl::epErrorName ep1)
    assert '[[ "${errorName}" == "CommunicationsError" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSetErrorType()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetErrorType "ProcessingError")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetErrorType ep7 "ProcessingError")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetErrorType "ProcessingError"
    assert '[[ "${ep1[ERRTYPE]}" == "ProcessingError" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetErrorType ep1 "EquipmentError"
    assert '[[ "${ep1[ERRTYPE]}" == "EquipmentError" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetErrorType ep2 "TimeoutError")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetErrorType ep2 "TimeoutError"
    assert '[[ "${ep2[ERRTYPE]}" == "TimeoutError" ]]'
    assert '[[ "${ep1[ERRTYPE]}" == "EquipmentError" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epErrorType()
{
    # call with non-existant EPS
    local errorType
    unset ep1
    
    errorType=$(ksl::epErrorType)
    assert '[[ "${errorType}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    errorType=$(ksl::epErrorType)
    assert '[[ "${errorType}" == "" ]]'

    # put something readable in error type
    ksl::epSetErrorType "UnderflowError"
    errorType=$(ksl::epErrorType)
    assert '[[ "${errorType}" == "UnderflowError" ]]'

    # call with different EPS
    ksl::epCreate ep2
    errorType=$(ksl::epErrorType ep2)
    assert '[[ "${errorType}" == "" ]]'
    errorType=$(ksl::epErrorType ep1)
    assert '[[ "${errorType}" == "UnderflowError" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSetSeverity()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetSeverity "Critical")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetSeverity ep7 "Critical")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetSeverity "Critical"
    assert '[[ "${ep1[SEVERITY]}" == "Critical" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetSeverity ep1 "Major"
    assert '[[ "${ep1[SEVERITY]}" == "Major" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetSeverity ep2 "Major")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetSeverity ep2 "Warn"
    assert '[[ "${ep2[SEVERITY]}" == "Warn" ]]'
    assert '[[ "${ep1[SEVERITY]}" == "Major" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSeverity()
{
    # call with non-existant EPS
    local severity
    unset ep1
    
    severity=$(ksl::epSeverity)
    assert '[[ "${severity}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    severity=$(ksl::epSeverity)
    assert '[[ "${severity}" == "" ]]'

    # put something readable in error type
    ksl::epSetSeverity "Critical"
    severity=$(ksl::epSeverity)
    assert '[[ "${severity}" == "Critical" ]]'

    # call with different EPS
    ksl::epCreate ep2
    severity=$(ksl::epSeverity ep2)
    assert '[[ "${severity}" == "" ]]'
    severity=$(ksl::epSeverity ep1)
    assert '[[ "${severity}" == "Critical" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSetFuncName()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetFuncName "parse()")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetFuncName ep7 "parse()")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetFuncName "parse()"
    assert '[[ "${ep1[FUNC]}" == "parse()" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetFuncName ep1 "sort()"
    assert '[[ "${ep1[FUNC]}" == "sort()" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetFuncName ep2 "invert()")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetFuncName ep2 "invert()"
    assert '[[ "${ep2[FUNC]}" == "invert()" ]]'
    assert '[[ "${ep1[FUNC]}" == "sort()" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epFuncName()
{
    # call with non-existant EPS
    local funcName
    unset ep1
    
    funcName=$(ksl::epFuncName)
    assert '[[ "${funcName}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    funcName=$(ksl::epFuncName)
    assert '[[ "${funcName}" == "" ]]'

    # put something readable in error type
    ksl::epSetFuncName "sort()"
    funcName=$(ksl::epFuncName)
    assert '[[ "${funcName}" == "sort()" ]]'

    # call with different EPS
    ksl::epCreate ep2
    funcName=$(ksl::epFuncName ep2)
    assert '[[ "${funcName}" == "" ]]'
    funcName=$(ksl::epFuncName ep1)
    assert '[[ "${funcName}" == "sort()" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSetFileName()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetFileName "commands.bash")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetFileName ep7 "command.bash")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetFileName "commands.bash"
    assert '[[ "${ep1[FILE]}" == "commands.bash" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetFileName ep1 "constants.bash"
    assert '[[ "${ep1[FILE]}" == "constants.bash" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetFileName ep2 "sort.bash")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetFileName ep2 "sort.bash"
    assert '[[ "${ep2[FILE]}" == "sort.bash" ]]'
    assert '[[ "${ep1[FILE]}" == "constants.bash" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epFileName()
{
    # call with non-existant EPS
    local fileName
    unset ep1
    
    fileName=$(ksl::epFileName)
    assert '[[ "${fileName}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    fileName=$(ksl::epFileName)
    assert '[[ "${fileName}" == "" ]]'

    # put something readable in error type
    ksl::epSetFileName "commands.bash"
    fileName=$(ksl::epFileName)
    assert '[[ "${fileName}" == "commands.bash" ]]'

    # call with different EPS
    ksl::epCreate ep2
    fileName=$(ksl::epFileName ep2)
    assert '[[ "${fileName}" == "" ]]'
    fileName=$(ksl::epFileName ep1)
    assert '[[ "${fileName}" == "commands.bash" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSetLineNum()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetLineNum "100")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetLineNum ep7 "100")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetLineNum "100"
    assert '[[ "${ep1[LINENUM]}" == "100" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetLineNum ep1 "200"
    assert '[[ "${ep1[LINENUM]}" == "200" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetLineNum ep2 "300")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetLineNum ep2 "300"
    assert '[[ "${ep2[LINENUM]}" == "300" ]]'
    assert '[[ "${ep1[LINENUM]}" == "200" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epLineNum()
{
    # call with non-existant EPS
    local lineNum
    unset ep1
    
    lineNum=$(ksl::epLineNum)
    assert '[[ "${lineNum}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    lineNum=$(ksl::epLineNum)
    assert '[[ "${lineNum}" == "" ]]'

    # put something readable in error type
    ksl::epSetLineNum "100"
    lineNum=$(ksl::epLineNum)
    assert '[[ "${lineNum}" == "100" ]]'

    # call with different EPS
    ksl::epCreate ep2
    lineNum=$(ksl::epLineNum ep2)
    assert '[[ "${lineNum}" == "" ]]'
    lineNum=$(ksl::epLineNum ep1)
    assert '[[ "${lineNum}" == "100" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSetCodeNum()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetCodeNum "100")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetCodeNum ep7 "100")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetCodeNum "100"
    assert '[[ "${ep1[CODENUM]}" == "100" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetCodeNum ep1 "200"
    assert '[[ "${ep1[CODENUM]}" == "200" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetCodeNum ep2 "300")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetCodeNum ep2 "300"
    assert '[[ "${ep2[CODENUM]}" == "300" ]]'
    assert '[[ "${ep1[CODENUM]}" == "200" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epCodeNum()
{
    # call with non-existant EPS
    local codeNum
    unset ep1
    
    codeNum=$(ksl::epCodeNum)
    assert '[[ "${codeNum}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    codeNum=$(ksl::epCodeNum)
    assert '[[ "${codeNum}" == "" ]]'

    # put something readable in error type
    ksl::epSetCodeNum "100"
    codeNum=$(ksl::epCodeNum)
    assert '[[ "${codeNum}" == "100" ]]'

    # call with different EPS
    ksl::epCreate ep2
    codeNum=$(ksl::epCodeNum ep2)
    assert '[[ "${codeNum}" == "" ]]'
    codeNum=$(ksl::epCodeNum ep1)
    assert '[[ "${codeNum}" == "100" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSetCause()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetCause "hardware fault")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetCause ep7 "hardware fault")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetCause "hardware fault"
    assert '[[ "${ep1[CAUSE]}" == "hardware fault" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetCause ep1 "overheating"
    assert '[[ "${ep1[CAUSE]}" == "overheating" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetCause ep2 "operator error")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetCause ep2 "power outage"
    assert '[[ "${ep2[CAUSE]}" == "power outage" ]]'
    assert '[[ "${ep1[CAUSE]}" == "overheating" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epCause()
{
    # call with non-existant EPS
    local cause
    unset ep1
    
    cause=$(ksl::epCause)
    assert '[[ "${cause}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    cause=$(ksl::epCause)
    assert '[[ "${cause}" == "" ]]'

    # put something readable in error type
    ksl::epSetCause "100"
    cause=$(ksl::epCause)
    assert '[[ "${cause}" == "100" ]]'

    # call with different EPS
    ksl::epCreate ep2
    cause=$(ksl::epCause ep2)
    assert '[[ "${cause}" == "" ]]'
    cause=$(ksl::epCause ep1)
    assert '[[ "${cause}" == "100" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epSetRepair()
{
    local -i ret
    local diag
    
    # Consume known error diags by assigning to diag 
    # variable so as to ignore them.
    
    # call with bad EPS
    unset ep1
    diag=$(ksl::epSetRepair "turn power on")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    diag=$(ksl::epSetRepair ep7 "turn power on")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetRepair "turn power on"
    assert '[[ "${ep1[REPAIR]}" == "turn power on" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetRepair ep1 "recycle power"
    assert '[[ "${ep1[REPAIR]}" == "recycle power" ]]'

    # put value for non-existent EPS
    diag=$(ksl::epSetRepair ep2 "replace temperature gauge")
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetRepair ep2 "replace sensor"
    assert '[[ "${ep2[REPAIR]}" == "replace sensor" ]]'
    assert '[[ "${ep1[REPAIR]}" == "recycle power" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

test_epRepair()
{
    # call with non-existant EPS
    local repair
    unset ep1
    
    repair=$(ksl::epRepair)
    assert '[[ "${repair}" == "epGetField() no such EPS:ep1" ]]'
    
    # call with existing EPS
    ksl::epCreate ep1
    repair=$(ksl::epRepair)
    assert '[[ "${repair}" == "" ]]'

    # put something readable in error type
    ksl::epSetRepair "100"
    repair=$(ksl::epRepair)
    assert '[[ "${repair}" == "100" ]]'

    # call with different EPS
    ksl::epCreate ep2
    repair=$(ksl::epRepair ep2)
    assert '[[ "${repair}" == "" ]]'
    repair=$(ksl::epRepair ep1)
    assert '[[ "${repair}" == "100" ]]'

    unset ep1
    unset ep2
}

# -----------------------------------------------------------

