
include(ParseArguments)
include(XSLTransform)
find_package(BoostBook)

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
  set(XML_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.xml)
  set(DBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.docbook)

  # copy to destination directory because quickbook screws up xinclude paths 
  # when the output is not in the source directory
  add_custom_command(OUTPUT ${QBK_FILE}
    COMMAND ${CMAKE_COMMAND} -E copy ${INPUT_PATH} ${QBK_FILE}
    DEPENDS ${INPUT_PATH})

  add_custom_command(OUTPUT ${XML_FILE}
    COMMAND quickbook "--output-file=${XML_FILE}" ${QBK_FILE}
    DEPENDS ${QBK_FILE} ${ARGN})
    
  xsl_transform(${DBK_FILE} ${XML_FILE}
    STYLESHEET ${BOOSTBOOK_XSL_DIR}/docbook.xsl
    CATALOG ${BOOSTBOOK_CATALOG}
    COMMENT "Generating DocBook from ${XML_FILE}."
    DEPENDS ${XML_FILE}
    )

  xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/html ${DBK_FILE}
    STYLESHEET ${BOOSTBOOK_XSL_DIR}/html.xsl
    CATALOG ${BOOSTBOOK_CATALOG}
    DIRECTORY HTML.manifest
    COMMENT "Generating HTML documentaiton for ${THIS_PROJECT_NAME}."
    MAKE_ALL_TARGET ${THIS_PROJECT_NAME}-html
    )

# xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/man ${DBK_FILE}
#   STYLESHEET ${BOOSTBOOK_XSL_DIR}/manpages.xsl
#   CATALOG ${CMAKE_BINARY_DIR}/catalog.xml
#   DIRECTORY man.manifest
#   COMMENT "Generating man pages for ${THIS_PROJECT_NAME}."
#   MAKE_ALL_TARGET ${THIS_PROJECT_NAME}-man)

endmacro(add_documentation INPUT)
