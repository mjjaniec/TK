CXX= g++
CXXFLAGS=-g -Wall -std=c++11  -Wno-write-strings -Wno-unused-function
LOADLIBES=-lfl

LEX=flex
LFLAGS= 

YACC= bison 
YFLAGS=-d -o y.tab.c


all: janiec_bylica clean
janiec_bylica:janiec_bylica.tab.cpp janiec_bylica.yy.cpp
	${CXX}  ${CXXFLAGS} -o $@ $^ ${LOADLIBES}
janiec_bylica.tab.cpp: janiec_bylica.y
	${YACC} ${YFLAGS} -o  $@ $^ 
janiec_bylica.yy.cpp: janiec_bylica.l
	${LEX} ${LFLAGS} -o $@ $^
clean:; rm -f *~ *tab* *yy* 

.PHONY: all clean

