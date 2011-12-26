# Alle Strategien werden von dieser Klasse abgeleitet
# 

require "spiel"

class Strategie
  def initialize
    # Hier Dinge initizlisieren
  end
  
  # liefert eine Zahl von 0 bis 3, um die Richtung für den nächsten
  # Schritt anzugeben.
  # Es wird eine Instanz von Spiel übergeben. Über die kann das Spielfeld
  # abgefragt werden.
  def wohin?(spiel)
    # Position und Richtung meiner Schlange
    x,y,dir = spiel.wo_bin_ich?
    return dir
  end
  
end
