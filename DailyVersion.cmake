
if(WIN32)
  # TODO: will give wrong results for US locale on Windows
  execute_process(COMMAND date /T
    OUTPUT_VARIABLE DATE OUTPUT_STRIP_TRAILING_WHITESPACE)
else(WIN32)
  execute_process(COMMAND date +%d/%m/%Y
    OUTPUT_VARIABLE DATE OUTPUT_STRIP_TRAILING_WHITESPACE)
endif(WIN32)

string(REGEX REPLACE "..[./]..[./]..(..)" "\\1" VERSION_MAJOR ${DATE})
string(REGEX REPLACE "..[./](..)[./]...." "\\1" VERSION_MINOR ${DATE})
string(REGEX REPLACE "(..)[./]..[./]...." "\\1" VERSION_PATCH ${DATE})

set(VERSION ${MAJOR}.${MINOR}.${PATCH})
