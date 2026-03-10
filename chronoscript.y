%{
/*
 * ChronoScript Parser - Syntax Analysis Phase
 * Bison Grammar for ChronoScript Compiler
 * 
 * This file defines the syntax rules and builds an Abstract Syntax Tree (AST)
 * for the ChronoScript programming language with temporal features.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* External declarations from lexer */
extern int yylex();
extern int yylineno;
extern FILE* yyin;
extern char* yytext;

/* Forward declarations */
void yyerror(const char* s);
void semantic_error(const char* msg, int line);

/* AST Node Types */
typedef enum {
    NODE_PROGRAM,
    NODE_DECL_LIST,
    NODE_VAR_DECL,
    NODE_FUNC_DECL,
    NODE_PARAM_LIST,
    NODE_PARAM,
    NODE_STMT_LIST,
    NODE_COMPOUND_STMT,
    NODE_IF_STMT,
    NODE_WHILE_STMT,
    NODE_FOR_STMT,
    NODE_RETURN_STMT,
    NODE_BREAK_STMT,
    NODE_CONTINUE_STMT,
    NODE_PRINT_STMT,
    NODE_EXPR_STMT,
    NODE_ASSIGN_STMT,
    NODE_BINARY_EXPR,
    NODE_UNARY_EXPR,
    NODE_CALL_EXPR,
    NODE_ARRAY_ACCESS,
    NODE_IDENTIFIER,
    NODE_INTEGER_LITERAL,
    NODE_FLOAT_LITERAL,
    NODE_CHAR_LITERAL,
    NODE_STRING_LITERAL,
    NODE_ARRAY_DECL,
    NODE_STRUCT_DECL,
    NODE_MEMBER_LIST
} NodeType;

/* AST Node Structure */
typedef struct ASTNode {
    NodeType type;
    int line;
    char* value;
    int intval;
    double floatval;
    struct ASTNode* child[4];    // Support up to 4 children
    struct ASTNode* sibling;      // For linked lists of nodes
    char* data_type;              // Variable type
    char* op;                     // Operator for expressions
} ASTNode;

/* Symbol Table Entry */
typedef struct Symbol {
    char* name;
    char* type;
    int scope;
    int line;
    int is_function;
    int is_array;
    struct Symbol* next;
} Symbol;

/* Global symbol table */
Symbol* symbol_table = NULL;
int current_scope = 0;
int error_count = 0;

/* AST root */
ASTNode* ast_root = NULL;

/* Function prototypes for AST construction */
ASTNode* create_node(NodeType type, int line);
ASTNode* create_binary_expr(char* op, ASTNode* left, ASTNode* right, int line);
ASTNode* create_unary_expr(char* op, ASTNode* expr, int line);
ASTNode* create_identifier(char* name, int line);
ASTNode* create_int_literal(int value, int line);
ASTNode* create_float_literal(double value, int line);
ASTNode* create_string_literal(char* value, int line);

/* Symbol table functions */
void insert_symbol(char* name, char* type, int is_function, int is_array);
Symbol* lookup_symbol(char* name);
void enter_scope();
void exit_scope();
void print_symbol_table();

/* AST printing */
void print_ast(ASTNode* node, int depth);
void free_ast(ASTNode* node);

%}

/* SEMANTIC VALUES - Union for different data types */
%union {
    int intval;
    double floatval;
    char charval;
    char* strval;
    struct ASTNode* node;
}

/* TOKEN DECLARATIONS - All tokens from the lexer */

/* Data Types */
%token VOID TRUTH MATTER ATOM STREAM ENERGY HIGH_ENERGY
%token PURE_MATTER LARGE_MATTER FULL_ENERGY SMALL_MATTER

/* Type Qualifiers */
%token FLUX FIXED

/* Structural Keywords */
%token TIMELINE STRUCTURE UNISON INSTANCE

/* Control Flow Keywords */
%token EVENT PERSIST ESCAPE RESOLVE OBSERVE BROADCAST
%token ERA ALTERNATE LOOP DIVERGE REFORGE STANDARD PERSPECTIVE

/* Arithmetic Operators */
%token PLUS MINUS MULTIPLY DIVIDE MODULO

/* Assignment and Comparison */
%token ASSIGN EQUAL NOT_EQUAL GREATER LESS GREATER_EQUAL LESS_EQUAL

/* Logical Operators */
%token LOGICAL_AND LOGICAL_OR LOGICAL_NOT

/* Bitwise Operators */
%token BITWISE_AND BITWISE_OR BITWISE_XOR LEFT_SHIFT RIGHT_SHIFT

/* Delimiters */
%token LBRACE RBRACE LPAREN RPAREN SEMICOLON COMMA
%token LBRACKET RBRACKET DOT COLON

