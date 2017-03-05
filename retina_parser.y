#! /usr/bin/ruby

# encoding: utf-8
#UNIVERSIDAD SIMÓN BOLÍVAR
#Traductores e Interpretadores
#Fase 2 de Proyecto : Parser de Retina.
#Elaborado por:
#    -Verónica Mazutiel, 13-10853
#    -Melanie Gomes, 13-10544

class Parser

    token DIGIT PLUS LESS MULT DIV2 LPARENT RPARENT TYPEN TYPEB                             
           TRUE FALSE AND NOT OR PROGRAM BEGIN END WITH DO IF THEN ELSE
           WHILE FOR REPEAT TIMES READ WRITE WRITELN FROM TO BY FUNC RETURN
           RETURN2 EQUIVALENT LESSTHAN DISTINCT GETHAN LETHAN GREATTHAN LPARENT
           RPARENT EQUAL SEMICOLON PLUS MOD DIV MOD2 DIV2 MULT LESS ID STRING
           DIGIT  LCURLY RCURLY COLON

    prechigh
        right NOT
        #Los aritmeticos tienen mas precedencia que los de comparacion
        UMINUS
        left MULT DIV2 MOD DIV MOD2
        left PLUS LESS
        nonassoc EQUIVALENT DISTINCT GETHAN LETHAN LESSTHAN GREATTHAN EQUAL DISTINCT #Los de comparacion tienen menor precedencia que los de or y and pero menor que el not y son de der a izq
        left AND
        left OR
        left SEMICOLON
        left COLON

    preclow

start S

