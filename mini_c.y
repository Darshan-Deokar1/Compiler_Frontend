// C code that will be copied into the generated parser
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;    
extern int yycolumn;    

void yyerror(const char *s);
int yylex();    // lexer function which return tokens

// Counter to generate temporary variables for TAC
int tempCount = 0;  // counters for generating temporary variables t0, t1, t2, etc.
int labelCount = 0; // counters for generating labels l0, l1, l2, etc.

/*
// status array is used to track status of variables
int status[100]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// these variables store expressions for generating TAC
int curr=0;
int front=0;
int sep=-1;
char*ifprint[100];
char*expr[100]={NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL};
char*expr1[100]={NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL};
*/

// function to generate new temporary variables
char* newTemp() 
{
    char * temp = (char*)malloc(10 * sizeof(char));
    sprintf(temp, "t%d", tempCount++);
    return temp;
}

// function to generate new labels
char* newLabel() 
{
    char * temp = (char*)malloc(10 * sizeof(char));
    sprintf(temp, "l%d", labelCount++);
    return temp;
}
%}

// defines a union for different datatypes
%union 
{
    int num;
    double decimal;
    char *id;
    char *str;
    char *str1;
    char *str2;
    char *str3;
    char *str4;
    char *str5;
    char *str6;
    char character;
}

// declares tokens for C operators, keywords and symbols
%token DEFINE INCLUDE IF ELSE OPERATOR DIRECTIVE 
%token LESSTHANEQUALTO GREATERTHANEQUALTO LESSTHAN GREATERTHAN NOTEQUALTO EQUALEQUALTO LOGICAL BOOLEAN
%token LEFTSQUAREBRACE RIGHTSQUAREBRACE RETURN ASSIGN SEMICOLON
%token LPAREN RPAREN LBRACE RBRACE COMMA PLUS MINUS MUL DIV MOD SELFADD SELFDIVIDE SELFMULTIPLY SELFSUBTRACT INCREMENT DECREMENT

// specifies the value type for each token (NUMBER as an integer, IDENTIFIER as a string, etc)
// %token defines terminal symbols whereas %type defines non-terminal symbols
%token <num> NUMBER
%token <id> IDENTIFIER
%token <decimal> FLOAT
%token <str> STRING
%token <character> CHARACTER
%token <str1> DATATYPE
%type <id> expression
%type <id> T
%type <id> F
%type <id> assignment declaration if_statement
%type <str2> preprogram
%type <str3> preprogram1
%type <str4> cond
%type <str5> preprogram2
%type <str5> preprogram3

/*
cond:
    NUMBER {
    	char buffer[20];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }
    | BOOLEAN{
    	$$=$1;
    }
    | FLOAT{
    	char buffer[20];
        sprintf(buffer, "%f", $1);
        $$ = strdup(buffer);
    }
    | IDENTIFIER ASSIGN expression{
    	char*temp=newTemp();
    	printf("TAC: %s = %s\n", temp, $3);
    	printf("TAC: %s = %s\n", $1,temp);
    	$$=temp;
    }
    | IDENTIFIER{
    	char*temp=newTemp();
    	printf("TAC: %s = %s\n",temp,$1);
    	$$=temp;
    }
    | expression{
    	$$=$1;
    }
    | cond CONDITION cond{
    	printf("%s %s %s\n",$1,$2,$3);
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s %s %s\n",$1,$2,$3);
    	$$=t;
    }
    
    ;
*/
//%type <str4> preprogram2

%%
program:
    // this is a recursive function that is, a program can contain another program, allowing multiple statements
    | preprocessor_directives program
    | function_call program
    | statements program
    | function_dec program
    ;
cond:
    // if it is a number, it converts it to a string using strdup(buffer) and assigns it to $$
    NUMBER 
    {
    	char buffer[20];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }

    // if an identifier is assigned an expression, a new temporary variable is created using newTemp()
    | IDENTIFIER ASSIGN expression
    {
    	char*temp = newTemp();
    	printf("TAC: %s = %s\n", temp, $3); // temp = expression
    	printf("TAC: %s = %s\n", $1,temp);  // identifier = temp
    	$$=temp;
    }

    // if the condition is an identifier, it assigns it to a temporary variable
    | IDENTIFIER
    {
    	char*temp = newTemp();
    	printf("TAC: %s = %s\n",temp,$1);
    	$$ = temp;
    }

    // if the condition is an expression, use the expression's value
    | expression
    {
    	$$=$1;
    }

    // defines relational operators
    | cond LESSTHAN cond          // important if
    {
    	//printf("%s %s %s\n",$1,$2,$3);
    	char*t=(char*)malloc(100*sizeof(char)); 
    	sprintf(t,"%s < %s",$1,$3); // temporary variable(t) = $1 < $3
    	$$=t;   // $$ = t
    }
    | cond GREATERTHAN cond
    {
    //	printf("%s %s %s\n",$1,$2,$3);
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s > %s",$1,$3);
    	$$=t;
    }
    | cond LESSTHANEQUALTO cond
    {
    //	printf("%s %s %s\n",$1,$3);
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s <= %s",$1,$3);
    	$$=t;
    }
    | cond GREATERTHANEQUALTO cond
    {
   // 	printf("%s %s %s\n",$1,$2,$3);
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s >= %s",$1,$3);
    	$$=t;
    }
    | cond NOTEQUALTO cond
    {
    //	printf("%s %s %s\n",$1,$2,$3);
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s != %s",$1,$3);
    	$$=t;
    }
    | cond EQUALEQUALTO cond
    {
    	//printf("%s %s %s\n",$1,$2,$3);
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s == %s",$1,$3);
    	$$=t;
    }
    ;
    // alls a function IDENTIFIER(arguments);
