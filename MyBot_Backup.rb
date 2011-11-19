$:.unshift File.dirname($0)
require 'ants.rb'
require 'route.rb'
require 'logger.rb'

class AntLocation
  attr_accessor :row
  attr_accessor :col
end

class HillHolder
  attr_accessor :hill
  attr_accessor :mainAnt
  attr_accessor :buddyDist
  
  def setHill(hill, mainAnt, buddyDist)
    @hill, @mainAnt, @buddyDist = hill, mainAnt, buddyDist
  end
end

ai               = AI.new
@route           = Route.new
@logger          = Logger.new
@logger.debug    = true
@hillHolder      = HillHolder.new
@hillHolderArray = Array.new
@goLoc           = AntLocation.new
#End declarations

#Begin setup code 
ai.setup do |ai|
  @maxRows = ai.rows
  @maxCols = ai.cols
  @radius  = ai.viewradius
  @notSeen = Hash.new
  antLoc   = AntLocation.new
  
  rows = 0
  while (rows < @maxRows)
    cols = 0
    while (cols < @maxCols)
      antLoc.row = rows
      antLoc.col = cols
      @notSeen[antLoc] = "Dummy"
      cols += 1
    end 
    rows += 1
  end
end
#End setup code

ai.run do |ai|
  @logger.log("RESET")
  @route.clearOrders
  @targets = Hash.new
  @foodMap = Hash.new
  
	def doMoveLoc(curAnt, dest)  #Move to specific location
	  @targets[dest] = curAnt
	  @foodMap.delete(dest)
	  #@logger.log("Added")
	  @route.setRoute(curAnt, dest, @maxRows, @maxCols)
	    #@logger.log("CurAnt: " + curAnt.square.row.to_s + "/" + curAnt.square.col.to_s + " TO: " + dest.row.to_s + "/" + dest.col.to_s)
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
  ai.my_ants.each do |ant|  
    @logger.log("======Begin Turn: " + ai.turn_number.to_s + " Ant: " + ant.square.row.to_s + "/" + ant.square.col.to_s)
    #Remove all 'visible' locations from our 'unseen' map
    removeSeen(ant)
     
    #Get a list of the available food and look for hills
    #@logger.log("NEW")
    #@targets.each do |theKey, theValue|
    #  @logger.log("Target key: " + theKey.row.to_s + "/" + theKey.col.to_s)
    #end
    
    @map = ai.map
    @map.each do |row|
      row.each do |square|
        if(square.hill? != false && square.hill? != 0) #Enemy Hill
          @logger.log("Enemy hill: "  + square.row.to_s + "/" + square.col.to_s)
          haveHill = false
          @hillHolderArray.each do |holder| #See if the hill we found is already known
            if (holder.hill == square)
              haveHill = true
              #if (holder.buddy == nil && holder.mainAnt != ant)
              #  holder.buddy = ant            #We're going to assist the Ant who first found the hill
              #end
            end
          end
          if(!haveHill)
            @hillHolder.setHill(square, ant, 999) #Set the hill properties
            @hillHolderArray.push(@hillHolder)    #Add the hill to our collection
            @logger.log("Hill added to array")
          end
        else
          if(square.food? == true && !@targets.has_key?(square))
            @logger.log("Food at: " + square.row.to_s + "/" + square.col.to_s)
            @route.setRoute(ant, square, ai.rows, ai.cols)
            @foodMap[square] = @route.getDistance    
          end
        end
      end
    end  
    holder = nil
   
    #Get them hills
    #If the current ant is at an Enemy hill AND has a buddy that is close; attack
    #if the ant *IS* the buddy, check distance and attack if we are close together
    attackOrMove = false
    if(@hillHolderArray && @hillHolderArray.length > 0)
      @hillHolderArray.each do |holder|

        if(holder.mainAnt == ant && holder.buddyDist > 4) #stay put if we are the mainAnt
          attackOrMove = true #A little confusing to set this one to true, but it's needed below
          @logger.log("Main Ant. Stay put")
          @goLoc = holder.mainAnt
        end
        
        if(holder.mainAnt == ant && holder.buddyDist <= 4) #stay put if we are the mainAnt
          attackOrMove = true #A little confusing to set this one to true, but it's needed below
          @logger.log("Main Ant. ATTACK")
          @goLoc = holder.mainAnt
        end
       
        #if((holder.mainAnt == ant && holder.buddy)|| holder.buddy == ant) # We only want attack hills if we have a mainAnt and a Buddy
        if (holder.mainAnt != ant) 
          #@logger.log("Hill Ant: " + holder.mainAnt.row.to_s + "/" + holder.mainAnt.col.to_s + " buddy: " + holder.buddyDist.to_s)
          attackOrMove = true
         #@route.setRoute(holder.mainAnt, holder.buddy.square, ai.rows, ai.cols)
          @route.setRoute(holder.mainAnt, ant.square, ai.rows, ai.cols)
          distance = @route.getDistance
          @logger.log("Distance " + distance.to_s)
          if(distance <= 4)
            #ATTACK!
            holder.buddyDist = distance
            @logger.log("Buddy ATTACK!")
            @goLoc = holder.hill  
          else
            #Move closer if we are a buddy
            @logger.log("Ant: " + ant.square.row.to_s + "/" + ant.square.col.to_s + " MainAnt: " + holder.mainAnt.square.row.to_s + " / " + holder.mainAnt.square.col.to_s)
            #if(holder.buddy == ant)
              antLoc = AntLocation.new
              antLoc.row = holder.mainAnt.square.row
              antLoc.col = holder.mainAnt.square.col + 1  # just keep him close
              @goLoc = antLoc
              @logger.log("Buddy Ant, move closer: " + @goLoc.row.to_s + "/" + @goLoc.col.to_s)
              holder.buddyDist = distance
              #@logger.log(attackOrMove.to_s)
            #end
          end
        end
      end
    end
    
    if(!attackOrMove)
      if (@foodMap.length > 0)
        foodArray = Hash.new
        foodArray = @foodMap.sort_by{|foodSquare, distanceSorted | distanceSorted}
        #the closest foodsquare is the first entry in the array, so let's send our ant there
        @goLoc = foodArray[0][0]
       else
        #No food, no attack. Go explore - get the closest non-seen square
        unseenDist  = Hash.new
        @notSeen.each_key do |unseenLoc|
          @route.setRoute(ant, unseenLoc, ai.rows, ai.cols)
          unseenDist[unseenLoc] = @route.getDistance
        end
        unseenArray = unseenDist.sort_by{|location, distanceSorted| distanceSorted}
        @goLoc = unseenArray[0][0]
        #@logger.log("Unseen Go Loc: " + goLoc.to_s)  
      end  
    end
    
    @logger.log("Turn: " + ai.turn_number.to_s + " MyBot says: Go from - to (r/c): " + ant.square.row.to_s + "/" + ant.square.col.to_s + " - " + @goLoc.row.to_s + "/" + @goLoc.col.to_s )
    if (ant != @goLoc)
      doMoveLoc(ant, @goLoc)
    end
  end
end