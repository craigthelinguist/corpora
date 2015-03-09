
## ============================================================
## Global.
## ============================================================

$BUF_SIZE = 4
$BUF_IN
$BUF_OUT


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

$FPATH_IN = "input.txt"
$FPATH_OUT = "output.txt"
$FPATH_MORPHEMES = "morphemes-english.tsv"
$FPATH_COUNTS = "morpheme-counts.tsv"

# Raise IOError if input paths cannot be found.
def validateFpaths
  raise IOError, "Could not find " + $FPATH_IN unless File.file?($FPATH_IN)
  raise IOError, "Could not find " + $FPATH_OUT unless File.file?($FPATH_OUT)
  raise IOError, "Could not find " + $FPATH_MORPHEMES unless File.file?($FPATH_MORPHEMES)
  raise IOError, "Could not find " + $FPATH_COUTNS unless File.file?($FPATH_COUNTS)
end

# Load a hash table from a tab-separated file.
# Params:
# +fpath+:: name of file containing the data.
def loadHash(fpath)
  dict = Hash.new
  IO.foreach(fpath) do |line|
    contents = line.split("\t")
    morpheme = contents[0]
    definition = contents[1]
    dict[morpheme] = definition
  end
  dict
end


if __FILE__ == $PROGRAM_NAME
  
  # open files
  validateFpaths
  
  # load morpheme definitions into a hash
  dictionary = loadHash($FPATH_MORPHEMES)
 
  # load morpheme counts into a hash
  counts = loadHash($FPATH_COUNTS)
  
end

