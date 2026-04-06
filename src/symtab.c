#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symtab.h"

extern int yylineno;

static Symbol *symbol_table  = NULL;
static int     current_scope = 0;

void insert_symbol(char *name, char *type, int is_function, int is_array) {
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
    Symbol *ns   = (Symbol *)malloc(sizeof(Symbol));
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
           "Name", "Type", "Scope", "Function", "Line");
    printf("---------------------------------------------------------------\n");
    for (Symbol *s = symbol_table; s; s = s->next)
        printf("%-20s %-15s %-8d %-10s %-8d\n",
               s->name, s->type, s->scope,
               s->is_function ? "Yes" : "No", s->line);
    printf("===================\n\n");
}

void save_symbol_table_to_file(const char *filename) {
    FILE *f = fopen(filename, "w");
    if (!f) return;
    fprintf(f, "=== ChronoScript Symbol Table ===\n");
    fprintf(f, "%-20s %-15s %-8s %-10s %-8s\n",
            "Name", "Type", "Scope", "Function", "Line");
    fprintf(f, "---------------------------------------------------------------\n");
    for (Symbol *s = symbol_table; s; s = s->next)
        fprintf(f, "%-20s %-15s %-8d %-10s %-8d\n",
                s->name, s->type, s->scope,
                s->is_function ? "Yes" : "No", s->line);
    fclose(f);
}
