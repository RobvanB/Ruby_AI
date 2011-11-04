$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
end

ai.run do |ai|
	#Prevent collisions
  @orders = Hash.new            #Gets initialized 'per ant (curAnt) - need to figure out why - works fine though
	def doMove(curAnt, direction)
    newLoc = curAnt.square.neighbor(direction)
	  oldLoc = curAnt
	  if (curAnt.square.neighbor(direction).land? && !@orders.has_key?(newLoc) )
      curAnt.order(direction)
      @orders[newLoc] = oldLoc	
	    return true
	  else
	    return false
	  end
	end
	
	#Default move
	ai.my_ants.each do |ant|
		# try to go north, if possible; otherwise try east, south, west.
		[:N, :E, :S, :W].each do |dir|
			if doMove(ant, dir)
			 break
			end
		end
	end
end