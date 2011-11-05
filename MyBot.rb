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
   
=begin 
  #Get a list of all the food
  @mapRows = ai.settings[:rows]
  @mapCols = ai.settings[:cols]
  
  #$stderr.puts mapRows
  #$stderr.puts mapCols
    
  def scanCols(row)
    cc = 0
    while cc <= @mapCols
     # $stderr.puts "loop2"
      if (ai.map[row][cc].food?)
        $stderr.puts "TRUE" #ai.map[row][cc].food   
      end
      cc += 1
    end
  end  
  
  rc = 0
  while rc <= @mapRows do
   # $stderr.puts "loop 1"
    scanCols(rc)
    rc += 1
  end
=end
  
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
  ai.my_ants.each do |ant|
    @map = ai.map
    @map.each do |row|
      row.each do |square|
        if (square.food? == true)
          
        end
        #$stderr.puts square.food?
        #square.ant=nil
        #square.hill=false
      end
    end  

    
    
    
    # try to go north, if possible; otherwise try east, south, west.
    [:N, :E, :S, :W].each do |dir|
      if doMove(ant, dir)
       break
      end
    end
  end

	#get a list of the food



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