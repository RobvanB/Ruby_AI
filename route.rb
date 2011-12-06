#$:.unshift File.dirname('/var/lib/gems/1.8/gems/ruby-debug-0.10.4/cli/ruby-debug.rb')
#$:.unshift File.dirname('/var/lib/gems/1.8/gems/ruby-debug-base-0.10.4/lib/ruby-debug-base.rb')
#require 'ruby-debug.rb'

$:.unshift File.dirname($0)
require 'ants.rb'
require 'logger.rb'

class MapSquare
  attr_accessor :row
  attr_accessor :col
end


class Route
  
  @startLoc     = nil
  @endLoc       = nil
  @distance     = nil
  @@routeHash    = Hash.new
 @@logger       = Logger.new
 @@logger.debug = true
 @@orders       = Hash.new
 @@oldOrders    = Hash.new
   
  def clearOrders
    @@oldOrders.clear
    @@oldOrders = @@orders.dup
    @@orders.clear
  end
  
  def setRoute(theAnt, endLoc, maxRows, maxCols, map)
    @ant      = theAnt
    @startLoc = @ant.square
    @endLoc   = endLoc
    @maxRows  = maxRows
    @maxCols  = maxCols
    @map      = map
  end
   
  def getDistance
   rowDiff = [@startLoc.row , @endLoc.row].max - [@startLoc.row , @endLoc.row].min 
   colDiff = [@startLoc.col , @endLoc.col].max - [@startLoc.col , @endLoc.col].min  
   return rowDiff + colDiff
  end
  
  def getDirection()
    i          = 1
    foundStart = false
    curSquare  = MapSquare.new
    testSquare = MapSquare.new
    curSquare.row = @endLoc.row 
    curSquare.col = @endLoc.col
   @@routeHash.clear
    
    while (!foundStart) # Set the counter (i) for the 4 squares 'around' the target square
    @@logger.log("Route while: Testing around CurSquare r/c: " + curSquare.row.to_s + "/" + curSquare.col.to_s)
      testSquare.row = curSquare.row - 1
      testSquare.col = curSquare.col 
      if (checkNewLoc(testSquare) && curSquare.row > 0 && !haveSquare(testSquare)) #Land and Ant? / valid row-col? / already in hash?
        @@routeHash[testSquare.dup] = i
      end
      foundStart = checkStartLoc(testSquare)     
      
      testSquare.row = curSquare.row + 1
      testSquare.col = curSquare.col 
      if (checkNewLoc(testSquare) && curSquare.row <= @maxRows && !haveSquare(testSquare))
        @@routeHash[testSquare.dup] = i
      end
      foundStart = foundStart || checkStartLoc(testSquare)      
      
      testSquare.row = curSquare.row 
      testSquare.col = curSquare.col - 1
      if (checkNewLoc(testSquare) && curSquare.col > 0 && !haveSquare(testSquare))
        @@routeHash[testSquare.dup] = i
      end
      foundStart = foundStart || checkStartLoc(testSquare)
      
      testSquare.row = curSquare.row 
      testSquare.col = curSquare.col + 1
      if (checkNewLoc(testSquare) && curSquare.col <= @maxCols && !haveSquare(testSquare))
        @@routeHash[testSquare.dup] = i
      end
      foundStart = foundStart || checkStartLoc(testSquare)
      
      #move to the next square -> needs to be closer to the starting point!
      if(@startLoc.row < curSquare.row)
        if(curSquare.row - @startLoc.row >= @maxRows / 2)
          curSquare.row += 1
        else
          curSquare.row -= 1
        end
      end
    
      if(@startLoc.row > curSquare.row)
        if(@startLoc.row - curSquare.row >= @maxRows / 2)
          curSquare.row -= 1
        else
          curSquare.row += 1
        end
      end
      
      if (@startLoc.col == curSquare.col)
         if(@startLoc.col < curSquare.col)
        if(curSquare.col - @startLoc.col >= @maxRows / 2)
          curSquare.col += 1
        else
          curSquare.col -= 1
        end
      end
    
      if(@startLoc.col > curSquare.col)
        if(@startLoc.col - curSquare.col >= @maxRows / 2)
          curSquare.col -= 1
        else
          curSquare.col += 1
        end
      end
      end
      
      if (curSquare.row > @maxRows)
        curSquare.row = 1
      end
      if (curSquare.col > @maxCols)
        curSquare.col = 1
      end
      i += 1
    end  # End While Loop
    
    #Now get first square in our route
    #hash.max_by{|k,v| v
    @@routeHash.each do |k, v|
      @@logger.log(k.row.to_s + "/" + k.col.to_s + " count: " + v.to_s)
    end
    gotoSquare = @@routeHash.max_by{|k,v|v}[0]
    counter =  @@routeHash.max_by{|k,v|v}[1]
    @@logger.log("Counter of selected record: " + counter.to_s)
    @@logger.log("GotoSquare of selected record: " + gotoSquare.row.to_s + "/"+ gotoSquare.col.to_s)
    returnMove = getMove(gotoSquare) 
    @@logger.log("Returning from getMove: " + returnMove)
    return returnMove
  end #End getDirection()
   
  def checkNewLoc(newLocSquare) #make sure it's land and no ant
    #checkLoc = @startLoc.dup #misuse the startloc so we have an instance of a square
    #checkLoc.row = newLocSquare.row
    #checkLoc.col = newLocSquare.col
    @@logger.log("R/C " + newLocSquare.row.to_s + "/" + newLocSquare.col.to_s)
    
    checkLoc = @map[newLocSquare.row][newLocSquare.col]
    
    @@logger.log(checkLoc.to_s)
    
    if (checkLoc.land? && !checkLoc.ant?) # && !@@orders.has_key?(newPos))
      @@logger.log("Checkloc yes")
      return true
    else
      @@logger.log("Checkloc no")
      return false
    end
  end #End checkNewLoc 
    
  def checkStartLoc(mapSquare)
    if (mapSquare.row == @startLoc.row && mapSquare.col = @startLoc.col)
      @@logger.log("CheckStartLoc: Found StartLoc")
      return true
    else
      return false
    end
  end #End checkStartLoc

  def getMove(theSquare)   
    @@logger.log("getMove Start: " + @startLoc.row.to_s + "/" + @startLoc.col.to_s)
    @@logger.log("getMove theSquare: " +  theSquare.row.to_s + "/" + theSquare.col.to_s)
    if(@startLoc.col < theSquare.col)
     if(theSquare.col - @startLoc.col >= @maxCols / 2)
       @@logger.log("getMove 1")
       move = "W" #checkMove("W")
       return move
     else
       @@logger.log("getMove 2")
       move = "E" #checkMove("E")
       return move
     end  
   end
    
   if(@startLoc.col > theSquare.col)
     if(@startLoc.col - theSquare.col >= @maxCols / 2)
       @@logger.log("getMove 3")
       move = "E" #checkMove("E")        return move
     else
       @@logger.log("getMove 4")
       move = "W" #checkMove("W")
       return move
     end
   end
    
   if(@startLoc.row < theSquare.row)
     if(theSquare.row - @startLoc.row >= @maxRows / 2)
        @@logger.log("getMove 5")
        move = "N" #checkMove("N")
        return move
     else
        @@logger.log("getMove 6")
        move = "S" #checkMove("S")
        return move
     end
   end
    
   if(@startLoc.row > theSquare.row)
     if(@startLoc.row - theSquare.row >= @maxRows / 2)
       @@logger.log("getMove 7")
       move = "S" #checkMove("S")
       return move
     else
       @@logger.log("getMove 8")
       move = "N" #checkMove("N")
       return move
     end
   end
  end #End getMove

  def haveSquare(testHashSquare) #see if we already have this square in the hash
     @@routeHash.each do |hashSquare, v|
       if (hashSquare.row == testHashSquare.row && hashSquare.col == testHashSquare.col)
         return true
       end
     end
     return false
  end

end #End class 
=begin   
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
=end    
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
=end