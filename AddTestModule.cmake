
# http://svn.boost.org/svn/boost/trunk/libs/test/doc/src/UTF.log.xsd
# http://svn.boost.org/svn/boost/trunk/libs/test/doc/src/UTF.report.xsd

set(TEST_MODULE_FLAGS
  --log_level=all
  --report_level=no
  --result_code=no
  )

find_package(Boost 1.40.0 REQUIRED
  COMPONENTS unit_test_framework
  )


#   add_test_module(name source1 [source2 [source3 [...]]])
#
# This macro defines the following variables: 
#
#   NAME_EXECUTABLE  location of the test module executable
#   NAME_LOG_XML     location of the xml file containing the test log
#   NAME_REPORT_XML  location of the xml file containing the test report
#

macro(ADD_TEST_MODULE NAME)

  set(MAIN_CPP ${CMAKE_CURRENT_BINARY_DIR}/${NAME}_main.cpp)

  file(WRITE ${MAIN_CPP} "#define BOOST_TEST_MODULE ${name}\n")

  if(NOT Boost_USE_STATIC_LIBS)
    file(APPEND ${MAIN_CPP} "#define BOOST_TEST_DYN_LINK\n")
  endif(NOT Boost_USE_STATIC_LIBS)

  file(APPEND ${MAIN_CPP} "#include <boost/test/unit_test.hpp>\n")

  add_executable(${NAME} EXCLUDE_FROM_ALL ${MAIN_CPP} ${ARGN})
  
  target_link_libraries(${NAME} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
  
  set(${NAME}_LOG_XML    ${CMAKE_CURRENT_BINARY_DIR}/${NAME}_log.xml)
  set(${NAME}_REPORT_XML ${CMAKE_CURRENT_BINARY_DIR}/${NAME}_report.xml)
  get_target_property(${NAME}_EXECUTABLE ${NAME} LOCATION)

  add_custom_command(
    OUTPUT
      ${${NAME}_LOG_XML}
      ${${NAME}_REPORT_XML}
    COMMAND
      ${${NAME}_EXECUTABLE} ${TEST_MODULE_FLAGS}
        1> ${${NAME}_LOG_XML} 
        2> ${${NAME}_REPORT_XML}
    DEPENDS
      ${TEST_MODULE_EXECUTABLE}
    COMMENT
      "Running test module ${NAME}."
    )

endmacro(ADD_TEST_MODULE NAME)
