$:.unshift File.dirname($0)
require 'route.rb'
require 'logger.rb'
require 'robTest.rb'
#require 'ruby-debug.rb'

class FoodList
  attr_accessor :food
  attr_accessor :ant
  attr_accessor :distance
end

foodArray = []

foodList = FoodList.new

foodList.food     = 'f3'
foodList.ant      = 'a3'
foodList.distance = 31
foodArray.push(foodList.dup)

foodList.food     = 'f1'
foodList.ant      = 'a1'
foodList.distance = 1
foodArray.push(foodList.dup)

foodList.food     = 'f2'
foodList.ant      = 'a2'
foodList.distance = 2
foodArray.push(foodList.dup)

foodTmp = FoodList.new

foodArray.each do |food|
  foodTmp = food
  puts foodTmp.ant
end

foodArray.sort! { ||}

=begin
testh = Hash.new

testh['abc'] = 'blammo'
testh['abc'] = 'blammo'
testh['abc'] = 'blammo'
testh['abc'] = 'blammo'
testh['abc'] = 'blammo'

testh.each do |key, value|
  puts key + " " + value
end


class HillHolder
  attr_accessor :hill
  attr_accessor :mainAnt
  attr_accessor :buddy
  
  def setHill(hill, mainAnt, buddy)
    @hill, @mainAnt, @buddy = hill, mainAnt, buddy
  end
end

hillHolder = HillHolder.new
hillHolderArray = Array.new

#hillHolder.hill = 'h1'
#hillHolder.mainAnt = 'm1'
#hillHolder.buddy = 'b1'

hillHolder.setHill("h1", "m1","b1")

hillHolderArray.push(hillHolder.dup)

#hillHolder.hill = 'h2'
#hillHolder.mainAnt = 'm2'
#hillHolder.buddy = 'b2'

hillHolder.setHill("h2", "m2","b2")
hillHolderArray.push(hillHolder.dup)

hillHolderArray.each do |hill|
  #puts hill.hill
  #puts hill.mainAnt
  if (hill.hill == "h2")
    hill.buddy = "b3"
  end
  #puts hill.buddy
end

hillHolderArray.each do |hill|
  puts hill.hill + " " + hill.mainAnt + " " + hill.buddy
end

#Logger test
  @@logger = Logger.new
  #debugger
  #@@logger.debug=true  
  @@logger.log('shazaam'+ 'something')
#End logger test




#Object test
  tc1 = Rob.new
  
  tc1.theParm="Shazaam"
  
  tc2 = tc1.dup
  
  #tc2.theParm="WHammo"
  
  puts tc1.theParm
  
  puts tc2.theParm
#End Object test

class AntLocation
  attr_accessor :row
  attr_accessor :col
end

startLoc = AntLocation.new
startLoc.row = 26
startLoc.col = 25
endLoc   = AntLocation.new
endLoc.row = 21
endLoc.col = 25

route = Route.new 
route.setRoute(startLoc, endLoc, 42, 38 ) 

puts route.getDistance

puts route.getDirection()

=begin
#puts newDir["ewMove"]
#puts newDir["nsMove"]
myList = Hash.new
myList["A"] = 2
myList["notherone"] = 1
myList["otherKey"] = 4
myList["whatEver"] = 3

myArray = myList.sort_by{|theKey, theNumber| theNumber} 

puts myArray[0][0]
puts myArray[0][1]
puts myArray[1][0]
puts myArray[1][1]


  @rows = 5
  @cols = 10
  
  puts "start"
  
  rc = 0
  while rc <= @rows
    cc = 0
    while cc <= @cols
      puts "cc" + cc.to_s
      cc += 1
    end 
    puts "rc" + rc.to_s
    rc += 1
  end
=end 