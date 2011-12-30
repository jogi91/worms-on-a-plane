# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "strategie"
# Strategie von Jogi
# Geschrieben mit einem Fixen Zeitlimit von 60 minuten
class Strategie_Jogi60Minutes < Strategie
	def initialize
		@spiel = nil
		@apfel = nil
		@modus = :check
	end

	def wohin?(spiel)
		@spiel = spiel
		@x,@y,@dir = spiel.wo_bin_ich?
		if @apfel != spiel.aepfel[0]
			@modus = :check
			@apfel = spiel.aepfel[0]
		end

		if @modus == :check
			if nearest?
				@modus = :apfel
			else
				@modus = :flucht
			end
		end

		puts @modus

		if @modus == :apfel
			if @apfel[0] > @x
				if freieSicht?(@apfel, 0)
					return 0
				end
			else
				if freieSicht?(@apfel,2)
					return 2
				end
			end

			if @apfel[1] > @y
				if freieSicht?(@apfel, 1)
					return 1
				end
			else
				if freieSicht?(@apfel,3)
					return 3
				end
			end

			#keine Freie Sicht:
			
			@modus = :flucht
		end


		if @modus == :flucht
			return rand(3)
					
		
			@modus = check

		end
	end

	def freieSicht?(zielkoordinaten, startrichtung)
		xZiel = zielkoordinaten[0]
		yZiel = zielkoordinaten[1]

		if startrichtung == 0 or startrichtung == 2
			#Erst x, dann y Richtund
			if @x < xZiel
				for i in @x+1..xZiel
					if @spiel[i, @y] != 0 or @spiel[i, @y] != -2
						return false
					end
				end
			else
				for i in xZiel..@x-1
					if @spiel[i, @y] != 0 or @spiel[i, @y] != -2
						return false
					end
				end
			end

			if @y < yZiel
				for i in @y..yZiel
					if @spiel[xZiel,i] != 0 or @spiel[xZiel, i] != -2
						return false
					end
				end
			else
				for i in yZiel..@y
					if @spiel[xZiel,i] != 0 or @spiel[xZiel, i] != -2
						return false
					end
				end
			end

			return true
		end

		if startrichtung == 1 or startrichtung == 3
			#Erst y, Dann X-Richtung
			if @y < yZiel
				for i in @y+1..yZiel
					if @spiel[xZiel,i] != 0 or @spiel[xZiel, i] != -2
						return false
					end
				end
			else
				for i in yZiel..@y-1
					if @spiel[xZiel,i] != 0 or @spiel[xZiel, i] != -2
						return false
					end
				end
			end

			if @x < xZiel
				for i in @x..xZiel
					if @spiel[i, @y] != 0 or @spiel[i, @y] != -2
						return false
					end
				end
			else
				for i in xZiel..@x
					if @spiel[i, @y] != 0 or @spiel[i, @y] != -2
						return false
					end
				end
			end
			
			return true
		end

	end

	def checkx(xZiel, yAchse)
	end
	#Implementation der Manhattanmetrik
	#Input: Zwei Arrays von Koordinaten
	def manhattan(koordinate1, koordinate2)
		result = (koordinate1[0]-koordinate2[0]).abs
		result += (koordinate1[1]-koordinate2[1]).abs
		return result
	end

	#Bin ich am Nächsten zum Apfel?
	def nearest?
		mydistance = manhattan([@x,@y],@apfel)
		@spiel.schlangen_pos.each { |position| 
			if manhattan(position[0, 2], @apfel) < mydistance
				return false
			end
		}
		return true
	end

end
