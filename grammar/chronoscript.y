%{
/*
 * ChronoScript Parser - Grammar Definition
 * All implementation code extracted to src/ modules.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "include/ast.h"
#include "include/symtab.h"

extern int   yylex(void);
extern int   yylineno;
extern char *yytext;

void yyerror(const char *s);
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
%type <node> statement
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
    | IDENTIFIER    { $$ = strdup($1); }
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
    : statement            { $$ = $1; }
    | variable_declaration { $$ = $1; }
    ;

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
    : SEMICOLON            { $$ = create_node(NODE_EXPR_STMT, yylineno); }
    | expression SEMICOLON { $$ = create_node(NODE_EXPR_STMT, yylineno); $$->child[0] = $1; }
    | error SEMICOLON      { yyerror("Invalid expression statement"); $$ = NULL; }
    ;

/* -------------------- IF STATEMENT -------------------- */

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
        $$ = create_node(NODE_WHILE_STMT, yylineno);
        $$->child[0] = $3; $$->child[1] = $5;
    }
    | LOOP LPAREN expression_statement expression_statement RPAREN statement {
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3; $$->child[1] = $4; $$->child[2] = NULL; $$->child[3] = $6;
    }
    | LOOP LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3; $$->child[1] = $4; $$->child[2] = $5; $$->child[3] = $7;
    }
    | LOOP LPAREN variable_declaration expression_statement RPAREN statement {
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3; $$->child[1] = $4; $$->child[2] = NULL; $$->child[3] = $6;
    }
    | LOOP LPAREN variable_declaration expression_statement expression RPAREN statement {
        $$ = create_node(NODE_FOR_STMT, yylineno);
        $$->child[0] = $3; $$->child[1] = $4; $$->child[2] = $5; $$->child[3] = $7;
    }
    | LOOP LPAREN error RPAREN statement {
        yyerror("Syntax error in loop header"); $$ = NULL;
    }
    | DIVERGE LPAREN expression RPAREN statement {
        $$ = create_node(NODE_WHILE_STMT, yylineno);
        $$->child[0] = $3; $$->child[1] = $5;
    }
    ;

/* -------------------- SWITCH / CASE -------------------- */

switch_statement
    : REFORGE LPAREN expression RPAREN LBRACE case_list RBRACE {
        $$ = create_node(NODE_SWITCH_STMT, yylineno);
        $$->child[0] = $3; $$->child[1] = $6;
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
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        $$->child[0] = $4; $$->child[1] = $2;
    }
    | PERSPECTIVE COLON block_item_list {
        $$ = create_node(NODE_COMPOUND_STMT, yylineno);
        $$->child[0] = $3;
        $$->data_type = strdup("default");
    }
    ;

/* -------------------- JUMP STATEMENTS -------------------- */

jump_statement
    : PERSIST SEMICOLON        { $$ = create_node(NODE_CONTINUE_STMT, yylineno); }
    | ESCAPE  SEMICOLON        { $$ = create_node(NODE_BREAK_STMT, yylineno); }
    | RESOLVE SEMICOLON        { $$ = create_node(NODE_RETURN_STMT, yylineno); }
    | RESOLVE expression SEMICOLON {
        $$ = create_node(NODE_RETURN_STMT, yylineno);
        $$->child[0] = $2;
    }
    ;

/* -------------------- PRINT / INPUT -------------------- */

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

expression : assignment_expression { $$ = $1; } ;

assignment_expression
    : logical_or_expression { $$ = $1; }
    | postfix_expression ASSIGN            assignment_expression { $$ = create_binary_expr("=",  $1, $3, yylineno); }
    | postfix_expression PLUS_ASSIGN       assignment_expression { $$ = create_binary_expr("+=", $1, $3, yylineno); }
    | postfix_expression MINUS_ASSIGN      assignment_expression { $$ = create_binary_expr("-=", $1, $3, yylineno); }
    | postfix_expression MULTIPLY_ASSIGN   assignment_expression { $$ = create_binary_expr("*=", $1, $3, yylineno); }
    | postfix_expression DIVIDE_ASSIGN     assignment_expression { $$ = create_binary_expr("/=", $1, $3, yylineno); }
    | postfix_expression MODULO_ASSIGN     assignment_expression { $$ = create_binary_expr("%=", $1, $3, yylineno); }
    ;

logical_or_expression
    : logical_and_expression { $$ = $1; }
    | logical_or_expression LOGICAL_OR logical_and_expression { $$ = create_binary_expr("||", $1, $3, yylineno); }
    ;

logical_and_expression
    : bitwise_or_expression { $$ = $1; }
    | logical_and_expression LOGICAL_AND bitwise_or_expression { $$ = create_binary_expr("&&", $1, $3, yylineno); }
    ;

bitwise_or_expression
    : bitwise_xor_expression { $$ = $1; }
    | bitwise_or_expression BITWISE_OR bitwise_xor_expression { $$ = create_binary_expr("|", $1, $3, yylineno); }
    ;

bitwise_xor_expression
    : bitwise_and_expression { $$ = $1; }
    | bitwise_xor_expression BITWISE_XOR bitwise_and_expression { $$ = create_binary_expr("^", $1, $3, yylineno); }
    ;

