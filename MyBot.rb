$:.unshift File.dirname($0)
require 'ants.rb'
require 'route.rb'
require 'logger.rb'

class TargetList
  attr_accessor :target
  attr_accessor :ant
  attr_accessor :distance
  attr_accessor :type
end

class AntLocation
  attr_accessor :row
  attr_accessor :col
end

####################################
ai               = AI.new
@route           = Route.new
@logger          = Logger.new
@logger.debug    = false
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
 #@logger.log("======Begin Turn: " + ai.turn_number.to_s + " Ant: " + ant.square.row.to_s + "/" + ant.square.col.to_s)

ai.run do |ai|
  @logger.log("Turn: " + ai.turn_number.to_s)
  hillTargets = []
  foodTargets = []
  targetHash  = Hash.new  #Hash of TargetList classes and distance
  @route.clearOrders
  @targets = Hash.new
	
  ai.my_ants.each do |ant|  
    #Remove all 'visible' locations from our 'unseen' map
    removeSeen(ant)
    #Collect all data on food and hills  
    @map = ai.map
    @map.each do |row|
      row.each do |square|
        
        if(square.hill? != false && square.hill? != 0) #Enemy Hill
         if (!hillTargets.include?(square))
           hillTargets.push(square)
         end  
        end
        
        if(square.food? == true)
          if (!foodTargets.include?(square))
            foodTargets.push(square)     
          end
        end

      end #End Map-Square loop
    end #End Map-Row loop  
  end #End Ant loop  

  #Loop through the ants again and collect the distance to the food/hill for each ant/food combination
  targetList = TargetList.new
  i = 0
  route = Route.new
  
  #collect food/hill distances
  ai.my_ants.each do |theAnt|
    foodTargets.each do |foodLoc|
      @route.setRoute(theAnt, foodLoc, @maxRows, @maxCols)
      targetList.type     = "food"
      targetList.ant      = theAnt
      targetList.target   = foodLoc
      targetList.distance = @route.getDistance
      targetHash[targetList.dup] = targetList.distance
     # @logger.log("Added to foodHash: " + foodList.food.row.to_s + "/" + foodList.food.col.to_s + "-" + foodList.distance.to_s)
    end       
    hillTargets.each do |hillLoc|
      @route.setRoute(theAnt, hillLoc, @maxRows, @maxCols)
      targetList.type     = "hill"
      targetList.ant      = theAnt
      targetList.target   = hillLoc
      targetList.distance = @route.getDistance
      targetHash[targetList.dup] = targetList.distance
     # @logger.log("Added to foodHash: " + foodList.food.row.to_s + "/" + foodList.food.col.to_s + "-" + foodList.distance.to_s)
    end         
  end
  
  #Sort the targets by distance
  targetsSorted = targetHash.sort_by{|theClass, distanceSorted | distanceSorted}
  
  targetsSorted.each do |tmpTarget, tmpDist|
    @logger.log("Target List: " + tmpTarget.target.row.to_s + "/" + tmpTarget.target.col.to_s + " Dist: " +  tmpDist.to_s)
  end
    
  #Now we loop through the ants *again* and send each ant to the closest foodSquare
  antCount   = 1
  ai.my_ants.each do |theAnt|  
    i = 0
    antMoved = false
    while (i < targetsSorted.length && !antMoved)
      firstTarget = targetsSorted[i][0]
      if (firstTarget.ant == theAnt && !@targets.has_key?(firstTarget.target))
        @logger.log("Ant : "+ firstTarget.ant.square.row.to_s + "/" + firstTarget.ant.square.col.to_s  + " Sent to: " +firstTarget.target.row.to_s + "/" + firstTarget.target.col.to_s )
        @route.setRoute(theAnt, firstTarget.target, @maxRows, @maxCols)
        direction = @route.getDirection
        if (direction == "H") # H = Cannot move
          tmpTarget = firstTarget.dup
          tmpTarget.target.row = theAnt.square.row
          tmpTarget.target.col = theAnt.square.col
          @targets[tmpTarget.target] = theAnt #Prevent sending ants to the same location
        else
          theAnt.order(direction)
          @targets[firstTarget.target] = theAnt #Prevent sending ants to the same location
          #@targets[theAnt.square] = theAnt #Prevent sending ants to the same location
        end
        antMoved = true
      end
      i += 1
    end
    
    #No food, no Hill, Go explore
    if (!antMoved)
      unseenDist  = Hash.new
      @notSeen.each_key do |unseenLoc|
        @route.setRoute(theAnt, unseenLoc, @maxRows, @maxCols)
        unseenDist[unseenLoc] = @route.getDistance
      end
      unseenArray = unseenDist.sort_by{|location, distanceSorted| distanceSorted}
      exploreLoc  = unseenArray[0][0]
      @route.setRoute(theAnt, exploreLoc, @maxRows, @maxCols)
      direction = @route.getDirection
      if (direction == "H") # H = Cannot move
        @targets[theAnt.square] = theAnt #Prevent sending ants to the same location
      else
        theAnt.order(direction)
        @targets[exploreLoc] = theAnt #Prevent sending ants to the same location
      end
    end
    antCount += 1
  end
        
end #End Class
  