/* Mathematical Functions */
%token SINE COSINE TANGENT INV_SINE INV_COSINE INV_TANGENT
%token LOGARITHM POWER ABSOLUTE FLOOR_FUNC CEILING_FUNC SQUAREROOT

/* Preprocessor */
%token INCORPORATE CONSTANT

/* Literals and Identifiers */
%token <intval> INTEGER_LITERAL
%token <floatval> FLOAT_LITERAL
%token <charval> CHAR_LITERAL
%token <strval> STRING_LITERAL
%token <strval> IDENTIFIER

/* NON-TERMINAL TYPES - Specify semantic value types */
%type <node> program
%type <node> declaration_list declaration
%type <node> variable_declaration var_declarator_list var_declarator
%type <node> function_declaration parameter_list parameter
%type <node> statement_list statement
%type <node> compound_statement
%type <node> expression_statement
%type <node> if_statement
%type <node> iteration_statement
%type <node> jump_statement
%type <node> print_statement
%type <node> expression assignment_expression
%type <node> logical_or_expression logical_and_expression
%type <node> bitwise_or_expression bitwise_xor_expression bitwise_and_expression
%type <node> equality_expression relational_expression
%type <node> shift_expression additive_expression multiplicative_expression
%type <node> unary_expression postfix_expression primary_expression
%type <node> argument_list
%type <node> struct_declaration member_list member_declaration
%type <node> array_declarator
%type <node> initializer
%type <strval> type_specifier

/* OPERATOR PRECEDENCE AND ASSOCIATIVITY */
/* Listed from lowest to highest precedence */
%right ASSIGN
%left LOGICAL_OR
%left LOGICAL_AND
%left BITWISE_OR
%left BITWISE_XOR
%left BITWISE_AND
%left EQUAL NOT_EQUAL
%left LESS LESS_EQUAL GREATER GREATER_EQUAL
%left LEFT_SHIFT RIGHT_SHIFT
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right LOGICAL_NOT UNARY_MINUS UNARY_PLUS
%left LPAREN RPAREN LBRACKET RBRACKET DOT

/* Start symbol */
%start program

%%

/* ===================================================================
   GRAMMAR RULES
   =================================================================== */

/* -------------------- PROGRAM STRUCTURE -------------------- */

program
    : declaration_list {
        $$ = create_node(NODE_PROGRAM, yylineno);
        $$->child[0] = $1;
        ast_root = $$;
        printf("Syntax analysis successful\n");
    }
    | /* empty */ {
        $$ = create_node(NODE_PROGRAM, yylineno);
        ast_root = $$;
    }
    | error {
        yyerror("Syntax error in program");
        $$ = NULL;
    }
    ;

declaration_list
    : declaration {
        $$ = create_node(NODE_DECL_LIST, yylineno);
        $$->child[0] = $1;
    }
    | declaration_list declaration {
        $$ = $1;
        ASTNode* temp = $1;
        while (temp->sibling != NULL) {
            temp = temp->sibling;
        }
        temp->sibling = $2;
    }
    ;

declaration
    : variable_declaration { $$ = $1; }
    | function_declaration { $$ = $1; }
    | struct_declaration { $$ = $1; }
    | INCORPORATE LESS IDENTIFIER GREATER SEMICOLON {
        $$ = create_node(NODE_DECL_LIST, yylineno);
        $$->value = $3;
    }
    | CONSTANT IDENTIFIER INTEGER_LITERAL {
        insert_symbol($2, "CONSTANT", 0, 0);
        $$ = create_node(NODE_VAR_DECL, yylineno);
        $$->value = $2;
        $$->intval = $3;
    }
    | error SEMICOLON {
        yyerror("Syntax error in declaration");
        $$ = NULL;
    }
    ;

/* -------------------- VARIABLE DECLARATIONS -------------------- */

variable_declaration
    : type_specifier var_declarator_list SEMICOLON {
        $$ = $2;
        /* Propagate type information to all declarators */
        ASTNode* temp = $$;
        while (temp != NULL) {
            temp->data_type = strdup($1);
            temp = temp->sibling;
        }
    }
    | error SEMICOLON {
        yyerror("Invalid variable declaration");
        $$ = NULL;
    }
    ;

var_declarator_list
    : var_declarator {
        $$ = $1;
    }
    | var_declarator_list COMMA var_declarator {
        $$ = $1;
        ASTNode* temp = $1;
        while (temp->sibling != NULL) {
            temp = temp->sibling;
        }
        temp->sibling = $3;
    }
    ;

