#=CommandLineInterface
#
#Wird vielleicht einmal alles übernehmen, die Turniere, 
#die Kommandozielenversion und die MCUF-Version
#
#Im Moment soll es aber nur das Turnier verwalten,
#der ganze Rest läuft über refactoring
#
#GetoptLong: http://ruby-doc.org/stdlib-1.8.7/

#Parser für die Kommandozeilenargumente einbinden
require "getoptlong"
#kann den Kommentar am Anfang des Files ausgeben
require "rdoc/usage"

opts = GetoptLong.new(
	[ "--help", "-h", GetoptLong::NO_ARGUMENT],
	[ "--include-dir", "-I", GetoptLong::REQUIRED_ARGUMENT],
	[ "--output-dir", "-o", GetoptLong::REQUIRED_ARGUMENT],
	[ "--verbose", "-v", GetoptLong::NO_ARGUMENT],
)

includeDir = "."
outputDir = "output"
verbose = false
quiet = false

opts.each { |opt, arg| 
	case opt
	when "--help"
		RDoc::usage
	when "--include-dir"
		includeDir = arg
	when "--output-dir"
		outputDir = arg
	when "--verbose"
		verbose =	true
	end
}

#Die Turniermethoden einbinden
require "tournier"
include Tournier

# bringt die Schlangen zum Schweigen
require "kernel"
include Kernel

unless verbose
	silence
end

berechneTurnier(includeDir, outputDir)
