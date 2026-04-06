%{
/*
 * ChronoScript Parser - Syntax Analysis Phase
 * Bison Grammar for ChronoScript Compiler
 *
 * Changes in this version:
 *  - Removed duplicate `assignment_statement` rule (was causing ~145
 *    reduce/reduce conflicts with expression_statement).
 *    `x = expr;` now parses cleanly via assignment_expression.
 *  - Removed the redundant `ALTERNATE if_statement` alternative;
 *    `ALTERNATE statement` already covers else-if chains.
 *  - Removed duplicate STRING_LITERAL alternative from print_statement.
 *  - Added %nonassoc LOWER_THAN_ALTERNATE / ALTERNATE for clean
 *    dangling-else resolution.
 *  - Extended runtime: WHILE/FOR loops, BREAK, CONTINUE, user-defined
 *    function calls (including recursion), math built-ins.
 *  - Observe reads integers, floats (Energy), strings (Stream), chars (Atom).
 *  - Wires ICG -> optimizer -> target-code generation after parse.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* Shared AST type definitions */
#include "ast.h"

/* Compiler pipeline phases */
#include "intermediate/icg.h"
#include "optimization/optimizer.h"
#include "target/target_codegen.h"

/* Cross-platform mkdir */
#ifdef _WIN32
#  include <direct.h>
#  define CS_MKDIR(p) _mkdir(p)
#else
#  include <sys/stat.h>
#  define CS_MKDIR(p) mkdir((p), 0755)
#endif

/* ------------------------------------------------------------------
   Lexer interface
   ------------------------------------------------------------------ */
extern int   yylex(void);
extern int   yylineno;
extern FILE *yyin;
extern char *yytext;

void yyerror(const char *s);
void semantic_error(const char *msg, int line);

/* ------------------------------------------------------------------
   Symbol table
   ------------------------------------------------------------------ */
typedef struct Symbol {
    char          *name;
    char          *type;
    int            scope;
    int            line;
    int            is_function;
    int            is_array;
    struct Symbol *next;
} Symbol;

static Symbol *symbol_table  = NULL;
static int     current_scope = 0;
int            error_count   = 0;

/* AST root exported for pipeline */
ASTNode *ast_root = NULL;

/* ------------------------------------------------------------------
   AST construction helpers – forward declarations
   ------------------------------------------------------------------ */
ASTNode *create_node(NodeType type, int line);
ASTNode *create_binary_expr(char *op, ASTNode *left, ASTNode *right, int line);
ASTNode *create_unary_expr(char *op, ASTNode *expr, int line);
ASTNode *create_identifier(char *name, int line);
ASTNode *create_int_literal(int value, int line);
ASTNode *create_float_literal(double value, int line);
ASTNode *create_string_literal(char *value, int line);

void    insert_symbol(char *name, char *type, int is_function, int is_array);
Symbol *lookup_symbol(char *name);
void    enter_scope(void);
void    exit_scope(void);
void    print_symbol_table(void);
void    print_ast(ASTNode *node, int depth);
void    free_ast(ASTNode *node);

/* ------------------------------------------------------------------
   Runtime value system
   ------------------------------------------------------------------ */
typedef enum {
    RUNTIME_VOID,
    RUNTIME_INT,
    RUNTIME_FLOAT,
    RUNTIME_CHAR,
    RUNTIME_STRING
} RuntimeValueType;

typedef struct RuntimeValue {
    RuntimeValueType type;
    int    intval;
    double floatval;
    char   charval;
    char  *strval;
} RuntimeValue;

typedef struct RuntimeVariable {
    char             *name;
    char             *declared_type;
    RuntimeValue      value;
    struct RuntimeVariable *next;
} RuntimeVariable;

typedef struct RuntimeContext {
    RuntimeVariable *variables;
    int              has_return;
    int              has_break;
    int              has_continue;
    RuntimeValue     return_value;
} RuntimeContext;

/* User-defined function table */
typedef struct RuntimeFunction {
    char                  *name;
    ASTNode               *func_decl;
    struct RuntimeFunction *next;
} RuntimeFunction;

static RuntimeFunction *function_table = NULL;

/* ------------------------------------------------------------------
   Runtime forward declarations
   ------------------------------------------------------------------ */
RuntimeValue runtime_make_void(void);
RuntimeValue runtime_make_int(int v);
RuntimeValue runtime_make_float(double v);
RuntimeValue runtime_make_char(char v);
RuntimeValue runtime_make_string(const char *s);
void         runtime_free_value(RuntimeValue *v);
RuntimeValue runtime_copy_value(RuntimeValue v);
int          runtime_is_truthy(RuntimeValue v);
double       runtime_as_double(RuntimeValue v);
int          runtime_as_int(RuntimeValue v);
static int   type_is_float(const char *t);
static int   type_is_string(const char *t);
static int   type_is_char(const char *t);

RuntimeVariable *runtime_find_variable(RuntimeContext *ctx, const char *name);
RuntimeVariable *runtime_declare_variable(RuntimeContext *ctx, const char *name,
                                          const char *declared_type);
void             runtime_assign_variable(RuntimeContext *ctx, const char *name,
                                         RuntimeValue value);
RuntimeValue     runtime_default_value_for_type(const char *t);

RuntimeValue runtime_eval_expression(ASTNode *node, RuntimeContext *ctx);
void         runtime_execute_statement(ASTNode *node, RuntimeContext *ctx);
void         runtime_execute_statement_list(ASTNode *node, RuntimeContext *ctx);
void         runtime_execute_declaration_list(ASTNode *node, RuntimeContext *ctx);
void         runtime_execute_compound(ASTNode *node, RuntimeContext *ctx);
void         runtime_print_value(RuntimeValue v);
void         runtime_read_into_identifier(ASTNode *node, RuntimeContext *ctx);

void            register_all_functions(ASTNode *root);
RuntimeFunction *lookup_rt_function(const char *name);
ASTNode        *find_main_function(ASTNode *root);
int             execute_program(ASTNode *root);
void            destroy_runtime_context(RuntimeContext *ctx);

%}

/* ================================================================
   BISON DECLARATIONS
   ================================================================ */

%union {
    int    intval;
    double floatval;
    char   charval;
    char  *strval;
    struct ASTNode *node;
}

/* Tokens */
%token VOID TRUTH MATTER ATOM STREAM ENERGY HIGH_ENERGY
%token PURE_MATTER LARGE_MATTER FULL_ENERGY SMALL_MATTER
%token FLUX FIXED
%token TIMELINE STRUCTURE UNISON INSTANCE
%token EVENT PERSIST ESCAPE RESOLVE OBSERVE BROADCAST
%token ERA ALTERNATE LOOP DIVERGE REFORGE STANDARD PERSPECTIVE
%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token ASSIGN EQUAL NOT_EQUAL GREATER LESS GREATER_EQUAL LESS_EQUAL
%token PLUS_ASSIGN MINUS_ASSIGN MULTIPLY_ASSIGN DIVIDE_ASSIGN MODULO_ASSIGN
%token LOGICAL_AND LOGICAL_OR LOGICAL_NOT
%token BITWISE_AND BITWISE_OR BITWISE_XOR LEFT_SHIFT RIGHT_SHIFT
%token LBRACE RBRACE LPAREN RPAREN SEMICOLON COMMA
%token LBRACKET RBRACKET DOT COLON
%token SINE COSINE TANGENT INV_SINE INV_COSINE INV_TANGENT
%token LOGARITHM POWER ABSOLUTE FLOOR_FUNC CEILING_FUNC SQUAREROOT
%token SINGULARITY_CHECK MASS_ACCUMULATION
%token INCORPORATE CONSTANT

%token <intval>   INTEGER_LITERAL
%token <floatval> FLOAT_LITERAL
%token <charval>  CHAR_LITERAL
%token <strval>   STRING_LITERAL
%token <strval>   IDENTIFIER

/* Non-terminal types */
%type <node> program
%type <node> declaration_list declaration
%type <node> variable_declaration var_declarator_list var_declarator
%type <node> function_declaration parameter_list parameter
%type <node> statement_list statement
%type <node> compound_statement block_item_list block_item
%type <node> expression_statement
%type <node> if_statement
%type <node> iteration_statement
%type <node> switch_statement case_list case_clause
%type <node> jump_statement
%type <node> print_statement
%type <node> input_statement
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

