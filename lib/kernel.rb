#bringt die Schlangen zum Schweigen
#
module Kernel
	alias_method :pdebug, :puts
	alias_method :printdebug, :print
	
	def silence
		def puts(*c)
		end
		def print(*c)
		end
	end
end

