%{
#include "mini_c.tab.h"

#include <stdlib.h>
#include <string.h>

extern int yylineno;  // Provided by Bison to track line numbers
int yycolumn = 1;     // Custom variable to track column numbers
%}

%%



"#define"            { return DEFINE; }
"#include"          { return INCLUDE; }
true|false|TRUE|FALSE { return BOOLEAN; }
"return"             { return RETURN; }
"<"[a-zA-Z0-9._]+">" { return DIRECTIVE; }
"bool"              { return DATATYPE; }
"int"               { return DATATYPE; }
"float"             { return DATATYPE; }
"char"              { return DATATYPE; }
"void"              { return DATATYPE; }

"if"                { return IF; }
"else"              { return ELSE; }
"-"                 { yycolumn++; return MINUS; }
[0-9]+          { yylval.num = atoi(yytext); yycolumn += strlen(yytext); return NUMBER; }
[-]?([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)([eE][-+]?[0-9]+)? { yylval.decimal = atof(yytext); yycolumn += strlen(yytext); return FLOAT; }
\"([^\"\n]|\\.)*\"   { yylval.str = strdup(yytext); yycolumn += strlen(yytext); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); yycolumn += strlen(yytext); return IDENTIFIER; }
'([^'\\\n]|\\.)'    { yylval.character = yytext[1]; yycolumn += strlen(yytext); return CHARACTER; }
"++"                { yycolumn += 2; return INCREMENT; }
"--"                { yycolumn += 2; return DECREMENT; }
"-="                { yycolumn += 2; return SELFSUBTRACT; }
"+="                { yycolumn += 2; return SELFADD; }
"/="                { yycolumn += 2; return SELFDIVIDE; }
"*="                { yycolumn += 2; return SELFMULTIPLY; }
"+"                 { yycolumn++; return PLUS; }

"*"                 { yycolumn++; return MUL; }
"/"                 { yycolumn++; return DIV; }
"%"                 { yycolumn++; return MOD; }
","                 { yycolumn++; return COMMA; }
"="                 { yycolumn++; return ASSIGN; }

"<="		    { yycolumn++; return LESSTHANEQUALTO; }
">="		    { yycolumn++; return GREATERTHANEQUALTO; }
"=="		    { yycolumn++; return EQUALEQUALTO; }
"!="		    { yycolumn++; return NOTEQUALTO; }
"<"		    { yycolumn++; return LESSTHAN; }
">"		    { yycolumn++; return GREATERTHAN; }
(&&|\|\||!)         { yycolumn++; return LOGICAL; }

";"                 { yycolumn++; return SEMICOLON; }
"("                 { yycolumn++; return LPAREN; }
")"                 { yycolumn++; return RPAREN; }
"{"                 { yycolumn++; return LBRACE; }
"}"                 { yycolumn++; return RBRACE; }
"["                 { yycolumn++; return LEFTSQUAREBRACE; }
"]"                 { yycolumn++; return RIGHTSQUAREBRACE; }
"//"[^\n]*          { /* Skip single-line comments */ }
"/\*"([^*]|\*+[^*/])*\*+"/"   { /* Skip multi-line comments */ }
[ \t\n]+            { 
                        if (yytext[0] == '\n') {
                            yylineno++;  
                            yycolumn = strlen(yytext);
                        } else {
                            yycolumn += strlen(yytext); 
                        }
                    }

%%

// yywrap() is a function used in Lex/Flex to determine whether the scanner should continue scanning after reaching the end of an input file
int yywrap() {
    return 1;  
}