/*
 * Operator precedence (lowest -> highest).
 *
 * LOWER_THAN_ALTERNATE / ALTERNATE: resolve the dangling-else
 * (Bison shifts ALTERNATE, associating it with the nearest ERA).
 */
%nonassoc LOWER_THAN_ALTERNATE
%nonassoc ALTERNATE

%right ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULTIPLY_ASSIGN DIVIDE_ASSIGN MODULO_ASSIGN
%left  LOGICAL_OR
%left  LOGICAL_AND
%left  BITWISE_OR
%left  BITWISE_XOR
%left  BITWISE_AND
%left  EQUAL NOT_EQUAL
%left  LESS LESS_EQUAL GREATER GREATER_EQUAL
%left  LEFT_SHIFT RIGHT_SHIFT
%left  PLUS MINUS
%left  MULTIPLY DIVIDE MODULO
%right LOGICAL_NOT UNARY_MINUS UNARY_PLUS
%left  LPAREN RPAREN LBRACKET RBRACKET DOT

%start program

%%

/* ================================================================
   GRAMMAR RULES
   ================================================================ */

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
        ASTNode *tmp = $1;
        while (tmp->sibling) tmp = tmp->sibling;
        tmp->sibling = $2;
    }
    ;

declaration
    : variable_declaration  { $$ = $1; }
    | function_declaration  { $$ = $1; }
    | struct_declaration    { $$ = $1; }
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
    ;

/* -------------------- VARIABLE DECLARATIONS -------------------- */

variable_declaration
    : type_specifier var_declarator_list SEMICOLON {
        $$ = $2;
        ASTNode *tmp = $$;
        while (tmp) { tmp->data_type = strdup($1); tmp = tmp->sibling; }
    }
    ;

var_declarator_list
    : var_declarator { $$ = $1; }
    | var_declarator_list COMMA var_declarator {
        $$ = $1;
        ASTNode *tmp = $1;
        while (tmp->sibling) tmp = tmp->sibling;
        tmp->sibling = $3;
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
        $$->child[1] = $3;
        $$->value = $1;
    }
    | array_declarator { $$ = $1; }
    ;

array_declarator
    : IDENTIFIER LBRACKET INTEGER_LITERAL RBRACKET {
        $$ = create_node(NODE_ARRAY_DECL, yylineno);
        $$->child[0] = create_identifier($1, yylineno);
        $$->intval = $3;
        $$->value = $1;
    }
    | IDENTIFIER LBRACKET RBRACKET ASSIGN LBRACE argument_list RBRACE {
        $$ = create_node(NODE_ARRAY_DECL, yylineno);
        $$->child[0] = create_identifier($1, yylineno);
        $$->child[1] = $6;
        $$->value = $1;
    }
    ;

initializer : expression { $$ = $1; } ;

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
    | IDENTIFIER    { $$ = strdup($1); }   /* user-defined struct type */
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
        ASTNode *tmp = $1;
        while (tmp->sibling) tmp = tmp->sibling;
        tmp->sibling = $2;
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
        $$->child[1] = $4;
        $$->child[2] = $6;
        $$->value = $2;
        insert_symbol($2, $1, 1, 0);
    }
    | EVENT IDENTIFIER LPAREN parameter_list RPAREN compound_statement {
        $$ = create_node(NODE_FUNC_DECL, yylineno);
        $$->data_type = strdup("Event");
        $$->child[0] = create_identifier($2, yylineno);
        $$->child[1] = $4;
        $$->child[2] = $6;
        $$->value = $2;
        insert_symbol($2, "Event", 1, 0);
    }
    | type_specifier IDENTIFIER LPAREN RPAREN compound_statement {
        $$ = create_node(NODE_FUNC_DECL, yylineno);
        $$->data_type = strdup($1);
        $$->child[0] = create_identifier($2, yylineno);
        $$->child[1] = NULL;
        $$->child[2] = $5;
        $$->value = $2;
        insert_symbol($2, $1, 1, 0);
    }
    | EVENT IDENTIFIER LPAREN RPAREN compound_statement {
        $$ = create_node(NODE_FUNC_DECL, yylineno);
        $$->data_type = strdup("Event");
        $$->child[0] = create_identifier($2, yylineno);
        $$->child[1] = NULL;
        $$->child[2] = $5;
        $$->value = $2;
        insert_symbol($2, "Event", 1, 0);
    }
    ;

parameter_list
    : parameter {
        $$ = create_node(NODE_PARAM_LIST, yylineno);
        $$->child[0] = $1;
    }
    | parameter_list COMMA parameter {
        $$ = $1;
        ASTNode *tmp = $1;
        while (tmp->sibling) tmp = tmp->sibling;
        tmp->sibling = $3;
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
        enter_scope(); exit_scope();
    }
    | LBRACE block_item_list RBRACE {
        enter_scope();
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        $$->child[0] = $2;
        exit_scope();
    }
    | error RBRACE {
        yyerror("Syntax error in compound statement");
        $$ = NULL;
    }
    ;

/* C99-style: declarations and statements may be freely mixed */
block_item_list
    : block_item {
        $$ = create_node(NODE_STMT_LIST, yylineno);
        $$->child[0] = $1;
    }
    | block_item_list block_item {
        $$ = $1;
        ASTNode *tmp = $1;
        while (tmp->sibling) tmp = tmp->sibling;
        tmp->sibling = $2;
    }
    ;

block_item
    : statement        { $$ = $1; }
    | variable_declaration { $$ = $1; }
    ;

statement_list
    : statement {
        $$ = create_node(NODE_STMT_LIST, yylineno);
        $$->child[0] = $1;
    }
    | statement_list statement {
        $$ = $1;
        ASTNode *tmp = $1;
        while (tmp->sibling) tmp = tmp->sibling;
        tmp->sibling = $2;
    }
    ;

/*
 * IMPORTANT: assignment_statement rule has been intentionally removed.
 * `x = expr;` parses as expression_statement via assignment_expression.
 * The old rule was the source of ~145 reduce/reduce conflicts.
 */
statement
    : compound_statement   { $$ = $1; }
    | expression_statement { $$ = $1; }
    | if_statement         { $$ = $1; }
    | iteration_statement  { $$ = $1; }
    | switch_statement     { $$ = $1; }
    | jump_statement       { $$ = $1; }
    | print_statement      { $$ = $1; }
    | input_statement      { $$ = $1; }
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

/* -------------------- IF STATEMENT -------------------- */
/*
 * %prec LOWER_THAN_ALTERNATE on the simple-if makes Bison prefer
 * shifting ALTERNATE over reducing, which correctly associates the
 * else-clause with the innermost if (standard dangling-else resolution).
 *
 * The explicit `ALTERNATE if_statement` alternative has been removed:
 * it was redundant (if_statement -> statement) and caused extra conflicts.
 */
if_statement
    : ERA LPAREN expression RPAREN statement %prec LOWER_THAN_ALTERNATE {
        $$ = create_node(NODE_IF_STMT, yylineno);
        $$->child[0] = $3;
        $$->child[1] = $5;
    }
    | ERA LPAREN expression RPAREN statement ALTERNATE statement {
        $$ = create_node(NODE_IF_STMT, yylineno);
        $$->child[0] = $3;
        $$->child[1] = $5;
        $$->child[2] = $7;
    }
    | ERA LPAREN error RPAREN statement {
        yyerror("Invalid condition in if statement");
        $$ = NULL;
    }
    ;

/* -------------------- LOOPS -------------------- */

iteration_statement
    : LOOP LPAREN expression RPAREN statement {
        /* While-style loop */
        $$ = create_node(NODE_WHILE_STMT, yylineno);
        $$->child[0] = $3;
        $$->child[1] = $5;
    }
    | LOOP LPAREN expression_statement expression_statement RPAREN statement {
        /* For-style: init(expr); cond(expr); body */
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3;    /* init  – expr_stmt */
        $$->child[1] = $4;    /* cond  – expr_stmt */
        $$->child[2] = NULL;
        $$->child[3] = $6;    /* body */
    }
    | LOOP LPAREN expression_statement expression_statement expression RPAREN statement {
        /* For-style: init(expr); cond(expr); incr(expr); body */
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3;
        $$->child[1] = $4;
        $$->child[2] = $5;
        $$->child[3] = $7;
    }
    | LOOP LPAREN variable_declaration expression_statement RPAREN statement {
        /* For-style: init(decl); cond(expr); body */
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3;    /* init  – var_decl */
        $$->child[1] = $4;
        $$->child[2] = NULL;
        $$->child[3] = $6;
    }
    | LOOP LPAREN variable_declaration expression_statement expression RPAREN statement {
        /* For-style: init(decl); cond(expr); incr(expr); body */
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3;
        $$->child[1] = $4;
        $$->child[2] = $5;
        $$->child[3] = $7;
    }
    | LOOP LPAREN error RPAREN statement {
        yyerror("Syntax error in loop header");
        $$ = NULL;
    }
    | DIVERGE LPAREN expression RPAREN statement {
        /* Diverge = while */
        $$ = create_node(NODE_WHILE_STMT, yylineno);
        $$->child[0] = $3;
        $$->child[1] = $5;
    }
    ;

