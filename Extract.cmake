
find_program(7Z_EXECUTABLE 7z $ENV{ProgramFiles}/7-Zip)
find_program(UNZIP_EXECUTABLE unzip)

function(EXTRACT ARCHIVE DIRECTORY)
  file(MAKE_DIRECTORY ${DIRECTORY})

  if(7Z_EXECUTABLE)
    execute_process(COMMAND ${7Z_EXECUTABLE} x -y ${ARCHIVE}
      WORKING_DIRECTORY ${DIRECTORY} OUTPUT_QUIET)

  elseif(UNZIP_EXECUTABLE)
    execute_process(COMMAND ${UNZIP_EXECUTABLE} -o ${ARCHIVE}
      WORKING_DIRECTORY ${DIRECTORY} OUTPUT_QUIET)

  else()
    message(FATAL_ERROR "cannot extract ${ARCHIVE}")

  endif()
endfunction(EXTRACT ARCHIVE DIRECTORY)
