=begin rdoc
Ein Element des Spielfeldes Feld.

@timer gibt an, wie viele Zeitschritte das Feld noch so bleibt.
=end
 

class Element
  
=begin rdoc 
gibt an, was auf dem Feld ist wobei:
  [0] leer
[-1] Mauer
[-2] Apfel
[z] Nummer der Schlange (z>0)
=end      
  attr_reader :art
  
  # gibt an, wie viel Zeitschritte das Element noch so bleibt
  # Ein negativer Wert oder 0 heisst für immer.  
  attr_reader :timer
  
  # X-Koordinate dieses Elements
  attr_reader :x
  # Y-Kooridnate dieses Elements
  attr_reader :y
  
  # Ausrichtung des Schlangenkörpers (wenn es dann eine ist)
  # 
  # * 0: Kopf-Rechts
  # * 1: Kopf-Unten
  # * 2: Kopf-Links
  # * 3: Kopf-Oben
  # * 4: rechts-unten
  # * 5: unten-links
  # * 6: links-oben
  # * 7: oben-rechts
  # * 8: horizontal
  # * 9: vertikal
  attr_accessor :dir

  
  # Generiert ein neues, leeres Element  
  def initialize(x,y)
    @x = x
    @y = y
    set(0,0)
  end
  
  # Ein Zeitschritt ist vorbei. Felder aktualisieren
  # Felder mit abgelaufenem @timer werden als leer markiert.
  def aktualisieren
    if (@timer>0)
      @timer -= 1
      if (@timer == 0)
        set(0,0)
      end
    end
  end
  
  # Werte neu setzen
  def set(art, timer, dir=0)
    @art = art
    @timer = timer
    @dir = dir
  end
  
end
