
%{

#include <iostream>
#include <cstdarg>
#include <cstring>
#include <cstdio>
#include <string>
#include <vector>
#include <queue>

void yyerror(const char *);
int yylex(void);

/**
* concat - concatenate strings: make new string that is concatenation and release all string market as managed.
* idea similar to java's immutable strings
* example:
* const char* x=concat("mmlm",s1,s2,"ala ma kota",s3);
* wil resturn concatenation that strings and also release strings s1,s2,s3
* fmt = l - literal, m - managed;
*/
const char * concat(const char *fmt,...);


/**
* convert - doing convertion from old type function to new type one. It use decl_type (DECL_SPECIFIER) and body (BODY)
* and information kept in global state: function name, declaration_queue_queue, identifier_queue
*/
std::string convert(const char *decl_type, const char* body);

template <typename C> void clear(C&o);
//cleans global states
void cleanup();
typedef std::vector<std::string> squeue;
typedef std::pair<squeue,std::string> queue_w_type;   //queue with type;
typedef std::queue<queue_w_type> decl_queue;

//queue of identifiers
squeue identifier_queue;
//queue of declarations - for one type (ended by semicolon ';')
squeue declaration_queue;
//queue of above queue - to handle list of declarations. Also keeps information about type for that declaratoin queue
decl_queue declaration_queue_queue;

std::string function_name;

bool myerrstat=false;
const char*body_error="ERROR: In function body. Did you forget: '}'?\n";
const char* ret_error="ERROR: In function return type.\n";
const char*decl_error="ERROR: In function declaration.\n";
const char*list_error="ERROR: In function declaration list.\n";


%}

%union {
  const char* string;
}

/* ( ) [ ]  */
%token LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_BRACKET RIGHT_BRACKET
%token COMMA SEMICOLON 
%token <string> POINTER BODY NUM ID DECL_SPECIFIER


%type <string> direct_declarator declarator direct_abstract_declarator identifier_list
%type <string> param_list_kleen param_declaration abstract_declarator identifier_list_kleen param_list

%% 

functions: function           
         | function functions 
         ;

function: DECL_SPECIFIER declarator declaration_list BODY { std::cout<<convert($1,$4);  delete[]$1; delete[]$2;; delete[]$4;               cleanup(); }
        |                declarator declaration_list BODY { std::cout<<convert("",$3);  delete[]$1; delete[]$3;                            cleanup(); }
        | DECL_SPECIFIER declarator                  BODY { std::cout<<$1<<" " <<$2<<"\n"<<$3<<"\n\n"; delete[]$1; delete[]$2; delete[]$3; cleanup(); }
        |                declarator                  BODY { std::cout<<$1<<"\n"<<$2<<"\n\n";           delete[]$1; delete[]$2;             cleanup(); }
      
        /* Everything below is errors handling */
        | DECL_SPECIFIER declarator declaration_list error { std::cerr<<body_error; delete[]$1; delete[]$2; cleanup();}
        |                declarator declaration_list error { std::cerr<<body_error; delete[]$1;             cleanup();}
        | DECL_SPECIFIER declarator                  error { std::cerr<<body_error; delete[]$1; delete[]$2; cleanup();}
        |                declarator                  error { std::cerr<<body_error; delete[]$1;             cleanup();} 
        
        | error          declarator declaration_list BODY { std::cerr<< ret_error;             delete[]$2; cleanup();}
        | DECL_SPECIFIER error      declaration_list BODY { std::cerr<<decl_error; delete[]$1;             cleanup();}
        | DECL_SPECIFIER declarator error            BODY { std::cerr<<list_error; delete[]$1; delete[]$2; cleanup();}
        |                error      declaration_list BODY { std::cerr<<decl_error;                         cleanup();}
        |                declarator error            BODY { std::cerr<<list_error; delete[]$1;             cleanup();}
        | error          declarator                  BODY { std::cerr<< ret_error;             delete[]$2; cleanup();}
        | DECL_SPECIFIER error                       BODY { std::cerr<<decl_error; delete[]$1;           ; cleanup();}
        |                error                       BODY { std::cerr<<decl_error;                         cleanup();} 
        ;

