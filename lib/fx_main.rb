# Interface für FX-Ruby
# 
# Man definiert ein Array von Klassen von Strategien (nicht Instanzen)
# Die Strategien werden dann für jedes Spiel automatisch neu initialisiert.
# 


require "fx_snake_window"

Dir.glob("strategie*.rb") {|stratfile|
  require stratfile
}

# Damit erhalten wir die Klassen aller Strategie-Objekte.
allestrategien = Module.constants.grep(/^Strategie./).sort.collect{|s| Kernel.const_get(s)}


# Neue Fox Anwendung
application = FXApp.new('Snake', 'Snake')
  
# Hauptfenster
snake = SnakeWindow.new(application,allestrategien)
  
# Create the application
application.create

# Run the application
application.run
