################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

find_program(DBLATEX_EXECUTABLE dblatex)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DBLaTeX DEFAULT_MSG DBLATEX_EXECUTABLE)
