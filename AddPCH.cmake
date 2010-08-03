

macro(ADD_PCH VARIABLE HEADER)

  set(${VARIABLE} "${HEADER}.gch")

  set(ARGS ${CMAKE_CXX_FLAGS})
  list(APPEND ARGS -c ${HEADER} -o ${${VARIABLE}})

  get_directory_property(INCDIRS INCLUDE_DIRECTORIES)

  foreach(DIR ${INCDIRS})
    list(APPEND ARGS -I${DIR})
  endforeach(DIR ${INCDIRS})

  separate_arguments(ARGS)
  add_custom_command(OUTPUT ${${VARIABLE}}
    COMMAND rm -f ${${VARIABLE}}
    COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1} ${ARGS}
    DEPENDS ${HEADER})

endmacro(ADD_PCH VARIABLE HEADER)

