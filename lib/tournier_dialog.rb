# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class Tournier_dialog < FXDialogBox
  
  attr_reader :anzahl, :auswahl, :speed
  
  def initialize(anwendung, strategien)
    # Konstruktor der Mutterklasse aufrufen
    super(anwendung, "Strategie-Auswahl", DECOR_TITLE|DECOR_BORDER)

    # Werte holen
    hole_werte

    
    # Platz für Anzahl
    anzahl_platz = FXHorizontalFrame.new(self,
        LAYOUT_SIDE_TOP|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH,
        :padLeft => 20, :padRight => 20, :padTop => 10, :padBottom => 10)

    # Label
    FXLabel.new(anzahl_platz, "Anzahl Strategien: ",nil, 
      LAYOUT_CENTER_Y|LAYOUT_CENTER_X)

    # Slider
    slider = FXSlider.new(anzahl_platz, @anzahl, FXDataTarget::ID_VALUE, (SLIDER_HORIZONTAL|
      SLIDER_INSIDE_BAR|LAYOUT_FILL_X))
    slider.range = 1..4
    slider.increment = 1
    
    textfeld = FXTextField.new(anzahl_platz, 2, @anzahl, FXDataTarget::ID_VALUE,
      LAYOUT_CENTER_Y|LAYOUT_CENTER_X|FRAME_SUNKEN|FRAME_THICK)
    textfeld.disable

    
    # Platz für Speed
    speed_platz = FXHorizontalFrame.new(self,
        LAYOUT_SIDE_TOP|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH,
        :padLeft => 20, :padRight => 20, :padTop => 10, :padBottom => 10)

    # Label
    FXLabel.new(speed_platz, "Zeit pro Schritt (ms): ",nil, 
      LAYOUT_CENTER_Y|LAYOUT_CENTER_X)

    # Slider
    slider = FXSlider.new(speed_platz, @speed, FXDataTarget::ID_VALUE, (SLIDER_HORIZONTAL|
      SLIDER_INSIDE_BAR|LAYOUT_FILL_X))
    slider.range = 1..200
    slider.increment = 1
    
    textfeld = FXTextField.new(speed_platz, 3, @speed, FXDataTarget::ID_VALUE,
      LAYOUT_CENTER_Y|LAYOUT_CENTER_X|FRAME_SUNKEN|FRAME_THICK)
    textfeld.disable



    
    # Platz für die Strategien
    strat_platz = FXHorizontalFrame.new(self,
        LAYOUT_SIDE_TOP|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH,
        :padLeft => 20, :padRight => 20, :padTop => 10, :padBottom => 10)

    #Grosse Matrix für 4 Spieler
    bigmatrix = FXMatrix.new(strat_platz, 2, MATRIX_BY_COLUMNS|LAYOUT_FILL_X)

    @boxes = []
    
    4.times{|strat|
          @boxes[strat] = FXGroupBox.new(bigmatrix, "Stragegie #{strat+1}",
                                GROUPBOX_TITLE_CENTER|FRAME_RIDGE)
          strategien.each_index{|i|
            stratname = strategien[i].to_s
                 FXRadioButton.new(@boxes[strat], stratname, @auswahl[strat], FXDataTarget::ID_OPTION+i) 
          }
          if strat>=@anzahl.value
            @boxes[strat].disable
          end
    }
    enable_disable_boxes

    @anzahl.connect(SEL_COMMAND) {
      enable_disable_boxes
    }
    
     # Platz für Knöpfe unten
    knopf_platz = FXHorizontalFrame.new(self,
        LAYOUT_SIDE_BOTTOM|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH,
        :padLeft => 20, :padRight => 20, :padTop => 10, :padBottom => 10)

    # Abbrechen
    FXButton.new(knopf_platz, "&Abbrechen", nil, self, ID_CANCEL,
      FRAME_RAISED|FRAME_THICK|LAYOUT_LEFT|LAYOUT_CENTER_Y)

    # OK
    ok_knopf = FXButton.new(knopf_platz, "&OK", nil, self, ID_ACCEPT,
      FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)

    ok_knopf.setDefault
    ok_knopf.setFocus
     
  end
  
  def enable_disable_boxes
     4.times {|i|
        if (i<@anzahl.value)
          @boxes[i].enable
          @boxes[i].each_child {|c|
            c.enable
          }
        else
          @boxes[i].disable
          @boxes[i].each_child {|c|
            c.disable
          }
        end
      }
  end
  
  # Holt die Standard-Werte aus einer Datei oder
  # setzt die Standard-Werte
  def hole_werte
    if File.exists?("standard-werte.rb")
      f = File.open("standard-werte.rb","r")
      text = ""
      while (line = f.gets)
        text += line
      end
      eval(text)
      f.close
    else
      @anzahl = FXDataTarget.new(2)
      @auswahl = Array.new(4) {FXDataTarget.new(0) }
      @speed = FXDataTarget.new(50)
#    puts @auswahl.inspect
      
#      @apfel = FXDataTarget.new(20)
#      @spielschritte = FXDataTarget.new(3000)
    end
  end
  
  # Schreibt die Werte
  def schreibe_werte
    f = File.open("standard-werte.rb","w")
    puts @auswahl.inspect
    f.puts "@anzahl = FXDataTarget.new(#{@anzahl.value})"
    f.puts "@auswahl = [#{@auswahl.collect{|t| 'FXDataTarget.new('+t.value.to_s+')'}.join(',')}]"
    f.puts "@speed = FXDataTarget.new(#{@speed.value})"
#  f.puts "@apfel = FXDataTarget.new(#{@apfel.value})"
#  f.puts "@spielschritte = FXDataTarget.new(#{@spielschritte.value})"
    f.close
  end
end
