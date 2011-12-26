require "spiel"

module Kernel
  alias_method :pdebug, :puts
  def puts(*c)
  end
  alias_method :printdebug, :print
  def print(*c)
  end
end

def get_bytes(color)
  r = ""
  color.split(" ").each {|n|
    r += n.to_i.chr
  }
  return r
end

def make_animation(felder, strats, matchnum, schritt)
  colors = ["255 0 0", "0 255 0", "0 0 255", 
            "200 200 0", "0 200 200", "200 0 200",
            "100 100 100","100 0 0", "0 100 0", "0 0 100"]
  transp = "123 123 123"
  black = "0 0 0"
  white = "255 255 255"
  prefix = sprintf("%04d-%04d",matchnum,schritt)
  filename = "00"
  convert = "convert -delay 50 -dispose None -layers optimize"
  for i in 0...felder.size
    if false and i>0  # and i<felder.size-1
      convert += " -transparent \"rgb(123,123,123)\""
    end
    convert += " output/#{filename}.ppm"
    ppm = File.open("output/#{filename}.ppm", "w")
    filename = filename.succ
    ppm.print "P6\n40 30 255\n"
    for p in 0...felder[i].size
      c = felder[i][p].chr
      if false and i>0  # and i<felder.size-1
        cc = felder[i-1][p].chr
      else
        cc = "9"
      end
      if c == "\n"
#        ppm.print "\n"
      else
        if c!=cc
          if c== "."
            ppm.print get_bytes(white)
          elsif c == "#" or c=="*"
            ppm.print get_bytes(black)
          elsif c.to_i>0
            ppm.print get_bytes(colors[strats[c.to_i-1]])
          end
        else
          ppm.print get_bytes(transp)
        end
      end
    end
    ppm.close
  end
  convert += " -loop 0 output/#{prefix}.gif"
  pdebug convert
  `#{convert}`
  return "<img width=\"400\" height=\"300\" alt=\"Match #{matchnum}, Schritte #{schritt-10} bis #{schritt}\" src=\"#{prefix}.gif\">"
end


def match(strategien, perm)
    pdebug "Match mit\n#{strategien.join(",\n")}"
    spiel = Spiel.new(40, 30, strategien, 0)
    schritt = 0
    felder = []
    lebend = Array.new(strategien.size,true)
    begin
      res = spiel.aktualisieren
      schritt += 1
      felder.push(spiel.feld.to_s)
      felder.shift if (felder.size>10)
      l = 0
      res.each_index {|i|
        if res[i] != lebend[i]
          $unfaelle[perm[i]] += make_animation(felder, perm, $match_num, schritt)
          lebend[i] = res[i]
        end
      }
    end until schritt==3000 or res.index(true) == nil or spiel.numapf==21
    punkte = Array.new(4,0)
    strategien.size.times {|i|
      if spiel.lebend[i]
        punkte[i] = spiel.schlang[i]
      end
    }
    #pdebug spiel.feld.to_s
    pdebug "#{schritt} Spielschritte, Resultat #{punkte.inspect}"
    $match_num += 1
    return punkte
end

def write_unfaelle(strats, punkte, punktequadrate, punkte_n)
  colors = ["255 0 0", "0 255 0", "0 0 255", 
            "200 200 0", "0 200 200", "200 0 200",
            "100 100 100","100 0 0", "0 100 0", "0 0 100"]
  
  legende = "<ul>\n"
  strats.each_index{|i|
    color = colors[i].gsub(/ /,",")
    if punkte_n[i]>1
      s = Math::sqrt(1.0/(punkte_n[i]-1)*(punktequadrate[i]-1.0/punkte_n[i]*punkte[i]))
      s = (s*Math::sqrt(punkte_n[i])).to_i
      intervall = "[#{punkte[i]-s},#{punkte[i]+s}]"
    else
      intervall = ""
    end
    legende += "<li><a href=\"#{strats[i].to_s}.html\" style=\"color:rgb(#{color});\">#{strats[i].to_s} (#{punkte[i]} Punkte)  68%-Konfidenzintervall: #{intervall}</a></li>\n"
  }
  legende += "</ul>\n"
  strats.each_index {|i|
    s = strats[i].to_s
    color = colors[i].gsub(/ /,",")
    html = File.open("output/#{s}.html","w")
    html.puts "<html><head><title>Always look on the bright side of death...</title></head><body><h1 style=\"color:rgb(#{color});\">#{s}</h1>"
    html.puts legende
    html.puts $unfaelle[i]
    html.puts "</body></html>"
    html.close
  }
end

$match_num = 0

# Strategie-Dateien einlesen
Dir.glob("strategie*.rb") {|stratfile|
  require stratfile
}

require "kombinationen"

# Damit erhalten wir die Klassen aller Strategie-Objekte.
allestrategien = Module.constants.grep(/^Strategie./).sort.collect{|s| Kernel.const_get(s)}

# Die lahmen Enten ausschalten zum Testen :-P
# allestrategien[allestrategien.index(Strategie_simon4)] = Strategie_zeno_alt
# allestrategien[allestrategien.index(Strategie_Pa2)] = Strategie_zeno

$unfaelle = Array.new(allestrategien.size,"")

numstrat = 4
k = Kombinationen.new(allestrategien.size,numstrat)

punkte = Array.new(allestrategien.size,0)
punktequadrate = Array.new(allestrategien.size,0)
punkte_n = Array.new(allestrategien.size,0)

k.each {|a|
  10.times {
    aa = (a.collect {|i| i-1}).sort_by {rand}
    strategien = aa.collect{|i|
      allestrategien[i].new
    }
    pkte = match(strategien,aa)
    numstrat.times {|i|
      punkte[aa[i]] += pkte[i]
      punktequadrate[aa[i]] += pkte[i]**2
      punkte_n[aa[i]] += 1
    }
    pdebug "Nach match #{aa.inspect} sind die Punkte:"
    allestrategien.size.times {|i|
      pdebug "#{allestrategien[i]} : #{punkte[i]}"
    }
  }
  write_unfaelle(allestrategien, punkte, punktequadrate, punkte_n)
}