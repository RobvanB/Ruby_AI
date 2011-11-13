$:.unshift File.dirname($0)
require 'ants.rb'
require 'route.rb'
require 'logger.rb'

ai            = AI.new
@route        = Route.new
@logger       = Logger.new
@logger.debug = true
@@enemyHills  = Hash.new

class Location
  attr_accessor :row
  attr_accessor :col
end

ai.setup do |ai|
	#Setup code here
  @maxRows = ai.rows
  @maxCols = ai.cols
  @radius  = ai.viewradius
  @notSeen = Hash.new
  location = Location.new   
  
  rows = 0
  while (rows < @maxRows)
    cols = 0
    while (cols < @maxCols)
      location.row = rows
      location.col = cols
      @notSeen[location] = "Dummy"
      cols += 1
    end 
    rows += 1
  end
end

ai.run do |ai|
  #Prevent collisions
  @targets = Hash.new
	def doMoveLoc(curAnt, dest)  #Move to specific location
	 #@targets[curAnt] = dest
	  @targets[dest] = curAnt
	  @route.setRoute(curAnt, dest, @maxRows, @maxCols)
	    direction = @route.getDirection()
	    #@logger.log("ORDER : "+ direction)
	    curAnt.order(direction)    
	  return true
	end
	
	def removeSeen(curLoc)
	 rc = 0
	 curRow = curLoc.square.row
	 curCol = curLoc.square.col
	 while(rc < @radius)
	   cc = 0
	   while(cc < @radius)
	     delRow = curRow + rc
	     delCol = curCol + cc
	     @notSeen.delete([delRow, delCol])
	     delRow = curRow - rc
       delCol = curCol - cc
       @notSeen.delete([delRow, delCol])
	     cc += 1 
	   end
	   rc += 1
	  end
	end
#End class methods
	
	#@logger.log("Turn: " + ai.turn_number.to_s)
	
	#Default move
  @foodMap = Hash.new
  ai.my_ants.each do |ant|  
    #Remove all 'visible' locations from our 'unseen' map
    removeSeen(ant)
     
    #Get a list of the available food
    @map = ai.map
    @map.each do |row|
      row.each do |square|
        if(square.hill? != false && square.hill? != 0)
         # @logger.log("Enemy hill : " + square.hill.to_s + " : " + square.row.to_s + "/" + square.col.to_s)
          @@enemyHills[square] = ant
        else
          if(square.food? == true && !@targets.has_key?(square))
            #@logger.log("Food at: " + square.row.to_s + "/" + square.col.to_s)
            @route.setRoute(ant, square, ai.rows, ai.cols)
            @foodMap[square] = @route.getDistance    
          end
        end
      end
    end  
 
    #Get them hills
    #For now, send all ants, gotta change this later to be a bit more balanced
    if(@@enemyHills.length > 0)
      @@enemyHills.each_key do |hill|
        @route.setRoute(ant, hill, ai.rows, ai.cols)
        @@enemyHills[hill] = @route.getDistance
      end
      
      hillArray = Hash.new
      hillArray = @@enemyHills.sort_by{|hill, distanceSorted| distanceSorted}
      goLoc = hillArray[0][0]
    else
      if (@foodMap.length > 0)
        foodArray = Hash.new
        foodArray = @foodMap.sort_by{|foodSquare, distanceSorted | distanceSorted}
        #the closest foodsquare is the first entry in the array, so let's send our ant there
        goLoc = foodArray[0][0]
       else
        #No food. Go explore - get the closest non-seen square
        unseenDist  = Hash.new
        @notSeen.each_key do |unseenLoc|
          @route.setRoute(ant, unseenLoc, ai.rows, ai.cols)
          unseenDist[unseenLoc] = @route.getDistance
        end
        unseenArray = unseenDist.sort_by{|location, distanceSorted| distanceSorted}
        goLoc = unseenArray[0][0]
        #@logger.log("Unseen Go Loc: " + goLoc.to_s)  
      end  
    end
    #@logger.log("Turn: " + ai.turn_number.to_s + " MyBot says: Go from - to (r/c): " + ant.square.row.to_s + "/" + ant.square.col.to_s + " - " + goLoc.row.to_s + "/" + goLoc.col.to_s )
    doMoveLoc(ant, goLoc)
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