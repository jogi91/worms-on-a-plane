# 
# Diese Klasse koordiniert ein Spiel und kommuniziert mit den Strategien
# 
 
require "feld"
require "snake"
require "timeout"

class Spiel
  # Breite des Spielfeldes
  attr_reader :x
  # Höhe des Spielfeldes
  attr_reader :y
  # Spielfeld (Feld)
  #attr_reader :feldi # Eigentlich unnötig, da ja die Methode Spiel[] angeboten wird
  # Array mit Koordinaten (Array mit 2 Koordinaten) der Äpfel
  # 
  # z.B [ [4,3], [7,4] ]
  # 
  # fuer 2 Äpfel
  # 
  # Die Strategie kann dann mit spiel.aepfel die Koordinaten der Äpfel erfragen.
  attr_reader :aepfel
  
  # Array mit den Koordinaten und Richtungen der Schlangen
  # 
  # z.B. [ [5,3,1], [17,13,3]]
  # 
  # wobei jeweils x,y-Koordinate und die Richtung 0-3 gespeichert ist.
  # 
  attr_reader :schlangen_pos 

  # Anzahl plazierter Äpfel (eins mehr als gefressen wurden)
  
  attr_reader :numapf
  
  # Leben die Schlangen ueberhaupt noch?
  attr_reader :lebend
  
  # Und wie lange sind diese Schlangen?
  attr_reader :schlang
  
  # Wie viele Spielschritte ausgeführt?
  attr_reader :schritt

  # Aktive Strategien
  attr_reader :strategien

  # Spielfeld mit Breite x, Höhe y
  # 
  # strategien ist ein Array befüllt mit Strategie-Objekten
  # 
  # Für jede Strategie wird eine Schlange kreiert.
  # 
  # feldart gibt die Nummer des Spielfeldes an (in Feld definieren)
  def initialize(x,y, strategien, feldart=0)
    @aepfel = []
    @x = x
    @y = y
    @feld = Feld.new(x,y,feldart)
    @schlangen =[]
    @strategien = strategien
    @strategien.each_index {|i|
      s = Snake.new(*@feld.startpos(i))
      @schlangen << s      
      x,y,dir = s.wo_bin_ich?
      @feld.set_element(x,y,i+1,s.lang)
    }
    @numapf = 0
    @schritt = 0
    neuer_Apfel
    update_schlangen_pos
  end

  # Aktualisiert schlangen_pos mit allen Positionen und Richtungen der Schlangen
  
  def update_schlangen_pos
    @schlangen_pos =[]
    @lebend = []
    @schlang = []
    @schlangen.each {|s|
      @schlangen_pos << [s.posx, s.posy, s.dir]
      @lebend << s.lebt
      @schlang << s.lang
    }
  end
  
  # Positioniert einen neuen Apfel so, dass auf den acht
  # Feldern um den Apfel nicht ist.
  # Werden Koordinaten uebergeben, wird dort der Apfel
  # aus dem @aepfel Array entfernt.
  def neuer_Apfel(wegx=-1,wegy=-1)
    if (wegx>=0)
      @aepfel.delete([wegx,wegy])
    end
    x,y = 0,0
    begin
      ok = true
      x,y = rand(@x-2)+1, rand(@y-2)+1
      for a in -1..1
        for b in -1..1
          art,timer = @feld[x+a,y+b]
          if (art != 0)
            ok = false
          end
        end
      end
    end until ok
    @feld.set_element(x,y,-2,0)
    @aepfel += [[x,y]]
    @numapf += 1
  end
  
  # Führt einen Spielschritt aus und gibt ein Array zurück mit 
  # true/false für jede noch lebende Schlange.
  def aktualisieren
    @schritt += 1
    # Alte Richtung und Position der Schlangen merken
    olddata = Array.new(4,0)
    # Strategien abfragen
    @strategien.each_index {|@aktive_schlange|
      s = @schlangen[@aktive_schlange]
      if s.lebt
        olddata[@aktive_schlange] = [s.posx, s.posy, s.dir]
        begin
          Timeout.timeout(0.25) {
            s.dir = @strategien[@aktive_schlange].wohin?(self)        
          }
        rescue Exception => e
          # Wenn die Strategie einen Ruby-Fehler produziert oder
          # mehr als 0.25 Sekunden braucht, stirbt die Schlange.
          s.lebt = false
          puts "Schlange tot wegen #{ e } (#{ e.class })!"
        end
      end
    }
    # Schlangen vorwärts bewegen
    @schlangen.each {|s| 
      if s.lebt
        s.aktualisieren
      end
    }
    # Feld aktualisieren
    @feld.aktualisieren
    
    # Kopf an Kopf Unfälle?
    for i in 0...(@schlangen.size-1)
      if (@schlangen[i].lebt)
        for j in (i+1)...(@schlangen.size)
          if (@schlangen[j].lebt)
            a,b,dir = @schlangen[i].wo_bin_ich?
            x,y,dir = @schlangen[j].wo_bin_ich?
            if a == x and b == y # Zwei Schlangen schlagen sich die Köpfe ein
              @schlangen[i].lebt=false
              @schlangen[j].lebt=false
            end
          end
        end
      end 
    end
    # Gibt es gefressene Äpfel oder Unfälle?
    @schlangen.each {|s|
      if s.lebt
        x,y,dir = s.wo_bin_ich?
        art,timer = @feld[x,y]
        case art
        when -2: # Apfel
          s.zunehmen(5) # Fünf Glieder mehr!
          # Neuer Apfel und Apfel an Position x,y kommt weg
          neuer_Apfel(x,y)
        when 0:
          # gar nix
        else
          #Unfall! Schlange stirbt
          s.lebt = false
        end
      end
    }
    # Neue Schlangenpositionen eintragen
    @schlangen.each_index{|i|
      s = @schlangen[i]
      if s.lebt
        x,y,dir = s.wo_bin_ich?
        if (dir==olddata[i][2])
          graphdir = dir % 2 + 8
        else
          olddir = olddata[i][2]
          if (olddir==3 and dir == 0) or (olddir==2  and dir == 1)
            graphdir = 4
          elsif (olddir==0 and dir == 1) or (olddir==3  and dir == 2)
            graphdir = 5
          elsif (olddir==1 and dir == 2) or (olddir==0  and dir == 3)
            graphdir = 6
          elsif (olddir==1 and dir == 0) or (olddir==2  and dir == 3)
            graphdir = 7
          end
        end
        @feld.set_element(olddata[i][0], olddata[i][1], i+1, s.lang-1, graphdir)
        @feld.set_element(x,y,i+1,s.lang,dir)
      end
    }

    update_schlangen_pos

    # Array mit lebenden Schlangen zurückgeben
    return @schlangen.collect{|s| s.lebt}
  end
  
  # Gibt Position und Richtung der aktiven Schlange zurück
  def wo_bin_ich?
    return @schlangen[@aktive_schlange].wo_bin_ich?
  end
  
  # Gibt die Art und den Timer von einem Element vom Feld zurück
  def [](x,y)
    return @feld[x,y]
  end
  
end
