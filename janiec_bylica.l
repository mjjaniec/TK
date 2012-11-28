%{
#include <string.h>
#include <stdio.h>
#include "janiec_bylica.tab.hpp"
int curly_bracket_counter=0;
const char* newyytext(const char*);
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

<INITIAL>{TYPE}     {yylval.string=newyytext(yytext); return DECL_SPECIFIER; }
<INITIAL>{EXTYPE}   {BEGIN(_EXTYPE); yymore(); }
<INITIAL>{NUM}      {yylval.string=newyytext(yytext); return NUM; }
<INITIAL>{ID}       {yylval.string=newyytext(yytext); return ID; }
<INITIAL>({WS}|\n)+ {} //eat-up white spaces

<_EXTYPE>{WS}+{ID}  {yylval.string=newyytext(yytext); BEGIN(INITIAL); return DECL_SPECIFIER; }


<INITIAL>"("        {return LEFT_PARENTHESIS; }
<INITIAL>")"        {return RIGHT_PARENTHESIS; }
<INITIAL>"["        {return LEFT_BRACKET; }
<INITIAL>"]"        {return RIGHT_BRACKET; }
<INITIAL>","        {return COMMA; }
<INITIAL>";"        {return SEMICOLON; }
<INITIAL>{POINTER}  {yylval.string=newyytext(yytext); return POINTER; }

 /* Comments outside a function */
<INITIAL>"//"       {BEGIN(_OUTER_LINE_COMMENT); }
<INITIAL>"/\*"      {BEGIN(_OUTER_C_COMMENT); }
<_OUTER_C_COMMENT>{ALL} {; }
<_OUTER_C_COMMENT>"*/"  {BEGIN(INITIAL);}
<_OUTER_LINE_COMMENT>.  {; }
<_OUTER_LINE_COMMENT>\n {BEGIN(INITIAL);}


 /*Body handling */
<INITIAL>"}"      {/* error */}
<INITIAL>"{"      {++curly_bracket_counter; yymore(); BEGIN(_BODY); }

<_BODY>"{"        {++curly_bracket_counter; yymore();   }
<_BODY>"}"        {--curly_bracket_counter; yymore(); if(curly_bracket_counter==0){BEGIN(INITIAL); yylval.string=newyytext(yytext);return BODY; } }
<_BODY>"'\"'"     {yymore();  }
<_BODY>"\""       {yymore(); BEGIN(_STRING); }
<_BODY>"//"       {yymore(); BEGIN(_LINE_COMMENT); }
<_BODY>"/\*"      {yymore(); BEGIN(_C_COMMENT); }
<_BODY>{ALL}      {yymore(); }

<_STRING>"\""     {yymore(); BEGIN(_BODY); }
<_STRING>.        {yymore();  }
<_STRING>"\\\""   {yymore();  }

<_C_COMMENT>{ALL} {yymore();  }
<_C_COMMENT>"*/"  {yymore(); BEGIN(_BODY); }

<_LINE_COMMENT>.  {yymore();  }
<_LINE_COMMENT>\n {yymore(); BEGIN(_BODY); }

{ALL}             {fprintf(stderr,"Lexing error\n");}

%%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
const char* newyytext(const char* txt){
  char *t=new char[strlen(txt)+1];
  strcpy(t,txt);
  return t;
}
      