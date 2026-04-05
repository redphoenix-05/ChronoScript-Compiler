%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "chronoscript.tab.h"

#ifdef DEBUG
    #define DEBUG_PRINT(token) printf("Line %d: Token %s ('%s')\n", yylineno, token, yytext)
#else
    #define DEBUG_PRINT(token)
#endif

%}

%option noyywrap
%option yylineno

DIGIT           [0-9]
LETTER          [a-zA-Z_]
IDENTIFIER_CHAR [a-zA-Z0-9_]
INTEGER         {DIGIT}+
FLOAT           {DIGIT}+\.{DIGIT}+([eE][+-]?{DIGIT}+)?
CHAR_LITERAL    '([^'\\]|\\.)' 
STRING_LITERAL  \"([^\"\\]|\\.)*\"
WHITESPACE      [ \t\r]+
NEWLINE         \n

%%

"SingularityCheck" { DEBUG_PRINT("SINGULARITY_CHECK"); return SINGULARITY_CHECK; }
"MassAccumulation"  { DEBUG_PRINT("MASS_ACCUMULATION");  return MASS_ACCUMULATION; }

"#Incorporate"[^\n]*    { /* skip include/import directives */ }
"#Constant"         { DEBUG_PRINT("CONSTANT"); return CONSTANT; }

"Void"              { DEBUG_PRINT("VOID"); return VOID; }
"Truth"             { DEBUG_PRINT("TRUTH"); return TRUTH; }
"Matter"            { DEBUG_PRINT("MATTER"); return MATTER; }
"Atom"              { DEBUG_PRINT("ATOM"); return ATOM; }
"Stream"            { DEBUG_PRINT("STREAM"); return STREAM; }
"Energy"            { DEBUG_PRINT("ENERGY"); return ENERGY; }
"HighEnergy"        { DEBUG_PRINT("HIGH_ENERGY"); return HIGH_ENERGY; }
"pureMatter"        { DEBUG_PRINT("PURE_MATTER"); return PURE_MATTER; }
"largeMatter"       { DEBUG_PRINT("LARGE_MATTER"); return LARGE_MATTER; }
"fullEnergy"        { DEBUG_PRINT("FULL_ENERGY"); return FULL_ENERGY; }
"smallMatter"       { DEBUG_PRINT("SMALL_MATTER"); return SMALL_MATTER; }

"flux"              { DEBUG_PRINT("FLUX"); return FLUX; }
"fixed"             { DEBUG_PRINT("FIXED"); return FIXED; }

"timeline"          { DEBUG_PRINT("TIMELINE"); return TIMELINE; }
"structure"         { DEBUG_PRINT("STRUCTURE"); return STRUCTURE; }
"unison"            { DEBUG_PRINT("UNISON"); return UNISON; }
"instance"          { DEBUG_PRINT("INSTANCE"); return INSTANCE; }

"Event"             { DEBUG_PRINT("EVENT"); return EVENT; }
"Persist"           { DEBUG_PRINT("PERSIST"); return PERSIST; }
"Escape"            { DEBUG_PRINT("ESCAPE"); return ESCAPE; }
"Resolve"           { DEBUG_PRINT("RESOLVE"); return RESOLVE; }
"Observe"           { DEBUG_PRINT("OBSERVE"); return OBSERVE; }
"Broadcast"         { DEBUG_PRINT("BROADCAST"); return BROADCAST; }

"Era"               { DEBUG_PRINT("ERA"); return ERA; }
"Alternate"         { DEBUG_PRINT("ALTERNATE"); return ALTERNATE; }
"Loop"              { DEBUG_PRINT("LOOP"); return LOOP; }
"Diverge"           { DEBUG_PRINT("DIVERGE"); return DIVERGE; }
"reforge"           { DEBUG_PRINT("REFORGE"); return REFORGE; }
"standard"          { DEBUG_PRINT("STANDARD"); return STANDARD; }
"perspective"       { DEBUG_PRINT("PERSPECTIVE"); return PERSPECTIVE; }

