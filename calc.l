%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "calc.tab.h"
int line_num = 0;
int memory = 0;
%}
%x COMMENTS


%%

"*--" {BEGIN(COMMENTS);}
<COMMENTS>"--*" {BEGIN(INITIAL);}
<COMMENTS>\n      { ++line_num; }   // still have to increment line numbers inside of comments!
<COMMENTS>.       ;

[ \t]	; // ignore all whitespace
[0-9]+\.[0-9]+ 	{yylval.fval = atof(yytext); return T_FLOAT;}
[0-9]+		    {yylval.ival = atoi(yytext); return T_INT;}
[a-zA-Z0-9]+\.cal    {yylval.sval = strdup(yytext); return F_STRING;}
\n		{++line_num; return T_NEWLINE;}
"+"		{return T_PLUS;}
"-"		{return T_MINUS;}
"*"		{return T_MULTIPLY;}
"/"		{return T_DIVIDE;}
"("		{return T_LEFT;}
")"		{return T_RIGHT;}
"file"  {return T_FILE;}
"pol"   {return T_POL;}
"save"  {return T_SAVE;}
"load"  {return T_LOAD;}
"exit"		{return T_QUIT;}
"quit"		{return T_QUIT;}

%%
