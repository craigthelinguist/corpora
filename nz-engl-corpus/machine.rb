
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
