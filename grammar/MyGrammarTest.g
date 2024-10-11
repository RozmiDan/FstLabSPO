grammar MyGrammarTest;

options
{
    language = C;
    output=AST;
    backtrack=true;
}

tokens{
	Source;
    SourceItem;
	FuncDef;
	FuncSignature;
	TypeRef;
    Vars;
    BodySig;
    ListArgDefs;
    ListIdentifier;
    BuiltinType;
    CustomType;
    ArrayType;
    IfStatement;
    BlockStatement;
    WhileStatement;
    DoStatement;
    BreakStatement;
    ExpressionStatement;
    Expression;
	CallExpr;
    ListExpr;
    Braces;
    Indexer;
}

// P a r s e r  p a r t

source : sourceItem* -> ^(Source sourceItem*);

sourceItem : funcDef -> ^(SourceItem funcDef);
fragment funcDef : 'method' funcSignature ( body | ';' ) -> ^(FuncDef funcSignature body?);
fragment body : ( 'var' ( list_identifier (':' typeRef)? ';' )* )? blockStatement -> ^(BodySig 'var' ^(Vars list_identifier typeRef?)* blockStatement) ; 
list_identifier: (IDENTIFIER (',' IDENTIFIER)*)? -> ^(ListIdentifier IDENTIFIER*) ;

typeRef : builtin -> ^(BuiltinType builtin)
    | custom -> ^(CustomType custom)
    | array ;                             
fragment builtin : ('bool' | 'byte' | 'int' | 'uint' | 'long' | 'ulong' | 'char' | 'string');
fragment custom : IDENTIFIER ;
fragment array : 'array' '[' (',')* ']' 'of' typeRef -> ^(ArrayType 'array' typeRef) ;

funcSignature : IDENTIFIER '(' list_argDef ')' typeRefDef? -> ^(FuncSignature IDENTIFIER list_argDef typeRefDef?);     
fragment list_argDef : (argDef (',' argDef)*)? -> ^( ListArgDefs argDef*) ;		    
fragment argDef : IDENTIFIER typeRefDef? ;
fragment typeRefDef : ':' typeRef -> ^(TypeRef typeRef) ;

// S t a t e m e n t s

statement : 
      ifStatement -> ^(IfStatement ifStatement)
    | blockStatement -> ^(BlockStatement blockStatement)
    | whileStatement -> ^(WhileStatement whileStatement)
    | doStatement  -> ^(DoStatement doStatement)
    | breakStatement -> ^(BreakStatement breakStatement)
    | expressionStatement -> ^(ExpressionStatement expressionStatement);

ifStatement : 'if' expr 'then' statement ('else' statement)? ;

blockStatement : 'begin' statement* 'end' ';' ;

whileStatement : 'while' expr 'do' statement ;

doStatement : 'repeat' statement ('while'|'until') expr ';' ;

breakStatement : 'break' ';' ;

expressionStatement : expr ';' ;

// E x p r e s s i o n s

expr : assignExpr -> ^( Expression assignExpr ) ;

assignExpr : logicOrExpr ( ':='^ logicOrExpr )* ;

logicOrExpr : logicAndExpr ( '||'^ logicAndExpr )* ;

logicAndExpr : inclusOrExpr ( '&&'^ inclusOrExpr )* ;

inclusOrExpr : xorExpr ( '|'^ xorExpr )* ;

xorExpr : andExpr ( '^'^ andExpr )* ;

andExpr : equalExpr ( '&'^ equalExpr )* ;

equalExpr: relatExpr (( '!=' | '==' )^ relatExpr)* ;

relatExpr : shiftExpr ( ('<' | '>' | '<=' | '>=')^ shiftExpr)* ;

shiftExpr : addExpr (('<<' | '>>')^ addExpr)* ;

addExpr : multExpr (('+' | '-')^ multExpr)* ;

multExpr : unaryExpr ( ('*' | '/' | '%')^ unaryExpr)? ;

unaryExpr :  ('!'|'~')^ unaryExpr |  ('-'^ | '+'^)? primaryExpr ; 

primaryExpr :
     LITERAL  
    | IDENTIFIER                             
    | callExpr   
    | indexer
    | '(' expr ')' -> ^(Braces expr)                         
    ;

callExpr: IDENTIFIER '(' list_expr ')' -> ^(CallExpr IDENTIFIER list_expr) ;

indexer: IDENTIFIER '[' list_expr ']' -> ^(Indexer IDENTIFIER list_expr) ;

list_expr : (expr (',' expr)*)? -> ^(ListExpr expr*) ;

// L e x e r 

LITERAL
  :  BOOL_LITERAL
  |  BITS_LITERAL
  |  HEX_LITERAL
  |  DEC_LITERAL
  |  CHAR
  |  STRING_LIT
  ;

fragment BOOL_LITERAL : ( 'true' | 'false' );
fragment BITS_LITERAL : '0' ('b'|'B') ('0'|'1')+ ;
fragment HEX_LITERAL : '0' ('x'|'X') HEX_DIGIT+ ;
fragment HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;
fragment DEC_LITERAL : ('0'..'9')+ ;
fragment CHAR : '\'' (ESC_SEQ | ~('\'')) '\'' ;
fragment STRING_LIT : '"' ( ESC_SEQ | ~('\\'|'"') )* '"';
fragment ESC_SEQ : '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\') ;
IDENTIFIER : ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ;
WS  :   ( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;} ;
LINE_COMMENT : '//' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;} ;