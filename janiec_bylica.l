%{
#include <string.h>
#include <stdio.h>
#include "janiec_bylica.tab.hpp"
int curly_bracket_counter=0;
%}

%option yylineno

WS       [ \t]
NUM      (0|0x)?[0-9]+
ID       [A-Za-z_$][A-Za-z_$0-9]
TYPE     void|char|short|int|long|float
EXTYPE   struct|union

%x _EXTYPE _BODY _STRING _LINE_COMMENT _C_COMMENT

%%

{ID}     {return id; }
{NUM}    {return num; }
{TYPE}   {return decl_specifier; }
{EXTYPE} {BEGIN(_EXTYPE); }

<_EXTYPE>{WS}+{ID} {BEGIN(INITIAL); return decl_specifier; }


"("      {return left_parentheses; }
")"      {return right_parentheses; }
"["      {return left_bracket; }
"]"      {return right_bracket; }
","      {return comma; }
";"      {return semicolon; }
"\*+"    {return pointer; }

<INITIAL>"}"    {/* error */}
"{"             {BEGIN(_BODY); }

<_BODY>"{"      {++curly_bracket_counter; }
<_BODY>"}"      {--curly_bracket_counter; if(curly_bracket_counter==0)BEGIN(INITIAL); return body; }
<_BODY>"'\"'"   {}
<_BODY>"\""     {BEGIN(_STRING); }
<_BODY>"//"     {BEGIN(_LINE_COMMENT); }
<_BODY>"/\*"    {BEGIN(_C_COMMENT); }

<_STRING>"\""   {BEGIN(_BODY); }
<_STRING>.      {}
<_STRING>"\\\"" {}

<_C_COMMENT>.     {}
<_C_COMMENT>"*/"  {BEGIN(_BODY);}

<_LINE_COMMENT>.  {}
<_LINE_COMMENT>\n {BEGIN(_BODY);}


%%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                

      