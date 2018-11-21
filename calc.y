%{

#include <stdio.h>
#include <stdlib.h>

// stuff from flex that bison needs to know about:
extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int line_num;
extern float memory;

void yyerror(const char* s);
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	int ival;
	float fval;
    char *sval;
}

// Define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token<ival> T_INT
%token<fval> T_FLOAT
%token<sval> F_STRING
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT 
%token T_NEWLINE T_QUIT T_COMMENT T_POL T_FILE T_SAVE T_LOAD
%left T_PLUS T_MINUS T_LOAD
%left T_MULTIPLY T_DIVIDE

%type<ival> expression
%type<fval> mixed_expression
%type<ival> pol_expression
%type<fval> mixed_pol_expression

%start calculation

%%
// This is the actual grammar that bison will parse
calculation:
	   | calculation line
;

line: T_NEWLINE
    | mixed_expression T_NEWLINE { printf("\tResult: %f\n", $1);}
    | expression T_NEWLINE { printf("\tResult: %i\n", $1); }
    | T_POL pol_expression T_NEWLINE { printf("\tResult: %i\n", $2); }
    | T_POL mixed_pol_expression T_NEWLINE { printf("\tResult: %f\n", $2); }
    | T_SAVE mixed_expression T_NEWLINE {
                                            //reset memory
                                            memory = 0;
                                            memory = $2;
                                        }
    | T_SAVE expression T_NEWLINE {
                                            //reset memory
                                            memory = 0;
                                            memory = $2;
                                        }
    | T_SAVE T_POL pol_expression T_NEWLINE {
                                            //reset memory
                                            memory = 0;
                                            memory = $3;
                                        }
    | T_SAVE T_POL mixed_pol_expression T_NEWLINE {
                                            //reset memory
                                            memory = 0;
                                            memory = $3;
                                        }
    | T_LOAD T_NEWLINE                  { printf("\tResult: %f\n", memory);}
    | T_FILE F_STRING T_NEWLINE {   
                                    //reset line_num 
                                    line_num = 0;
                                    // open a file handle to a particular file:
                                    FILE *myfile = fopen($2, "r");
                                    // make sure it's valid:
                                    if (!myfile) {
                                        printf("\tCould not open file! \n");
                                        return -1;
                                    }
                                    // set lex to read from it instead of defaulting to STDIN:
                                    yyin = myfile;
                                    }
    | T_QUIT T_NEWLINE { printf("bye!\n"); exit(0); }
;

mixed_expression: T_FLOAT                 		 { $$ = $1; }
	  | mixed_expression T_PLUS mixed_expression	 { $$ = $1 + $3; }
      | mixed_expression T_PLUS T_LOAD	             { $$ = $1 + memory; }
      | T_LOAD T_PLUS mixed_expression	             { $$ = memory + $3; }
	  | mixed_expression T_MINUS mixed_expression	 { $$ = $1 - $3; }
      | mixed_expression T_MINUS T_LOAD	             { $$ = $1 - memory; }
      | T_LOAD T_MINUS mixed_expression	             { $$ = memory - $3; }
	  | mixed_expression T_MULTIPLY mixed_expression { $$ = $1 * $3; }
      | mixed_expression T_MULTIPLY T_LOAD	             { $$ = $1 * memory; }
      | T_LOAD T_MULTIPLY mixed_expression	             { $$ = memory * $3; }
	  | mixed_expression T_DIVIDE mixed_expression	 { $$ = $1 / $3; }
      | mixed_expression T_DIVIDE T_LOAD	             { $$ = $1 / memory; }
      | T_LOAD T_DIVIDE mixed_expression	             { $$ = memory / $3; }
	  | T_LEFT mixed_expression T_RIGHT		 { $$ = $2; }
	  | expression T_PLUS mixed_expression	 	 { $$ = $1 + $3; }
      | expression T_PLUS T_LOAD	 	        { $$ = $1 + memory; }
	  | expression T_MINUS mixed_expression	 	 { $$ = $1 - $3; }
      | expression T_MINUS T_LOAD	 	        { $$ = $1 - memory; }
	  | expression T_MULTIPLY mixed_expression 	 { $$ = $1 * $3; }
      | expression T_MULTIPLY T_LOAD	 	    { $$ = $1 * memory; }
	  | expression T_DIVIDE mixed_expression	 { $$ = $1 / $3; }
      | expression T_DIVIDE T_LOAD 	            { $$ = $1 / memory; }
	  | mixed_expression T_PLUS expression	 	 { $$ = $1 + $3; }
      | T_LOAD T_PLUS expression	 	        { $$ = memory + $3; }
	  | mixed_expression T_MINUS expression	 	 { $$ = $1 - $3; }
      | T_LOAD T_MINUS expression	 	        { $$ = memory - $3; }
	  | mixed_expression T_MULTIPLY expression 	 { $$ = $1 * $3; }
      | T_LOAD T_MULTIPLY expression 	        { $$ = memory * $3; }
	  | mixed_expression T_DIVIDE expression	 { $$ = $1 / $3; }
      | T_LOAD T_DIVIDE expression	            { $$ = memory / $3; }
	  | expression T_DIVIDE expression		 { $$ = $1 / (float)$3; }
