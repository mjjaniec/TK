%{
#include <string.h>
#include <stdio.h>
#include "janiec_bylica.tab.hpp"
int curly_bracket_counter=0;
//void yyerror(const char *s);
%}

%option yylineno

WS       [ \t]
NUM      (0|0x)?[0-9]+
ID       [A-Za-z_$][A-Za-z_$0-9]*
TYPE     void|char|short|int|long|float
EXTYPE   struct|union
ALL      .|[\n]
POINTER  [*]+

%x _BODY _STRING _LINE_COMMENT _C_COMMENT
%x _EXTYPE _OUTER_LINE_COMMENT _OUTER_C_COMMENT


%%

<INITIAL>{TYPE}     {return DECL_SPECIFIER; }
<INITIAL>{EXTYPE}   {BEGIN(_EXTYPE); }
<INITIAL>{NUM}      {return NUM; }
<INITIAL>{ID}       {return ID; }
<INITIAL>({WS}|\n)+ {} //eat-up white spaces

<_EXTYPE>{WS}+{ID}  {BEGIN(INITIAL); return DECL_SPECIFIER; }


<INITIAL>"("        {return LEFT_PARENTHESIS; }
<INITIAL>")"        {return RIGHT_PARENTHESIS; }
<INITIAL>"["        {return LEFT_BRACKET; }
<INITIAL>"]"        {return RIGHT_BRACKET; }
<INITIAL>","        {return COMMA; }
<INITIAL>";"        {return SEMICOLON; }
<INITIAL>{POINTER}  {return POINTER; }

 /* Comments outside a function */
<INITIAL>"//"       {BEGIN(_OUTER_LINE_COMMENT); }
<INITIAL>"/\*"      {BEGIN(_OUTER_C_COMMENT); }
<_OUTER_C_COMMENT>{ALL} {; }
<_OUTER_C_COMMENT>"*/"  {BEGIN(INITIAL);}
<_OUTER_LINE_COMMENT>.  {; }
<_OUTER_LINE_COMMENT>\n {BEGIN(INITIAL);}


 /*Body handling */
<INITIAL>"}"      {/* error */}
<INITIAL>"{"               {++curly_bracket_counter; BEGIN(_BODY); }

<_BODY>"{"        {++curly_bracket_counter; }
<_BODY>"}"        {--curly_bracket_counter; if(curly_bracket_counter==0)BEGIN(INITIAL); return BODY; }
<_BODY>"'\"'"     {; }
<_BODY>"\""       {BEGIN(_STRING); }
<_BODY>"//"       {BEGIN(_LINE_COMMENT); }
<_BODY>"/\*"      {BEGIN(_C_COMMENT); }
<_BODY>{ALL}      {}

<_STRING>"\""     {BEGIN(_BODY); }
<_STRING>.        {; }
<_STRING>"\\\""   {; }

<_C_COMMENT>{ALL} {; }
<_C_COMMENT>"*/"  {BEGIN(_BODY); }

<_LINE_COMMENT>.  {; }
<_LINE_COMMENT>\n {BEGIN(_BODY); }

{ALL}             {fprintf(stderr,"Lexing error\n");}

%%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                

      