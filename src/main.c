#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../include/ast.h"
#include "../include/symtab.h"
#include "../include/interpreter.h"
#include "../include/icg.h"
#include "../include/optimizer.h"
#include "../include/target_codegen.h"

#ifdef _WIN32
#  include <direct.h>
#  define CS_MKDIR(p) _mkdir(p)
#else
#  include <sys/stat.h>
#  define CS_MKDIR(p) mkdir((p), 0755)
#endif

extern int   yyparse(void);
extern FILE *yyin;

static void run_compiler_pipeline(ASTNode *root) {
    CS_MKDIR("outputs");

    /* Save symbol table */
    save_symbol_table_to_file("outputs/symbol_table.txt");
    printf("Symbol table  -> outputs/symbol_table.txt\n");

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

int main(int argc, char **argv) {
    printf("ChronoScript Compiler\n");
    printf("=====================\n\n");

    int         show_ast      = 0;
    int         skip_pipeline = 0;
    const char *input_file    = NULL;

    for (int i = 1; i < argc; i++) {
        if      (strcmp(argv[i], "--ast") == 0)         show_ast      = 1;
        else if (strcmp(argv[i], "--no-pipeline") == 0) skip_pipeline = 1;
        else                                            input_file    = argv[i];
    }

    if (input_file) {
        FILE *f = fopen(input_file, "r");
        if (!f) { fprintf(stderr, "Error: Cannot open '%s'\n", input_file); return 1; }
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

        if (!skip_pipeline) run_compiler_pipeline(ast_root);
        if (ast_root) execute_program(ast_root);
        free_ast(ast_root);
    } else {
        printf("\n===========================================\n");
        printf("Compilation failed with %d error(s)\n", error_count);
        printf("===========================================\n");
    }

    if (input_file) fclose(yyin);
    return (error_count == 0) ? 0 : 1;
}
