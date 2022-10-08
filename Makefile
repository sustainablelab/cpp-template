CXXFLAGS := -std=c++20 -Wall -Wextra -Wpedantic

# --- My make variables ---
# Identify the main source file
SRC := src/main.cpp
# Put the build directory in .gitignore
BUILD_DIR := build
# HEADER_LIST : list of dependenices output by the compiler
HEADER_LIST := $(BUILD_DIR)/$(basename $(notdir $(SRC))).d

# --- Check my make variables ---
# run with 'make what' or just 'make'
.PHONY: what
what:
	@echo --- My make variables ---
	@echo
	@echo expect SRC : src/main.cpp
	@echo SRC : $(SRC)
	@echo
	@echo expect HEADER_LIST : build/main.d
	@echo HEADER_LIST : $(HEADER_LIST)

# --- Format the dependencies list for ctags ---
# Build a simple C program that generates build/headers.txt.
# Run the program like this (see 'tags' recipe below):
# ./ctags-dlist build/main.d
.PHONY: ctags-dlist
$(BUILD_DIR)/ctags-dlist: ctags-dlist.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^

# --- Get the list of dependencies ---
# The expanded recipe for listing dependencies looks like this:
# g++ -std=c++20 -Wall -Wextra -Wpedantic -M main.cpp -MF main.d
.PHONY: $(HEADER_LIST)
$(HEADER_LIST): $(SRC)
	$(CXX) $(CXXFLAGS) -M $^ -MF $@

# --- Make the tags file ---
# Usually ctags only tags the source code I write.
# Use the dependencies list to include lib tags!
# `./ctags-dlist main.d` <---- creates file 'headers.txt'.
# Generate lib tags from 'headers.txt'.
# Then append my source code tags to that tags file.
.PHONY: tags
tags: $(HEADER_LIST)
	$(BUILD_DIR)/ctags-dlist $(HEADER_LIST)
	ctags --c-kinds=+p+x -L headers.txt
	ctags --c-kinds=+p+x+l -a $(SRC)