"sine"              { DEBUG_PRINT("SINE"); return SINE; }
"cosine"            { DEBUG_PRINT("COSINE"); return COSINE; }
"tangent"           { DEBUG_PRINT("TANGENT"); return TANGENT; }
"invSine"           { DEBUG_PRINT("INV_SINE"); return INV_SINE; }
"invCosine"         { DEBUG_PRINT("INV_COSINE"); return INV_COSINE; }
"invTangent"        { DEBUG_PRINT("INV_TANGENT"); return INV_TANGENT; }
"logarithm"         { DEBUG_PRINT("LOGARITHM"); return LOGARITHM; }
"power"             { DEBUG_PRINT("POWER"); return POWER; }
"absolute"          { DEBUG_PRINT("ABSOLUTE"); return ABSOLUTE; }
"floor"             { DEBUG_PRINT("FLOOR_FUNC"); return FLOOR_FUNC; }
"ceiling"           { DEBUG_PRINT("CEILING_FUNC"); return CEILING_FUNC; }
"squareroot"        { DEBUG_PRINT("SQUAREROOT"); return SQUAREROOT; }

"<<"                { DEBUG_PRINT("LEFT_SHIFT"); return LEFT_SHIFT; }
">>"                { DEBUG_PRINT("RIGHT_SHIFT"); return RIGHT_SHIFT; }
"=="                { DEBUG_PRINT("EQUAL"); return EQUAL; }
"+="                { DEBUG_PRINT("PLUS_ASSIGN"); return PLUS_ASSIGN; }
"-="                { DEBUG_PRINT("MINUS_ASSIGN"); return MINUS_ASSIGN; }
"*="                { DEBUG_PRINT("MULTIPLY_ASSIGN"); return MULTIPLY_ASSIGN; }
"/="                { DEBUG_PRINT("DIVIDE_ASSIGN"); return DIVIDE_ASSIGN; }
"%="                { DEBUG_PRINT("MODULO_ASSIGN"); return MODULO_ASSIGN; }

"!="                { DEBUG_PRINT("NOT_EQUAL"); return NOT_EQUAL; }
">="                { DEBUG_PRINT("GREATER_EQUAL"); return GREATER_EQUAL; }
"<="                { DEBUG_PRINT("LESS_EQUAL"); return LESS_EQUAL; }
"&&"                { DEBUG_PRINT("LOGICAL_AND"); return LOGICAL_AND; }
"||"                { DEBUG_PRINT("LOGICAL_OR"); return LOGICAL_OR; }

"+"                 { DEBUG_PRINT("PLUS"); return PLUS; }
"-"                 { DEBUG_PRINT("MINUS"); return MINUS; }
"*"                 { DEBUG_PRINT("MULTIPLY"); return MULTIPLY; }
"/"                 { DEBUG_PRINT("DIVIDE"); return DIVIDE; }
"%"                 { DEBUG_PRINT("MODULO"); return MODULO; }
"="                 { DEBUG_PRINT("ASSIGN"); return ASSIGN; }
">"                 { DEBUG_PRINT("GREATER"); return GREATER; }
"<"                 { DEBUG_PRINT("LESS"); return LESS; }
"!"                 { DEBUG_PRINT("LOGICAL_NOT"); return LOGICAL_NOT; }
"&"                 { DEBUG_PRINT("BITWISE_AND"); return BITWISE_AND; }
"|"                 { DEBUG_PRINT("BITWISE_OR"); return BITWISE_OR; }
"^"                 { DEBUG_PRINT("BITWISE_XOR"); return BITWISE_XOR; }

"{"                 { DEBUG_PRINT("LBRACE"); return LBRACE; }
"}"                 { DEBUG_PRINT("RBRACE"); return RBRACE; }
"("                 { DEBUG_PRINT("LPAREN"); return LPAREN; }
")"                 { DEBUG_PRINT("RPAREN"); return RPAREN; }
";"                 { DEBUG_PRINT("SEMICOLON"); return SEMICOLON; }
","                 { DEBUG_PRINT("COMMA"); return COMMA; }
"["                 { DEBUG_PRINT("LBRACKET"); return LBRACKET; }
"]"                 { DEBUG_PRINT("RBRACKET"); return RBRACKET; }
"."                 { DEBUG_PRINT("DOT"); return DOT; }
":"                 { DEBUG_PRINT("COLON"); return COLON; }

{INTEGER}           { 
                        yylval.intval = atoi(yytext); 
                        DEBUG_PRINT("INTEGER_LITERAL"); 
                        return INTEGER_LITERAL; 
                    }

