%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>
#include <vector>

using namespace std;

struct Tipo {
  string nome;  
  string decl;  
  string fmt;
    bool retorno;
  vector<int> dim;

};

Tipo Integer = { "integer", "int", "d",true };
Tipo Double =  { "double", "double", "lf", true };
Tipo String =  { "string", "char", "s",true };
Tipo Char =    { "char", "char", "c", true };
Tipo Void =    { "void", "void", "", false };
Tipo Boolean = { "boolean", "bool", "", true };

struct Atributo {
  string v, c;
  Tipo t;
  vector<string> lst;
}; 

#define YYSTYPE Atributo

int yylex();
int yyparse();
void yyerror(const char *);
void erro( string );

map<string,Tipo> ts;
map<string,Tipo> tsl;
map< string, map< string, Tipo > > tro;// tipo_resltado_operacao;
map<string, vector<string>> funcoes;
vector<string> atributos_funcao;

// contadores para variáveis temporariras
map< string, int > temp_global;
map< string, int > temp_local;
map< string, int > nlabel;

vector<string> vetor_indice_cases;

bool escopo_local = false;
int nswitch = 0 ;

string toString( int n ) {
  char buf[256] = "";
  sprintf( buf, "%d", n );
  
  return buf;
}

int toInt( string valor ) {
  int aux = 0,i=0;

  
  i=sscanf( valor.c_str(), "%d", &aux );
  if(i==0) return -1;
  else return aux;
}

string gera_nome_var( Tipo t ) {
  return "t_" + t.nome + "_" + 
   toString( ++(escopo_local ? temp_local : temp_global)[t.nome] );
}

// 'Atributo&': o '&' significa passar por referência (modifica).
void declara_variavel( Atributo& ss, 
                       const Atributo& s1, const Atributo& s2, const string s3) {
  ss.c = "";
  if(escopo_local){
  	for( int i = 0; i < s2.lst.size(); i++ ) {
    	if( tsl.find( s2.lst[i] ) != tsl.end() ) 
      	erro( "Variável já declarada: " + s2.lst[i] );
    	else {
        if(s1.t.nome==String.nome){
          tsl[ s2.lst[i] ] = s1.t;
      	  ss.c += s1.t.decl + " " + s2.lst[i]+ "["+toString(s1.t.dim[0]+1)+"]" + s3 + ";\n"; 
        }
        else{
          tsl[ s2.lst[i] ] = s1.t;
          ss.c += s1.t.decl + " " + s2.lst[i]+ s3 + ";\n"; 
        }
    	}  
  	}
	}
	else{
		for( int i = 0; i < s2.lst.size(); i++ ) {
    	if( ts.find( s2.lst[i] ) != ts.end() ) 
      	erro( "Variável já declarada: " + s2.lst[i] );
    	else {
      	if(s1.t.nome==String.nome){
          ts[ s2.lst[i] ] = s1.t;
          ss.c += s1.t.decl + " " + s2.lst[i]+ "["+toString(s1.t.dim[0]+1)+"]" + s3 + ";\n"; 
        }
        else{
          ts[ s2.lst[i] ] = s1.t;
          ss.c += s1.t.decl + " " + s2.lst[i]+ s3 + ";\n"; 
        }
    	}  
  	}
	}
}

string declara_nvar_temp( Tipo t, int qtde ) {
  string aux = "";
   
  for( int i = 1; i <= qtde; i++ )
    if(t.nome!=String.nome){
      aux += t.decl + " t_" + t.nome + "_" + toString( i ) + ";\n";
    }
    else{
      aux += t.decl + " t_" + t.nome + "_" + toString( i )+"["+toString(t.dim[0]+1)+"]"+ ";\n";
    }
    
  return aux;  
}

string declara_var_temp( map< string, int >& temp ) {
  string decls = 
    declara_nvar_temp( Integer, temp[Integer.nome] ) +
    declara_nvar_temp( Boolean, temp[Boolean.nome] ) +
    declara_nvar_temp( Double, temp[Double.nome] ) +
    declara_nvar_temp( String, temp[String.nome] ) +
    declara_nvar_temp( Char, temp[Char.nome] )  +
    "\n";
  
  temp.clear();
  
  return decls;
}

