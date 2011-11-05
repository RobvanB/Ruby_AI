$:.unshift File.dirname($0)
require 'route.rb'

startLoc = {"row"=>1, "col"=>2}
endLoc   = {"row"=>1, "col"=>5}

route = Route.new 
route.setRoute(startLoc, endLoc) 

puts route.getDistance

newDir = route.getDirection(startLoc, endLoc)

puts newDir["ewMove"]
puts newDir["nsMove"]

=begin
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