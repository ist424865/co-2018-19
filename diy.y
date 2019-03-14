%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "node.h"
#include "tabid.h"
extern int yylex();
void yyerror(char *s);
%}

%union {
	int i;			/* integer value */
	double d;		/* real value */
	char *s;		/* symbol name or string literal */
};

%token <i> tINT
%token <d> tREAL
%token <s> tSTRING
%token tVOID tINT_TYPE tSTRING_TYPE tPUBLIC tREAL_TYPE tCONST tIF tTHEN tELSE tWHILE tDO tFOR tIN tSTEP tUPTO tDOWNTO tDOWNTO tBREAK tCONTINUE 
%token tLE tGE tEQ tNE tASSIGN tINC tDEC 
%token tIDENTIFIER tINT tSTRING tREAL
%%
start:;
%%
int yyerror(char *s) { printf("%s\n",s); return 1; }
char *dupstr(const char*s) { return strdup(s); }
char **yynames =
#if YYDEBUG > 0
		 (char**)yyname;
#else
		 0;
#endif
int main(int argc, char *argv[]) {
	extern YYSTYPE yylval;
    int tk;
	while ((tk = yylex())) 
	    if (tk > YYERRCODE)
			printf("%d:\t%s\n", tk, yyname[tk]);
		else
		    printf("%d:\t%c\n", tk, tk);
    return 0;
}
