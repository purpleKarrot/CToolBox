
find_package(Wget REQUIRED)

set(CTOOLBOX_DIR ${CMAKE_BINARY_DIR}/CToolBox)

if(NOT EXISTS ${CTOOLBOX_DIR})

  execute_process(COMMAND ${WGET_EXECUTABLE}
    http://github.com/purpleKarrot/CToolBox/tarball/master)

  file(GLOB CTOOLBOX_TGZ ${CMAKE_BINARY_DIR}/purpleKarrot-CToolBox-*.tar.gz)
  execute_process(COMMAND tar -zxvf ${CTOOLBOX_TGZ})
    
  get_filename_component(CTOOLBOX_NWE "${CTOOLBOX_TGZ}" NAME_WE)
  file(RENAME ${CMAKE_BINARY_DIR}/${CTOOLBOX_NWE} ${CTOOLBOX_DIR})

  execute_process(COMMAND rm ${CTOOLBOX_TGZ})

endif(NOT EXISTS ${CTOOLBOX_DIR})

list(APPEND CMAKE_MODULE_PATH ${CTOOLBOX_DIR})
