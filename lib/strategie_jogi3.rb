# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "strategie"
# Strategie von Jogi
# Weiterentwicklung des Epic-Fail Commits
class Strategie_Jogi3 < Strategie
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
				puts "Bin nicht der nächste, also fliehe ich"
				@modus = :flucht
			end
		end

		puts @modus

		if @modus == :apfel
			if @apfel[0] > @x
				puts "Teste x Richtung" 
				if freieSicht?(@apfel, 0)
					return 0
				else
					puts "Keine Freie Sicht in Richtung 0"
				end
			elsif @apfel[0] < @x
				if freieSicht?(@apfel,2)
					return 2
				end
			end

			if @apfel[1] > @y
				puts "Teste y Richtung"
				if freieSicht?(@apfel, 1)
					return 1
				else
					puts "Keine Freie Sicht in Richtung 1"
				end
			else
				if freieSicht?(@apfel,3)
					return 3
				end
			end

			#keine Freie Sicht:
			
			@modus = :flucht
		end


		#Gehe in die Richtung, wo ich die meisten Felder habe
		if @modus == :flucht
			@modus = :check
			
			dirs = Array.new(4,0)
			for i in 0..3
				x = @x + i.to_dir[0]
				y = @y + i.to_dir[1]

				if onTheField?(x,y) == false
					next
				end

				#Zähle die freien Felder
				while free?(@spiel[x,y])
					dirs[i] += 1
					x += i.to_dir[0]
					y += i.to_dir[1]
					
					if onTheField?(x,y) == false
						break
					end
				end
				#wenn ich am meisten Platz habe, neuen topwert speichern
				if dirs[i] >= dirs.max
					mostspace = i
				end
			end
			return mostspace
		end
	end

	def freieSicht?(zielkoordinaten, startrichtung)
		xZiel = zielkoordinaten[0]
		yZiel = zielkoordinaten[1]

		if startrichtung == 0 or startrichtung == 2
			#Erst x, dann y Richtund
			if @x < xZiel
				for i in @x+1..xZiel
					#Wenn das Feld nicht Frei oder ein Apfel ist, ist das keine freie Sichtlinie
					if !(@spiel[i, @y][0] == 0 or @spiel[i, @y][0] == -2)
						puts "@x: #{@x}, i: #{i}"
						p @spiel[@x,i]
						return false
					end
				end
			else
				for i in xZiel..@x-1
					if !(@spiel[i, @y][0] == 0 or @spiel[i, @y][0] == -2)
						puts "@x: #{@x}, i: #{i}"
						p @spiel[@x,i]
						return false
					end
				end
			end

			if @y < yZiel
				for i in @y..yZiel
					if !(@spiel[xZiel,i][0] == 0 or @spiel[xZiel, i][0] == -2)
						puts "@x: #{@x}, i: #{i}"
						p @spiel[@x,i]
						return false
					end
				end
			else
				for i in yZiel..@y
					if !(@spiel[xZiel,i][0] == 0 or @spiel[xZiel, i][0] == -2)
						puts "@x: #{@x}, i: #{i}"
						p @spiel[@x,i]
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
					if !(@spiel[@x,i][0] == 0 or @spiel[@x, i][0] == -2)
						puts "@x: #{@x}, i: #{i}"
						p @spiel[@x,i]
						return false
					end
				end
			else
				for i in yZiel..@y-1
					if !(@spiel[@x,i][0] == 0 or @spiel[@x, i][0] == -2)
						puts "Nach obenhin falsch"
						puts "@x: #{@x}, i: #{i}"
						p @spiel[@x,i]
						return false
					end
				end
			end

			if @x < xZiel
				for i in @x..xZiel
					if !(@spiel[i, yZiel][0] == 0 or @spiel[i, yZiel][0] == -2)
						puts "@x: #{@x}, i: #{i}"
						p @spiel[@x,i]
						return false
					end
				end
			else
				for i in xZiel..@x
					if !(@spiel[i, yZiel][0] == 0 or @spiel[i, yZiel][0] == -2)
						puts "@x: #{@x}, i: #{i}"
						p @spiel[@x,i]
						return false
					end
				end
			end
			
			return true
		end

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
		
	def free?(field)
		if field[0] == 0 or field[0] == -2
			return true
		else
			return false
		end
	end

	def onTheField?(x,y)
		if x < 0 or y < 0 or x > @spiel.x or y > @spiel.y
			return false
		else
			return true
		end
	end
end