void gera_codigo_atribuicao( Atributo& ss, 
                             const Atributo& s1, 
                             const Atributo& s3 ) {
  if( (s1.t.nome == s3.t.nome  || (s1.t.nome=="integer" && s3.t.nome=="float")|| (s1.t.nome=="float" && s3.t.nome=="double")
  || (s1.t.nome=="double" && s3.t.nome=="float")|| (s1.t.nome=="float" && s3.t.nome=="integer")|| (s1.t.nome=="integer" && s3.t.nome=="double")
  || (s1.t.nome=="double" && s3.t.nome=="integer")) && s1.t.nome!=String.nome )
  {
    ss.c = s1.c + s3.c + "  " + s1.v + " = " + s3.v + ";\n";
  }
  else if( s1.t.nome == s3.t.nome &&  s1.t.nome == String.nome) {
    ss.c = s1.c + s3.c + "  " 
           + "strncpy( " + s1.v + ", " + s3.v + ", " + 
           toString( s1.t.dim[0]) + " );\n";
  }
}

void gera1Dim(const Atributo& s2, const Atributo& s4){
//comment
	if(escopo_local){
    for( int i = 0; i < s2.lst.size(); i++ ) {
      tsl[s2.lst[i]].dim.push_back(toInt(s4.v));
    }
  }
  else{//comment
  	for( int i = 0; i < s2.lst.size(); i++ ) {
      ts[s2.lst[i]].dim.push_back(toInt(s4.v));
    }
  }//comment
}

void gera2Dim(const Atributo& s2, const Atributo& s4, const Atributo& s7){
//comment
	if(escopo_local){
    for( int i = 0; i < s2.lst.size(); i++ ) {
      tsl[s2.lst[i]].dim.push_back(toInt(s4.v));
      tsl[s2.lst[i]].dim.push_back(toInt(s7.v));
    }
  }
  else{//comment
  	for( int i = 0; i < s2.lst.size(); i++ ) {
      ts[s2.lst[i]].dim.push_back(toInt(s4.v));
      ts[s2.lst[i]].dim.push_back(toInt(s7.v));
    }
  }//comment
}

void busca_tipo_da_variavel( Atributo& ss, const Atributo& s1 ) {
//comment
	if(escopo_local){
  	    if((tsl.find( s1.v ) == tsl.end()) && (ts.find( s1.v ) == ts.end()) ){
    	    erro( "Variável não declarada: " + s1.v );
        }
  	    else {
            if(tsl.find( s1.v ) == tsl.end()){
                ss.t = ts[ s1.v ];
            }
            else{
                ss.t = tsl[ s1.v ];
            }
            if(s1.t.nome == String.nome){
             ss.v = s1.v + "["+toString(s1.t.dim[0]+1)+"]" ;
            }

  	    }
	}
	else{//comment
		if( ts.find( s1.v ) == ts.end() ) {
    	    erro( "Variável não declarada: " + s1.v );
        }
      	else {
        	ss.t = ts[ s1.v ];
        	 if(s1.t.nome == String.nome){
                  ss.v = s1.v + "["+toString(s1.t.dim[0]+1)+"]" ;
             }

      	}
    }
}

string par( Tipo a, Tipo b ) {
  return a.nome + "," + b.nome;  
}

void gera_codigo_operador( Atributo& ss, const Atributo& s1, const Atributo& s2, const Atributo& s3) {
  if( tro.find( s2.v ) != tro.end() ) {
    if( tro[s2.v].find( par( s1.t, s3.t ) ) != tro[s2.v].end() ) {
      ss.t = tro[s2.v][par( s1.t, s3.t )];
      ss.v = gera_nome_var( ss.t );
      if(ss.t.nome==String.nome){
        ss.c = s1.c + s3.c + "  " +"strncpy("+ ss.v +","+  s1.v +","+toString(s1.t.dim[0])+");\n"+ "  strncat("+ss.v+"," + s3.v + 
        ","+toString(s3.t.dim[0])+");\n";
      }
      else{
        ss.c = s1.c + s3.c + "  " + ss.v + " = " + s1.v + s2.v + s3.v + ";\n";
      }
    }
    else
      erro( "O operador '" + s2.v + "' não está definido para os tipos " + s1.t.nome + " e " + s3.t.nome + "." );
  }
  else
    erro( "Operador '" + s2.v + "' não definido." );
}

