
%{
#include <stdio.h>
void yyerror(char *);
int yylex(void);


%}

%token NUM ID DECL_SPECIFIER COMMA SEMICOLON 
/* ( ) [ ]  */
%token LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_BRACKET RIGHT_BRACKET
%token POINTER BODY


%%

functions: function           {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
         | function functions {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
         ;

function: DECL_SPECIFIER declarator declaration_list BODY {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        |                declarator declaration_list BODY {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        | DECL_SPECIFIER declarator                  BODY {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        | declarator BODY                                 {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        ;

declaration_list: declaration                  {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                | declaration declaration_list {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                ;

declaration: DECL_SPECIFIER declarator_list SEMICOLON {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
           | DECL_SPECIFIER                 SEMICOLON {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
           ;

declarator_list: declarator declarator_list_kleen     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
               ;
               
declarator_list_kleen: /* empt */
                     | COMMA declarator declarator_list_kleen {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                     ;
                     
declarator:         direct_declarator {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          | POINTER direct_declarator {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          ;
          
         
direct_declarator: ID                                                                   {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}  
                 | LEFT_PARENTHESIS declarator RIGHT_PARENTHESIS                        {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_BRACKET NUM RIGHT_BRACKET                     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_BRACKET     RIGHT_BRACKET                     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_PARENTHESIS param_list      RIGHT_PARENTHESIS {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_PARENTHESIS identifier_list RIGHT_PARENTHESIS {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_PARENTHESIS                 RIGHT_PARENTHESIS {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 ;

identifier_list: ID identifier_list_kleen {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
               ;
               
identifier_list_kleen: /* empty */                    {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                     | COMMA ID identifier_list_kleen {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);} 
                     ;                    
                     
param_list: param_declaration param_list_kleen   {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          ;
          
param_list_kleen: /* empty */                              {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                | COMMA param_declaration param_list_kleen {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                ;

param_declaration: DECL_SPECIFIER declarator          {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | DECL_SPECIFIER abstract_declarator {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | DECL_SPECIFIER                     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 ;

abstract_declarator: POINTER                            {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   |         direct_abstract_declarator {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   | POINTER direct_abstract_declarator {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   ;
                   
direct_abstract_declarator: LEFT_PARENTHESIS abstract_declarator RIGHT_PARENTHESIS    {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          | direct_abstract_declarator LEFT_BRACKET NUM RIGHT_BRACKET {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            LEFT_BRACKET NUM RIGHT_BRACKET {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          
                          | direct_abstract_declarator LEFT_BRACKET param_list RIGHT_BRACKET {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            LEFT_BRACKET param_list RIGHT_BRACKET {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          | direct_abstract_declarator LEFT_BRACKET RIGHT_BRACKET     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            LEFT_BRACKET RIGHT_BRACKET     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          ;


%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) { 
    yyparse();
}