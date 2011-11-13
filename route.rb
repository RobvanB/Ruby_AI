
#$:.unshift File.dirname('/var/lib/gems/1.8/gems/ruby-debug-0.10.4/cli/ruby-debug.rb')
#$:.unshift File.dirname('/var/lib/gems/1.8/gems/ruby-debug-base-0.10.4/lib/ruby-debug-base.rb')
#require 'ruby-debug.rb'

$:.unshift File.dirname($0)
require 'ants.rb'
require 'logger.rb'

class Route
  
  @startLoc     = nil
  @endLoc       = nil
  @distance     = nil
 @@logger       = Logger.new
 @@logger.debug = false
 @@orders       = Hash.new
  
  def setRoute(theAnt, endLoc, maxRows, maxCols)
    @ant      = theAnt
    @startLoc = @ant.square
    @endLoc   = endLoc
    @maxRows  = maxRows
    @maxCols  = maxCols
   @@orders[@ant] = endLoc    
   #@@distance = distance
  end
   
  def getDistance
  #  $stderr.puts "ROUTE"  + @@startLoc.row.to_s
   rowDiff = [@startLoc.row , @endLoc.row].max - [@startLoc.row , @endLoc.row].min 
   colDiff = [@startLoc.col , @endLoc.col].max - [@startLoc.col , @endLoc.col].min  
   #puts colDiff
  #@@logger.log("Distance: " + rowDiff.to_s + ' + ' + colDiff.to_s)
   return rowDiff + colDiff
  end
  
  def getDirection()
   #@@logger.log(@@orders.length.to_s)
   #@@logger.log("CURRENT r/c: " + @@startLoc.row.to_s + "/" + @@startLoc.col.to_s)
   #@@logger.log("DIRECTIONS r/c: " + @@endLoc.row.to_s + "/" + @@endLoc.col.to_s)
    #Make sure we are going somewhere
    
    if(@startLoc.col < @endLoc.col)
      if(@endLoc.col - @startLoc.col >= @maxCols / 2)
        move = checkMove("W")
      else
        move = checkMove("E")
      end  
    end
    
    if(@startLoc.col > @endLoc.col)
      if(@startLoc.col - @endLoc.col >= @maxCols / 2)
        move = checkMove "E"
      else
        move = checkMove "W"
      end
    end
    
    if(@startLoc.row < @endLoc.row)
      if(@endLoc.row - @startLoc.row >= @maxRows / 2)
        move = checkMove("N")
      else
        move = checkMove("S")
      end
    end
    
    if(@startLoc.row > @endLoc.row)
      if(@startLoc.row - @endLoc.row >= @maxRows / 2)
        move = checkMove("S")
      else
        move = checkMove("N")
      end
    end
    
    if (@startLoc.row == @endLoc.row && @startLoc.col == @endLoc.col) 
      move = checkMove("W") #for some reason we are already there... just go West
    end
    
    @@logger.log("ANT :" + @ant.to_s + "Cur Loc (r/c): " + @ant.square.row.to_s + "/" + @ant.square.col.to_s + " move: " + move)
    return move
  end
  
  #See if we can move in the requested direction. If not, cycle through all directions 
  def checkMove(move)
    i = 1
    #@@logger.log("ANT :" + @@ant.to_s + " counter: " + i.to_s + " start move: " + move)
    while i < 4
      #@@logger.log("ANT :" + @@ant.to_s + " counter: " + i.to_s + " proposed move: " + move)
       #if (@@orders.has_key?(@@ant.square.neighbor(move)))
        # @@logger.log("ANT :" + @@ant.to_s + " counter: " + i.to_s + " cannot move: " + move)
       #end 
       
       if (@ant.square.neighbor(move).land? && !@ant.square.neighbor(move).ant? && !@@orders.has_key?(@ant.square.neighbor(move)))
         @@orders[@ant.square.neighbor(move)] = @ant
         return move
       else
        #@@logger.log("Orders : " + @@orders.to_s)
        move = cycleDir(move)
       end
       i += 1
    end
    #Cannot move ant, so now let's try moving it to previous locations
    i = 1
    while i < 4
      #@@logger.log("ANT :" + @@ant.to_s + " counter: " + i.to_s + " proposed move: " + move)
       #if (@@orders.has_key?(@@ant.square.neighbor(move)))
        # @@logger.log("ANT :" + @@ant.to_s + " counter: " + i.to_s + " cannot move: " + move)
       #end 
       
       if (@ant.square.neighbor(move).land? && !@ant.square.neighbor(move).ant?)
         @@orders[@ant.square.neighbor(move)] = @ant
         return move
      else
       #@@logger.log("Orders : " + @@orders.to_s)
        move = cycleDir(move)
      end
      i += 1
    end
    #@@logger.log("CANNOT MOVE ANT :" + @@ant.to_s + " counter: " + i.to_s + " last move: " + move)
    return "W"
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
    return @distance - route.distance
  end
  
  def hashCode
    #return @@startLoc.hash * 
  end
  
  def equals curRoute
    result = false
    if (curRoute.instance_of? Route)
      if (curRoute.getStartLoc == @startLoc && curRoute.getEndLoc == @endLoc)  
        result = true
      end
      return result
    end
  end
end