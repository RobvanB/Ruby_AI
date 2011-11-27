
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
   
  def clearOrders
    @@orders = Hash.new
  end
  
  def setRoute(theAnt, endLoc, maxRows, maxCols)
    @ant      = theAnt
    @startLoc = @ant.square
    @endLoc   = endLoc
    @maxRows  = maxRows
    @maxCols  = maxCols
  end
   
  def getDistance
   rowDiff = [@startLoc.row , @endLoc.row].max - [@startLoc.row , @endLoc.row].min 
   colDiff = [@startLoc.col , @endLoc.col].max - [@startLoc.col , @endLoc.col].min  
   return rowDiff + colDiff
  end
  
  def getDirection()
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
        move = checkMove("E")
      else
        move = checkMove("W")
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
      move = "H" #checkMove("W") #for some reason we are already there... just go West
    end
    
    #@@logger.log("ANT :" + @ant.to_s + "Cur Loc (r/c): " + @ant.square.row.to_s + "/" + @ant.square.col.to_s + " move: " + move)
    if (move == "H")
      @@orders[@ant.square] = @ant
    else
      @@orders[@ant.square.neighbor(move)] = @ant
    end
    return move
  end
  
  #See if we can move in the requested direction. If not, cycle through all directions 
  def checkMove(move)
    i = 1
    while i < 4
     if (move == "H" || (@ant.square.neighbor(move).land? && !@ant.square.neighbor(move).ant? && !@@orders.has_key?(@ant.square.neighbor(move))))
       return move
     else
      move = cycleDir(move)
     end
     i += 1
    end

    #Cannot move ant, so now let's try moving it to previous locations (i.e. don't check for previous orders)
=begin    
    i = 1
    while i < 4
      if (@ant.square.neighbor(move).land? && !@ant.square.neighbor(move).ant?)
         return move
      else
         move = cycleDir(move)
      end
      i += 1
    end
=end
    #Cannot move 
    @@logger.log("Cannot move - Hold")
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
end