# Copyright (c) 2010 Daniel Pfeifer <daniel@pfeifer-mail.de>

include(ParseArguments)

macro(PURPLE_LIBRARY NAME)
  string(TOUPPER ${NAME} UPPER_NAME)

  parse_arguments(THIS_LIB
    "SOURCES;HEADERS;DEPENDS"
    "SHARED;STATIC"
    ${ARGN}
    )

  if(NOT THIS_LIB_SHARED AND NOT THIS_LIB_STATIC)
    set(THIS_LIB_SHARED ON)
    set(THIS_LIB_STATIC ON)
  endif(NOT THIS_LIB_SHARED AND NOT THIS_LIB_STATIC)

  if(MSVC)
    list(APPEND THIS_LIB_SOURCES ${THIS_LIB_HEADERS})
  endif(MSVC)

  set(THIS_LIB_TARGETS)

  if(THIS_LIB_SHARED)
    set(THIS_LIB_TARGET lib_${NAME}_shared)
    list(APPEND THIS_LIB_TARGETS ${THIS_LIB_TARGET})

    #set(THIS_LIB_LINK_LIBRARIES)
    #foreach(DEP ${THIS_LIB_DEPENDS})
    #  if(TARGET lib_${DEP}_shared)
    #    list(APPEND THIS_LIB_LINK_LIBRARIES lib_${DEP}_shared)
    #  elseif(TARGET lib_${DEP}_static)
    #    list(APPEND THIS_LIB_LINK_LIBRARIES lib_${DEP}_static)
    #  else(TARGET lib_${DEP}_shared)
    #    list(APPEND THIS_LIB_LINK_LIBRARIES ${DEP})
    #  endif(TARGET lib_${DEP}_shared)
    #endforeach(DEP ${THIS_LIB_DEPENDS})

    add_library(${THIS_LIB_TARGET} SHARED ${THIS_LIB_SOURCES})

    set_target_properties(${THIS_LIB_TARGET} PROPERTIES
      OUTPUT_NAME ${NAME} COMPILE_DEFINITIONS ${UPPER_NAME}_SHARED)

    target_link_libraries(${THIS_LIB_TARGET} ${THIS_LIB_DEPENDS})
  endif(THIS_LIB_SHARED)

  if(THIS_LIB_STATIC)
    set(THIS_LIB_TARGET lib_${NAME}_static)
    list(APPEND THIS_LIB_TARGETS ${THIS_LIB_TARGET})

    add_library(${THIS_LIB_TARGET} STATIC ${THIS_LIB_SOURCES})

    set_target_properties(${THIS_LIB_TARGET} PROPERTIES
      OUTPUT_NAME ${NAME} COMPILE_DEFINITIONS ${UPPER_NAME}_STATIC PREFIX lib) 
  endif(THIS_LIB_STATIC)

  install(TARGETS ${THIS_LIB_TARGETS}
    ARCHIVE DESTINATION lib COMPONENT dev
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    )
endmacro(PURPLE_LIBRARY NAME)
