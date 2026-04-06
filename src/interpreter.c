#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "../include/interpreter.h"

/* ---- Type helpers ---- */

static int type_is_float(const char *t) {
    return t && (strcmp(t,"Energy")==0 || strcmp(t,"HighEnergy")==0 ||
                 strcmp(t,"fullEnergy")==0);
}
static int type_is_string(const char *t) { return t && strcmp(t,"Stream")==0; }
static int type_is_char(const char *t)   { return t && strcmp(t,"Atom")==0; }

/* ---- Value constructors ---- */

RuntimeValue runtime_make_void(void) {
    RuntimeValue v; memset(&v,0,sizeof(v)); v.type = RUNTIME_VOID; return v;
}
RuntimeValue runtime_make_int(int val) {
    RuntimeValue v; memset(&v,0,sizeof(v));
    v.type = RUNTIME_INT; v.intval = val; v.floatval = (double)val; return v;
}
RuntimeValue runtime_make_float(double val) {
    RuntimeValue v; memset(&v,0,sizeof(v));
    v.type = RUNTIME_FLOAT; v.floatval = val; v.intval = (int)val; return v;
}
RuntimeValue runtime_make_char(char ch) {
    RuntimeValue v; memset(&v,0,sizeof(v));
    v.type = RUNTIME_CHAR; v.charval = ch; v.intval = (int)(unsigned char)ch;
    v.floatval = (double)v.intval; return v;
}
RuntimeValue runtime_make_string(const char *s) {
    RuntimeValue v; memset(&v,0,sizeof(v));
    v.type = RUNTIME_STRING; v.strval = strdup(s ? s : ""); return v;
}

static void runtime_free_value(RuntimeValue *v) {
    if (!v) return;
    if (v->type == RUNTIME_STRING && v->strval) { free(v->strval); v->strval = NULL; }
    v->type = RUNTIME_VOID;
}

static RuntimeValue runtime_copy_value(RuntimeValue v) {
    if (v.type == RUNTIME_STRING) return runtime_make_string(v.strval);
    return v;
}

static int runtime_is_truthy(RuntimeValue v) {
    switch (v.type) {
        case RUNTIME_INT:    return v.intval != 0;
        case RUNTIME_FLOAT:  return v.floatval != 0.0;
        case RUNTIME_CHAR:   return v.charval != '\0';
        case RUNTIME_STRING: return v.strval && v.strval[0] != '\0';
        default:             return 0;
    }
}

static double runtime_as_double(RuntimeValue v) {
    switch (v.type) {
        case RUNTIME_FLOAT: return v.floatval;
        case RUNTIME_CHAR:  return (double)(unsigned char)v.charval;
        case RUNTIME_INT:   return (double)v.intval;
        default:            return 0.0;
    }
}

static int runtime_as_int(RuntimeValue v) {
    switch (v.type) {
        case RUNTIME_FLOAT: return (int)v.floatval;
        case RUNTIME_CHAR:  return (int)(unsigned char)v.charval;
        case RUNTIME_INT:   return v.intval;
        default:            return 0;
    }
}

/* ---- Variable management ---- */

static RuntimeVariable *runtime_find_variable(RuntimeContext *ctx, const char *name) {
    for (RuntimeVariable *v = ctx ? ctx->variables : NULL; v; v = v->next)
        if (strcmp(v->name, name) == 0) return v;
    return NULL;
}

