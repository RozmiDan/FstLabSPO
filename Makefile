TARGET = FstLabSpo 
CC = gcc

#LDFLAGS= -Lantlr -lMyGrammarTestParser
CFLAGS = -I/usr/local/include -Wall -O2
LDFLAGS = -L/lib/x86_64-linux-gnu -lantlr3c 

PREF_SRC = ./src/
PREF_OBJ = ./obj/

SRC = $(wildcard $(PREF_SRC)*.c)
OBJ = $(patsubst $(PREF_SRC)%.c, $(PREF_OBJ)%.o, $(SRC))


$(TARGET) : $(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o $(TARGET)

$(PREF_OBJ)%.o : $(PREF_SRC)%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean: 
	rm $(TARGET) $(PREF_OBJ)*.o
	rm -f *.dot
distclean:
	rm -f ./src/MyGrammarTestLexer.c ./src/MyGrammarTestLexer.h ./src/MyGrammarTestParser.c ./src/MyGrammarTestParser.h
	rm -f ./src/MyGrammarTest.tokens
