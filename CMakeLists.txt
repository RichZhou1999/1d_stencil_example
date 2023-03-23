cmake_minimum_required(VERSION 3.11)

project(cuda-example LANGUAGES CXX CUDA)

add_executable(cuda-example main.cu)

set_property(TARGET cuda-example PROPERTY CUDA_ARCHITECTURES 72)

target_compile_features(cuda-example PUBLIC cxx_std_11)

target_link_libraries(cuda-example PRIVATE cuda)


if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -g -G")
    set(CMAKE_CUDA_DEBUGGER_EXECUTABLE "cuda-gdb")
    set_property(TARGET cuda-example PROPERTY CUDA_DEBUGGER_ARGS "-x ${CMAKE_CURRENT_SOURCE_DIR}/debugger.gdb")
endif()