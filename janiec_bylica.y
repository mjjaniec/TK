
%{
#include <stdio.h>
void yyerror(char *);
int yylex(void);


%}

%token NUM ID DECL_SPECIFIER comma semicolon 
/* ( ) [ ]  */
%token left_parentheses right_parentheses left_bracket right_bracket
%token pointer 

%token BODY


%%

functions: function           {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
         | function functions {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
         ;

function: DECL_SPECIFIER declarator declaration_list BODY {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        | declarator declaration_list BODY                {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        | DECL_SPECIFIER declarator BODY                  {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        | declarator BODY                                 {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        ;

declaration_list: declaration                  {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                | declaration declaration_list {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                ;

declaration: DECL_SPECIFIER declarator_list semicolon {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
           | DECL_SPECIFIER semicolon                 {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
           ;

declarator_list: declarator declarator_list_kleen     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
               ;
               
declarator_list_kleen: /* empt */
                     | comma declarator declarator_list_kleen {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                     ;
                     
declarator: direct_declarator         {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          | pointer direct_declarator {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          ;
          
         
direct_declarator: ID                                                                   {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}  
                 | left_parentheses declarator right_parentheses                        {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator left_bracket NUM right_bracket                     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator left_bracket right_bracket                         {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator left_parentheses param_list right_parentheses      {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator left_parentheses identifier_list right_parentheses {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator left_parentheses right_parentheses                 {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 ;

identifier_list: ID identifier_list_kleen {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
               ;
               
identifier_list_kleen: /* empty */                    {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                     | comma ID identifier_list_kleen {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);} 
                     ;                    
                     
param_list: param_declaration param_list_kleen   {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          ;
          
param_list_kleen: /* empty */                              {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                | comma param_declaration param_list_kleen {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                ;

param_declaration: DECL_SPECIFIER declarator          {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | DECL_SPECIFIER abstract_declarator {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | DECL_SPECIFIER                     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 ;

abstract_declarator: pointer                            {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   | direct_abstract_declarator         {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   | pointer direct_abstract_declarator {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   ;
                   
direct_abstract_declarator: left_parentheses abstract_declarator right_parentheses    {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          | direct_abstract_declarator left_bracket NUM right_bracket {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            left_bracket NUM right_bracket {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          | direct_abstract_declarator left_bracket right_bracket     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            left_bracket right_bracket     {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          | direct_abstract_declarator left_bracket param_list right_bracket {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            left_bracket param_list right_bracket {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          ;


%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
}