cmake_minimum_required (VERSION 3.14)
project(riscv-cpu)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

enable_testing()

find_package(verilator REQUIRED)

find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIR})

add_executable(toplev_unit_tests 
        tests/toplev/toplev_tests.cpp
)
target_link_libraries(toplev_unit_tests PRIVATE GTest::GTest GTest::Main)

verilate(toplev_unit_tests
  INCLUDE_DIRS 
  "tests/toplev/"
  VERILATOR_ARGS --unroll-count 512
  SOURCES
  rtl/toplev/toplev.sv
)
