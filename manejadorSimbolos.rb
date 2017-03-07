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
	funcError = 0
	if (scope.elems[0]!=nil)
		funcError = func_Handler(scope.elems[0])
	end
	progError = prog_Handler(scope.elems[1])


