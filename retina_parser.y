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
    : Listfunciones PROGRAM LInst END SEMICOLON {puts "scope"}
    ;

    Listfunciones
    :
    |funciones Listfunciones 
    ; 

    funciones
    :FUNC ID LPARENT ListD RPARENT Retorno BEGIN funcInst END SEMICOLON {puts "funcion"}
    ;

    wis
    :DO  LInst END SEMICOLON {puts "do"} # Puedo tener bloques sin with?->  programas qe solo tengan un write o una cuenta.
    |WITH Ldecl DO LInst END SEMICOLON {puts "with do"}
    |WITH DO END SEMICOLON {puts "with do"}
    ;

    ListD
    :
    |type ID {puts "lista parametros"}
    |type ID COLON ListD {puts "lista parámetros"}
    ;

    type
    :TYPEN  {puts "number"}
    |TYPEB  {puts "boolean"}
    ;

    Ldecl
    :type Assign  {puts "asignacion"}
    |type Assign Ldecl  {puts "asignaciones"}
    |type ListID SEMICOLON  {puts "declaracions"}
    |type ListID SEMICOLON Ldecl  {puts "declaraciones"}
    
    ; 
    
    ListID
    :ID  {puts val[0]}
    |ID COLON ListID  {puts "list id #{val[0]}"}
    ;

    Retorno
    :
    |RETURN2 type  {puts "->"}
    ;

    funcInst
    :
    |LInst {puts "instrucciones en funcion"}
    ;

    LInst
    : Inst  {puts "Instruccion"}
    | LInst Inst  {puts "Lista Instruccion"}

    Inst
    : wis  {puts "bloquewith"}
    | RETURN Expr SEMICOLON {puts "return"}
    | Assign  {puts "asignacion"}
    | Iterator  {puts "iterator"}
    | READ ID SEMICOLON  {puts "read"}
    | WRITE writable SEMICOLON  {puts "write"}
    | WRITELN writable SEMICOLON  {puts "writeln"}
    | Cond  {puts "considtional"}
    | Call SEMICOLON {puts "call"}
    | Expr SEMICOLON {puts "Expresion como instr"}
    ;

    writable #Puedo imprimir vacio?
    :Expr  {puts "write expr"}
    |Str   {puts "write str"}
    |Call   {puts "write call"}
    |writable COLON writable  {puts "lista write"}
    ; 
    
    Str
    : STRING  {puts "string #{val[0]}"}
    ;

    Assign
    :ID EQUAL Expr SEMICOLON  {puts "asignacion #{val[0]}"}
    ;

    Iterator
    : WHILE Expr DO LInst END SEMICOLON  {puts "bloque while"}
    | FOR ID FROM Expr TO Expr by DO LInst END SEMICOLON  {puts "bloque for"}
    | REPEAT Expr TIMES LInst END SEMICOLON  {puts "bloque repeat"}
    ;

    by
    :
    | BY Expr  {puts "by"}
    ;

    Cond
    :IF Expr THEN LInst END SEMICOLON  {puts "cond if" }
    |IF Expr THEN LInst ELSE LInst END SEMICOLON  {puts "con if else"}
    ;

    Call
    : ID LPARENT ListParam RPARENT {puts "call"}
    | ID LPARENT RPARENT {puts "call sin param"}
    ;

    ListParam
    :Expr  {puts "param expr"}
    |Expr COLON ListID  {puts "lista param"}
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
    : TRUE          {result = Terms.new(:TRUE , val[0]); puts "true"}
    | FALSE         {result = Terms.new(:FALSE , val[0]);puts "false"}
    ;
    # Expresiones básicas: definen todas las expresiones hoja en Retina.
    Term
    : DIGIT {result= Terms.new(:DIGIT,val[0]); puts val[0]}
    | ID   {result = Terms.new(:ID , val[0]); puts val[0]}
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
        if @token.eql? "$" then
            "Unexpected EOF"
        else
            "Line unexpected token #{@token}" 
        end
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



