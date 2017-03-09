require_relative "tablaSimbolos"
require_relative "retina_ast"

$symTable = nil		# Tabla de simbolos.
$tableStack = []	# Pila de tablas.

################################################
# Manejo de la estructura general del programa #
################################################

# Manejador del programa principal.
def program_Handler(ast)
	scope_Handler(ast.scope)
end

#Manejador de alcances
def scope_Handler(scope)


	listFuncError = 0
	if (scope.elems[0]!=nil)
		listFuncError = listFunc_Handler(scope.elems[0])
	end
	progError = prog_Handler(scope.elems[1])



	return listFuncError + progError
end

#Manejador de lista de Funciones.
def listFunc_Handler(elem)
	# Asignación de una nueva tabla.
	symTableAux = SymbolTable.new($symTable)
	$symTable = symTableAux

	#Manejo de la esperabatructura.
	nombreError = nombreF_Handler(elem.elem.elems[0])

	funcError =  Func_Handler(elem.elem)
	listFuncError = 0
	if (elem.list!=nil)
		listFuncError = listFunc_Handler(elem.list)
	end
	# Se empila la tabla del scope en la pila de tablas.
	$tableStack << $symTable
	$symTable = $symTable.father
	# Si ya se analizo todo el programa, se imprimen cada
	# de las tablas (si no hubo errores).
	if ($symTable == nil)
		if (funcError > 0) or (listFuncError > 0)
			puts "Symbol table will not be shown."
			abort
		end
		puts "Symbol Table:list func"
		$tableStack.reverse!
		$tableStack.each do |st|
			st.print_Table
		end
	end
	return listFuncError + funcError
end
#Manejador de Funciones
def Func_Handler(func)
	# Asignación de una nueva tabla.
	symTableAux = SymbolTable.new($symTable)
	$symTable = symTableAux


	

	paramsError = 0
	if (func.elems[1] != nil)
		paramsError = param_Handler(nombre,func.elems[1])
	end

	# Se empila la tabla del scope en la pila de tablas.
	$tableStack << $symTable
	$symTable = $symTable.father
	# Si ya se analizo todo el programa, se imprimen cada
	# de las tablas (si no hubo errores).
	if ($symTable == nil)
		if (nombreError > 0) or (param_Error > 0)
			puts "Symbol table will not be shown."
			abort
		end
		puts "Symbol Table: func"
		$tableStack.reverse!
		$tableStack.each do |st|
			st.print_Table
		end
	end




=begin
typeRError = 0
if (func.elems[2] != nil)
	typeRError = typeR_Handler(func.elems[2])
end
fInsError = 0
if (func.elems[3] != nil)
	fInsError = LInst_Handler(func.elems[3])    #### Acá revisar que sea directo con LInst o necesito un manejador para FInst.
end
=end
return 0 #+ paramsError + typeRError + fInsError
end

def param_Handler(nombre,param)
	puts "ENTRO"
	
	#decl = param.
end

#Manejador de nombres de funciones
def nombreF_Handler(func)
	nombre = func.term.id
	if ($symTable.lookup(nombre)==nil)
		#pos[0] tipo ret
		#pos [1] arreglo de tipos de parametros
		($symTable.insert(nombre,[nil,nil]))
		return 0 
	else 
		puts "ERROR: Funcion '#{nombre}' previamente declarada"
		return 1
	end	 
end 

#Manejador de lista de instrucciones de una función
def LInst_Handler(elem)
	instError =  Inst_Handler(elem.elem)

	listInstError = 0
	if (elem.list!=nil)
		listInstError= LInst_Handler(elem.list)
	end
	return listInstError + instError
end

#Manejador de Program
def prog_Handler(elem)
	# Asignación de una nueva tabla.
	symTableAux = SymbolTable.new($symTable)
	$symTable = symTableAux

	instError =  Inst_Handler(elem.elem)
	listInstError = 0
	if (elem.list!=nil)
		listInstError= LInst_Handler(elem.list)
	end
		$tableStack << $symTable
	$symTable = $symTable.father
	# Si ya se analizo todo el programa, se imprimen cada
	# de las tablas (si no hubo errores).
	if ($symTable == nil)
		if (instError > 0) or (listInstError > 0)
			puts "Symbol table will not be shown."
			abort
		end
		puts "Symbol Table: prog"
		$tableStack.reverse!
		$tableStack.each do |st|
			st.print_Table
		end
	end

	return listInstError + instError
end

