%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../chronoscript.tab.h"

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
