# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canoncical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/Cellar/cmake/2.8.6/bin/cmake

# The command to remove a file.
RM = /usr/local/Cellar/cmake/2.8.6/bin/cmake -E remove -f

# The program to use to edit the cache.
CMAKE_EDIT_COMMAND = /usr/local/Cellar/cmake/2.8.6/bin/ccmake

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Volumes/HD/Users/adam/code/rabbitmq-c

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Volumes/HD/Users/adam/code/rabbitmq-c

# Include any dependencies generated for this target.
include examples/CMakeFiles/amqp_producer.dir/depend.make

# Include the progress variables for this target.
include examples/CMakeFiles/amqp_producer.dir/progress.make

# Include the compile flags for this target's objects.
include examples/CMakeFiles/amqp_producer.dir/flags.make

examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o: examples/CMakeFiles/amqp_producer.dir/flags.make
examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o: examples/amqp_producer.c
	$(CMAKE_COMMAND) -E cmake_progress_report /Volumes/HD/Users/adam/code/rabbitmq-c/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building C object examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -o CMakeFiles/amqp_producer.dir/amqp_producer.c.o   -c /Volumes/HD/Users/adam/code/rabbitmq-c/examples/amqp_producer.c

examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/amqp_producer.dir/amqp_producer.c.i"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -E /Volumes/HD/Users/adam/code/rabbitmq-c/examples/amqp_producer.c > CMakeFiles/amqp_producer.dir/amqp_producer.c.i

examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/amqp_producer.dir/amqp_producer.c.s"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -S /Volumes/HD/Users/adam/code/rabbitmq-c/examples/amqp_producer.c -o CMakeFiles/amqp_producer.dir/amqp_producer.c.s

examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o.requires:
.PHONY : examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o.requires

examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o.provides: examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o.requires
	$(MAKE) -f examples/CMakeFiles/amqp_producer.dir/build.make examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o.provides.build
.PHONY : examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o.provides

examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o.provides.build: examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o

examples/CMakeFiles/amqp_producer.dir/utils.c.o: examples/CMakeFiles/amqp_producer.dir/flags.make
examples/CMakeFiles/amqp_producer.dir/utils.c.o: examples/utils.c
	$(CMAKE_COMMAND) -E cmake_progress_report /Volumes/HD/Users/adam/code/rabbitmq-c/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building C object examples/CMakeFiles/amqp_producer.dir/utils.c.o"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -o CMakeFiles/amqp_producer.dir/utils.c.o   -c /Volumes/HD/Users/adam/code/rabbitmq-c/examples/utils.c

examples/CMakeFiles/amqp_producer.dir/utils.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/amqp_producer.dir/utils.c.i"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -E /Volumes/HD/Users/adam/code/rabbitmq-c/examples/utils.c > CMakeFiles/amqp_producer.dir/utils.c.i

examples/CMakeFiles/amqp_producer.dir/utils.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/amqp_producer.dir/utils.c.s"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -S /Volumes/HD/Users/adam/code/rabbitmq-c/examples/utils.c -o CMakeFiles/amqp_producer.dir/utils.c.s

examples/CMakeFiles/amqp_producer.dir/utils.c.o.requires:
.PHONY : examples/CMakeFiles/amqp_producer.dir/utils.c.o.requires

examples/CMakeFiles/amqp_producer.dir/utils.c.o.provides: examples/CMakeFiles/amqp_producer.dir/utils.c.o.requires
	$(MAKE) -f examples/CMakeFiles/amqp_producer.dir/build.make examples/CMakeFiles/amqp_producer.dir/utils.c.o.provides.build
.PHONY : examples/CMakeFiles/amqp_producer.dir/utils.c.o.provides

examples/CMakeFiles/amqp_producer.dir/utils.c.o.provides.build: examples/CMakeFiles/amqp_producer.dir/utils.c.o

examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o: examples/CMakeFiles/amqp_producer.dir/flags.make
examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o: examples/unix/platform_utils.c
	$(CMAKE_COMMAND) -E cmake_progress_report /Volumes/HD/Users/adam/code/rabbitmq-c/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building C object examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -o CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o   -c /Volumes/HD/Users/adam/code/rabbitmq-c/examples/unix/platform_utils.c

examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/amqp_producer.dir/unix/platform_utils.c.i"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -E /Volumes/HD/Users/adam/code/rabbitmq-c/examples/unix/platform_utils.c > CMakeFiles/amqp_producer.dir/unix/platform_utils.c.i

examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/amqp_producer.dir/unix/platform_utils.c.s"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && /usr/bin/gcc  $(C_DEFINES) $(C_FLAGS) -S /Volumes/HD/Users/adam/code/rabbitmq-c/examples/unix/platform_utils.c -o CMakeFiles/amqp_producer.dir/unix/platform_utils.c.s

examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o.requires:
.PHONY : examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o.requires

examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o.provides: examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o.requires
	$(MAKE) -f examples/CMakeFiles/amqp_producer.dir/build.make examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o.provides.build
.PHONY : examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o.provides

examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o.provides.build: examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o

# Object files for target amqp_producer
amqp_producer_OBJECTS = \
"CMakeFiles/amqp_producer.dir/amqp_producer.c.o" \
"CMakeFiles/amqp_producer.dir/utils.c.o" \
"CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o"

# External object files for target amqp_producer
amqp_producer_EXTERNAL_OBJECTS =

examples/amqp_producer: examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o
examples/amqp_producer: examples/CMakeFiles/amqp_producer.dir/utils.c.o
examples/amqp_producer: examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o
examples/amqp_producer: librabbitmq/librabbitmq.dylib
examples/amqp_producer: examples/CMakeFiles/amqp_producer.dir/build.make
examples/amqp_producer: examples/CMakeFiles/amqp_producer.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking C executable amqp_producer"
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/amqp_producer.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
examples/CMakeFiles/amqp_producer.dir/build: examples/amqp_producer
.PHONY : examples/CMakeFiles/amqp_producer.dir/build

examples/CMakeFiles/amqp_producer.dir/requires: examples/CMakeFiles/amqp_producer.dir/amqp_producer.c.o.requires
examples/CMakeFiles/amqp_producer.dir/requires: examples/CMakeFiles/amqp_producer.dir/utils.c.o.requires
examples/CMakeFiles/amqp_producer.dir/requires: examples/CMakeFiles/amqp_producer.dir/unix/platform_utils.c.o.requires
.PHONY : examples/CMakeFiles/amqp_producer.dir/requires

examples/CMakeFiles/amqp_producer.dir/clean:
	cd /Volumes/HD/Users/adam/code/rabbitmq-c/examples && $(CMAKE_COMMAND) -P CMakeFiles/amqp_producer.dir/cmake_clean.cmake
.PHONY : examples/CMakeFiles/amqp_producer.dir/clean

examples/CMakeFiles/amqp_producer.dir/depend:
	cd /Volumes/HD/Users/adam/code/rabbitmq-c && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Volumes/HD/Users/adam/code/rabbitmq-c /Volumes/HD/Users/adam/code/rabbitmq-c/examples /Volumes/HD/Users/adam/code/rabbitmq-c /Volumes/HD/Users/adam/code/rabbitmq-c/examples /Volumes/HD/Users/adam/code/rabbitmq-c/examples/CMakeFiles/amqp_producer.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : examples/CMakeFiles/amqp_producer.dir/depend

