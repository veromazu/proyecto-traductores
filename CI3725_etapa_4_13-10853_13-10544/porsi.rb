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
#Variable global para saber si se debe ejecutar una función
$ejecutar=false
#Variable que guarda el nombre de la función a ejecutar
$nombreFunc=nil
$parametros = [true,15]

####################################
# Clases predefinidas  #############
####################################
=begin
class openeye
    def initialize()
    end
    def openeye()
    end
end
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
    def interprete(tableStack)
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
    def interprete(tableStack)
        #puts "Scope de Scope"
        #@symTable.print_Table
        #if @elems[0] !=nil
         #   @elems[0].interprete(@symTable)
            #print"1 Scope de funciones"
            #@symTable.print_Table
       # end
       # if $ejecutar
        #    @elems[0].interprete(@symTable)
        #end
        $ejecutar=false
        $parametros=nil
        if @elems[1] !=nil
           # puts "symTable"
           # @symTable.print_Table
            @elems[1].interprete(@symTable,tableStack)
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
    def initialize(type1,type2,var,type3=nil,list=nil,type4=nil,typeret=nil,type5=nil,inst=nil,type6=nil,var6=nil)
        @type1=type1

        @types=[type2,type3,type4,type5,type6]
        @elems=[var,list,typeret,inst,var6]
        #@symTable = nil

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
    def interprete(symTable,tableStack)
        if @types[1] == :asignacion
            @elems[1].interprete(symTable,tableStack)
        end
        if @elems[2]!=nil
            @elems[2].interprete(symTable,tableStack)
        end
        #for i in 0..4
        #    if @elems[i] != nil
        #        @elems[i].interprete(symTable)       
        #    end
        #end
    end
end
#Clase para la impresion de un ciclo While
class WLoop<Ldecl
    attr_accessor :types
    attr_accessor :type1
    attr_accessor :elems
    def initialize(type1,type2,var,type3=nil,list=nil,type4=nil,typeret=nil,type5=nil,inst=nil,type6=nil,var6=nil)
        @type1=type1

        @types=[type2,type3,type4,type5,type6]
        @elems=[var,list,typeret,inst,var6]
    end
    def interprete(symTable,tableStack)
        if elems[1] != nil
            while @elems[0].interprete(symTable,tableStack)
                elems[1].interprete(symTable,tableStack)
            end
        else
            while condicion
            end
        end
    end
end

#Clase para la impresion de ciclos For
class FLoop<Ldecl
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
    def interprete(symTable,tableStack)
        varIter= @elems[0].term.id
        valor = @elems[1].interprete(@symTable,tableStack)
        valFinal =  @elems[2].interprete(@symTable,tableStack)
        symTable.update(varIter, [:TYPEN, valor])
        if @elems[3]!=nil
            salto = @elems[3].interprete(@symTable,tableStack)
        else 
            salto = 1
        end
        while valor <= valFinal
            if elems[4]!= nil
                elems[4].interprete(@symTable,tableStack)
            end
            valor += salto
            symTable.update(varIter, [:TYPEN, valor])
            #symTable.print_Table
        end
    end
end

#Clase para la impresion de ciclos Repear
class RLoop<Ldecl
    attr_accessor :types
    attr_accessor :type1
    attr_accessor :elems
    def initialize(type1,type2,var,type3=nil,list=nil,type4=nil,typeret=nil,type5=nil,inst=nil,type6=nil,var6=nil)
        @type1=type1
        @types=[type2,type3,type4,type5,type6]
        @elems=[var,list,typeret,inst,var6]

    end
    def interprete(symTable,tableStack)
        iter = @elems[0].interprete(symTable,tableStack)
        if elems[1] != nil
            iter.to_i.times {
                elems[1].interprete(symTable,tableStack)
            }
        end
    end