var_declarator
    : IDENTIFIER {
        $$ = create_node(NODE_VAR_DECL, yylineno);
        $$->child[0] = create_identifier($1, yylineno);
        $$->value = $1;
    }
    | IDENTIFIER ASSIGN initializer {
        $$ = create_node(NODE_VAR_DECL, yylineno);
        $$->child[0] = create_identifier($1, yylineno);
        $$->child[1] = $3;  /* initializer expression */
        $$->value = $1;
    }
    | array_declarator {
        $$ = $1;
    }
    ;

array_declarator
    : IDENTIFIER LBRACKET INTEGER_LITERAL RBRACKET {
        $$ = create_node(NODE_ARRAY_DECL, yylineno);
        $$->child[0] = create_identifier($1, yylineno);
        $$->intval = $3;  /* array size */
        $$->value = $1;
    }
    | IDENTIFIER LBRACKET RBRACKET ASSIGN LBRACE argument_list RBRACE {
        $$ = create_node(NODE_ARRAY_DECL, yylineno);
        $$->child[0] = create_identifier($1, yylineno);
        $$->child[1] = $6;  /* initializer list */
        $$->value = $1;
    }
    ;

initializer
    : expression { $$ = $1; }
    ;

/* -------------------- TYPE SPECIFIERS -------------------- */

type_specifier
    : VOID          { $$ = strdup("Void"); }
    | TRUTH         { $$ = strdup("Truth"); }
    | MATTER        { $$ = strdup("Matter"); }
    | ATOM          { $$ = strdup("Atom"); }
    | STREAM        { $$ = strdup("Stream"); }
    | ENERGY        { $$ = strdup("Energy"); }
    | HIGH_ENERGY   { $$ = strdup("HighEnergy"); }
    | PURE_MATTER   { $$ = strdup("pureMatter"); }
    | LARGE_MATTER  { $$ = strdup("largeMatter"); }
    | FULL_ENERGY   { $$ = strdup("fullEnergy"); }
    | SMALL_MATTER  { $$ = strdup("smallMatter"); }
    ;

/* -------------------- STRUCTURE DECLARATIONS -------------------- */

struct_declaration
    : STRUCTURE IDENTIFIER LBRACE member_list RBRACE SEMICOLON {
        $$ = create_node(NODE_STRUCT_DECL, yylineno);
        $$->child[0] = create_identifier($2, yylineno);
        $$->child[1] = $4;
        $$->value = $2;
        insert_symbol($2, "structure", 0, 0);
    }
    ;

member_list
    : member_declaration {
        $$ = create_node(NODE_MEMBER_LIST, yylineno);
        $$->child[0] = $1;
    }
    | member_list member_declaration {
        $$ = $1;
        ASTNode* temp = $1;
        while (temp->sibling != NULL) {
            temp = temp->sibling;
        }
        temp->sibling = $2;
    }
    ;

member_declaration
    : type_specifier IDENTIFIER SEMICOLON {
        $$ = create_node(NODE_VAR_DECL, yylineno);
        $$->data_type = strdup($1);
        $$->value = $2;
    }
    ;

/* -------------------- FUNCTION DECLARATIONS -------------------- */

function_declaration
    : type_specifier IDENTIFIER LPAREN parameter_list RPAREN compound_statement {
        $$ = create_node(NODE_FUNC_DECL, yylineno);
        $$->data_type = strdup($1);
        $$->child[0] = create_identifier($2, yylineno);
        $$->child[1] = $4;  /* parameters */
        $$->child[2] = $6;  /* body */
        $$->value = $2;
        insert_symbol($2, $1, 1, 0);
    }
    | EVENT IDENTIFIER LPAREN parameter_list RPAREN compound_statement {
        $$ = create_node(NODE_FUNC_DECL, yylineno);
        $$->data_type = strdup("Event");
        $$->child[0] = create_identifier($2, yylineno);
        $$->child[1] = $4;  /* parameters */
        $$->child[2] = $6;  /* body */
        $$->value = $2;
        insert_symbol($2, "Event", 1, 0);
    }
    | type_specifier IDENTIFIER LPAREN RPAREN compound_statement {
        $$ = create_node(NODE_FUNC_DECL, yylineno);
        $$->data_type = strdup($1);
        $$->child[0] = create_identifier($2, yylineno);
        $$->child[1] = NULL;  /* no parameters */
        $$->child[2] = $5;    /* body */
        $$->value = $2;
        insert_symbol($2, $1, 1, 0);
    }
    | EVENT IDENTIFIER LPAREN RPAREN compound_statement {
        $$ = create_node(NODE_FUNC_DECL, yylineno);
        $$->data_type = strdup("Event");
        $$->child[0] = create_identifier($2, yylineno);
        $$->child[1] = NULL;  /* no parameters */
        $$->child[2] = $5;    /* body */
        $$->value = $2;
        insert_symbol($2, "Event", 1, 0);
    }
    | error RBRACE {
        yyerror("Syntax error in function declaration");
        $$ = NULL;
    }
    ;