/* -------------------- SWITCH / CASE (reforge / standard / perspective) ---------- */

switch_statement
    : REFORGE LPAREN expression RPAREN LBRACE case_list RBRACE {
        $$ = create_node(NODE_SWITCH_STMT, yylineno);
        $$->child[0] = $3;  /* switch expr */
        $$->child[1] = $6;  /* case_list   */
    }
    | REFORGE LPAREN expression RPAREN LBRACE RBRACE {
        $$ = create_node(NODE_SWITCH_STMT, yylineno);
        $$->child[0] = $3;
    }
    ;

case_list
    : case_clause { $$ = $1; }
    | case_list case_clause {
        $$ = $1;
        ASTNode *t = $1;
        while (t->sibling) t = t->sibling;
        t->sibling = $2;
    }
    ;

case_clause
    : STANDARD expression COLON block_item_list {
        /* standard val: stmts  →  if(switch_expr==val) { stmts } */
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        $$->child[0] = $4;
        $$->data_type = NULL;
        /* attach the case value for runtime matching */
        $$->child[1] = $2;
    }
    | PERSPECTIVE COLON block_item_list {
        /* perspective: stmts  →  default block */
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        $$->child[0] = $3;
        $$->data_type = strdup("default");  /* mark as default */
    }
    ;

/* -------------------- JUMP STATEMENTS -------------------- */

jump_statement
    : PERSIST SEMICOLON { $$ = create_node(NODE_CONTINUE_STMT, yylineno); }
    | ESCAPE  SEMICOLON { $$ = create_node(NODE_BREAK_STMT,    yylineno); }
    | RESOLVE SEMICOLON { $$ = create_node(NODE_RETURN_STMT,   yylineno); }
    | RESOLVE expression SEMICOLON {
        $$ = create_node(NODE_RETURN_STMT, yylineno);
        $$->child[0] = $2;
    }
    ;

/* -------------------- PRINT / INPUT -------------------- */
/*
 * Duplicate STRING_LITERAL alternative removed from print_statement:
 * STRING_LITERAL is already a valid primary_expression so the two rules
 * were reduce/reduce-conflicting on RPAREN lookahead.
 */
print_statement
    : BROADCAST LPAREN expression RPAREN SEMICOLON {
        $$ = create_node(NODE_PRINT_STMT, yylineno);
        $$->child[0] = $3;
    }
    ;

input_statement
    : OBSERVE LPAREN IDENTIFIER RPAREN SEMICOLON {
        $$ = create_node(NODE_INPUT_STMT, yylineno);
        $$->child[0] = create_identifier($3, yylineno);
    }
    ;

/* -------------------- EXPRESSIONS -------------------- */

expression
    : assignment_expression { $$ = $1; }
    ;

assignment_expression
    : logical_or_expression { $$ = $1; }
    | postfix_expression ASSIGN assignment_expression {
        $$ = create_binary_expr("=", $1, $3, yylineno);
    }
    | postfix_expression PLUS_ASSIGN assignment_expression {
        $$ = create_binary_expr("+=", $1, $3, yylineno);
    }
    | postfix_expression MINUS_ASSIGN assignment_expression {
        $$ = create_binary_expr("-=", $1, $3, yylineno);
    }
    | postfix_expression MULTIPLY_ASSIGN assignment_expression {
        $$ = create_binary_expr("*=", $1, $3, yylineno);
    }
    | postfix_expression DIVIDE_ASSIGN assignment_expression {
        $$ = create_binary_expr("/=", $1, $3, yylineno);
    }
    | postfix_expression MODULO_ASSIGN assignment_expression {
        $$ = create_binary_expr("%=", $1, $3, yylineno);
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
    | equality_expression EQUAL     relational_expression {
        $$ = create_binary_expr("==", $1, $3, yylineno);
    }
    | equality_expression NOT_EQUAL relational_expression {
        $$ = create_binary_expr("!=", $1, $3, yylineno);
    }
    ;

relational_expression
    : shift_expression { $$ = $1; }
    | relational_expression LESS          shift_expression {
        $$ = create_binary_expr("<",  $1, $3, yylineno);
    }
    | relational_expression GREATER       shift_expression {
        $$ = create_binary_expr(">",  $1, $3, yylineno);
    }
    | relational_expression LESS_EQUAL    shift_expression {
        $$ = create_binary_expr("<=", $1, $3, yylineno);
    }
    | relational_expression GREATER_EQUAL shift_expression {
        $$ = create_binary_expr(">=", $1, $3, yylineno);
    }
    ;

shift_expression
    : additive_expression { $$ = $1; }
    | shift_expression LEFT_SHIFT  additive_expression {
        $$ = create_binary_expr("<<", $1, $3, yylineno);
    }
    | shift_expression RIGHT_SHIFT additive_expression {
        $$ = create_binary_expr(">>", $1, $3, yylineno);
    }
    ;

additive_expression
    : multiplicative_expression { $$ = $1; }
    | additive_expression PLUS  multiplicative_expression {
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
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | postfix_expression LPAREN RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = $1;
        $$->child[1] = NULL;
    }
    | postfix_expression LPAREN argument_list RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | postfix_expression DOT IDENTIFIER {
        $$ = create_binary_expr(".", $1,
             create_identifier($3, yylineno), yylineno);
    }
    /* Built-in math functions */
    | SINE       LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("sine", yylineno);
        $$->child[1] = $3;
    }
    | COSINE     LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("cosine", yylineno);
        $$->child[1] = $3;
    }
    | TANGENT    LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("tangent", yylineno);
        $$->child[1] = $3;
    }
    | INV_SINE   LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("invSine", yylineno);
        $$->child[1] = $3;
    }
    | INV_COSINE LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("invCosine", yylineno);
        $$->child[1] = $3;
    }
    | INV_TANGENT LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("invTangent", yylineno);
        $$->child[1] = $3;
    }
    | SQUAREROOT LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("squareroot", yylineno);
        $$->child[1] = $3;
    }
    | ABSOLUTE   LPAREN expression RPAREN {
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
    | LOGARITHM  LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("logarithm", yylineno);
        $$->child[1] = $3;
    }
    | POWER LPAREN expression COMMA expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("power", yylineno);
        $3->sibling  = $5;
        $$->child[1] = $3;
    }
    | SINGULARITY_CHECK LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("SingularityCheck", yylineno);
        $$->child[1] = $3;
    }
    | MASS_ACCUMULATION LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("MassAccumulation", yylineno);
        $$->child[1] = $3;
    }
    ;

primary_expression
    : IDENTIFIER              { $$ = create_identifier($1, yylineno); }
    | INTEGER_LITERAL         { $$ = create_int_literal($1, yylineno); }
    | FLOAT_LITERAL           { $$ = create_float_literal($1, yylineno); }
    | CHAR_LITERAL            {
        $$ = create_node(NODE_CHAR_LITERAL, yylineno);
        $$->charval = $1;
    }
    | STRING_LITERAL          { $$ = create_string_literal($1, yylineno); }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

argument_list
    : assignment_expression { $$ = $1; }
    | argument_list COMMA assignment_expression {
        $$ = $1;
        ASTNode *tmp = $1;
        while (tmp->sibling) tmp = tmp->sibling;
        tmp->sibling = $3;
    }
    ;

%%

/* ================================================================
   C CODE SECTION – helpers, runtime, main
   ================================================================ */

/* -------------------- Error handling -------------------- */

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
    error_count++;
}

void semantic_error(const char *msg, int line) {
    fprintf(stderr, "Semantic error at line %d: %s\n", line, msg);
    error_count++;
}

/* -------------------- AST node factories -------------------- */

ASTNode *create_node(NodeType type, int line) {
    ASTNode *n = (ASTNode *)calloc(1, sizeof(ASTNode));
    if (!n) { fputs("OOM\n", stderr); exit(1); }
    n->type = type;
    n->line = line;
    return n;
}

