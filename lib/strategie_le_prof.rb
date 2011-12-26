
require "strategie"

class Fixnum
  def sign
    return 1 if self>0
    return 0 if self == 0
    return -1 if self<0
  end
end

# Strategie du Prof
class Strategie_leProf < Strategie
  def initialize
    @force = 0
    @boese = Array.new(4,false)
  end
  
  # 
  def wohin?(spiel)
    @spiel = spiel
    # Position und Richtung meiner Schlange
    x,y,dir = spiel.wo_bin_ich?
    # Apfel
    apfx, apfy = *spiel.aepfel[0]
    # Distanzen der Schlangen
    dist = Array.new(spiel.schlangen_pos.size) {|i|
      (spiel.schlangen_pos[i][0]-apfx).abs+(spiel.schlangen_pos[i][1]-apfy).abs
    }
    # Meinen Index ermitteln und tote Schlange aussortieren
    me = nil
    spiel.schlangen_pos.each_index {|i|
      p = spiel.schlangen_pos[i]
      if p[0] == x and p[1]==y
        me = i
      end
      if spiel.lebend[i] == false
          dist[i] = 99999
      end
    }
    @me = me
 #   #puts "[#{@me}] Ich bin #{me} at #{spiel.schlangen_pos[me].inspect}"

    d = check_program(x,y,dir,spiel)
    if d
      #puts "[#{@me}] Programm sagt #{d}"
    end
    
    
    # Sonst mal schauen, ob ich böse sein kann
    t,s = kann_boese_sein(spiel,me)
    if t>0 and @boese[s] == false
      @boese[s] = true
      
      @program = quetschen(spiel, me, s)
      d = check_program(x,y,dir,spiel)
      if d
        #puts "[#{@me}] Beginne zu quetschen mit #{d}"
        return d 
      end
      @program = verar___en(t, me, s)
      d = check_program(x,y,dir,spiel)
      if d
        #puts "[#{@me}] Beginne zu verar___en mit #{d}"
        return d
      end     
#      #puts "[#{@me}] #{me} kann böse sein mit t=#{t} und s=#{s} at #{spiel.schlangen_pos[s].inspect}"
    elsif t == 0
      @boese = Array.new(4,false)
    end

=begin    # Direkter Weg zur Schlange (nur beide Rechtecksmöglichkeiten), wenn
    # ich auch am nächsten bin.
    if dist.min == dist[me]
      d = check_next(x,y,dir, apfx,apfy)
      if d != nil
        @force = 0
        return d
      end
    end