parameter_list
    : parameter {
        $$ = create_node(NODE_PARAM_LIST, yylineno);
        $$->child[0] = $1;
    }
    | parameter_list COMMA parameter {
        $$ = $1;
        ASTNode* temp = $1;
        while (temp->sibling != NULL) {
            temp = temp->sibling;
        }
        temp->sibling = $3;
    }
    ;

parameter
    : type_specifier IDENTIFIER {
        $$ = create_node(NODE_PARAM, yylineno);
        $$->data_type = strdup($1);
        $$->child[0] = create_identifier($2, yylineno);
        $$->value = $2;
        insert_symbol($2, $1, 0, 0);
    }
    | type_specifier IDENTIFIER LBRACKET RBRACKET {
        $$ = create_node(NODE_PARAM, yylineno);
        $$->data_type = strdup($1);
        $$->child[0] = create_identifier($2, yylineno);
        $$->value = $2;
        insert_symbol($2, $1, 0, 1);
    }
    ;

/* -------------------- STATEMENTS -------------------- */

compound_statement
    : LBRACE RBRACE {
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        enter_scope();
        exit_scope();
    }
    | LBRACE statement_list RBRACE {
        enter_scope();
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        $$->child[0] = $2;
        exit_scope();
    }
    | LBRACE declaration_list RBRACE {
        enter_scope();
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        $$->child[0] = $2;
        exit_scope();
    }
    | LBRACE declaration_list statement_list RBRACE {
        enter_scope();
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        $$->child[0] = $2;
        $$->child[1] = $3;
        exit_scope();
    }
    | error RBRACE {
        yyerror("Syntax error in compound statement");
        $$ = NULL;
    }
    ;

statement_list
    : statement {
        $$ = create_node(NODE_STMT_LIST, yylineno);
        $$->child[0] = $1;
    }
    | statement_list statement {
        $$ = $1;
        ASTNode* temp = $1;
        while (temp->sibling != NULL) {
            temp = temp->sibling;
        }
        temp->sibling = $2;
    }
    ;

statement
    : compound_statement     { $$ = $1; }
    | expression_statement   { $$ = $1; }
    | if_statement           { $$ = $1; }
    | iteration_statement    { $$ = $1; }
    | jump_statement         { $$ = $1; }
    | print_statement        { $$ = $1; }
    ;

expression_statement
    : SEMICOLON {
        $$ = create_node(NODE_EXPR_STMT, yylineno);
    }
    | expression SEMICOLON {
        $$ = create_node(NODE_EXPR_STMT, yylineno);
        $$->child[0] = $1;
    }
    | error SEMICOLON {
        yyerror("Invalid expression statement");
        $$ = NULL;
    }
    ;

/* -------------------- CONTROL FLOW: IF STATEMENTS -------------------- */

if_statement
    : ERA LPAREN expression RPAREN statement {
        $$ = create_node(NODE_IF_STMT, yylineno);
        $$->child[0] = $3;  /* condition */
        $$->child[1] = $5;  /* then-statement */
    }
    | ERA LPAREN expression RPAREN statement ALTERNATE statement {
        $$ = create_node(NODE_IF_STMT, yylineno);
        $$->child[0] = $3;  /* condition */
        $$->child[1] = $5;  /* then-statement */
        $$->child[2] = $7;  /* else-statement */
    }
    | ERA LPAREN expression RPAREN statement ALTERNATE if_statement {
        $$ = create_node(NODE_IF_STMT, yylineno);
        $$->child[0] = $3;  /* condition */
        $$->child[1] = $5;  /* then-statement */
        $$->child[2] = $7;  /* else-if chain */
    }
    | ERA LPAREN error RPAREN statement {
        yyerror("Invalid condition in if statement");
        $$ = NULL;
    }
    ;

/* -------------------- CONTROL FLOW: LOOPS -------------------- */