end


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
    def interprete(symTable,parametros,tableStack)
        if @elems[3] != nil      
            #print "3 Funciones ANTES"
            #@symTable.print_Table   
            cont=0
            @symTable.symTable.each do |k,v|
               @symTable.update(k, [v[0],parametros[cont]])
                #v[1]=$parametros[cont]
                puts "parma #{parametros[cont]}"
                #k.param = $parametros[cont]
                cont+=1
            end
            print "3 Funciones"
            @symTable.print_Table
            @elems[3].interprete(@symTable,tableStack
        end
    end
end

#Clase para la impresion de condicionales
class Cond<Func
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,var1,type2=nil,var2=nil,type3=nil,var3=nil,type4=nil,var4=nil)
        @types=[type1,type2,type3,type4]
        @elems=[var1,var2,var3,var4]
    end
    def interprete(symTable,tableStack)
        condicion = @elems[0].interprete(symTable,tableStack)
        if condicion
            if @elems[1] !=nil
                @elems[1].interprete(symTable,tableStack)
            end
        else
            if @elems[2] != nil
                @elems[2].interprete(symTable,tableStack)
            end
        end
    end
end

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
    def interprete(symTable,tableStack)
        if @elems[0]!=nil
            @elems[0].interprete(@symTable,tableStack)
        end

        if @elems[1] != nil
            @elems[1].interprete(@symTable,tableStack) 
            #@symTable.print_Table         
        end
    end
    
end

#Clase para la impresion de Instrucciones
class Inst < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        @elems[0].interprete(symTable,tableStack)
    end
end


class InstWisf < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        
       @elems[0].interprete(symTable,tableStack)
       #puts"instAsignWisf"
       #symTable.print_Table
    end

end
class InstWis < InstWisf
    def interprete(symTable,tableStack)
        
        @elems[0].interprete(symTable,tableStack)
        #print"instAsignWis"
        #@symTable.print_Table
    end
end
class InstReturn < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
end
class InstReturn_call < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
end
class InstAsign < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
       @elems[0].interprete(symTable,tableStack)
       # print"instAsign"
       #symTable.print_Table
    end
end


#Clase par imprimir una lista de argumentos de una función
class ListD < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
end
#Clase para imrimir los elementos de una intruccion Write
class Writable<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        print @elems[0].interprete(symTable,tableStack)
        if @elems[1] != nil
            print @elems[1].interprete(symTable,tableStack)
        end
    end
end

class Writable2<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        puts @elems[0].interprete(symTable,tableStack)
        if @elems[1] != nil
            puts @elems[1].interprete(symTable,tableStack)
        end
    end
end
#Clase para la impresion de elementos de una asignacion
class Asignable_Expr<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        return elems[0].interprete(symTable,tableStack)
    end
end
class Asignable_Call<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
end
#Clase para la impresion de llamadas de funcion
class Call<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        nombreFunc=@elems[0].term.id
        #$ejecutar = true
        parametros = nil
        if @elems[1]!=nil
           parametros = @elems[1].interprete(symTable,tableStack)
        end
        puts "La funcion es #{nombreFunc}"
        puts "los parametros son #{parametros}"
        puts "nombre #{symTable.nombre}"
        aux = symTable
        while aux != nil
            if aux.nombre == "Alcance "+ nombreFunc
                puts "Lo encontre"
                clase = aux.clase
                clase.interprete(symTable,parametros,tableStack)
                break
            end
            aux= aux.father
        end
    end
end
#Clase para la impreion de lista de Instrucciones
class LInst<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
end
#Clase para la impresion de una instruccion Write
class Write<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        elems[0].interprete(symTable,tableStack)
    end
end
class WriteSalto<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        elems[0].interprete(symTable,tableStack)
    end
end
#Clase para la impresion de una instruccion de Retorno
class Retorno<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
end
#Clase para la impreion de instruccion Assign
class Assign < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable,tableStack)
        idVar = @elems[0].term.id
        valor = @elems[1].interprete(symTable,tableStack)
        tipo = symTable.lookup(idVar)[0]
        symTable.update(idVar, [tipo, valor])
        #print "assign"
        #symTable.print_Table
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

    def interprete(symTable,tableStack)
        @elem.interprete(symTable,tableStack)
        if @list != nil
           @list.interprete(symTable,tableStack)
        end
    end
end

#Clase para la impresion de Lista de funciones
class ListaFunc<ListaInst
    def interprete(symTable,tableStack)
        #if @elem.elems[0].term.id == $nombreFunc
            @elem.interprete(symTable,tableStack)
        #end
        if (@list!=nil)
            @list.interprete(symTable,tableStack)
        end
    end
