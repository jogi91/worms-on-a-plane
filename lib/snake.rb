require "tools"

include Tools

# Jede Schlange wird durch eine Instanz von Snake dargestellt
#
 

class Snake
  
  # X-Position des Schlangenkopfs
  attr_reader :posx
  # Y-Position des Schlangenkopfs
  attr_reader :posy
  # Richtung in die die Schlange schaut
  attr_accessor :dir
  # Länge der Schlange
  attr_reader :lang
  # Lebt die Schlange noch?
  attr_accessor :lebt
  
  
  # Startpunkt (posx, posy) und Richtung dir (siehe Tools).
  def initialize(posx, posy, dir)
    @posx = posx
    @posy = posy
    @dir = dir
    @lang = 5
    @lebt = true
  end
  
  
  # Bewegt den Schlangenkopf in Richtung @dir
  def aktualisieren
    fx,fy = @dir.to_dir
    @posx += fx
    @posy += fy
  end
  
  # Verlängert die Schlange um Anzahl Glieder
  def zunehmen(anzahl)
    @lang += anzahl
  end
  
  # Gibt Position und Richtung in Komma-Schreibweise zurück
  def wo_bin_ich?
    return @posx, @posy, @dir
  end
  
end
