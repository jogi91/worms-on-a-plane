# Alle Strategien werden von dieser Klasse abgeleitet
# 

require "spiel"
require "strategie"

class Strategie_tastatur < Strategie
  def initialize
    # Hier Dinge initizlisieren
    @tastendir = []
  end
  
  # liefert eine Zahl von 0 bis 3, um die Richtung für den nächsten
  # Schritt anzugeben.
  # Es wird eine Instanz von Spiel übergeben. Über die kann das Spielfeld
  # abgefragt werden.
  def wohin?(spiel)
    # Position und Richtung meiner Schlange
    x,y,dir = spiel.wo_bin_ich?
    while @tastendir.size>0  and 
        ((dir-@tastendir[0]).abs == 2 or dir==@tastendir[0])
      #puts "Shifted rubbish!"
      @tastendir.shift
    end
    if @tastendir.size>0 
      p#uts "Get a change"
      dir = @tastendir.shift
    end
    return dir
  end
  
  def taste(code)
    @tastendir.push(0) if code == 65363
    @tastendir.push(1) if code == 65364
    @tastendir.push(2) if code == 65361
    @tastendir.push(3) if code == 65362
    #puts "New dir #{@tastendir}"
  end

end
