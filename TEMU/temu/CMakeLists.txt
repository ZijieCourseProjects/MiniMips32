cmake_minimum_required(VERSION 3.23)
project(temu C)

set(CMAKE_C_STANDARD 11)

include_directories(include)
include_directories(include/cpu)
include_directories(include/memory)
include_directories(include/monitor)
include_directories(src)

add_executable(temu
        include/cpu/all-instr.h
        include/cpu/helper.h
        include/cpu/i-type.h
        include/cpu/operand.h
        include/cpu/r-type.h
        include/cpu/reg.h
        include/cpu/special.h
        include/memory/burst.h
        include/memory/memory.h
        include/monitor/expr.h
        include/monitor/monitor.h
        include/monitor/watchpoint.h
        include/common.h
        include/debug.h
        include/macro.h
        include/misc.h
        include/temu.h
        src/cpu/exec.c
        src/cpu/i-type.c
        src/cpu/r-type.c
        src/cpu/reg.c
        src/cpu/special.c
        src/memory/dram.c
        src/memory/memory.c
        src/monitor/cpu-exec.c
        src/monitor/expr.c
        src/monitor/monitor.c
        src/monitor/ui.c
        src/monitor/watchpoint.c
        src/main.c)
