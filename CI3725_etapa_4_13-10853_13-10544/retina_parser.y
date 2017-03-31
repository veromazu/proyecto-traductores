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
    :  Scope {result = S.new(val[0]);$Close = Closeeye.new()
        $Open= Openeye.new();
        $Home = Home.new();
        $Forward = Forward.new();
        $Backward = Backward.new();
        $Setposition = Setposition.new()}
    ;   
    
    # Alcance: le quita la recursividad al simbolo inicial.
    Scope 
    : Listfunciones PROGRAM LInst END SEMICOLON {result = Scope.new(:Funciones,val[0],:Program,val[2])}
    | Listfunciones PROGRAM END SEMICOLON {result = Scope.new(:Funciones,val[0],nil,nil)}
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
    |WITH Ldecl DO LInst END SEMICOLON {result=Bloque.new(:declaraciones,val[1],:instrucciones,val[3])}
    |WITH Ldecl DO END SEMICOLON {result=Bloque.new(:declaraciones,val[1])}
    |WITH DO END SEMICOLON {result=Bloque.new(:declaraciones,nil,:instrucciones,nil)}
    ;

    wisf
    :DO  LInstf END SEMICOLON {result=Bloque.new(:declaraciones,nil,:instrucciones,val[1])}
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
    |type Assign Ldecl  {result=Ldecl.new(:declaracion,:tipo,val[0],:asignacion,val[1],:declaracion,val[2])}
    |type ListID SEMICOLON   {result=Ldecl.new(:declaracion,:tipo,val[0],:Lista_ID,val[1])}
    |type ListID SEMICOLON Ldecl  {result=Ldecl.new(:Lista_Decl,:tipo,val[0],:Lista_ID,val[1],:declaracion,val[3])}
    ; 
    
    ListID
    :Var              {result=ListID.new(:ID,val[0])}
    |Var COLON ListID {result=ListID.new(:ID,val[0],val[2])}
    ;

    Retorno
    :
    |RETURN2 type  {result=Retorno.new(:tipo,val[1])}
    ;

    funcInst
    :
    |LInstf
    ;


    LInstf
    : Instf  {result=ListaInst.new(:Instruccion,val[0])}
    | LInstf Instf  {result=ListaInst.new(:Instruccion,val[1],val[0])}
    ;

    Instf
    : wisf  {result=InstWis.new(:Bloque,val[0])}
    | RETURN Expr SEMICOLON {result=InstReturn.new(:Retorno,val[1])}
    | Assign  {result=InstAsign.new(:Asignacion,val[0])}
    | IteratorF  {result=Inst.new(:Iteracion,val[0])}
    | READ Var SEMICOLON  {result=Read.new(:Lectura,val[1])}   
    | WRITE writable1 SEMICOLON  {result=Write.new(:Salida,val[1])}
    | WRITELN writable2 SEMICOLON  {result=WriteSalto.new(:Salida_Con_Salto,val[1])}
    | CondF  {result=Inst.new(:Condicional,val[0])}
    | Expr SEMICOLON {result=Inst.new(:Expresion,val[0])}
    ;

    LInstruc
    :
    | LInst
    ;

    LInst
    : Inst  {result=ListaInst.new(:Instruccion,val[0])}
    | LInst Inst   {result=ListaInst.new(:Instruccion,val[1],val[0])}
    ;


    Inst
    : wis  {result=InstWis.new(:Bloque,val[0])}
    | Assign  {result=InstAsign.new(:Asignacion,val[0])}
    | Iterator  {result=Inst.new(:Iteracion,val[0])}
    | READ Var SEMICOLON  {result=Read.new(:Lectura,val[1])}    #listo
    | WRITE writable1 SEMICOLON  {result=Write.new(:Salida,val[1])}
    | WRITELN writable2 SEMICOLON  {result=WriteSalto.new(:Salida_Con_Salto,val[1])}
    | Cond  {result=Inst.new(:Condicional,val[0])}
    | Expr SEMICOLON {result=Inst.new(:Expresion,val[0])}
    ;

    writable1 
    :Expr  {result=Writable.new(:Expresion,val[0])} #listo
    |Str   {result=Writable.new(:String,val[0])}
    |writable1 COLON writable1 {result=Writable.new(:valor,val[0],:valor,val[2])} #listo para expr
    ; 

    writable2 
    :Expr  {result=Writable2.new(:Expresion,val[0])} #listo
    |Str   {result=Writable2.new(:String,val[0])}
    |writable2 COLON writable2 {result=Writable.new(:valor,val[0],:valor,val[2])} #listo para expr
    ; 

    
    Str
    : STRING  {result=Str.new(val[0])}
    ;

    Assign  
    : Var EQUAL Asignable SEMICOLON  {result=Assign.new(:Lado_Izquierdo,val[0],:Lado_Derecho,val[2])}
    ;

    Asignable #Puedo asignar cualquiera de estos a una variable
    :Expr  {result=Asignable_Expr.new(:Expresion,val[0])}
    ;

    Iterator
    : WHILE Expr DO LInstruc END SEMICOLON  {result=WLoop.new(:Ciclo_While,:Condicion,val[1],:Do,val[3])}
    | FOR Var FROM Expr TO Expr by DO LInstruc END SEMICOLON  {result= FLoop.new(:Ciclo_For,:For,val[1],:From,val[3],:To,val[5],:By,val[6],:Instrucciones,val[8])}
    | REPEAT Expr TIMES LInstruc END SEMICOLON  {result=RLoop.new(:Ciclo_Repeat,:Times,val[1],:Instrucciones,val[3])}
    ;

    IteratorF
    : WHILE Expr DO funcInst END SEMICOLON  {result=WLoop.new(:Ciclo_While,:Condicion,val[1],:Do,val[3])}
    | FOR Var FROM Expr TO Expr by DO funcInst END SEMICOLON  {result= FLoop.new(:Ciclo_For,:For,val[1],:From,val[3],:To,val[5],:By,val[6],:Instrucciones,val[8])}
    | REPEAT Expr TIMES funcInst END SEMICOLON  {result=RLoop.new(:Ciclo_Repeat,:Times,val[1],:Instrucciones,val[3])}
    ;

    by
    :
    | BY Expr  {result=By.new(val[1])}
    ;

    Cond
    :IF Expr THEN LInstruc END SEMICOLON  {result=Cond.new(:Condición,val[1],:Instrucciones,val[3])}
    |IF Expr THEN LInstruc ELSE LInstruc END SEMICOLON  {result=Cond.new(:Condicion,val[1],:Instrucciones,val[3],:Instrucciones_Else,val[5])}
    ;

    CondF
    :IF Expr THEN funcInst END SEMICOLON  {result=Cond.new(:Condición,val[1],:Instrucciones,val[3])}
    |IF Expr THEN funcInst ELSE funcInst END SEMICOLON  {result=Cond.new(:Condicion,val[1],:Instrucciones,val[3],:Instrucciones_Else,val[5])}
    ;
    
    Call   
    : Var LPARENT ListParam RPARENT {result=Call.new(:nombre,val[0],:argumentos,val[2])}
    | Var LPARENT RPARENT {result=Call.new(:nombre,val[0])}
    ;

    ListParam
    :Expr  {result=ListParam.new(:expresion,val[0])}
    |Expr COLON ListParam {result=ListParam.new(:expresion,val[0],val[2])}
    ;

  ##################################
  # Expresiones validas en Retina #
  ##################################

    # Expresiones: define todas las expresiones recursivas en Retina.
    Expr                          
    : Term   
    | Call                          
    | Expr PLUS Expr                  {result = BinExpSuma.new(:Suma, val[0], val[2])}
    | Expr LESS Expr                   {result = BinExpResta.new(:Resta, val[0], val[2])}
    | Expr MULT Expr                {result = BinExpMult.new(:Multiplicacion, val[0], val[2])}
    | Expr DIV2 Expr                {result = BinExpDiv2.new(:Division_Exacta, val[0], val[2])}
    | Expr MOD2 Expr                 {result = BinExpMod2.new(:Resto_Exacto, val[0], val[2])}
    | Expr DIV Expr                {result = BinExpDiv.new(:Division_Entera, val[0], val[2])}
    | Expr MOD Expr                 {result = BinExpMod.new(:Resto_Entero, val[0], val[2])}
    | LESS Expr  =UMINUS                 {result = UnaExp.new(:Inverso_Aditivo , val[1])}
    | NOT Expr                        {result = UnaExp.new(:Negacion , val[1])}
    | LPARENT Expr RPARENT            {result = ParExp.new(:Expresion, val[1])}
    | Expr OR Expr                    {result = BinExpOr.new(:Or , val[0],val[2])}
    | Expr AND Expr                   {result = BinExpAnd.new(:And, val[0], val[2])}
    | Expr LESSTHAN Expr                 {result = BinExpLT.new(:Menor_que, val[0], val[2])}
    | Expr GREATTHAN Expr              {result = BinExpGT.new(:Mayor_que, val[0], val[2])}
    | Expr LETHAN Expr               {result = BinExpLET.new(:Menor_O_Igual_Que, val[0], val[2])}
    | Expr GETHAN Expr            {result = BinExpGET.new(:Mayor_O_Igual_Que, val[0], val[2])}
    | Expr DISTINCT Expr                 {result = BinExpDist.new(:Distinto_Que, val[0], val[2])}
    | Expr EQUIVALENT Expr              {result = BinExpEQ.new(:Equivalencia,val[0],val[2])}
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

