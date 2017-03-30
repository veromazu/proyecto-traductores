#! /usr/bin/ruby
# encoding: utf-8
=begin

UNIVERSIDAD SIMÓN BOLÍVAR
Traductores e Interpretadores
Fase 2 de Proyecto : Parser de Retina.
Elaborado por:
    -Verónica Mazutiel, 13-10853
    -Melanie Gomes, 13-10544

En este archivo se implementan las clases destinadas a imprimir el Árbol Sintáctico Abstracto.
=end


#####################################
# Clases asociadas a instrucciones. #
#####################################
# Simbolo inicial: define un programa en Retina e incorpora el alcance.
class S
    attr_accessor :scope
    attr_accessor :decl
    # Donde scope es de la clase Scope.
    def initialize(scope)
        @scope = scope
    end 
    def printAST(lvl)
        @scope.printAST(0)
    end
    def interprete()
        @scope.interprete()
    end
end

#Clase que le quita la recursividad al símbolo inicial.
class Scope
    attr_accessor :types
    attr_accessor :elems
    attr_accessor :symTable
    # Donde inst es de la clase Instr
    def initialize(type1,func=nil,type2,inst)
        @types=[type1,type2]
        @elems=[func,inst]
        @symTable = nil
    end
    def printAST(lvl)     
        for i in 0..1
            if @elems[i] != nil
                (lvl).times{ print" "}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+1)            
            end
        end
    end
    def interprete()
        #puts "Scope de Scope"
        #@symTable.print_Table
        if @elems[0] !=nil
            @elems[0].interprete(@symTable)
            #print"1 Scope de funciones"
            #@symTable.print_Table
        end
        if @elems[1] !=nil
            
            @elems[1].interprete(@symTable)
            #print"2 Scope de instrucciones"
            #@symTable.print_Table
        end
    end

end



##Clase para imprimir lista de declaraciones
class Ldecl
   #Donde type1 es :Funcion, type2 es :Nombre_Funcion,type3 es :Parámetros,type4 es Tipo_Retorno
   # y type5 es Instrucciones. var es el nombre de la función, list es la lista de parámetros,
   # typeret es el tipo de retorno, inst es un conjunto de instrucciones.
    attr_accessor :types
    attr_accessor :type1
    attr_accessor :elems
    attr_accessor :symTable
    def initialize(type1,type2,var,type3=nil,list=nil,type4=nil,typeret=nil,type5=nil,inst=nil,type6=nil,var6=nil)
        @type1=type1

        @types=[type2,type3,type4,type5,type6]
        @elems=[var,list,typeret,inst,var6]
        @symTable = nil

    end
    def printAST(lvl)
        lvl.times{print " "}
        puts "#{@type1}:"
        for i in 0..4
            if @elems[i] != nil
                 (lvl+1).times{ print" "}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+2)
                
            end
        end
    end
    def interprete(symtable)
        if @elems[4] != nil
            @elems[4].interprete(symTable)
        end
        #for i in 0..4
        #    if @elems[i] != nil
        #        @elems[i].interprete(symTable)       
        #    end
        #end
    end
end
#Clase para la impresion de un ciclo While
class WLoop<Ldecl;end
#Clase para la impresion de ciclos For
class FLoop<Ldecl;end
#Clase para la impresion de ciclos Repear
class RLoop<Ldecl;end

#Clase para imprimir Funciones
class Func
    attr_accessor :types
    attr_accessor :elems
    attr_accessor :symTable
    #var4 son las instrucciones
    def initialize(type1,var1,type2=nil,var2=nil,type3=nil,var3=nil,type4=nil,var4=nil)
        @types=[type1,type2,type3,type4]
        @elems=[var1,var2,var3,var4]
        @symTable = nil
    end
    def printAST(lvl)     
        for i in 0..3
            if @elems[i] != nil
                (lvl).times{ print" "}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+1)            
            end
        end
    end
    def interprete(symTable)
        if @elems[3] != nil      
            #print "3 Funciones ANTES"
            #@symTable.print_Table    
            @elems[3].interprete(@symTable)
            #print "3 Funciones"
            #@symTable.print_Table
        end
    end
end

#Clase para la impresion de condicionales
class Cond<Func;end

#Clase para imprimir bloques with.
# Recibe: lisdecl que es una lista de declaraciones de la clase ListD y listinst es una lista de instrucciones de la clase Inst
class Bloque
    attr_accessor :types
    attr_accessor :elems
    attr_accessor :symTable
    def initialize(type1,listDecl,type2=nil,listinst=nil)
        @types=[type1,type2]
        @elems=[listDecl,listinst]
        @symTable = nil
    end
    def printAST(lvl)     
        for i in 0..1
            if @elems[i] != nil
                (lvl).times{ print" "}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+1)            
            end
        end
    end
    def interprete(symTable)
        for i in 0..1
            if @elems[i] != nil
                @elems[i].interprete(@symTable) 
                #@symTable.print_Table         
            end
        end
    end
end

#Clase para la impresion de Instrucciones
class Inst<Bloque;end