declaration_list : declaration       
                 | declaration declaration_list 
                 ;
                                                       //remember type for current declaration
declaration: DECL_SPECIFIER declarator_list SEMICOLON { declaration_queue_queue.back().second=$1; }
           | DECL_SPECIFIER                 SEMICOLON { declaration_queue_queue.back().second=$1; }
           ;
   
   //add an entry to declaration_queue_queue
declarator_list: declarator declarator_list_kleen     { 
    declaration_queue.push_back($1); 
    declaration_queue_queue.push(make_pair(declaration_queue,""));
    declaration_queue.clear();
  };
               
declarator_list_kleen: /* empt */                             {                                   }
                     | COMMA declarator declarator_list_kleen { declaration_queue.push_back($2);  };
                     
declarator:         direct_declarator { $$=concat("m",$1);     }
          | POINTER direct_declarator { $$=concat("mm",$1,$2); }
          ;
          
         
direct_declarator: ID                                                                   { $$=concat("m",$1);                }  
                 | LEFT_PARENTHESIS declarator RIGHT_PARENTHESIS                        { $$=concat("lml","(", $2, ")");    }
                 | direct_declarator LEFT_BRACKET NUM RIGHT_BRACKET                     { $$=concat("mlml",$1,"[", $3, "]");}
                 | direct_declarator LEFT_BRACKET     RIGHT_BRACKET                     { $$=concat("ml",  $1,"[]");        }
                 | direct_declarator LEFT_PARENTHESIS param_list      RIGHT_PARENTHESIS { $$=concat("mlml",$1,"(", $3, ")");} 
                 /* below: resolve funtion name, only once for a function (as a parameter may be kept a function pointer which may be mismathced */
                 | direct_declarator LEFT_PARENTHESIS identifier_list RIGHT_PARENTHESIS { if(function_name=="")function_name=$1; $$=concat("mlml",$1,"(", $3, ")");}
                 | direct_declarator LEFT_PARENTHESIS                 RIGHT_PARENTHESIS { if(function_name=="")function_name=$1; $$=concat("ml",  $1,"(void)");    }
                 ;

identifier_list: ID identifier_list_kleen { identifier_queue.push_back($1); $$=concat("mm",$1,$2);  }
               ;
               
identifier_list_kleen: /* empty */                    { $$=concat("l","");                                                       }
                     | COMMA ID identifier_list_kleen { identifier_queue.push_back(std::string($2)); $$=concat("lmm",",",$2,$3); } 
                     ;                    
                     
param_list: param_declaration param_list_kleen   { $$=concat("mm",$1,$2); }
          ;
          
param_list_kleen: /* empty */                              { $$=concat("l","");           }
                | COMMA param_declaration param_list_kleen { $$=concat("lmm",", ",$2,$3); }
                ;

param_declaration: DECL_SPECIFIER declarator          { $$=concat("mlm",$1," ",$2); }
                 | DECL_SPECIFIER abstract_declarator { $$=concat("mlm",$1," ",$2); }
                 | DECL_SPECIFIER                     { $$=concat("m",$1);          }
                 ;

abstract_declarator: POINTER                            { $$=concat("m",$1);      }
                   |         direct_abstract_declarator { $$=concat("m",$1);      }
                   | POINTER direct_abstract_declarator { $$=concat("mm", $1, $2);}
                   ;
                   
