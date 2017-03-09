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
end

#Clase que le quita la recursividad al símbolo inicial.
class Scope
    attr_accessor :types
    attr_accessor :elems
    # Donde inst es de la clase Instr
    def initialize(type1,func=nil,type2,inst)
        @types=[type1,type2]
        @elems=[func,inst]
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
end



##Clase para imprimir lista de declaraciones
class Ldecl
   #Donde type1 es :Funcion, type2 es :Nombre_Funcion,type3 es :Parámetros,type4 es Tipo_Retorno
   # y type5 es Instrucciones. var es el nombre de la función, list es la lista de parámetros,
   # typeret es el tipo de retorno, inst es un conjunto de instrucciones.
    attr_accessor :types
    attr_accessor :type1
    attr_accessor :elems
    def initialize(type1,type2,var,type3=nil,list=nil,type4=nil,typeret=nil,type5=nil,inst=nil,type6=nil,var6=nil)
        @type1=type1

        @types=[type2,type3,type4,type5,type6]
        @elems=[var,list,typeret,inst,var6]

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
end


class Func
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,listDecl,type2=nil,listinst=nil,type3=nil,var3=nil,type4=nil,var4=nil)
        @types=[type1,type2,type3,type4]
        @elems=[listDecl,listinst,var3,var4]
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
end

#Clase para imprimir bloques with.
# Recibe: lisdecl que es una lista de declaraciones de la clase ListD y listinst es una lista de instrucciones de la clase Inst
class Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,listDecl,type2=nil,listinst=nil)
        @types=[type1,type2]
        @elems=[listDecl,listinst]
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
end
class Inst<Bloque;end
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
end
class ListaFunc<ListaInst;end
class ListParam<ListaInst;end
class ListID<ListaInst;end
#Clase par imprimir una lista de argumentos de una función
# list es la lista de la clase ListD, type1 es :Argumento y type2 es de la clase Esp
class ListD < Bloque;end
class Writable<Bloque;end
class Asignable<Bloque;end

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

class LInst<Bloque;end
class Write<Bloque;end  #########################
class Retorno<Bloque;end

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

#Clase para imprimir las asignaciones 
# Recibe: type1 es :VARIABLE y type2 es :EXPRESSION

class Assign < Bloque;end
class WLoop<Ldecl;end
class FLoop<Ldecl;end
class RLoop<Ldecl;end
class Cond<Func;end
class Call<Bloque;end



###################################
# Clases asociadas a expresiones. #
###################################

#Clase para la impresion de operacines binarias.
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
end

#Clase par la impresión de Terms : identificadores, literales booleanos y literales nuḿéricos
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
end