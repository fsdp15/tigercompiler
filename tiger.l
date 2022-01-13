%{
	#include <stdio.h>
	#include "st.h"
	#include "tiger.tab.h"
	int yylex();
%}

%option noyywrap
%option yylineno

%x COMMENT
	int nesting;
%%

"/*"	{BEGIN COMMENT; nesting = 1;}
<COMMENT>"/*"	{nesting++;}
<COMMENT>"*/"	{--nesting; if (nesting == 0) BEGIN INITIAL;}

[ \t\n]

[V|v][A|a][R|r]	{return VAR;}
[F|f][U|u][N|n][C|c][T|t][I|i][O|o][N|n]	{return FUNCTION;}
[I|i][F|f]	{return IF;}
[T|t][H|h][E|e][N|n]	{return THEN;}
[E|e][L|l][S|s][E|e]	{return ELSE;}
[W|w][H|h][I|i][L|l][E|e]	{return WHILE;}
[D|d][O|o]	{return DO;}
[L|l][E|e][T|t]	{return LET;}
[I|i][N|n]	{return IN;}
[E|e][N|n][D|d]	{return END;}

[0-9]+	{yylval.ival = atoi(yytext); return INT;}

":="	{return ATTRIBUTION;}
";"		{return SEMICOLON;}
","		{return COMMA;}
"("		{return LEFTP;}
")"		{return RIGHTP;}
"+"		{return PLUS;}
"-"		{return MINUS;}
"*"		{return TIMES;}
"/"		{return DIVISION;}
"="		{return EQUAL;}
"<>"	{return DIFFERENT;}
">"		{return GREATER;}
"<"		{return LESSER;}
">="	{return GREATEREQUAL;}
"<="	{return LESSEREQUAL;}
"&"		{return AND;}
"|"		{return OR;}

[a-zA-Z][a-zA-Z0-9_]*	{yylval.sval = malloc(strlen(yytext)); strncpy(yylval.sval, yytext, strlen(yytext)); return ID;}
.

%%