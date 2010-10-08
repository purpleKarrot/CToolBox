
find_program(DEBUILD_EXECUTABLE debuild)
find_program(DPUT_EXECUTABLE dput)

if(NOT DEBUILD_EXECUTABLE OR NOT DPUT_EXECUTABLE)
  return()
endif(NOT DEBUILD_EXECUTABLE OR NOT DPUT_EXECUTABLE)

# DEBIAN/control
# debian policy enforce lower case for package name
# Package: (mandatory)
IF(NOT CPACK_DEBIAN_PACKAGE_NAME)
  STRING(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_DEBIAN_PACKAGE_NAME)
ENDIF(NOT CPACK_DEBIAN_PACKAGE_NAME)

# Section: (recommended)
IF(NOT CPACK_DEBIAN_PACKAGE_SECTION)
  SET(CPACK_DEBIAN_PACKAGE_SECTION "devel")
ENDIF(NOT CPACK_DEBIAN_PACKAGE_SECTION)

# Priority: (recommended)
IF(NOT CPACK_DEBIAN_PACKAGE_PRIORITY)
  SET(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
ENDIF(NOT CPACK_DEBIAN_PACKAGE_PRIORITY )

set(DEBIAN_SOURCE_DIR ${CMAKE_BINARY_DIR}/Debian/${CPACK_DEBIAN_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-source)
execute_process(COMMAND ${CMAKE_COMMAND} -E
  copy_directory ${CMAKE_SOURCE_DIR} ${DEBIAN_SOURCE_DIR}
  )

file(MAKE_DIRECTORY ${DEBIAN_SOURCE_DIR}/debian)

##############################################################################
# debian/control
set(DEBIAN_CONTROL ${DEBIAN_SOURCE_DIR}/debian/control)
file(WRITE ${DEBIAN_CONTROL}
  "Source: ${CPACK_DEBIAN_PACKAGE_NAME}\n"
  "Section: ${CPACK_DEBIAN_PACKAGE_SECTION}\n"
  "Priority: ${CPACK_DEBIAN_PACKAGE_PRIORITY}\n"
  "Maintainer: ${CPACK_PACKAGE_CONTACT}\n"
  "Build-Depends: "
  )

foreach(DEP ${CPACK_DEBIAN_BUILD_DEPENDS})
  file(APPEND ${DEBIAN_CONTROL} "${DEP}, ")
endforeach(DEP ${CPACK_DEBIAN_BUILD_DEPENDS})  

file(APPEND ${DEBIAN_CONTROL} "cmake\n"
  "Standards-Version: 3.8.4\n"
  "Homepage: ${CPACK_PACKAGE_VENDOR}\n"
  "\n"
  "Package: ${CPACK_DEBIAN_PACKAGE_NAME}\n"
  "Architecture: any\n"
  "Depends: \${shlibs:Depends}\n"
  "Description: ${CPACK_PACKAGE_DESCRIPTION_SUMMARY}\n"
  )

# split desc in lines
# for each line print " line"

#		for (std::map<std::string, cmCPackComponentGroup>::iterator it =
#			this->ComponentGroups.begin(); it != this->ComponentGroups.end(); ++it)
#		{
#			const cmCPackComponentGroup& group = it->second;
#
#			control << "Package: " << name << '-' << group.Name << std::endl;
#			control << "Architecture: any\n";
#			control << "Description: " << summary << ": " << group.DisplayName;
#			control << "\n ";
#			std::copy(desc.begin(), desc.end(), //
#				std::ostream_iterator<cmStdString>(control, "\n "));
#			control << ".\n ";
#
#			std::vector<cmStdString> group_desc;
#			cmSystemTools::Split(group.Description.c_str(), group_desc);
#			std::copy(group_desc.begin(), group_desc.end(), //
#				std::ostream_iterator<cmStdString>(control, "\n "));
#			control << std::endl;
#		}
#	}

##############################################################################
# debian/copyright
set(DEBIAN_COPYRIGHT ${DEBIAN_SOURCE_DIR}/debian/copyright)
execute_process(COMMAND ${CMAKE_COMMAND} -E
  copy ${CPACK_RESOURCE_FILE_LICENSE} ${DEBIAN_COPYRIGHT}
  )

##############################################################################
# debian/rules
set(DEBIAN_RULES ${DEBIAN_SOURCE_DIR}/debian/rules)
file(WRITE ${DEBIAN_RULES}
  "#!/usr/bin/make -f\n"
  "\n"
  "BUILDDIR = build_dir\n"
  "\n"
  "build:\n"
  "	mkdir $(BUILDDIR)\n"
  "	cd $(BUILDDIR); cmake ..\n"
  "	make -C $(BUILDDIR) preinstall\n"
  "	touch build\n"
  "\n"
  "binary: binary-indep binary-arch\n"
  "\n"
  "binary-indep: build\n"
  "\n"
  "binary-arch: build\n"
  )

foreach(COMPONENT ${CPACK_COMPONENTS_ALL})
  file(APPEND ${DEBIAN_RULES}
    "	cd $(BUILDDIR); cmake"
    " -DCOMPONENT=${COMPONENT}"
    " -DCMAKE_INSTALL_PREFIX=../debian/tmp/usr"
    " -P cmake_install.cmake\n"
    )
endforeach(COMPONENT ${CPACK_COMPONENTS_ALL})

file(APPEND ${DEBIAN_RULES}
  "	mkdir debian/tmp/DEBIAN\n"
  "	dpkg-gencontrol\n"
  "	dpkg --build debian/tmp ..\n\n"
  "clean:\n"
  "	rm -f build\n"
  "	rm -rf $(BUILDDIR)\n"
  "\n"
  ".PHONY: binary binary-arch binary-indep clean\n"
  )

execute_process(COMMAND chmod +x ${DEBIAN_RULES})

##############################################################################
# debian/compat
file(WRITE ${DEBIAN_SOURCE_DIR}/debian/compat "7")

##############################################################################
# debian/source/format
file(WRITE ${DEBIAN_SOURCE_DIR}/debian/source/format "3.0 (native)")

##############################################################################
# debian/changelog
set(DEBIAN_CHANGELOG ${DEBIAN_SOURCE_DIR}/debian/changelog)
execute_process(COMMAND date -R  OUTPUT_VARIABLE DATE_TIME)
file(WRITE ${DEBIAN_CHANGELOG}
  "${CPACK_DEBIAN_PACKAGE_NAME} (${CPACK_PACKAGE_VERSION}) maverick; urgency=low\n\n"
  "  * Package built with CMake\n\n"
  " -- ${CPACK_PACKAGE_CONTACT}  ${DATE_TIME}"
  )

##############################################################################
# debuild -S
set(DEB_SOURCE_CHANGES
  ${CPACK_DEBIAN_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}_source.changes
  )

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/Debian/${DEB_SOURCE_CHANGES}
  COMMAND ${DEBUILD_EXECUTABLE} -S
  WORKING_DIRECTORY ${DEBIAN_SOURCE_DIR}
  )

##############################################################################
# dput ppa:your-lp-id/ppa <source.changes>
add_custom_target(dput ${DPUT_EXECUTABLE} ${DPUT_HOST} ${DEB_SOURCE_CHANGES}
  DEPENDS ${CMAKE_BINARY_DIR}/Debian/${DEB_SOURCE_CHANGES}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/Debian
  )
