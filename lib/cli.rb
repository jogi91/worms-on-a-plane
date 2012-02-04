#=CommandLineInterface
#
#Wird vielleicht einmal alles übernehmen, die Turniere, 
#die Kommandozielenversion und die MCUF-Version
#
#Im Moment soll es aber nur das Turnier verwalten,
#der ganze Rest läuft über refactoring
#
#GetoptLong: http://ruby-doc.org/stdlib-1.8.7/libdoc/getoptlong/rdoc/index.html

#Parser für die Kommandozeilenargumente einbinden
require "getoptlong"
#kann den Kommentar am Anfang des Files ausgeben
require "rdoc/usage"

opts = GetoptLong.new(
	[ "--help", "-h", GetoptLong::NO_ARGUMENT]
)

opts.each { |opt, arg| 
	case opt
	when "--help"
		RDoc::usage
	end
}

#Die Turniermethoden einbinden
require "tournier"
include Tournier

#bringt die Schlangen zum Schweigen
#
#==TODO:
#sollte nur auf wunsch eingebunden werden können
module Kernel
	alias_method :pdebug, :puts
	def puts(*c)
	end
	alias_method :printdebug, :print
	def print(*c)
	end
end

$match_num = 0

# Strategie-Dateien einlesen
Dir.glob("strategie*.rb") {|stratfile|
  require stratfile
}

require "kombinationen"

# Damit erhalten wir die Klassen aller Strategie-Objekte.
allestrategien = Module.constants.grep(/^Strategie./).sort.collect{|s| Kernel.const_get(s)}

gewaehltestrategien = strategieabfrage(allestrategien)

$unfaelle = Array.new(gewaehltestrategien.size,"")

numstrat = 4
k = Kombinationen.new(gewaehltestrategien.size,numstrat)

punkte = Array.new(gewaehltestrategien.size,0)
punktequadrate = Array.new(gewaehltestrategien.size,0)
punkte_n = Array.new(gewaehltestrategien.size,0)

k.each {|a|
  10.times {
    aa = (a.collect {|i| i-1}).sort_by {rand}
    strategien = aa.collect{|i|
      gewaehltestrategien[i].new
    }
    pkte = match(strategien,aa)
    numstrat.times {|i|
      punkte[aa[i]] += pkte[i]
      punktequadrate[aa[i]] += pkte[i]**2
      punkte_n[aa[i]] += 1
    }
    pdebug "Nach match #{aa.inspect} sind die Punkte:"
    gewaehltestrategien.size.times {|i|
      pdebug "#{gewaehltestrategien[i]} : #{punkte[i]}"
    }
  }
  write_unfaelle(gewaehltestrategien, punkte, punktequadrate, punkte_n)
}
