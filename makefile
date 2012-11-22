CXX= g++
CXXFLAGS=-g -Wall -std=c++11  -Wno-write-strings -Wno-unused-function
LOADLIBES=-lfl

LEX=flex
LFLAGS=-d

YACC= bison 
YFLAGS=-d --debug


all: save_all clean janiec_bylica run
janiec_bylica:janiec_bylica.tab.cpp janiec_bylica.yy.cpp
	${CXX}  ${CXXFLAGS} -o $@ $^ ${LOADLIBES}
janiec_bylica.tab.cpp: janiec_bylica.y
	${YACC} ${YFLAGS} -o  $@ $^ 
janiec_bylica.yy.cpp: janiec_bylica.l
	${LEX} ${LFLAGS} -o $@ $^

clean:; rm -f *~ *tab* *yy* janiec_bylica out*
run:;   ./janiec_bylica < in1.c 1>out1.c 2>/dev/null && cat out1.c

#Allways do 30 pushups as the punishment for using FUCKING sleep!
save_all:;if [ "`who | grep janiec`" ] ; echo "\nlOOSER! He use sleep!\n"; then xdotool key ctrl+alt+shift+S; sleep 0.2; fi

.PHONY: all clean run save_all

  