require_relative "retina_lexer"

require_relative 'retina_ast'

class SyntacticError < RuntimeError

    def initialize(tok)
        @token = tok
    end

    def to_s
        if @token.eql? "$" then
            "Unexpected EOF"
        else
            case @token.symbol
                when :TYPEN,:TYPEB
                tokenName="tipo de dato"
            when :TRUE,:FALSE
                tokenName="literal booleano"
            when :AND,:NOT,:OR
                tokenName="operador booleano"
            when :PROGRAM,:BEGIN,:END,:WITH,:DO,:IF,:THEN,:READ,:ELSE,:WHILE,:FOR,:REPEAT,:WRITE,:WRITELN,:FROM,:TO,:BY,:FUNC,:RETURN,:RETURN2
                tokenName="palabra reservada"
            when :EQUIVALENT,:LESSTHAN,:DISTINCT,:GETHAN,:LESSTHAN,:GREATTHAN
                tokenName="operador de comparación"
            when :LPARENT,:RPARENT,:EQUAL,:SEMICOLON,:COLON,:RCURLY,:LCURLY
                tokenName="signo"
            when :PLUS,:MOD,:DIV,:MOD2,:DIV2,:MULT,:LESS
                tokenName="operador aritmético"
            when :ID
                tokenName="identificador"
            when :STRING
                tokenName="string"
            when :DIGIT
                tokenName="literal numérico"
            end
           return " Línea #{@token.position[0]}, Column #{@token.position[1]}: token inesperado : "<< tokenName << " : #{@token.id}"
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
