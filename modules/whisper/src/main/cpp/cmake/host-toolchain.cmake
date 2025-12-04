# Host toolchain for building vulkan-shaders-gen in Docker (Linux)
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Use system compilers (available in cimg/android Docker image)
set(CMAKE_C_COMPILER /usr/bin/gcc)
set(CMAKE_CXX_COMPILER /usr/bin/g++)

# Ninja will be installed in Docker image
set(CMAKE_MAKE_PROGRAM /usr/bin/ninja CACHE FILEPATH "Ninja build tool")

# Standard flags
set(CMAKE_C_FLAGS "-O3" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "-O3" CACHE STRING "" FORCE)
