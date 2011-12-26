require "spiel"
require "tools"


class Strategie_Do
   
  def wohin?(spiel)
    check = true 
    x,y,dir = spiel.wo_bin_ich?
    art,timer = spiel[x,y]
    chg = 0   
    abstx = 0
    absty = 0
    nx = 0
    ny = 0
    
    begin     
      if (check == false) 
        sx = nx
        sy = ny
        sart = -1
        k = 0
        cchg = @chg
        
        #geht der Schlange entlang, bis freies Feld in richtige Richtung
        #TODO Schlange geht noch in falsche Richtung
                
        begin
          if (sart > 0||sart == -1)
            cvx,cvy = cchg.to_dir
            sx += cvx
            sy += cvy
            sart,stimer = spiel[sx,sy]
              
            if (sx == nx&&sy == ny)
              if (@chg == 0||@chg == 2)
                @chg = 3
              elsif (@chg == 1||@chg == 3)
                @chg = 0
              end
              a = true
            end
                        
          else
            if (k == 0)
              if (cchg == 0)
                cchg = 1
              elsif (cchg == 1)
                cchg = 2
              elsif (cchg == 2)
                cchg = 3
              elsif (cchg == 3)
                cchg = 0
              end
              k += 1
              sart = -1
            elsif (k == 1)
              if (cchg == 0)
                cchg = 2
              elsif (cchg == 1)
                cchg = 3
              elsif (cchg == 2)
                cchg = 0
              elsif (cchg == 3)
                cchg = 1
              end
              k += 1
              sart = -1
            elsif (k == 2)
              if (@chg == 0||@chg == 2)
                @chg = 1
              elsif (@chg == 1|| @chg == 3)
                @chg = 2
              end
              k += 1
            end
          end
        end until (k == 3||a == true)
                
        #TODO Fläche berechnen (wenn gösser als Aussenfeld dann in die Fläche)
        
      else
        #definiert Richtungsvektor in Richtung der Apfels (ausser Gegenrichtung)  
        posapf = spiel.aepfel[0]
        abstx = posapf[0]-x
        absty = posapf[1]-y
        #TODO Schlange versucht immer sich selber nachzufahren
        if (abstx > 0)
          @chg = 0
        elsif (abstx < 0)
          @chg = 2
        else
         if (absty > 0)
            @chg = 1
          elsif (absty < 0)
            @chg = 3
          end
        end
      end
      
      #Berechnet das neue Feld
      vx,vy = @chg.to_dir
      nx = x+vx
      ny = y+vy
      nart,ntimer = spiel[nx,ny]
      
      #Schaut ob Feld besetzt
      if (nart == -1||nart > 0)
        check = false
      else
        check = true
      end
    end until (check == true)
    
    return @chg
  end
end