;

expression: T_INT				{ $$ = $1; }
	  | expression T_PLUS expression	{ $$ = $1 + $3; }
	  | expression T_MINUS expression	{ $$ = $1 - $3; }
	  | expression T_MULTIPLY expression	{ $$ = $1 * $3; }
	  | T_LEFT expression T_RIGHT		{ $$ = $2; }
;

pol_expression: T_INT				{ $$ = $1; }
    | T_PLUS pol_expression pol_expression	    { $$ = $2 + $3; }
	| T_MINUS pol_expression pol_expression	    { $$ = $2 - $3; }
    | T_MULTIPLY pol_expression pol_expression	{ $$ = $2 * $3; }
;

mixed_pol_expression: T_FLOAT                 		 { $$ = $1; }
	  | T_PLUS mixed_pol_expression mixed_pol_expression	 { $$ = $2 + $3; }
      | T_PLUS mixed_pol_expression T_LOAD	             { $$ = $2 + memory; }
      | T_PLUS T_LOAD mixed_pol_expression	             { $$ = memory + $3; }
	  | T_MINUS mixed_pol_expression mixed_pol_expression	 { $$ = $2 - $3; }
      | T_MINUS mixed_pol_expression T_LOAD	             { $$ = $2 - memory; }
      | T_MINUS T_LOAD mixed_pol_expression	             { $$ = memory - $3; }
	  | T_MULTIPLY mixed_pol_expression mixed_pol_expression { $$ = $2 * $3; }
      | T_MULTIPLY mixed_pol_expression T_LOAD	             { $$ = $2 * memory; }
      | T_MULTIPLY T_LOAD mixed_pol_expression	             { $$ = memory * $3; }
	  | T_DIVIDE mixed_pol_expression mixed_pol_expression	 { $$ = $2 / $3; }
      | T_DIVIDE mixed_pol_expression T_LOAD	             { $$ = $2 / memory; }
      | T_DIVIDE T_LOAD mixed_pol_expression	             { $$ = memory / $3; }
	  | T_PLUS  pol_expression mixed_pol_expression	 	 { $$ = $2 + $3; }
      | T_PLUS pol_expression T_LOAD	 	        { $$ = $2 + memory; }
	  | T_MINUS pol_expression mixed_pol_expression	 	 { $$ = $2 - $3; }
      | T_MINUS pol_expression T_LOAD	 	        { $$ = $2 - memory; }
	  | T_MULTIPLY pol_expression mixed_pol_expression 	 { $$ = $2 * $3; }
      | T_MULTIPLY pol_expression T_LOAD	 	    { $$ = $2 * memory; }
	  | T_DIVIDE pol_expression mixed_pol_expression	 { $$ = $2 / $3; }
      | T_DIVIDE pol_expression T_LOAD 	            { $$ = $2 / memory; }
	  | T_PLUS mixed_pol_expression pol_expression	 	 { $$ = $2 + $3; }
      | T_PLUS T_LOAD pol_expression	 	        { $$ = memory + $3; }
	  | T_MINUS mixed_pol_expression pol_expression	 	 { $$ = $2 - $3; }
      | T_MINUS T_LOAD pol_expression	 	        { $$ = memory - $3; }
	  | T_MULTIPLY mixed_pol_expression pol_expression 	 { $$ = $2 * $3; }
      | T_MULTIPLY T_LOAD pol_expression	 	        { $$ = memory * $3; }
	  | T_DIVIDE mixed_pol_expression pol_expression	 { $$ = $2 / $3; }
      | T_DIVIDE T_LOAD pol_expression	 	        { $$ = memory / $3; }
	  | T_DIVIDE pol_expression pol_expression		 { $$ = $2 / (float)$3; }
;

%%

int main() {
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "line %i",line_num);
	fprintf(stderr, " Parse error: %s\n", s);
	exit(1);
}