=end    
    # Wenn nicht, dann doch den Apfel suchen (eine andere Schlange macht ja
    # vielleicht Umwege
    d = check_next(x,y,dir, apfx,apfy)
    if d != nil
      @force = 0
      #puts "[#{@me}] Kann auf direktem Weg zum Apfel mit #{d}"
      return d
    end
    
    
    # Direkter Weg nicht möglich

    # Müssen wir Heizkörper bauen?
    if @force !=0 
      d = (dir+@force)%4
      if check_dir(spiel,x,y,d) and (not sackgasse?(x,y,d))
        #puts "[#{@me}] Wir Heizkörpern mit #{d}"
        @force = 0
        return d
      end
      
      @force = 0
    end
    
    # Sonst mal weiter in die gleiche Richtung  
    
    # Ausser wenn Hindernis
    unless check_dir(spiel,x,y,dir) and (not sackgasse?(x,y,dir))
      plus = false
      minus = false
      if check_dir(spiel,x,y,(dir+1)%4) and (not sackgasse?(x,y,(dir+1)%4))
        plus = true
      end
      if check_dir(spiel,x,y,(dir-1)%4) and (not sackgasse?(x,y,(dir-1)%4))
        minus = true
      end
      # Wenn sowohl links und rechts offen sind
      if minus and plus
        gplus = gefaengnis(x,y,dir, 1)
        gminus = gefaengnis(x,y,dir, -1)
        if gplus>gminus
          #puts "[#{@me}] Plus #{gplus} > Minus #{gminus} mit #{(dir+1)%4}"
          return (dir+1) % 4
        else
          #puts "[#{@me}] Plus #{gplus} <= Minus #{gminus} mit #{(dir-1)%4}"
          return (dir-1) % 4
        end
      else
        if plus
          @force = 1
          #puts "[#{@me}] Muss nach #{(dir+1)%4}"
          return (dir+1)%4
        elsif minus
          #puts "[#{@me}] Muss nach #{(dir-1)%4}"
          @force = -1
          return (dir-1)%4
        end
      end
    end
    if check_dir(spiel,x,y,dir,false)
      #puts "[#{@me}] Erst mal weiter nach #{dir}"      
      return dir
    end
    ([-1,1].sort_by { rand }).each {|d|
      d = (dir+d)%4
      if check_dir(spiel,x,y,d,false)
        #puts "[#{@me}] Zufallsrichtung nach #{dir}"
        return d
      end
    }
    #puts "[#{@me}] Bin wohl tot... #{dir}"
    return dir
  end

  def check_program(x,y,dir,spiel)
    return nil if @program == nil
    d = @program.shift
    if check_dir(spiel,x,y,d)
      if @programcondition == "kleben"
        victim = @boese.index(true)
        if victim == nil
          @programcondtion = nil
          @program = nil
          @boese = Array.new(4,false)
          return nil
        end
        a,b = spiel.schlangen_pos[victim]
        ok = false
        for i in 0..3
          fx, fy = i.to_dir
          xx,yy = a+fx, b+fy
          if spiel[xx,yy][0] == (@me+1)
            ok = true
          end
        end
        unless ok
          @programcondtion = nil
          @program = nil
          return nil
        end
      end
      if sackgasse?(x,y,d)
          @programcondtion = nil
          @program = nil
          return nil        
      end
      @program=nil if @program.size ==0
#      #puts "[#{@me}] Programm ok to #{d} remains #{@program.inspect}"
#      gets
      return d
    end
    @program = nil
    return nil
  end
  
  # Liefert true, wenn Spielzug ok
  def check_dir(spiel,x,y,dir, harakiri_detection = true)
    fx,fy = dir.to_dir
    a,b = x+fx, y+fy
    return false if spiel[a,b][0] !=0 and spiel[a,b][0] != -2
    return true unless harakiri_detection
    spiel.schlangen_pos.each_index {|i|
      if (spiel.lebend[i])
        p = spiel.schlangen_pos[i]
#        #puts "[#{@me}] x,y: #{x},#{y}   a,b #{a},#{b}  and p=#{p.inspect}"
        if ((p[0]-a).abs + (p[1]-b).abs) == 1 and ((p[0]-x).abs + (p[1]-y).abs) > 0
#          #puts "[#{@me}] Harakiri detection! Me at #{x},#{y}, the other at #{p.inspect}"
          return false
        end
      end
    }
    return true
  end
  
  # Baut ein Programm um anschmiegsame Schlangen einzuschliessen
  def verar___en(t, me, victim)
    x,y,dir = @spiel.schlangen_pos[me]
    a,b,dirv = @spiel.schlangen_pos[victim]
    tdiff = @spiel[x,y][1] - t
    if (tdiff>=8 and tdiff <=16 and dir == dirv)
      turn = 0
      fx,fy = dir.to_dir
      dx,dy = x-a, y-b
      if (dx.abs == 1 or dy.abs==1)
        if (dx*fy-dy*fx > 0)
          turn = 1
        else
          turn = -1
        end
        p = [1,1,1,1,2,2,2]+Array.new((tdiff-8)/2,2)+[3,3,2]
        p = p.collect{|d| (d*turn+dir)%4}