function_call:
    IDENTIFIER LPAREN all_data_types RPAREN SEMICOLON
    ;

    // similar to functioncall but without semicolon which can be used inside expressions
function_call1:
    IDENTIFIER LPAREN all_data_types RPAREN

    // handles different argument types in a function call
all_data_types:
    | NUMBER all_data_types1
    | FLOAT all_data_types1
    | CHARACTER all_data_types1
    | STRING all_data_types1
    | BOOLEAN all_data_types1
    | IDENTIFIER all_data_types1
    | function_call1 all_data_types1
    ;

    // handles multiple arguments (comma-separated)
all_data_types1:
    | COMMA NUMBER all_data_types1
    | COMMA FLOAT all_data_types1
    | COMMA CHARACTER all_data_types1
    | COMMA STRING all_data_types1
    | COMMA BOOLEAN all_data_types1
    | COMMA IDENTIFIER all_data_types1
    | COMMA function_call1 all_data_types1
    ;

    // Declares a function returnType functionName(arguments) { body }
function_dec:
    DATATYPE IDENTIFIER LPAREN argument RPAREN LBRACE function_dec1 RBRACE
    ;

    // allows function bodies to contain statements or function calls
function_dec1:
    | statements function_dec1
    | function_call function_dec1
    ;

    // function argument like (int a)
argument:
    | DATATYPE IDENTIFIER arg1
    ;

    // additional arguments like (int x, float y, char z)
arg1:
    | COMMA DATATYPE IDENTIFIER arg1
    ;

preprocessor_directives:
    DEFINE IDENTIFIER NUMBER    // #define PI 3.14
    | DEFINE IDENTIFIER LPAREN IDENTIFIER RPAREN LPAREN expression RPAREN   // #define SQUARE(x) (x * x) 
    | INCLUDE DIRECTIVE // #include<stdio.h>
    ;

    // a list of statements
statements:
    | statements statement
    ;

// a single statement can contain assignment, declaration, function call, if, or return
statement:
    declaration
    | assignment
    | if_statement
    | function_call
    | ret SEMICOLON
    ;

ret:
    | RETURN BOOLEAN
    | RETURN NUMBER
    | RETURN FLOAT
    | RETURN CHARACTER
    | RETURN STRING
;

assignment:       // important assignment important =
    IDENTIFIER ASSIGN expression SEMICOLON 
    {
     //   printf("TAC: %    s = %s\n", $1, $3);
        	char temp[1000];
        	printf("TAC: %s = %s\n", $1, $3);   // x = y + 3
        	//printf("= %d\n",curr);
    }
    | IDENTIFIER INCREMENT SEMICOLON {
        char *t = newTemp();
        printf("TAC: %s = %s + 1\n", t, $1);
        printf("TAC: %s = %s\n", $1, t);    // x++
    }
    | IDENTIFIER DECREMENT SEMICOLON {
        char *t = newTemp();
        printf("TAC: %s = %s - 1\n", t, $1);
        printf("TAC: %s = %s\n", $1, t);    // x--
    }
    | IDENTIFIER SELFADD expression SEMICOLON {
        char *t = newTemp();
        printf("TAC: %s = %s + %s\n", t, $1, $3);
        printf("TAC: %s = %s\n", $1, t);    // x += y
    }
    | IDENTIFIER SELFSUBTRACT expression SEMICOLON {
        char *t = newTemp();
        printf("TAC: %s = %s - %s\n", t, $1, $3);
        printf("TAC: %s = %s\n", $1, t);    // x -= y
    }
    | IDENTIFIER SELFMULTIPLY expression SEMICOLON {
        char *t = newTemp();
        printf("TAC: %s = %s * %s\n", t, $1, $3);
        printf("TAC: %s = %s\n", $1, t);    // x *= y
    }
    | IDENTIFIER SELFDIVIDE expression SEMICOLON {
        char *t = newTemp();
        printf("TAC: %s = %s / %s\n", t, $1, $3);
        printf("TAC: %s = %s\n", $1, t);    // x /= y
    }
    ;

