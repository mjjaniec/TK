CXX= g++
CXXFLAGS=-g -Wall -std=c++11  -Wno-write-strings -Wno-unused-function
LOADLIBES=-lfl

LEX=flex
LFLAGS=

YACC= bison 
YFLAGS=-d --debug




all:  janiec_bylica run
janiec_bylica:janiec_bylica.tab.cpp janiec_bylica.yy.cpp
	${CXX}  ${CXXFLAGS} -o $@ $^ ${LOADLIBES}
janiec_bylica.tab.cpp: janiec_bylica.y
	${YACC} ${YFLAGS} -o  $@ $^ 
janiec_bylica.yy.cpp: janiec_bylica.l
	${LEX} ${LFLAGS} -o $@ $^

clean:; rm -f *~ *tab* *yy* janiec_bylica out*
run:;   ./janiec_bylica < in1.c

.PHONY: all clean run save_all

  