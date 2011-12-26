require "spiel"
require "strategie"
require "strategie_le_prof"

strategien = [Strategie_leProf.new]

#strategien = Array.new(1) {Strategie_Remote.new}

spiel = Spiel.new(38, 14, strategien, 0)

i = 0
begin
  res = spiel.aktualisieren
  puts spiel.feld.to_s
  #puts res
  i += 1
end until i>300 or res.index(true) == nil