static RuntimeVariable *runtime_declare_variable(RuntimeContext *ctx,
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

static RuntimeValue runtime_default_value_for_type(const char *t) {
    if (type_is_float(t))  return runtime_make_float(0.0);
    if (type_is_string(t)) return runtime_make_string("");
    if (type_is_char(t))   return runtime_make_char('\0');
    return runtime_make_int(0);
}

static void runtime_assign_variable(RuntimeContext *ctx, const char *name,
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

typedef struct RuntimeFunction {
    char                   *name;
    ASTNode                *func_decl;
    struct RuntimeFunction *next;
} RuntimeFunction;

static RuntimeFunction *function_table = NULL;

static void register_all_functions(ASTNode *root) {
    while (function_table) {
        RuntimeFunction *next = function_table->next;
        free(function_table->name); free(function_table);
        function_table = next;
    }
    if (!root || !root->child[0]) return;
    ASTNode *decl = root->child[0];
    while (decl) {
        ASTNode *cur = (decl->type == NODE_DECL_LIST) ? decl->child[0] : decl;
        if (cur && cur->type == NODE_FUNC_DECL && cur->value) {
            RuntimeFunction *rf = (RuntimeFunction *)malloc(sizeof(RuntimeFunction));
            rf->name      = strdup(cur->value);
            rf->func_decl = cur;
            rf->next      = function_table;
            function_table = rf;
        }
        decl = decl->sibling;
    }
}

static RuntimeFunction *lookup_rt_function(const char *name) {
    for (RuntimeFunction *f = function_table; f; f = f->next)
        if (strcmp(f->name, name) == 0) return f;
    return NULL;
}

/* ---- Forward declarations ---- */

static RuntimeValue runtime_eval_expression(ASTNode *node, RuntimeContext *ctx);
static void runtime_execute_statement(ASTNode *node, RuntimeContext *ctx);
static void runtime_execute_statement_list(ASTNode *node, RuntimeContext *ctx);
static void runtime_execute_declaration_list(ASTNode *node, RuntimeContext *ctx);
static void runtime_execute_compound(ASTNode *node, RuntimeContext *ctx);

/* ---- Expression evaluator ---- */

static RuntimeValue runtime_eval_expression(ASTNode *node, RuntimeContext *ctx) {
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
        if      (strcmp(node->op, "-") == 0)
            r = (op.type == RUNTIME_FLOAT)
                ? runtime_make_float(-runtime_as_double(op))
                : runtime_make_int(-runtime_as_int(op));
        else if (strcmp(node->op, "+") == 0)
            r = runtime_copy_value(op);
        else if (strcmp(node->op, "!") == 0)
            r = runtime_make_int(!runtime_is_truthy(op));
        else if (strcmp(node->op, "~") == 0)
            r = runtime_make_int(~runtime_as_int(op));
        runtime_free_value(&op);
        return r;
    }

    case NODE_BINARY_EXPR: {
        const char *op = node->op;

        /* Simple assignment */
        if (strcmp(op, "=") == 0 && node->child[0]) {
            if (node->child[0]->type == NODE_IDENTIFIER) {
                RuntimeValue rhs = runtime_eval_expression(node->child[1], ctx);
                runtime_assign_variable(ctx, node->child[0]->value, rhs);
                RuntimeValue res = runtime_copy_value(rhs);
                runtime_free_value(&rhs);
                return res;
            }
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
            return runtime_eval_expression(node->child[1], ctx);
        }

        /* Compound assignments */
        if ((strcmp(op,"+=")==0||strcmp(op,"-=")==0||
             strcmp(op,"*=")==0||strcmp(op,"/=")==0||strcmp(op,"%=")==0) &&
            node->child[0] && node->child[0]->type == NODE_IDENTIFIER)
        {
            RuntimeValue cur = runtime_eval_expression(node->child[0], ctx);
            RuntimeValue rhs = runtime_eval_expression(node->child[1], ctx);
            double cd = runtime_as_double(cur), rd = runtime_as_double(rhs);
            int ci = runtime_as_int(cur), ri = runtime_as_int(rhs);
            int fm = (cur.type == RUNTIME_FLOAT || rhs.type == RUNTIME_FLOAT);
            RuntimeValue res;
            if      (strcmp(op,"+=")==0) res = fm ? runtime_make_float(cd+rd) : runtime_make_int(ci+ri);
            else if (strcmp(op,"-=")==0) res = fm ? runtime_make_float(cd-rd) : runtime_make_int(ci-ri);
            else if (strcmp(op,"*=")==0) res = fm ? runtime_make_float(cd*rd) : runtime_make_int(ci*ri);
            else if (strcmp(op,"/=")==0) res = (ri==0) ? runtime_make_int(0) : (fm ? runtime_make_float(cd/rd) : runtime_make_int(ci/ri));
            else                        res = (ri==0) ? runtime_make_int(0) : runtime_make_int(ci%ri);
            runtime_assign_variable(ctx, node->child[0]->value, res);
            RuntimeValue ret = runtime_copy_value(res);
            runtime_free_value(&cur); runtime_free_value(&rhs); runtime_free_value(&res);
            return ret;
        }

        /* Arithmetic / relational / logical / bitwise */
        RuntimeValue lv = runtime_eval_expression(node->child[0], ctx);
        RuntimeValue rv = runtime_eval_expression(node->child[1], ctx);
        RuntimeValue r  = runtime_make_void();
        int fm = (lv.type == RUNTIME_FLOAT || rv.type == RUNTIME_FLOAT);

        if      (strcmp(op,"+")==0) r = fm ? runtime_make_float(runtime_as_double(lv)+runtime_as_double(rv)) : runtime_make_int(runtime_as_int(lv)+runtime_as_int(rv));
        else if (strcmp(op,"-")==0) r = fm ? runtime_make_float(runtime_as_double(lv)-runtime_as_double(rv)) : runtime_make_int(runtime_as_int(lv)-runtime_as_int(rv));
        else if (strcmp(op,"*")==0) r = fm ? runtime_make_float(runtime_as_double(lv)*runtime_as_double(rv)) : runtime_make_int(runtime_as_int(lv)*runtime_as_int(rv));
        else if (strcmp(op,"/")==0) {
            double d = runtime_as_double(rv);
            r = (d==0.0) ? runtime_make_int(0) : (fm ? runtime_make_float(runtime_as_double(lv)/d) : runtime_make_int(runtime_as_int(lv)/runtime_as_int(rv)));
        }
        else if (strcmp(op,"%")==0) { int d = runtime_as_int(rv); r = d ? runtime_make_int(runtime_as_int(lv)%d) : runtime_make_int(0); }
        else if (strcmp(op,"<" )==0) r = runtime_make_int(runtime_as_double(lv) < runtime_as_double(rv));
        else if (strcmp(op,">" )==0) r = runtime_make_int(runtime_as_double(lv) > runtime_as_double(rv));
        else if (strcmp(op,"<=")==0) r = runtime_make_int(runtime_as_double(lv) <= runtime_as_double(rv));
        else if (strcmp(op,">=")==0) r = runtime_make_int(runtime_as_double(lv) >= runtime_as_double(rv));
        else if (strcmp(op,"==")==0) {
            if (lv.type == RUNTIME_STRING && rv.type == RUNTIME_STRING)
                r = runtime_make_int(lv.strval && rv.strval && strcmp(lv.strval, rv.strval)==0);
            else
                r = runtime_make_int(runtime_as_double(lv) == runtime_as_double(rv));
        }
        else if (strcmp(op,"!=")==0) {
            if (lv.type == RUNTIME_STRING && rv.type == RUNTIME_STRING)
                r = runtime_make_int(!(lv.strval && rv.strval && strcmp(lv.strval, rv.strval)==0));
            else
                r = runtime_make_int(runtime_as_double(lv) != runtime_as_double(rv));
        }
        else if (strcmp(op,"&&")==0) r = runtime_make_int(runtime_is_truthy(lv) && runtime_is_truthy(rv));
        else if (strcmp(op,"||")==0) r = runtime_make_int(runtime_is_truthy(lv) || runtime_is_truthy(rv));
        else if (strcmp(op,"&" )==0) r = runtime_make_int(runtime_as_int(lv) & runtime_as_int(rv));
        else if (strcmp(op,"|" )==0) r = runtime_make_int(runtime_as_int(lv) | runtime_as_int(rv));
        else if (strcmp(op,"^" )==0) r = runtime_make_int(runtime_as_int(lv) ^ runtime_as_int(rv));
        else if (strcmp(op,"<<")==0) r = runtime_make_int(runtime_as_int(lv) << runtime_as_int(rv));
        else if (strcmp(op,">>")==0) r = runtime_make_int(runtime_as_int(lv) >> runtime_as_int(rv));

        runtime_free_value(&lv); runtime_free_value(&rv);
        return r;
    }

    case NODE_CALL_EXPR: {
        if (!node->child[0]) return runtime_make_void();
        const char *fname = node->child[0]->value;
        if (!fname) return runtime_make_void();

        /* Built-in single-arg math functions */
        struct { const char *name; double (*fn)(double); } math1[] = {
            {"sine", sin}, {"cosine", cos}, {"tangent", tan},
            {"invSine", asin}, {"invCosine", acos}, {"invTangent", atan},
            {"floor", floor}, {"ceiling", ceil},
            {NULL, NULL}
        };
        for (int i = 0; math1[i].name; i++) {
            if (strcmp(fname, math1[i].name) == 0) {
                RuntimeValue a = runtime_eval_expression(node->child[1], ctx);
                RuntimeValue r = runtime_make_float(math1[i].fn(runtime_as_double(a)));
                runtime_free_value(&a); return r;
            }
        }

        if (strcmp(fname,"squareroot")==0) {
            RuntimeValue a = runtime_eval_expression(node->child[1], ctx);
            double av = runtime_as_double(a);
            RuntimeValue r = runtime_make_float(av >= 0.0 ? sqrt(av) : 0.0);
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"absolute")==0) {
            RuntimeValue a = runtime_eval_expression(node->child[1], ctx);
            RuntimeValue r = (a.type == RUNTIME_FLOAT)
                ? runtime_make_float(fabs(runtime_as_double(a)))
                : runtime_make_int(abs(runtime_as_int(a)));
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"logarithm")==0) {
            RuntimeValue a = runtime_eval_expression(node->child[1], ctx);
            double av = runtime_as_double(a);
            RuntimeValue r = runtime_make_float(av > 0.0 ? log(av) : 0.0);
            runtime_free_value(&a); return r;
        }
        if (strcmp(fname,"power")==0) {
            RuntimeValue base = runtime_eval_expression(node->child[1], ctx);
            RuntimeValue exp = (node->child[1] && node->child[1]->sibling)
                ? runtime_eval_expression(node->child[1]->sibling, ctx)
                : runtime_make_int(1);
            RuntimeValue r = runtime_make_float(pow(runtime_as_double(base), runtime_as_double(exp)));
            runtime_free_value(&base); runtime_free_value(&exp); return r;
        }
        if (strcmp(fname,"SingularityCheck")==0) {
            RuntimeValue a = runtime_eval_expression(node->child[1], ctx);
            int n = runtime_as_int(a); runtime_free_value(&a);
            if (n < 2) return runtime_make_int(0);
            if (n == 2) return runtime_make_int(1);
            if (n % 2 == 0) return runtime_make_int(0);
            for (int d = 3; (long long)d*d <= n; d += 2)
                if (n % d == 0) return runtime_make_int(0);
            return runtime_make_int(1);
        }
        if (strcmp(fname,"MassAccumulation")==0) {
            RuntimeValue a = runtime_eval_expression(node->child[1], ctx);
            long long n = runtime_as_int(a); runtime_free_value(&a);
            long long f = 1;
            for (long long i = 2; i <= n; i++) f *= i;
            return runtime_make_int((int)f);
        }

        /* User-defined function call */
        RuntimeFunction *rf = lookup_rt_function(fname);
        if (rf) {
            RuntimeContext child_ctx = {NULL, 0, 0, 0, runtime_make_void()};
            ASTNode *pn = rf->func_decl->child[1];
            ASTNode *an = node->child[1];
            while (pn && an) {
                ASTNode *param = (pn->type == NODE_PARAM_LIST) ? pn->child[0] : pn;
                if (param && param->value) {
                    RuntimeValue av = runtime_eval_expression(an, ctx);
                    runtime_declare_variable(&child_ctx, param->value, param->data_type);
                    runtime_assign_variable(&child_ctx, param->value, av);
                    runtime_free_value(&av);
                }
                pn = pn->sibling; an = an->sibling;
            }
            runtime_execute_compound(rf->func_decl->child[2], &child_ctx);
            RuntimeValue result = runtime_copy_value(child_ctx.return_value);
            /* Cleanup child context */
            RuntimeVariable *v = child_ctx.variables;
            while (v) { RuntimeVariable *next = v->next; free(v->name); free(v->declared_type); runtime_free_value(&v->value); free(v); v = next; }
            runtime_free_value(&child_ctx.return_value);
            return result;
        }
        return runtime_make_void();
    }

    default: return runtime_make_void();
    }
}

