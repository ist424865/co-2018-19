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
file	:
	;
%%
char **yynames =
#if YYDEBUG > 0
		 (char**)yyname;
#else
		 0;
#endif
