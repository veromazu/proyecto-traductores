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
#scope es del tipo scope
def scope_Handler(scope)


	listFuncError = 0
	if (scope.elems[0]!=nil)
		listFuncError = listFunc_Handler(scope.elems[0])
	end
	progError = prog_Handler(scope.elems[1])



	return listFuncError + progError
end

#Manejador de lista de Funciones.
#elem es de la clase ListaFunc
def listFunc_Handler(elem)
	# Asignación de una nueva tabla.
	symTableAux = SymbolTable.new("funciones",$symTable)
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
		if (funcError > 0) or (nombreError > 0 or listFuncError>0)
			puts "No se mostrará la tabla de simbolos."
			abort
		end
		#puts "Alcance: Funciones"
		#$tableStack.reverse!
		#$tableStack.each do |st|
		#	st.print_Table
		#end
	end
	return listFuncError + funcError + nombreError
end
#Manejador de Funciones
#func es de la clase Func
def Func_Handler(func)
	namefunc= func.elems[0].term.id

	# Asignación de una nueva tabla.
	symTableAux = SymbolTable.new(namefunc,$symTable)
	$symTable = symTableAux


	

	paramsError = 0
	if (func.elems[1] != nil)
		paramsError = param_Handler(namefunc,func.elems[1])
	end

	if (func.elems[2] != nil)
		tipoRetorno = func.elems[2].elems[0].val.symbol
		$symTable.update(namefunc,[tipoRetorno,[]])
	end
	fInsError = 0
	if (func.elems[3] != nil)
		#fInsError = LInst_Handler(func.elems[3]) 
		fInsRetError =FInst_Handler(namefunc,func.elems[3])   #### Igual que el otro manejador peri si veo un return veo que sea del mismo tipo ret de la funciin
	end

	# Se empila la tabla del scope en la pila de tablas.
	$tableStack << $symTable
	$symTable = $symTable.father

return  paramsError + fInsError
end
#Manejador de una lista de parámetros de una función
#param es de la clase ListD o de la clase List
def param_Handler(nombre,param)

	if param.instance_of?(ListD)
		paramError = paramDec_Handler(nombre,param.elems[0],param.elems[1].term.id)
		listError=0
	end
	if param.instance_of?(List)
		paramError = paramDec_Handler(nombre,param.elems[0],param.elems[1].term.id)
		listError=param_Handler(nombre,param.list)
	end
	return listError + paramError
end



def paramDec_Handler(nombre,type,id)
	type=type.val.symbol

	if !($symTable.contains(id))
		$symTable.insert(id, [type, nil])
		$symTable.param << [id,type] 
	
		tipoRetorno = $symTable.lookup(nombre)[0]
		#tiposArg = $symTable.lookup(nombre)[1]
		#if tiposArg == nil
		#	tiposArg=Array.new
		#end
		#($symTable.update(nombre,[tipoRetorno,tiposArg<<type]))
	else
		puts "ERROR: variable '#{id}' fue declarada antes " \
				" para la misma Funcion."
		return 1
	end
	return 0
end

#Manejador de instrucciones de funciones
#FuncInst es de la clase funcInst
def FInst_Handler(namefunc,funcInst) 

	if (funcInst != nil)
		fInsErrors = LInstF_Handler(namefunc,funcInst)
	end
	return fInsErrors
end

#Manejador de lista de instrucciones denntro de una funcion
#LInstf es de la clase ListaInst
def LInstF_Handler(namefunc,lInstf)
	instError =  InstF_Handler(namefunc,lInstf.elem)
	lInstFError = 0
	if (lInstf.list != nil)
		lInstFError = LInstF_Handler(namefunc,lInstf.list)
	end
	return instError + lInstFError
end

#Manejador de una instruccion dentro de una funcion
#instr es de la clase Inst
def InstF_Handler(namefunc, instr)
case instr.types[0]
	when :Bloque
		return bloqueF_Handler(namefunc,instr.elems[0]) #listo
	when  :Retorno
		return return_Handler(namefunc,instr.elems[0])
	when :Asignacion
		return asign_Handler(instr.elems[0].elems[0].term.id,instr.elems[0].elems[1]) #listo
	when :Iteracion
		return iteratorF_Handler(namefunc,instr.elems[0]) #listo
	when :Lectura
		return lect_Handler(instr.elems[0]) #listo
	when :Salida
		return salida_Handler(instr.elems[0])    ### Escrita pero no probada por problema de expry falta call
	when :Salida_Con_Salto
		return salida_Handler(instr.elems[0])  ## Escrita pero no probada por expr y call
	when :Condicional
		return condF_Handler(namefunc,instr.elems[0])
	when :Llamada_de_Funcion
		return llamada_Handler(instr.elems[0])
	when :Expresion
		return expr_Handler(instr.elems[0]) 
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
		puts "ERROR: tipo de retorno '#{tipoExpr}' inesperado para '#{namefunc}'"
		return 1
	elsif typeRet != typeExpr
		if typeRet== :TYPEN
			tipoRetorno= "number"
		elsif typeRet == :TYPEB
			tipoRetorno = "boolean"
		end
		puts "ERROR: tipo de retorno '#{tipoExpr}' inesperado para '#{namefunc}', se esperaba tipo de retorno '#{tipoRetorno}'"
		return 1
	end
	return 0
end



#Manejador de nombres de funciones
#func es del tipo var
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

