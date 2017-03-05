#!/usr/bin/ruby
# encoding: utf-8
=begin

* UNIVERSIDAD SIMÓN BOLÍVAR
* Traductores e Interpretadores
* Fase 1 de Proyecto : Lexer de Retina
* Elaborado por:
*	-Verónica Mazutiel, 13-10853
*	-Melanie Gomes, 13-10544
* Ultima modificación : 18/02/17
=end


# Diccionario global que guarda los tokens leidos por el lenguaje retina

$tokens = {
/^number/ 											=> :TYPEN,
	/^boolean/										=> :TYPEB,															
	/^true/											=> :TRUE,
	/^false/										=> :FALSE,					
	/^and/											=> :AND,
	/^not/											=>:NOT,
	/^or/											=>:OR,
	/^program/										=>:PROGRAM,
	/^begin/										=>:BEGIN,
	/^end/											=>:END,
	/^with/											=>:WITH,
	/^do/								 			=>:DO,
	/^if/											=>:IF,
	/^then/											=>:THEN,
	/^else/											=>:ELSE,
	/^while/										=>:WHILE,
	/^for/											=> :FOR,
	/^repeat/										=>:REPEAT,
	/^times/										=>:TIMES,
	/^read/											=>:READ,
	/^write/										=>:WRITE,
	/^writeln/										=>:WRITELN,
	/^from/											=>:FROM,
	/^to/											=>:TO,
	/^by/											=>:BY,
	/^func/											=>:FUNC,
	/^return/										=>:RETURN,
	/^->/											=>:RETURN2,
	/^==/											=>:EQUIVALENT,
	/^</											=>:LESSTHAN,
	/^\/=/											=>:DISTINCT,
	/^>=/											=>:GETHAN,
	/^<=/											=>:LETHAN,
	/^>/											=>:GREATTHAN,
	/^\(/											=>:LPARENT,
	/^\)/											=>:RPARENT,
	/^=/											=>:EQUAL,
	/^;/											=>:SEMICOLON,
	/^,/											=>:COLON,
	/^\+/											=>:PLUS,
	/^mod/											=>:MOD,
	/^div/											=>:DIV,
	/^%/											=>:MOD2,
	/^\//											=>:DIV2,
	/^\*/											=>:MULT,
	/^-/											=>:LESS,
	/^[a-z][a-zA-Z0-9_]*/							=>:ID,
	/^"[a-zA-Z\d\s[[:punct:]]]*"/					=>:STRING,
	/^([1-9][0-9]*|0)(\.[0-9]+)?/					=>:DIGIT,
}



class Token
	# Creamos metodos para acceder a los atributos privados de la clase.
	attr_accessor :id
	attr_accessor :symbol
	attr_accessor :position
	def initialize (symbol,id, position)
		@id=id
		@symbol = symbol
		@position = position
	end

	def idAndValue
		return [@symbol, @id]
	end
end

class Lexer
	attr_accessor :tokensList
=begin
	atr:   @tokensList: lista de tokens validos del lenguaje.
		   @errList: lista de tokens no validos del lenguaje.
=end	
=begin
	funcion: initialize: inicializa la clase Lexer.
=end
	def initialize
		@tokensList = Array.new
		@tokensAux = Array.new
		@errList = Array.new
	end
=begin
	funcion: identifier: identifica los tokens validos e invalidos en un archivo.
	@param: file: archivo a analizar.
=end
	def identifier(file)
		lineNum = 0
		commline = 0 
		commcol = 0 
		

		file.each_line do |line|
			# En cada iteracion (salto de linea), el numero de linea aumenta.
			# y el numero de columna vuelve a 1.
			lineNum += 1
			colNum = 1
			# Cuando lo que queda de la linea es un salto de pagina, pasamos a la
			# proxima linea (arriba)
			while line != ""
				tokAccepted=false
				$tokens.each do |expr,lexeme|
					if line =~ expr
					#si coincide se agrega a la lista de los lexemas leidos
						word = line[expr]
						line = line.partition(word).last
						@tokensList << Token.new(lexeme,word,[lineNum, colNum])
						colNum += word.size
						tokAccepted=true
						break
					end
				end
				if not tokAccepted
					case line

					#Si encuentra {- ignora todo hasta encontrar -}, si no lo encuentra da error. 
					# Este es para las tabulaciones, las cuenta como 4 espacios. 
					when /^\t+/
						word = line[/^\t+/]
						line = line.partition(word).last
						colNum += 4
				
					# Este es para los espacios en blanco o saltos de linea.
					when /^\s+/
						word = line[/^\s+/]
						line = line.partition(word).last
						colNum += word.size
					when /^#/ 
						word = line[/^#/]
						line = line.partition(word).last
						break
					else
						word = line[/^./]
						line = line.partition(word).last
						@errList << Token.new("", word,[lineNum, colNum])
						colNum += word.size
					end
				end
			end
		end

		# Si hubo algun caracter invalido, se imprime y se borra el arreglo de tokens validos.
		if (@errList.any? == true)
			@tokensList.drop(@tokensList.length)
			#printErrors
			return false
		# Si todos los caracteres son validos, se imprimen los tokens.
		else
			#printTokens
			return true
		end
	end

	def printTokens 
		@tokensList.each do |token|
			case token.symbol
			when :TYPEN,:TYPEB
				tokenName="tipo de dato"
			when :TRUE,:FALSE
				tokenName="literal booleano"
			when :AND,:NOT,:OR
				tokenName="operador booleano"
			when :PROGRAM,:BEGIN,:END,:WITH,:DO,:IF,:THEN,:ELSE,:WHILE,:FOR,:REPEAT,:WRITE,:WRITELN,:FROM,:TO,:BY,:FUNC,:RETURN,:RETURN2
				tokenName="palabra reservada"
			when :EQUIVALENT,:LESSTHAN,:DISTINCT,:GETHAN,:LESSTHAN,:GREATTHAN
				tokenName="operador de comparación"
			when :LPARENT,:RPARENT,:EQUAL,:SEMICOLON,:COLON,:RCURLY,:LCURLY
				tokenName="signo"
			when :PLUS,:MOD,:DIV,:MOD2,:DIV2,:MULT,:LESS
				tokenName="operador aritmético"
			when :ID
				tokenName="identificador"
			when :STRING
				tokenName="string"
			when :DIGIT
				tokenName="literal numérico"
			end
			puts "linea #{token.position[0]}, columna #{token.position[1]}: #{tokenName} '#{token.id}'"
		end
	end

	def printErrors
		@errList.each do |error| 
			puts "linea #{error.position[0]}, columna #{error.position[1]}: caracter inesperado :'#{error.id}'"
		end
	end


	def next_token
		if ((tok = @tokensList.shift) != nil)
			@tokensAux << tok
			return tok.idAndValue
		else
			return nil
		end
	end
end
=begin
def main  
	# Vemos que usuario ingrese el archivo
	if ARGV[0].nil?
		puts "Ingrese archivo."
		return
	end

	# Verificamos extension '.rtn' de archivo
	ARGV[0] =~ /\w+\.rtn/;
	if $&.nil? 
		puts "Extensión  inválida."
		return
	end

	# Verificar existencia del archivo
	if not File.file?(ARGV[0])
		puts "Archivo no encontrado."
		return
	end
	input = File::read(ARGV[0])
	# Create lexer
	lexer = Lexer.new()
	lexer.identifier(input)

end
main
=end 