class InstWisf < Bloque;
    def interprete(symTable)
        
       @elems[0].interprete(symTable)
       #puts"instAsignWisf"
       #symTable.print_Table
    end

end
class InstWis < InstWisf
    def interprete(symTable)
        
        @elems[0].interprete(symTable)
        #print"instAsignWis"
        #@symTable.print_Table
    end
end
class InstReturn < Bloque;end
class InstReturn_call < Bloque;end
class InstAsign < Bloque
    def interprete(symTable)
       @elems[0].interprete(symTable)
       # print"instAsign"
       #symTable.print_Table
    end
end
class InstIteratorF < Bloque;end
class InstRead < Bloque;end
class InstCondF < Bloque;end
class InstCall < Bloque;end
class InstExpr< Bloque;end

#Clase par imprimir una lista de argumentos de una función
class ListD < Bloque;end
#Clase para imrimir los elementos de una intruccion Write
class Writable<Bloque;end
#Clase para la impresion de elementos de una asignacion
class Asignable_Expr<Bloque
    def interprete()
        return elems[0].interprete()
    end
end
class Asignable_Call<Bloque;end
#Clase para la impresion de llamadas de funcion
class Call<Bloque;end
#Clase para la impreion de lista de Instrucciones
class LInst<Bloque;end
#Clase para la impresion de una instruccion Write
class Write<Bloque
    def interprete(symtable)
        elems[0].interprete(symTable)
    end
end


#Clase para la impresion de una instruccion de Retorno
class Retorno<Bloque;end
#Clase para la impreion de instruccion Assign
class Assign < Bloque
    def interprete(symTable)
        idVar = @elems[0].interprete()
        valor = @elems[1].interprete()
        puts "valor #{valor}"
        tipo = symTable.lookup(idVar)[0]
        puts "el tipo es #{tipo}"
        symTable.update(idVar, [tipo, valor])
        print "assign"
        symTable.print_Table
    end
end


#Clase para imprimir una lista de argumentos en la definicion de una función.
class List
    attr_accessor :types
    attr_accessor :elems
    attr_accessor :list
    def initialize(type1,var,list,type2=nil,var2=nil)
        @types=[type1,type2]
        @elems=[var,var2]
        @list=list
    end
    def printAST(lvl)     
        for i in 0..1
            if @elems[i] != nil
                (lvl).times{ print" "}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+1)            
            end
        end
        @list.printAST(lvl)
    end
end

#Clase para imprimir una lista de instrucciones dentro de un programa
class ListaInst
    attr_accessor :type
    attr_accessor :elem
    attr_accessor :list
    def initialize(type,elem,list=nil)
        @list=list
        @type=type
        @elem=elem
    end
    def printAST(lvl)
        
        lvl.times{print(" ")}
        puts "#{@type}:"
        @elem.printAST(lvl+1)
        if @list!=nil
            @list.printAST(lvl)
        end
    end

    def interprete(symTable)
        @elem.interprete(symTable)
        if @list != nil
           @list.interprete(symTable)
        end
    end
end

#Clase para la impresion de Lista de funciones
class ListaFunc<ListaInst
    def interprete(symTable)
        @elem.interprete(symTable)
        if (@list!=nil)
            @list.interprete(symTable)
        end
    end
end
#Clase para la impresion de Lista de Parámtros de una llamade de funcion
class ListParam<ListaInst;end
#Clase para la impresion de lista de identificadores en una declaracion
class ListID<ListaInst;end

#Clase para la impresion del salto By en los ciclos For
class By
    attr_accessor :salto
    def initialize(salto)
        @salto=salto
    end
    def printAST(lvl)
        @salto.printAST(lvl)
    end
end

    
#Clase para imprimir los tipos de datos boolean o number.
# Recibe: type es boolean o number.
class Type
    attr_accessor :type
    attr_accessor :val
    def initialize(type,val)
        @type=type
        @val=val
    end
    def printAST(lvl)
        (lvl).times{ print" "}
        puts "#{@type}:"
        (lvl+1).times{print" "}
        puts "nombre: #{@val.id}"
    end
end

#Clase par la impresion de instrucciones Read
class Read
    attr_accessor :type
    attr_accessor :val
    def initialize(type,val)
        @type=type
        @val=val
    end
    def printAST(lvl)
        (lvl).times{ print" "}
        puts "#{@type}:"
        (lvl+1).times{print" "}
        puts "Identificador: #{@val.id}"
    end
end


#Clase para la impresion de Strings
# Recibe: type que es :String y cadena que es del tipo STRING
class Str
    attr_accessor :cadena
    def initialize(cadena)
        @cadena=cadena
    end
    def printAST(lvl)
        (lvl).times{print" "}
        puts "valor: #{@cadena.id}"
    end
end

###################################
# Clases asociadas a expresiones. #
###################################