// handles int x = 5;
declaration:
    DATATYPE IDENTIFIER ASSIGN expression SEMICOLON {
        printf("TAC: %s = %s\n", $2, $4);
    }
    | DATATYPE IDENTIFIER SEMICOLON {
        printf("TAC: %s = 0\n", $2);
    }
    ;

// matches if(expression)
// Eg: if (x > 10)
// TAC: if NOT x > 10 goto L1  
preprogram:
	LPAREN expression RPAREN LBRACE 
    {
		char*l1=newLabel(); // Creates a new label l1 for the false condition
		printf("TAC: if NOT %s goto %s\n",$2,l1);   // if NOT <expression> goto <label>
		$$ = l1;    // xtores label l1 in $$ (used for jump handling)
	};

// handling else cases
// matches if block ending with else
/*
if (x > 10) {
    y = 5;
} else {
    y = 7;
}
*/
/*
TAC: if NOT x > 10 goto L1
TAC: y = 5
TAC: goto L2
L1:
TAC: y = 7
L2:
*/
preprogram1:
	preprogram statements RBRACE ELSE
    {
		char*l2=newLabel();     // creates l2 (new label) for else block
		printf("TAC: goto %s\n",l2);    // jumps to l2 after the if block
		printf("%s:\n",$1); // prints the false label ($1) to continue execution
		$$=l2;
	};

    // preprogram2 & preprogram3 handle if conditions with cond
    // preprogram2: works like preprogram, but for cond (relational conditions like x < y)
    // preprogram3: handles if-else using cond
    /* Eg:
    if (x < y) {
        a = 1;
    } else {
        a = 2;
    }
    */
    /*
    TAC: if NOT x < y goto L1
    TAC: a = 1
    TAC: goto L2
    L1:
    TAC: a = 2
    L2:
    */
preprogram2:
	LPAREN cond RPAREN LBRACE {
		char*l1=newLabel();
		printf("TAC: if NOT %s goto %s\n",$2,l1);
		$$ = l1;
	};
preprogram3:
	preprogram2 statements RBRACE ELSE{
		char*l2=newLabel();
		printf("TAC: goto %s\n",l2);
		printf("%s:\n",$1);
		$$=l2;
	};

/*
handles if statements with and without else.
calls preprogram* rules for different if conditions.
prints labels when necessary.
*/
if_statement:        // important if
    IF preprogram1  LBRACE statements RBRACE {
        printf("%s:\n",$2);
       	
    }
    |IF preprogram3  LBRACE statements RBRACE {
        printf("%s:\n",$2);
       	
    }
    |IF preprogram statements RBRACE {
       printf("%s:\n",$2);
    }
    |IF preprogram2 statements RBRACE {
       printf("%s:\n",$2);
    }
    |IF preprogram1 if_statement{
        printf("%s:\n",$2);
       	
    }
    |IF preprogram3 if_statement{
        printf("%s:\n",$2);
       	
    }
    ;
    
expression:
    expression PLUS T {
    char *t = newTemp();
    		char temp[1000];
        	
        	printf("TAC: %s = %s + %s\n", t, $1, $3);
        	
        
        $$ = t;
    }
    | expression MINUS T {
        char *t = newTemp();
       
        	char temp[1000];
        	printf("TAC: %s = %s - %s\n", t, $1, $3);
        	//strcat(ifprint[curr],temp);
        
        $$ = t;
    }
    | T {
        $$ = $1;
    }
    ;

T:
    T MUL F {
        char *t = newTemp();
       
        
        	char temp[1000];
        	printf("TAC: %s = %s * %s\n", t, $1, $3);
        	
        	//sprintf(temp,"TAC: %s = %s * %s\n", t, $1, $3);
        	//printf("%s %d",temp,curr);
        	
     
        $$ = t;
    }
    | T DIV F {
        char *t = newTemp();
        printf("TAC: %s = %s / %s\n", t, $1, $3);

        $$ = t;
    }
    | F {
        $$ = $1;
    }
    ;

F:
    IDENTIFIER {
        $$ = $1;
    }
    | NUMBER {
        char buffer[20];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }
    | FLOAT {
        char buffer[20];
        sprintf(buffer, "%f", $1);
        $$ = strdup(buffer);
    }
    | STRING {
        $$ = strdup($1);
    }
    | CHARACTER {
        char buffer[5];
        sprintf(buffer, "'%c'", $1);
        $$ = strdup(buffer);
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d, column %d: %s\n", yylineno, yycolumn, s);
}

int main(void) {
    printf("Parsing Mini-C and generating TAC...\n");
    yyparse();
    return 0;
}