# ChronoScript Compiler - Complete Makefile
# Builds all compiler phases (Lexer, Parser, Semantic, ICG, Optimization, Target Code Gen)

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -g -O2
FLEX = flex
BISON = bison
BISON_FLAGS = -d -v

# Directories
GRAMMAR_DIR = grammar
INCLUDE_DIR = include
SRC_DIR = src
EXAMPLES_DIR = examples
TEST_DIR = tests
OUTPUT_DIR = outputs

# Source files
LEXER_SOURCE = $(GRAMMAR_DIR)/chronoscript.l
PARSER_SOURCE = $(GRAMMAR_DIR)/chronoscript.y
ICG_SOURCE = $(SRC_DIR)/icg.c
OPT_SOURCE = $(SRC_DIR)/optimizer.c
TARGET_SOURCE = $(SRC_DIR)/target_codegen.c

# Generated files
LEXER_OUTPUT = lex.yy.c
PARSER_OUTPUT_C = chronoscript.tab.c
PARSER_OUTPUT_H = chronoscript.tab.h
PARSER_VERBOSE = chronoscript.output

# Object files
ICG_OBJ = icg.o
OPT_OBJ = optimizer.o
TARGET_OBJ = target_codegen.o

# Executable
TARGET_EXEC = chrono_compiler

# Test files
TEST_FILES = $(TEST_DIR)/test1_declarations.cscr \
             $(TEST_DIR)/test2_expressions.cscr \
             $(TEST_DIR)/test3_control_flow.cscr \
             $(TEST_DIR)/test4_functions.cscr \
             $(TEST_DIR)/test5_comprehensive.cscr

EXAMPLE_FILES = $(EXAMPLES_DIR)/simple.cscr \
                $(EXAMPLES_DIR)/demo.cscr \
                $(EXAMPLES_DIR)/calculator.cscr

# Output files
OUTPUT_FILES = $(OUTPUT_DIR)/intermediate_code.txt \
               $(OUTPUT_DIR)/optimized_code.txt \
               $(OUTPUT_DIR)/target_code.txt \
               $(OUTPUT_DIR)/symbol_table.txt

# Default target
.PHONY: all
all: directories $(TARGET_EXEC)
	@echo "======================================"
	@echo "ChronoScript Compiler Built Successfully!"
	@echo "======================================"
	@echo "Run: ./$(TARGET_EXEC) <input_file.cscr>"

# Create necessary directories
.PHONY: directories
directories:
	@mkdir -p $(OUTPUT_DIR)

# Build the compiler
$(TARGET_EXEC): $(LEXER_OUTPUT) $(PARSER_OUTPUT_C) $(ICG_OBJ) $(OPT_OBJ) $(TARGET_OBJ)
	@echo "Linking compiler..."
	$(CC) $(CFLAGS) $(LEXER_OUTPUT) $(PARSER_OUTPUT_C) $(ICG_OBJ) $(OPT_OBJ) $(TARGET_OBJ) -o $(TARGET_EXEC) -lfl -lm
	@echo "Compiler executable created: $(TARGET_EXEC)"

# Generate lexer
$(LEXER_OUTPUT): $(LEXER_SOURCE)
	@echo "Generating lexical analyzer..."
	cd $(GRAMMAR_DIR) && $(FLEX) chronoscript.l && mv lex.yy.c ../$(LEXER_OUTPUT)
	@echo "Lexer generated: $(LEXER_OUTPUT)"

# Generate parser
$(PARSER_OUTPUT_C) $(PARSER_OUTPUT_H): $(PARSER_SOURCE)
	@echo "Generating syntax analyzer..."
	$(BISON) $(BISON_FLAGS) -o $(PARSER_OUTPUT_C) $(PARSER_SOURCE)
	@echo "Parser generated: $(PARSER_OUTPUT_C), $(PARSER_OUTPUT_H)"

# Compile intermediate code generator
$(ICG_OBJ): $(ICG_SOURCE) $(INCLUDE_DIR)/icg.h
	@echo "Compiling intermediate code generator..."
	$(CC) $(CFLAGS) -c $(ICG_SOURCE) -o $(ICG_OBJ) -I.
	@echo "ICG compiled"

# Compile optimizer
$(OPT_OBJ): $(OPT_SOURCE) $(INCLUDE_DIR)/optimizer.h $(INCLUDE_DIR)/icg.h
	@echo "Compiling code optimizer..."
	$(CC) $(CFLAGS) -c $(OPT_SOURCE) -o $(OPT_OBJ) -I.
	@echo "Optimizer compiled"

# Compile target code generator
$(TARGET_OBJ): $(TARGET_SOURCE) $(INCLUDE_DIR)/target_codegen.h $(INCLUDE_DIR)/icg.h
	@echo "Compiling target code generator..."
	$(CC) $(CFLAGS) -c $(TARGET_SOURCE) -o $(TARGET_OBJ) -I.
	@echo "Target code generator compiled"

# Run tests
.PHONY: test
test: $(TARGET_EXEC)
	@echo "======================================"
	@echo "Running ChronoScript Compiler Tests"
	@echo "======================================"
	@echo ""
	@echo "Test 1: Simple Program"
	@./$(TARGET_EXEC) $(EXAMPLES_DIR)/simple.cscr
	@echo ""
	@echo "Test 2: Demo Program"
	@./$(TARGET_EXEC) $(EXAMPLES_DIR)/demo.cscr
	@echo ""
	@echo "Test 3: Declarations"
	@./$(TARGET_EXEC) $(TEST_DIR)/test1_declarations.cscr
	@echo ""
	@echo "======================================"
	@echo "All tests completed!"
	@echo "======================================"

# Run a specific test file
.PHONY: run
run: $(TARGET_EXEC)
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make run FILE=<filename.cscr>"; \
	else \
		echo "Compiling $(FILE)..."; \
		./$(TARGET_EXEC) $(FILE); \
	fi

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(LEXER_OUTPUT)
	rm -f $(PARSER_OUTPUT_C) $(PARSER_OUTPUT_H) $(PARSER_VERBOSE)
	rm -f *.o
	rm -f $(TARGET_EXEC)
	rm -f $(TARGET_EXEC).exe
	@echo "Clean complete"

# Clean everything including outputs
.PHONY: cleanall
cleanall: clean
	@echo "Cleaning output files..."
	rm -f $(OUTPUT_DIR)/*.txt
	@echo "All files cleaned"

# Install dependencies (Linux/macOS)
.PHONY: install-deps
install-deps:
	@echo "Installing dependencies..."
	@echo "For Ubuntu/Debian:"
	@echo "  sudo apt-get install flex bison gcc"
	@echo "For macOS:"
	@echo "  brew install flex bison gcc"
	@echo "For Windows:"
	@echo "  Use MinGW or Cygwin"

# Display help
.PHONY: help
help:
	@echo "ChronoScript Compiler Makefile"
	@echo "================================"
	@echo ""
	@echo "Targets:"
	@echo "  all         - Build the complete compiler (default)"
	@echo "  test        - Run all test programs"
	@echo "  run FILE=<file> - Compile a specific ChronoScript file"
	@echo "  clean       - Remove build artifacts"
	@echo "  cleanall    - Remove all generated files"
	@echo "  help        - Display this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                           # Build compiler"
	@echo "  make test                      # Run tests"
	@echo "  make run FILE=examples/demo.cscr    # Compile demo.cscr"
	@echo "  make clean                     # Clean build files"

# Phony targets
.PHONY: all directories test run clean cleanall install-deps help
