#Dieses File soll die Methoden bereitstellen,
#einen Feldstring in einen MCUF-Stream umzuwandeln.
#Dabei soll die Grösse des Displays angegeben werden können,
#damit das Feld angepasst werden kann.

#Übernimmt einen Feld-String und schippselt ihn
#auf die gewünschte Anzeigengrösse zurecht
#
#Gibt wieder einen String zurück
#TODO
def zoom (feld, hoehe, breite)
	
end

#Nimmt einen Feldstring und konvertiert ihn in
#MCUF-Pixeldaten (Die Payload des Pakets)
#Die restliche konfiguration sollte beim Senden erfolgen
#
#http://wiki.blinkenarea.org/index.php/MicroControllerUnitFrame
#
#Die Feldtypen sollte man in der Dokumentation der Klasse Feld finden
#
#TODO
def convertToMCUF (string)
	result = String.new
	result = string.gsub(/\./, "\x00") #leere Felder (.) durch das Hex-Value 0 ersetzen
	result = result.gsub(/\*/, "\xFF") # Der Apfel darf leuchten
	result = result.gsub(/#/, "\x7F") # Wände nur halb so hell
	#Schlangen
	result = result.gsub(/1/, "\xF0")
	result = result.gsub(/2/, "\xC8")
	result = result.gsub(/3/, "\xA0")
	result = result.gsub(/4/, "\x64")
	
	#Sehe keine Sinnvolle abkürzung, wenn die Schlangen
	#unterschiedlich hell sein sollen.
	#for i in 0..3
	#result = result.gsub(/#{i}/,"")
	#end
	
	result = result.gsub(/\s+/, "") #Whitespaces entfernen
	return result
end