void gera_codigo_matrix(Atributo& ss, const Atributo& s1, const Atributo& s3, const Atributo& s6, const Atributo& s9){
	string aux1, aux2, aux3, axu4; 
	//Comment
	if(escopo_local){
  	if( (tsl.find( s1.v ) == tsl.end()) && (ts.find( s1.v ) == ts.end()) )
    	erro( "Variável não declarada: " + s1.v );
  	else if( s1.t.nome == s9.t.nome ){
    	if((tsl[s1.v].dim[0]-1)<toInt(s3.v) || (tsl[s1.v].dim[1]-1)<toInt(s6.v)){
      	erro("Acesso indevido ao Array\n");
    	}
    	aux1=gera_nome_var( Integer );
    	ss.c=ss.c+"  "+aux1+" = "+ s3.v + '*' + toString(tsl[s1.v].dim[1])+";\n";
    	aux2=gera_nome_var( Integer );
    	ss.c=ss.c+"  "+aux2+ " = "+ aux1 +'+'+ s6.v+";\n";
    	ss.c =s1.c + s3.c +ss.c+  "  " + s1.v + '[' + aux2 + ']' + " = " + s9.v + ";\n";    
  	}
  	else{
    	erro("Tipo errado na atribuição");
  	}
	}
	else{//Comment
		if( ts.find( s1.v ) == ts.end() )
    	erro( "Variável não declarada: " + s1.v );
  	else if( s1.t.nome == s9.t.nome ){
    	if((ts[s1.v].dim[0]-1)<toInt(s3.v) || (ts[s1.v].dim[1]-1)<toInt(s6.v)){
      	erro("Acesso indevido ao Array\n");
    	}
    	aux1=gera_nome_var( Integer );
    	ss.c=ss.c+"  "+aux1+" = "+ s3.v + '*' + toString(ts[s1.v].dim[1])+";\n";
    	aux2=gera_nome_var( Integer );
    	ss.c=ss.c+"  "+aux2+ " = "+ aux1 +'+'+ s6.v+";\n";
    	ss.c =s1.c + s9.c +ss.c+  "  " + s1.v + '[' + aux2 + ']' + " = " + s9.v + ";\n";    
  	}
  	else{
    	erro("Tipo errado na atribuição");
  	}
	}//Comment
}

void gera_codigo_vetor(Atributo& ss, const Atributo& s1, const Atributo& s3, const Atributo& s6){
	//comment
	if(escopo_local){
		if((tsl.find( s1.v ) == tsl.end()) && (ts.find( s1.v ) == ts.end()))
    	erro( "Variável não declarada: " + s1.v);
 		else if( s1.t.nome == s6.t.nome ){
   		if((tsl[s1.v].dim[0]-1)<toInt(s3.v)){
     		erro("Acesso indevido ao Array\n");
    	}
    ss.c =s1.c + s3.c +ss.c+  "  " + s1.v + '[' + s3.v + ']' + " = " + s6.v + ";\n";    
  	}
  	else{
    	erro("Tipo errado na atribuição");
  	}
	}
	else{//comment
  	if(ts.find( s1.v ) == ts.end())
    	erro( "Variável não declarada: " + s1.v);
  	else if( s1.t.nome == s6.t.nome ){
    	if((ts[s1.v].dim[0]-1)<toInt(s3.v)){
      	erro("Acesso indevido ao Array\n");
    	}
    	ss.c =s1.c + s3.c +ss.c+  "  " + s1.v + '[' + s3.v + ']' + " = " + s6.v + ";\n";    
  	}
  	else{
    	erro("Tipo errado na atribuição");
  	}
	}//comment
}

