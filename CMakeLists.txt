cmake_minimum_required(VERSION 3.24)
project(fractals)

set(BINARY_DIR ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${BINARY_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${BINARY_DIR})
make_directory(${BINARY_DIR})

add_subdirectory(SDL)
add_executable(fractals WIN32 main.cpp shader.cpp)
set_target_properties(fractals PROPERTIES CXX_STANDARD 23)
target_link_libraries(fractals PRIVATE SDL3::SDL3)

function(add_shader FILE)
    set(DEPENDS ${ARGN})
    set(GLSL ${CMAKE_SOURCE_DIR}/${FILE})
    set(SPV ${CMAKE_SOURCE_DIR}/bin/${FILE}.spv)
    set(MSL ${CMAKE_SOURCE_DIR}/bin/${FILE}.msl)
    set(JSON ${CMAKE_SOURCE_DIR}/bin/${FILE}.json)

    function(compile PROGRAM SOURCE OUTPUT)
        add_custom_command(
            OUTPUT ${OUTPUT}
            COMMAND ${PROGRAM} ${SOURCE} -o ${OUTPUT}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            DEPENDS ${SOURCE} ${DEPENDS}
            COMMENT ${OUTPUT}
        )
        get_filename_component(NAME ${OUTPUT} NAME)
        string(REPLACE . _ NAME ${NAME})
        set(NAME compile_${NAME})
        add_custom_target(${NAME} DEPENDS ${OUTPUT})
        add_dependencies(fractals ${NAME})
    endfunction()
    if (MSVC)
        set(SHADERCROSS SDL_shadercross/msvc/shadercross.exe)
        compile(glslc ${GLSL} ${SPV})
        compile(${SHADERCROSS} ${SPV} ${MSL})
        compile(${SHADERCROSS} ${SPV} ${JSON})
    endif()

    function(package OUTPUT)
        get_filename_component(NAME ${OUTPUT} NAME)
        set(BINARY ${BINARY_DIR}/${NAME})
        add_custom_command(
            OUTPUT ${BINARY}
            COMMAND ${CMAKE_COMMAND} -E copy ${OUTPUT} ${BINARY}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            DEPENDS ${OUTPUT}
            COMMENT ${BINARY}
        )
        string(REPLACE . _ NAME ${NAME})
        set(NAME package_${NAME})
        add_custom_target(${NAME} DEPENDS ${BINARY})
        add_dependencies(fractals ${NAME})
    endfunction()
    if(APPLE)
        package(${MSL})
    else()
        package(${SPV})
    endif()
    package(${JSON})
endfunction()
add_shader(render.frag)
add_shader(render.vert)

configure_file(LICENSE.txt ${BINARY_DIR} COPYONLY)
configure_file(README.md ${BINARY_DIR} COPYONLY)