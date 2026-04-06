#ifndef SYMTAB_H
#define SYMTAB_H

typedef struct Symbol {
    char *name;
    char *type;
    int   scope;
    int   line;
    int   is_function;
    int   is_array;
    struct Symbol *next;
} Symbol;

extern int error_count;

void    insert_symbol(char *name, char *type, int is_function, int is_array);
Symbol *lookup_symbol(char *name);
void    enter_scope(void);
void    exit_scope(void);
void    print_symbol_table(void);
void    save_symbol_table_to_file(const char *filename);
void    semantic_error(const char *msg, int line);

#endif /* SYMTAB_H */