direct_abstract_declarator: LEFT_PARENTHESIS abstract_declarator RIGHT_PARENTHESIS    { $$=concat("lml","(", $2, ")"); }
                          
                          | direct_abstract_declarator LEFT_BRACKET NUM RIGHT_BRACKET { $$=concat("mlml",$1,"[", $3, "]"); }
                          |                            LEFT_BRACKET NUM RIGHT_BRACKET { $$=concat("lml","[", $2, "]");     }
                          
                          | direct_abstract_declarator LEFT_BRACKET     RIGHT_BRACKET { $$=concat("ml",$1,"[]");  }
                          |                            LEFT_BRACKET     RIGHT_BRACKET { $$=concat("l","[]");      }
                          
                          
                          | direct_abstract_declarator LEFT_PARENTHESIS param_list RIGHT_PARENTHESIS { $$=concat("mlml",$1,"(",$3,")"); }
                          |                            LEFT_PARENTHESIS param_list RIGHT_PARENTHESIS { $$=concat("lml","(",$2,")");     }
                          
                          | direct_abstract_declarator LEFT_PARENTHESIS            RIGHT_PARENTHESIS { $$=concat("ml", $1,"(void)"); }
                          |                            LEFT_PARENTHESIS            RIGHT_PARENTHESIS { $$=concat("l","(void)");      }
                          ;

%%

void cleanup(){
    clear(declaration_queue_queue);
    declaration_queue.clear();
    identifier_queue.clear();
    function_name="";
    myerrstat=false;
}

//are there repeting identifiers
bool are_repeting(){
  typedef std::vector<std::string>::iterator iterator;
  
  for(iterator i=identifier_queue.begin(), e=identifier_queue.end(); i!=e; ++i){
    for(iterator j=i+1; j!=e; ++j)
      if(*i==*j){
        std::cerr<<"ERROR: in declaration of function: \'"<<function_name<<"\':";
        std::cerr<<" identifier: \'"<<*i<<"\' occures more than once.\n";
        return true;
      }
  }
  return false;
}


bool to_many_declarations(squeue& current_queue){
  if(!current_queue.empty()){
    std::cerr<<"ERROR: in declaration of function: \'"<<function_name<<"\':";
    std::cerr<<" to many declarations.\n";
    return true;
  }
  return false;
}

bool not_enough_declarations(){
  if(!identifier_queue.empty()){
     std::cerr<<"ERROR: in declaration of function: \'"<<function_name<<"\':";
     std::cerr<<" not enough declarations.\n";
     return true;
  }
  return false;
}

/*
* match identifier to declaration. Its kind of redoing parser's job. Bath thats easier way. 
* Its not hard to find identifier in declaration: i skip all "*(" and just check.
*/
bool bad_declaration(std::string ident, std::string decl){
  const char *d=decl.c_str(),*i=ident.c_str();
  const char *permissible="()[ "; int amount = 5; //with \0;
  
  while(*d=='*'||*d=='(')++d;
  while(*i)if(*i++!=*d++)goto AmILazy;
  for(int k=0; k<amount; ++k)
    if(*d==permissible[k]){ return false;}
AmILazy:
  std::cerr<<"ERROR: in declaration of function: \'"<<function_name<<"\':";
  std::cerr<<" declaration: \'"<<decl<<"\' does not match identifier: \'"<<ident<<"\'.\n";
  return true;
}


std::string convert(const char* decl_type, const char* body){
   if(are_repeting())return "";
   
   bool first=true;
   squeue current_queue;
   
   std::string res=std::string("\n")+std::string(decl_type)+" "+function_name+"(";
   
   for(;!declaration_queue_queue.empty();declaration_queue_queue.pop()){
     std::string type=declaration_queue_queue.front().second;
     for(current_queue=declaration_queue_queue.front().first; !current_queue.empty() && !identifier_queue.empty(); current_queue.pop_back(), identifier_queue.pop_back()){
        std::string ident=identifier_queue.back();
        std::string decl =current_queue.back();
        if(bad_declaration(ident,decl))return "";
        res.append(first?first=false,"":", ");
        res.append(type+" "+decl);
     }
   }
   if(to_many_declarations(current_queue))return "";
   if(not_enough_declarations())return "";
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

void yyerror(const char *s) {
    if(!myerrstat){
      fprintf(stderr, "%s\n", s);
      myerrstat=true;
    }
}

int main(void) { 
   yyparse();
}