iteration_statement
    : LOOP LPAREN expression RPAREN statement {
        $$ = create_node(NODE_WHILE_STMT, yylineno);
        $$->child[0] = $3;  /* condition */
        $$->child[1] = $5;  /* body */
    }
    | LOOP LPAREN expression_statement expression_statement RPAREN statement {
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3;  /* init */
        $$->child[1] = $4;  /* condition */
        $$->child[2] = NULL;  /* no increment */
        $$->child[3] = $6;  /* body */
    }
    | LOOP LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3;  /* init */
        $$->child[1] = $4;  /* condition */
        $$->child[2] = $5;  /* increment */
        $$->child[3] = $7;  /* body */
    }
    | LOOP LPAREN variable_declaration expression_statement RPAREN statement {
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3;  /* init with declaration */
        $$->child[1] = $4;  /* condition */
        $$->child[2] = NULL;  /* no increment */
        $$->child[3] = $6;  /* body */
    }
    | LOOP LPAREN variable_declaration expression_statement expression RPAREN statement {
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3;  /* init with declaration */
        $$->child[1] = $4;  /* condition */
        $$->child[2] = $5;  /* increment */
        $$->child[3] = $7;  /* body */
    }
    | LOOP LPAREN error RPAREN statement {
        yyerror("Syntax error in loop header");
        $$ = NULL;
    }
    ;

/* -------------------- JUMP STATEMENTS -------------------- */

jump_statement
    : PERSIST SEMICOLON {
        $$ = create_node(NODE_CONTINUE_STMT, yylineno);
    }
    | ESCAPE SEMICOLON {
        $$ = create_node(NODE_BREAK_STMT, yylineno);
    }
    | RESOLVE SEMICOLON {
        $$ = create_node(NODE_RETURN_STMT, yylineno);
    }
    | RESOLVE expression SEMICOLON {
        $$ = create_node(NODE_RETURN_STMT, yylineno);
        $$->child[0] = $2;
    }
    ;

print_statement
    : BROADCAST LPAREN expression RPAREN SEMICOLON {
        $$ = create_node(NODE_PRINT_STMT, yylineno);
        $$->child[0] = $3;
    }
    | BROADCAST LPAREN STRING_LITERAL RPAREN SEMICOLON {
        $$ = create_node(NODE_PRINT_STMT, yylineno);
        $$->child[0] = create_string_literal($3, yylineno);
    }
    | OBSERVE LPAREN expression RPAREN SEMICOLON {
        $$ = create_node(NODE_PRINT_STMT, yylineno);
        $$->child[0] = $3;
    }
    ;

/* -------------------- EXPRESSIONS -------------------- */

expression
    : assignment_expression {
        $$ = $1;
    }
    | expression COMMA assignment_expression {
        $$ = create_binary_expr(",", $1, $3, yylineno);
    }
    ;

assignment_expression
    : logical_or_expression { $$ = $1; }
    | postfix_expression ASSIGN assignment_expression {
        $$ = create_binary_expr("=", $1, $3, yylineno);
    }
    | postfix_expression PLUS ASSIGN assignment_expression {
        $$ = create_binary_expr("+=", $1, $4, yylineno);
    }
    | postfix_expression MINUS ASSIGN assignment_expression {
        $$ = create_binary_expr("-=", $1, $4, yylineno);
    }
    | postfix_expression MULTIPLY ASSIGN assignment_expression {
        $$ = create_binary_expr("*=", $1, $4, yylineno);
    }
    | postfix_expression DIVIDE ASSIGN assignment_expression {
        $$ = create_binary_expr("/=", $1, $4, yylineno);
    }
    | postfix_expression MODULO ASSIGN assignment_expression {
        $$ = create_binary_expr("%=", $1, $4, yylineno);
    }
    ;

logical_or_expression
    : logical_and_expression { $$ = $1; }
    | logical_or_expression LOGICAL_OR logical_and_expression {
        $$ = create_binary_expr("||", $1, $3, yylineno);
    }
    ;

logical_and_expression
    : bitwise_or_expression { $$ = $1; }
    | logical_and_expression LOGICAL_AND bitwise_or_expression {
        $$ = create_binary_expr("&&", $1, $3, yylineno);
    }
    ;

bitwise_or_expression
    : bitwise_xor_expression { $$ = $1; }
    | bitwise_or_expression BITWISE_OR bitwise_xor_expression {
        $$ = create_binary_expr("|", $1, $3, yylineno);
    }
    ;

bitwise_xor_expression
    : bitwise_and_expression { $$ = $1; }
    | bitwise_xor_expression BITWISE_XOR bitwise_and_expression {
        $$ = create_binary_expr("^", $1, $3, yylineno);
    }
    ;

bitwise_and_expression
    : equality_expression { $$ = $1; }
    | bitwise_and_expression BITWISE_AND equality_expression {
        $$ = create_binary_expr("&", $1, $3, yylineno);
    }
    ;

equality_expression
    : relational_expression { $$ = $1; }
    | equality_expression EQUAL relational_expression {
        $$ = create_binary_expr("==", $1, $3, yylineno);
    }
    | equality_expression NOT_EQUAL relational_expression {
        $$ = create_binary_expr("!=", $1, $3, yylineno);
    }
    ;

