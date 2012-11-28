
%{

#include <iostream>
#include <cstdarg>
#include <cstring>
#include <cstdio>
#include <string>
#include <vector>
#include <queue>
#include <stack>

void yyerror(char *);
int yylex(void);

/// fmt = l - literal, m - managed;
const char * concat(const char *fmt,...);
std::string convert(const char *decl_type, const char* body);
template <typename C> void clear(C&o);

typedef std::vector<std::string> squeue;
typedef std::pair<squeue,std::string> queue_w_type;   //queue with type;
typedef std::queue<queue_w_type> decl_queue;

squeue identifier_queue;
squeue declaration_queue;
decl_queue declaration_queue_queue;
std::string function_name;

%}

%union {
  const char* string;
}

/* ( ) [ ]  */
%token LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_BRACKET RIGHT_BRACKET
%token COMMA SEMICOLON 
%token <string> POINTER BODY NUM ID DECL_SPECIFIER


/* everything without function and functions */
%type <string> direct_declarator declarator declaration_list declarator_list
%type <string> declaration declarator_list_kleen direct_abstract_declarator
%type <string> identifier_list identifier_list_kleen param_list
%type <string> param_list_kleen param_declaration abstract_declarator

%% 

functions: function           {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
         | function functions {fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
         ;

function:
  DECL_SPECIFIER declarator declaration_list BODY { 
    std::cout<<convert($1,$4);
    delete[]$1; delete[]$2; delete[]$3; delete[]$4;
    fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);
  }|
  declarator declaration_list                BODY {
    std::cout<<convert("",$3);
    delete[]$1; delete[]$2; delete[]$3;
    fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);
  }
        | DECL_SPECIFIER declarator                  BODY { std::cout<<$1<<" " <<$2<<"\n"<<$3<<"\n\n"; delete[]$1; delete[]$2; delete[]$3;fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        | declarator BODY                                 { std::cout<<$1<<"\n"<<$2<<"\n\n"; delete[]$1; delete[]$2;fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
        ;

declaration_list
  : declaration       {  }  
  | declaration declaration_list {

    $$=concat("mlm", $1,"\n", $2);  fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);  
  };

declaration: DECL_SPECIFIER declarator_list SEMICOLON { declaration_queue_queue.back().second=$1;  $$=concat("mlml", $1," ", $2, ";"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
           | DECL_SPECIFIER                 SEMICOLON { declaration_queue_queue.back().second=$1;  $$=concat("ml", $1,";"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
           ;

declarator_list: declarator declarator_list_kleen     { 
    declaration_queue.push_back($1); 
    declaration_queue_queue.push(make_pair(declaration_queue,""));
    declaration_queue.clear();
    $$=concat("mm",$1,$2); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);
  };
               
declarator_list_kleen: /* empt */                             { $$=concat("l","");  }
                     | COMMA declarator declarator_list_kleen { 
    declaration_queue.push_back($2); 
    $$=concat("lmm",", ",$2,$3); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);
  };
                     
declarator:         direct_declarator { $$=concat("m",$1); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          | POINTER direct_declarator { $$=concat("mm",$1,$2); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          ;
          
         
direct_declarator: ID                                                                   { $$=concat("m",$1); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}  
                 | LEFT_PARENTHESIS declarator RIGHT_PARENTHESIS                        { $$=concat("lml","(", $2, ")"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_BRACKET NUM RIGHT_BRACKET                     { $$=concat("mlml",$1,"[", $3, "]");fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_BRACKET     RIGHT_BRACKET                     { $$=concat("ml",  $1,"[]");fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_PARENTHESIS param_list      RIGHT_PARENTHESIS { $$=concat("mlml",$1,"(", $3, ")");fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_PARENTHESIS identifier_list RIGHT_PARENTHESIS { if(function_name=="")function_name=$1; $$=concat("mlml",$1,"(", $3, ")");fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | direct_declarator LEFT_PARENTHESIS                 RIGHT_PARENTHESIS { $$=concat("ml",  $1,"()");fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 ;

identifier_list: ID identifier_list_kleen { identifier_queue.push_back($1); $$=concat("mm",$1,$2);  fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
               ;
               
identifier_list_kleen: /* empty */                    { $$=concat("l",""); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                     | COMMA ID identifier_list_kleen { identifier_queue.push_back(std::string($2)); $$=concat("lmm",",",$2,$3); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);} 
                     ;                    
                     
param_list: param_declaration param_list_kleen   { $$=concat("mm",$1,$2); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
          ;
          
param_list_kleen: /* empty */                              { $$=concat("l",""); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                | COMMA param_declaration param_list_kleen { $$=concat("lmm",", ",$2,$3); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                ;

param_declaration: DECL_SPECIFIER declarator          { $$=concat("mm",$1,$2); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | DECL_SPECIFIER abstract_declarator { $$=concat("mm",$1,$2); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 | DECL_SPECIFIER                     { $$=concat("m",$1);    fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                 ;

abstract_declarator: POINTER                            { $$=concat("m",$1); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   |         direct_abstract_declarator { $$=concat("m",$1);fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   | POINTER direct_abstract_declarator { $$=concat("mm", $1, $2);fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                   ;
                   
direct_abstract_declarator: LEFT_PARENTHESIS abstract_declarator RIGHT_PARENTHESIS    { $$=concat("lml","(", $2, ")"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          | direct_abstract_declarator LEFT_BRACKET NUM RIGHT_BRACKET { $$=concat("mlml",$1,"[", $3, "]"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            LEFT_BRACKET NUM RIGHT_BRACKET { $$=concat("lml","[", $2, "]"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          | direct_abstract_declarator LEFT_BRACKET     RIGHT_BRACKET { $$=concat("ml",$1,"[]"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__); }
                          |                            LEFT_BRACKET     RIGHT_BRACKET { $$=concat("l","[]"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__); }
                          
                          
                          | direct_abstract_declarator LEFT_PARENTHESIS param_list RIGHT_PARENTHESIS { $$=concat("mlml",$1,"(",$3,")"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            LEFT_PARENTHESIS param_list RIGHT_PARENTHESIS { $$=concat("lml","(",$2,")"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          
                          | direct_abstract_declarator LEFT_PARENTHESIS            RIGHT_PARENTHESIS { $$=concat("ml", $1,"()"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          |                            LEFT_PARENTHESIS            RIGHT_PARENTHESIS { $$=concat("l","()"); fprintf(stderr,"%s: %d\n",__FILE__,__LINE__);}
                          ;

%%

bool are_repeting(){
  typedef std::vector<std::string>::iterator iterator;
  
  for(iterator i=identifier_queue.begin(), e=identifier_queue.end(); i!=e; ++i){
    for(iterator j=i+1; j!=e; ++j)
      if(*i==*j)return true;
  }
  return false;
}

std::string convert(const char* decl_type, const char* body){
   if(are_repeting())return "";
   std::string res=std::string(decl_type)+" "+function_name+"(";
   bool first=true;
    for(;!declaration_queue_queue.empty();declaration_queue_queue.pop()){
      std::string type=declaration_queue_queue.front().second;
      for(squeue current_queue=declaration_queue_queue.front().first; !current_queue.empty() && !identifier_queue.empty(); current_queue.pop_back(), identifier_queue.pop_back()){
          std::string ident=identifier_queue.back();
          std::string decl =current_queue.back();
          res.append(first?first=false,"":", ");
          res.append(type);
          res.append(" ");
          res.append(decl);
          std::cout<<": "<<"I: "<<ident<<"\tD: "<<decl<<"\tT: "<<declaration_queue_queue.front().second<<"\n";
      }
    }
    clear(declaration_queue_queue);
/*    clear(declaration_queue);
    clear(identifier_queue);*/
    function_name="";
    
    return res+")\n"+body+"\n\n";
}


template <typename C> void clear(C&o){
  while(!o.empty())o.pop();
}

const char * concat(const char *fmt,...){
  const char *fit, *pit, *beg;
  char *res, *rit;
  int length=0;
  va_list v;
  
  va_start(v,fmt);
  for(fit=fmt; *fit; ++fit)
    length+=strlen(pit=va_arg(v,const char *));
    
  va_start(v,fmt);
  rit=res=new char[length+1];
  for(fit=fmt; *fit; ++fit){
    for(beg=pit=va_arg(v,const char*); (*rit=*pit); ++rit,++pit);
    if(*fit=='M'||*fit=='m')
      delete [] beg;
  }*rit='\0';
  return res;      
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) { 
   yyparse();
}