rule

  #################################
  # Estructura general de Retina #
  #################################

    # Simbolo inicial: define un programa en Retina e incorpora el alcance.
    S
    :  Scope {result = S.new(val[0])}
    ;   
    
    # Alcance: le quita la recursividad al simbolo inicial.
    Scope 
    : Listfunciones PROGRAM wis END SEMICOLON {puts "ok"}
    ;

    Listfunciones
    :
    |funciones Listfunciones 
    ; 

    funciones
    :FUNC ID LPARENT ListD RPARENT Retorno BEGIN funcInst END SEMICOLON {puts "ok"}
    ;

    wis
    :DO  LInst END SEMICOLON {puts "ok"} # Puedo tener bloques sin with?->  programas qe solo tengan un write o una cuenta.
    |WITH Ldecl DO LInst END SEMICOLON {puts "ok"}
    ;

    ListD
    :
    |type ID {puts "ok"}
    |type ID COLON ListD {puts "ok"}
    ;

    type
    :TYPEN  {puts "ok"}
    |TYPEB  {puts "ok"}
    ;

    Ldecl
    :type ListID SEMICOLON  {puts "ok"}
    |type ListID SEMICOLON Ldecl  {puts "ok"}
    |type ID EQUAL Expr SEMICOLON  {puts "ok"}
    |type ID EQUAL Expr SEMICOLON Ldecl  {puts "ok"}
    ; 
    
    ListID
    :ID  {puts "ok"}
    |ID COLON ListID  {puts "ok"}
    ;

    Retorno
    :
    |RETURN2 type  {puts "ok"}
    ;

    funcInst
    :
    |LInst {puts "ok"}
    ;

    LInst
    : Inst  {puts "ok"}
    | LInst Inst  {puts "ok"}

    Inst
    : wis  {puts "ok"}
    | RETURN Expr SEMICOLON {puts "ok"}
    | Assign  {puts "ok"}
    | Iterator  {puts "ok"}
    | READ ID SEMICOLON  {puts "ok"}
    | WRITE writable SEMICOLON  {puts "ok"}
    | WRITELN writable SEMICOLON  {puts "ok"}
    | Cond  {puts "ok"}
    | Call  {puts "ok"}
    ;

    writable #Puedo imprimir vacio?
    : Expr  {puts "ok"}
    | Str   {puts "ok"}
    | writable COLON writable  {puts "ok"}
    ; 
     Str
    : STRING  {puts "ok"}
    ;

    Assign
    : ID EQUAL Expr SEMICOLON  {puts "ok"}
    ;

    Iterator
    :  WHILE Expr DO LInst END SEMICOLON  {puts "ok"}
    | FOR ID FROM Expr TO Expr by DO LInst END SEMICOLON  {puts "ok"}
    | REPEAT Expr TIMES LInst END SEMICOLON  {puts "ok"}
    ;

    by
    :
    | BY Expr  {puts "ok"}
    ;

    Cond
    :  IF Expr THEN LInst END SEMICOLON  {puts "ok"}
    | IF Expr THEN LInst ELSE LInst END SEMICOLON  {puts "ok"}
    ;

    Call
    : ID LPARENT ListID RPARENT  {puts "ok"}
    | ID LPARENT RPARENT  {puts "ok"}
    ;

  ##################################
  # Expresiones validas en Retina #
  ##################################

    # Expresiones: define todas las expresiones recursivas en Retina.
    Expr                          
    : Term                        
    | Expr PLUS Expr                  {result = BinExp.new(:Suma, val[0], val[2])}
    | Expr LESS Expr                   {result = BinExp.new(:Resta, val[0], val[2])}
    | Expr MULT Expr                {result = BinExp.new(:Multiplicacion, val[0], val[2])}
    | Expr DIV2 Expr                {result = BinExp.new(:Division_Exacta, val[0], val[2])}
    | Expr MOD2 Expr                 {result = BinExp.new(:Resto_Exacto, val[0], val[2])}
    | Expr DIV Expr                {result = BinExp.new(:Division_Entera, val[0], val[2])}
    | Expr MOD Expr                 {result = BinExp.new(:Resto_Entero, val[0], val[2])}
    | LESS Expr  =UMINUS                 {result = UnaExp.new(:Inverso_Aditivo , val[1])}
    | LPARENT Expr RPARENT            {result = ParExp.new(:Expresion, val[1])}
    | Expr OR Expr                    {result = BinExp.new(:Or , val[0],val[2])}
    | Expr AND Expr                   {result = BinExp.new(:And, val[0], val[2])}
    | Expr LESSTHAN Expr                 {result = BinExp.new(:Menor_que, val[0], val[2])}
    | Expr GREATTHAN Expr              {result = BinExp.new(:Mayor_que, val[0], val[2])}
    | Expr LETHAN Expr               {result = BinExp.new(:Menor_O_Igual_Que, val[0], val[2])}
    | Expr GETHAN Expr            {result = BinExp.new(:Mayor_O_Igual_Que, val[0], val[2])}
    | Expr DISTINCT Expr                 {result = BinExp.new(:Distinto_Que, val[0], val[2])}
    | Expr EQUIVALENT Expr              {result = BinExp.new(:Equivalencia,val[0],val[2])}
    ;

    # Booleanos: define al tipo de variables booleanas en Retina.

    Bool
    : TRUE          {result = Terms.new(:TRUE , val[0])}
    | FALSE         {result = Terms.new(:FALSE , val[0])}
    ;
    # Expresiones básicas: definen todas las expresiones hoja en Retina.
    Term
    : DIGIT {result= Terms.new(:DIGIT,val[0])}
    | ID   {result = Terms.new(:ID , val[0])}
    | Bool
    ;

    
end

---- header

require_relative "lexer"

require './retina_ast.rb'

class SyntacticError < RuntimeError

    def initialize(tok)
        @token = tok
    end

    def to_s
        "Syntactic error on: #{@token}"   
    end
end

---- inner


def on_error(id, token, stack)
    raise SyntacticError::new(token)
end

def initialize(lexer)
  @lexer=lexer
end

def next_token
  @lexer.next_token
end


def parse(lexer)
	@yydebug = true
	@lexer = lexer
	@tokens = []
	do_parse
	
end



