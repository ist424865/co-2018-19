%option stack 
%{
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "node.h"
#include "y.tab.h"

static int is_delimited = 0;
void yyerror(char *s);
int octal(char *s);

%}
%x X_COMMENT X_STRING
%%

"void"	                is_delimited = 0; return tVOID;
"integer"	            is_delimited = 0; return tINT_TYPE;
"string"	            is_delimited = 0; return tSTRING_TYPE;
"public"	            is_delimited = 0; return tPUBLIC;
"number"	            is_delimited = 0; return tREAL_TYPE;
"const"	                is_delimited = 0; return tCONST;
"if"	                is_delimited = 0; return tIF;
"then"	                is_delimited = 0; return tTHEN;
"else"	                is_delimited = 0; return tELSE;
"while"	                is_delimited = 0; return tWHILE;
"do"                    is_delimited = 0; return tDO;
"for"			        is_delimited = 0; return tFOR;
"in"	                is_delimited = 0; return tIN;
"step"	                is_delimited = 0; return tSTEP;
"upto"	                is_delimited = 0; return tUPTO;
"downto"	            is_delimited = 0; return tDOWNTO;
"break"	                is_delimited = 0; return tBREAK;
"continue"              is_delimited = 0; return tCONTINUE;

"<="			        is_delimited = 0; return tLE;
">="			        is_delimited = 0; return tGE;
"="|"<>"			    is_delimited = 0; return tEQ;
"!"			            is_delimited = 1; return tNE;
":="			        is_delimited = 0; return tASSIGN;
"++"			        is_delimited = 0; return tINC;
"--"			        is_delimited = 0; return tDEC;

"=<"                    yy_push_state(X_COMMENT);
<X_COMMENT>"=<"         yy_push_state(X_COMMENT);
<X_COMMENT>">="         yy_pop_state(); is_delimited = 0;
<X_COMMENT>.|\n         ;

"==".*$                 is_delimited = 0; /* Comentarios em linha */

[a-zA-Z][a-zA-Z0-9_]*   { is_delimited = 1; yylval.s = strdup(yytext); return tIDENTIFIER; }

0[0-9]+		            { is_delimited = 1; yylval.i = octal(yytext); return tINT; } 

"0b"[0-1]+              { is_delimited = 1; errno = 0; yylval.i = strtol(yytext, 0, 2);  if (errno == ERANGE) yyerror("Binary overflow."); return tINT; } 
"0b"[0-9]+              yyerror("Invalid base 2 number.");

0|[1-9][0-9]*		    { is_delimited = 1; errno = 0; yylval.i = strtol(yytext, 0, 10); if (errno == ERANGE) yyerror("Decimal overflow."); return tINT; } 

\"                              yy_push_state(X_STRING);
<X_STRING>\\\"                  strcat(yylval.s, yytext);
<X_STRING>\"                    is_delimited = 1; yy_pop_state(); return tSTRING;
<X_STRING>\\[0-9a-fA-F]{1,2}    strcat(yylval.s, (char*)strtol(yytext + 1, 0, 16));
<X_STRING>\0                    yyerror("NULL character at string literal.");
<X_STRING>.|\n                  strcat(yylval.s, yytext);

[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?      { is_delimited = 1; errno = 0; yylval.d = strtod(yytext, 0); if (errno == ERANGE) yyerror("Real overflow."); return tREAL; }

[-+*/%<>|&~]            is_delimited = 0; return *yytext; /* Operadores de expressoes */
[#{}(\[\];,]            is_delimited = 0; return *yytext; /* Delimitadores */
")"                     is_delimited = 1; return *yytext;

[\n]+                   if (is_delimited != 0) {is_delimited = 0; return ';'; }

[ \r\t]+		        ; /* Caracteres brancos */
.			            yyerror("Unknown character.");

%%

int yywrap(void) { return 1; }
char *getyytext() { return yytext; }

int octal(char *s) {
  int i, a = 0, b = 0;

  for (i = 0; i < strlen(s); i++) {
    if (s[i] < '0' || s[i] > '9') break;
    b = b * 8 + s[i] - '0';
    if (b < a) {
      yyerror("octal overflow");
      break;
    }
    a = b;
  }
}

