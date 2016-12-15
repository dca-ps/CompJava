all: trabalho entrada.java
	trabalho.exe < entrada.java > gerado.cc
#	gabarito.exe < gerado.cc
#	g++ -o saida gerado.cc
#	saida.exe

lex.yy.c: trabalho.lex
	flex trabalho.lex

y.tab.c: trabalho.y
	bison -dy trabalho.y

trabalho: lex.yy.c y.tab.c
	g++ -std=gnu++11 -o trabalho y.tab.c -L"C:\GnuWin32\lib" -lfl
