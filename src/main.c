#include <stdio.h>
#include <stdlib.h>
#include "myParser.h"

void writeTreeAsDot(AstNode* node, FILE* file, int* nodeCounter) {
    if (node == NULL) {
        return;
    }

    int currentNodeId = (*nodeCounter)++;

    fprintf(file, "  node%d [label=\"%s\"];\n", currentNodeId, node->nodeName);
    
    for (int i = 0; i < node->childrenCount; i++) {
        int childNodeId = *nodeCounter;
        writeTreeAsDot(&node->children[i], file, nodeCounter);
        fprintf(file, "  node%d -> node%d;\n", currentNodeId, childNodeId);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <input_file> <output_dot_file>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    ParseResult result = parseString(argv[1]);

    if (result.tree != NULL) {
        printf("Tree generated successfully.\n");

        // Создаем Dot файл
        FILE *dotFile = fopen(argv[2], "w");
        if (dotFile != NULL) {
            fprintf(dotFile, "digraph ParseTree {\n");
            fprintf(dotFile, "  node [shape=box];\n");
            int nodeCounter = 0;
            writeTreeAsDot(result.tree, dotFile, &nodeCounter); 
            fprintf(dotFile, "}\n");
            fclose(dotFile);
            printf("Dot file generated: %s\n", argv[2]);
        } else {
            printf("Failed to create dot file.\n");
        }
    } else {
        printf("Failed to generate tree.\n");
    }

    if (result.firstError != NULL) {
        ErrorInfo *error = result.firstError;
        while (error != NULL) {
            printf("Error: %s\n", error->message);
            error = error->next;
        }
    }

    freeParseResult(&result);

    return 0;
}