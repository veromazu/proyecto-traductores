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
    def initialize(func=nil,inst)
        @inst = inst
        @func=func
    end
    def printAST(lvl)
        if @func!=nil
            @func.printAST(lvl)
        end
        @inst.printAST(lvl)
        
    end
end



#Clase para la impresion de funciones
class Func
   #Donde type1 es :Funcion, var es el nombre de la funcion, type2 es de la clase ListD,
    # => tipoRetorno es del tipo Type, type3 es :Instrucciones y inst es del tipo InstF, funcion2 hace referencia a otra clase Func

    def initialize(type1,type2,var,type3,lista,type4=nil,tipoRetorno=nil,type5,inst,funcion2)
        @type1=type1

        @types=[type2,type3,type4,type5]
        @elems=[var,lista,tipoRetorno,inst]
        @inst=inst
        @funcion2=funcion2

    end
    def printAST(lvl)
        lvl.times{print "\t"}
        puts "#{@type1}:"
        for i in 0..3
            if @types[i] != nil
                 (lvl+1).times{ print"\t"}
                puts "#{@types[i]}:"

                @elems[i].printAST(lvl+2)
                
            end
        end

        #(lvl+1).times{print "\t"}
        #puts @inst.printAST(lvl)
        if @funcion2 !=nil
            (lvl).times{print "\t"}
            puts @funcion2.printAST(lvl)
        end
    end
end

#Clase para imprimir las instrucciones contenidas en una Función.
# => inst es de la clase Inst, type es :Retorna, y expr es del tipo Expr.

class InstF
    def initialize(inst,type,expr)
        @inst=inst
        @type=type
        @expr=expr
    end
    def printAST(lvl)
        if @inst!=nil
            inst.printAST(lvl)
        end
        lvl.times{print"\t"}
        puts "#{@type}:"
        @expr.printAST(lvl+1)
    end
end


#Clase para imprimir las llamadas a otras funciones
#=>  Recibe: type2 Es :Nombre, type3 es :Argumentos, nombre es de la clase Term y lista es de la clase ListL

class Call
    def initialize(type2,nombre,type3,lista)
        @types=[type2,type3]
        @elem=[nombre,lista]
    end
    def printAST(lvl)
        for i in 0..1
            if @types[i] != nil
                (lvl).times{ print"\t"}
                puts "#{@types[i]}:"

                @elem[i].printAST(lvl+1)
              
            end  
        end
    end
end

#Clase para imprimir una lista de elementos seguidos por coma
#ListL.new(val[0],:Argumento,val[2])}
class ListL
    def initialize(list,type,elem)
        @list=list
        @type=type
        @elem=elem
    end
    def printAST(lvl)
        if @list!=nil
            @list.printAST(lvl)
        end
        lvl.times{print("\t")}
        puts "#{@type}:"
        @elem.printAST(lvl+1)
    end
end

#Clase para imprimir un bloque de Instrucciones
class Instr
    # Donde nameinst1 puede ser :instrucciones,:Entrada,:Salida,:Salida_Con_Salto,:Asignacion,
    # =>Instrucciones_Condicionales,:Iteracion, :Bloque, :Llamada
    # => nameinst2 tiene que ser :instrucciones
    def initialize(nameinst1, inst1, nameinst2 = nil, inst2 = nil)
        @opID = [nameinst1, nameinst2]
        @branches = [inst1, inst2]
    end
    def printAST(lvl)

        @branches.each do |branch|
            if branch != nil
                #if @opID[0] == :INSTR

#                    branch.printAST(lvl)
 #               else
                    (lvl).times{ print"\t"}
                    puts "#{@opID[0]}: "
                    branch.printAST(lvl+1)
                #end
            end
        end
    end
end

#Clase para imprimir bloques del tipo: With decl Do Inst end;
# Recibe: lisdecl que es una lista de declaraciones de la clase ListD y listinst es una lista de instrucciones de la clase Inst
class Bloque
    def initialize(listdecl,listinst)
        @listdecl=listdecl
        @listinst=listinst
    end
    def printAST(lvl)     
        @listdecl.printAST(lvl)
        @listinst.printAST(lvl)
    end
end

