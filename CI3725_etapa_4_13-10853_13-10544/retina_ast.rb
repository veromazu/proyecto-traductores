#! /usr/bin/ruby
# encoding: utf-8
=begin

UNIVERSIDAD SIMÓN BOLÍVAR
Traductores e Interpretadores
Fase 4 de Proyecto : Parser de Retina.
Elaborado por:
    -Verónica Mazutiel, 13-10853
    -Melanie Gomes, 13-10544

En este archivo se implementan las clases destinadas a imprimir el Árbol Sintáctico Abstracto.
=end

include Math
$Tablas=nil
$Pixels=nil
$Tortuga=nil
$Close = nil
$Open= nil
$Home = nil
$Forward = nil
$Backward = nil
$Rotatel =nil
$Rotater = nil
$Setposition = nil
$angulo = nil



##########################################
####### Clases predefinidas  #############
##########################################

#Clase para la ejecución de Home
class Home
    attr_accessor :symTable
    def initialize()
        @symTable=nil
    end
    def interprete(symTable,parametros)
        $Tortuga=[500,500]
    end
end

#Clase para la ejecución de Openeye
class Openeye
    attr_accessor :symTable
    attr_accessor :activo
    def initialize()
        @symTable=nil
        @activo=false
    end
    def interprete(symTable,parametros)
        @activo = true
        puts @activo
    end
end

#Clase para la ejecución de Closeeye
class Closeeye
    attr_accessor :symTable
    attr_accessor :activo
    def initialize()
        @symTable=nil
    end
    def interprete(symTable,parametros)
        $Open.activo =false
        puts $Open.activo 
    end
end

#Clase para la ejecución de Forward
class Forward
    attr_accessor :symTable
    def initialize()
        @symTable=nil
    end

    def valido(x,y)
        if 0<=x and x<=1001 and 0<=y and y<=1001
            return true
        else
            return false
        end
    end

    def interprete(symTable,parametros)
        pasos = parametros[0]
        
        x = $Tortuga[0]
        y = $Tortuga[1]
        #b de la ecuación de la recta
        b = $Tortuga[1]-500

        
        #Angulo en 1er cuadrante
        if 0 <= $angulo and $angulo<PI/2 
            #pendiente m
            m = Math.tan($angulo)
            j=y
            for i in x..x+pasos
                cont=0
                j=y
                while cont <= pasos 
                    recta =  (j-500) - m*(i-500) - b
                    if recta>=-0.85 and recta <=0.85
                        if $Open.activo and valido(i,j)
                            $Pixels[j][i]=1
                        end
                        $Tortuga[1] = i
                        $Tortuga[0] = j
                    end
                    j-= 1
                    cont += 1
                end
            end
        #Angulo en segundo cuadrante
        elsif $angulo>PI/2 and $angulo<PI
            #pendiente m
            m = Math.tan($angulo)
            j=y
            i=x
            conti = 0       
            while conti <= pasos 
                contj = 0
                j=y
                while contj <= pasos
                    recta =  (j-500) - m*(i-500) - b
                    if recta>=-0.85 and recta <=0.85
                        if $Open.activo and valido(i,j)
                            $Pixels[i][j]=1
                        end
                        $Tortuga[1] = j
                        $Tortuga[0] = i
                    end
                    j -= 1
                    contj += 1
                end
                i-=1
                conti+=1
            end

        #Angulo en tercer cuadrante
        elsif PI<$angulo and $angulo<(3*PI)/2
            #pendiente m
            m = Math.tan($angulo)
            j=y
            i=x
            conti = 0       
            while conti <= pasos 
                contj = 0
                j=y
                while contj <= pasos
                    recta =  (j-500) - m*(i-500) - b
                    #puts recta
                    if recta>=-0.85 and recta<=0.85
                        if $Open.activo and valido(i,j)
                            $Pixels[i][j]=1
                        end
                        $Tortuga[1] = j
                        $Tortuga[0] = i
                    end
                        j += 1
                        contj += 1
                end
                i-=1
                conti+=1
            end
        #Angulo en cuarto cuadrante
        elsif (3*PI)/2<$angulo and $angulo <2*PI
            #pendiente m
            puts $angulo
            m = Math.tan($angulo)
           for i in x..x+pasos
                for j in y..y+pasos 
                    recta =  (j-500) - m*(i-500) - b
                    if recta>=-0.85 and recta<=0.85
                        if $Open.activo and valido(i,j)
                            $Pixels[i][j]=1
                        end
                        $Tortuga[1] = j
                        $Tortuga[0] = i
                    end
                end
            end

        #Si es 90
        elsif $angulo == (PI)/2
            conti = 0
            i=x+pasos
            while i >=x
                if $Open.activo and valido(i,j)
                    $Pixels[i][y]=1
                end
                i=i-1
            end
            $Tortuga[1] = y
            $Tortuga[0] = i

        #Si es 270
        elsif $angulo == (3*PI)/2
            conti = 0
            i=x
            while conti <= pasos 
                if $Open.activo and valido(i,j)
                    $Pixels[i][y]=1
                end
                i+=1
                conti+=1
                $Tortuga[1] = y
                $Tortuga[0] = i
            end

        #Angulo es 180
        elsif $angulo==PI            
            contj = 0
            j=y
            while contj <= pasos 
                if $Open.activo and valido(i,j)
                    $Pixels[x][j]=1
                end
                j-=1
                contj += 1
                $Tortuga[1] = j
                $Tortuga[0] = x
            end
        end       
    end
