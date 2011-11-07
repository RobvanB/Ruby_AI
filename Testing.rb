$:.unshift File.dirname($0)
require 'route.rb'
require 'logger.rb'
require 'robTest.rb'
require 'ruby-debug'

#Logger test
  @@logger = Logger.new
  debugger
  #@@logger.debug=true  
  @@logger.log('shazaam'+ 'something')
#End logger test


=begin

#Object test
  tc1 = Rob.new
  
  tc1.theParm="Shazaam"
  
  tc2 = tc1.dup
  
  #tc2.theParm="WHammo"
  
  puts tc1.theParm
  
  puts tc2.theParm
#End Object test


startLoc = {"row"=>1, "col"=>2}
endLoc   = {"row"=>1, "col"=>5}

route = Route.new 
route.setRoute(startLoc, endLoc) 

puts route.getDistance

newDir = route.getDirection()

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