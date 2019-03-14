%option stack debug
%{
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "node.h"
#include "y.tab.h"

char *dupstr(const char *s);
int yyerror(char *s);

%}
%x X_COMMENT X_STRING
%%

"void"	                return tVOID;
"integer"	            return tINT_TYPE;
"string"	            return tSTRING_TYPE;
"public"	            return tPUBLIC;
"number"	            return tREAL_TYPE;
"const"	                return tCONST;
"if"	                return tIF;
"then"	                return tTHEN;
"else"	                return tELSE;
"while"	                return tWHILE;
"do"                    return tDO;
"for"			        return tFOR;
"in"	                return tIN;
"step"	                return tSTEP;
"upto"	                return tUPTO;
"downto"	            return tDOWNTO;
"break"	                return tBREAK;
"continue"              return tCONTINUE;

"<="			        return tLE;
">="			        return tGE;
"="|"<>"			    return tEQ;
"!"			            return tNE;
":="			        return tASSIGN;
"++"			        return tINC;
"--"			        return tDEC;

"=<"                    yy_push_state(X_COMMENT);
<X_COMMENT>"=<"         yy_push_state(X_COMMENT);
<X_COMMENT>">="         yy_pop_state();
<X_COMMENT>.|\n         ;

"==".*$                 ; /* Comentarios em linha */

[a-zA-Z][a-zA-Z0-9_]*   yylval.s = dupstr(yytext); return tIDENTIFIER; 

0[0-7]+		            { errno = 0; yylval.i = strtol(yytext, 0, 8);  if (errno == ERANGE) yyerror("Octal overflow."); return tINT; }
0[0-9]+                 yyerror("Invalid base 8 number.");

"0b"[0-1]+              { errno = 0; yylval.i = strtol(yytext, 0, 2);  if (errno == ERANGE) yyerror("Binary overflow."); return tINT; }
"0b"[0-9]+              yyerror("Invalid base 2 number.");

0|[1-9][0-9]*		    { errno = 0; yylval.i = strtol(yytext, 0, 10); if (errno == ERANGE) yyerror("Decimal overflow."); return tINT; } 

\"                              yy_push_state(X_STRING);
<X_STRING>\\\"                  strcat(yylval.s, yytext);
<X_STRING>\"                    yy_pop_state(); return tSTRING;
<X_STRING>\\[0-9a-fA-F]{1,2}    strcat(yylval.s, (char*)strtol(yytext + 1, 0, 16));
<X_STRING>\0                    yyerror("NULL character at string literal.");
<X_STRING>.|\n                  strcat(yylval.s, yytext);

[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?      { errno = 0; yylval.d = strtod(yytext, 0); if (errno == ERANGE) yyerror("Real overflow."); return tREAL; }

[-+*/%<>|&~]            return *yytext; /* Operadores de expressoes */
[#{}()\[\];,]           return *yytext; /* Delimitadores */

    /* FALTA DELIMITADOR DE LINHA */

[ \n\r\t]+		        ; /* Caracteres brancos */
.			            yyerror("Unknown character.");

%%

int yywrap(void) { return 1; }
char *getyytext() { return yytext; }