relational_expression
    : shift_expression { $$ = $1; }
    | relational_expression LESS shift_expression {
        $$ = create_binary_expr("<", $1, $3, yylineno);
    }
    | relational_expression GREATER shift_expression {
        $$ = create_binary_expr(">", $1, $3, yylineno);
    }
    | relational_expression LESS_EQUAL shift_expression {
        $$ = create_binary_expr("<=", $1, $3, yylineno);
    }
    | relational_expression GREATER_EQUAL shift_expression {
        $$ = create_binary_expr(">=", $1, $3, yylineno);
    }
    ;

shift_expression
    : additive_expression { $$ = $1; }
    | shift_expression LEFT_SHIFT additive_expression {
        $$ = create_binary_expr("<<", $1, $3, yylineno);
    }
    | shift_expression RIGHT_SHIFT additive_expression {
        $$ = create_binary_expr(">>", $1, $3, yylineno);
    }
    ;

additive_expression
    : multiplicative_expression { $$ = $1; }
    | additive_expression PLUS multiplicative_expression {
        $$ = create_binary_expr("+", $1, $3, yylineno);
    }
    | additive_expression MINUS multiplicative_expression {
        $$ = create_binary_expr("-", $1, $3, yylineno);
    }
    ;

multiplicative_expression
    : unary_expression { $$ = $1; }
    | multiplicative_expression MULTIPLY unary_expression {
        $$ = create_binary_expr("*", $1, $3, yylineno);
    }
    | multiplicative_expression DIVIDE unary_expression {
        $$ = create_binary_expr("/", $1, $3, yylineno);
    }
    | multiplicative_expression MODULO unary_expression {
        $$ = create_binary_expr("%", $1, $3, yylineno);
    }
    | multiplicative_expression BITWISE_XOR unary_expression {
        $$ = create_binary_expr("^", $1, $3, yylineno);
    }
    ;

unary_expression
    : postfix_expression { $$ = $1; }
    | MINUS unary_expression %prec UNARY_MINUS {
        $$ = create_unary_expr("-", $2, yylineno);
    }
    | PLUS unary_expression %prec UNARY_PLUS {
        $$ = create_unary_expr("+", $2, yylineno);
    }
    | LOGICAL_NOT unary_expression {
        $$ = create_unary_expr("!", $2, yylineno);
    }
    | BITWISE_XOR unary_expression {
        $$ = create_unary_expr("~", $2, yylineno);
    }
    ;

postfix_expression
    : primary_expression { $$ = $1; }
    | postfix_expression LBRACKET expression RBRACKET {
        $$ = create_node(NODE_ARRAY_ACCESS, yylineno);
        $$->child[0] = $1;  /* array name */
        $$->child[1] = $3;  /* index */
    }
    | postfix_expression LPAREN RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = $1;  /* function name */
        $$->child[1] = NULL;  /* no arguments */
    }
    | postfix_expression LPAREN argument_list RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = $1;  /* function name */
        $$->child[1] = $3;  /* arguments */
    }
    | postfix_expression DOT IDENTIFIER {
        $$ = create_binary_expr(".", $1, create_identifier($3, yylineno), yylineno);
    }
    /* Built-in math functions */
    | SINE LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("sine", yylineno);
        $$->child[1] = $3;
    }
    | COSINE LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("cosine", yylineno);
        $$->child[1] = $3;
    }
    | TANGENT LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("tangent", yylineno);
        $$->child[1] = $3;
    }
    | SQUAREROOT LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("squareroot", yylineno);
        $$->child[1] = $3;
    }
    | ABSOLUTE LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("absolute", yylineno);
        $$->child[1] = $3;
    }
    | FLOOR_FUNC LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("floor", yylineno);
        $$->child[1] = $3;
    }
    | CEILING_FUNC LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("ceiling", yylineno);
        $$->child[1] = $3;
    }
    | LOGARITHM LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("logarithm", yylineno);
        $$->child[1] = $3;
    }
    | POWER LPAREN expression COMMA expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("power", yylineno);
        ASTNode* args = $3;
        args->sibling = $5;
        $$->child[1] = args;
    }
    ;