ASTNode *create_binary_expr(char *op, ASTNode *left, ASTNode *right, int line) {
    ASTNode *n = create_node(NODE_BINARY_EXPR, line);
    n->op = strdup(op);
    n->child[0] = left;
    n->child[1] = right;
    return n;
}

ASTNode *create_unary_expr(char *op, ASTNode *expr, int line) {
    ASTNode *n = create_node(NODE_UNARY_EXPR, line);
    n->op = strdup(op);
    n->child[0] = expr;
    return n;
}

ASTNode *create_identifier(char *name, int line) {
    ASTNode *n = create_node(NODE_IDENTIFIER, line);
    n->value = strdup(name);
    return n;
}

ASTNode *create_int_literal(int value, int line) {
    ASTNode *n = create_node(NODE_INTEGER_LITERAL, line);
    n->intval = value;
    return n;
}

ASTNode *create_float_literal(double value, int line) {
    ASTNode *n = create_node(NODE_FLOAT_LITERAL, line);
    n->floatval = value;
    return n;
}

ASTNode *create_string_literal(char *value, int line) {
    ASTNode *n = create_node(NODE_STRING_LITERAL, line);
    n->value = strdup(value);
    return n;
}

/* -------------------- Symbol table -------------------- */

void insert_symbol(char *name, char *type, int is_function, int is_array) {
    /* Only check for redeclaration of function/struct names at global scope.
       Variable and parameter redeclaration checks are skipped because
       bison final-actions run after block items are parsed, so all local
       symbols appear at scope 0, causing false positives across functions. */
    if (is_function) {
        for (Symbol *s = symbol_table; s; s = s->next) {
            if (s->is_function && strcmp(s->name, name) == 0) {
                char msg[256];
                snprintf(msg, sizeof(msg), "Redeclaration of function '%s'", name);
                semantic_error(msg, yylineno);
                return;
            }
        }
    }
    Symbol *ns = (Symbol *)malloc(sizeof(Symbol));
    ns->name        = strdup(name);
    ns->type        = strdup(type);
    ns->scope       = current_scope;
    ns->line        = yylineno;
    ns->is_function = is_function;
    ns->is_array    = is_array;
    ns->next        = symbol_table;
    symbol_table    = ns;
}

Symbol *lookup_symbol(char *name) {
    for (Symbol *s = symbol_table; s; s = s->next)
        if (strcmp(s->name, name) == 0) return s;
    return NULL;
}

void enter_scope(void) { current_scope++; }

void exit_scope(void) {
    Symbol *s = symbol_table, *prev = NULL;
    while (s) {
        if (s->scope == current_scope) {
            Symbol *del = s;
            if (prev) prev->next = s->next;
            else      symbol_table = s->next;
            s = s->next;
            free(del->name); free(del->type); free(del);
        } else { prev = s; s = s->next; }
    }
    current_scope--;
}

void print_symbol_table(void) {
    printf("\n=== Symbol Table ===\n");
    printf("%-20s %-15s %-8s %-10s %-8s\n",
           "Name","Type","Scope","Function","Line");
    printf("---------------------------------------------------------------\n");
    for (Symbol *s = symbol_table; s; s = s->next)
        printf("%-20s %-15s %-8d %-10s %-8d\n",
               s->name, s->type, s->scope,
               s->is_function ? "Yes":"No", s->line);
    printf("===================\n\n");
}

/* -------------------- AST printing -------------------- */

static const char *node_type_name(NodeType t) {
    switch (t) {
        case NODE_PROGRAM:        return "PROGRAM";
        case NODE_DECL_LIST:      return "DECL_LIST";
        case NODE_VAR_DECL:       return "VAR_DECL";
        case NODE_FUNC_DECL:      return "FUNC_DECL";
        case NODE_PARAM_LIST:     return "PARAM_LIST";
        case NODE_PARAM:          return "PARAM";
        case NODE_STMT_LIST:      return "STMT_LIST";
        case NODE_COMPOUND_STMT:  return "COMPOUND_STMT";
        case NODE_IF_STMT:        return "IF_STMT";
        case NODE_WHILE_STMT:     return "WHILE_STMT";
        case NODE_FOR_STMT:       return "FOR_STMT";
        case NODE_RETURN_STMT:    return "RETURN_STMT";
        case NODE_BREAK_STMT:     return "BREAK_STMT";
        case NODE_CONTINUE_STMT:  return "CONTINUE_STMT";
        case NODE_PRINT_STMT:     return "PRINT_STMT";
        case NODE_INPUT_STMT:     return "INPUT_STMT";
        case NODE_EXPR_STMT:      return "EXPR_STMT";
        case NODE_BINARY_EXPR:    return "BINARY_EXPR";
        case NODE_UNARY_EXPR:     return "UNARY_EXPR";
        case NODE_CALL_EXPR:      return "CALL_EXPR";
        case NODE_ARRAY_ACCESS:   return "ARRAY_ACCESS";
        case NODE_IDENTIFIER:     return "IDENTIFIER";
        case NODE_INTEGER_LITERAL: return "INTEGER";
        case NODE_FLOAT_LITERAL:  return "FLOAT";
        case NODE_CHAR_LITERAL:   return "CHAR";
        case NODE_STRING_LITERAL: return "STRING";
        case NODE_ARRAY_DECL:     return "ARRAY_DECL";
        case NODE_STRUCT_DECL:    return "STRUCT_DECL";
        case NODE_MEMBER_LIST:    return "MEMBER_LIST";
        case NODE_SWITCH_STMT:    return "SWITCH_STMT";
        default:                  return "UNKNOWN";
    }
}

void print_ast(ASTNode *n, int depth) {
    if (!n) return;
    for (int i = 0; i < depth; i++) printf("  ");
    printf("%s", node_type_name(n->type));
    if (n->value)    printf(" (%s)", n->value);
    if (n->op)       printf(" [%s]", n->op);
    if (n->data_type) printf(" <%s>", n->data_type);
    if (n->type == NODE_INTEGER_LITERAL) printf(" = %d", n->intval);
    if (n->type == NODE_FLOAT_LITERAL)   printf(" = %f", n->floatval);
    if (n->type == NODE_CHAR_LITERAL)    printf(" = '%c'", n->charval);
    printf("\n");
    for (int i = 0; i < 4; i++) print_ast(n->child[i], depth+1);
    print_ast(n->sibling, depth);
}

void free_ast(ASTNode *n) {
    if (!n) return;
    for (int i = 0; i < 4; i++) free_ast(n->child[i]);
    free_ast(n->sibling);
    free(n->value); free(n->op); free(n->data_type);
    free(n);
}

/* ================================================================
   RUNTIME INTERPRETER
   ================================================================ */

static int type_is_float(const char *t) {
    return t && (strcmp(t,"Energy")==0 || strcmp(t,"HighEnergy")==0 ||
                 strcmp(t,"fullEnergy")==0);
}
static int type_is_string(const char *t) {
    return t && strcmp(t,"Stream")==0;
}
static int type_is_char(const char *t) {
    return t && strcmp(t,"Atom")==0;
}

/* ---- Value constructors ---- */

RuntimeValue runtime_make_void(void) {
    RuntimeValue v; memset(&v,0,sizeof(v)); v.type=RUNTIME_VOID; return v;
}
RuntimeValue runtime_make_int(int val) {
    RuntimeValue v; memset(&v,0,sizeof(v));
    v.type=RUNTIME_INT; v.intval=val; v.floatval=(double)val; return v;
}
RuntimeValue runtime_make_float(double val) {
    RuntimeValue v; memset(&v,0,sizeof(v));
    v.type=RUNTIME_FLOAT; v.floatval=val; v.intval=(int)val; return v;
}
RuntimeValue runtime_make_char(char ch) {
    RuntimeValue v; memset(&v,0,sizeof(v));
    v.type=RUNTIME_CHAR; v.charval=ch; v.intval=(int)(unsigned char)ch;
    v.floatval=(double)v.intval; return v;
}
RuntimeValue runtime_make_string(const char *s) {
    RuntimeValue v; memset(&v,0,sizeof(v));
    v.type=RUNTIME_STRING; v.strval=strdup(s?s:""); return v;
}

void runtime_free_value(RuntimeValue *v) {
    if (!v) return;
    if (v->type==RUNTIME_STRING && v->strval) { free(v->strval); v->strval=NULL; }
    v->type = RUNTIME_VOID;
}

