$:.unshift File.dirname($0)
require 'ants.rb'

class Route
  
  @@startLoc
  @@endLoc
  @@distance
  
  def setRoute(startLoc, endLoc)
    @@startLoc = startLoc
    @@endLoc   = endLoc
   #@@distance = distance
  end
  
  def getStartLoc
    return @@startLoc
  end
  
  def getEndLoc
    return @@endLoc
  end
  
  def getDistance
    rowDiff = (@@startLoc["row"] - @@endLoc["row"]).abs
    colDiff = (@@startLoc["col"] - @@endLoc["col"]).abs
    #puts colDiff
    return rowDiff + colDiff
  end
  
  def getDirection(curLoc, endLoc)
    if(curLoc["col"] == endLoc["col"])
      ewMove = "H" #Hold
    else
      if(curLoc["col"] > endLoc["col"])
        ewMove = "W"
      else
        ewMove = "E"
      end   
    end
    
    if (curLoc["row"] == endLoc["row"])
      nsMove = "H" #Hold
    else
      if(curLoc["row"] > endLoc["row"])
        nsMove = "N"
      else
        nsMove = "S"
      end
    end
    return {"ewMove"=>ewMove,"nsMove"=> nsMove}
  end
  
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