primary_expression
    : IDENTIFIER {
        $$ = create_identifier($1, yylineno);
    }
    | INTEGER_LITERAL {
        $$ = create_int_literal($1, yylineno);
    }
    | FLOAT_LITERAL {
        $$ = create_float_literal($1, yylineno);
    }
    | CHAR_LITERAL {
        $$ = create_node(NODE_CHAR_LITERAL, yylineno);
        $$->charval = $1;
    }
    | STRING_LITERAL {
        $$ = create_string_literal($1, yylineno);
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

argument_list
    : assignment_expression {
        $$ = $1;
    }
    | argument_list COMMA assignment_expression {
        $$ = $1;
        ASTNode* temp = $1;
        while (temp->sibling != NULL) {
            temp = temp->sibling;
        }
        temp->sibling = $3;
    }
    ;

%%

/* ===================================================================
   C CODE SECTION - Helper Functions
   =================================================================== */

/* -------------------- ERROR HANDLING -------------------- */

void yyerror(const char* s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
    error_count++;
}

void semantic_error(const char* msg, int line) {
    fprintf(stderr, "Semantic error at line %d: %s\n", line, msg);
    error_count++;
}

/* -------------------- AST NODE CREATION -------------------- */

ASTNode* create_node(NodeType type, int line) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation error\n");
        exit(1);
    }
    node->type = type;
    node->line = line;
    node->value = NULL;
    node->intval = 0;
    node->floatval = 0.0;
    node->data_type = NULL;
    node->op = NULL;
    node->sibling = NULL;
    for (int i = 0; i < 4; i++) {
        node->child[i] = NULL;
    }
    return node;
}

ASTNode* create_binary_expr(char* op, ASTNode* left, ASTNode* right, int line) {
    ASTNode* node = create_node(NODE_BINARY_EXPR, line);
    node->op = strdup(op);
    node->child[0] = left;
    node->child[1] = right;
    return node;
}

ASTNode* create_unary_expr(char* op, ASTNode* expr, int line) {
    ASTNode* node = create_node(NODE_UNARY_EXPR, line);
    node->op = strdup(op);
    node->child[0] = expr;
    return node;
}

ASTNode* create_identifier(char* name, int line) {
    ASTNode* node = create_node(NODE_IDENTIFIER, line);
    node->value = strdup(name);
    return node;
}

ASTNode* create_int_literal(int value, int line) {
    ASTNode* node = create_node(NODE_INTEGER_LITERAL, line);
    node->intval = value;
    return node;
}

ASTNode* create_float_literal(double value, int line) {
    ASTNode* node = create_node(NODE_FLOAT_LITERAL, line);
    node->floatval = value;
    return node;
}

ASTNode* create_string_literal(char* value, int line) {
    ASTNode* node = create_node(NODE_STRING_LITERAL, line);
    node->value = strdup(value);
    return node;
}

/* -------------------- SYMBOL TABLE FUNCTIONS -------------------- */

void insert_symbol(char* name, char* type, int is_function, int is_array) {
    /* Check for duplicate declarations in current scope */
    Symbol* sym = symbol_table;
    while (sym != NULL) {
        if (sym->scope == current_scope && strcmp(sym->name, name) == 0) {
            char error_msg[256];
            sprintf(error_msg, "Redeclaration of '%s'", name);
            semantic_error(error_msg, yylineno);
            return;
        }
        sym = sym->next;
    }
    
    /* Insert new symbol */
    Symbol* new_sym = (Symbol*)malloc(sizeof(Symbol));
    new_sym->name = strdup(name);
    new_sym->type = strdup(type);
    new_sym->scope = current_scope;
    new_sym->line = yylineno;
    new_sym->is_function = is_function;
    new_sym->is_array = is_array;
    new_sym->next = symbol_table;
    symbol_table = new_sym;
}

Symbol* lookup_symbol(char* name) {
    Symbol* sym = symbol_table;
    while (sym != NULL) {
        if (strcmp(sym->name, name) == 0) {
            return sym;
        }
        sym = sym->next;
    }
    return NULL;
}

void enter_scope() {
    current_scope++;
}

void exit_scope() {
    /* Remove symbols from the exiting scope */
    Symbol* sym = symbol_table;
    Symbol* prev = NULL;
    
    while (sym != NULL) {
        if (sym->scope == current_scope) {
            if (prev == NULL) {
                symbol_table = sym->next;
                free(sym->name);
                free(sym->type);
                free(sym);
                sym = symbol_table;
            } else {
                prev->next = sym->next;
                free(sym->name);
                free(sym->type);
                free(sym);
                sym = prev->next;
            }
        } else {
            prev = sym;
            sym = sym->next;
        }
    }
    
    current_scope--;
}

void print_symbol_table() {
    printf("\n=== Symbol Table ===\n");
    printf("%-20s %-15s %-8s %-10s %-8s\n", "Name", "Type", "Scope", "Function", "Line");
    printf("---------------------------------------------------------------\n");
    
    Symbol* sym = symbol_table;
    while (sym != NULL) {
        printf("%-20s %-15s %-8d %-10s %-8d\n", 
               sym->name, 
               sym->type, 
               sym->scope, 
               sym->is_function ? "Yes" : "No",
               sym->line);
        sym = sym->next;
    }
    printf("===================\n\n");
}