RuntimeValue runtime_copy_value(RuntimeValue v) {
    if (v.type==RUNTIME_STRING) return runtime_make_string(v.strval);
    return v;
}

int runtime_is_truthy(RuntimeValue v) {
    switch(v.type) {
        case RUNTIME_INT:    return v.intval != 0;
        case RUNTIME_FLOAT:  return v.floatval != 0.0;
        case RUNTIME_CHAR:   return v.charval != '\0';
        case RUNTIME_STRING: return v.strval && v.strval[0]!='\0';
        default:             return 0;
    }
}

double runtime_as_double(RuntimeValue v) {
    switch(v.type) {
        case RUNTIME_FLOAT:  return v.floatval;
        case RUNTIME_CHAR:   return (double)(unsigned char)v.charval;
        case RUNTIME_INT:    return (double)v.intval;
        default:             return 0.0;
    }
}

int runtime_as_int(RuntimeValue v) {
    switch(v.type) {
        case RUNTIME_FLOAT:  return (int)v.floatval;
        case RUNTIME_CHAR:   return (int)(unsigned char)v.charval;
        case RUNTIME_INT:    return v.intval;
        default:             return 0;
    }
}

/* ---- Variable management ---- */

RuntimeVariable *runtime_find_variable(RuntimeContext *ctx, const char *name) {
    for (RuntimeVariable *v = ctx ? ctx->variables : NULL; v; v = v->next)
        if (strcmp(v->name, name)==0) return v;
    return NULL;
}

RuntimeVariable *runtime_declare_variable(RuntimeContext *ctx,
                                          const char *name,
                                          const char *declared_type) {
    RuntimeVariable *v = runtime_find_variable(ctx, name);
    if (v) return v;
    v = (RuntimeVariable *)malloc(sizeof(RuntimeVariable));
    v->name          = strdup(name);
    v->declared_type = strdup(declared_type ? declared_type : "Matter");
    v->value         = runtime_make_void();
    v->next          = ctx->variables;
    ctx->variables   = v;
    return v;
}

RuntimeValue runtime_default_value_for_type(const char *t) {
    if (type_is_float(t))  return runtime_make_float(0.0);
    if (type_is_string(t)) return runtime_make_string("");
    if (type_is_char(t))   return runtime_make_char('\0');
    return runtime_make_int(0);
}

void runtime_assign_variable(RuntimeContext *ctx, const char *name,
                              RuntimeValue value) {
    RuntimeVariable *v = runtime_find_variable(ctx, name);
    if (!v) v = runtime_declare_variable(ctx, name, "Matter");
    runtime_free_value(&v->value);
    const char *dt = v->declared_type;
    if (type_is_float(dt))
        v->value = runtime_make_float(runtime_as_double(value));
    else if (type_is_string(dt)) {
        if (value.type == RUNTIME_STRING)
            v->value = runtime_make_string(value.strval);
        else {
            char buf[128];
            if (value.type == RUNTIME_FLOAT)
                snprintf(buf, sizeof(buf), "%g", value.floatval);
            else
                snprintf(buf, sizeof(buf), "%d", runtime_as_int(value));
            v->value = runtime_make_string(buf);
        }
    } else if (type_is_char(dt))
        v->value = runtime_make_char((char)runtime_as_int(value));
    else
        v->value = runtime_make_int(runtime_as_int(value));
}

/* ---- Function table ---- */

void register_all_functions(ASTNode *root) {
    while (function_table) {
        RuntimeFunction *next = function_table->next;
        free(function_table->name);
        free(function_table);
        function_table = next;
    }
    if (!root || !root->child[0]) return;
    ASTNode *decl = root->child[0];
    while (decl) {
        ASTNode *cur = (decl->type==NODE_DECL_LIST) ? decl->child[0] : decl;
        if (cur && cur->type==NODE_FUNC_DECL && cur->value) {
            RuntimeFunction *rf = (RuntimeFunction *)malloc(sizeof(RuntimeFunction));
            rf->name       = strdup(cur->value);
            rf->func_decl  = cur;
            rf->next       = function_table;
            function_table = rf;
        }
        decl = decl->sibling;
    }
}

RuntimeFunction *lookup_rt_function(const char *name) {
    for (RuntimeFunction *f = function_table; f; f = f->next)
        if (strcmp(f->name, name)==0) return f;
    return NULL;
}

/* ---- Expression evaluator ---- */

