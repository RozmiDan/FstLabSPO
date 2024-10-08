#include <stdio.h>
#include <antlr3.h>
#include "MyGrammarTestLexer.h"
#include "MyGrammarTestParser.h"

int main(int argc, char *argv[]) {
    
    //START WORKING WITH FILE
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    //get the size of file
    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    char* file_content = malloc(file_size + 1);
    size_t j = fread(file_content, 1, file_size, file);
    if(j);
    file_content[file_size] = '\0'; 
    fclose(file);
    //END WORKING WITH FILE

    //START WORKING WITH ANTLR
    pANTLR3_INPUT_STREAM           input;
    pMyGrammarTestLexer            lex;
    pANTLR3_COMMON_TOKEN_STREAM    tokens;
    pMyGrammarTestParser           parser;

    input = antlr3FileStreamNew((pANTLR3_UINT8)argv[1], ANTLR3_ENC_UTF8);
    lex = MyGrammarTestLexerNew(input);
    tokens = antlr3CommonTokenStreamSourceNew(ANTLR3_SIZE_HINT, TOKENSOURCE(lex));
    parser = MyGrammarTestParserNew(tokens);

    // Запускаем парсер (например, mainRule — это правило, описанное в грамматике)
    //parser->mainRule(parser);
    //END WORKING WITH ANTLR

    tokens->free(tokens);
    lex->free(lex);
    input->close(input);
    free(file_content);

    return 0;
}