bitwise_and_expression
    : equality_expression { $$ = $1; }
    | bitwise_and_expression BITWISE_AND equality_expression { $$ = create_binary_expr("&", $1, $3, yylineno); }
    ;

equality_expression
    : relational_expression { $$ = $1; }
    | equality_expression EQUAL     relational_expression { $$ = create_binary_expr("==", $1, $3, yylineno); }
    | equality_expression NOT_EQUAL relational_expression { $$ = create_binary_expr("!=", $1, $3, yylineno); }
    ;

relational_expression
    : shift_expression { $$ = $1; }
    | relational_expression LESS          shift_expression { $$ = create_binary_expr("<",  $1, $3, yylineno); }
    | relational_expression GREATER       shift_expression { $$ = create_binary_expr(">",  $1, $3, yylineno); }
    | relational_expression LESS_EQUAL    shift_expression { $$ = create_binary_expr("<=", $1, $3, yylineno); }
    | relational_expression GREATER_EQUAL shift_expression { $$ = create_binary_expr(">=", $1, $3, yylineno); }
    ;

shift_expression
    : additive_expression { $$ = $1; }
    | shift_expression LEFT_SHIFT  additive_expression { $$ = create_binary_expr("<<", $1, $3, yylineno); }
    | shift_expression RIGHT_SHIFT additive_expression { $$ = create_binary_expr(">>", $1, $3, yylineno); }
    ;

additive_expression
    : multiplicative_expression { $$ = $1; }
    | additive_expression PLUS  multiplicative_expression { $$ = create_binary_expr("+", $1, $3, yylineno); }
    | additive_expression MINUS multiplicative_expression { $$ = create_binary_expr("-", $1, $3, yylineno); }
    ;

multiplicative_expression
    : unary_expression { $$ = $1; }
    | multiplicative_expression MULTIPLY unary_expression { $$ = create_binary_expr("*", $1, $3, yylineno); }
    | multiplicative_expression DIVIDE   unary_expression { $$ = create_binary_expr("/", $1, $3, yylineno); }
    | multiplicative_expression MODULO   unary_expression { $$ = create_binary_expr("%", $1, $3, yylineno); }
    ;

unary_expression
    : postfix_expression { $$ = $1; }
    | MINUS       unary_expression %prec UNARY_MINUS { $$ = create_unary_expr("-", $2, yylineno); }
    | PLUS        unary_expression %prec UNARY_PLUS  { $$ = create_unary_expr("+", $2, yylineno); }
    | LOGICAL_NOT unary_expression                    { $$ = create_unary_expr("!", $2, yylineno); }
    | BITWISE_XOR unary_expression                    { $$ = create_unary_expr("~", $2, yylineno); }
    ;

postfix_expression
    : primary_expression { $$ = $1; }
    | postfix_expression LBRACKET expression RBRACKET {
        $$ = create_node(NODE_ARRAY_ACCESS, yylineno);
        $$->child[0] = $1; $$->child[1] = $3;
    }
    | postfix_expression LPAREN RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = $1;
    }
    | postfix_expression LPAREN argument_list RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = $1; $$->child[1] = $3;
    }
    | postfix_expression DOT IDENTIFIER {
        $$ = create_binary_expr(".", $1, create_identifier($3, yylineno), yylineno);
    }
    /* Built-in math functions */
    | SINE        LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("sine", yylineno); $$->child[1] = $3; }
    | COSINE      LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("cosine", yylineno); $$->child[1] = $3; }
    | TANGENT     LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("tangent", yylineno); $$->child[1] = $3; }
    | INV_SINE    LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("invSine", yylineno); $$->child[1] = $3; }
    | INV_COSINE  LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("invCosine", yylineno); $$->child[1] = $3; }
    | INV_TANGENT LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("invTangent", yylineno); $$->child[1] = $3; }
    | SQUAREROOT  LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("squareroot", yylineno); $$->child[1] = $3; }
    | ABSOLUTE    LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("absolute", yylineno); $$->child[1] = $3; }
    | FLOOR_FUNC  LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("floor", yylineno); $$->child[1] = $3; }
    | CEILING_FUNC LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("ceiling", yylineno); $$->child[1] = $3; }
    | LOGARITHM   LPAREN expression RPAREN { $$ = create_node(NODE_CALL_EXPR, yylineno); $$->child[0] = create_identifier("logarithm", yylineno); $$->child[1] = $3; }
    | POWER LPAREN expression COMMA expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("power", yylineno);
        $3->sibling = $5; $$->child[1] = $3;
    }
    | SINGULARITY_CHECK LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("SingularityCheck", yylineno); $$->child[1] = $3;
    }
    | MASS_ACCUMULATION LPAREN expression RPAREN {
        $$ = create_node(NODE_CALL_EXPR, yylineno);
        $$->child[0] = create_identifier("MassAccumulation", yylineno); $$->child[1] = $3;
    }
    ;

primary_expression
    : IDENTIFIER               { $$ = create_identifier($1, yylineno); }
    | INTEGER_LITERAL          { $$ = create_int_literal($1, yylineno); }
    | FLOAT_LITERAL            { $$ = create_float_literal($1, yylineno); }
    | CHAR_LITERAL             { $$ = create_node(NODE_CHAR_LITERAL, yylineno); $$->charval = $1; }
    | STRING_LITERAL           { $$ = create_string_literal($1, yylineno); }
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

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
    error_count++;
}
