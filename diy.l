%option stack 
%{
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "node.h"
#include "y.tab.h"

static bool is_delimited = false;
void yyerror(char *s);

%}
%x X_COMMENT X_STRING
%%

"void"	                is_delimited = false; return tVOID;
"integer"	            is_delimited = false; return tINT_TYPE;
"string"	            is_delimited = false; return tSTRING_TYPE;
"public"	            is_delimited = false; return tPUBLIC;
"number"	            is_delimited = false; return tREAL_TYPE;
"const"	                is_delimited = false; return tCONST;
"if"	                is_delimited = false; return tIF;
"then"	                is_delimited = false; return tTHEN;
"else"	                is_delimited = false; return tELSE;
"while"	                is_delimited = false; return tWHILE;
"do"                    is_delimited = false; return tDO;
"for"			        is_delimited = false; return tFOR;
"in"	                is_delimited = false; return tIN;
"step"	                is_delimited = false; return tSTEP;
"upto"	                is_delimited = false; return tUPTO;
"downto"	            is_delimited = false; return tDOWNTO;
"break"	                is_delimited = false; return tBREAK;
"continue"              is_delimited = false; return tCONTINUE;

"<="			        is_delimited = false; return tLE;
">="			        is_delimited = false; return tGE;
"="|"<>"			    is_delimited = false; return tEQ;
"!"			            is_delimited = true; return tNE;
":="			        is_delimited = false; return tASSIGN;
"++"			        is_delimited = false; return tINC;
"--"			        is_delimited = false; return tDEC;

"=<"                    yy_push_state(X_COMMENT);
<X_COMMENT>"=<"         yy_push_state(X_COMMENT);
<X_COMMENT>">="         yy_pop_state(); is_delimited = false;
<X_COMMENT>.|\n         ;

"==".*$                 is_delimited = false; /* Comentarios em linha */

[a-zA-Z][a-zA-Z0-9_]*   { is_delimited = true; yylval.s = strdup(yytext); return tIDENTIFIER; }

0[0-9]+		            { is_delimited = true; yylval.i = octal(yytext); return tINT; } 

"0b"[0-1]+              { is_delimited = true; errno = 0; yylval.i = strtol(yytext, 0, 2);  if (errno == ERANGE) yyerror("Binary overflow."); return tINT; } 
"0b"[0-9]+              yyerror("Invalid base 2 number.");

0|[1-9][0-9]*		    { is_delimited = true; errno = 0; yylval.i = strtol(yytext, 0, 10); if (errno == ERANGE) yyerror("Decimal overflow."); return tINT; } 

\"                              yy_push_state(X_STRING);
<X_STRING>\\\"                  strcat(yylval.s, yytext);
<X_STRING>\"                    is_delimited = true; yy_pop_state(); return tSTRING;
<X_STRING>\\[0-9a-fA-F]{1,2}    strcat(yylval.s, (char*)strtol(yytext + 1, 0, 16));
<X_STRING>\0                    yyerror("NULL character at string literal.");
<X_STRING>.|\n                  strcat(yylval.s, yytext);

[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?      { is_delimited = true; errno = 0; yylval.d = strtod(yytext, 0); if (errno == ERANGE) yyerror("Real overflow."); return tREAL; }

[-+*/%<>|&~]            is_delimited = false; return *yytext; /* Operadores de expressoes */
[#{}(\[\];,]            is_delimited = false; return *yytext; /* Delimitadores */
")"                     is_delimited = true; return *yytext;

[\n]+                   if (is_delimited) {is_delimited = false; return ';'; }

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

