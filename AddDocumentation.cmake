include(ParseArguments)
include(XSLTransform)
find_package(BoostBook REQUIRED)
find_package(DBLaTeX   REQUIRED)

# Transform Quickbook into BoostBook XML
macro(add_documentation INPUT)

  # If INPUT is not a full path, it's in the current source directory.
  get_filename_component(INPUT_PATH ${INPUT} PATH)
  if(INPUT_PATH STREQUAL "")
    set(INPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${INPUT}")
  else(INPUT_PATH STREQUAL "")
    set(INPUT_PATH ${INPUT})
  endif(INPUT_PATH STREQUAL "")

  set(QBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.qbk)
  set(DBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.docbook)
  set(PDF_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.pdf)

  # copy to destination directory because quickbook screws up xinclude paths 
  # when the output is not in the source directory
  add_custom_command(OUTPUT ${QBK_FILE}
    COMMAND ${CMAKE_COMMAND} -E copy ${INPUT_PATH} ${QBK_FILE}
    DEPENDS ${INPUT_PATH})
    
  # copy all dependencies that are not built
  set(DEPENDENCIES)
  foreach(file ${ARGN})
    set(srcfile ${CMAKE_CURRENT_SOURCE_DIR}/${file})
    set(binfile ${CMAKE_CURRENT_BINARY_DIR}/${file})
    if(EXISTS ${srcfile})
      add_custom_command(OUTPUT ${binfile}
        COMMAND ${CMAKE_COMMAND} -E copy ${srcfile} ${binfile}
        DEPENDS ${srcfile})
    endif(EXISTS ${srcfile})
    set(DEPENDENCIES ${DEPENDENCIES} ${binfile})
  endforeach(file ${ARGN})

  quickbook_to_docbook(${DBK_FILE} ${QBK_FILE} ${DEPENDENCIES})

  xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/html ${DBK_FILE}
    STYLESHEET ${BOOSTBOOK_XSL_DIR}/html.xsl
    CATALOG ${BOOSTBOOK_CATALOG}
    DIRECTORY HTML.manifest
    COMMENT "Generating HTML documentaiton for ${THIS_PROJECT_NAME}."
    MAKE_TARGET ${THIS_PROJECT_NAME}-html)

  xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/man ${DBK_FILE}
    STYLESHEET ${BOOSTBOOK_XSL_DIR}/manpages.xsl
    CATALOG ${BOOSTBOOK_CATALOG}
    DIRECTORY man.manifest
    COMMENT "Generating man pages for ${THIS_PROJECT_NAME}."
    MAKE_TARGET ${THIS_PROJECT_NAME}-man)

  add_custom_command(OUTPUT ${PDF_FILE}
    COMMAND ${DBLATEX_EXECUTABLE} -o ${PDF_FILE} ${DBK_FILE}
    DEPENDS ${DBK_FILE})
  add_custom_target(${THIS_PROJECT_NAME}-pdf DEPENDS ${PDF_FILE})
  set_target_properties(${THIS_PROJECT_NAME}-pdf
    PROPERTIES EXCLUDE_FROM_ALL ON)

endmacro(add_documentation INPUT)
