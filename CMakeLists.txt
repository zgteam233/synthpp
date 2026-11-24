cmake_minimum_required(VERSION 4.3)
project(synthpp)


set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


find_package(PortAudio CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)

get_property(_targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY IMPORTED_TARGETS)
message(STATUS "Imported targets: ${_targets}")

# 包含你自己的头文件目录
include_directories(include)

# 添加可执行文件
add_executable(synthpp main.cpp
        src/score.cpp
        src/voice.cpp
        src/synth_engine.cpp
        src/wav_renderer.cpp
        src/json_melody.cpp)

# 链接
target_link_libraries(synthpp
        PRIVATE
            portaudio
            nlohmann_json::nlohmann_json
)

# （可选）为 Windows 生成控制台应用，避免弹出窗口
set_target_properties(synthpp PROPERTIES WIN32_EXECUTABLE FALSE)