{FLOAT}             { 
                        yylval.floatval = atof(yytext); 
                        DEBUG_PRINT("FLOAT_LITERAL"); 
                        return FLOAT_LITERAL; 
                    }

{CHAR_LITERAL}      { 
                        if (yytext[1] == '\\') {
                            switch(yytext[2]) {
                                case 'n': yylval.charval = '\n'; break;
                                case 't': yylval.charval = '\t'; break;
                                case 'r': yylval.charval = '\r'; break;
                                case '\\': yylval.charval = '\\'; break;
                                case '\'': yylval.charval = '\''; break;
                                case '0': yylval.charval = '\0'; break;
                                default: yylval.charval = yytext[2]; break;
                            }
                        } else {
                            yylval.charval = yytext[1];
                        }
                        DEBUG_PRINT("CHAR_LITERAL"); 
                        return CHAR_LITERAL; 
                    }

{STRING_LITERAL}    { 
                        int len = strlen(yytext);
                        yylval.strval = (char*)malloc(len - 1);
                        strncpy(yylval.strval, yytext + 1, len - 2);
                        yylval.strval[len - 2] = '\0';
                        DEBUG_PRINT("STRING_LITERAL"); 
                        return STRING_LITERAL; 
                    }

{LETTER}{IDENTIFIER_CHAR}* { 
                        yylval.strval = strdup(yytext); 
                        DEBUG_PRINT("IDENTIFIER"); 
                        return IDENTIFIER; 
                    }

"//".*              { }

"/*"                {
                        int c;
                        int prev = 0;
                        while ((c = input()) != 0) {
                            if (c == '\n') yylineno++;
                            if (prev == '*' && c == '/') break;
                            prev = c;
                        }
                    }

{WHITESPACE}        { }
{NEWLINE}           { }

.                   { 
                        fprintf(stderr, "Lexical Error: Unknown symbol '%s' at line %d\n", 
                                yytext, yylineno);
                    }

%%

const char* get_token_name(int token) {
    switch(token) {
        case VOID: return "VOID";
        case TRUTH: return "TRUTH";
        case MATTER: return "MATTER";
        case ATOM: return "ATOM";
        case STREAM: return "STREAM";
        case ENERGY: return "ENERGY";
        case HIGH_ENERGY: return "HIGH_ENERGY";
        case PURE_MATTER: return "PURE_MATTER";
        case LARGE_MATTER: return "LARGE_MATTER";
        case FULL_ENERGY: return "FULL_ENERGY";
        case SMALL_MATTER: return "SMALL_MATTER";
        case FLUX: return "FLUX";
        case FIXED: return "FIXED";
        case TIMELINE: return "TIMELINE";
        case STRUCTURE: return "STRUCTURE";
        case UNISON: return "UNISON";
        case INSTANCE: return "INSTANCE";
        case EVENT: return "EVENT";
        case PERSIST: return "PERSIST";
        case ESCAPE: return "ESCAPE";
        case RESOLVE: return "RESOLVE";
        case OBSERVE: return "OBSERVE";
        case BROADCAST: return "BROADCAST";
        case ERA: return "ERA";
        case ALTERNATE: return "ALTERNATE";
        case LOOP: return "LOOP";
        case DIVERGE: return "DIVERGE";
        case REFORGE: return "REFORGE";
        case STANDARD: return "STANDARD";
        case PERSPECTIVE: return "PERSPECTIVE";
        case PLUS: return "PLUS";
        case MINUS: return "MINUS";
        case MULTIPLY: return "MULTIPLY";
        case DIVIDE: return "DIVIDE";
        case MODULO: return "MODULO";
        case ASSIGN: return "ASSIGN";
        case EQUAL: return "EQUAL";
        case NOT_EQUAL: return "NOT_EQUAL";
        case GREATER: return "GREATER";
        case LESS: return "LESS";
        case GREATER_EQUAL: return "GREATER_EQUAL";
        case LESS_EQUAL: return "LESS_EQUAL";
        case LOGICAL_AND: return "LOGICAL_AND";
        case LOGICAL_OR: return "LOGICAL_OR";
        case LOGICAL_NOT: return "LOGICAL_NOT";
        case BITWISE_AND: return "BITWISE_AND";
        case BITWISE_OR: return "BITWISE_OR";
        case BITWISE_XOR: return "BITWISE_XOR";
        case LEFT_SHIFT: return "LEFT_SHIFT";
        case RIGHT_SHIFT: return "RIGHT_SHIFT";
        case LBRACE: return "LBRACE";
        case RBRACE: return "RBRACE";
        case LPAREN: return "LPAREN";
        case RPAREN: return "RPAREN";
        case SEMICOLON: return "SEMICOLON";
        case COMMA: return "COMMA";
        case LBRACKET: return "LBRACKET";
        case RBRACKET: return "RBRACKET";
        case DOT: return "DOT";
        case COLON: return "COLON";
        case SINE: return "SINE";
        case COSINE: return "COSINE";
        case TANGENT: return "TANGENT";
        case INV_SINE: return "INV_SINE";
        case INV_COSINE: return "INV_COSINE";
        case INV_TANGENT: return "INV_TANGENT";
        case LOGARITHM: return "LOGARITHM";
        case POWER: return "POWER";
        case ABSOLUTE: return "ABSOLUTE";
        case FLOOR_FUNC: return "FLOOR_FUNC";
        case CEILING_FUNC: return "CEILING_FUNC";
        case SQUAREROOT: return "SQUAREROOT";
        case INCORPORATE: return "INCORPORATE";
        case CONSTANT: return "CONSTANT";
        case INTEGER_LITERAL: return "INTEGER_LITERAL";
        case FLOAT_LITERAL: return "FLOAT_LITERAL";
        case CHAR_LITERAL: return "CHAR_LITERAL";
        case STRING_LITERAL: return "STRING_LITERAL";
        case IDENTIFIER: return "IDENTIFIER";
        default: return "UNKNOWN";
    }
}

