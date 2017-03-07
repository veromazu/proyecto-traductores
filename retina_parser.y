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
    :  Scope {result = S.new(val[0]);result.printAST(0)}
    ;   
    
    # Alcance: le quita la recursividad al simbolo inicial.
    Scope 
    : Listfunciones PROGRAM LInst END SEMICOLON {result = Scope.new(:Funciones,val[0],:Program,val[2])}
    ;

    Listfunciones
    :
    |funciones Listfunciones {result=ListaFunc.new(:Funcion,val[0],val[1])}
    ; 

    funciones
    :FUNC Var LPARENT ListD RPARENT Retorno BEGIN funcInst END SEMICOLON {result=Func.new(:Nombre_Funcion,val[1],:Parametros,val[3],:Tipo_Retorno,val[5],:Instrucciones,val[7])}
    ;

    wis
    :DO  LInst END SEMICOLON {result=Bloque.new(:declaraciones,nil,:instrucciones,val[1])}
    |WITH Ldecl DO funcInst END SEMICOLON {result=Bloque.new(:declaraciones,val[1],:instrucciones,val[3])}
    |WITH DO END SEMICOLON {result=Bloque.new(:declaraciones,nil,:instrucciones,nil)}
    ;

    ListD
    :
    |type Var {result=ListD.new(:tipos,val[0],:identificadores,val[1])}
    |type Var COLON ListD {result=List.new(:tipos,val[0],val[3],:identificadores,val[1])}
    ;

    Var
    : ID {result = Terms.new(:ID , val[0])}
    ; 

    type
    :TYPEN  {result=Type.new(:Tipo,val[0])}
    |TYPEB  {result=Type.new(:Tipo,val[0])}
    ;

    Ldecl
    :type Assign {result=Ldecl.new(:declaracion,:tipo,val[0],:asignacion,val[1])}
    |type Assign Ldecl  {result=Ldecl.new(:declaracion,:tipo,val[0],:asignacion,val[1])}
    |type ListID SEMICOLON   {result=Ldecl.new(:declaracion,:tipo,val[0],:Lista_ID,val[1])}
    |type ListID SEMICOLON Ldecl  {result=Ldecl.new(:Lista_Decl,:tipo,val[0],:Lista_ID,val[1],:declaracion,val[3])}
    ; 
    
    ListID
    :Var              {result=ListaInst.new(:ID,val[0])}
    |Var COLON ListID {result=ListaInst.new(:ID,val[0],val[2])}
    ;

    Retorno
    :
    |RETURN2 type  {result=Bloque.new(:tipo,val[1])}
    ;

    funcInst
    :
    |LInst
    ;

    LInst
    : Inst  {result=ListaInst.new(:Instruccion,val[0])}
    | Inst LInst  {result=ListaInst.new(:Instruccion,val[0],val[1])}

    Inst
    : wis  {result=Bloque.new(:Bloque,val[0])}
    | RETURN Expr SEMICOLON {result=Bloque.new(:Retorno,val[1])}
    | Assign  {result=Bloque.new(:Asignacion,val[0])}
    | Iterator  {result=Bloque.new(:Iteracion,val[0])}
    | READ Var SEMICOLON  {result=Bloque.new(:Lectura,val[1])}    ###### FALTA ACOMODAR ESTOOOO ########
    | WRITE writable SEMICOLON  {result=Write.new(:Salida,val[1])}
    | WRITELN writable SEMICOLON  {result=Write.new(:Salida_Con_Salto,val[1])}
    | Cond  {result=Bloque.new(:Condicional,val[0])}
    | Call SEMICOLON {result=Bloque.new(:Llamada_de_Funcion,val[0])}
    | Expr SEMICOLON {result=Bloque.new(:Expresion,val[0])}
    ;

    writable #Puedo imprimir vacio?
    :Expr  {result=Bloque.new(:expresion,val[0])}
    |Str   {result=Bloque.new(:string,val[0])}
    |Call   {result=Bloque.new(:Call,val[0])}
    |writable COLON writable {result=Bloque.new(:valor,val[0],:valor,val[2])}
    ; 
    
    Str
    : STRING  {result=Str.new(val[0])}
    ;

    Assign  
    : Var EQUAL Expr SEMICOLON  {result=Assign.new(:Lado_Izquierdo,val[0],:Lado_Derecho,val[2])}
    ;

    Iterator
    : WHILE Expr DO LInst END SEMICOLON  {result=WLoop.new(:Ciclo_While,:Condicion,val[1],:Do,val[1])}
    | FOR Var FROM Expr TO Expr by DO LInst END SEMICOLON  {result= FLoop.new(:Ciclo_For,:For,val[1],:From,val[3],:To,val[5],:By,nil,:Instrucciones,val[8])}
    | REPEAT Expr TIMES LInst END SEMICOLON  {result=RLoop.new(:Ciclo_Repeat,:Times,val[1],:Instrucciones,val[3])}
    ;

    by
    :
    | BY Expr  {result=Bloque.new(:By,val[1])}
    ;

    Cond
    :IF Expr THEN LInst END SEMICOLON  {result=Cond.new(:Condición,val[1],:Instrucciones,val[3])}
    |IF Expr THEN LInst ELSE LInst END SEMICOLON  {result=Cond.new(:Condicion,val[1],:Instrucciones,val[3],:Instrucciones_Else,val[5])}
    ;

    Call   #######
    : Var LPARENT ListParam RPARENT {result=Call.new(:nombre,val[0],:argumentos,val[2])}
    | Var LPARENT RPARENT {result=Call.new(:nombre,val[0])}
    ;

    ListParam
    :Expr  {result=Bloque.new(:expresion,val[0])}
    |Expr COLON ListParam {result=Bloque.new(:expresion,val[0])}
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
        if @token.eql? "$" then
            "Unexpected EOF"
        else
           " Línea #{@token.position[0]}, Column #{@token.position[1]}: token inesperado : #{@token.symbol} : #{@token.id}"
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
    if ((token = @lexer.next_token)!=nil)
        return [token.symbol,token]
    else 
        return nil
    end

end


def parse(lexer)
	@yydebug = true
	@lexer = lexer
	@tokens = []
	do_parse
	
end