end
#Clase para la impresion de Lista de Parámtros de una llamade de funcion
class ListParam<ListaInst
    attr_accessor :type
    attr_accessor :elem
    attr_accessor :list
    def initialize(type,elem,list=nil)
        @list=list
        @type=type
        @elem=elem
    end
    def interprete(symTable,tableStack)
        parametro=@elem.interprete(symTable,tableStack)
        parametros=[parametro]
        if @list !=nil
            return parametros + (@list.interprete(symTable),tableStack)
        end
        return parametros
    end
end

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
    def interprete(symTable,tableStack)
        @salto.interprete(symTable,tableStack)
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
    attr_accessor :types
    attr_accessor :val
    def initialize(type,val)
        @types=[type]
        @val=val
    end
    def printAST(lvl)
        (lvl).times{ print" "}
        puts "#{@type}:"
        (lvl+1).times{print" "}
        puts "Identificador: #{@val.term.id}"
    end

    def interprete(symTable,tableStack)
        idVar = @val.term.id
       # idVal = @val.interprete(symTable)
        tipo = symTable.lookup(idVar)[0]
        # Se espera a que se lea una entrada valida.
        auxVar = STDIN.gets().chomp
        #auxVar.slice! "\n"
        # Verificación de tipo
        case auxVar

        when /^true/
            if (tipo == :TYPEB)
                auxVar = true
                valid = true
            else
                raise ExecError.new "Entrada inválida para variable '#{idVar}'"
            end
        when /^false/
            if (tipo == :TYPEB)
                auxVar = false
                valid = true
            else
                raise ExecError.new "Entrada inválida para varaible '#{idVar}'"
            end
        when    /^[a-z][a-zA-Z0-9_]*/   
            raise ExecError.new "Entrada inválida para variable '#{idVar}'"
    
        when /^(-|)([1-9][0-9]*|0)(\.[0-9]+)?/
            if (tipo == :TYPEN)
                auxVar = auxVar.to_f
                valid = true
            else
                raise ExecError.new "Entrada inválida para variable '#{idVar}'"
            end
        end
        symTable.update(idVar, [tipo, auxVar])
        symTable.print_Table
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
    def interprete(symTable,tableStack)
        return @cadena.id.to_s
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
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo + derecho
    end
end
#Clase de restas
class BinExpResta <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo - derecho
    end
end
#Clase de multiplicaciones
class BinExpMult <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo * derecho
    end
end
#clase de /
class BinExpDiv2 <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: División por cero"
        else
            return (izquierdo).fdiv(derecho)
        end
    end
end
#Clase de %
class BinExpMod2 <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: Resto exacto de cero"
        else
            return (izquierdo) % (derecho)
        end
    end
end
#Clase de div
class BinExpDiv <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
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
    def interprete(symTable,tableStack)

        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: Resto exacto de cero"
        else
            return izquierdo.to_i.modulo(derecho)
        end
    end
end

#Clase del or
class BinExpOr <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo || derecho
    end
end

#Clase del and
class BinExpAnd <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo && derecho
    end
end

#Clase del < 
class BinExpLT < BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo < derecho
    end
end
#Clase del >
class BinExpGT <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo > derecho
    end
end

#Clase del <
class BinExpLET <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo <= derecho
    end
end

#Clase del >=
class BinExpGET <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo >= derecho
    end
end

#Clase del /=
class BinExpDist <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
        return izquierdo != derecho
    end
end

#clase del ==
class BinExpEQ <BinExp
    def interprete(symTable,tableStack)
        izquierdo = @elems[0].interprete(symTable,tableStack)
        derecho =  @elems[1].interprete(symTable,tableStack)
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

    def interprete(symTable,tableStack)
        if op == :Inverso_Aditivo
            return - @elem.interprete(symTable,tableStack)
        elsif op == :Negacion
            return !@elem.interprete(symTable,tableStack)
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

    def interprete(symTable,tableStack)
        return @expr.interprete(symTable,tableStack)
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

    def interprete(symTable,tableStack)
        case @nameTerm
        when :ID
            #Retorno el valor del id que esta guardado en la tabla de simbolos
            return symTable.lookup(@term.id)[1]
        when :DIGIT
            #retorno el valor convertido en float del digit
            return @term.id.to_f
        when :TRUE
            #retorno true 
            return true
        when :FALSE
            #retorno false
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
