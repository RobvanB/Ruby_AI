$:.unshift File.dirname($0)
require 'ants.rb'
require 'route.rb'
require 'logger.rb'

ai      = AI.new
@route  = Route.new
@logger = Logger.new
@logger.debug = true

ai.setup do |ai|
	# your setup code here, if any
end

ai.run do |ai|
  #Prevent collisions
	@targets = Hash.new
	def doMoveLoc(curAnt, dest)  #Move to specific location
	  @targets[curAnt] = dest
	  @route.setRoute(curAnt, dest)
	    direction = @route.getDirection()
	    #@logger.log("ORDER : "+ direction)
	    curAnt.order(direction)    
	  return true
	end
#End class methods
	
	#Default move
  @foodMap = Hash.new
  ai.my_ants.each do |ant|  
    #@logger.log("Current Ant: " + ant.to_s)
    #@logger.log("Turn : " + ai.turn_number.to_s)
    #First get a list of the available food
    @map = ai.map
    @map.each do |row|
      row.each do |square|
        if (square.food? == true)
          @route.setRoute(ant, square)
          @foodMap[square] = @route.getDistance    
        end
      end
    end  
    #get the closest location of the food
    # if no food found, just go west
    if (@foodMap.length == 0)
      #@logger.log("CUR LOC: " + goLoc.row.to_s + "/" + goLoc.col.to_s)
      #@logger.log("ANT SQUARE : " + ant.square.col.to_s)
      #@logger.log("NEW LOC: " + goLoc.row.to_s + "/" + goLoc.col.to_s)
      #@logger.log("ANT SQUARE : " + ant.square.col.to_s)
      goLoc = ant.square.neighbor("W")
      @route.setRoute(ant, goLoc)     
    else 
      foodArray = Hash.new
      foodArray = @foodMap.sort_by{|foodSquare, distanceSorted | distanceSorted}
      #the closest foodsquare is the first entry in the array, so let's send our ant there
      goLoc = foodArray[0][0]
      #@logger.log("MyBot says: Go from - to (r/c): " + ant.square.row.to_s + "/" + ant.square.col.to_s + " - " + goLoc.row.to_s + "/" + goLoc.col.to_s )
    end 
    if doMoveLoc(ant, goLoc)
      break
    end
  end
end

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