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
    VarsDefenition;
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
    Argument;
    Condition;
    Then;
    Else;
    FunctionCall;
    ArrayAccess;
    Args;
    Indices;
    ELEMS;
}

// P a r s e r  p a r t

source : sourceItem* -> ^(Source sourceItem*);

sourceItem : funcDef -> ^(SourceItem funcDef);
fragment funcDef : 'method' funcSignature ( body | ';' ) -> ^(FuncDef funcSignature body?);
fragment body : ( 'var' ( list_identifier (':' typeRef)? ';' )* )? blockStatement -> ^(BodySig ^(VarsDefenition list_identifier typeRef?)* blockStatement) ; 
list_identifier: (IDENTIFIER (',' IDENTIFIER)*)? -> ^(ListIdentifier IDENTIFIER*) ;

typeRef : builtin -> ^(BuiltinType builtin)
    | custom -> ^(CustomType custom)
    | arrayType;
//    | array ;                             
fragment builtin : ('bool' | 'byte' | 'int' | 'uint' | 'long' | 'ulong' | 'char' | 'string');
fragment custom : IDENTIFIER ;
//fragment array : 'array' '[' (',')* ']' 'of' typeRef -> ^(ArrayType typeRef) ;

arrayType
    : 'array' '[' elems ']' 'of' typeRef -> ^(ArrayType typeRef elems)
    ;

elems 
    : (',' )* -> ^(ELEMS ',')
    ;

funcSignature : IDENTIFIER '(' list_argDef ')' typeRefDef? -> ^(FuncSignature IDENTIFIER list_argDef typeRefDef?);     
fragment list_argDef : (argDef (',' argDef)*)? -> ^( ListArgDefs argDef*) ;	
//fst mark	    
fragment argDef : IDENTIFIER typeRefDef? -> ^(Argument IDENTIFIER typeRefDef?);
fragment typeRefDef : ':' typeRef -> ^(TypeRef typeRef) ;

// S t a t e m e n t s

statement : 
      ifStatement
    | blockStatement 
    | whileStatement 
    | doStatement  
    | breakStatement 
    | expressionStatement;

ifStatement : 'if' expr 'then' statement ('else' statement)? -> 
^(IfStatement ^(expr) ^(statement) ^(statement)?);

blockStatement : 'begin' statement* 'end' ';' -> ^(BlockStatement statement*);

whileStatement : 'while' expr 'do' statement -> ^(WhileStatement ^(expr) ^(statement)); 

doStatement : 'repeat' statement ('while'|'until') expr ';' -> ^(DoStatement ^(statement) ^(expr) );

breakStatement : 'break' ';' -> ^(BreakStatement);

expressionStatement : expr ';' -> ^(ExpressionStatement expr);

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

unaryExpr :  ('!'|'-')^ unaryExpr | primaryExpr ; 

primaryExpr 
	: baseExpr '(' (expr (',' expr)*)? ')' sufExpr? -> ^(FunctionCall baseExpr ^(Args expr*) sufExpr?)
	| baseExpr '[' (expr (',' expr)*)? ']' sufExpr? -> ^(ArrayAccess baseExpr ^(Indices expr*) sufExpr?)
	| baseExpr
	;

sufExpr 
	: '(' (expr (',' expr)*)? ')' sufExpr? -> ^(FunctionCall ^(Args expr*) sufExpr?)
	| '[' (expr (',' expr)*)? ']' sufExpr? -> ^(ArrayAccess ^(Indices expr*) sufExpr?)
	;

baseExpr :
     LITERAL  
    | IDENTIFIER                             
    | '(' expr ')' -> ^(Braces expr)                         
    ;

//callExpr: IDENTIFIER '(' list_expr ')' -> ^(CallExpr IDENTIFIER list_expr) ;

//indexer: IDENTIFIER '[' list_expr ']' -> ^(Indexer IDENTIFIER list_expr) ;

//list_expr : (expr (',' expr)*)? -> ^(ListExpr expr*) ;

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