/* -------------------- AST PRINTING -------------------- */

const char* node_type_name(NodeType type) {
    switch (type) {
        case NODE_PROGRAM: return "PROGRAM";
        case NODE_DECL_LIST: return "DECL_LIST";
        case NODE_VAR_DECL: return "VAR_DECL";
        case NODE_FUNC_DECL: return "FUNC_DECL";
        case NODE_PARAM_LIST: return "PARAM_LIST";
        case NODE_PARAM: return "PARAM";
        case NODE_STMT_LIST: return "STMT_LIST";
        case NODE_COMPOUND_STMT: return "COMPOUND_STMT";
        case NODE_IF_STMT: return "IF_STMT";
        case NODE_WHILE_STMT: return "WHILE_STMT";
        case NODE_FOR_STMT: return "FOR_STMT";
        case NODE_RETURN_STMT: return "RETURN_STMT";
        case NODE_BREAK_STMT: return "BREAK_STMT";
        case NODE_CONTINUE_STMT: return "CONTINUE_STMT";
        case NODE_PRINT_STMT: return "PRINT_STMT";
        case NODE_EXPR_STMT: return "EXPR_STMT";
        case NODE_ASSIGN_STMT: return "ASSIGN_STMT";
        case NODE_BINARY_EXPR: return "BINARY_EXPR";
        case NODE_UNARY_EXPR: return "UNARY_EXPR";
        case NODE_CALL_EXPR: return "CALL_EXPR";
        case NODE_ARRAY_ACCESS: return "ARRAY_ACCESS";
        case NODE_IDENTIFIER: return "IDENTIFIER";
        case NODE_INTEGER_LITERAL: return "INTEGER";
        case NODE_FLOAT_LITERAL: return "FLOAT";
        case NODE_CHAR_LITERAL: return "CHAR";
        case NODE_STRING_LITERAL: return "STRING";
        case NODE_ARRAY_DECL: return "ARRAY_DECL";
        case NODE_STRUCT_DECL: return "STRUCT_DECL";
        case NODE_MEMBER_LIST: return "MEMBER_LIST";
        default: return "UNKNOWN";
    }
}

void print_ast(ASTNode* node, int depth) {
    if (node == NULL) return;
    
    /* Print indentation */
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }
    
    /* Print node information */
    printf("%s", node_type_name(node->type));
    
    if (node->value) {
        printf(" (%s)", node->value);
    }
    if (node->op) {
        printf(" [%s]", node->op);
    }
    if (node->data_type) {
        printf(" <%s>", node->data_type);
    }
    if (node->type == NODE_INTEGER_LITERAL) {
        printf(" = %d", node->intval);
    }
    if (node->type == NODE_FLOAT_LITERAL) {
        printf(" = %f", node->floatval);
    }
    
    printf("\n");
    
    /* Print children */
    for (int i = 0; i < 4; i++) {
        if (node->child[i]) {
            print_ast(node->child[i], depth + 1);
        }
    }
    
    /* Print siblings */
    if (node->sibling) {
        print_ast(node->sibling, depth);
    }
}

void free_ast(ASTNode* node) {
    if (node == NULL) return;
    
    /* Free children */
    for (int i = 0; i < 4; i++) {
        free_ast(node->child[i]);
    }
    
    /* Free sibling */
    free_ast(node->sibling);
    
    /* Free node data */
    if (node->value) free(node->value);
    if (node->op) free(node->op);
    if (node->data_type) free(node->data_type);
    
    free(node);
}

/* -------------------- MAIN FUNCTION -------------------- */

int main(int argc, char** argv) {
    printf("ChronoScript Parser - Syntax Analysis Phase\n");
    printf("============================================\n\n");
    
    if (argc > 1) {
        FILE* file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Error: Cannot open file '%s'\n", argv[1]);
            return 1;
        }
        yyin = file;
        printf("Parsing file: %s\n\n", argv[1]);
    } else {
        printf("Reading from standard input...\n\n");
        yyin = stdin;
    }
    
    /* Parse the input */
    int result = yyparse();
    
    if (result == 0 && error_count == 0) {
        printf("\n===========================================\n");
        printf("Parsing completed successfully!\n");
        printf("===========================================\n\n");
        
        /* Print AST */
        if (ast_root) {
            printf("=== Abstract Syntax Tree ===\n");
            print_ast(ast_root, 0);
            printf("\n");
        }
        
        /* Print symbol table */
        print_symbol_table();
        
        /* Clean up */
        free_ast(ast_root);
    } else {
        printf("\n===========================================\n");
        printf("Parsing failed with %d error(s)\n", error_count);
        printf("===========================================\n");
    }
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    return (error_count == 0) ? 0 : 1;
}
