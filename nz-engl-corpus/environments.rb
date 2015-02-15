
require "./machine"

## ============================================================
## Environments.
## ============================================================

class ShellEnv

  def initialize(machine)
    @machine = machine
  end
  
  def run
    puts "Enter stuff to be evaluated by the machine."
    puts "Type exit() to quit."
    while true
      print ">"
      input = gets.strip
      return if input == "exit()"
      words = @machine.process(input)
      words.each { |word| puts word }
    end
  end
  
end

class FileEnv
  
  def initialize(machine)
    @machine = machine
  end
  
  def run(fpath)
    file = File.new(fpath)
    dictionary = Hash.new(0)
    IO.foreach(file) do |line|
      line = line.split("-")
      line.each do |line|
        words = @machine.process(line)
        words.each { |word| dictionary[word] += 1 }
      end
    end
    file.close
    return dictionary
  end
  
  def save(fpath, dictionary)
    
    # load dict in current output file, if there is one
    other_dict = Hash.new(0)
    if File.exist?(fpath)
      File.open(fpath, "r") do |file|
        IO.foreach(file) do |line|
          line = line.split("\t")
          word, count = line[0], line[1]
          dictionary[word] += count
        end
      end
    end
    
    # combine dictionaries
    other_dict.each { |word, count| dictionary[word] += count }
     
    # write to output file
    File.open(fpath, "w") do |file|
      dictionary.each { |word, count| file.write word + "\t" + count.to_s + "\n" }
    end
    
  end
  
end

## ============================================================
## Main.
## ============================================================

if __FILE__ == $PROGRAM_NAME
  
  # init stuff
  mode = ""
  fpath_in = ""
  fpath_out = ""
  
  # parse command line arguments
  if ARGV.size == 0
    mode = "shell"
  elsif ARGV.size == 2
    fpath_in = ARGV[0]
    fpath_out = ARGV[1]
    abort("Could not find file " + fpath) unless File.exist?(fpath_in)
    mode = "file"
  else
    abort("Bad number of arguments: " + args.size.to_s)
  end
  
  # process stuff
  machine = Machine.new
  if mode == "shell"
    ShellEnv.new(machine).run
  elsif mode == "file"
    env = FileEnv.new(machine)
    puts("Started text processing.")
    dictionary = env.run(fpath_in)
    puts("Finished text processing.")
    puts("Saving.")
    env.save(fpath_out, dictionary)
    puts("Saved.")
  end
  
  puts "Finished"
  
end