end

#Clase para ejecución de método Backward
class Backward
    attr_accessor :symTable
    def initialize()
        @symTable=nil
    end

    def valido(x,y)
        if 0<=x and x<=1001 and 0<=y and y<=1001
            return true
        else
            return false
        end
    end
    def interprete(symTable,parametros)
        pasos = parametros[0]
        
        x = $Tortuga[0]
        y = $Tortuga[1]
        #b de la ecuación de la recta
        b = $Tortuga[1] - 500

        if 0 <= $angulo and $angulo<PI/2 
            #pendiente m
            m = Math.tan($angulo)
            j=y
            i=x
            conti = 0       
            while conti <= pasos 
                contj = 0
                j=y
                while contj <= pasos
                    recta =  (j-500) - m*(i-500) - b
                    if recta>=-0.85 and recta<=0.85
                        if $Open.activo and valido(i,j)
                            $Pixels[i][i]=1
                        end
                        $Tortuga[1] = j
                        $Tortuga[0] = i
                    end
                        j += 1
                        contj += 1
                end
                i-=1
                conti+=1
            end
        elsif $angulo>PI/2 and $angulo<PI
            #pendiente m
            m = Math.tan($angulo)
            for i in x..x+pasos
                for j in y..y+pasos 
                    recta =  (j-500) - m*(i-500) - b
                    if recta>=-0.85 and recta<=0.85
                        if $Open.activo and valido(i,j)
                            $Pixels[i][j]=1
                        end
                        $Tortuga[1] = j
                        $Tortuga[0] = i
                    end
                end
            end

        elsif PI<$angulo and $angulo<(3*PI)/2
            #pendiente m
            m = Math.tan($angulo)              
            for i in x..x+pasos
                cont=0
                j=y
                while cont <= pasos 
                    recta =  (j-500) - m*(i-500) - b
                    if recta>=-0.85 and recta <=0.85
                        if $Open.activo and valido(i,j)
                            $Pixels[j][i]=1
                        end
                        $Tortuga[1] = j
                        $Tortuga[0] = i
                    end
                    j-= 1
                    cont += 1
                end
            end
        elsif (3*PI)/2<$angulo and $angulo <2*PI
            #pendiente m
            m = Math.tan($angulo)
            j=y
            i=x
            conti = 0       
            while conti <= pasos 
                contj = 0
                j=y
                while contj <= pasos
                    recta =  (j-500) - m*(i-500) - b
                    if recta>=-0.85 and recta <=0.85
                        if $Open.activo and valido(i,j)
                            $Pixels[i][j]=1
                        end
                        $Tortuga[1] = j
                        $Tortuga[0] = i
                    end
                    j -= 1
                    contj += 1
                end
                i-=1
                conti+=1
            end

        #Si es 90
        elsif $angulo == PI/2
            conti = 0
            i=x
            while conti <= pasos 
                if $Open.activo and valido(i,j)
                    $Pixels[i][y]=1
                end
                i+=1
                conti+=1
                $Tortuga[1] = y
                $Tortuga[0] = i
            end
        #Si es 270
        elsif $angulo == (3*PI)/2
            conti = 0
            i=x
            while conti <= pasos 
                if $Open.activo and valido(i,j)
                    $Pixels[i][y]=1
                end
                i-=1
                conti+=1
                $Tortuga[1] = y
                $Tortuga[0] = i
            end

        #Angulo es 180
        elsif $angulo==PI             
            contj = 0
            j=y
            while contj <= pasos 
                if $Open.activo and valido(i,j)
                    $Pixels[x][j]=1
                end
                j+=1
                contj += 1
                $Tortuga[1] = j
                $Tortuga[0] = x
            end
        end
    end
