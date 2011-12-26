# 
# Dieses Modul enthält nützliche Routinen
# und Erweiterungen von Ruby Standard-Objekten
 

module Tools  
  
end


class Integer
    # Wandelt einen Ganzzahlwert in einen Richtungsvektor der Länge 1 um.
    # Der Vektor wird in Komma-Schreibweise zurückgegeben.
    # z.B. a,b = 2.dir (ergibt -1,0).
    # Definiert sind Werte von 0-3 (90 Grad-Schritte im Einheitskreis)
    def to_dir
      case self
      when 0:
          return 1,0
      when 1:
          return 0,1
      when 2:
          return -1,0
      when 3:
          return 0,-1
      else
          raise "Richtungen sind nur für Zahlen von 0-3 definiert"
      end
    end
end