#Clase de operacines binarias.
class BinExp
    attr_accessor :op
    attr_accessor :elems
    # Donde type0 es :OPERATION, op puede ser +, -, *, /, %, ~, \/, /\, <, <=,
    # >, >=, =, ' o &, type1 y type2 son las distintas operaciones dependiedo el caso y expr1 y expr2 son expresiones
    def initialize(op, expr1, expr2)
        @elems = [expr1, expr2]
        @op = op
    end
    def printAST(lvl)
        str=["lado izquierdo:","lado derecho:"]
        (lvl).times{ print" "}
        puts"#{@op}:"
        j=0
        @elems.each do |elem|
            (lvl+1).times{ print" "}
            puts str[j]
            elem.printAST(lvl+2)
            j+=1
        end
    end
end
#Clase de sumas
class BinExpSuma <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        puts izquierdo
        puts derecho
        return izquierdo + derecho
    end
end
#Clase de restas
class BinExpResta <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        puts izquierdo - derecho
        return izquierdo - derecho
    end
end
#Clase de multiplicaciones
class BinExpMult <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        puts izquierdo * derecho
        return izquierdo * derecho
    end
end
#clase de /
class BinExpDiv2 <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: División por cero"
        else
            puts izquierdo.fdiv(derecho)
            return (izquierdo).fdiv(derecho)
        end
    end
end
#Clase de %
class BinExpMod2 <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: Resto exacto de cero"
        else
            puts izquierdo% derecho
            return (izquierdo) % (derecho)
        end
    end
end
#Clase de div
class BinExpDiv <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: Resto exacto de cero"
        else
            izquierdo.div(derecho)
            return (izquierdo).div(derecho)
        end
    end
end

#Clase de mod
class BinExpMod <BinExp
    def interprete()

        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: Resto exacto de cero"
        else
            puts izquierdo.to_i.modulo(derecho)
            return izquierdo.to_i.modulo(derecho)
        end
    end
end

#Clase del or
class BinExpOr <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        return izquierdo || derecho
    end
end

#Clase del and
class BinExpAnd <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        return izquierdo && derecho
    end
end

#Clase del < 
class BinExpLT < BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        return izquierdo < derecho
    end
end
#Clase del >
class BinExpGT <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        return izquierdo > derecho
    end
end

#Clase del <
class BinExpLET <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        return izquierdo <= derecho
    end
end

#Clase del >=
class BinExpGET <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        return izquierdo >= derecho
    end
end

#Clase del /=
class BinExpDist <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        return izquierdo != derecho
    end
end

#clase del ==
class BinExpEQ <BinExp
    def interprete()
        izquierdo = @elems[0].interprete()
        derecho =  @elems[1].interprete()
        return izquierdo == derecho
    end
end

#Clase para la impresion de operacion Unarias como el inverso Aditivo
# op es :Inverso_Aditivo y expr es la expresion.
class UnaExp
    attr_accessor :op
    attr_accessor :elem
    def initialize(op, expr)
        @elem = expr
        @op = op
    end
    def printAST(lvl)
        for i in 1..lvl
            print " "
        end
        puts "#{@op}"
        @elem.printAST(lvl+1)
    end

    def interprete()
        if op == :Inverso_Aditivo
            return - @elem.interprete()
        elsif op == :Negacion
            return !@elem.interprete()
        end
    end
end

#Clase para la impresion de exoresiones encerradas en paréntesis
# Donde type es :Expresion y expr es una expresion cualquiera
class ParExp
    attr_accessor :type
    attr_accessor :expr
    def initialize(type, expr)
        @type = type
        @expr = expr        
    end
    def printAST(lvl)
        for i in 1..lvl
            print "  "
        end
        puts "#{@type}"
        @expr.printAST(lvl+1)       
    end 

    def interprete()
        return @expr
    end
end

#Clase para la impresión de Terms : identificadores, literales booleanos y literales nuḿéricos
class Terms
    attr_accessor :nameTerm
    attr_accessor :term
    def initialize(nameTerm, term)
        @nameTerm = nameTerm
        @term = term
    end
    def printAST(lvl)
        for i in 1..lvl
            print " "
        end     
        case @nameTerm
        when :ID
            puts "Identificador:"
            (lvl+1).times{ print" "}
            puts"nombre:#{@term.id}"
        when :DIGIT
            puts "Literal Numérico:"
            (lvl+1).times{ print" "}
            puts"valor:#{@term.id}"
        when :TRUE,:FALSE
            puts "Literal Booleano:"
            (lvl+1).times{ print" "}
            puts"valor:#{@term.id}"
        end
    end

    def interprete()
        case @nameTerm
        when :ID
            return @term.id
        when :DIGIT
            return @term.id.to_f
        when :TRUE
            return true
        when :FALSE
            return false
        end
    end

end

class ExecError < RuntimeError

    def initialize(info,tok=nil)
        @info=info
        @token=tok
    end

    def to_s
        #Línea #{token.position[0]}, Column #{token.position[1]}
        if @token!=nil
            puts "ERROR: Línea #{@token.position[0]}, Columna #{@token.position[1]}: #{@info}"
        else
            puts "ERROR:#{@info}"
        end
    end
end