end

#Clase para la función setposition
class Setposition
    attr_accessor :symTable
    def initialize()
        @symTable=nil
    end
    def interprete(symTable,parametros)
        $Tortuga[0]=parametros[0]
        $Tortuga[1]=parametros[1]
    end
end

#Clase para la función rotater
class Rotater
    attr_accessor :symTable
    def initialize()
        @symTable=nil
    end
    def interprete(symTable,parametros)
        grados=parametros[0]%360
        #Conversión a  radianes para uso de Ruby
        radianes = (grados* PI)/180
        $angulo -= radianes
        $angulo = $angulo % (2*PI)
    end
end

#Clase para la función rotatel
class Rotatel
    attr_accessor :symTable
    def initialize()
        @symTable=nil
    end
    def interprete(symTable,parametros)
        grados=parametros[0]%360
        #Conversión a  radianes para uso de Ruby
        radianes = (grados* PI)/180
        $angulo += radianes
        $angulo = $angulo % (2*PI)

    end
end

### Se definen clases con métodos para imprimir e interpretar el AST ####

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
        #Se guarda como variable global la pila de Tablas de símbolos para su uso cuando se requiera
        $Tablas=tableStack

        $Pixels=[]
        for i in 0 .. 1001
            $Pixels[i] = [0]*1001
        end
        $Tortuga=[500,500]
        $angulo = 0
        $Open.activo = true
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

        #Si las instrucciones no son vacías éstas se interpretan
        if @elems[1] !=nil
            @elems[1].interprete(@symTable)

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
    def interprete(symTable,parametros)
        #Se inicializan las variables en el alcance de la función con los valores de la llamada
        if @elems[3] != nil        
            cont=0
            @symTable.symTable.each do |k,v|
               @symTable.update(k, [v[0],parametros[cont]])
                cont+=1
            end
            return @elems[3].interprete(@symTable)
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
    def interprete(symTable) 
        if @elems[0].interprete(symTable)
            if @elems[1] !=nil
                return @elems[1].interprete(symTable)
            end
        else
            if @elems[2] != nil
                return @elems[2].interprete(symTable)
            end
        end
    end
end

##Clase de las declaraciones dentro de un bloque "With"
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
    def interprete(symTable)
        #Si la declaración tiene directamente una asignación, ésta se ejecuta
        if @types[1] == :asignacion
            @elems[1].interprete(symTable)
        end
        if @elems[2]!=nil
            @elems[2].interprete(symTable)
        end
    end
end

#Clase para los civlos while
class WLoop<Ldecl
    attr_accessor :types
    attr_accessor :type1
    attr_accessor :elems
    def initialize(type1,type2,var,type3=nil,list=nil,type4=nil,typeret=nil,type5=nil,inst=nil,type6=nil,var6=nil)
        @type1=type1

        @types=[type2,type3,type4,type5,type6]
        @elems=[var,list,typeret,inst,var6]
    end
    def interprete(symTable)
    #Si hay alguna instruccion se ejecuta el while y las acciones del mismo
        if elems[1] != nil
            while @elems[0].interprete(symTable)
                accion = elems[1].interprete(symTable)
            end

        else
    # Si no hay instruccines se ejecuta un ciclo
            while @elems[0].interprete(symTable)
            end
        end
    end
end

