# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require "strategie"
# Strategie von Jogi
class Strategie_Jogi2 < Strategie
	def initialize
		@i = 1
        @test = true
        @wait = 0
	end
  
	def wohin?(spiel)
		x,y,dir = spiel.wo_bin_ich?
		puts "Richtung am Anfang des Zuges #{dir}"
		counter = 0
                if(@test == true)
                  for j in 0..3
                          if (spiel.lebend[j] == true)
                          counter += 1
                          end	        
                  end
				  if(spiel.numapf == 15)
					@test = false
					@wait = 0
				  end
				  
				  if(@i == 1500)
				  	@test = false
				  	@wait = 0
				  end	
          		end
          
                if (counter <= 2)
                  @test = false
                  @wait = 0 #spiel.schlang.max
                end
                
		while (@test == true)
			
		
			if (@i%3 != 0)
				dir += 1
				if (dir == 4)
					dir = 0
				end
			end
	
			@i += 1

			return dir
		end
		
                if (@wait > 0)
                         if (@i%3 != 0)
				dir += 1
				if (dir == 4)
					dir = 0
				end
 			end
                    @i += 1
                    @wait -= 1
                    return dir
                end
		xapfel,yapfel = spiel.aepfel
                
		if (x < xapfel[0] )
			puts "ich muss nach rechts"
           	if (spiel[x+1,y][0] == 0 or spiel[x+1,y][0] == -2)
           		puts "geprüft, ob Feld Rechts frei oder Apfelist"
            	if (dir != 2)
            		puts "keine 180 Wende, dir=0"
            		dir = 0
					return dir
				end
			end
			if(spiel[x,y+1][0] == 0 and xapfel[1]>y)
				dir = 1
				return dir
			end
			if(spiel[x,y-1][0] == 0)
				dir = 3
				return dir
			end
		end
		if (x > xapfel[0])
			puts "ich muss nach links"
			if (spiel[x-1,y][0] == 0 or spiel[x-1,y][0] == -2)
				puts "geprüft, ob Feld links frei oder Apfel ist"
				if(dir != 0)
					puts "keine 180 Wende, dir=2"
            		dir = 2
					return dir
				end
			end
			if(spiel[x,y+1][0] == 0 and xapfel[1]>y)
				dir = 1
				return dir
			end
			if(spiel[x,y-1][0] == 0)
				dir = 3
				return dir
			end            
		end
                if (x == xapfel[0]) 
                  puts "Hier ist die Richtige x-Koordinate erreicht"
                  if (y > xapfel[1] and (spiel[x,y-1][0]==0 or spiel[x,y-1][0]==-2 ))
                          dir = 3
                  end
                  if (y < xapfel[1] and (spiel[x,y+1][0]==0 or spiel[x,y+1][0]==-2))
                          dir = 1
                  end
                end
        for i in 0..3
        	dir = (dir+i)%4
        	puts "Richtung am Ende des Zuges: #{dir}"        
        	if (spiel[(x+dir.to_dir[0]),(y+dir.to_dir[1])][0] == 0 or spiel[x+dir.to_dir[0],y+dir.to_dir[1]][0] == -2)
        		return dir
       		end
       	end
       	return dir
	end
end