#Clase para imprimir las declaraciones de variables.
class Decl
    def initialize(decl,type,listidentifier)
        @decl=decl
        @type=type
        @listidentifier=listidentifier
    end
    def printAST(lvl)
        (lvl).times{ print"\t"}
        puts "declaraciones:"
        if @type!=nil and @listidentifier!=nil
            (lvl+1).times{ print"\t"}
            puts "Declaracion:"
            @type.printAST(lvl+2)
            (lvl+1).times{ print"\t"}
            puts "identificadores:"
            @listidentifier.printAST(lvl+2)
        end
        if @decl!=nil
            @decl.printAST(lvl)
        end     
    end
end

#Clase para imprimir una lista de variables declaradas del mismo tipo.
# var es del tipo Term y list es de
class ListI
    def initialize(var,list)
        @var=var
        @list=list
    end
    def printAST(lvl)
        if @var!=nil
            @var.printAST(lvl)
        end
        @list.printAST(lvl)
    end
end

#ListD.new(val[0],:Argumento,val[2],val[3])

#Clase par imprimir una lista de argumentos de una función
# list es la lista de la clase ListD, type1 es :Argumento y type2 es de la clase Esp
class ListD
    def initialize(list,type1,type2)
        @type1=type1
        @type2=type2
        @list=list
    end
    def printAST(lvl)
        lvl.times{print"\t"}
        puts "#{@type1}"
        if @list!=nil
            @list.printAST(lvl+1)
        end
        puts @type2.printAST(lvl+1)
    end
end

#Esp.new(val[0],val[1])
#Clase para imprimir una declaracion del tipo Type Var. tipo es de la clase Type y var es de la clase Term.
class Esp
    def initialize(tipo,var)
        @tipo=tipo
        @var=var
    end

    def printAST(lvl)
        @tipo.printAST(lvl)
        @var.printAST(lvl)
    end
end

#Clase para imprimir los tipos de datos boolean o number.
# Recibe: type es boolean o number.
class Type
    def initialize(type)
        @type=type
    end
    def printAST(lvl)
        (lvl).times{ print"\t"}
        puts "tipo:"
        (lvl+1).times{print"\t"}
        puts "Tipo:"
        (lvl+2).times{print"\t"}
        puts "nombre: #{@type}"
    end
end

#Clase para imprimir las asignaciones 
# Recibe: type1 es :VARIABLE y type2 es :EXPRESSION
class Assign
    def initialize(type1, var, type2, expr)
        @types = [type1, type2] # Donde type1 es :Lado_Izquierdo y type2 es :Lado_Derecho
        @branches = [var, expr] # Donde var es clase Var y expr es clase Expr
    end
    def printAST(lvl)
        # Escribirá el nombre de cada operación y llamará a los prints de las clases
        # => involucradas
        str=["lado izquierdo:","lado derecho:"]
        for i in 0..1
            (lvl).times{ print"\t"}
            puts "#{str[i]}"

           @branches[i].printAST(lvl+1)
        end
    end
end

#Clase para imprimir las instrucciones Write
#Recibe: lista que es una lista separada por comas de objetos a imprimir de la clase Writey expr que es la expresion a imprimir 
# => es de la clase Str o Expr.
class Write
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

#Clase para la impresion de Strings
# Recibe: type que es :String y cadena que es del tipo STRING
class Str
    def initialize(type,cadena)
        @type=type
        @cadena=cadena
    end
    def printAST(lvl)
        lvl.times{print "\t"}
        puts "#{@type}:"
        (lvl+1).times{print"\t"}
        puts @cadena.to_s
    end
end

#Clase para la impresion de Condicionales
# Recibe: type1 es :condicion, type2 es :then y type3 puede ser :else
# => expr es de la clase Expr, inst1 e inst2 son de la clase Instr.
class Cond
    
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
class WLoop
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
class Floop
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
class RLoop
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
        puts"expresiones:\t"
        (lvl+1).times{ print"\t"}
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
            puts"nombre:#{@term}"
        when :DIGIT
            puts "Literal Numérico:"
            (lvl+1).times{ print"\t"}
            puts"valor:#{@term}"
        when :TRUE,:FALSE
            puts "Literal Booleano:"
            (lvl+1).times{ print"\t"}
            puts"valor:#{@term}"
        end
    end
end