#Manejador de instrucciones
def Inst_Handler(instr)
	case instr.types[0]
	when :Bloque
		return bloque_Handler(instr.elems[0]) #listo
	when  :Retorno
		return return_Handler(instr.elems[0])
	when :Asignacion
		return asign_Handler(instr.elems[0].elems[0].term.id,instr.elems[0].elems[1]) #listo
	when :Iteracion
		return iterator_Handler(instr.elems[0]) #listo
	when :Lectura
		return lect_Handler(instr.elems[0]) #listo
	when :Salida
		return salida_Handler(instr.elems[0])    ### Escrita pero no probada por problema de expry falta call
	when :Salida_Con_Salto
		return salida_Handler(instr.elems[0])  ## Escrita pero no probada por expr y call
	when :Condicional
		return cond_Handler(instr.elems[0])
	when :Llamada_de_Funcion
		return llamada_Handler(instr.elems[0])
	when :Expresion
		return expr_Handler(instr.elems[0]) 
	end
end

############################################
# Manejo de las instrucciones del programa #
############################################

#Manejador de iteradores
def iterator_Handler(iter)
	iter_error = 0
	expr = iter.elems[0]
	inst = iter.elems[1]
	case iter.type1

	when :Ciclo_While
		if (expression_Handler(expr)!= :TYPEB)
			puts "ITERATION ERROR: Se esperaba condicion del tipo 'boolean'"
			return 1
		else
			iter_error = LInst_Handler(inst)
		end
			return iter_error
	
	when :Ciclo_Repeat

		if (expression_Handler(expr)!= :TYPEN)
			puts "ITERATION ERROR: Se esperaba expresion del tipo 'number'"
			return 1
		else
			iter_error = LInst_Handler(inst)
		end
			return iter_error
	when :Ciclo_For
		expr = iter.elems[1]
		expr2 = iter.elems[2]
		by = iter.elems[3]
		puts "#{by} soy byyyyy"
		inst = iter.elems[4]
		err=0
		
		if (by != nil)
			if ((expression_Handler(expr) != :TYPEN) or (expression_Handler(expr2) != :TYPEN))
				puts "ITERATION ERROR: Se esperaba rango del tipo 'number'"
				err = 1
			end
			if 	(expression_Handler(by.salto)!= :TYPEN)
				puts "ITERATION ERROR: Se esperaba salto 'by' del tipo 'number'"
				err += 1
			else
				iter_error = LInst_Handler(inst) 
			end 	
		else
			if ((expression_Handler(expr) != :TYPEN) or (expression_Handler(expr2) != :TYPEN))
				puts "ITERATION ERROR: Se esperaba rango del tipo 'number'"
				error = 1
			else 
				iter_error = LInst_Handler(inst) 
			end 
		end
	end
	return err
end 

def lect_Handler(lect)
	var= lect.term.id
	if ($symTable.lookup(var)==nil)
		puts "variable #{var} no declarada en este alcance"
		return 1
	else
		return 0
	end

end

def salida_Handler(write)
	valType = write.types[0]
	case valType
	when :Expresion
		return expr_Handler(write.elems[0])
	when :Call 
		return llamada_Handler(write.elems[0])
	when :valor
		return salida_Handler(write.elems[0]) + salida_Handler(write.elems[1])
	end
end


def cond_Handler(cond)
	cond_error = 0
	expr = cond.elems[0]
	inst1= cond.elems[1]
	inst2= cond.elems[2]
	puts inst2

	if (expression_Handler(expr)!= :TYPEB)
		puts "CONDITIONAL ERROR : La condicion debe ser del tipo : 'boolean'"
	else
		cond_error = LInst_Handler(inst1) #Aqui explota si es una expr
	end
	if (inst2 != nil)
		cond_error = cond_error +	LInst_Handler(inst2) 
	end

	return cond_error
end


def bloque_Handler(wis)
	symTableAux = SymbolTable.new($symTable)
	$symTable = symTableAux
	declError=0
	if (wis.elems[0] !=nil)
		declError = decl_Handler(wis.elems[0])

	end
	listInstError=0

	if (wis.elems[1] !=nil)
		listInstError =  LInst_Handler(wis.elems[1])
	end
	$tableStack << $symTable
	$symTable = $symTable.father

	if ($symTable == nil)
		if (declError > 0) or (listInstError > 0)
			puts "No se mostrara la tabla de simbolos"
			abort
		end
		puts "Tabla de Simbolos"
		$tableStack.reverse!
		$tableStack.each do |st|
			st.print_Table
		end
	end

	return declError + listInstError

end



##### Decl handleeeer ###########
def decl_Handler(decl)
	dError=0
	case decl.types[1]
	when :asignacion
		
		dError=decAsig_Handler(decl.elems[1],decl.elems[0].val.symbol) #### AQUI FALTA PASARLE EL TYPE
		
	when :Lista_ID
		type=decl.elems[0].val.symbol
		lista=decl.elems[1]

		dError = ListI_Handler(type,lista)

	end
	listD = decl.elems[2]
	dListError = 0
	if (listD != nil)
		dListError = decl_Handler(listD)
	end
	return dError + dListError
