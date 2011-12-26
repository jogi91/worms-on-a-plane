# Interface für FX-Ruby
# 
# Diese Datei modifiziert das Objekt Element, so dass bei jeder
# änderung die Gafik automatisch neu gezeichnet wird.
# 

require 'rubygems'
require 'fox16'
require 'fox16/kwargs'

include Fox


require "spiel"
require "element"
require "tournier_dialog"

class Element
  # Neue Klassenvariable für die Grafik
  def self.set_fxwin(win)
    @@snakewindow = win
  end

  # Methode set klonen  und eigene einhängen.
  alias_method :set_old, :set
  def set(*p)
    set_old(*p);
    element_change;
  end
  
  # Callback zur Grafik
  def element_change
    if defined? @@snakewindow and @@snakewindow != nil
      @@snakewindow.zeichne(@x,@y,@art, @dir)
    end
  end
end

class SnakeWindow < FXMainWindow
  attr_accessor :canvas
  
  # Zeichnet die Schlangen (wäre schöner mit vorgefertigten Bitmaps!
  
  def element_zeichnen(dc,x,y,art,dir)
    dx = 20
    ddx = 2
    dc.foreground = "white"
    dc.fillRectangle(x*dx, y*dx, dx, dx)
    dc.foreground = @colors[art]
    if (art>0)
        
      if (dir==8)   
        dc.fillRectangle(x*dx, y*dx+ddx, dx, dx-2*ddx)
      end
      if (dir == 9)
        dc.fillRectangle(x*dx+ddx, y*dx, dx-2*ddx, dx)
      end
      if (dir ==0 or dir==5 or dir==6)
        dc.fillRectangle(x*dx, y*dx+ddx, dx/2, dx-2*ddx)
      end
      if (dir == 1 or dir ==6 or dir == 7)
        dc.fillRectangle(x*dx+ddx, y*dx, dx-2*ddx, dx/2)
      end
      if (dir == 2 or dir == 4 or dir == 7)
        dc.fillRectangle(x*dx+dx/2, y*dx+ddx, dx/2, dx-2*ddx)
      end
      if (dir == 3 or dir == 4 or dir == 5)
        dc.fillRectangle(x*dx+ddx, y*dx+dx/2, dx-2*ddx, dx/2)
      end
      if (dir != 8 and dir != 9)
        dc.fillCircle(x*dx+dx/2, y*dx+dx/2, dx/2-ddx)
      end
    else
      case art
      when -1:
        dc.fillRectangle(x*dx, y*dx, dx, dx)
      when -2:
        dc.fillCircle(x*dx+dx/2, y*dx+dx/2, dx/2)
      end
    end         
    
  end
  
  def zeichne(x,y,art,dir)
    #puts "Zeichne(#{x}, #{y}, #{art}, #{dir})"
    dc = FXDCWindow.new(@canvas)
    element_zeichnen(dc,x,y,art,dir)
    dc.end
  end
  
  def alles_zeichnen
    dc = FXDCWindow.new(@canvas)
    dc.foreground = "white"
    dc.fillRectangle(0, 0, @canvas.width, @canvas.height)
    if @spiel
      feld = @spiel.feld
      for y in 0...@spiel.y
        for x in 0...@spiel.x
          art,timer,dir = feld[x,y]
          if (art != 0)
            element_zeichnen(dc,x,y,art,dir)
          end
        end
      end
    end
    dc.end
  end
  
  def initialize(app, strategien)
    
    @strategien = strategien
    @spiel = nil
    @starts = nil
    @speed = 50
    @timeoutref = nil
