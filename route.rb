$:.unshift File.dirname($0)
require 'ants.rb'

class Route
  
  @@startLoc
  @@endLoc
  @@distance
  
  def Route(startLoc, endLoc, distance)
    @@startLoc = startLoc
    @@endLoc   = endLoc
    @@distance = distance
  end
  
  def getStartLoc
    return @@startLoc
  end
  
  def getEndLoc
    return @@endLoc
  end
  
  def getDistance
    return @@distance
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