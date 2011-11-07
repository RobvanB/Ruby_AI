$:.unshift File.dirname($0)
require 'ants.rb'
require 'logger.rb'

class Route
  
  @@startLoc
  @@endLoc
  @@distance
  @@logger = Logger.new
  @@orders = Hash.new
  
  def setRoute(theAnt, endLoc)
    @@ant      = theAnt
    @@startLoc = @@ant.square
    @@endLoc   = endLoc
   #@@distance = distance
  end
  
  def getStartLoc
    return @@startLoc
  end
  
  def getEndLoc
    return @@endLoc
  end
  
  def clearOrders
    @@orders.clear
  end
  
  def getDistance
  #  $stderr.puts "ROUTE"  + @@startLoc.row.to_s
   rowDiff = (@@startLoc.row - @@endLoc.row).abs
   colDiff = (@@startLoc.col - @@endLoc.col).abs
    #puts colDiff
    return rowDiff + colDiff
  end
  
  def getDirection()
    #Make sure we are going somewhere
    if(@@startLoc.col == @@endLoc.col)
      ewMove = "H" #Hold
    else
      if(@@startLoc.col > @@endLoc.col)
        ewMove = checkMove("W")
      else
        ewMove = checkMove("E")
      end   
    end
    
    if (@@startLoc.row == @@endLoc.row)
      nsMove = "H" #Hold
    else
      if(@@startLoc.row > @@endLoc.row)
        nsMove = checkMove("N")
      else
        nsMove = checkMove("S")
      end
    end
    @@logger.log("ANT :" + @@ant.to_s + "Cur Loc (r/c): " + @@ant.square.row.to_s + "/" + @@ant.square.col.to_s + " ew: " + ewMove + " ns: " + nsMove )
    #Remove 'old' location from orders to make sure it is free
    if (@@orders.has_key?(@@ant.square))
      @@orders.delete(@@ant.square)
      @@logger.log("DELETED")
    end
    return {"ewMove"=>ewMove,"nsMove"=> nsMove}
  end
  
  #See if we can move in the requested direction. If not, cycle through all directions 
  def checkMove(move)
    i = 1
    #@@logger.log("ANT :" + @@ant.to_s + " counter: " + i.to_s + " start move: " + move)
    while i < 4
      #@@logger.log("ANT :" + @@ant.to_s + " counter: " + i.to_s + " proposed move: " + move)
       if (@@orders.has_key?(@@ant.square.neighbor(move)))
         @@logger.log("ANT :" + @@ant.to_s + " counter: " + i.to_s + " cannot move: " + move)
       end 
       
       if (@@ant.square.neighbor(move).land? && !@@orders.has_key?(@@ant.square.neighbor(move)))
         @@orders[@@ant.square.neighbor(move)] = @@ant
         return move
      else
       #@@logger.log("Orders : " + @@orders.to_s)
        move = cycleDir(move)
      end
      i += 1
    end
    @@logger.log("CANNOT MOVE ANT :" + @@ant.to_s + " counter: " + i.to_s + " last move: " + move)
    return "H"
  end  
  
  def cycleDir(dir)
    case dir
      when "N"
        return "E"
      when "E"
        return "S"
      when "S"
        return "W"
      when "W"
        return "N"
      else
        return "UNKNOWN"
    end
  end
#Code below currently not used 
  def compareTo(route)
    return @@distance - route.distance
  end
  
  def hashCode
    #return @@startLoc.hash * 
  end
  
  def equals curRoute
    result = false
    if (curRoute.instance_of? Route)
      if (curRoute.getStartLoc == @@startLoc && curRoute.getEndLoc == @@endLoc)  
        result = true
      end
      return result
    end
  end
end