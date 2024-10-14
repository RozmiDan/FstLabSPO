#ifndef MYPARSE_H
#define MYPARSE_H

// Структура для хранения результата разбора
typedef struct AstNode {
    struct AstNode* children;
    char* nodeName;
    int childrenCount;
} AstNode;

typedef struct ErrorInfo {
    struct ErrorInfo* next;
    char* message;
} ErrorInfo;

typedef struct {
    AstNode* tree;
    ErrorInfo* firstError;
    ErrorInfo* lastError;
} ParseResult;

ParseResult parseString(char* input);
void freeParseResult(ParseResult* result);

#endif // MYPARSE_H