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
"String"      { yylval = Atributos( yytext ); return TK_STRING; }
"System.out.print"  { yylval = Atributos( yytext ); return TK_SYSO; }
"if"       { yylval = Atributos( yytext ); return TK_IF; }
"else"     { yylval = Atributos( yytext ); return TK_ELSE; }
"for"      { yylval = Atributos( yytext ); return TK_FOR; }
"do-while"       { yylval = Atributos( yytext ); return TK_DO;}
"switch"       { yylval = Atributos( yytext ); return TK_DO; }
"while"       { yylval = Atributos( yytext ); return TK_WHILE; }

"static void main"      { yylval = Atributos( yytext ); return TK_MAIN; }



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