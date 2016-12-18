%{
int yyrowno = 1;
int yylineno = 0;
void trata_folha();
void trata_aspas_simples();
%}
WS      [\t ]
DIGITO  [0-9]
LETRA   [A-Za-z_]
ID      {LETRA}({LETRA}|{DIGITO})*

END         <fim
ENDALL        <fimtudo>
BEGINALL      <comecatudo>

INT		    int
DOUBLE		double
CHAR		char
STRING		string
VOID        void
IF		    si
ELSE		"<"sinão">"
FOR		    para
FUNCTION	funcao
PRINT		escrevi
INPUT       le

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
{VOID}      { trata_folha(); return TK_VOID; }
{IF} 		{ trata_folha(); return TK_IF; }
{ELSE} 		{ trata_folha(); return TK_ELSE; }
{FOR} 		{ trata_folha(); return TK_FOR; }
{FUNCTION}  { trata_folha(); return TK_FUNCTION; }
{PRINT}		{ trata_folha(); return TK_PRINT; }
{INPUT}		{ trata_folha(); return TK_INPUT; }

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

