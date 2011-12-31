#   Snake-Strategie
#   von:
#       _______
#         /    |   
#      __/____/  
#       /
#      / 
#
#   "My software never has bugs. It just develops random features."
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# # # # # # # # # # # # # # # # # # #
#  0 ---------------->  X           #
#  |                                #
#  |        Dir:     3              #   # # # # # # # # # # # # # # # # # # # # #
#  |                 ^              #   #   Feld:                               #
#  |                 |              #   #       0  = leer                       #
#  |         2 < ----o---- > 0      #   #       -1 = Mauer                      #
#  |                 |              #   #       -2 = Apfel                      #
#  v                 v              #   #       n  = Schlangennummer (n > 0)    #
#                    1              #   # # # # # # # # # # # # # # # # # # # # #
#  Y                                #
#                                   #
# # # # # # # # # # # # # # # # # # #






require "strategie"

class Strategie_Pa < Strategie
	
	def initialize
		# @modus: Entscheidung welche Strategie (fressen oder warten)
		# @modus = 0: anfang des Spiels fressen
		# @modus = 1: sobald die Schlange nicht mehr verlieren kann: warten bis zum Spielende
		@modus = 0
		
		# zählt die anzahl Züge
		@zugnr = 0
		# Anzahl der Spielschritte die das Spiel läuft
		@zugmax = 3000
		# Anzahl der Aepfel die ins Spiel kommen
		@gesamtzahl_der_aepfel = 20
		
		# Informationen ausgeben
		@debug = false
	end
	
	
	########################################################################################################################
	def vorlaufige_strategie
		@hauptziel = [ 13, 7]
		distanz = 1000
		@spiel.aepfel.each {
			|apfel|
			if (((@x-apfel[0]).abs+(@y-apfel[1]).abs).abs < distanz)
				distanz = ((@x-apfel[0]).abs+(@y-apfel[1]).abs).abs
				@hauptziel = apfel
			end
		}
		
		
		dir = @indexliste[0]
		@indexliste.each {
			|richtung|
			dx,dy = richtung.to_dir
			if (((@x-@hauptziel[0]).abs+(@y-@hauptziel[1]).abs).abs >= ((@x-@hauptziel[0]+dx).abs+(@y-@hauptziel[1]+dy).abs).abs)
				if(@richtungen[richtung] < 20 && @richtungen[richtung] < @richtungen[@indexliste[0]]+7)	# muss besser als das beste um 10 verschlechtert sein und besser als 30
					return richtung
				end
			end
		}
		return dir
	end
	########################################################################################################################
	
	
	
	
	def anz_moeglichkeiten(x,y,zeitliche_entfernung)
		# zählt die anzahl freier Felder um das Feld x,y , welches in "zeitliche_entfernung" Spielschritten erreicht wird
		anzahlmoeglickeiten = 4
		for i in 0..3
			vx,vy = i.to_dir
			art,timer = @spiel[x+vx,y+vy]
			# wenn auf dem Feld entweder eine Schange (>0) oder eine Mauer (-1) und gleichzeitig der Timer grösser als Entfernung ist (da sonst in den nächsten Zügen gelöscht) oder = 0
			if ((art > 0 || art == -1) && (timer > zeitliche_entfernung+1 || timer = 0))
				anzahlmoeglickeiten -= 1
			end
		end
		return anzahlmoeglickeiten
	end
		
	
	def schlangenkoepfe(x,y)
		# schätzt die Gefahr durch Schlangenköpfe für den Zug NACH Punkt x,y ein
		
		wertung = 0
		# der schlangenindex entspricht der Schlangennummer - 1
		schlangenindex = 0
		# alle Schlangen überprüfen
		@spiel.schlangen_pos.each {
			|schlange|
			# wenn die Schlange noch lebt und nicht die eigene ist
			if (@spiel.lebend[schlangenindex] && schlangenindex+1 != @nummer)
				# Wenn die Distanz von dem Schlangenkopf zum Richtungsfeld gleich 1 ist
				if (((schlange[0] - x).abs + (schlange[1] - y).abs) == 1)
					#puts "schlangenkopf auf [#{schlange[0]},#{schlange[1]}], dir=#{schlange[2]}"
					# Bewertung für Gefahr:
					# anz_moeglichkeiten(schlange[0],schlange[1],0) ist die anzahl Möglichkeiten die die gegnerische Schlange hat
					gegnerische_moeglichkeiten = anz_moeglichkeiten(schlange[0],schlange[1],0)
					if (gegnerische_moeglichkeiten == 1)
						return 99	# keine 100%-ige sicherheit für tod, da die gegnerische Schlange ein Fehler machen kann
					end
					# wenn gegnerische_moeglichkeiten != 1 dann sind sie entweder 2 oder 3
					wertung += (4 - gegnerische_moeglichkeiten)*10
				end
			end
			schlangenindex += 1
		}
		
		# >>> Reaktion auf Apfel mit Schlangen in der nähe
		art,timer = @spiel[x,y]
		if (art == -2)	# wenn es ein Apfel auf dem Feld hat:
			wertung = (wertung * 1.5).to_i
		end
		
		return wertung
		# wertung ist zwischen 0 und 99 (wenn keine schlange in der Nähe: 0 --> für Funktion kein_naher_schlangenkopf)
	end
	
	
	def vektor_verschiebung(x,y,dir)
		vx,vy = dir.to_dir
		return x+vx,y+vy
	end
	
	
	def kein_naher_schlangenkopf(x,y)
		# wenn um den Punkt x,y kein Schlangenkopf ist: true, sonst: false
		# eigener Kopf wird nicht als schlangenkopf gezählt
		if (schlangenkoepfe(x,y) == 0)
			return true
			# kein Kopf
		else
			return false
			# Schlangekopf in der Nähe
		end
	end
	
	
	def geschlossener_bereich(x,y,kennnummer)
		# Gefahr durch abgeschlossene Bereiche bewerten, indem die Bereichgrösse berechnet wird. 
		# "kennnummer" wird für den Eintrag im Array @spielfeld_kopie gebrauch und muss bei jedem Aufruf anders gewählt werden, da sonst nicht richtig gezält wird
		# @spielfeld_kopie[x][y][Attribute(=2)]
		
		zu_puefende_Punkte = Array.new
		# die ersten vier Punkte die geprüft werden sollen
		for i in 0..3
			testx,testy = vektor_verschiebung(x,y,i)
			zu_puefende_Punkte.push([testx,testy])
		end
		
		bereichgroesse = 0
		until (zu_puefende_Punkte.length == 0 || bereichgroesse > @anz_freie_felder/2)		# bis er fertig mit scannen ist oder er schon 1/3 des gesamten freien Spielfeldes gefunden hat
			punkt = zu_puefende_Punkte.pop
			#if ((@spielfeld_kopie[punkt[0]][punkt[1]][0] == 0 || @spielfeld_kopie[punkt[0]][punkt[1]][0] == -2 ) && kein_naher_schlangenkopf(punkt[0],punkt[1]))	# wenn das Feld frei ist und sich kein Schlangenkopf in der Nähe befindet - aus geschwindigkteitsgründen weggelassen
			if (@spielfeld_kopie[punkt[0]][punkt[1]][0] == 0 || @spielfeld_kopie[punkt[0]][punkt[1]][0] == -2 )	# wenn das Feld frei ist
				# weiteres freies Feld im Bereich gefunden:
				# Punkt als gefunden eintragen
				@spielfeld_kopie[punkt[0]][punkt[1]][2] = kennnummer
				
				# Bereichgrösse um 1 erhöhen
				bereichgroesse += 1
				
				# weitere Punkte aufschreiben,
				# welche NICHT SCHON GEPÜFT WORDEN SIND!!!
				for i in 0..3
					testx,testy = vektor_verschiebung(punkt[0],punkt[1],i)
					# wenn der Punkt noch nicht gefunden wurde
					if(@spielfeld_kopie[testx][testy][2] != kennnummer)
						zu_puefende_Punkte.push([testx,testy])
					end
				end
				
			end
		end
		
		rel_groesse = bereichgroesse.to_f/@anz_freie_felder.to_f
		
		if (rel_groesse >= 1.0/2)
			gefahr = 0
		elsif (rel_groesse >= 1.0/3)
			gefahr = 7
		elsif (rel_groesse >= 1.0/5)
			gefahr = 16
		elsif (rel_groesse >= 1.0/10)
			gefahr = 30
		else
			gefahr = 45
		end
		
		puts "Bereichgrösse ist #{bereichgroesse} (rel=#{rel_groesse},  GefahrBereich: #{gefahr})" if @debug
		return gefahr
	end
	
	
	def sortieren(array)
		anz_elemente = array.length
		if(anz_elemente == 0)
			return nil
		end
		alle = Array.new(anz_elemente,1)
		indexliste =  Array.new(anz_elemente,0)
		for i in 0..(anz_elemente-1)
			min = 1000000000000000
			for j in 0..(anz_elemente-1)
				if(array[j] < min && alle[j] == 1)
					index = j
					min = array[j]
				end
			end
			alle[index] = 0
			indexliste[i] = index
		end
		return indexliste
	end
	
	
	def direktester_weg
		# findet den direktesten Weg zum Apfel
		# Als ziel wird der 1. Apfel im Array @spiel.aepfel genommen
		ziel = @spiel.aepfel[0]
		
		# kreise um 1.ziel bis : zu viele kreise, bei meiner Schlange, bereich gefüllt
		# in @spielfeld_kopie[x][y][3]
		
		
		# gibt Array mit richtungen zurück die 
		# return [dir1,dir2,dir3]
		return false
	end
	
	def killmoeglichkeiten
		# findet mögliche kills (z.B. weg Abschneiden)
		@spiel.schlangen_pos.each {
			|schlange|
			
			}
		kills = [false,false,false,false]
		return kills
	end
	
	
	def strategie_fressen
		# frisst Äpfel ohne zu sterben
	
		# @richtungen: Array, welches die Richtungen 0-3 enthält
		# Zahl(int) = Bewertung des Zuges nach der Gefahr
		# 100 = Mauer/Hindernis -> sicherer Tod in DIESEM Zug!
		# 0 = keine Bedrohung
		@richtungen = [0,0,0,0]
		
		# Richtungen bewerten
		for richtung in 0..3	# Richtungen von 0 bis 3 durchgehen
			zug_x,zug_y = vektor_verschiebung(@x,@y,richtung)
			art,timer = @spiel[zug_x,zug_y]
			if (art == 0 || art == -2 || timer == 1)	# wenn auf dem Feld etweder nichts(0) oder ein Apfel(-2) ist oder das Feld im nächsten Zug geloescht wird (timer = 1)
				# Richtung ist frei
				# Bewertung:
				moeglichkeiten = anz_moeglichkeiten(zug_x,zug_y,1)		# Anzahl angrenzende, freie Felder (0-3)
				gefahr_schlangen = schlangenkoepfe(zug_x,zug_y)			# Gefahr durch Schlangenkopf (Bewertung in 0-99)
				puts "schlangen: #{gefahr_schlangen}, moeglichkeiten: #{moeglichkeiten}" if @debug
				if(gefahr_schlangen == 99)
					@richtungen[richtung] = 99
				elsif(moeglichkeiten == 0)
					@richtungen[richtung] = 99
				else
					@richtungen[richtung] = gefahr_schlangen
					@richtungen[richtung] += (3-moeglichkeiten)*6
					@richtungen[richtung] += geschlossener_bereich(zug_x,zug_y,richtung+1)	# Gefahr durch abgeschlossener (kleiner) Bereich 
				end
				
			else
				# in der Richtung ist ein Hindernis
				@richtungen[richtung] = 100		# Richtung mit 100 (am schlechtesten) bewerten
			end
		end
		
		@indexliste = sortieren(@richtungen)
		
		# Array mit der Distanz zum Ziel für jede Richtung 0-3
		wege = direktester_weg
		# Array mit true oder false für jede Richtung 0-3 (true = kill)
		kills = killmoeglichkeiten
		
		
		dir = vorlaufige_strategie
		
		if (@debug)
			puts "[re,ab,li,auf]"
			print @richtungen.inspect
			puts @indexliste.inspect
		end
		return dir
	end
		
	
	
	
	
	def wohin?(spiel)

		@spiel = spiel
		
		# Position und Richtung der Schlange
		@x,@y,@dir = @spiel.wo_bin_ich?
		dir = @dir
		
		begin	# Timersicherung
		Timeout.timeout(0.1) {
		
		# Schlangen-Nummer und Länge der Schlange (nummer von 1-n)
		@nummer,@laenge = @spiel[@x,@y]
		
		# Zugnummer hochzählen
		@zugnr += 1
		
		# Schlangenlängen aufschreiben
		@schlangenlaengen = Array.new
		@gesamtlaenge_schlangen = 0
		@anzahl_schlangen = 0
		i = 0
		@spiel.schlangen_pos.each {
			|schlange|
			if(@spiel.lebend[i])	# wenn die Schlange noch lebt
				nummer,laenge = @spiel[schlange[0],schlange[1]]
				@gesamtlaenge_schlangen += laenge
				@schlangenlaengen.push(laenge)
				@anzahl_schlangen += 1
			else
				@schlangenlaengen.push(0)
			end
			i += 1
		}
		
		# Beim 1. Zug:
		if (@zugnr == 1)
			# Informationen zum Spielfeld
			@max_x = @spiel.x
			@max_y = @spiel.y
		end
		
		# Spielfeld scannen
		# @spielfeld_kopie[x][y][Attribute] Attribute: 0=art, 1=timer, 2=geschlossenerBereich-status, 3=schnellsterWegApfel-status
		@spielfeld_kopie = Array.new()
		for xfeld in 0..@max_x-1
			spalte = Array.new
			for yfeld in 0..@max_y-1
				art,timer = @spiel[xfeld,yfeld]
				spalte.push([art,timer,0,0])
				# jedes Feld enthält [art,timer,für geschlossener Bereich,für schnellster weg zum Apfel]
			end
			@spielfeld_kopie.push(spalte)
		end
		
		# Beim 1. Zug:
		if (@zugnr == 1)
			@gesamtzahl_felder = @max_x*@max_y
			@gesamtzahl_freie_felder = @gesamtzahl_felder		# Anzahl freie Felder im Spielfeld (ohne Schlangen)
			@spielfeld_kopie.each {
				|spalte|
				spalte.each {
					|feld|
					if (feld[0] == -1)		# Wenn art = eine Mauer
						@gesamtzahl_freie_felder -= 1
					end
				}
			}
			
			# Damit in 1. Zug geradeaus läuft
			puts "1. Zug der Schlange #{@nummer}: geradeaus" if @debug
			return @dir
		end
		# Anzahl freie Felder (inkl. Schlangen)
		@anz_freie_felder = @gesamtzahl_freie_felder - @gesamtlaenge_schlangen
		
		# vorläufiges dir:
		for i in 0..3
			dx,dy = vektor_verschiebung(@x,@y,i)
			art,timer = @spiel[dx,dy]
			if (art == 0 || art == -2 || timer == 1)	# wenn das Feld frei ist
				dir = i
			end
		end
		
		
		if (@debug)
			puts "Allgemeine Infos Spielschritt #{@zugnr}:"
			puts "Schlangen: #{@spiel.schlangen_pos.inspect} (#{@spiel.lebend.inspect}), (Anzahl Schlangen = #{@anzahl_schlangen})"
			puts "Spielfeld: Felder: Gesamtzahl: #{@gesamtzahl_felder} davon #{@gesamtzahl_freie_felder} frei (mit Schlangen: #{@anz_freie_felder} frei)"
			puts "********* Schlange #{@nummer}, Position [#{@x},#{@y}], Laenge #{@laenge} ************************************"
		end
		dir = strategie_fressen
		
		if (@debug)
			if (@richtungen[dir] == 100) # wenn meine Schlange jetzt stirbt
				puts "Schlange stirbt!"
				gets
			end
			puts "Return: #{dir}, Gefahr: #{@richtungen[dir]}"
			puts "********* Ende Schlange #{@nummer} ************************************"
		end
		return dir
		
		             
		}
        rescue Timeout::Error => e
          puts "Funktion aus Zeitmangel abgebrochen"
		  return dir
        end
		
	end
end