typedef struct {
    int token;
    char lexeme[256];
    int line;
} TokenInfo;

TokenInfo tokens[10000];
int token_count = 0;
char current_lexeme[256];

void process_file(const char* input_file, const char* output_file) {
    FILE* file = fopen(input_file, "r");
    if (!file) {
        fprintf(stderr, "Error: Cannot open file '%s'\n", input_file);
        return;
    }
    
    FILE* output = fopen(output_file, "w");
    if (!output) {
        fprintf(stderr, "Error: Cannot create output file '%s'\n", output_file);
        fclose(file);
        return;
    }
    
    yyin = file;
    yylineno = 1;
    token_count = 0;
    
    int token;
    while ((token = yylex()) != 0) {
        tokens[token_count].token = token;
        strncpy(tokens[token_count].lexeme, yytext, 255);
        tokens[token_count].lexeme[255] = '\0';
        tokens[token_count].line = yylineno;
        token_count++;
    }
    
    fprintf(output, "TOKEN TYPE           LEXEME                    LINE\n");
    fprintf(output, "--------------------------------------------------------------------------------\n");
    
    for (int i = 0; i < token_count; i++) {
        fprintf(output, "%-20s %-25s %d\n", 
                get_token_name(tokens[i].token), 
                tokens[i].lexeme, 
                tokens[i].line);
    }
    
    fprintf(output, "--------------------------------------------------------------------------------\n");
    fprintf(output, "Total Tokens: %d\n", token_count);
    fprintf(output, "Total Lines: %d\n", yylineno);
    
    fclose(file);
    fclose(output);
}

/* Standalone lexer driver retained for token-dump workflows only. */
#ifdef LEXER_STANDALONE
int main(int argc, char** argv) {
    printf("ChronoScript Lexical Analyzer\n");
    printf("==============================\n\n");
    
    const char* input_files[] = {
        "samples/sample1_helloworld.txt",
        "samples/sample2_arithmetic.txt",
        "samples/sample3_control.txt",
        "samples/sample4_functions.txt",
        "samples/sample5_complete.txt"
    };
    
    const char* output_files[] = {
        "outputs/output1_helloworld.txt",
        "outputs/output2_arithmetic.txt",
        "outputs/output3_control.txt",
        "outputs/output4_functions.txt",
        "outputs/output5_complete.txt"
    };
    
    int num_files = 5;
    
    for (int i = 0; i < num_files; i++) {
        printf("Processing sample %d...", i + 1);
        fflush(stdout);
        process_file(input_files[i], output_files[i]);
        printf(" Done!\n");
    }
    
    printf("\n==============================\n");
    printf("All samples processed successfully!\n");
    
    return 0;
}
#endif
