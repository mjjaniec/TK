
%{
    #include <stdio.h>
    void yyerror(char *);
    int yylex(void);

    int sym[26];
%}

%token num id decl_specifier comma semicolon 
/* ( ) [ ]  */
%token left_parentheses right_parentheses left_bracket right_bracket
%token pointer 

%token body


%%

functions: function
         | function functions
         ;

function: decl_specifier declarator declaration_list body
        | declarator declaration_list body
        | decl_specifier declarator body
        | declarator body
        ;

declaration_list: declaration
                | declaration declaration_list
                ;

declaration: decl_specifier declarator_list semicolon
           | decl_specifier semicolon
           ;

declarator_list: declarator declarator_list_kleen
               ;
               
declarator_list_kleen: /* empt */
                     | comma declarator declarator_list_kleen
                     ;
                     
declarator: direct_declarator
          | pointer direct_declarator
          ;
          
         
direct_declarator: id
                 | left_parentheses declarator right_parentheses
                 | direct_declarator left_bracket num right_bracket
                 | direct_declarator left_bracket right_bracket
                 | direct_declarator left_parentheses param_list right_parentheses
                 | direct_declarator left_parentheses identifier_list right_parentheses
                 ;

identifier_list: id identifier_list_kleen
               ;
               
identifier_list_kleen: /* empty */
                     | comma id identifier_list_kleen
                     ;
                     
param_list: param_declaration param_list_kleen
          ;
          
param_list_kleen: /* empty */
                | comma param_declaration param_list_kleen
                ;

param_declaration: decl_specifier declarator
                 | decl_specifier abstract_declarator
                 | decl_specifier
                 ;

abstract_declarator: pointer
                   | direct_abstract_declarator
                   | pointer direct_abstract_declarator
                   ;
                   
direct_abstract_declarator: left_parentheses abstract_declarator right_parentheses

                          | direct_abstract_declarator left_bracket num right_bracket
                          |                            left_bracket num right_bracket
                          
                          | direct_abstract_declarator left_bracket right_bracket
                          |                            left_bracket right_bracket
                          
                          | direct_abstract_declarator left_bracket param_list right_bracket
                          |                            left_bracket param_list right_bracket
                          ;


%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
}