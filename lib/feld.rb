require 'element'

# Die Klasse Feld enthält das aktuelle Spielfeld

class Feld 
  # Breite vom Feld.
  attr_reader :x
  # Höhe vom Feld.
  attr_reader :y
  
  # Erzeugt ein Spielfeld mit der Breit x und Höhe y
  # Die art des Feldes gibt die Verteilung von Mauern an.
  # = TODO
  # Verschiedene Felder generieren.
  def initialize(x, y, art=0)
    @x = x
    @y = y
    @art = 0
    @elemente = Array.new(x) {|i| Array.new(y) {|j| Element.new(i,j)}}
    
    #Mauern setzen
    for x in 0...@x
      @elemente[x][0].set(-1,0)
      @elemente[x][@y-1].set(-1,0)
    end 
    for y in 0...@y
      @elemente[0][y].set(-1,0)
      @elemente[@x-1][y].set(-1,0)
    end 
    
    
    case art
    when 0:
         # Nichts tun, Mauern sind schon gesetzt.
    else
      raise "Feld der Art #{art} ist nicht definiert!"
    end
  end
  
  # Gibt die Art vom Inhalt vom Element an Position x,y und
  # den Timer zurück (als durch Komma getrennte Wert.
  # 
  # *Achtung* Die Werte laufen von 0 bis Breite-1 und 0 bis Höhe-1
  def [](x,y)
    if (x<0 or y<0 or x>=@x or y>=@y)
      raise "Das Element #{x} #{y} gibt es auf dem #{@x} x #{@y} Feld nicht!"
    end
    return @elemente[x][y].art, @elemente[x][y].timer, @elemente[x][y].dir
  end
  # Das Element x,y auf art und timer setzen
  def set_element(x,y,art,timer,dir=0)
    if (x<0 or y<0 or x>=@x or y>=@y)
      raise "Das Element #{x} #{y} gibt es auf dem #{@x} x #{y} Feld nicht!"
    end
    @elemente[x][y].set(art,timer,dir)
  end
  
  # Aktualisiert alle Element-Einträge
  def aktualisieren
    @elemente.each {|kolonne|
      kolonne.each {|e|
        e.aktualisieren
      }
    }
  end

  # Gibt die Startposition (x,y) und dir Richtung der Schlangennummer nr
  # an (von 0 bis Anzahl Schlangen, mindestens 3)
  def startpos(nr)
    case @art
    when 0:
        case nr
        when 0:
          return @x/4,@y/2,0
        when 1:
          return 3*@x/4,@y/2,2
        when 2:
          return @x/2,@y/4,1
        when 3:
          return @x/2,3*@y/4,3
        else
          raise "Für dieses Feld sind nur 4 Positionen definiert!"
        end
    else
      raise "Art #{art} ist noch nicht definiert!"
    end
  end
  
  # Ein ganz einfache Methode, um das Feld auszugeben
  def to_s
#    res = "Feld #{@x} x #{@y}\n"
    res = ""
    for y in 0...@y
      for x in 0...@x
        case @elemente[x][y].art
        when -1: # Mauer
          res += "#"
        when -2:
          res += "*"
        when 0:
          res += "."
        else
		  #res += @elemente[x][y].dir.to_s
          res += @elemente[x][y].art.to_s
        end
      end
      res += "\n"
    end 
    return res
  end
end