end

def decAsig_Handler(dec,type)
	dError=0
	nameVar = dec.elems[0].term.id
	asignable = dec.elems[1]
	if !($symTable.contains(nameVar))	
		$symTable.insert(nameVar,[type,nil])

		dError = asign_Handler(nameVar,asignable) 
	else 
		#puts  "ERROR: variable '#{dec.elems[0].term.id}' was declared before" \
				#{}" at the same scope."
		return 1
	end
	return dError
end

#### Manejador de Asignaciones #####
#idVar es del tipo term.id
#asig es de la clase asignable
def asign_Handler(idVar,asig)

	tipoAsig = asig.types[0]
	valAsig = asig.elems[0]
	if ($symTable.lookup(idVar)==nil)
		puts "Error de Asignacion: variable '#{idVar}' no ha sido declarada."
		return 1
	else 
		typeVar=$symTable.lookup(idVar)[0]
		case tipoAsig
		when :Expresion
			
			typeExpr=expression_Handler(valAsig)
			if(typeVar != typeExpr)

				puts "ASSIGN ERROR: #{typeExpr} expression assigned to #{typeVar} "\
			"variable '#{idVar}'."
				return 1
			end

		when :Llamada_de_Funcion
			valAsig=valAsig.elems[0]
			typeExpr = typeCall_Handler(valAsig)
			if(typeVar != typeExpr)
				puts "ASSIGN ERROR: #{typeExpr} expression assigned to #{typeVar} "\
			"variable '#{idVar}'."
				return 1
			end
		end
		return 0
	end

	#if para cuando ya fue asignada.
end

def ListI_Handler(type,list)
	id=list.elem.term.id
	listID=list.list
	if !($symTable.contains(id))
		$symTable.insert(id, [type, nil])
		if (listID!= nil)
			return ListI_Handler(type,listID)
		end
		return 0
	else
		puts "ERROR: variable '#{id}' fue declarada antes " \
				" en el mismo alcance."
		if (listID != nil)
			return listI_Handler(type,listID) + 1
		end
		return 1
	end
end

def expr_Handler(expr)
	if expression_Handler(expr) == nil
		puts "EXPRESION ERROR: Error en los tipos de la expresion"
		return 1
	else 
		return 0
	end
end


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
				puts "ERROR: Variale '#{idVar}' no declarada en este entorno"
				return typeVar
			end
		when :DIGIT
			return :TYPEN
		when :TRUE
			return :TYPEB
		when :FALSE
			return :TYPEB	
		end
	else
		puts "ERROR: hubo un errror expression_Handler."		
	end
end


# Manejador de expresiones binarias:
# Devuelve el tipo de las expresiones binarias
# => si hay un error de tipo, devuelve nil.
def binExp_Handler(expr)
	typeExpr1 = expression_Handler(expr.elems[0])
	typeExpr2 = expression_Handler(expr.elems[1])

	
	case expr.op
	when :Suma,:Resta,:Multiplicacion

		if (typeExpr1 == :TYPEN) and (typeExpr2 == :TYPEN)
			#return 0
			return :TYPEN #AQUI HAY QUE HACER MODIFICACIONES PARA QUE DEVUELVA
			#0 CUANDO NO HAY ERROR Y 1 CUANDO SI PORQUE CUANDO LA UTILIZO PARA 
			#OTRAS FUNCIONES EXPLOTA UN POQUITO
		else
			return nil
		end
	when :Menor_que,:Mayor_que,:Menor_O_Igual_Que,:Mayor_O_Igual_Que,:Distinto_que
		if (typeExpr1 == :TYPEN) and (typeExpr2 == :TYPEN)
			return :TYPEB

		elsif (typeExpr1 == :TYPEB) and (typeExpr2 == :TYPEB)
			return :TYPEB
		else
			return nil
		end

	when :Or,:And
		if (typeExpr1 == :TYPEB) and (typeExpr2 == :TYPEB)
			return :TYPEB
		else
			return nil
		end
	when :Equivalencia,:Distinto_que
		if (typeExpr1 == :TYPEN) and (typeExpr2 == :TYPEN)
			return :TYPEN
		elsif (typeExpr1 == :TYPEB) and (typeExpr2 == :TYPEB)
			return :TYPEB
		else
			return nil
		end
	when :Division_Exacta,:Resto_Exacto,:Division_Entera,:Resto_Entero
		if (typeExpr1 == :TYPEN) and (typeExpr2 == :TYPEN)
			#/ver como hacer lo de division por cero.
			return :TYPEN
		else
			return nil
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
			return nil
		end
	when :Negacion
		if typeExpr == :TYPEB
			return :TYPEB
		else
			return nil
		end
	end
end