string gera_nome_label( string cmd ) {
  return "L_" + cmd + "_" + toString( ++nlabel[cmd] );
}

void gera_cmd_if( Atributo& ss, const Atributo& exp, const Atributo& cmd_then, string cmd_else ) { 
  string lbl_then = gera_nome_label( "then" );
  string lbl_end_if = gera_nome_label( "end_if" );

  if( exp.t.nome == String.nome || exp.t.nome == Char.nome)
    erro( "A expressão do IF deve ser um numero!" );
    
  ss.c = exp.c + 
         "\nif( " + exp.v + " ) goto " + lbl_then + ";\n" +
         cmd_else + "  goto " + lbl_end_if + ";\n\n" +
         lbl_then + ":;\n" + 
         cmd_then.c + "\n" +
         lbl_end_if + ":;\n"; 
}

void gera_cmd_for(Atributo& ss, const Atributo& s4, const Atributo& s6, const Atributo& s8, const Atributo& s11){
	string lbl_inicio_for = gera_nome_label("inicio_for");								
	string lbl_fim_for = gera_nome_label("fim_for");									

	ss.c =  s4.c + "  " + lbl_inicio_for + ":;\n" + s6.c + s6.v + "= !" + s6.v + "; \n" +
			"  if (" + s6.v + ") goto " + lbl_fim_for + ";\n" +s11.c +
			"\n" + s8.c +
			"\n  goto " + lbl_inicio_for + ";\n  " +
			lbl_fim_for + ":;\n";
}

void gera_cmd_while(Atributo& ss, const Atributo& s4, const Atributo& s7){
    string lbl_inicio_while = gera_nome_label("inicio_while");
    string lbl_fim_while = gera_nome_label("fim_while");

    ss.c =  lbl_inicio_while + ":;\n" + s4.c + s4.v + "= !" + s4.v + ";\n"
            "  if (" + s4.v + ") goto " + lbl_fim_while + ";\n" +
            "\n" +  s7.c +
            "\n  goto " + lbl_inicio_while + ";\n  " +
            lbl_fim_while + ":;\n";
}

void gera_cmd_dowhile(Atributo& ss, const Atributo& s4, const Atributo& s8){
    string lbl_inicio_dowhile = gera_nome_label("inicio_dowhile");
    string lbl_fim_dowhile = gera_nome_label("fim_dowhile");

    ss.c = "  " + lbl_inicio_dowhile + ":;\n" + s4.c + s8.c + s8.v + "= !" + s8.v + ";\n" + " if(" + s8.v + ") goto " + lbl_fim_dowhile + ";\n" +
    "\n" + "\n goto " + lbl_inicio_dowhile + ";\n " + lbl_fim_dowhile + ":;\n";
}

void gera_cmd_switch(Atributo& ss, const Atributo& s4, const Atributo& s6) {
    string lbl_inicio_switch = gera_nome_label("inicio_switch"+toString(nswitch));
    string lbl_fim_switch = gera_nome_label("fim_switch"+toString(nswitch));

    string teste_cases = "";
    string label;
    int tam = vetor_indice_cases.size();
    for(int i = 0; i < tam ; i++){
       string var = vetor_indice_cases.front();
       vetor_indice_cases.erase(vetor_indice_cases.begin());
        label = "L_case" + toString(nswitch) + var +"_1";
       teste_cases += " var_aux_switch = " + s4.v + " == " + var + ";\n";
       teste_cases += "if(var_aux_switch) goto " + label + ";\n";
    }
    label = "L_default" + toString(nswitch) + "_1";
    teste_cases += "goto " + label + ";\n";

    vetor_indice_cases.clear();
    nswitch++;

    ss.c = " " + lbl_inicio_switch + ":;\n" + s4.c + "\n" + teste_cases + "\n"
    + s6.c + "\n" + lbl_fim_switch + ":;\n";
}



