grammar MyGrammarTest;

options
{
    language = C;
    output=AST;
}

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

list_item : (item (',' item)*)? ;
fragment item : (BOOL_LITERAL | CHAR | STRING_LIT | HEX_LITERAL | BITS_LITERAL | DEC_LITERAL) ;

typeRef : (builtin | custom);
fragment builtin : ('bool' | 'byte' | 'int' | 'uint' | 'long' | 'ulong' | 'char' | 'string');
fragment custom : IDENTIFIER ;
fragment array : 'array' '[' (',')* ']' 'of' typeRef;

funcSignature : IDENTIFIER '(' list_argDef ')' (':' typeRef)? ;
fragment list_argDef : (argDef (',' argDef)*)? ;
fragment argDef : IDENTIFIER (':' typeRef)? ;

