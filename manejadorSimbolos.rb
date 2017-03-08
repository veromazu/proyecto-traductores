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
	#Asignacion de una nueva tabla.
	symTableAux = SymbolTable.new($symTable)
	$symTable = symTableAux
	#Manejo de la estructura.
	listFuncError = 0
	if (scope.elems[0]!=nil)
		listFuncError = listFunc_Handler(scope.elems[0])
	end
	progError = prog_Handler(scope.elems[1])
	return listFuncError + progError
end

#Manejador de lista de Funciones.
def listFunc_Handler(elem)
	funcError =  Func_Handler(elem.elem)
	listFuncError = 0
	if (elem.list!=nil)
		listFuncError = listFunc_Handler(elem.list)
	return listFuncError + funcError
end
#Manejador de Funciones
def Func_Handler(func)
	nombreError = nombreF_Handler(func.elems[0])
	paramsError = 0
	if (func.elems[1] != nil)
		paramsError = param_Handler(func.elems[1])
	end
	typeRError = 0
	if (func.elems[2] != nil)
		typeRError = typeR_Handler(func.elems[2])
	end
	fInsError = 0
	if (func.elems[3] != nil)
		fInsError = LInst_Handler(func.elems[3])    #### Acá revisar que sea directo con LInst o necesito un manejador para FInst.
	end
	return nombreError + paramsError + typeRError + fInsError
end

#Manejador de lista de instrucciones de una función
def LInst_Handler(elem)
	instError =  Inst_Handler(elem.elem)
	listInstError = 0
	if (elem.list!=nil)
		listInstError= LInst_Handler(elem.list)
	return listInstError + instError
end

#Manejador de Program
def prog_Handler(elem)
	listInstError =  LInst_Handler(elem.elem)
	return listInstError
end

#Manejador de instrucciones
def Inst_Handler(instr)
	case instr.types[0]
	when :Bloque
		return bloque_Handler(elems[0])
	when  :Retorno
		return return_Handler(elems[0])
	when :Asignacion
		return asign_Handler(elems[0])
	when :Iterator
		return iterator_Handler(elems[0])
	when :Lectura
		return lect_Handler(elems[0])
	when :Salida
		return salida_Handler(elems[0])
	when :Salida_Con_Salto
		return salida_Handler(elems[0])
	when :Condicional
		return cond_Handler(elems[0])
	when :Llamada_de_Funcion
		return llamada_Handler(elems[0])
	when :Expresion
		return expr_Handler(elems[0])
	end
end

############################################
# Manejo de las instrucciones del programa #
############################################

def bloque_Handler(wis)
	declError=0
	if (wis.elems[0] !=nil)
		declError = decl_Handler(elems[0])

	end
	listInstError=0
	if (wis.elems[1] !=nil)
		listInstError =  LInst_Handler(wis.elems[0])
	end
end



##### Decl handleeeer ###########

def asign_Handler(asig)
	idVar=asign.elems[0].term.id
	if ($symTable.lookup(idVar)==nil)
		puts "Error de Asignacion: variable '#{idVar}' no ha sido declarada."
		return 1
	end

	#if para cuando ya fue asignada.
end

