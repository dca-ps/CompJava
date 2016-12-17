%{

char* troca_aspas( char* lexema );

%}

DELIM   [\t ]
LINHA   [\n]
NUMERO  [0-9]
LETRA   [A-Za-z_]
INT     {NUMERO}+
DOUBLE  {NUMERO}+("."{NUMERO}+)?
ID      {LETRA}({LETRA}|{NUMERO})*
CSTRING """([^\n']|"''")*"""

COMMENT "(*"([^*]|"*"[^)])*"*)"

%%

{LINHA}    { nlinha++; }
{DELIM}    {}
{COMMENT}  {}

"int"      { yylval = Atributos( yytext ); return TK_INT; }
"double"      { yylval = Atributos( yytext ); return TK_DOUBLE; }
"char"      { yylval = Atributos( yytext ); return TK_CHAR; }
"boolean"      { yylval = Atributos( yytext ); return TK_BOOL; }
"string"      { yylval = Atributos( yytext ); return TK_STRING; }
"imprimi"  { yylval = Atributos( yytext ); return TK_PRINT; }
"si"       { yylval = Atributos( yytext ); return TK_IF; }
"sinao"     { yylval = Atributos( yytext ); return TK_ELSE; }
"para"      { yylval = Atributos( yytext ); return TK_FOR; }
"facanto"       { yylval = Atributos( yytext ); return TK_DO;}
"interruptor"       { yylval = Atributos( yytext ); return TK_SWITCH; }
"enquanto"       { yylval = Atributos( yytext ); return TK_WHILE; }

"principal"      { yylval = Atributos( yytext ); return TK_MAIN; }



"<="       { yylval = Atributos( yytext ); return TK_MEIG; }
"=="       { yylval = Atributos( yytext ); return TK_IG; }
">="       { yylval = Atributos( yytext ); return TK_MAIG; }
"!="       { yylval = Atributos( yytext ); return TK_DIF; }
"&&"       { yylval = Atributos( yytext ); return TK_AND; }
"||"       { yylval = Atributos( yytext ); return TK_OR; }



{CSTRING}  { yylval = Atributos( troca_aspas( yytext ), Tipo( "string" ) ); 
             return TK_CSTRING; }
{ID}       { yylval = Atributos( yytext ); return TK_ID; }
{INT}      { yylval = Atributos( yytext, Tipo( "int" ) ); return TK_CINT; }
{DOUBLE}   { yylval = Atributos( yytext, Tipo( "double" ) ); return TK_CDOUBLE; }
.           { yylval = Atributos( yytext ); return *yytext; }

%%

char* troca_aspas( char* lexema ) {
  int n = strlen( lexema );
  lexema[0] = '"';
  lexema[n-1] = '"';
  
  return lexema;
}