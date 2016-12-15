all: trabalho entrada.pas
	./trabalho < entrada.pas > gerado.cc
	./gabarito < gerado.cc
	g++ -o saida gerado.cc
	./saida

lex.yy.c: trabalho.lex
	flex trabalho.lex

y.tab.c: trabalho.y
	bison -dy trabalho.y

trabalho: lex.yy.c y.tab.c
	g++ -std=gnu++11 -o trabalho y.tab.c -lfl