#Clase para la clase del ciclos For
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
    # Se tiene una variable dummy definida en el alcance del for que va aumentand
    # desde el valor con la que se definió hasta llegar al valor final
    def interprete(symTable)
        varIter= @elems[0].term.id
        valor = @elems[1].interprete(@symTable)
        valFinal =  @elems[2].interprete(@symTable)
        @symTable.update(@elems[0].term.id, [:TYPEN, valor])
        if @elems[3]!=nil
            salto = @elems[3].interprete(@symTable)
        else 
            salto = 1
        end
        while valor <= valFinal
            if elems[4]!= nil
                elems[4].interprete(@symTable)
            end
            valor += salto
            @symTable.update(@elems[0].term.id, [:TYPEN, valor])

        end
    end
end

#Clase para los ciclos repeat
class RLoop<Ldecl
    attr_accessor :types
    attr_accessor :type1
    attr_accessor :elems
    def initialize(type1,type2,var,type3=nil,list=nil,type4=nil,typeret=nil,type5=nil,inst=nil,type6=nil,var6=nil)
        @type1=type1
        @types=[type2,type3,type4,type5,type6]
        @elems=[var,list,typeret,inst,var6]

    end
    def interprete(symTable)

        #En iter está la cantidad de veces que se hará la iteracion
        iter = @elems[0].interprete(symTable)
        if elems[1] != nil
            iter.to_i.times {
                elems[1].interprete(symTable)
            }
        end
    end
end


#Clase de los bloques With
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
        #Se ejecuta la parte de las declaraciones
        if @elems[0]!=nil
            @elems[0].interprete(@symTable)
        end

        #Se ejecuta la parte de las instrucciones
        if @elems[1] != nil
            @elems[1].interprete(@symTable) 
        
        end
    end
    
end

#Clase para la impresion y ejecucion de Instrucciones
class Inst < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
        return @elems[0].interprete(symTable)
    end
end

#Clase para la ejecucion de bloques de una función
class InstWisf < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
        
      return @elems[0].interprete(symTable)

    end
end

#Clase para la ejecución de bloques en un program
class InstWis < InstWisf
    def interprete(symTable)  
        return @elems[0].interprete(symTable)
    end
end

#Clase de la instrucción del return
class InstReturn < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end

    def interprete(symTable)
        return @elems[0].interprete(symTable)
    end
end

#Clase para la ejecución de isntrucciones de asignacion
class InstAsign < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
       @elems[0].interprete(symTable)
    end
end

#Clase para las asignaciones
class Assign < Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
        #Se guarda el identificador a asignar
        idVar = @elems[0].term.id
        #Se calcula el valor que tendrá idVAr
        valor = @elems[1].interprete(symTable)
        #Se busca el tipo con el que fue declarado para luego actualizar la tabla de símbolos
        tipo = symTable.lookup(idVar)[0]
        symTable.update(idVar, [tipo, valor])

    end
end

#Clase par imprimir una lista de argumentos de una función. Su impresión es igual que la de Bloque
class ListD < Bloque;end

#Clase para las instruccion Write
class Write<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
        #Se retorna el valor procesado a imprimir
        return elems[0].interprete(symTable)
    end
end

