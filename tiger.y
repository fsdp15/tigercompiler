%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "st.h"

	int yylex();
	int yyparse();
	extern int yylineno;  

	void yyerror(const char *s);
%}

%union {
	int ival;
	char *sval;
	tree *a_tree;
}

%define parse.error verbose

%token <ival> INT
%token <sval> ID
%token <sval> VAR FUNCTION IF THEN ELSE WHILE DO LET IN END
%token <sval> LEFTP RIGHTP SEMICOLON COMMA ATTRIBUTION
%left <sval> TIMES DIVISION
%left <sval> PLUS MINUS
%nonassoc <sval> EQUAL DIFFERENT GREATER LESSER GREATEREQUAL LESSEREQUAL
%left <sval> AND
%left <sval> OR

%type <sval> infixOp
%type <a_tree> letExp whileExp ifThen ifThenElse assignment infixExp callExp
%type <a_tree> seqExp expC expLoopC expSemiC expLoop exp lValue varDec funDec fieldDecComma dec fieldDec decPlus

%%
program:
	exp 	{printtree($1, 0);}
;

decPlus:
	dec decPlus {$$ = make_operator($1, "decPlus", $2);}
	| dec {$$ = $1;}
;

dec:
	varDec {$$ = $1;}
	| funDec {$$ = $1;}
;

fieldDec:
	ID fieldDecComma {if (!$2) {
						$$ = make_id($1);
					   } 
					   else {
					    $$ = make_operator(make_id($1), ",", $2);
					  }}
	| %empty {$$ = 0;}
; 

fieldDecComma:
	COMMA ID fieldDecComma {if (!$3) {
							$$ = make_id($2);
							} 
							else {
							$$ = make_operator(make_id($2), ",", $3);
							}}
	| %empty {$$ = 0;}
;

funDec:
	FUNCTION ID LEFTP fieldDec RIGHTP EQUAL exp {if (!$4) {
													tree **nodes = malloc(sizeof(tree*) * 5);
													tree *nodeAux = malloc(sizeof(tree));
													nodes[0] = make_word("FUNCTION");
													nodes[1] = make_id($2);
													nodes[2] = make_terminal($3);
													nodes[3] = make_terminal($5);
													nodes[4] = make_terminal($6);
													nodeAux = make_multiple_operator(nodes, "funDec", 5);
													$$ = make_operator(nodeAux, "=", $7);
													}
												else {
													tree **nodes = malloc(sizeof(tree*) * 6);
													tree *nodeAux = malloc(sizeof(tree));
													nodes[0] = make_word("FUNCTION");
													nodes[1] = make_id($2);
													nodes[2] = make_terminal($3);
													nodes[3] = $4;
													nodes[4] = make_terminal($5);
													nodes[5] = make_terminal($6);
													nodeAux = make_multiple_operator(nodes, "funDec", 6);	
													$$ = make_operator(nodeAux, "=", $7);										
													}
												}
;

varDec:
	VAR ID ATTRIBUTION exp {
							tree **nodes = malloc(sizeof(tree*) * 2);
							tree *nodeAux = malloc(sizeof(tree));
							nodes[0] = make_word("VAR");
							nodes[1] = make_id($2);
							nodeAux = make_multiple_operator(nodes, "varDec", 2);	
							$$ = make_operator(nodeAux, ":=", $4);
							}
;

lValue:
	ID {$$ = make_id($1);}
;

exp:
	lValue {$$ = $1;}
	| INT {$$ = make_number($1);}
	| seqExp {$$ = $1;}
	| callExp {$$ = $1;}
	| infixExp {$$ = $1;}
	| assignment {$$ = $1;}
	| ifThenElse {$$ = $1;}
	| ifThen {$$ = $1;}
	| whileExp {$$ = $1;}
	| letExp {$$ = $1;}
;

expLoop:
	exp expSemiC {if (!$2) {
						$$ =  $1;
					   } 
					   else {
					    $$ = make_operator($1, ";", $2);
					  }}
	| %empty {$$ = 0;}
