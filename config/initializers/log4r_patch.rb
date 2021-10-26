class Log4r::Logger
  def formatter()
    Proc.new{|severity, time, progname, msg|
      formatted_severity = sprintf("%-5s",severity.to_s)
      formatted_time = time.strftime("%Y-%m-%d %H:%M:%S")
      "[#{formatted_severity} #{formatted_time} #{$$}]\n #{msg}\n"
    }
  end
  def formatter=(temp)
  end
end