/* ---- Print / Input helpers ---- */

static void runtime_print_value(RuntimeValue v) {
    switch (v.type) {
        case RUNTIME_FLOAT:  printf("%g\n",  v.floatval); break;
        case RUNTIME_STRING: printf("%s\n",  v.strval ? v.strval : ""); break;
        case RUNTIME_CHAR:   printf("%c\n",  v.charval); break;
        case RUNTIME_INT:    printf("%d\n",  v.intval); break;
        default:             printf("\n"); break;
    }
}

static void runtime_read_into_identifier(ASTNode *node, RuntimeContext *ctx) {
    if (!node || node->type != NODE_IDENTIFIER) return;
    RuntimeVariable *v = runtime_find_variable(ctx, node->value);
    if (!v) {
        v = runtime_declare_variable(ctx, node->value, "Matter");
        runtime_assign_variable(ctx, v->name, runtime_make_int(0));
    }
    char buf[512];
    printf("Enter %s: ", v->name); fflush(stdout);
    if (!fgets(buf, sizeof(buf), stdin)) return;
    buf[strcspn(buf, "\r\n")] = '\0';

    RuntimeValue val;
    if (type_is_float(v->declared_type))       val = runtime_make_float(strtod(buf, NULL));
    else if (type_is_string(v->declared_type)) val = runtime_make_string(buf);
    else if (type_is_char(v->declared_type))   val = runtime_make_char(buf[0] ? buf[0] : '\0');
    else                                       val = runtime_make_int((int)strtol(buf, NULL, 10));
    runtime_assign_variable(ctx, v->name, val);
    runtime_free_value(&val);
}

