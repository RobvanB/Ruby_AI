$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any

=begin	 
	 ai.map.each do |row|
      row.each do |square|
        square.food=false
        square.ant=nil
        square.hill=false
      end
    end
=end
end

ai.run do |ai|
  
  #Get a list of all the food
  mapRows = ai.settings[:rows]
  mapCols = ai.settings[:cols]
  
  #$stderr.puts mapRows
  
  rc = 1
  cc = 1
  while rc <= mapRows
    while cc <= mapCols
      $stderr.puts ai.map[rc][cc].food
       if (ai.map[rc][cc].food)
        $stderr.puts "*******************"
        $stderr.puts rc
        $stderr.puts "*******************"
       end
       cc += 1       
    end
    rc += 1
  end
  
  
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
	
	@targets
	def doMoveLoc(curAnt, dest)  #Move to specific location
	  @targets[curAnt] = dest
	  if (doMove(curAnt, dest))
	    return true
	  else
	    return false
	  end
	end
	
	#Default move
	
	puts ai.my_ants.foods
	  
	
	
	
	
=begin
	#Default move (old)
	ai.my_ants.each do |ant|
		# try to go north, if possible; otherwise try east, south, west.
		[:N, :E, :S, :W].each do |dir|
			if doMove(ant, dir)
			 break
			end
		end
	end
=end

end