#        #puts "[#{@me}] verar__en -> #{p.inspect}"
#        gets
        @programcondition = "kleben"
        return p
      end
    end
    return nil
  end

  # Treppenprogramm zur Wand, wenn eine Schlange hinter mir
  def quetschen(spiel, me, victim)
    x,y,dirm = spiel.schlangen_pos[me]
    a,b,dirv = spiel.schlangen_pos[victim]
    dist = 5
    if (x<dist and (dirm % 2 ==1) and a<x)
      return Array.new(2*(x-1)) {|i| i%2==0 ? 2 : dirm}
    elsif (x>=spiel.x-dist and (dirm % 2 ==1) and a>x)
      return Array.new(2*(spiel.x-x-1)) {|i| i%2==0 ? 0 : dirm}
    elsif (y<dist and (dirm % 2 == 0) and b<y)
      return Array.new(2*(y-1)){|i| i%2==0 ? 3 : dirm}
    elsif (y>=spiel.y-dist and (dirm % 2 == 0) and b>y)
      return Array.new(2*(spiel.y-y-1)) {|i| i%2==0 ? 1 : dirm}
    end
    return nil
  end     
  # Gibt den Timer des eigenen Schlangenfeldes
  # neben der nächsten anschmiegsamen Schlange zurück und deren Position
  # 
  def kann_boese_sein(spiel,me)
    found = 0
    schlange = nil
    spiel.schlangen_pos.each_index {|i|
      if (i != me) and spiel.lebend[i]
          p = spiel.schlangen_pos[i]
          for d in 0..3
            fx,fy = d.to_dir
            x,y = p[0]+fx,p[1]+fy
            art,timer = spiel[x,y]
 #           #puts "[#{@me}] pos #{x},#{y} has #{art}, #{timer}"
            if art == (me+1)
              if timer>found
                found = timer
                schlange = i
              end
            end
          end
      end 
    }
    return found, schlange
  end
  
  # Direkten Weg zum Apfel?
  def check_next(x,y,dir,apfx,apfy)
    fx, fy = (apfx-x).sign, (apfy-y).sign
    # Zuerst in X-Richtung
    if fx != 0 and dir != (1+fx)
      if check_line(x,y,apfx,y,fx,0) and
          check_line(apfx,y,apfx,apfy,0,fy)
        return 1-fx if check_dir(@spiel,x,y,1-fx) and (not sackgasse?(x,y,1-fx))
      end
    end
    if fy !=0 and dir != (2+fy)
      if check_line(x,y,x,apfy,0,fy) and
          check_line(x,apfy,apfx,apfy,fx,0)
        return 2-fy if check_dir(@spiel,x,y,2-fy) and (not sackgasse?(x,y,2-fy))
      end
    end
    return nil
  end
  
  # Eventuelle Sackgasse voraus?
  # True falls ja
  def sackgasse?(x,y,dir)
    fx,fy = dir.to_dir
    a,b = x+fx,y+fy
    if check_dir(@spiel,a,b,(dir+1)%4,false) == false and
       check_dir(@spiel,a,b,(dir-1)%4,false) == false
       #puts "[#{@me}] Sackgasse gefunden! #{x},#{y} - #{dir}"
       return true
    end
    return false
  end
  
  # Ueberprueft alle Felder ohne a,b bis und mit x,y
  # ob die Felder frei sind (oder werden!)
  def check_line(a,b,x,y,fx,fy,timer = 0)
    while a!=x or b!=y
      a+=fx
      b+=fy
      timer += 1
      art,tm = @spiel[a,b]
      return false if art == -1
      return false if art > 0 and timer<tm
    end
    return true
  end

  # Gibt das letzte freie Feld auf einer Geraden zurück
  def frei_bis(a,b,dir)
#    #puts "[#{@me}] frei_bis(#{a}, #{b}, #{dir}, #{timer})"
    fx,fy = dir.to_dir
    begin
      a += fx
      b += fy
      art, tm = @spiel[a,b]
    end until art==-1 or (art>0)
    a -= fx
    b -= fy
    return a,b
  end
  
  # gibt die Grösse vom "Gefängnis" zurück, wenn man bei a,b + dir startet
  # Grobe Schätzung. Inspiriert von der Idee von
  # Dominik Reukauf
  def gefaengnis(a,b,dir,drehsinn)
    seiten = []
    for i in 0..3
      dir = (dir+drehsinn) % 4
#      #puts "[#{@me}] gefaengnis(#{a},#{b},#{dir},#{drehsinn})"
      x,y = frei_bis(a,b,dir)
      seiten.push((x-a).abs+(y-b).abs)
      a,b = x,y
    end
    r=[seiten[0],seiten[2]].min*[seiten[1]*seiten[3]].min
#    #puts "[#{@me}]     ergibt #{r} aus #{seiten.inspect}"
    return r
  end 
end
