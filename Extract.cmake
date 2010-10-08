# Copyright (c) 2010 Daniel Pfeifer <daniel@pfeifer-mail.de>

function(EXTRACT ARCHIVE DIRECTORY)
  if(NOT IS_ABSOLUTE ${ARCHIVE})
    set(ARCHIVE ${CMAKE_CURRENT_SOURCE_DIR}/${ARCHIVE})
  endif(NOT IS_ABSOLUTE ${ARCHIVE})

  get_filename_component(NAME ${ARCHIVE} NAME)
  set(EXTRACTED ${CMAKE_CURRENT_BINARY_DIR}/${NAME}.extracted)

  if(NOT EXISTS ${EXTRACTED})
    message(STATUS "Extracting: ${ARCHIVE}")
    file(MAKE_DIRECTORY ${DIRECTORY})
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE}
      WORKING_DIRECTORY ${DIRECTORY} RESULT_VARIABLE RESULT)
    if(RESULT EQUAL 0)
      file(WRITE ${EXTRACTED} "ok")
    endif(RESULT EQUAL 0)
  endif(NOT EXISTS ${EXTRACTED})
endfunction(EXTRACT ARCHIVE DIRECTORY)