void gera_case(Atributo& ss, const Atributo& s4, const Atributo& s7, const Atributo& s8, const Atributo& s9) {
    string valor = s4.v;
    string lbl_case = gera_nome_label("case"+toString(nswitch)+valor);
    ss.c = " " + lbl_case + ":;\n" + s7.c + s8.c + s9.c +"\n";
    vetor_indice_cases.push_back(valor);

}

void gera_default(Atributo& ss, const Atributo& s3) {
    string lbl_default = gera_nome_label("default" + toString(nswitch));
    ss.c = " " + lbl_default + ":;\n" + s3.c + "\n";


}

void gera_codigo_atomico(Atributo& ss,const Atributo& s1, const Atributo& s2){
	string aux;
	if(s1.t.nome==String.nome||s1.t.nome==Char.nome){
		erro("Operação não permitida para esse tipo");
	}
	else{
		aux=gera_nome_var(s1.t);
		ss.c= "  " + aux + " = " + s1.v + ";\n";
		ss.c= ss.c + "  " + s1.v + " = " + aux + " + 1; \n";
	}
}

void gera_codigo_funcao(Atributo& ss,const Atributo& s1, const Atributo& s4, const Atributo& s7, const Atributo& s10, const Atributo& s11) {


    string temp = "" + s4.v;
    std::pair<std::map<string,vector<string>>::iterator,bool> ret;
    ret = funcoes.insert(std::pair<string, vector<string>> (temp,atributos_funcao));
    atributos_funcao.clear();
    if(ret.second==false){
        erro("Funcao já declarada");
    }

    if((s1.t.nome == s11.t.nome) || (s1.t.nome == "void" && s11.c == "" ) ) {
        ss.c = s1.t.decl + " " + s4.v + " (" + s7.c + "){\n  " + declara_var_temp(temp_local) + "  " + s10.c + s11.c + "}\n";
    }
    else erro("Retorno invalido");
}

void calcula_matrix( Atributo& ss, const Atributo& s1, const Atributo& s3, const Atributo& s6 ){
	string aux1, aux2;
	if(ts.find( s1.v ) == ts.end())
    	erro( "Variável não declarada: " + s1.v);
    	if((ts[s1.v].dim[0]-1)<toInt(s3.v)){
      	erro("Acesso indevido ao Array\n");
    	}
    	ss.t=ts[s1.v];
    	aux1=gera_nome_var( ss.t );
    	ss.c="  "+aux1+" = "+ s3.v + '*' + toString(ts[s1.v].dim[1])+";\n";
    	aux2=gera_nome_var( ss.t );
    	ss.c=ss.c+"  "+aux2+ " = "+ aux1 +'+'+ s6.v+";\n";
    	ss.c =s1.c + s3.c +ss.c + "\n"; 
    	ss.v= s1.v + '[' + aux2 + ']';
}

int gera_codigo_final(string codigo){
  FILE* arq;

  arq=fopen("gerado.cc","w");
  fprintf(arq, "%s",codigo.c_str());
  fclose(arq);
  return 0;
}

void gera_input(Atributo& ss, const Atributo& s3){
    if(s3.t.nome == "string"){
        ss.c = "  scanf(\"%" +s3.t.fmt + "\", " + s3.v + ");\n" ;
    }
    else{
        ss.c = "  scanf(\"%" +s3.t.fmt + "\", &" + s3.v + ");\n" ;
    }
}

void gera_chamada(Atributo& ss, const Atributo& s1, const Atributo& s3) {
    std::map<string,vector<string>>::iterator item = funcoes.find(s1.v);
    if(item != funcoes.end()){
        if(atributos_funcao.size() == item->second.size()){
            for(int i = 0; i < atributos_funcao.size(); i++){
                    if(atributos_funcao[i] != item->second[item->second.size()-1 - i]) erro("Tipo incompatível");
                }
        }
        else{
            erro("Numero de parametros inadequados");
        }
    }
    else{
        erro("Função não declarada");
    }




    ss.c = s1.v + "(" + s3.v + ");\n" ;
}

