
## ============================================================
## I/O.
## ============================================================

class Machine

  @@ValidChars = ["a","b","c","d","e","f","g","h","i","j","k","l","m",
                  "n","o","p","q","r","s","t","u","v","w","x","y","z"]
  @@STATE_NORMAL = 0
  @@STATE_IN_TAG = 1
  @@TAGS_IGNORE = {
    "*<" => "*>",   # heading
    "**[" => "**]", # comment
    "{" => "}",     # deviant
  }
                      
  def initialize()
    @state = @@STATE_NORMAL
    @tag = nil
  end

  def clean(word)
    badChars = word.split("").each.select { |x| !@@ValidChars.include?(x) }
    badChars.each do |bad|
      word = word.gsub(bad, "")
    end
    return word
  end
  
  def feed(token)
    
    # Machine parsing regular input.
    if @state == @@STATE_NORMAL
      # found opening tag for some text you should ignore
      # move into inside tag ignore state, clean and return
      @@TAGS_IGNORE.keys.each do |key|
        if token.start_with?(key)
          if !token.end_with?(@@TAGS_IGNORE[key]) # check if tag ends on this token
            @state = @@STATE_IN_TAG
            @tag = key
          end
          return ""
        end
      end
      # regular token, clean and return\
      return self.clean(token)
   
    ### Machine in a tag whose contents should be ignored.
    elsif @state == @@STATE_IN_TAG
      closing = @@TAGS_IGNORE[@tag]
      if token.end_with?(closing)
        @state = @@STATE_NORMAL
        @tag = nil
      end
      return ""
    end
    
    raise SignalException("Mangled state: " + @state.to_s)
    
  end
  
  def process(line)
    line = line.downcase.split(" ")
    line.map! { |token| self.feed(token) }
    line.select { |token| token.size > 0 }
  end
  
  
end

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