%{
int yyrowno = 1;
int yylineno = 1;
void trata_folha();
void trata_aspas_simples();
%}
WS      [\t ]
DIGITO  [0-9]
LETRA   [A-Za-z_]
ID      {LETRA}({LETRA}|{DIGITO})*

END           <fim
ENDALL        <fimtudo>
BEGINALL      <comecatudo>

INT		    int
DOUBLE		double
CHAR		char
STRING		string
VOID        void
BOOL        bool
IF		    si
ELSE		"<"sinão">"
FOR		    para
DEFAULT		padrao
BREAK       quebra
FUNCTION	funcao
PRINT		escrevi
INPUT       le
WHILE       enquanto
DO          faca
SWITCH      interruptor
CASE        caso
RETURN      retorna

CSTRING	"\""([^"\n]|"''")*"\""
CDOUBLE	({DIGITO}+)"."{DIGITO}+
CINT {DIGITO}+

%%
"\n" { yylineno++; yyrowno = 1; }
{WS} { yyrowno += 1; }

{END}       { trata_folha(); return TK_END; }
{ENDALL}       { trata_folha(); return TK_ENDALL; }
{BEGINALL}       { trata_folha(); return TK_BEGINALL; }


{INT}		{ trata_folha(); return TK_INT; }
{DOUBLE}	{ trata_folha(); return TK_DOUBLE; }
{CHAR}		{ trata_folha(); return TK_CHAR; }
{STRING} 	{ trata_folha(); return TK_STRING; }
{BOOL}      { trata_folha(); return TK_BOOL; }
{VOID}      { trata_folha(); return TK_VOID; }
{IF} 		{ trata_folha(); return TK_IF; }
{ELSE} 		{ trata_folha(); return TK_ELSE; }
{FOR} 		{ trata_folha(); return TK_FOR; }
{WHILE}     { trata_folha(); return TK_WHILE; }
{DO}        { trata_folha(); return TK_DO; }
{SWITCH}    { trata_folha(); return TK_SWITCH; }
{CASE}      { trata_folha(); return TK_CASE; }
{FUNCTION}  { trata_folha(); return TK_FUNCTION; }
{PRINT}		{ trata_folha(); return TK_PRINT; }
{INPUT}		{ trata_folha(); return TK_INPUT; }
{DEFAULT}	{ trata_folha(); return TK_DEFAULT; }
{BREAK}	    { trata_folha(); return TK_BREAK; }
{RETURN}    { trata_folha(); return TK_RETURN; }



{CSTRING} 	{ trata_aspas_simples(); return TK_CSTRING; }
{CINT} 	{ trata_folha(); return TK_CINT; }
{CDOUBLE} 	{ trata_folha(); return TK_CDOUBLE; }

{ID}  		{ trata_folha(); return TK_ID; }

"=="		{ trata_folha(); return TK_IG; }
"++"		{ trata_folha(); return TK_PLUSPLUS; }
"--"		{ trata_folha(); return TK_MINUSMINUS; }
"!="		{ trata_folha(); return TK_DIF; }
">="		{ trata_folha(); return TK_MAIG; }
"<="		{ trata_folha(); return TK_MEIG; }
"&&"		{ trata_folha(); return TK_AND; }
"||"		{ trata_folha(); return TK_OR; }



.    		{ trata_folha(); return yytext[0]; }

%%

void trata_folha() {
  yylval.v = yytext;
  yylval.t.nome = "";
  yylval.t.decl = "";
  yylval.t.fmt = "";
  yylval.c = "";
  yylval.lst.clear();
  
  yyrowno += strlen( yytext ); 
}

void trata_aspas_simples() {
  trata_folha(); 
  yylval.v = "\"" + yylval.v.substr( 1, yylval.v.length()-2 ) + "\""; 
}

