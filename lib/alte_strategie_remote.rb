require "strategie"

class Strategie_Remote < Strategie
  def initialize
    
  end
  
  def wohin?(spiel)
    # Position und Richtung meiner Schlange
    x,y,dir = spiel.wo_bin_ich?
    print "-----Remote-----\n"
    print "x=#{x}, y=#{y}, dir=#{dir}"
    print "\nRichtung: [w][s][a][d]   "
    e = gets.chomp
    print "----------------\n"
    if(e=="w")
      dir = 3
    end
    if (e=="a")
      dir = 2
    end
    if (e=="s")
      dir = 1
    end
    if (e=="d")
      dir = 0
    end
    return dir
  end
end

