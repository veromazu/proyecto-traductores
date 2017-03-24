#! /usr/local/bin/ruby
# encoding: utf-8
=begin

UNIVERSIDAD SIMÓN BOLÍVAR
Traductores e Interpretadores
Fase 3 de Proyecto : Parser de Retina
Elaborado por:
	-Verónica Mazutiel, 13-10853
	-Melanie Gomes, 13-10544

=end


require_relative "tablaSimbolos"
require_relative "retina_ast"

$symTable = nil		# Tabla de simbolos.
$tableStack = []	# Pila de tablas.

################################################
# Manejo de la estructura general del programa #
################################################
class Analizador
	def initialize(ast)
		@ast=ast
	end
	# Manejador del programa principal.
	def program_Handler
		scope_Handler(@ast.scope)
	end

	#Manejador de alcances
	#scope es del tipo scope
	def scope_Handler(scope)
		# Asignación de una nueva tabla.
		symTableAux = SymbolTable.new("Programa principal",$symTable)
		$symTable = symTableAux


		listFuncError = 0
		if (scope.elems[0]!=nil)
			listFuncError = listFunc_Handler(scope.elems[0])
		end
		progError = prog_Handler(scope.elems[1])
		$tableStack << $symTable
		$symTable = $symTable.father

		if ($symTable == nil)

			puts "Tabla de Simbolos"
			$tableStack.reverse!
			$tableStack.each do |st|
				st.print_Table
			end
		end
	end

	#Manejador de lista de Funciones.
	#elem es de la clase ListaFunc
	def listFunc_Handler(elem)

		nombreF_Handler(elem.elem.elems[0])

		Func_Handler(elem.elem)
		listFuncError = 0
		if (elem.list!=nil)
			listFunc_Handler(elem.list)
		end

		return 
	end

	#Manejador de Program
	#elem es del tipo Linst
	def prog_Handler(elem)

		if (elem.list!=nil)
			LInst_Handler(elem.list)
		end
		Inst_Handler(elem.elem)
	end

	########################################################
	# Manejo de declaraciones e instrucciones de funciones #
	########################################################

	#Manejador de Funciones
	#func es de la clase Func
	def Func_Handler(func)
		namefunc= func.elems[0].term.id

		# Asignación de una nueva tabla.
		symTableAux = SymbolTable.new("Alcance #{namefunc}",$symTable)
		$symTable = symTableAux

		if (func.elems[1] != nil)
			param_Handler(namefunc,func.elems[1])
		end

		if (func.elems[2] != nil)
			tipoRetorno = func.elems[2].elems[0].val.symbol
			$symTable.update(namefunc,[tipoRetorno,[]])
		end

		if (func.elems[3] != nil)

			FInst_Handler(namefunc,func.elems[3])   
		end

		# Se empila la tabla del scope en la pila de tablas.
		$tableStack << $symTable
		$symTable = $symTable.father

	return  
	end

	#Manejador de una lista de parámetros de una función
	#param es de la clase ListD o de la clase List
	def param_Handler(nombre,param)

		if param.instance_of?(ListD)
			paramDec_Handler(nombre,param.elems[0],param.elems[1].term.id)

		end
		if param.instance_of?(List)
			paramDec_Handler(nombre,param.elems[0],param.elems[1].term.id)
			param_Handler(nombre,param.list)
		end
	end


	#Manejador de parámetros en la definición de una función
	def paramDec_Handler(nombre,type,id)
		type=type.val.symbol

		if !($symTable.contains(id))
			$symTable.insert(id, [type, nil])
			$symTable.param << type 
		
		else
			raise SemanticError.new ("variable '#{id}' fue declarada antes " \
					" para la misma Funcion.")
		end
	end

	#Manejador de instrucciones de funciones
	#FuncInst es de la clase funcInst
	def FInst_Handler(namefunc,funcInst) 

		if (funcInst != nil)
			LInstF_Handler(namefunc,funcInst)
		end
	end

	#Manejador de lista de instrucciones denntro de una funcion
	#LInstf es de la clase ListaInst
	def LInstF_Handler(namefunc,lInstf)
		InstF_Handler(namefunc,lInstf.elem)
		
		if (lInstf.list != nil)
			LInstF_Handler(namefunc,lInstf.list)
		end

	end

	#Manejador de una instruccion dentro de una funcion
	#instr es de la clase Inst
	def InstF_Handler(namefunc, instr)
	case instr.types[0]
		when :Bloque
			bloqueF_Handler(namefunc,instr.elems[0]) #listo
		when  :Retorno
			return_Handler(namefunc,instr.elems[0])
		when :Asignacion
			asign_Handler(instr.elems[0].elems[0].term.id,instr.elems[0].elems[1]) #listo
		when :Iteracion
			iteratorF_Handler(namefunc,instr.elems[0]) #listo
		when :Lectura
			lect_Handler(instr.elems[0]) #listo
		when :Salida
			salida_Handler(instr.elems[0])    ### Escrita pero no probada por problema de expry falta call
		when :Salida_Con_Salto
			salida_Handler(instr.elems[0])  ## Escrita pero no probada por expr y call
		when :Condicional
			condF_Handler(namefunc,instr.elems[0])
		when :Llamada_de_Funcion
			llamada_Handler(instr.elems[0])
		when :Expresion
			expr_Handler(instr.elems[0]) 
		end
	end

	#Manejador de instrucciones de retorno dentro de una funcion
	#expr es de la clase Expr
	def return_Handler(namefunc,expr)
		typeExpr = expression_Handler(expr)
		if typeExpr == :TYPEN
			tipoExpr = "number"
		elsif typeExpr == :TYPEB
			tipoExpr = "boolean"
		end

		typeRet = $symTable.lookup(namefunc)[0]

		if typeRet == nil
			raise SemanticError.new "tipo de retorno '#{tipoExpr}' inesperado para '#{namefunc}'"

		elsif typeRet != typeExpr
			if typeRet== :TYPEN
				tipoRetorno= "number"
			elsif typeRet == :TYPEB
				tipoRetorno = "boolean"
			end
			raise SemanticError.new "tipo de retorno '#{tipoExpr}' inesperado para '#{namefunc}', se esperaba tipo de retorno '#{tipoRetorno}'"
		end
	end

	#Manejador de nombres de funciones
	#func es del tipo var
	def nombreF_Handler(func)
		nombre = func.term.id
		if ($symTable.lookup(nombre)==nil)
			#pos[0] tipo ret
			#pos [1] arreglo de tipos de parametros
			($symTable.insert(nombre,[nil,nil]))
		else 
			raise SemanticError.new " Funcion '#{nombre}' previamente declarada"
		end	 
	end 

	#Manejador de Bloques with dentro de una función
	def bloqueF_Handler(namefunc,wis)
		nivel_alcance = $symTable.cont
		if nivel_alcance == nil
			nivel_alcance = 0
		end
		symTableAux = SymbolTable.new("Alcance",$symTable,nil,nivel_alcance + 1)
		$symTable = symTableAux


		if (wis.elems[0] !=nil)
			decl_Handler(wis.elems[0])

		end
		if (wis.elems[1] !=nil)
			LInstF_Handler(namefunc,wis.elems[1])
		end
		$tableStack << $symTable
		$symTable = $symTable.father

		if ($symTable == nil)

			puts "Subalcances:"
			$tableStack.reverse!
			$tableStack.each do |st|
				st.print_Table
			end
		end

	end

	#Manejador de iteradores dentro de una función
	def iteratorF_Handler(namefunc,iter)
		iter_error = 0
		expr = iter.elems[0]
		inst = iter.elems[1]
		case iter.type1

		when :Ciclo_While
			if (expression_Handler(expr)!= :TYPEB)
				raise SemanticError.new " Se esperaba condicion del tipo 'boolean'"
			else
				LInstF_Handler(namefunc,inst)
			end

		
		when :Ciclo_Repeat

			if (expression_Handler(expr)!= :TYPEN)
				raise SemanticError.new " Se esperaba expresion del tipo 'number'"

			else
				LInstF_Handler(namefunc,inst)
			end

		when :Ciclo_For
			symTableAux = SymbolTable.new("Ciclo_For",$symTable)
			$symTable = symTableAux
			var = iter.elems[0].term.id
			expr = iter.elems[1]
			expr2 = iter.elems[2]
			by = iter.elems[3]
			inst = iter.elems[4]
			$symTable.insert(var,[:TYPEN,nil])

			if (by != nil)
				if ((expression_Handler(expr) != :TYPEN) or (expression_Handler(expr2) != :TYPEN))
					raise SemanticError.new " Se esperaba rango del tipo 'number'"
					
				end
				if 	(expression_Handler(by.salto)!= :TYPEN)
					raise SemanticError.new "Se esperaba salto 'by' del tipo 'number'"
					
				else
					LInstF_Handler(namefunc,inst) 
				end 	
			else
				if ((expression_Handler(expr) != :TYPEN) or (expression_Handler(expr2) != :TYPEN))
					raise SemanticError.new "Se esperaba rango del tipo 'number'"
				else 
					LInstF_Handler(namefunc,inst) 
				end 
			end
			$tableStack << $symTable
			$symTable = $symTable.father
		end
	end 

	#Manejador de condicionales dentro de una función
	def condF_Handler(namefunc,cond)

		expr = cond.elems[0]
		inst1 = cond.elems[1]
		inst2 = cond.elems[2]


		if (expression_Handler(expr)!= :TYPEB)
			raise SemanticError.new " La condicion debe ser del tipo : 'boolean'"
		else
			LInstF_Handler(namefunc,inst1) 
		end
		if (inst2 != nil)
			LInstF_Handler(namefunc,inst2) 
		end

	end



	#Manejador de lista de instrucciones de un porgram
	def LInst_Handler(elem)


		if (elem.list!=nil)
			LInst_Handler(elem.list) 
		end
		
		Inst_Handler(elem.elem)
	end

	#Manejador de instrucciones
	def Inst_Handler(instr)
		case instr.types[0]
		when :Bloque
			bloque_Handler(instr.elems[0]) 
		when :Asignacion
			asign_Handler(instr.elems[0].elems[0].term.id,instr.elems[0].elems[1]) 
		when :Iteracion
			iterator_Handler(instr.elems[0])
		when :Lectura
			lect_Handler(instr.elems[0]) 
		when :Salida
			salida_Handler(instr.elems[0])  
		when :Salida_Con_Salto
			salida_Handler(instr.elems[0]) 
		when :Condicional
			cond_Handler(instr.elems[0])
		when :Llamada_de_Funcion
			llamada_Handler(instr.elems[0])
		when :Expresion	
			expr_Handler(instr.elems[0]) 	
		end
	end

	############################################
	# Manejo de las instrucciones del programa #
	############################################

	#Manejador de llamadas de funciones
	def llamada_Handler(llamada)
		func = llamada.elems[0].term.id
		parametros = llamada.elems[1]

		$funcionParam = [] 

		case func
		when "home", "closeeye", "openeye"
			if (parametros != nil)
				raise SemanticError.new "Cantidad inválida de argumentos para '#{func}'"
			end
		when "forward", "backward", "rotater", "rotatel"
			if (parametros !=nil)
				if (parametros.list!=nil)
					raise SemanticError.new " Cantidad inválida de argumentos para '#{func}'"
				else
					tipo=expression_Handler(parametros.elem)
					if (tipo != :TYPEN)
						if tipo == :TYPEB
							raise SemanticError.new " Argumento inválido boolean para '#{func}'"
						else 
						end
					end
				end
			else
				raise SemanticError.new "Cantidad inválida de argumentos para '#{func}'"
			end

		when "setposition", "arc"
			if (parametros !=nil)
				if (parametros.list==nil or parametros.list.list!=nil)
					raise SemanticError.new " Cantidad inválida de argumentos para '#{func}'"
				else 
					tipo1 = expression_Handler(parametros.elem)
					tipo2 = expression_Handler(parametros.list.elem)
					if (tipo1 != :TYPEN )
						if (tipo1 == :TYPEB )
							raise SemanticError.new " Argumento inválido boolean para '#{func}'"
						else
							raise SemanticError.new " Argumento inválido para '#{func}'"
						end

					elsif (tipo2 != :TYPEN)
						if (tipo2 == :TYPEB )
							raise SemanticError.new  " Argumento inválido boolean para'#{func}'"
						end
					end
				end
			end
		else
			if ($symTable.lookup(func) != nil)
				$cantArgFunc = 0
				$tableStack.each do |t|

					if (t.nombre == "Alcance "+ func)
						tablafunc = t 
						$cantArgFunc = tablafunc.param.size
						$funcionParam = tablafunc.param
						break
					end
				end
				#Cálculo de cantidad de argumentos en la llamada
				cantArgCall = 0
				if (parametros == nil)
					cantArgCall = 0
				else
					if parametros.list != nil
						cantArgCall = 2
						aux=parametros.list
						while (aux.list!=nil)
							cantArgCall += 1
							aux = aux.list
						end
					else
						cantArgCall =1
					end

				end

				#Error de cantidad de argumentos
				if cantArgCall != $cantArgFunc
					raise SemanticError.new " Cantidad inválida de argumentos para '#{func}'"

				#Error por tipo de argumentos
				else
					for i in 0..($cantArgFunc-1)
						aux = parametros.elem
						tipoCall = expression_Handler(aux)
						tipoDef = $funcionParam[i]
						if tipoCall != tipoDef
							if tipoCall == :TYPEN	
								tipo = "number"
							elsif tipoCall == :TYPEB
								tipo = "boolean"
							end
							raise SemanticError.new "Argumento inválido '#{tipo}' para '#{func}'"
						end
						parametros = parametros.list

					end
				end
			else 
				raise SemanticError.new llamada.elems[0].term," Funcion #{func} no declarada"
			end
		end
	end

	#Manejador de iteradores
	def iterator_Handler(iter)

		expr = iter.elems[0]
		inst = iter.elems[1]
		case iter.type1

		when :Ciclo_While
			if (expression_Handler(expr)!= :TYPEB)
				raise SemanticError.new "Se esperaba condicion del tipo 'boolean'"
			else
				LInst_Handler(inst)
			end
		
		when :Ciclo_Repeat

			if (expression_Handler(expr)!= :TYPEN)
				raise SemanticError.new " Se esperaba expresion del tipo 'number'"
			else
				LInst_Handler(inst)
			end
		when :Ciclo_For
			symTableAux = SymbolTable.new("Ciclo_For",$symTable)
			$symTable = symTableAux
			var = iter.elems[0].term.id
			expr = iter.elems[1]
			expr2 = iter.elems[2]
			by = iter.elems[3]
			$symTable.insert(var,[:TYPEN,nil])

			inst = iter.elems[4]

			
			if (by != nil)
				if ((expression_Handler(expr) != :TYPEN) or (expression_Handler(expr2) != :TYPEN))
					raise SemanticError.new "Se esperaba rango del tipo 'number'"

				end
				if 	(expression_Handler(by.salto)!= :TYPEN)
					raise SemanticError.new " Se esperaba salto 'by' del tipo 'number'"

				else
					LInst_Handler(inst) 
				end 	
			else
				if ((expression_Handler(expr) != :TYPEN) or (expression_Handler(expr2) != :TYPEN))
					raise SemanticError.new "Se esperaba rango del tipo 'number'"
				else 
					LInst_Handler(inst) 
				end 
			end
			$tableStack << $symTable
			$symTable = $symTable.father
		end
	end 

	#Manejador de instrucciones Read
	def lect_Handler(lect)
		var = lect.term.id
		if ($symTable.lookup(var)==nil)
			raise SemanticError.new " Variable '#{var}' no declarada en este alcance"
		end
	end

	#Manjador de instrucciones Write
	def salida_Handler(write)
		valType = write.types[0]
		case valType
		when :Expresion
			expr_Handler(write.elems[0])
		when :Call 
			llamada_Handler(write.elems[0])
		when :valor
			salida_Handler(write.elems[0])
			salida_Handler(write.elems[1])
		end
	end

	#Manejador de Consdicionales
	def cond_Handler(cond)
		expr = cond.elems[0]
		inst1= cond.elems[1]
		inst2= cond.elems[2]


		if (expression_Handler(expr)!= :TYPEB)
			raise SemanticError.new " La condicion debe ser del tipo : 'boolean'"

		else
			LInst_Handler(inst1) 
		end
		if (inst2 != nil)
			LInst_Handler(inst2) 
		end
	end

	#MAnejador de bloques with
	def bloque_Handler(wis)
		nivel_alcance = $symTable.cont
		if nivel_alcance == nil
			nivel_alcance = 0
		end
		symTableAux = SymbolTable.new("Alcance",$symTable,nil,nivel_alcance + 1)
		$symTable = symTableAux


		if (wis.elems[0] !=nil)
			decl_Handler(wis.elems[0])

		end
		if (wis.elems[1] !=nil)
			LInst_Handler(wis.elems[1])
		end
		$tableStack << $symTable
		$symTable = $symTable.father
	end



	# Manejador de instrucciones de declaración
	def decl_Handler(decl)

		case decl.types[1]
		when :asignacion
			
			decAsig_Handler(decl.elems[1],decl.elems[0].val.symbol) 
			
		when :Lista_ID
			type=decl.elems[0].val.symbol
			lista=decl.elems[1]

			ListI_Handler(type,lista)
		end
		listD = decl.elems[2]
		dListError = 0
		if (listD != nil)
			decl_Handler(listD)
		end
	end

	#Manejador de Asignaciones en una declaracion
	def decAsig_Handler(dec,type)

		nameVar = dec.elems[0].term.id
		asignable = dec.elems[1]

		
		if ($symTable.lookup(nameVar)==nil)
			$symTable.insert(nameVar,[type,nil])

			asign_Handler(nameVar,asignable) 
		else 
			raise SemanticError.new " variable '#{dec.elems[0].term.id}' fue declarada antes" \
					" en el mismo alcance."
		end
	end

	#### Manejador de Asignaciones #####
	#idVar es del tipo term.id
	#asig es de la clase asignable
	def asign_Handler(idVar,asig)

		tipoAsig = asig.types[0]
		valAsig = asig.elems[0]
		if ($symTable.lookup(idVar)==nil)
			raise SemanticError.new " variable '#{idVar}' no ha sido declarada."
		else 
			typeVar=$symTable.lookup(idVar)[0]
			case tipoAsig
			when :Expresion
				
				typeExpr=expression_Handler(valAsig)


				if(typeVar != typeExpr)

					if typeExpr == :TYPEN
						tipoExpr = "number"
					elsif typeExpr == :TYPEB
						tipoExpr = "boolean"
					end

					if typeVar == :TYPEN
						tipoVar = "number"
					elsif typeVar == :TYPEB
						tipoVar = "boolean"
					end

					raise SemanticError.new " Expresion de tipo '#{tipoExpr}' y se esperaba una de tipo '#{tipoVar}' para variable '#{idVar}'."
				end

			when :Llamada_de_Funcion
				valAsig=valAsig.elems[0]
				typeCall_Handler(valAsig,typeVar)
			end
		end
	end

	#Manejador de tipo de valor de retorno al hacer una asigncion a un llamada de función
	def typeCall_Handler(valAsig,typeVar)

		funcNombre = valAsig.term.id
		funcion = $symTable.lookup(funcNombre)
		if (funcion != nil)
			tipo = funcion[0]
			if typeVar == :TYPEN
				tipoVar = "number"
			elsif typeVar == :TYPEB
				tipoVar = "boolean"
			end
			if tipo != typeVar
				raise SemanticError.new " Expresion de tipo '#{tipoVar}' inválido para '#{funcNombre}'. "
			end
		else
			raise SemanticError.new " Funcion '#{funcNombre}' no declarada"
		end
	end

	#Manejador de lista de identificadores 
	def ListI_Handler(type,list)
		id=list.elem.term.id
		listID=list.list

		if !($symTable.lookup(id))
			$symTable.insert(id, [type, nil])
			if (listID!= nil)
				ListI_Handler(type,listID)
			end
		else
			raise SemanticError.new " variable '#{id}' fue declarada antes " \
					" en el mismo alcance."
		end
	end

	#Manejador de instrucciones como expresión
	def expr_Handler(expr)
		if expression_Handler(expr) == nil
			raise SemanticError.new "ERROR: Error en los tipos de la expresion"
		end
	end

	# Función que dada una expresión retorna su tipo
	def expression_Handler(expr)
		# Procesar como binaria
		if expr.instance_of?(BinExp)
			return binExp_Handler(expr)
		# Procesar como unaria
		elsif expr.instance_of?(UnaExp)
			return unaExp_Handler(expr)
		# Procesar como parentizada
		elsif expr.instance_of?(ParExp)
			return parExp_Handler(expr)
		# Procesar como un caso base, un termino.
		elsif expr.instance_of?(Terms)
			type = expr.nameTerm
			case type
			when :ID		
				idVar = expr.term.id
				typeVar = $symTable.lookup(idVar)
				if typeVar!=nil
					typeVar = typeVar[0]
				else
					raise SemanticError.new " Variale '#{idVar}' no declarada en este entorno"
				end
				return typeVar
			when :DIGIT
				return :TYPEN
			when :TRUE
				return :TYPEB
			when :FALSE
				return :TYPEB	
			end
		else
			raise SemanticError.new "Hubo un error expression_Handler."	
		end

	end


	# Manejador de expresiones binarias:
	# Devuelve el tipo de las expresiones binarias
	# => si hay un error de tipo, devuelve nil.
	def binExp_Handler(expr)
		typeExpr1 = expression_Handler(expr.elems[0])
		typeExpr2 = expression_Handler(expr.elems[1])

		 #ver para imprimir fila y columna de error
		case expr.op
		when :Suma,:Resta,:Multiplicacion

			if (typeExpr1 == :TYPEN) and (typeExpr2 == :TYPEN)
				return :TYPEN 
			elsif (typeExpr1 == :TYPEB) 
				raise SemanticError.new "Tipo de expresión 'boolean' inesperado para operador aritmético" 
			elsif (typeExpr2 == :TYPEB)
				raise SemanticError.new "Tipo de expresión 'boolean' inesperado para operador aritmético"
			end
		when :Menor_que,:Mayor_que,:Menor_O_Igual_Que,:Mayor_O_Igual_Que,:Distinto_que
			if (typeExpr1 == :TYPEN) and (typeExpr2 == :TYPEN)
				return :TYPEB

			elsif (typeExpr1 == :TYPEB) and (typeExpr2 == :TYPEB)
				return :TYPEB
			else
				raise SemanticError.new "Tipos de expresión distintos para operación de comparación"
			end

		when :Or,:And
			if (typeExpr1 == :TYPEB) and (typeExpr2 == :TYPEB)
				return :TYPEB
			else
				raise SemanticError.new "Tipos de expresión distintos para operación de comparación"
			end
		when :Equivalencia,:Distinto_que
			if (typeExpr1 == :TYPEN) and (typeExpr2 == :TYPEN)
				return :TYPEB
			elsif (typeExpr1 == :TYPEB) and (typeExpr2 == :TYPEB)
				return :TYPEB
			else
				raise SemanticError.new "Tipos de expresión distintos para operación de comparación"
			end
		when :Division_Exacta,:Resto_Exacto,:Division_Entera,:Resto_Entero
			if (typeExpr1 == :TYPEN) and (typeExpr2 == :TYPEN)
				return :TYPEN
			elsif (typeExpr1 == :TYPEB) 
				raise SemanticError.new "Tipo de expresión 'boolean' inesperado para operador aritmético"
			elsif (typeExpr2 == :TYPEB)
				raise SemanticError.new "Tipo de expresión 'boolean' inesperado para operador aritmético"
			end 	 		 	 
		end
	end

	# Manejador de expresiones parentizadas.
	def parExp_Handler(expr)
		return expression_Handler(expr.expr)
	end

	# Manejador de expresiones unarias.
	# Devuelve el tipo de las expresiones unarias
	# => si hay un error de tipo, devuelve nil.
	def unaExp_Handler(expr)
		typeExpr = expression_Handler(expr.elem)
		case expr.op
		when :Inverso_Aditivo
			if typeExpr == :TYPEN
				return :TYPEN
			else
				raise SemanticError.new "Tipo de expresión 'boolean' inesperado para operador iverso aditivo : '-'"
			end
		when :Negacion
			if typeExpr == :TYPEB
				return :TYPEB
			else
				raise SemanticError.new "Tipo de expresión 'number' inesperado para operador 'not'"
			end
		end
	end


		# Raise semantic error if found
	def on_error(id, token, stack)
    	raise SemanticError::new(token)
	end


	class SemanticError < RuntimeError

	    def initialize(tok,info)
	        @info=info
	        @token=tok
	    end

	    def to_s
	    	#Línea #{token.position[0]}, Column #{token.position[1]}
	    	puts "ERROR: Línea #{@token.position[0]}, Column #{@token.position[1]}: #{@info}"
	    end
	end
end