void gera_relacionais(Atributo& ss, const Atributo& s1, const Atributo& s2, const Atributo& s3) {

}
void gera_chamada_string(Atributo& ss, const Atributo& s1, const Atributo& s2){
    atributos_funcao.push_back(s1.t.nome);
        if(s1.t.nome == String.nome){
            ss.c =s1.t.decl + " " + s2.v + "["+toString(256)+"]" ;
        }
        else{
            ss.c= s1.t.decl + " " + s2.v;
        }
}
void gera_chamada_string2(Atributo& ss, const Atributo& s1, const Atributo& s2, const Atributo& s4){
    atributos_funcao.push_back(s1.t.nome);
        if(s1.t.nome == String.nome){
            ss.c =s1.t.decl + " " + s2.v + "["+toString(256)+"]" +" , "+s4.c; ;
        }
        else{
            ss.c= s1.t.decl + " " + s2.v+" , "+s4.c;
        }
}


%}

%token TK_ID TK_CINT TK_CDOUBLE TK_INT TK_DOUBLE TK_CHAR TK_BOOL TK_VOID
%token TK_PRINT TK_CSTRING TK_STRING TK_INPUT TK_END TK_BEGINALL TK_ENDALL
%token TK_MAIG TK_MEIG TK_IG TK_DIF TK_IF TK_ELSE TK_AND TK_OR
%token TK_FOR TK_DO TK_WHILE TK_MAIN TK_PLUSPLUS TK_FUNCTION TK_MINUSMINUS
%token TK_SWITCH TK_CASE TK_DEFAULT TK_BREAK TK_RETURN

%left TK_AND TK_OR
%nonassoc '<' '>' TK_MAIG TK_MEIG '=' TK_DIF TK_IG
%left '+' '-'
%left '*' '/' '%' TK_MOD

%start S

%%

S : MIOLOS  ABRE PRINCIPAL FECHA
  { cout << gera_codigo_final( "#include <iostream>\n"
                "#include <string>\n"
                "\n"
                 "using namespace std;\n\n"+ declara_var_temp( temp_global ) + "int var_aux_switch;\n" + $1.c +"int main (){\n" +$3.c+"}")<<endl;
  }
  ;

ABRE : TK_BEGINALL
     ;
FECHA: TK_ENDALL
     ;
   
MIOLOS : MIOLO MIOLOS {$$.c = $1.c + $2.c;}
       | {$$.c="";}
       ;
       
MIOLO : DECL 		{$$=$1;}
      | FUNCTION 	{$$=$1;}
      ;     

FUNC: FUNC_DECLS CMDS  {$$.c=$1.c + $2.c;}
    ;

FUNC_DECLS: FUNC_DECLS DECL {$$.c = $1.c + $2.c; }
          | {$$.c = "";}
          ;

MAIN_DECLS: MAIN_DECLS DECL {$$.c = $1.c + $2.c;}
          | {$$.c = "";}
          ;

DECL: TIPO ID ';'               
		{ declara_variavel( $$, $1, $2,"" );}
    | TIPO ID '[' TK_CINT ']''[' TK_CINT ']'  ';'
    { declara_variavel( $$, $1, $2,'['+toString(toInt($4.v) *toInt($7.v))+']'); gera2Dim($2, $4, $7); }
    | TIPO ID '[' TK_CINT ']' ';'
    { declara_variavel( $$, $1, $2,'['+$4.v+']'); gera1Dim($2, $4);}
    ;

TIPO: TK_INT      { $$.t = Integer; }
    | TK_DOUBLE   { $$.t = Double; }
    | TK_CHAR     { $$.t = Char; }
    | TK_STRING   { $$.t = String; }
    ;

TIPO_FUNC: TK_INT      { $$.t = Integer; }
    | TK_DOUBLE   { $$.t = Double; }
    | TK_CHAR     { $$.t = Char; }
    | TK_STRING   { $$.t = String; }
    | TK_VOID     {$$.t = Void;}

    ;

ID: ID ',' TK_ID { $$.lst = $1.lst; $$.lst.push_back( $3.v ); }
  | TK_ID  { $$.lst.push_back( $1.v ); }
  ;

