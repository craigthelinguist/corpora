
## ============================================================
## Global.
## ============================================================

$BUF_SIZE = 4
$BUF_IN
$BUF_OUT
$FPATH_IN = "input.txt"
$FPATH_OUT = "output.txt"

## ============================================================
## Classes.
## ============================================================

class Stream
  
  def initialize(fpath, write_args)
    @write_args = write_args
    @fpath = fpath
    open!
  end

  def read
    @file.readline
  end
  
  def readAll
    return @file.each.select { true }
  end

  def close!
    @file.close
  end
  
  def append(content)
    content.each { |x| @file.puts x }
  end
  
  def open!
    @file = File.new(@fpath, @write_args)
  end
  
  def reload!
    @file.close
    @file = File.new(@fpath, @write_args)
    @open = true
  end
  
  def empty?
    return @file.eof
  end
    
end


## ============================================================
## Functions.
## ============================================================

def segment(morpheme)
  
  puts morpheme
  print ">"
  segmentation = gets
  
end


## ============================================================
## Meta-functions.
## ============================================================

def terminate(err_msg)
  puts err_msg
  if $IN
    $IN.close
  end
  if $OUT
    $OUT.close
  end
end


## ============================================================
## Main.
## ============================================================

if __FILE__ == $PROGRAM_NAME
  
  # open files
  raise IOError, "Could not find " + $FPATH_IN unless File.file?($FPATH_IN)
  raise IOError, "Could not find " + $FPATH_OUT unless File.file?($FPATH_OUT)
    
  $BUF_IN = Stream.new($FPATH_IN, "r")
  $BUF_OUT = Stream.new($FPATH_OUT, "a")

  while !$BUF_IN.empty?
    
    # read in morphemes from input file
    morphemes = []
    for i in 1..$BUF_SIZE
      break if $BUF_IN.empty?
      morphemes.push($BUF_IN.read)
    end
    
    # get user to segment
    segmentations = []
    morphemes.each do |line|
      segmentation = segment(line)
      segmentations.push(segmentation.split("-"))
    end
    
    # close the input file
    $BUF_OUT.append(segmentations)
    remainder = $BUF_IN.readAll
    $BUF_IN.close!
    
    # write changes to input file
    out = File.new($FPATH_IN, "w")
    remainder.each { |x| out.puts x }
    out.close
    
    # reopen input file
    $BUF_IN = Stream.new($FPATH_IN, "r")
          
  end 
    
  puts "Finished."
  
end

