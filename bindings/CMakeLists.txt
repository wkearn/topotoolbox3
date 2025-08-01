cmake_minimum_required(VERSION 3.14)

project(
  mxtopotoolbox
  VERSION 0.0.1
  LANGUAGES C
)

include(FindMatlab)

include(FetchContent)
FetchContent_Declare(
  topotoolbox
  GIT_REPOSITORY https://github.com/TopoToolbox/libtopotoolbox.git
  GIT_TAG 3ed8f8f444145f07b24c9897177e8dca0c773cca
)
FetchContent_MakeAvailable(topotoolbox)

matlab_add_mex(
  NAME tt_has_topotoolbox
  MODULE
  SRC tt_has_topotoolbox.c
  R2018a
  LINK_TO topotoolbox
)

matlab_add_mex(
  NAME tt_fillsinks
  MODULE
  SRC tt_fillsinks.c
  R2018a
  LINK_TO topotoolbox
)

matlab_add_mex(
  NAME tt_identifyflats
  MODULE
  SRC tt_identifyflats.c
  R2018a
  LINK_TO topotoolbox
)

matlab_add_mex(
  NAME tt_gwdt_computecosts
  MODULE
  SRC tt_gwdt_computecosts.c
  R2018a
  LINK_TO topotoolbox
)

matlab_add_mex(
  NAME tt_lowerenv
  MODULE
  SRC tt_lowerenv.c
  R2018a
  LINK_TO topotoolbox
)

matlab_add_mex(
  NAME tt_hillshade
  MODULE
  SRC tt_hillshade.c
  R2018a
  LINK_TO topotoolbox
)

install(
  TARGETS tt_has_topotoolbox tt_fillsinks tt_identifyflats tt_gwdt_computecosts
          tt_lowerenv tt_hillshade
  DESTINATION "."
  COMPONENT Runtime
)