/* ---- Statement executor ---- */

static void runtime_execute_statement(ASTNode *node, RuntimeContext *ctx) {
    if (!node || ctx->has_return || ctx->has_break || ctx->has_continue) return;

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
        if (runtime_is_truthy(cond)) runtime_execute_statement(node->child[1], ctx);
        else if (node->child[2])     runtime_execute_statement(node->child[2], ctx);
        runtime_free_value(&cond);
        break;
    }

    case NODE_WHILE_STMT:
        while (!ctx->has_return && !ctx->has_break) {
            RuntimeValue cond = runtime_eval_expression(node->child[0], ctx);
            int t = runtime_is_truthy(cond); runtime_free_value(&cond);
            if (!t) break;
            runtime_execute_statement(node->child[1], ctx);
            if (ctx->has_continue) ctx->has_continue = 0;
        }
        ctx->has_break = 0;
        break;

    case NODE_FOR_STMT: {
        if (node->child[0]) {
            if (node->child[0]->type == NODE_VAR_DECL || node->child[0]->type == NODE_ARRAY_DECL)
                runtime_execute_declaration_list(node->child[0], ctx);
            else
                runtime_execute_statement(node->child[0], ctx);
        }
        while (!ctx->has_return && !ctx->has_break) {
            if (node->child[1] && node->child[1]->child[0]) {
                RuntimeValue cond = runtime_eval_expression(node->child[1]->child[0], ctx);
                int t = runtime_is_truthy(cond); runtime_free_value(&cond);
                if (!t) break;
            }
            runtime_execute_statement(node->child[3], ctx);
            if (ctx->has_break) break;
            if (ctx->has_continue) ctx->has_continue = 0;
            if (node->child[2]) {
                RuntimeValue inc = runtime_eval_expression(node->child[2], ctx);
                runtime_free_value(&inc);
            }
        }
        ctx->has_break = 0;
        break;
    }

    case NODE_RETURN_STMT:
        ctx->has_return   = 1;
        ctx->return_value = node->child[0]
            ? runtime_eval_expression(node->child[0], ctx) : runtime_make_void();
        break;

    case NODE_BREAK_STMT:    ctx->has_break = 1; break;
    case NODE_CONTINUE_STMT: ctx->has_continue = 1; break;

    case NODE_VAR_DECL: {
        RuntimeVariable *v = runtime_declare_variable(ctx, node->value, node->data_type);
        RuntimeValue init = node->child[1]
            ? runtime_eval_expression(node->child[1], ctx)
            : runtime_default_value_for_type(node->data_type);
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
            ASTNode *init = node->child[1]; int ai = 0;
            while (init) {
                ASTNode *val = (init->type == NODE_STMT_LIST || init->type == NODE_DECL_LIST) ? init->child[0] : init;
                if (val) {
                    char ename[512];
                    snprintf(ename, sizeof(ename), "%s__%d", node->value, ai);
                    RuntimeValue iv = runtime_eval_expression(val, ctx);
                    runtime_assign_variable(ctx, ename, iv);
                    runtime_free_value(&iv);
                }
                ai++; init = init->sibling;
            }
        }
        break;
    }

    case NODE_SWITCH_STMT: {
        if (!node->child[0]) break;
        RuntimeValue sw = runtime_eval_expression(node->child[0], ctx);
        int matched = 0;
        ASTNode *cl = node->child[1], *def_clause = NULL;
        while (cl && !ctx->has_return && !ctx->has_break) {
            if (cl->data_type && strcmp(cl->data_type, "default") == 0) {
                def_clause = cl; cl = cl->sibling; continue;
            }
            if (cl->child[1]) {
                RuntimeValue cv = runtime_eval_expression(cl->child[1], ctx);
                int eq = (sw.type == RUNTIME_FLOAT || cv.type == RUNTIME_FLOAT)
                    ? (runtime_as_double(sw) == runtime_as_double(cv))
                    : (runtime_as_int(sw) == runtime_as_int(cv));
                runtime_free_value(&cv);
                if (eq) {
                    matched = 1;
                    runtime_execute_statement_list(cl->child[0], ctx);
                    if (ctx->has_break) { ctx->has_break = 0; break; }
                }
            }
            cl = cl->sibling;
        }
        if (!matched && def_clause && !ctx->has_return && !ctx->has_break)
            runtime_execute_statement_list(def_clause->child[0], ctx);
        runtime_free_value(&sw);
        ctx->has_break = 0;
        break;
    }

    default: break;
    }
}

