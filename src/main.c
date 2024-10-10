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

    pANTLR3_INPUT_STREAM input = antlr3FileStreamNew((pANTLR3_UINT8)argv[1], ANTLR3_ENC_UTF8);
    pMyGrammarTestLexer lex = MyGrammarTestLexerNew(input);
    pANTLR3_COMMON_TOKEN_STREAM tokens = antlr3CommonTokenStreamSourceNew(ANTLR3_SIZE_HINT, TOKENSOURCE(lex));
    pMyGrammarTestParser parser = MyGrammarTestParserNew(tokens);

    parser->adaptor = antlr3CommonTreeAdaptorNew(); // TODO

    parser->pParser->rec->displayRecognitionError = ANTLR3_TRUE; // Включаем отображение ошибок

    if (parser == NULL) {
        printf("Parser initialization failed.\n");
        return 1; 
    }

    MyGrammarTestParser_source_return result = parser->source(parser);

    if (result.tree == NULL) {
        printf("Tree was not generated.\n");
        return 1; 
    }


    // if (parser->pParser->rec->state->errorCount > 0) {
    //     printf("Parsing failed: %d errors.\n", parser->pParser->rec->state->errorCount);
    // } else {
    //     pANTLR3_BASE_TREE tree = result.tree;
    //     // Выводим дерево разбора, если оно было сгенерировано
    //     if (tree != NULL) {
    //         printf("Tree: %s\n", tree->toStringTree(tree)->chars);
    //     } else {
    //         printf("No tree generated.\n");
    //     }
    // }
    
    if (parser->pParser->rec->state->errorCount > 0) {
        printf("Parsing failed: %d errors.\n", parser->pParser->rec->state->errorCount);
    } else {
        pANTLR3_BASE_TREE tree = result.tree;
        // Выводим дерево разбора, если оно было сгенерировано
        if (parser->adaptor != NULL && tree != NULL) {
            FILE *dotFile = fopen("parsetree.dot", "w");
            if (dotFile != NULL) {
                // Генерируем граф в формате Dot
                printf("Access\n");
                parser->adaptor->makeDot(tree, dotFile);
                fclose(dotFile);
                printf("Dot file generated: parsetree.dot\n");
            } else {
                printf("Failed to create dot file.\n");
            }
        } else {
            printf("Failed to (parser->adaptor != NULL && tree != NULL)\n");
        }
    }

    //END WORKING WITH ANTLR

    tokens->free(tokens);
    lex->free(lex);
    input->close(input);
    free(file_content);

    return 0;
}