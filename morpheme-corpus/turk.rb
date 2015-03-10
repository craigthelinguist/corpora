

## ============================================================
## Global constants.
## ============================================================
$FPATH_IN = "input.txt"
$FPATH_OUT = "output.txt"
$FPATH_MORPHEMES = "morphemes-english.tsv"
$FPATH_COUNTS = "morpheme-counts.tsv"


## ============================================================
## Functions.
## ============================================================

# Get user input specifying how the word should be segmented.
# Params:
# +word+:: word to segment.
# +dictionary+:: dictionary of known morphemes.
def segment(word, dictionary)
  
  # display all morphemes that are substrings of the current word
  puts "-----------------"
  dictionary.each do |morpheme, definition|
    if word.include? morpheme
      puts morpheme + " ---> " + definition
    end
  end
    
  loop do
    # get user segmentation of the word
    puts "-----------------"
    puts word
    segment = gets
  
    # check segmentation was valid
    if not segment.tr('-', '') == word
      puts "Your segmentation is bad (missing some characters from original word)"
    elsif not segment.include? "-"
      puts "No segments. Type 'y' or 'yes' if this is correct"
      input = gets.rstrip
      if input == "y" or input == "yes"
        return segment
      end
    else
      return segment
    end
  
  end
  
end


## ============================================================
## I/O.
## ============================================================

# Raise IOError if input paths cannot be found.
def validateFpaths
  raise IOError, "Could not find " + $FPATH_IN unless File.file?($FPATH_IN)
  raise IOError, "Could not find " + $FPATH_OUT unless File.file?($FPATH_OUT)
  raise IOError, "Could not find " + $FPATH_MORPHEMES unless File.file?($FPATH_MORPHEMES)
  raise IOError, "Could not find " + $FPATH_COUNTS unless File.file?($FPATH_COUNTS)
end

# Load a hash table from a tab-separated file.
# Params:
# +fpath+:: name of file containing the data.
# +hash+:: the hash to put the data into.
def loadHash(fpath, hash)
  IO.foreach(fpath) do |line|
    contents = line.split("\t")
    morpheme = contents[0]
    definition = contents[1]
    hash[morpheme] = definition
  end
  return hash
end

# Trim a file by removing a specified number of lines from the start.
# Params:
# +fpath+:: name of file to trim.
# +toTrim+:: number of lines to trim from start of file.
def trimFile (fpath, toTrim)
  # todo....
end

# Save morpheme counts to specified file.
# Params:
# +fpath+:: name of file to save to.
# +counts+:: morpheme frequency counts.
def saveCounts (fpath, counts)
  # todo.....
end

## ============================================================
## Main.
## ============================================================

if __FILE__ == $PROGRAM_NAME
  
  # open files
  validateFpaths
  
  # load morpheme definitions into a hash
  dictionary = loadHash($FPATH_MORPHEMES, Hash.new)
 
  # load morpheme counts into a hash
  counts = loadHash($FPATH_COUNTS, Hash.new(0))
  
  # load input file.
  REFRESH = 10 # how many lines before refreshing the file
  loop do
  
    # open file and segment
    count = 0 # number of lines read
    IO.foreach($FPATH_IN) do |line|
      break unless count < REFRESH
      segmentation = segment(line, dictionary)
      split = segmentation.split("-")
      # atm just endlessly prints the lines
    split.each { |m| counts[m] += 1 }
    end
    
    # refresh input file and counts file
    saveCounts($FPATH_COUNTS, counts)
    trimFile($FPATH_IN, count)
    
  end
  
end

