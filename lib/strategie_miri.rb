#!/usr/bin/ruby
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require "strategie"
#Zufalls-Strategie von Zeno
class Strategie_miri < Strategie
 
 def initialize
	@spiel = nil
 end
 
 def wohin?(spiel)
	@spiel = spiel
    # Position und Richtung meiner Schlange
    x,y,dir = spiel.wo_bin_ich?
    #ZufÃ¤llige Richtung ausser Gegenrichtung
    #dir = (dir +rand(3)-1)%4;
	x_apfel = spiel.aepfel[0][0]
	y_apfel = spiel.aepfel[0][1]
	
	if (x_apfel != x)
		if (x_apfel > x)
			dir = 0
		else
			dir = 2
		end
	elsif (y_apfel > y)
		dir = 1
	else
		dir = 3
	end
	
	#puts "dir =" + dir.to_s
	if richtung_gut?(dir) == true
		return dir
	else
		for i in 0..3
			puts "i ist: " + i.to_s
			if richtung_gut?(i) == true
				return i
			end
		end
		puts "shit happens"
		return dir
	end
	
			
		
end    

def richtung_gut?(dir)
	x,y,z = @spiel.wo_bin_ich?
	xadd, yadd = dir.to_dir
	
	#puts "richtung prüfen für: "  + @spiel[ x+xadd,y+yadd].inspect
	if @spiel[ x+xadd,y+yadd][0] == 0 or @spiel[ x+xadd,y+yadd][0] == -2
		puts "true" 
		return true
	else 
		return false
	end
	
end

end

   