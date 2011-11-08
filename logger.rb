class Logger

  attr_accessor :debug 
  def initialization
    @debug = false
  end
  def log(theLogMessage)
    if(@debug)
      logfile = File.new("/usr1/home/rob/ai_dev/AntsLog.txt", "a")
      logfile.write(theLogMessage + "\n")
      logfile.close  
    end
  end
end