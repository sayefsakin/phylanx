# Copyright (c) 2019 Hartmut Kaiser
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

function(add_phylanx_library name)
  # retrieve arguments
  set(options EXCLUDE_FROM_ALL NOLIBS AUTOGLOB STATIC PLUGIN NONAMEPREFIX)
  set(one_value_args FOLDER SOURCE_ROOT HEADER_ROOT SOURCE_GLOB HEADER_GLOB OUTPUT_SUFFIX INSTALL_SUFFIX)
  set(multi_value_args SOURCES HEADERS AUXILIARY DEPENDENCIES COMPONENT_DEPENDENCIES COMPILER_FLAGS LINK_FLAGS)
  cmake_parse_arguments(${name} "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(NOT ${name}_SOURCE_ROOT)
    set(${name}_SOURCE_ROOT ".")
  endif()
  phylanx_debug("add_library.${name}" "${name}_SOURCE_ROOT: ${${name}_SOURCE_ROOT}")

  if(NOT ${name}_HEADER_ROOT)
    set(${name}_HEADER_ROOT ".")
  endif()
  phylanx_debug("add_library.${name}" "${name}_HEADER_ROOT: ${${name}_HEADER_ROOT}")

  if(${${name}_AUTOGLOB})
    if(NOT ${name}_SOURCE_GLOB)
      set(${name}_SOURCE_GLOB "${${name}_SOURCE_ROOT}/*.cpp")
    endif()
    phylanx_debug("add_library.${name}" "${name}_SOURCE_GLOB: ${${name}_SOURCE_GLOB}")

    add_phylanx_library_sources(${name}
      GLOB_RECURSE GLOBS "${${name}_SOURCE_GLOB}")

    set(${name}_SOURCES ${${name}_SOURCES})
    add_phylanx_source_group(
      NAME ${name}
      CLASS "Source Files"
      ROOT ${${name}_SOURCE_ROOT}
      TARGETS ${${name}_SOURCES})

    if(NOT ${name}_HEADER_GLOB)
      set(${name}_HEADER_GLOB "${${name}_HEADER_ROOT}/*.hpp"
                              "${${name}_HEADER_ROOT}/*.h")
    endif()
    phylanx_debug("add_library.${name}" "${name}_HEADER_GLOB: ${${name}_HEADER_GLOB}")

    add_phylanx_library_headers(${name}
      GLOB_RECURSE GLOBS "${${name}_HEADER_GLOB}")

    set(${name}_HEADERS ${${name}_HEADERS})
    add_phylanx_source_group(
      NAME ${name}
      CLASS "Header Files"
      ROOT ${${name}_HEADER_ROOT}
      TARGETS ${${name}_HEADERS})
  else()
    add_phylanx_library_sources_noglob(${name}
        SOURCES "${${name}_SOURCES}")

    add_phylanx_source_group(
      NAME ${name}
      CLASS "Source Files"
      ROOT ${${name}_SOURCE_ROOT}
      TARGETS ${${name}_SOURCES})

    add_phylanx_library_headers_noglob(${name}
        HEADERS "${${name}_HEADERS}")

    add_phylanx_source_group(
      NAME ${name}
      CLASS "Header Files"
      ROOT ${${name}_HEADER_ROOT}
      TARGETS ${${name}_HEADERS})
  endif()

  phylanx_debug("DEBUG" "add_library.${name}" "Sources for ${name}" ${name}_SOURCES)
  phylanx_debug("DEBUG" "add_library.${name}" "Headers for ${name}" ${name}_HEADERS)
  phylanx_debug("DEBUG" "add_library.${name}" "Dependencies for ${name}" ${name}_DEPENDENCIES)
  phylanx_debug("DEBUG" "add_library.${name}" "Component dependencies for ${name}" ${name}_COMPONENT_DEPENDENCIES)
  phylanx_debug("Add primitive plugin ${name}: ${name}_HEADER_ROOT:" ${${name}_HEADER_ROOT})
  phylanx_debug("Add primitive plugin ${name}: ${name}_SOURCE_ROOT:" ${${name}_SOURCE_ROOT})

  set(exclude_from_all)
  set(install_options)
  if(${name}_EXCLUDE_FROM_ALL)
    set(exclude_from_all EXCLUDE_FROM_ALL)
  else()
    if(${name}_PLUGIN AND NOT PHYLANX_WITH_STATIC_LINKING)
      if(MSVC)
        set(library_install_destination ${CMAKE_INSTALL_BINDIR}/phylanx)
      else()
        set(library_install_destination ${CMAKE_INSTALL_LIBDIR}/phylanx)
      endif()
      set(archive_install_destination ${CMAKE_INSTALL_LIBDIR}/phylanx)
      set(runtime_install_destination ${CMAKE_INSTALL_BINDIR}/phylanx)
      set(${name}_OUTPUT_SUFFIX phylanx)
    else()
      if(MSVC)
        set(library_install_destination ${CMAKE_INSTALL_BINDIR})
      else()
        set(library_install_destination ${CMAKE_INSTALL_LIBDIR})
      endif()
      set(archive_install_destination ${CMAKE_INSTALL_LIBDIR})
      set(runtime_install_destination ${CMAKE_INSTALL_BINDIR})
    endif()
    if(${name}_INSTALL_SUFFIX)
      set(library_install_destination ${${name}_INSTALL_SUFFIX})
      set(archive_install_destination ${${name}_INSTALL_SUFFIX})
      set(runtime_install_destination ${${name}_INSTALL_SUFFIX})
    endif()
    set(_target_flags
      INSTALL
      INSTALL_FLAGS
        LIBRARY DESTINATION ${library_install_destination}
        ARCHIVE DESTINATION ${archive_install_destination}
        RUNTIME DESTINATION ${runtime_install_destination}
    )
  endif()

  if(${name}_PLUGIN)
    set(_target_flags ${_target_flags} PLUGIN)
  endif()
  if(${name}_NONAMEPREFIX)
    set(_target_flags ${_target_flags} NONAMEPREFIX)
  endif()

  if(${name}_STATIC)
    set(${name}_linktype STATIC)
  else()
    if(HPX_WITH_STATIC_LINKING)
      set(${name}_linktype STATIC)
    else()
      set(${name}_linktype SHARED)
    endif()
  endif()

  # Manage files with .cu extension in case When Cuda Clang is used
  if(PHYLANX_WITH_CUDA_CLANG)
    foreach(source ${${name}_SOURCES})
      get_filename_component(extension ${source} EXT)
      if(${extension} STREQUAL ".cu")
        SET_SOURCE_FILES_PROPERTIES(${source} PROPERTIES
          LANGUAGE CXX)
      endif()
    endforeach()
  endif()

  if(PHYLANX_WITH_CUDA AND NOT PHYLANX_WITH_CUDA_CLANG)
    cuda_add_library(${name} ${${name}_linktype} ${exclude_from_all}
      ${${name}_SOURCES} ${${name}_HEADERS} ${${name}_AUXILIARY})
  else()
    add_library(${name} ${${name}_linktype} ${exclude_from_all}
      ${${name}_SOURCES} ${${name}_HEADERS} ${${name}_AUXILIARY})
  endif()

  if(${name}_OUTPUT_SUFFIX)
    if(MSVC)
      set_target_properties(${name} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/Release/bin/${${name}_OUTPUT_SUFFIX}"
        LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/Release/lib/${${name}_OUTPUT_SUFFIX}"
        ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/Release/lib/${${name}_OUTPUT_SUFFIX}"
        RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/Debug/bin/${${name}_OUTPUT_SUFFIX}"
        LIBRARY_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/Debug/lib/${${name}_OUTPUT_SUFFIX}"
        ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/Debug/lib/${${name}_OUTPUT_SUFFIX}"
        RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_BINARY_DIR}/MinSizeRel/bin/${${name}_OUTPUT_SUFFIX}"
        LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_BINARY_DIR}/MinSizeRel/lib/${${name}_OUTPUT_SUFFIX}"
        ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_BINARY_DIR}/MinSizeRel/lib/${${name}_OUTPUT_SUFFIX}"
        RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/RelWithDebInfo/bin/${${name}_OUTPUT_SUFFIX}"
        LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/RelWithDebInfo/lib/${${name}_OUTPUT_SUFFIX}"
        ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/RelWithDebInfo/lib/${${name}_OUTPUT_SUFFIX}")
    else()
      set_target_properties(${name} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/${${name}_OUTPUT_SUFFIX}"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/${${name}_OUTPUT_SUFFIX}"
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/${${name}_OUTPUT_SUFFIX}")
    endif()
  endif()

  # get public and private compile options that hpx needs
  if(${${name}_NOLIBS})
    set(_target_flags ${_target_flags} NOLIBS)
  endif()

  phylanx_setup_target(
    ${name}
    TYPE LIBRARY
    NAME ${name}
    EXPORT
    FOLDER ${${name}_FOLDER}
    COMPILE_FLAGS ${${name}_COMPILE_FLAGS}
    LINK_FLAGS ${${name}_LINK_FLAGS}
    DEPENDENCIES ${${name}_DEPENDENCIES}
    COMPONENT_DEPENDENCIES ${${name}_COMPONENT_DEPENDENCIES}
    ${_target_flags}
    ${install_optional}
  )

  target_link_libraries(${name}
    PUBLIC ${BLAS_LIBRARIES} ${LAPACK_LIBRARIES})
  target_link_libraries(${name}
    PRIVATE blaze::blaze BlazeTensor::BlazeTensor)

endfunction()

