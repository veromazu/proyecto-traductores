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
    # Donde inst es de la clase Instr
    def initialize(type1,func=nil,type2,inst)
        @types=[type1,type2]
        @elems=[func,inst]
    end
    def printAST(lvl)     
        for i in 0..1
            if @elems[i] != nil
                (lvl).times{ print"\t"}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+1)            
            end
        end
    end
end



#Clase para la impresion de funciones
class Func
   #Donde type1 es :Funcion, type2 es :Nombre_Funcion,type3 es :Parámetros,type4 es Tipo_Retorno
   # y type5 es Instrucciones. var es el nombre de la función, list es la lista de parámetros,
   # typeret es el tipo de retorno, inst es un conjunto de instrucciones.

    def initialize(type1,type2,var,type3=nil,list=nil,type4=nil,typeret=nil,type5=nil,inst=nil,type6=nil,var6=nil)
        @type1=type1

        @types=[type2,type3,type4,type5,type6]
        @elems=[var,list,typeret,inst,var6]

    end
    def printAST(lvl)
        lvl.times{print "\t"}
        puts "#{@type1}:"
        for i in 0..4
            if @elems[i] != nil
                 (lvl+1).times{ print"\t"}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+2)
                
            end
        end
    end
end

#Clase para imprimir bloques with.
# Recibe: lisdecl que es una lista de declaraciones de la clase ListD y listinst es una lista de instrucciones de la clase Inst
class Bloque
    def initialize(type1,listDecl,type2=nil,listinst=nil,type3=nil,var3=nil,type4=nil,var4=nil)
        @types=[type1,type2,type3,type4]
        @elems=[listDecl,listinst,var3,var4]
    end
    def printAST(lvl)     
        for i in 0..3
            if @elems[i] != nil
                (lvl).times{ print"\t"}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+1)            
            end
        end
    end
end

class List
    def initialize(type1,var,list,type2=nil,var2=nil)
        @types=[type1,type2]
        @elems=[var,var2]
        @list=list
    end
    def printAST(lvl)     
        for i in 0..1
            if @elems[i] != nil
                (lvl).times{ print"\t"}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+1)            
            end
        end
        @list.printAST(lvl)
    end
end

class ListaInst
    def initialize(type,elem,list=nil)
        @list=list
        @type=type
        @elem=elem
    end
    def printAST(lvl)
        
        lvl.times{print("\t")}
        puts "#{@type}:"
        @elem.printAST(lvl+1)
        if @list!=nil
            @list.printAST(lvl)
        end
    end
end
class ListaFunc<ListaInst;end
#Clase par imprimir una lista de argumentos de una función
# list es la lista de la clase ListD, type1 es :Argumento y type2 es de la clase Esp
class ListD < Bloque;end
=begin

class ListD
    def initialize(type1,,var)
        @type=type
        @var=var
    end
    def printAST(lvl)
        @type.printAST(lvl)
        @var.printAST(lvl)
    end
end
=end
#Clase para imprimir lista de declaraciones
class Ldecl<Func;end
    

#Clase para imprimir los tipos de datos boolean o number.
# Recibe: type es boolean o number.
class Type
    def initialize(type,val)
        @type=type
        @val=val
    end
    def printAST(lvl)
        (lvl).times{ print"\t"}
        puts "#{@type}:"
        (lvl+1).times{print"\t"}
        puts "nombre: #{@val.id}"
    end
end

class LInst<Bloque;end
class Write<Bloque;end  #########################

class Read
    def initialize(type,val)
        @type=type
        @val=val
    end
    def printAST(lvl)
        (lvl).times{ print"\t"}
        puts "#{@type}:"
        (lvl+1).times{print"\t"}
        puts "Identificador: #{@val.id}"
    end
end


#Clase para la impresion de Strings
# Recibe: type que es :String y cadena que es del tipo STRING
class Str
    def initialize(cadena)
        @cadena=cadena
    end
    def printAST(lvl)
        (lvl).times{print"\t"}
        puts "valor: #{@cadena.id}"
    end
end

#Clase para imprimir las asignaciones 
# Recibe: type1 es :VARIABLE y type2 es :EXPRESSION

class Assign < Bloque;end
class WLoop<Func;end
class FLoop<Func;end
class RLoop<Func;end
class Cond<Bloque;end
class Call<Bloque;end

=begin
#Clase para imprimir las instrucciones Write
#Recibe: lista que es una lista separada por comas de objetos a imprimir de la clase Writey expr que es la expresion a imprimir 
# => es de la clase Str o Expr.
class Write2
    def initialize(lista,expr)
        @lista = lista   #Lista separada por comas de objetos a imprimir
        @expr = expr    #Expresion a imprimir
    end
    def printAST(lvl)
        if @lista!=nil
            @lista.printAST(lvl)
        end
        @expr.printAST(lvl)
    end
end