def bloqueF_Handler(namefunc,wis)
	symTableAux = SymbolTable.new("Subalcances",$symTable)
	$symTable = symTableAux
	declError=0
	if (wis.elems[0] !=nil)
		declError = decl_Handler(wis.elems[0])

	end
	listInstError=0

	if (wis.elems[1] !=nil)
		listInstError = LInstF_Handler(namefunc,wis.elems[1])
	end
	$tableStack << $symTable
	$symTable = $symTable.father

	if ($symTable == nil)
		if (declError > 0) or (listInstError > 0)
			puts "No se mostrara la tabla de simbolos"
			abort
		end
		puts "Subalcances:"
		$tableStack.reverse!
		$tableStack.each do |st|
			st.print_Table
		end
	end

	return declError + listInstError

end

#Manejador de iteradores
def iteratorF_Handler(namefunc,iter)
	iter_error = 0
	expr = iter.elems[0]
	inst = iter.elems[1]
	case iter.type1

	when :Ciclo_While
		if (expression_Handler(expr)!= :TYPEB)
			puts "ITERATION ERROR: Se esperaba condicion del tipo 'boolean'"
			return 1
		else
			iter_error = LInstF_Handler(namefunc,inst)
		end
			return iter_error
	
	when :Ciclo_Repeat

		if (expression_Handler(expr)!= :TYPEN)
			puts "ITERATION ERROR: Se esperaba expresion del tipo 'number'"
			return 1
		else
			iter_error = LInstF_Handler(namefunc,inst)
		end
			return iter_error
	when :Ciclo_For
		expr = iter.elems[1]
		expr2 = iter.elems[2]
		by = iter.elems[3]
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
				iter_error = LInstF_Handler(namefunc,inst) 
			end 	
		else
			if ((expression_Handler(expr) != :TYPEN) or (expression_Handler(expr2) != :TYPEN))
				puts "ITERATION ERROR: Se esperaba rango del tipo 'number'"
				error = 1
			else 
				iter_error = LInstF_Handler(namefunc,inst) 
			end 
		end
	end
	return err
end 

def condF_Handler(namefunc,cond)
	cond_error = 0
	expr = cond.elems[0]
	inst1= cond.elems[1]
	inst2= cond.elems[2]


	if (expression_Handler(expr)!= :TYPEB)
		puts "CONDITIONAL ERROR : La condicion debe ser del tipo : 'boolean'"
	else
		cond_error = LInstF_Handler(namefunc,inst1) #Aqui explota si es una expr
	end
	if (inst2 != nil)
		cond_error = cond_error +	LInstF_Handler(namefunc,inst2) 
	end

	return cond_error
end

#Manejador de Program
#elem es del tipo Linst
def prog_Handler(elem)
	# Asignación de una nueva tabla.
	symTableAux = SymbolTable.new("Programa",$symTable)
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
		puts "Tabla de Simbolos"
		$tableStack.reverse!
		$tableStack.each do |st|
			st.print_Table
		end
	end

	return listInstError + instError
end


#Manejador de lista de instrucciones de un porgram
def LInst_Handler(elem)
	instError =  Inst_Handler(elem.elem)

	listInstError = 0
	if (elem.list!=nil)
		listInstError= LInst_Handler(namefunc,elem.list)
	end
	return listInstError + instError
end

#Manejador de instrucciones
def Inst_Handler(instr)
	case instr.types[0]
	when :Bloque
		return bloque_Handler(instr.elems[0]) 
	when :Asignacion
		return asign_Handler(instr.elems[0].elems[0].term.id,instr.elems[0].elems[1]) 
	when :Iteracion
		return iterator_Handler(instr.elems[0])
	when :Lectura
		return lect_Handler(instr.elems[0]) 
	when :Salida
		return salida_Handler(instr.elems[0])   
	when :Salida_Con_Salto
		return salida_Handler(instr.elems[0]) 
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

#Manejador de llamadas de funciones
def llamada_Handler(llamada)
	func = llamada.elems[0].term.id

	if ($symTable.lookup(func))
		$tableStack.each do |t|
			if (t.nombre == func)
				$tablafunc = t 
			end
		end
	else 	
		puts "Funcion #{func} no declarada"
	end


	if (llamada.elems[1]!=nil)
		puts "Tiene parametros"
	end

	return 0
end

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
		puts "ERROR: Variable #{var} no declarada en este alcance"
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
	symTableAux = SymbolTable.new("bloque",$symTable)
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
		puts "Subalcances:"
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

	
	if ($symTable.lookup(nameVar)==nil)
	#if !($symTable.contains(nameVar))	
		$symTable.insert(nameVar,[type,nil])

		dError = asign_Handler(nameVar,asignable) 
	else 
		puts  "ERROR: variable '#{dec.elems[0].term.id}' fue declarada antes" \
				" en el mismo alcance."
		abort
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
		puts "ASSIGN ERROR: variable '#{idVar}' no ha sido declarada."
		return 1
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

				puts "ASSIGN ERROR: Expresion de tipo '#{tipoExpr}' y se esperaba una de tipo '#{tipoVar}' para variable #{idVar}."
				return 1
			end

		when :Llamada_de_Funcion
			valAsig=valAsig.elems[0]
			typeExpr = typeCall_Handler(valAsig)
			if(typeVar != typeExpr)
				puts "ASSIGN ERROR: #{typeExpr} expresión asiganda de tipo '#{typeVar}' "\
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

	if !($symTable.lookup(id))
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
		puts "ERROR: hubo un error expression_Handler."		
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