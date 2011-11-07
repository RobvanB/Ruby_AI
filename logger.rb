class Logger

  def log(theLogMessage)
    logfile = File.new("/usr1/home/rob/ai_dev/AntsLog.txt", "a")
    logfile.write (theLogMessage + "\n")
    logfile.close
  end

end