#    puts "app #{app}"
    super(app, "Snake",  :width => 1000, :height => 860)

    
    @colors = {-2=>"yellow", -1=>"black", 0=>"white", 1=>'blue', 2=>'red', 3=>'green', 4=>'purple'}

    # Menu-Leiste (Oben, über ganze Breite)
    menu_leiste = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

    # Menu-Punkt Datei
    datei_menu = FXMenuPane.new(self)
    # Ein Eintrag (Parameter regeln)
    FXMenuCommand.new(datei_menu, "&Parameter\tCtl-P").connect(SEL_COMMAND) {
      parameter_dialog
    }
    FXMenuCommand.new(datei_menu, "&Start\tCtl-G").connect(SEL_COMMAND) {
      stop_game
      new_game
      start_game
    }
    FXMenuCommand.new(datei_menu, "&Stop\tCtl-C").connect(SEL_COMMAND) {
      stop_game
    }
    # Ein Eintrag (Quit)
    FXMenuCommand.new(datei_menu, "&Verlassen\tCtl-Q", nil, getApp(), FXApp::ID_QUIT)
    # Menu-Punkt "Datei" ins Menu einfügen
    FXMenuTitle.new(menu_leiste, "&Datei", nil, datei_menu)

    # Status-Zeile
    status_platz = FXHorizontalFrame.new(self,
        LAYOUT_SIDE_BOTTOM|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH)
    @status = FXStatusLine.new(status_platz)
    
    # Drawing canvas
    @canvas = FXCanvas.new(self, :opts => LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT)
    @canvas.connect(SEL_PAINT) { |sender, sel, event|
      alles_zeichnen
    }


    @canvas.connect(SEL_KEYPRESS) { |sender, sel, event|
      @spiel.strategien.each {|s| 
        s.taste(event.code) if s.respond_to?(:taste)
      } if @spiel != nil
#      self.handle(sender, sel, event)
#      puts "Key down: #{event.code}"
    }
#    @canvas.connect(SEL_KEYRELEASE) { |sender, sel, event|
#      puts "Key up: #{event.code}"
#    }
    
    # Timeouts
    # da drin läuft das Game ab.
    
    # Den Elementen sagen, wo gezeichnet werden soll.
    Element.set_fxwin(self);
    @lebend = 0
    
    @timeouthandler = lambda { |sender, sel, data|
      if (@lebend>0)
        if @spiel.numapf == 41 || @spiel.schritt==3000
          text = "Punkte: "
          @strats.size.times {|i|
            text += @strats[i].to_s + ": "+@spiel.schlang[i].to_s+"  " if @spiel.lebend[i]
          }
          @status.normalText = text if text!=@status.normalText and @lebend>0
          stop_game
        else        
          res = @spiel.aktualisieren
          @lebend = 0
          res.each {|l| @lebend += 1 if l }
          text = "#{@spiel.numapf} : "
          @strats.size.times {|i|
            text += @strats[i].to_s + ": "+@colors[i+1]+"  " if res[i]
          }
          @status.normalText = text if text!=@status.normalText and @lebend>0
          @timeoutref = self.app.addTimeout(@speed,  @timeouthandler)
        end
      else
        stop_game
      end
    }
    
#    app.addTimeout(100, @timeouthandler)

  end
  
  def start_game
    if @spiel
      @timeoutref = self.app.addTimeout(@speed, @timeouthandler)
      @canvas.setFocus
    end
  end
  
  def stop_game
    self.app.removeTimeout(@timeoutref) if @timeoutref
    @lebend = 0
    @spiel = nil
  end
  
  def new_game
    if @strats
      unless @strats.include?(Strategie_tastatur)
        @strats = @strats.sort_by { rand } 
      end
      @lebend = @strats.size
      @spiel = Spiel.new(50, 40, Array.new(@lebend) {|i| @strats[i].new}, 0)
      text = ""
      @strats.size.times {|i|
        text += @strats[i].to_s + ": "+@colors[i+1]+"  "
      }
      @status.normalText = text
    else
      @status.normalText = "Zuerst die Parameter festlegen!"
    end
  end

  def parameter_dialog
    dialog = Tournier_dialog.new(self, @strategien)
    # Wenn OK-Knopf gedrückt, updated und zeichnen
    if dialog.execute == 1
      dialog.schreibe_werte
      @speed = dialog.speed.value
      @strats = Array.new(dialog.anzahl.value) {|i| @strategien[dialog.auswahl[i].value] }
      new_game
      start_game
    end
    return 1
  end
  
  def create
    super
    show
  end
end