static void runtime_execute_declaration_list(ASTNode *node, RuntimeContext *ctx) {
    ASTNode *decl = node;
    while (decl) {
        ASTNode *cur = (decl->type == NODE_DECL_LIST) ? decl->child[0] : decl;
        if (cur) runtime_execute_statement(cur, ctx);
        decl = decl->sibling;
    }
}

static void runtime_execute_statement_list(ASTNode *node, RuntimeContext *ctx) {
    ASTNode *stmt = node;
    while (stmt && !ctx->has_return && !ctx->has_break && !ctx->has_continue) {
        ASTNode *cur = (stmt->type == NODE_STMT_LIST) ? stmt->child[0] : stmt;
        runtime_execute_statement(cur, ctx);
        stmt = stmt->sibling;
    }
}

static void runtime_execute_compound(ASTNode *node, RuntimeContext *ctx) {
    if (node && node->child[0])
        runtime_execute_statement_list(node->child[0], ctx);
}

/* ---- Public entry point ---- */

int execute_program(ASTNode *root) {
    register_all_functions(root);
    /* Find main() */
    ASTNode *main_fn = NULL;
    if (root && root->child[0]) {
        ASTNode *decl = root->child[0];
        while (decl) {
            ASTNode *cur = (decl->type == NODE_DECL_LIST) ? decl->child[0] : decl;
            if (cur && cur->type == NODE_FUNC_DECL && cur->value && strcmp(cur->value, "main") == 0) {
                main_fn = cur; break;
            }
            decl = decl->sibling;
        }
    }
    if (!main_fn) {
        fprintf(stderr, "Runtime error: Event main() not found\n");
        return 1;
    }
    RuntimeContext ctx = {NULL, 0, 0, 0, runtime_make_void()};
    printf("=== Program Output ===\n");
    runtime_execute_compound(main_fn->child[2], &ctx);
    int exit_code = (ctx.has_return && ctx.return_value.type == RUNTIME_INT)
                    ? ctx.return_value.intval : 0;
    /* Cleanup */
    RuntimeVariable *v = ctx.variables;
    while (v) { RuntimeVariable *next = v->next; free(v->name); free(v->declared_type); runtime_free_value(&v->value); free(v); v = next; }
    runtime_free_value(&ctx.return_value);
    return exit_code;
}
