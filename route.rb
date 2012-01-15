$:.unshift File.dirname('/var/lib/gems/1.8/gems/ruby-debug-0.10.4/cli/ruby-debug.rb')
$:.unshift File.dirname('/var/lib/gems/1.8/gems/ruby-debug-base-0.10.4/lib/ruby-debug-base.rb')
#require 'ruby-debug-ide'

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
    @@foundStart = false
    curSquare  = MapSquare.new
    curSquare.row = @endLoc.row
    curSquare.col = @endLoc.col
    @tmpMarkedHash = Hash.new
    @@routeHash.clear

    #Work through the map until we've found our starting point
    markedHash = mark4(i, curSquare ) # Mark the 4 squares around the current square

    while (!@@foundStart)
      markedHash.each do | k,v |
        if (!@@foundStart)
          returnedHash = mark4(i + 1, k)
          @tmpMarkedHash = @tmpMarkedHash.merge(returnedHash)
        end
      end

      markedHash = @tmpMarkedHash.dup
      @tmpMarkedHash.clear
      i += 1
    end

    #Now get the adjacent square with the lowest number
    @gotoSquare = nil
    #@@logger.log("StartLoc r/c: " + @startLoc.row.to_s + "/" + @startLoc.col.to_s)
    lowestNum = 999999
    @@routeHash.each do |k, v|
      if (checkNewLoc(k))
        if (v < lowestNum)
          lowestNum = v
          @gotoSquare = k
          #@@logger.log("LowestNum :" + lowestNum.to_s)
        end
      end
      @@logger.log(k.row.to_s + "/" + k.col.to_s + " count: " + v.to_s)
    end

    if (@gotoSquare == nil)
       @@routeHash.each do |k, v|
         print k
       end
    end

    #@@logger.log("GotoSquare of selected record: " + @gotoSquare.row.to_s + "/"+ @gotoSquare.col.to_s)
    returnMove = getMove(@gotoSquare)
    #@@orders[@gotoSquare] = "moved"
    #@@logger.log("Returning from getMove: " + returnMove)
    return returnMove
  end
  #End getDirection

  def mark4(_i, _mark4Square)
    # Set the counter (_i) for the 4 squares 'around' the target square
    mark4Hash = Hash.new
    testSquare = MapSquare.new
    #@@logger.log("Route while: Testing around Square r/c: " + curSquare.row.to_s + "/" + curSquare.col.to_s)
    testSquare.row = _mark4Square.row - 1
    testSquare.col = _mark4Square.col
    if (_mark4Square.row > 0 && !haveSquare(testSquare)) #valid row-col? / already in hash?
      if (checkNewLoc(testSquare))                    #Land and Ant?
        @@foundStart = @@foundStart || checkStartLoc(testSquare)
        #if (testSquare.row != @startLoc.row || testSquare.col != @startLoc.col) #Don't add the start square in the hash, otherwise it will pick that one to move to
        if (!isStartLoc(testSquare)) #Don't add the start square in the hash, otherwise it will pick that one to move to
          @@routeHash[testSquare.dup] = _i
          mark4Hash[testSquare.dup]   = _i
        end
      #else
      #  @@routeHash[testSquare.dup] = 0 #So it is marked as 'unusable square'
      end
    end

    testSquare.row = _mark4Square.row + 1
    testSquare.col = _mark4Square.col
    if (_mark4Square.row <= @maxRows && !haveSquare(testSquare))
      if (checkNewLoc(testSquare))
        @@foundStart = @@foundStart || checkStartLoc(testSquare)
        #if (testSquare.row != @startLoc.row || testSquare.col != @startLoc.col) #Don't add the start square in the hash, otherwise it will pick that one to move to
        if (!isStartLoc(testSquare)) #Don't add the start square in the hash, otherwise it will pick that one to move to
          @@routeHash[testSquare.dup] = _i
          mark4Hash[testSquare.dup] = _i
        end
      #else
      #  @@routeHash[testSquare.dup] = 0 #So it is marked as 'unusable square'
      end
    end

    testSquare.row = _mark4Square.row
    testSquare.col = _mark4Square.col - 1
    if (_mark4Square.col > 0 && !haveSquare(testSquare))
      if (checkNewLoc(testSquare))
        @@foundStart = @@foundStart || checkStartLoc(testSquare)
        #if (testSquare.row != @startLoc.row || testSquare.col != @startLoc.col) #Don't add the start square in the hash, otherwise it will pick that one to move to
        if (!isStartLoc(testSquare)) #Don't add the start square in the hash, otherwise it will pick that one to move to
          @@routeHash[testSquare.dup] = _i
          mark4Hash[testSquare.dup] = _i
        end
      #else
      #  @@routeHash[testSquare.dup] = 0 #So it is marked as 'unusable square'
      end
    end

    testSquare.row = _mark4Square.row
    testSquare.col = _mark4Square.col + 1
    if (_mark4Square.col <= @maxCols && !haveSquare(testSquare))
      if (checkNewLoc(testSquare))
        @@foundStart = @@foundStart || checkStartLoc(testSquare)
        #if (testSquare.row != @startLoc.row || testSquare.col != @startLoc.col) #Don't add the start square in the hash, otherwise it will pick that one to move to
        if (!isStartLoc(testSquare)) #Don't add the start square in the hash, otherwise it will pick that one to move to
          @@routeHash[testSquare.dup] = _i
          mark4Hash[testSquare.dup] = _i
        end
      #else
      #  @@routeHash[testSquare.dup] = 0 #So it is marked as 'unusable square'
      end
    end
    return mark4Hash
  end #End mark4 method
  def isStartLoc(mapSquare)
    if (mapSquare.row == @startLoc.row && mapSquare.col == @startLoc.row)
      return true
    else
      return false
    end
  end


  def checkNewLoc(newLocSquare) #make sure it's land and no ant, and that we've not already sent an ant there
    checkLoc = @map[newLocSquare.row][newLocSquare.col]
    
    if (checkLoc.land? && !checkLoc.ant? && !@@orders.has_key?(checkLoc))
      #@@logger.log("Checkloc is land - no ant " + newLocSquare.row.to_s + "/" + newLocSquare.col.to_s)
      return true
    else
      #@@logger.log("Checkloc land or ant" + newLocSquare.row.to_s + "/" + newLocSquare.col.to_s)
      return false
    end
  end #End checkNewLoc 
    
  def checkStartLoc(mapSquare) #Returns true if the square is *adjacent* to the start square
    if (
          ((mapSquare.row == @startLoc.row + 1 || mapSquare.row == @startLoc.row - 1) && mapSquare.col == @startLoc.col) ||
          ((mapSquare.col == @startLoc.col + 1 || mapSquare.col == @startLoc.col - 1) && mapSquare.row == @startLoc.row)
       )
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