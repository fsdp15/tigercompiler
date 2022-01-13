all:
	bison -d tiger.y
	flex tiger.l
	gcc tiger.tab.c lex.yy.c -o tc-- -DECHO -lfl
	rm lex.yy.c tiger.tab.c tiger.tab.h
clean:
	rm tc--