RuntimeValue runtime_eval_expression(ASTNode *node, RuntimeContext *ctx) {
    if (!node) return runtime_make_void();

    switch (node->type) {
    case NODE_INTEGER_LITERAL: return runtime_make_int(node->intval);
    case NODE_FLOAT_LITERAL:   return runtime_make_float(node->floatval);
    case NODE_CHAR_LITERAL:    return runtime_make_char(node->charval);
    case NODE_STRING_LITERAL:  return runtime_make_string(node->value);

    case NODE_IDENTIFIER: {
        RuntimeVariable *v = runtime_find_variable(ctx, node->value);
        return v ? runtime_copy_value(v->value) : runtime_make_int(0);
    }

    case NODE_ARRAY_ACCESS: {
        const char *aname = node->child[0] ? node->child[0]->value : NULL;
        if (!aname) return runtime_make_int(0);
        RuntimeValue idx = runtime_eval_expression(node->child[1], ctx);
        int i = runtime_as_int(idx);
        runtime_free_value(&idx);
        char ename[512];
        snprintf(ename, sizeof(ename), "%s__%d", aname, i);
        RuntimeVariable *ev = runtime_find_variable(ctx, ename);
        return ev ? runtime_copy_value(ev->value) : runtime_make_int(0);
    }

    case NODE_UNARY_EXPR: {
        RuntimeValue op = runtime_eval_expression(node->child[0], ctx);
        RuntimeValue r  = runtime_make_void();
        if      (strcmp(node->op,"-")==0)
            r = (op.type==RUNTIME_FLOAT)
                ? runtime_make_float(-runtime_as_double(op))
                : runtime_make_int(-runtime_as_int(op));
        else if (strcmp(node->op,"+")==0)
            r = runtime_copy_value(op);
        else if (strcmp(node->op,"!")==0)
            r = runtime_make_int(!runtime_is_truthy(op));
        else if (strcmp(node->op,"~")==0)
            r = runtime_make_int(~runtime_as_int(op));
        runtime_free_value(&op);
        return r;
    }

    case NODE_BINARY_EXPR: {
        const char *op = node->op;

        /* Simple identifier assignment */
        if (strcmp(op,"=")==0 && node->child[0]) {
            if (node->child[0]->type == NODE_IDENTIFIER) {
                RuntimeValue rhs = runtime_eval_expression(node->child[1], ctx);
                runtime_assign_variable(ctx, node->child[0]->value, rhs);
                RuntimeValue res = runtime_copy_value(rhs);
                runtime_free_value(&rhs);
                return res;
            }
            /* Array element assignment: arr[i] = value */
            if (node->child[0]->type == NODE_ARRAY_ACCESS) {
                ASTNode *acc = node->child[0];
                const char *aname = acc->child[0] ? acc->child[0]->value : NULL;
                RuntimeValue rhs = runtime_eval_expression(node->child[1], ctx);
                if (aname) {
                    RuntimeValue idx = runtime_eval_expression(acc->child[1], ctx);
                    int i = runtime_as_int(idx);
                    runtime_free_value(&idx);
                    char ename[512];
                    snprintf(ename, sizeof(ename), "%s__%d", aname, i);
                    runtime_assign_variable(ctx, ename, rhs);
                }
                return rhs;
            }
            /* Fallback: evaluate rhs */
            return runtime_eval_expression(node->child[1], ctx);
        }

        /* Compound assignments */
        if ((strcmp(op,"+=")==0||strcmp(op,"-=")==0||
             strcmp(op,"*=")==0||strcmp(op,"/=")==0||strcmp(op,"%=")==0) &&
            node->child[0] && node->child[0]->type==NODE_IDENTIFIER)
        {
            RuntimeValue cur = runtime_eval_expression(node->child[0], ctx);
            RuntimeValue rhs = runtime_eval_expression(node->child[1], ctx);
            int ci = runtime_as_int(cur), ri = runtime_as_int(rhs);
            double cd = runtime_as_double(cur), rd = runtime_as_double(rhs);
            int fm = (cur.type==RUNTIME_FLOAT||rhs.type==RUNTIME_FLOAT);
            RuntimeValue res = runtime_make_void();
            if      (strcmp(op,"+=")==0)
                res = fm?runtime_make_float(cd+rd):runtime_make_int(ci+ri);
            else if (strcmp(op,"-=")==0)
                res = fm?runtime_make_float(cd-rd):runtime_make_int(ci-ri);
            else if (strcmp(op,"*=")==0)
                res = fm?runtime_make_float(cd*rd):runtime_make_int(ci*ri);
            else if (strcmp(op,"/=")==0) {
                res = (ri==0)?runtime_make_int(0)
                    :(fm?runtime_make_float(cd/rd):runtime_make_int(ci/ri));
            } else
                res = (ri==0)?runtime_make_int(0):runtime_make_int(ci%ri);
            runtime_assign_variable(ctx, node->child[0]->value, res);
            RuntimeValue ret = runtime_copy_value(res);
            runtime_free_value(&cur); runtime_free_value(&rhs);
            runtime_free_value(&res);
            return ret;
        }

        /* Arithmetic / relational / logical / bitwise */
        RuntimeValue lv = runtime_eval_expression(node->child[0], ctx);
        RuntimeValue rv = runtime_eval_expression(node->child[1], ctx);
        RuntimeValue r  = runtime_make_void();
        int fm = (lv.type==RUNTIME_FLOAT||rv.type==RUNTIME_FLOAT);

        if      (strcmp(op,"+")==0)
            r=fm?runtime_make_float(runtime_as_double(lv)+runtime_as_double(rv))
               :runtime_make_int(runtime_as_int(lv)+runtime_as_int(rv));
        else if (strcmp(op,"-")==0)
            r=fm?runtime_make_float(runtime_as_double(lv)-runtime_as_double(rv))
               :runtime_make_int(runtime_as_int(lv)-runtime_as_int(rv));
        else if (strcmp(op,"*")==0)
            r=fm?runtime_make_float(runtime_as_double(lv)*runtime_as_double(rv))
               :runtime_make_int(runtime_as_int(lv)*runtime_as_int(rv));
        else if (strcmp(op,"/")==0) {
            double d = runtime_as_double(rv);
            r=(d==0.0)?runtime_make_int(0)
              :(fm?runtime_make_float(runtime_as_double(lv)/d)
                  :runtime_make_int(runtime_as_int(lv)/runtime_as_int(rv)));
        }
        else if (strcmp(op,"%")==0) {
            int d=runtime_as_int(rv);
            r=d?runtime_make_int(runtime_as_int(lv)%d):runtime_make_int(0);
        }
        else if (strcmp(op,"<" )==0) r=runtime_make_int(runtime_as_double(lv)<runtime_as_double(rv));
        else if (strcmp(op,">" )==0) r=runtime_make_int(runtime_as_double(lv)>runtime_as_double(rv));
        else if (strcmp(op,"<=")==0) r=runtime_make_int(runtime_as_double(lv)<=runtime_as_double(rv));
        else if (strcmp(op,">=")==0) r=runtime_make_int(runtime_as_double(lv)>=runtime_as_double(rv));
        else if (strcmp(op,"==")==0) {
            if (lv.type==RUNTIME_STRING && rv.type==RUNTIME_STRING)
                r=runtime_make_int(lv.strval && rv.strval && strcmp(lv.strval,rv.strval)==0);
            else
                r=runtime_make_int(runtime_as_double(lv)==runtime_as_double(rv));
        }
        else if (strcmp(op,"!=")==0) {
            if (lv.type==RUNTIME_STRING && rv.type==RUNTIME_STRING)
                r=runtime_make_int(!(lv.strval && rv.strval && strcmp(lv.strval,rv.strval)==0));
            else
                r=runtime_make_int(runtime_as_double(lv)!=runtime_as_double(rv));
        }
        else if (strcmp(op,"&&")==0) r=runtime_make_int(runtime_is_truthy(lv)&&runtime_is_truthy(rv));
        else if (strcmp(op,"||")==0) r=runtime_make_int(runtime_is_truthy(lv)||runtime_is_truthy(rv));
        else if (strcmp(op,"&" )==0) r=runtime_make_int(runtime_as_int(lv)&runtime_as_int(rv));
        else if (strcmp(op,"|" )==0) r=runtime_make_int(runtime_as_int(lv)|runtime_as_int(rv));
        else if (strcmp(op,"^" )==0) r=runtime_make_int(runtime_as_int(lv)^runtime_as_int(rv));
        else if (strcmp(op,"<<")==0) r=runtime_make_int(runtime_as_int(lv)<<runtime_as_int(rv));
        else if (strcmp(op,">>")==0) r=runtime_make_int(runtime_as_int(lv)>>runtime_as_int(rv));
        else if (strcmp(op,"," )==0) { runtime_free_value(&lv); return rv; }

        runtime_free_value(&lv);
        runtime_free_value(&rv);
        return r;
    }

    case NODE_CALL_EXPR: {
        if (!node->child[0]) return runtime_make_void();
        const char *fname = node->child[0]->value;
        if (!fname) return runtime_make_void();

#define EVAL1(n) runtime_eval_expression((n), ctx)

        /* ---- Built-in math functions ---- */
        if (strcmp(fname,"sine")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=runtime_make_float(sin(runtime_as_double(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"cosine")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=runtime_make_float(cos(runtime_as_double(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"tangent")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=runtime_make_float(tan(runtime_as_double(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"invSine")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=runtime_make_float(asin(runtime_as_double(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"invCosine")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=runtime_make_float(acos(runtime_as_double(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"invTangent")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=runtime_make_float(atan(runtime_as_double(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"squareroot")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            double av=runtime_as_double(a);
            RuntimeValue r=runtime_make_float(av>=0.0?sqrt(av):0.0);
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"absolute")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=(a.type==RUNTIME_FLOAT)
                ?runtime_make_float(fabs(runtime_as_double(a)))
                :runtime_make_int(abs(runtime_as_int(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"floor")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=runtime_make_float(floor(runtime_as_double(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"ceiling")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            RuntimeValue r=runtime_make_float(ceil(runtime_as_double(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"logarithm")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            double av=runtime_as_double(a);
            RuntimeValue r=runtime_make_float(av>0.0?log(av):0.0);
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"power")==0) {
            RuntimeValue base=EVAL1(node->child[1]);
            RuntimeValue exp=node->child[1]&&node->child[1]->sibling
                ?EVAL1(node->child[1]->sibling):runtime_make_int(1);
            RuntimeValue r=runtime_make_float(
                pow(runtime_as_double(base),runtime_as_double(exp)));
            runtime_free_value(&base); runtime_free_value(&exp); return r;
        }

        /* ---- SingularityCheck(n) — prime detection ---- */
        if (strcmp(fname,"SingularityCheck")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            int n=runtime_as_int(a); runtime_free_value(&a);
            if (n < 2) return runtime_make_int(0);
            if (n == 2) return runtime_make_int(1);
            if (n % 2 == 0) return runtime_make_int(0);
            for (int d=3; (long long)d*d<=n; d+=2)
                if (n%d==0) return runtime_make_int(0);
            return runtime_make_int(1);
        }

        /* ---- MassAccumulation(n) — factorial ---- */
        if (strcmp(fname,"MassAccumulation")==0) {
            RuntimeValue a=EVAL1(node->child[1]);
            long long n=runtime_as_int(a); runtime_free_value(&a);
            long long f=1;
            for (long long i=2; i<=n; i++) f*=i;
            return runtime_make_int((int)f);
        }

#undef EVAL1

        /* ---- User-defined function ---- */
        RuntimeFunction *rf = lookup_rt_function(fname);
        if (rf) {
            RuntimeContext child_ctx;
            child_ctx.variables    = NULL;
            child_ctx.has_return   = 0;
            child_ctx.has_break    = 0;
            child_ctx.has_continue = 0;
            child_ctx.return_value = runtime_make_void();

            /* Bind parameters */
            ASTNode *pn = rf->func_decl->child[1]; /* PARAM_LIST or NULL */
            ASTNode *an = node->child[1];           /* first argument */
            while (pn && an) {
                ASTNode *param = (pn->type==NODE_PARAM_LIST) ? pn->child[0]:pn;
                if (param && param->value) {
                    RuntimeValue av = runtime_eval_expression(an, ctx);
                    runtime_declare_variable(&child_ctx, param->value,
                                            param->data_type);
                    runtime_assign_variable(&child_ctx, param->value, av);
                    runtime_free_value(&av);
                }
                pn = pn->sibling;
                an = an->sibling;
            }
            runtime_execute_compound(rf->func_decl->child[2], &child_ctx);
            RuntimeValue result = runtime_copy_value(child_ctx.return_value);
            destroy_runtime_context(&child_ctx);
            return result;
        }
        return runtime_make_void();
    }

    default:
        return runtime_make_void();
    }
}

/* ---- Statement executor ---- */

void runtime_print_value(RuntimeValue v) {
    switch(v.type) {
        case RUNTIME_FLOAT:  printf("%g\n",  v.floatval); break;
        case RUNTIME_STRING: printf("%s\n",  v.strval ? v.strval:""); break;
        case RUNTIME_CHAR:   printf("%c\n",  v.charval); break;
        case RUNTIME_INT:    printf("%d\n",  v.intval);  break;
        default:             printf("\n");   break;
    }
}

void runtime_read_into_identifier(ASTNode *node, RuntimeContext *ctx) {
    if (!node || node->type != NODE_IDENTIFIER) return;
    RuntimeVariable *v = runtime_find_variable(ctx, node->value);
    if (!v) {
        v = runtime_declare_variable(ctx, node->value, "Matter");
        runtime_assign_variable(ctx, v->name, runtime_make_int(0));
    }
    char buf[512];
    printf("Enter %s: ", v->name);
    fflush(stdout);
    if (!fgets(buf, sizeof(buf), stdin)) return;
    buf[strcspn(buf, "\r\n")] = '\0';

    if (type_is_float(v->declared_type)) {
        RuntimeValue val = runtime_make_float(strtod(buf, NULL));
        runtime_assign_variable(ctx, v->name, val);
        runtime_free_value(&val);
    } else if (type_is_string(v->declared_type)) {
        RuntimeValue val = runtime_make_string(buf);
        runtime_assign_variable(ctx, v->name, val);
        runtime_free_value(&val);
    } else if (type_is_char(v->declared_type)) {
        RuntimeValue val = runtime_make_char(buf[0] ? buf[0] : '\0');
        runtime_assign_variable(ctx, v->name, val);
    } else {
        /*
         * Default: integer.  Covers Matter, Truth, pureMatter,
         * largeMatter, smallMatter.  For Truth, 0/non-zero is read.
         */
        RuntimeValue val = runtime_make_int((int)strtol(buf, NULL, 10));
        runtime_assign_variable(ctx, v->name, val);
    }
}

void runtime_execute_statement(ASTNode *node, RuntimeContext *ctx) {
    if (!node) return;
    if (ctx->has_return || ctx->has_break || ctx->has_continue) return;

    switch (node->type) {
    case NODE_COMPOUND_STMT:
        runtime_execute_compound(node, ctx);
        break;

    case NODE_EXPR_STMT:
        if (node->child[0]) {
            RuntimeValue v = runtime_eval_expression(node->child[0], ctx);
            runtime_free_value(&v);
        }
        break;

    case NODE_PRINT_STMT: {
        RuntimeValue v = runtime_eval_expression(node->child[0], ctx);
        runtime_print_value(v);
        runtime_free_value(&v);
        break;
    }

    case NODE_INPUT_STMT:
        runtime_read_into_identifier(node->child[0], ctx);
        break;

    case NODE_IF_STMT: {
        RuntimeValue cond = runtime_eval_expression(node->child[0], ctx);
        int truthy = runtime_is_truthy(cond);
        runtime_free_value(&cond);
        if (truthy)
            runtime_execute_statement(node->child[1], ctx);
        else if (node->child[2])
            runtime_execute_statement(node->child[2], ctx);
        break;
    }

    case NODE_WHILE_STMT: {
        while (!ctx->has_return && !ctx->has_break) {
            RuntimeValue cond = runtime_eval_expression(node->child[0], ctx);
            int truthy = runtime_is_truthy(cond);
            runtime_free_value(&cond);
            if (!truthy) break;
            runtime_execute_statement(node->child[1], ctx);
            if (ctx->has_continue) ctx->has_continue = 0;
        }
        ctx->has_break = 0;
        break;
    }

    case NODE_FOR_STMT: {
        /* Init */
        if (node->child[0]) {
            if (node->child[0]->type==NODE_VAR_DECL ||
                node->child[0]->type==NODE_ARRAY_DECL)
                runtime_execute_declaration_list(node->child[0], ctx);
            else
                runtime_execute_statement(node->child[0], ctx);
        }
        while (!ctx->has_return && !ctx->has_break) {
            /* Condition */
            if (node->child[1] && node->child[1]->child[0]) {
                RuntimeValue cond =
                    runtime_eval_expression(node->child[1]->child[0], ctx);
                int truthy = runtime_is_truthy(cond);
                runtime_free_value(&cond);
                if (!truthy) break;
            }
            /* Body */
            runtime_execute_statement(node->child[3], ctx);
            if (ctx->has_break) break;
            if (ctx->has_continue) ctx->has_continue = 0;
            /* Increment */
            if (node->child[2]) {
                RuntimeValue inc =
                    runtime_eval_expression(node->child[2], ctx);
                runtime_free_value(&inc);
            }
        }
        ctx->has_break = 0;
        break;
    }

    case NODE_RETURN_STMT:
        ctx->has_return   = 1;
        ctx->return_value = node->child[0]
            ? runtime_eval_expression(node->child[0], ctx)
            : runtime_make_void();
        break;

    case NODE_BREAK_STMT:
        ctx->has_break = 1;
        break;

    case NODE_CONTINUE_STMT:
        ctx->has_continue = 1;
        break;

    case NODE_VAR_DECL: {
        RuntimeVariable *v =
            runtime_declare_variable(ctx, node->value, node->data_type);
        RuntimeValue init = runtime_default_value_for_type(node->data_type);
        if (node->child[1]) {
            runtime_free_value(&init);
            init = runtime_eval_expression(node->child[1], ctx);
        }
        runtime_assign_variable(ctx, v->name, init);
        runtime_free_value(&init);
        break;
    }
    case NODE_ARRAY_DECL: {
        int size = node->intval > 0 ? node->intval : 1;
        RuntimeValue dflt = runtime_default_value_for_type(node->data_type);
        for (int ai = 0; ai < size; ai++) {
            char ename[512];
            snprintf(ename, sizeof(ename), "%s__%d", node->value, ai);
            RuntimeVariable *ev = runtime_declare_variable(ctx, ename, node->data_type);
            runtime_assign_variable(ctx, ev->name, dflt);
        }
        runtime_free_value(&dflt);
        if (node->child[1]) {
            ASTNode *init = node->child[1];
            int ai = 0;
            while (init) {
                ASTNode *val = (init->type == NODE_STMT_LIST ||
                                init->type == NODE_DECL_LIST)
                               ? init->child[0] : init;
                if (val) {
                    char ename[512];
                    snprintf(ename, sizeof(ename), "%s__%d", node->value, ai);
                    RuntimeValue iv = runtime_eval_expression(val, ctx);
                    runtime_assign_variable(ctx, ename, iv);
                    runtime_free_value(&iv);
                }
                ai++;
                init = init->sibling;
            }
        }
        break;
    }

    case NODE_SWITCH_STMT: {
        /* reforge(expr) { standard val: stmts; ... perspective: stmts; } */
        if (!node->child[0]) break;
        RuntimeValue sw = runtime_eval_expression(node->child[0], ctx);
        int matched = 0;
        ASTNode *cl = node->child[1];
        ASTNode *def_clause = NULL;
        /* First pass: find matching standard clause */
        while (cl && !ctx->has_return && !ctx->has_break) {
            if (cl->data_type && strcmp(cl->data_type,"default")==0) {
                def_clause = cl;
                cl = cl->sibling;
                continue;
            }
            /* cl->child[1] is the case value expression */
            if (cl->child[1]) {
                RuntimeValue cv = runtime_eval_expression(cl->child[1], ctx);
                int eq = (sw.type==RUNTIME_FLOAT||cv.type==RUNTIME_FLOAT)
                       ? (runtime_as_double(sw)==runtime_as_double(cv))
                       : (runtime_as_int(sw)==runtime_as_int(cv));
                runtime_free_value(&cv);
                if (eq) {
                    matched = 1;
                    runtime_execute_statement_list(cl->child[0], ctx);
                    if (ctx->has_break) { ctx->has_break = 0; break; }
                }
            }
            cl = cl->sibling;
        }
        /* Second pass: default */
        if (!matched && def_clause && !ctx->has_return && !ctx->has_break)
            runtime_execute_statement_list(def_clause->child[0], ctx);
        runtime_free_value(&sw);
        ctx->has_break = 0;
        break;
    }

    default:
        break;
    }
}

void runtime_execute_declaration_list(ASTNode *node, RuntimeContext *ctx) {
    if (!node) return;
    ASTNode *decl = node;
    while (decl) {
        ASTNode *cur=(decl->type==NODE_DECL_LIST)?decl->child[0]:decl;
        if (cur && cur->value) {
            if (cur->type == NODE_ARRAY_DECL) {
                /* Array declaration: create indexed variables name__0 .. name__n-1 */
                int size = cur->intval > 0 ? cur->intval : 1;
                RuntimeValue dflt = runtime_default_value_for_type(cur->data_type);
                for (int ai = 0; ai < size; ai++) {
                    char ename[512];
                    snprintf(ename, sizeof(ename), "%s__%d", cur->value, ai);
                    RuntimeVariable *ev =
                        runtime_declare_variable(ctx, ename, cur->data_type);
                    runtime_assign_variable(ctx, ev->name, dflt);
                }
                runtime_free_value(&dflt);
                /* If there's an initializer list (arr[] = {v1,v2,...}), apply it */
                if (cur->child[1]) {
                    ASTNode *init = cur->child[1];
                    int ai = 0;
                    while (init) {
                        ASTNode *val = (init->type == NODE_STMT_LIST ||
                                        init->type == NODE_DECL_LIST)
                                       ? init->child[0] : init;
                        if (val) {
                            char ename[512];
                            snprintf(ename, sizeof(ename), "%s__%d", cur->value, ai);
                            RuntimeValue iv = runtime_eval_expression(val, ctx);
                            runtime_assign_variable(ctx, ename, iv);
                            runtime_free_value(&iv);
                        }
                        ai++;
                        init = init->sibling;
                    }
                }
            } else if (cur->type == NODE_VAR_DECL) {
                RuntimeVariable *v =
                    runtime_declare_variable(ctx, cur->value, cur->data_type);
                RuntimeValue init = runtime_default_value_for_type(cur->data_type);
                if (cur->child[1]) {
                    runtime_free_value(&init);
                    init = runtime_eval_expression(cur->child[1], ctx);
                }
                runtime_assign_variable(ctx, v->name, init);
                runtime_free_value(&init);
            }
        }
        decl = decl->sibling;
    }
}

void runtime_execute_statement_list(ASTNode *node, RuntimeContext *ctx) {
    if (!node) return;
    ASTNode *stmt = node;
    while (stmt &&
           !ctx->has_return && !ctx->has_break && !ctx->has_continue) {
        ASTNode *cur=(stmt->type==NODE_STMT_LIST)?stmt->child[0]:stmt;
        runtime_execute_statement(cur, ctx);
        stmt = stmt->sibling;
    }
}

void runtime_execute_compound(ASTNode *node, RuntimeContext *ctx) {
    if (!node) return;
    /* block_item_list is stored as NODE_STMT_LIST chain in child[0] */
    if (node->child[0])
        runtime_execute_statement_list(node->child[0], ctx);
}

void destroy_runtime_context(RuntimeContext *ctx) {
    if (!ctx) return;
    RuntimeVariable *v = ctx->variables;
    while (v) {
        RuntimeVariable *next = v->next;
        free(v->name); free(v->declared_type);
        runtime_free_value(&v->value);
        free(v);
        v = next;
    }
    runtime_free_value(&ctx->return_value);
    ctx->variables = NULL;
}

ASTNode *find_main_function(ASTNode *root) {
    if (!root || !root->child[0]) return NULL;
    ASTNode *decl = root->child[0];
    while (decl) {
        ASTNode *cur=(decl->type==NODE_DECL_LIST)?decl->child[0]:decl;
        if (cur && cur->type==NODE_FUNC_DECL &&
            cur->value && strcmp(cur->value,"main")==0)
            return cur;
        decl = decl->sibling;
    }
    return NULL;
}

int execute_program(ASTNode *root) {
    register_all_functions(root);
    ASTNode *main_fn = find_main_function(root);
    if (!main_fn) {
        fprintf(stderr, "Runtime error: Event main() not found\n");
        return 1;
    }
    RuntimeContext ctx;
    ctx.variables    = NULL;
    ctx.has_return   = 0;
    ctx.has_break    = 0;
    ctx.has_continue = 0;
    ctx.return_value = runtime_make_void();
    printf("=== Program Output ===\n");
    runtime_execute_compound(main_fn->child[2], &ctx);
    int exit_code = (ctx.has_return && ctx.return_value.type==RUNTIME_INT)
                    ? ctx.return_value.intval : 0;
    destroy_runtime_context(&ctx);
    return exit_code;
}

/* ================================================================
   COMPILER PIPELINE – semantic symbol table + ICG + opt + target
   ================================================================ */

static void run_compiler_pipeline(ASTNode *root) {
    CS_MKDIR("outputs");

    /* Save symbol table */
    FILE *sf = fopen("outputs/symbol_table.txt","w");
    if (sf) {
        fprintf(sf,"=== ChronoScript Symbol Table ===\n");
        fprintf(sf,"%-20s %-15s %-8s %-10s %-8s\n",
                "Name","Type","Scope","Function","Line");
        fprintf(sf,"---------------------------------------------------------------\n");
        for (Symbol *s=symbol_table; s; s=s->next)
            fprintf(sf,"%-20s %-15s %-8d %-10s %-8d\n",
                    s->name,s->type,s->scope,
                    s->is_function?"Yes":"No",s->line);
        fclose(sf);
        printf("Symbol table  -> outputs/symbol_table.txt\n");
    }

    /* Phase 3: ICG */
    printf("\n--- Intermediate Code Generation ---\n");
    TacCode *tac = generate_intermediate_code(root);
    if (!tac) return;
    print_tac_code(tac, stdout);
    save_tac_to_file(tac, "outputs/intermediate_code.txt");

    /* Phase 4: Optimization */
    printf("\n--- Code Optimization ---\n");
    OptimizationStats stats;
    memset(&stats, 0, sizeof(stats));
    TacCode *opt = optimize_code(tac, &stats);
    print_optimization_stats(&stats, stdout);
    if (!opt) { destroy_tac_code(tac); return; }
    save_tac_to_file(opt, "outputs/optimized_code.txt");

    /* Phase 5: Target code */
    printf("\n--- Target Code Generation ---\n");
    TargetCode *tgt = generate_target_code(opt);
    if (tgt) {
        print_target_code(tgt, stdout);
        save_target_code(tgt, "outputs/target_code.txt");
        destroy_target_code(tgt);
    }
    destroy_tac_code(opt);
}

/* ================================================================
   MAIN
   ================================================================ */

int main(int argc, char **argv) {
    printf("ChronoScript Compiler\n");
    printf("=====================\n\n");

    int         show_ast      = 0;
    int         skip_pipeline = 0;
    const char *input_file    = NULL;

    for (int i = 1; i < argc; i++) {
        if      (strcmp(argv[i],"--ast")==0)          show_ast      = 1;
        else if (strcmp(argv[i],"--no-pipeline")==0)  skip_pipeline = 1;
        else                                           input_file    = argv[i];
    }

    if (input_file) {
        FILE *f = fopen(input_file,"r");
        if (!f) {
            fprintf(stderr,"Error: Cannot open '%s'\n", input_file);
            return 1;
        }
        yyin = f;
        printf("Compiling: %s\n\n", input_file);
    } else {
        printf("Reading from stdin...\n\n");
        yyin = stdin;
    }

    int parse_result = yyparse();

    if (parse_result == 0 && error_count == 0) {
        printf("\n===========================================\n");
        printf("Compilation succeeded!\n");
        printf("===========================================\n\n");

        if (show_ast && ast_root) {
            printf("=== Abstract Syntax Tree ===\n");
            print_ast(ast_root, 0);
            printf("\n");
            print_symbol_table();
        }

        if (!skip_pipeline)
            run_compiler_pipeline(ast_root);

        if (ast_root)
            execute_program(ast_root);

        free_ast(ast_root);
    } else {
        printf("\n===========================================\n");
        printf("Compilation failed with %d error(s)\n", error_count);
        printf("===========================================\n");
    }

    if (input_file) fclose(yyin);
    return (error_count == 0) ? 0 : 1;
}

