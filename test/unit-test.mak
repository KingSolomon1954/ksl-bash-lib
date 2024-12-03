# -------------------------------------------------------
#
# Submake to run unit tests
#
# -------------------------------------------------------

ifndef _INCLUDE_UNIT_TEST_MAK
_INCLUDE_UNIT_TEST_MAK := 1

ifndef D_TOOLS
    $(error Parent makefile must define 'D_TOOLS')
endif

bash_unit_exec := $(D_TOOLS)/bash-unit/bash_unit
# https://github.com/pgrange/bash_unit

UNIT_TESTS := \
	test/libArraysTest.bash \
	test/libColorsTest.bash \
	test/libEnvTest.bash \
	test/libErrorTest.bash \
	test/libFilesTest.bash \
	test/libStdOutTest.bash \
	test/libStringsTest.bash

unit-tests \
unit-test:
	KSL_BASH_LIB=$(PWD)/lib $(bash_unit_exec) $(UNIT_TESTS)

.PHONY: unit-test unit-tests

# ------------ Help Section ------------

HELP_TXT += "\n\
unit-tests, runs unit tests\n\
unit-test,  runs unit tests\n\
"

endif
