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
 @@logger.debug = true
 @@orders       = Hash.new
 @@oldOrders    = Hash.new
   
  def clearOrders
    @@oldOrders.clear
    @@oldOrders = @@orders.dup
    @@orders.clear
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
    @@logger.log("Start r/c: " + @startLoc.row.to_s + "/" + @startLoc.col.to_s + " End r/c : "  + @endLoc.row.to_s + "/" + @endLoc.col.to_s)
    if(@startLoc.col < @endLoc.col)
      if(@endLoc.col - @startLoc.col >= @maxCols / 2)
        @@logger.log("1")
        move = checkMove("W")
        return move
      else
        @@logger.log("2")
        move = checkMove("E")
        return move
      end  
    end
    
    if(@startLoc.col > @endLoc.col)
      if(@startLoc.col - @endLoc.col >= @maxCols / 2)
        @@logger.log("3")
        move = checkMove("E")
        return move
      else
        @@logger.log("4")
        move = checkMove("W")
        return move
      end
    end
    
    if(@startLoc.row < @endLoc.row)
      if(@endLoc.row - @startLoc.row >= @maxRows / 2)
        @@logger.log("5")
        move = checkMove("N")
        return move
      else
        @@logger.log("6")
        move = checkMove("S")
        return move
      end
    end
    
    if(@startLoc.row > @endLoc.row)
      if(@startLoc.row - @endLoc.row >= @maxRows / 2)
        @@logger.log("7")
        move = checkMove("S")
        return move
      else
        @@logger.log("8")
        move = checkMove("N")
        return move
      end
    end
    
    if (@startLoc.row == @endLoc.row && @startLoc.col == @endLoc.col) 
      move = "H" #checkMove("W") #for some reason we are already there... 
      @@logger.log("Apparently we are there")
      return move
    end
    
    #@@logger.log("ANT :" + @ant.to_s + "Cur Loc (r/c): " + @ant.square.row.to_s + "/" + @ant.square.col.to_s + " move: " + move)
    if (move == "H")
      @@orders[@ant.square] = move
    else
       @@logger.log("Move: " + move)
      @@orders[@ant.square.neighbor(move)] = move
    end
    return move
  end
  
  #See if we can move in the requested direction. 
  def checkMove(move)
    case move
      when "E", "W"
        newPos = @ant.square.neighbor(move)
        #@@logger.log("NewPos : " + newPos.row.to_s)
        if (checkNewPos(newPos))
          @@logger.log("Returning 1: " + move)
          @@orders[@ant.square.neighbor(move)] = move
          return move
        else
          if (@@oldOrders.has_key?(@ant.square)) #In case we are already moving around an obstacle, keep going in same direction
            move = @@oldOrders.fetch(@ant.square)
            if (checkMove(move))
              @@logger.log("Returning 1a: " + move)
              @@orders[@ant.square.neighbor(move)] = move
              return move
            else
              move = "S"
              @@logger.log("Returning 1b: " + move)
              @@orders[@ant.square.neighbor(move)] = move
              return move
            end
          else
            if (@endLoc.row >= @startLoc.row)
              move = "S"
            else
              move = "N"
            end
          end
          
          newPos = @ant.square.neighbor(move)
          if (checkNewPos(newPos))
              @@logger.log("Returning 2: " + move)
              @@orders[@ant.square.neighbor(move)] = move
            return move
          end
          @@logger.log("Cannot move E/W- Hold")
          return "H" #Review!
        end 
      
      when "N", "S"
        newPos = @ant.square.neighbor(move)
        #@@logger.log("NewPos : " + newPos.row.to_s)
        if (checkNewPos(newPos))
            @@logger.log("Returning 3: " + move)
            @@orders[@ant.square.neighbor(move)] = move
          return move
        else
         if (@@oldOrders.has_key?(@ant.square)) #In case we are already moving around an obstacle, keep going in same direction
           move = @@oldOrders.fetch(@ant.square)
           @@logger.log("Returning 1a: " + move)
           @@orders[@ant.square.neighbor(move)] = move
           return move
         else 
          if (@endLoc.col >= @startLoc.col)
            move = "E"
          else
            move = "W"
          end
          newPos = @ant.square.neighbor(move)
          if (checkNewPos(newPos))
            @@logger.log("Returning 4: " + move)
            @@orders[@ant.square.neighbor(move)] = move
            return move
          end
          @@logger.log("Cannot move N/S - Hold")
          return "H" #Review!
         end 
      end
    end #End case    
  end 
  
  def checkNewPos(newPos)
    @@logger.log("CheckNewPos r/c: " + newPos.row.to_s + "/" + newPos.col.to_s)
    if (newPos.land? && !newPos.ant? && !@@orders.has_key?(newPos))
      return true
    else
      return false
    end
  end
    
=begin  
    i = 1
    while i < 4
     if (move == "H" || (@ant.square.neighbor(move).land? && !@ant.square.neighbor(move).ant? && !@@orders.has_key?(@ant.square.neighbor(move))))
       return move
     else
      move = cycleDir(move)
     end
     #make sure we are not going back-and-forth
     if (@@oldOrders)
       keyArray = @@oldOrders.find{|key,value| value == @ant}
       
       @@oldOrders.each do |key1, value1|
         @@logger.log("OldOrders: " + key1.to_s + " / " + value1.to_s)
       end
       
       if(keyArray)
         key = keyArray[0][0]
         @@logger.log("Got Ant")
       else
        key = ""
       end
       if (key == @ant.square.neighbor(move))
         @@logger.log("From: " + move)
         move = cycleDir(move)
         @@logger.log("To: " + move)
       end 
      end
     i += 1
    end
=end
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