FUNCTION: TIPO_FUNC '<' TK_FUNCTION TK_ID {escopo_local=true; tsl.clear(); atributos_funcao.clear(); }'(' ARGS ')' '>' FUNC RETURN TK_END TK_FUNCTION '>'
				{gera_codigo_funcao($$,$1, $4,$7,$10, $11);	escopo_local=false; tsl.clear(); }
;
RETURN : TK_RETURN E ';' {$$.c = " return " + $2.v + ";\n"; $$.t = $2.t;};
          | TK_RETURN ';' {$$.c = " return;\n";};
          | {$$.c = "";}
          ;

ARGS: IDS {$$=$1;}
    |  		{$$.c="";}
    ;
     
IDS : TIPO TK_ID ',' IDS 	{gera_chamada_string2($$,$1,$2,$4);}
    | TIPO TK_ID 					{gera_chamada_string($$,$1,$2);}
    ;      
   
PRINCIPAL : MAIN_DECLS CMDS {$$.c=$1.c+$2.c;}
          ;
          
CMDS : CMD  CMDS {$$.c=$1.c+$2.c;}
     | {$$.c="";}
     ;                   
 
CMD : SAIDA';'     		{$$=$1;}
    | CMD_IF       		{$$=$1;}
    | CMD_FOR      		{$$=$1;}
    | CMD_ATRIB';'    {$$=$1;}
    | CMD_ATOM';' 		{$$=$1;}
    | CMD_INPUT';'		{$$=$1;}
    | CMD_FUNC';'       {$$=$1;}
    | CMD_WHILE     {$$=$1;}
    | CMD_DOWHILE   {$$=$1;}
    | CMD_SWITCH    {$$=$1;}
    | DECL
    ;
    
CMD_ATRIB : LVALUE '=' E 								{gera_codigo_atribuicao($$, $1, $3); }
          | LVALUE '['E']''['E']' '=' E {gera_codigo_matrix($$,$1,$3,$6, $9);}
          | LVALUE '['E']' '=' E 				{gera_codigo_vetor($$,$1,$3,$6);}
          ;  

CMD_ATOM: LVALUE TK_PLUSPLUS   {gera_codigo_atomico($$,$1,$2);}
        | LVALUE TK_MINUSMINUS {gera_codigo_atomico($$,$1,$2);}
        ;

LVALUE: TK_ID { busca_tipo_da_variavel( $$, $1 ); }
      ;
    
CMD_FOR : '<'TK_FOR '('CMD_ATRIB';' E ';' CMD_ATOM ')''>' CMDS TK_END TK_FOR'>' {gera_cmd_for($$,$4,$6,$8,$11);}
        | '<'TK_FOR '('CMD_ATRIB';' E ';' CMD_ATRIB ')''>' CMDS TK_END TK_FOR'>' {gera_cmd_for($$,$4,$6,$8,$11);}
        ;    

CMD_INPUT : TK_INPUT '(' LVALUE ')'		{ gera_input( $$, $3);}
            ;

CMD_FUNC : TK_ID {atributos_funcao.clear();} '(' CHAMADAS_MULT ')' {gera_chamada($$, $1, $4); }
         ;

CHAMADAS_MULT : CHAMADA_MULT ',' CHAMADAS_MULT {$$.v = $1.v + ","+ $3.v;}
                | CHAMADA_MULT {$$ = $1;};
                |{$$.v = "";};
CHAMADA_MULT: E {atributos_funcao.push_back($1.t.nome); $$ = $1;  };


CMD_IF : '<'TK_IF '('E')' '>' CMDS TK_END TK_IF '>'             {gera_cmd_if( $$, $4, $7, "");}
       | '<'TK_IF '('E')' '>' CMDS TK_ELSE CMDS  TK_END TK_IF '>' {gera_cmd_if( $$, $4, $7, $9.c);}
       ;

CMD_WHILE : '<'TK_WHILE '(' E ')' '>' CMDS TK_END TK_WHILE'>'  {gera_cmd_while($$, $4, $7);}
          ;

CMD_DOWHILE : '<' TK_DO '>' CMDS TK_END TK_WHILE '(' E ')' '>' {gera_cmd_dowhile($$, $4, $8);}
            ;

