# -*- mode: cmake; -*-
# - Try to find rocksdb include dirs and libraries
# Usage of this module as follows:
# This file defines:
# * ROCKSDB_FOUND if protoc was found
# * ROCKSDB_LIBRARY The lib to link to (currently only a static unix lib, not
# portable)
# * ROCKSDB_INCLUDE The include directories for rocksdb.

include(FindPackageHandleStandardArgs)

# set defaults
SET(_rocksdb_HOME "/opt/rocksdb")
SET(_rocksdb_INCLUDE_SEARCH_DIRS
  ${CMAKE_INCLUDE_PATH}
  /usr/local/include
  /usr/include
  /opt/rocksdb/include
)

SET(_rocksdb_LIBRARIES_SEARCH_DIRS
  ${CMAKE_LIBRARY_PATH}
  /usr/local/lib
  /usr/lib
  /opt/rocksdb
)

##
if( "${ROCKSDB_HOME}" STREQUAL "")
  if("" MATCHES "$ENV{ROCKSDB_HOME}")
    set (ROCKSDB_HOME ${_rocksdb_HOME})
  else("" MATCHES "$ENV{ROCKSDB_HOME}")
    set (ROCKSDB_HOME "$ENV{ROCKSDB_HOME}")
  endif("" MATCHES "$ENV{ROCKSDB_HOME}")
else( "${ROCKSDB_HOME}" STREQUAL "")
  message(STATUS "ROCKSDB_HOME is not empty: \"${ROCKSDB_HOME}\"")
endif( "${ROCKSDB_HOME}" STREQUAL "")
##

IF( NOT ${ROCKSDB_HOME} STREQUAL "" )
  SET(_rocksdb_INCLUDE_SEARCH_DIRS ${ROCKSDB_HOME}/include ${_rocksdb_INCLUDE_SEARCH_DIRS})
  SET(_rocksdb_LIBRARIES_SEARCH_DIRS ${ROCKSDB_HOME}/lib ${_rocksdb_LIBRARIES_SEARCH_DIRS})
  SET(_rocksdb_HOME ${ROCKSDB_HOME})
ENDIF( NOT ${ROCKSDB_HOME} STREQUAL "" )

IF( NOT $ENV{ROCKSDB_INCLUDEDIR} STREQUAL "" )
  SET(_rocksdb_INCLUDE_SEARCH_DIRS $ENV{ROCKSDB_INCLUDEDIR} ${_rocksdb_INCLUDE_SEARCH_DIRS})
ENDIF( NOT $ENV{ROCKSDB_INCLUDEDIR} STREQUAL "" )

IF( NOT $ENV{ROCKSDB_LIBRARYDIR} STREQUAL "" )
  SET(_rocksdb_LIBRARIES_SEARCH_DIRS $ENV{ROCKSDB_LIBRARYDIR} ${_rocksdb_LIBRARIES_SEARCH_DIRS})
ENDIF( NOT $ENV{ROCKSDB_LIBRARYDIR} STREQUAL "" )

IF( ROCKSDB_HOME )
  SET(_rocksdb_INCLUDE_SEARCH_DIRS ${ROCKSDB_HOME}/include ${_rocksdb_INCLUDE_SEARCH_DIRS})
  SET(_rocksdb_LIBRARIES_SEARCH_DIRS ${ROCKSDB_HOME}/lib ${_rocksdb_LIBRARIES_SEARCH_DIRS})
  SET(_rocksdb_HOME ${ROCKSDB_HOME})
ENDIF( ROCKSDB_HOME )

# find the include files
FIND_PATH(ROCKSDB_INCLUDE_DIR rocksdb/db.h
  HINTS
  ${_rocksdb_INCLUDE_SEARCH_DIRS}
  ${PC_ROCKSDB_INCLUDEDIR}
  ${PC_ROCKSDB_INCLUDE_DIRS}
  ${CMAKE_INCLUDE_PATH}
)

# locate the library
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  # On MacOS
  set(ROCKSDB_LIBRARY_NAMES ${ROCKSDB_LIBRARY_NAMES} librocksdb.dylib)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  # On Linux
  set(ROCKSDB_LIBRARY_NAMES ${ROCKSDB_LIBRARY_NAMES} librocksdb.so)
else()
  set(ROCKSDB_LIBRARY_NAMES ${ROCKSDB_LIBRARY_NAMES} librocksdb.a)
endif()

set(ROCKSDB_STATIC_LIBRARY_NAMES ${ROCKSDB_STATIC_LIBRARY_NAMES} librocksdb.a)

find_library(ROCKSDB_LIBRARIES NAMES ${ROCKSDB_LIBRARY_NAMES}
  HINTS ${_rocksdb_LIBRARIES_SEARCH_DIRS}
)

find_library(ROCKSDB_STATIC_LIBRARY NAMES ${ROCKSDB_STATIC_LIBRARY_NAMES}
  HINTS ${_rocksdb_LIBRARIES_SEARCH_DIRS}
)

find_library(ROCKSDB_SNAPPY_LIBRARY NAMES libsnappy.a
  HINTS ${_rocksdb_LIBRARIES_SEARCH_DIRS}
)

if(NOT ${ROCKSDB_SNAPPY_LIBRARY} STREQUAL "ROCKSDB_SNAPPY_LIBRARY-NOTFOUND")
  set(ROCKSDB_STATIC_LIBRARIES
    ${ROCKSDB_STATIC_LIBRARY}
    ${ROCKSDB_SNAPPY_LIBRARY}
  )
endif()

if( ${ROCKSDB_LIBRARIES} STREQUAL "ROCKSDB_LIBRARIES-NOTFOUND" )
  set(ROCKSDB_LIBRARIES ${ROCKSDB_STATIC_LIBRARIES})
endif()

# if the include and the program are found then we have it
if(ROCKSDB_INCLUDE_DIR AND ROCKSDB_LIBRARIES)
  set(ROCKSDB_FOUND "YES")
  LOG_LIBRARY(rocksdb "${ROCKSDB_STATIC_LIBRARY}")
  LOG_LIBRARY(snappy "${ROCKSDB_SNAPPY_LIBRARY}")
endif()