;

expSemiC:
	SEMICOLON exp expSemiC {if (!$3) {
							$$ = $2;
							} 
							else {
							$$ = make_operator($2, ";", $3);
							}}
	| %empty {$$ = 0;}
;

expLoopC:
	exp expC {if (!$2) {
						$$ =  $1;
					   } 
					   else {
					    $$ = make_operator($1, ",", $2);
					  }}
	| %empty {$$ = 0;}
;

expC:
	COMMA exp expC {if (!$3) {
							$$ = $2;
							} 
							else {
							$$ = make_operator($2, ",", $3);
							}}
	| %empty {$$ = 0;}
;

seqExp:
	LEFTP expLoop RIGHTP {
							tree **nodes = malloc(sizeof(tree*) * 3);
							nodes[0] = make_terminal($1);
							nodes[1] = $2;
							nodes[2] = make_terminal($3);
							$$ = make_multiple_operator(nodes, "seqExp", 3);	
							}
;

callExp:
	ID LEFTP expLoopC RIGHTP {
							tree **nodes = malloc(sizeof(tree*) * 4);
							nodes[0] = make_id($1);
							nodes[1] = make_terminal($2);
							nodes[2] = $3;
							nodes[3] = make_terminal($4);
							$$ = make_multiple_operator(nodes, "callExp", 4);	
							}
;

infixExp:
	exp infixOp exp {
							$$ = make_operator($1, $2, $3);	
							}
;

assignment:
	lValue ATTRIBUTION exp {
							$$ = make_operator($1, ":=", $3);		
							}
;

ifThenElse:
	IF exp THEN exp ELSE exp {
							tree **nodes = malloc(sizeof(tree*) * 6);
							nodes[0] = make_word("IF");
							nodes[1] = $2;
							nodes[2] = make_word("THEN");
							nodes[3] = $4;
							nodes[4] = make_word("ELSE");
							nodes[5] = $6;
							$$ = make_multiple_operator(nodes, "ifThenElse", 6);	
							}
;

ifThen:
	IF exp THEN exp {
							tree **nodes = malloc(sizeof(tree*) * 4);
							nodes[0] = make_word("IF");
							nodes[1] = $2;
							nodes[2] = make_word("THEN");
							nodes[3] = $4;
							$$ = make_multiple_operator(nodes, "ifThen", 4);	
							}
;

whileExp:
	WHILE exp DO exp {
							tree **nodes = malloc(sizeof(tree*) * 4);
							nodes[0] = make_word("WHILE");
							nodes[1] = $2;
							nodes[2] = make_word("DO");
							nodes[3] = $4;
							$$ = make_multiple_operator(nodes, "whileExp", 4);	
							}
;


letExp:
	LET decPlus IN expLoop END {
							tree **nodes = malloc(sizeof(tree*) * 5);
							//tree *nodeAux = malloc(sizeof(tree));
							nodes[0] = make_word("LET");
							nodes[1] = $2;
							nodes[2] = make_word("IN");
							nodes[3] = $4;
							nodes[4] = make_word("END");
							$$ = make_multiple_operator(nodes, "letExp", 5);	
						//	$$ = make_operator(nodeAux, "letExp", $3);
							}
;

infixOp:
	PLUS {$$ = "+";}
	| MINUS {$$ = "-";}
	| TIMES {$$ = "*";}
	| DIVISION {$$ = "/";}
	| EQUAL {$$ = "=";}
	| DIFFERENT {$$ = "<>";}
	| GREATER {$$ = ">";}
	| LESSER {$$ = "<";}
	| GREATEREQUAL {$$ = ">=";}
	| LESSEREQUAL {$$ = "<=";}
	| AND {$$ = "&";}
	| OR {$$ = "|";}
;

%%

int main() {
	yyparse();
}

void yyerror(const char *s) {
   fprintf (stderr, "Error around line: %d\n%s\n", yylineno, s);
 }
