# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require "strategie"
require "feld"
require "element"
require "spiel"
#Zufalls-Strategie von Zeno
class Strategie_zeno < Strategie
 
 def initialize
   @ecke=10
   @direction=0   
 end
 
 def wohin?(spiel)
    # Position und Richtung meiner Schlange
    x,y,dir = spiel.wo_bin_ich?
    #Zufällige Richtung ausser Gegenrichtung
    #dir = (dir +rand(3)-1)%4;
 



   if @ecke!=10 then
   ecke=@ecke
   dir=ecke
   @ecke=10
   return dir
   break
   end
   
   #@ecke=10
     
    puts "#{dir} vorher" 
  
   xpos_apfel = spiel.aepfel[0][0]
   ypos_apfel = spiel.aepfel[0][1]
   puts "Xpos apfel: #{xpos_apfel}"
   puts "Ypos apfel: #{ypos_apfel}"
   art,timer = spiel[x,y]
   puts "Schlangenkopf #{x},#{y}"
   
   if  xpos_apfel==x and ypos_apfel>y then
     dir=1
     puts "Habe Apfel unten gesehen!"

   end
   
   if  xpos_apfel==x and ypos_apfel<y then
     dir=3
     puts "Habe Apfel oben gesehen!"
   end
   
   if  xpos_apfel>x and ypos_apfel==y then
     dir=0
     puts "Habe Apfel rechts gesehen!"
   end
    
   if  xpos_apfel<x and ypos_apfel==y then
     dir=2
     puts "Habe Apfel links gesehen!"
   end
   
  if (dir==0) then
    art,timer = spiel[x+1,y]
    puts " art: #{art}"
   
  
      if art!=0 and art!=-2 then
        dir = 1
        if @direction == 1 then
          dir =3
          @direction = 0
        else
          @direction = 1
        end
        if dir == 1 then
        art,timer = spiel[x,y+1]
          if art!=0 and art!=-2 then
            dir = 3
            @ecke = 2
          end
        
        elsif dir == 3 then
        art,timer = spiel[x,y-1]
          if art!=0 and art!=-2 then
            dir = 1
            @ecke = 2
          end        
        end
      end
 
   
  
  elsif (dir==1) then
   art,timer = spiel[x,y+1]
   puts " art: #{art}"
   
  
      if art!=0 and art!=-2 then
        dir = 2
        if @direction == 1 then
          dir = 0
          @direction = 0
        else
          @direction = 1
        end
        if dir == 2 then
        art,timer = spiel[x-1,y]
          if art!=0 and art!=-2 then
            dir = 0
            @ecke = 3
          end
        
        elsif dir == 0 then
        art,timer = spiel[x+1,y]
          if art!=0 and art!=-2 then
            dir = 2
            @ecke = 3
          end        
        end
      end


  
  
  elsif (dir==2) then
   art,timer = spiel[x-1,y]
   puts " art: #{art}"
   
       
      if art!=0 and art!=-2 then
        dir = 3
        if @direction == 1 then
          dir = 1
          @direction = 0
        else
          @direction = 1
        end
        if dir == 3 then
        art,timer = spiel[x,y-1]
          if art!=0 and art!=-2 then
            dir = 1
            @ecke = 0
          end 
        
        elsif dir == 1 then
        art,timer = spiel[x,y+1]
          if art!=0 and art!=-2 then
            dir = 3
            @ecke = 0
          end        
        end
      end


 
  elsif (dir==3) then
   art,timer = spiel[x,y-1]
     puts " art: #{art}"
     
      if art!=0 and art!=-2 then
        dir = 2
        if @direction == 1 then
          dir = 0
          @direction = 0
        else
          @direction = 1
        end
        if dir == 2 then
        art,timer = spiel[x-1,y]
          if art!=0 and art!=-2 then
            dir = 0
            @ecke = 1
          end
       
        elsif dir == 0 then
        art,timer = spiel[x+1,y]
          if art!=0 and art!=-2 then
            dir = 2
            @ecke = 1
          end        
        end
      end


  end

  puts "#{dir} nachher"
    return dir
  end    
 
end

   