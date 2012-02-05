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