CMD_SWITCH : '<' TK_SWITCH '(' E ')' '>'  BLOCO_SWITCH TK_END TK_SWITCH '>' {gera_cmd_switch($$, $4, $7);};



BLOCO_SWITCH : CASES DEFAULT {$$.c = $1.c + $2.c;};
    ;

CASES : CASE CASES {$$.c = $1.c + $2.c;};
      | {$$.c = "";}
      ;
CASE:'<'TK_CASE '(' E ')' '>' CMDS BREAK CMDS TK_END TK_CASE '>' {gera_case($$, $4, $7, $8, $9);};

DEFAULT: TK_DEFAULT '>' CMDS TK_END TK_DEFAULT '>' {gera_default($$, $3);};
        |{$$.c = " " + gera_nome_label("default" + toString(nswitch)) + ":;\n";};
        ;

BREAK: TK_BREAK ';' {$$.c = " goto L_fim_switch" + toString(nswitch)+"_1;\n";};
       | {$$.c = "";};


SAIDA : TK_PRINT '(' F ')'        { $$.c = $3.c + "  cout << " + $3.v + ";\n"
                                                    "  cout << endl;\n";
                                           }
      ;
   
E : E '+' E     		 { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E '-' E     		 { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E '*' E     		 { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E '/' E    			 { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E '%' E     	   { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E '>' E     		 { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E '<' E     		 { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E TK_IG E   { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E TK_DIF E   { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E TK_MAIG E  { gera_codigo_operador( $$, $1, $2, $3 ); }
  | E TK_MEIG E  { gera_codigo_operador( $$, $1, $2, $3 ); }
  | F
  ;
  
F : TK_CSTRING   		 { $$ = $1; $$.t = String; }
  | TK_CINT  		 { $$ = $1; $$.t = Integer; }
  | TK_CDOUBLE  		 { $$ = $1; $$.t = Double; }
  | TK_ID           		 { busca_tipo_da_variavel( $$, $1 );  }
  | TK_ID '['E']''['E']' { calcula_matrix( $$, $1, $3, $6 );  }
  | TK_ID '['E']'        { $$.v = $1.v + "[" +$3.v +"]"+";\n";  }
  | '('E')'       		 { $$ = $2; }
  |
  ;     
 
%%

#include "lex.yy.c"

void inicializa_tabela_de_resultado_de_operacoes() {
  map< string, Tipo > r;
  
  // OBS: a ordem é muito importante!!  
  r[par(Integer, Integer)] = Integer;    
  tro[ "%" ] = r;

  r[par(Integer, Integer)] = Integer;
  r[par(Double, Integer)] = Double;
  r[par(Integer, Double)] = Double;
  r[par(Double, Double)] = Double;    

  tro[ "-" ] = r; 
  tro[ "*" ] = r; 
  tro[ "/" ] = r; 

  r[par(Char, Char)] = String;      
  r[par(String, Char)] = String;      
  r[par(Char, String)] = String;    
  r[par(String, String)] = String;    
  tro[ "+" ] = r; 
  
  r.clear();
  r[par(Integer, Integer)] = Integer;
  r[par(Double, Double)] = Integer;
  r[par(Char, Char)] = Integer;
  r[par(String, String)] = Integer;
  r[par(Boolean, Boolean)] = Integer;
  tro["=="] = r;
  tro["!="] = r;
  tro[">="] = r;
  tro[">"] = r;
  tro["<"] = r;
  tro["<="] = r;
}

void erro( string st ) {
  yyerror( st.c_str() );
  exit( 1 );
}

void yyerror( const char* st )
{
   if( strlen( yytext ) == 0 )
     printf( "%s\nNo final do arquivo\n", st );
   else  
     printf( "%s\nProximo a: %s\nlinha/coluna: %d/%d\n", st, 
             yytext, yylineno, yyrowno - (int) strlen( yytext ) );
}

int main( int argc, char* argv[] )
{
  String.dim.push_back(255);
  inicializa_tabela_de_resultado_de_operacoes();
  yyparse();
}

