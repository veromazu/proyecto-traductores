#! /usr/bin/ruby
# encoding: utf-8
=begin

UNIVERSIDAD SIMÓN BOLÍVAR
Traductores e Interpretadores
Fase 3 de Proyecto : Parser de Retina.
Elaborado por:
    -Verónica Mazutiel, 13-10853
    -Melanie Gomes, 13-10544

En este archivo se implementan las funciones para las tabla de simbolos.
=end


class SymbolTable

	attr_accessor :father
	attr_accessor :nombre
	attr_accessor :param
	attr_accessor :cont

	def initialize(nombre,father = nil,param=nil,cont=nil)
		@symTable = Hash.new
		@father = father
		@nombre = nombre
		@param = []
		@cont=cont
	end
	
	def insert(key, values)
		return @symTable.store(key, values)
	end

	def delete(key)
		return @symTable.delete(key)
	end
	
	def contains(key)
		return @symTable.include?(key)
	end

	def update(key, value)
		if !(contains(key))
			if (@father != nil)
				return @father.update(key, value)
			else
				puts "ERROR: variable '#{key}' has not been declared."
				return false
			end
		else
			@symTable[key] = value
			return true
		end		
	end

	def lookup(key)
		if !(contains(key))
			if (@father != nil)
				return @father.lookup(key)
			else
				return nil
			end
		else
			return @symTable[key]
		end
	end


	def lookup_param(key)
		if !(contains(key))
			if (@father != nil)
				return @father.lookup(key)
			else
				return nil
			end
		else
			return @param
		end
	end

	

	def get_lvl
		auxTab = self
		lvl = 0
		while (auxTab.father != nil)
			auxTab = auxTab.father
			lvl += 1
		end
		return lvl
	end

	def print_Table
		lvl = get_lvl
		(lvl).times{print " "}

		puts "#{@nombre}: "
		if @nombre  == "Programa principal"
			(lvl + 1).times{print " "}
			print "Funciones: "
		else 
			(lvl + 1).times{print " "}

			print "Variables: "
		end

		if (@symTable.empty?)
			puts " None "
		else	
				
			@symTable.each do |k,v|
				if v[0] == :TYPEN	
					tipo = "number"
				elsif v[0] == :TYPEB
					tipo = "boolean"
				end
				puts
				(lvl+1).times { print " "}
				print"#{k} : #{tipo} "

			end
			
		end
		puts
		puts 
	end
end