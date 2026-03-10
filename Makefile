# Makefile for ChronoScript Compiler
# Builds lexer and parser for ChronoScript language

# Compiler and flags
CC = gcc
CFLAGS = -Wall -g
FLEX = flex
BISON = bison
BISON_FLAGS = -d -v

# File names
LEXER_SOURCE = chronoscript.l
PARSER_SOURCE = chronoscript.y
LEXER_OUTPUT = lex.yy.c
PARSER_OUTPUT_C = chronoscript.tab.c
PARSER_OUTPUT_H = chronoscript.tab.h
PARSER_VERBOSE = chronoscript.output
TARGET = chronoscript_parser

# Test files
TEST_DIR = test_samples
TESTS = $(TEST_DIR)/test1_declarations.cs \
        $(TEST_DIR)/test2_expressions.cs \
        $(TEST_DIR)/test3_control_flow.cs \
        $(TEST_DIR)/test4_functions.cs \
        $(TEST_DIR)/test5_comprehensive.cs

# Colors for output (optional)
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

# Default target
all: $(TARGET)
	@echo "$(GREEN)Build complete! Run './$(TARGET) <file.cs>' to parse ChronoScript files$(NC)"

# Build the parser executable
$(TARGET): $(LEXER_OUTPUT) $(PARSER_OUTPUT_C)
	@echo "$(YELLOW)Compiling parser...$(NC)"
	$(CC) $(CFLAGS) $(LEXER_OUTPUT) $(PARSER_OUTPUT_C) -o $(TARGET) -lfl
	@echo "$(GREEN)Parser compiled successfully!$(NC)"

# Generate lexer from Flex
$(LEXER_OUTPUT): $(LEXER_SOURCE)
	@echo "$(YELLOW)Generating lexer from $(LEXER_SOURCE)...$(NC)"
	$(FLEX) $(LEXER_SOURCE)
	@echo "$(GREEN)Lexer generated: $(LEXER_OUTPUT)$(NC)"

# Generate parser from Bison
$(PARSER_OUTPUT_C): $(PARSER_SOURCE)
	@echo "$(YELLOW)Generating parser from $(PARSER_SOURCE)...$(NC)"
	$(BISON) $(BISON_FLAGS) $(PARSER_SOURCE)
	@echo "$(GREEN)Parser generated: $(PARSER_OUTPUT_C), $(PARSER_OUTPUT_H)$(NC)"

# Run all tests
test: $(TARGET)
	@echo "$(GREEN)========================================$(NC)"
	@echo "$(GREEN)Running ChronoScript Parser Tests$(NC)"
	@echo "$(GREEN)========================================$(NC)"
	@for test in $(TESTS); do \
		echo "$(YELLOW)\nTest: $$test$(NC)"; \
		./$(TARGET) $$test; \
		echo "----------------------------------------"; \
	done
	@echo "$(GREEN)All tests completed!$(NC)"

# Run specific test
test1: $(TARGET)
	./$(TARGET) $(TEST_DIR)/test1_declarations.cs

test2: $(TARGET)
	./$(TARGET) $(TEST_DIR)/test2_expressions.cs

test3: $(TARGET)
	./$(TARGET) $(TEST_DIR)/test3_control_flow.cs

test4: $(TARGET)
	./$(TARGET) $(TEST_DIR)/test4_functions.cs

test5: $(TARGET)
	./$(TARGET) $(TEST_DIR)/test5_comprehensive.cs

test6: $(TARGET)
	./$(TARGET) $(TEST_DIR)/test6_errors.cs

# Check for grammar conflicts
check-grammar: $(PARSER_SOURCE)
	@echo "$(YELLOW)Checking grammar for conflicts...$(NC)"
	$(BISON) $(BISON_FLAGS) $(PARSER_SOURCE)
	@if [ -f $(PARSER_VERBOSE) ]; then \
		echo "$(GREEN)Grammar report generated: $(PARSER_VERBOSE)$(NC)"; \
		grep -A 5 "conflict" $(PARSER_VERBOSE) || echo "$(GREEN)No conflicts found!$(NC)"; \
	fi

# Clean generated files
clean:
	@echo "$(YELLOW)Cleaning generated files...$(NC)"
	rm -f $(LEXER_OUTPUT) $(PARSER_OUTPUT_C) $(PARSER_OUTPUT_H) $(PARSER_VERBOSE) $(TARGET)
	@echo "$(GREEN)Clean complete!$(NC)"

# Clean and rebuild
rebuild: clean all

# Help message
help:
	@echo "ChronoScript Parser Makefile"
	@echo "============================"
	@echo ""
	@echo "Targets:"
	@echo "  make              - Build the parser (default)"
	@echo "  make test         - Run all test programs"
	@echo "  make test1-6      - Run specific test (e.g., make test1)"
	@echo "  make check-grammar - Check for grammar conflicts"
	@echo "  make clean        - Remove generated files"
	@echo "  make rebuild      - Clean and rebuild"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  ./$(TARGET) <input_file.cs>    - Parse a ChronoScript file"
	@echo "  ./$(TARGET)                     - Parse from stdin"

# Phony targets (not actual files)
.PHONY: all test test1 test2 test3 test4 test5 test6 check-grammar clean rebuild help