#Clase para la impresion de Condicionales
# Recibe: type1 es :condicion, type2 es :then y type3 puede ser :else
# => expr es de la clase Expr, inst1 e inst2 son de la clase Instr.
class Cond2
    
    def initialize(type1, expr, type2, inst1, type3=nil, inst2=nil)
        @types = [type1, type2, type3]
        @elems = [expr, inst1, inst2]
    end
    def printAST(lvl)
        for i in 0..2
            if @types[i] != nil
                (lvl).times{ print"\t"}
                puts "#{@types[i]}:"
                @elems[i].printAST(lvl+1)
            end
        end
    end
end


#Clase par imprimir Iteraciones While
# Recibe type1 es :While y type2 es :Instrucciones
#=> expr es de la clase Expr e inst es de la clase Instr 
class WLoop2
    def initialize(type1, expr, type2, inst)
        @types = [type1, type2]
        @elems = [expr, inst]
    end
    def printAST(lvl)
        for i in 0..1
            (lvl).times{print "\t"}
            puts "#{@types[i]}:"
            @elems[i].printAST(lvl+1)
        end     
    end

end

#Clase par imprimir los ciclos For
# Recibe: type1 es :For type2 es :From ,type3 ses :To , type4 es :Intrucciones y type5 es :Paso,
# var es de la clase Var, expr1 , expr2 y expr2 son de la clase Term
# => inst es de la clase Instr
class Floop2
    def initialize(type1, var, type2, expr1, type3, expr2, type4, inst,type5=nil,expr3=nil)
        @types = [type1, type2, type3, type4,type5]
        @elems = [var, expr1, expr2, inst,expr3]      
    end
    def printAST(lvl)
        for i in 0..4
            if (@elems[i] != nil)
                (lvl).times{print "\t"}
                puts "#{@types[i]}:"
                @elems[i].printAST(lvl+1)
            end
        end
    end 
end

#Clase para la impresiond e los cilos Repeat
#Recibe: type1 es :Repat, type2 es :Instrucciones
# => var es del tipo Expr y inst es del tipo Instr
class RLoop2
    def initialize(type1,var,type2,type3,inst)
        @type1=type1
        @type2=type2
        @type3=type3
        @var=var
        @inst=inst
    end
    def printAST(lvl)
        (lvl).times{print"\t"}
        puts "#{@type1}:"
        (lvl+1).times{print "\t"}
        puts "#{@type2}:"
        @var.printAST(lvl+2)
        (lvl+1).times{print "\t"}
        puts "#{@type3}:"
        @inst.printAST(lvl+2)
    end
end

=end

###################################
# Clases asociadas a expresiones. #
###################################

#Clase para la impresion de operacines binarias.
class BinExp
    # Donde type0 es :OPERATION, op puede ser +, -, *, /, %, ~, \/, /\, <, <=,
    # >, >=, =, ' o &, type1 y type2 son las distintas operaciones dependiedo el caso y expr1 y expr2 son expresiones
    def initialize(op, expr1, expr2)
        @elems = [expr1, expr2]
        @op = op
    end
    def printAST(lvl)
        str=["lado izquierdo:","lado derecho:"]
        (lvl).times{ print"\t"}
        puts"#{@op}:"
        j=0
        @elems.each do |elem|
            (lvl+1).times{ print"\t"}
            puts str[j]
            elem.printAST(lvl+2)
            j+=1
        end
    end
end

#Clase para la impresion de operacion Unarias como el inverso Aditivo
# op es :Inverso_Aditivo y expr es la expresion.
class UnaExp
    def initialize(op, expr)
        @elem = expr
        @op = op
    end
    def printAST(lvl)
        for i in 1..lvl
            print "\t"
        end
        puts "#{@op}"
        @elem.printAST(lvl+1)
    end
end

#Clase para la impresion de exoresiones encerradas en paréntesis
# Donde type es :Expresion y expr es una expresion cualquiera
class ParExp
    def initialize(type, expr)
        @type = type
        @expr = expr        
    end
    def printAST(lvl)
        for i in 1..lvl
            print "\t "
        end
        puts "#{@type}"
        @expr.printAST(lvl+1)       
    end 
end

#Clase par la impresión de Terms : identificadores, literales booleanos y literales nuḿéricos
class Terms
    def initialize(nameTerm, term)
        @nameTerm = nameTerm
        @term = term
    end
    def printAST(lvl)
        for i in 1..lvl
            print "\t"
        end     
        case @nameTerm
        when :ID
            puts "Identificador:"
            (lvl+1).times{ print"\t"}
            puts"nombre:#{@term.id}"
        when :DIGIT
            puts "Literal Numérico:"
            (lvl+1).times{ print"\t"}
            puts"valor:#{@term.id}"
        when :TRUE,:FALSE
            puts "Literal Booleano:"
            (lvl+1).times{ print"\t"}
            puts"valor:#{@term.id}"
        end
    end
end