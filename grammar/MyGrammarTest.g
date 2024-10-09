grammar MyGrammarTest;


options
{
    language = C;
    output=AST;
    backtrack=true;
}


// L e x e r 

BOOL_LITERAL : 'true' | 'false' ;
IDENTIFIER : ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ;
STRING_LIT : '"' ( ESC_SEQ | ~('\\'|'"') )* '"';
fragment ESC_SEQ : '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\') ;
CHAR : '\'' (ESC_SEQ | ~('\'')) '\'' ;
HEX_LITERAL : '0' ('x'|'X') HEX_DIGIT+ ;
fragment HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;
BITS_LITERAL : '0' ('b'|'B') ('0'|'1')+ ;
DEC_LITERAL : ('0'..'9')+ ;
WS  :   ( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;} ;
LINE_COMMENT : '//' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;} ;


// P a r s e r  p a r t

list_identifier: (IDENTIFIER (',' IDENTIFIER)*)? ;

list_item : (item (',' item)*)? ;
fragment item : (BOOL_LITERAL | CHAR | STRING_LIT | HEX_LITERAL | BITS_LITERAL | DEC_LITERAL) ;

source : sourceItem* ;

sourceItem : funcDef ;
fragment funcDef : 'method' funcSignature ( body | ';' );
fragment body : ( 'var' ( list_identifier (':' typeRef)? ';' )* )? blockStatement ; // TODO

typeRef : (builtin | custom | array);
fragment builtin : ('bool' | 'byte' | 'int' | 'uint' | 'long' | 'ulong' | 'char' | 'string');
fragment custom : IDENTIFIER ;
fragment array : 'array' '[' (',')* ']' 'of' typeRef;

funcSignature : IDENTIFIER '(' list_argDef ')' (':' typeRef)? ;     // question about priority of
fragment list_argDef : (argDef (',' argDef)*)? ;		    // list CAREFULL!!
fragment argDef : IDENTIFIER (':' typeRef)? ;


// S t a t e m e n t s

statement : ( ifStatement | blockStatement | whileStatement | doStatement
    | breakStatement | expressionStatement ) ;

ifStatement : 'if' expr 'then' statement ('else' statement)? ;

blockStatement : 'begin' statement* 'end' ';' ;

whileStatement : 'while' expr 'do' statement ;

doStatement : 'repeat' statement ('while'|'until') expr ';' ;

breakStatement : 'break' ';' ;

expressionStatement : expr ';' ;


// E x p r e s s i o n s


expr : assignExpr ;

fragment assignExpr : binaryExpr ('+=' | ':=') binaryExpr  | binaryExpr;

fragment binaryExpr : additiveExpr ;

fragment additiveExpr : multiplicativeExpr ('+' | '-') multiplicativeExpr  | multiplicativeExpr ;

fragment multiplicativeExpr : unaryExpr ('*' | '/' | '%') unaryExpr | unaryExpr ;

fragment unaryExpr : unOp unaryExpr | primaryExpr ;

fragment primaryExpr
    : literal                            
    | IDENTIFIER                         
    | '(' expr ')'                        
    | call                               
    | indexer                            
    ;

call : IDENTIFIER '(' list_expr ')' ;

fragment indexer : IDENTIFIER '[' list_expr ']' ;

fragment literal : BOOL_LITERAL | STRING_LIT | CHAR | HEX_LITERAL | BITS_LITERAL | DEC_LITERAL ;

list_expr : (expr (',' expr)*)? ;

unOp : ('-' | '!' ) ;