#Clase para las instrucciones Write
class WriteSalto<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
        #Se retorna el valor procesado a imprimir
        elems[0].interprete(symTable)
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
    def interprete(symTable)
        #Se imprime el lado derecho de la coma
        val = @elems[0].interprete(symTable).to_s
        case val
        when /^"[a-zA-Z\d\s[[:punct:]]]*"/
            val.gsub!(/"/,'')

            print val
        else
            print val
        end

        #Si hay lado izquirdo se imprime
        if @elems[1] != nil
             val = @elems[1].interprete(symTable).to_s
            case val
            when /^"[a-zA-Z\d\s[[:punct:]]]*"/
                val.gsub!(/"/,'')
                print val
            else
                print val
            end
        end
    end
end

#Clase para la ejecusión  de Writeln
class Writable2<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
        #Se imprime el lado derecho de la coma
        val = @elems[0].interprete(symTable).to_s
        case val
        when /^"[a-zA-Z\d\s[[:punct:]]]*"/
            val.gsub!(/"/,'')
            puts val
        else
            puts val
        end

        #Si hay lado izquirdo se imprime
        if @elems[1] != nil
             val = @elems[1].interprete(symTable).to_s
            case val
            when /^"[a-zA-Z\d\s[[:punct:]]]*"/
                val.gsub!(/"/,'')
                puts val
            else
                puts val
            end
        end
    end
end

#Clase para la ejecución de Asignaciones
class Asignable_Expr<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
        #Se llama al interprete de Expresiones
        return elems[0].interprete(symTable)
    end
end

#Clase para la ejecución de llamadas a funciones
class Call<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
    end
    def interprete(symTable)
        nombreFunc=@elems[0].term.id
        parametros = nil
        if @elems[1]!=nil
           parametros = @elems[1].interprete(symTable)
        end
        tipoRetorno = symTable.lookup(nombreFunc)[0]

        #Se busca la tabla de símbolos de la función, para así 
        # tener la tabla a la que pertenece y ejecutar el método interpretar
        $Tablas.each do |t|
            if (t.nombre == "Alcance "+ nombreFunc)

                clase = t.clase
                  
                llamada = clase.interprete(symTable,parametros)
                if llamada==nil and tipoRetorno!= nil
                    raise ExecError.new "No se encontró valor de Retorno para función '#{nombreFunc}'"
                end
                return llamada
                break
            end
        end
    end

end


#Clase para las instrucciones de Retorno
class Retorno<Bloque
    attr_accessor :types
    attr_accessor :elems
    def initialize(type1,elem1,type2=nil,elem2=nil)
        @types=[type1,type2]
        @elems=[elem1,elem2]
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

#Clase para la lista de instrucciones 
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
        #Si la lista no está vacía se ejecuta
        if @list != nil
            @list.interprete(symTable)
        end
        #Se retorna el valor  que retornó la ejecución de la primera instrucción
        return @elem.interprete(symTable)
    end
end

#Clase para la manejar la lista de funciones definidas
class ListaFunc<ListaInst
    def interprete(symTable)
        #if @elem.elems[0].term.id == $nombreFunc
            @elem.interprete(symTable)
        #end
        if (@list!=nil)
            @list.interprete(symTable)
        end
    end
end

#Clase para la impresion de Lista de Parámetros de una llamada de de funcion
class ListParam<ListaInst
    attr_accessor :type
    attr_accessor :elem
    attr_accessor :list
    def initialize(type,elem,list=nil)
        @list=list
        @type=type
        @elem=elem
    end
    def interprete(symTable)
        parametro=@elem.interprete(symTable)
        parametros=[parametro]
        if @list !=nil
            return parametros + (@list.interprete(symTable))
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

    def interprete(symTable)
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
    def interprete(symTable)
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
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo + derecho
    end
end
#Clase de restas
class BinExpResta <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo - derecho
    end
end
#Clase de multiplicaciones
class BinExpMult <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo * derecho
    end
end
#Clase de /
class BinExpDiv2 <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: División por cero"
        else
            return (izquierdo).fdiv(derecho)
        end
    end
end
#Clase de %
class BinExpMod2 <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: Resto exacto de cero"
        else
            return (izquierdo) % (derecho)
        end
    end
end
#Clase de div
class BinExpDiv <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
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
    def interprete(symTable)

        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        if derecho == 0
            raise ExecError.new "No es posible completar la operación: Resto exacto de cero"
        else
            return izquierdo.to_i.modulo(derecho)
        end
    end
end

#Clase del or
class BinExpOr <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo || derecho
    end
end

#Clase del and
class BinExpAnd <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo && derecho
    end
end

#Clase del < 
class BinExpLT < BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo < derecho
    end
end
#Clase del >
class BinExpGT <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo > derecho
    end
end

#Clase del <
class BinExpLET <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo <= derecho
    end
end

#Clase del >=
class BinExpGET <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo >= derecho
    end
end

#Clase del /=
class BinExpDist <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
        return izquierdo != derecho
    end
end

#clase del ==
class BinExpEQ <BinExp
    def interprete(symTable)
        izquierdo = @elems[0].interprete(symTable)
        derecho =  @elems[1].interprete(symTable)
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

    def interprete(symTable)
        if op == :Inverso_Aditivo
            return - @elem.interprete(symTable)
        elsif op == :Negacion
            return !@elem.interprete(symTable)
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

    def interprete(symTable)
        return @expr.interprete(symTable)
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

    def interprete(symTable)
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
